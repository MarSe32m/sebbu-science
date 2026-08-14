// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import NumericsExtensions

public extension MatrixOperations {
    /// Controls the second modified Gram-Schmidt pass used by GMRES.
    enum GMRESReorthogonalization: Sendable {
        /// Use one modified Gram-Schmidt pass.
        case never
        /// Reorthogonalize when the first pass substantially reduces the norm.
        case whenNeeded
        /// Always use two modified Gram-Schmidt passes.
        case always
    }

    /// Information about a completed GMRES solve.
    struct GMRESResult<Magnitude: Real> {
        public enum Reason: Sendable, Equatable {
            case converged
            case maximumIterations
            case breakdown
            case nonFiniteResidual
        }

        /// Number of Arnoldi iterations performed.
        public let iterations: Int
        /// Total number of applications of the linear operator, including
        /// explicit residual checks.
        public let operatorApplications: Int
        /// Number of restarted Krylov cycles entered.
        public let restartCycles: Int
        /// Norm of the explicitly evaluated final residual.
        public let residualNorm: Magnitude
        /// Final residual norm divided by the right-hand-side norm. This is
        /// infinity when the right-hand side is zero and the residual is not.
        public let relativeResidualNorm: Magnitude
        /// Initial and per-iteration residual norms. Values within a restart
        /// cycle are inexpensive QR estimates; cycle boundaries are explicit
        /// residual evaluations.
        public let residualNormHistory: [Magnitude]
        public let reason: Reason

        @inlinable
        public var converged: Bool { reason == .converged }

        @inlinable
        public init(
            iterations: Int,
            operatorApplications: Int,
            restartCycles: Int,
            residualNorm: Magnitude,
            relativeResidualNorm: Magnitude,
            residualNormHistory: [Magnitude],
            reason: Reason
        ) {
            self.iterations = iterations
            self.operatorApplications = operatorApplications
            self.restartCycles = restartCycles
            self.residualNorm = residualNorm
            self.relativeResidualNorm = relativeResidualNorm
            self.residualNormHistory = residualNormHistory
            self.reason = reason
        }
    }

    /// Solves `Ax = b` using restarted GMRES for a real linear operator.
    ///
    /// `solution` contains the initial guess on entry and the best computed
    /// solution on return. The method minimizes the unpreconditioned residual
    /// and uses incremental Givens rotations rather than normal equations.
    @inlinable
    static func gmres<Operator: ~Copyable & LinearOperator, Scalar: Real>(
        linearOperator: borrowing Operator,
        b: borrowing UniqueVector<Scalar>,
        solution: inout UniqueVector<Scalar>,
        restart: Int = 30,
        maxIterations: Int = 1000,
        relativeTolerance: Scalar? = nil,
        absoluteTolerance: Scalar? = nil,
        reorthogonalization: GMRESReorthogonalization = .whenNeeded
    ) -> GMRESResult<Scalar> where Operator.Scalar == Scalar {
        _gmres(
            linearOperator: linearOperator,
            b: b,
            solution: &solution,
            restart: restart,
            maxIterations: maxIterations,
            relativeTolerance: relativeTolerance ?? 1 / 100_000_000,
            absoluteTolerance: absoluteTolerance ?? .zero,
            reorthogonalization: reorthogonalization,
            makeScalar: { $0 }
        )
    }

    /// Solves `Ax = b` using restarted GMRES for a complex linear operator.
    ///
    /// The Arnoldi inner product conjugates its first argument and the QR
    /// update uses complex unitary Givens rotations.
    @inlinable
    static func gmres<Operator: ~Copyable & LinearOperator, Scalar: Real>(
        linearOperator: borrowing Operator,
        b: borrowing UniqueVector<Complex<Scalar>>,
        solution: inout UniqueVector<Complex<Scalar>>,
        restart: Int = 30,
        maxIterations: Int = 1000,
        relativeTolerance: Scalar? = nil,
        absoluteTolerance: Scalar? = nil,
        reorthogonalization: GMRESReorthogonalization = .whenNeeded
    ) -> GMRESResult<Scalar> where Operator.Scalar == Complex<Scalar> {
        _gmres(
            linearOperator: linearOperator,
            b: b,
            solution: &solution,
            restart: restart,
            maxIterations: maxIterations,
            relativeTolerance: relativeTolerance ?? 1 / 100_000_000,
            absoluteTolerance: absoluteTolerance ?? .zero,
            reorthogonalization: reorthogonalization,
            makeScalar: { Complex($0) }
        )
    }

    @inlinable
    internal static func _gmres<
        Operator: ~Copyable & LinearOperator,
        Scalar: ConjugatableScalar,
        Magnitude: Real
    >(
        linearOperator: borrowing Operator,
        b: borrowing UniqueVector<Scalar>,
        solution: inout UniqueVector<Scalar>,
        restart: Int,
        maxIterations: Int,
        relativeTolerance: Magnitude,
        absoluteTolerance: Magnitude,
        reorthogonalization: GMRESReorthogonalization,
        makeScalar: (Magnitude) -> Scalar
    ) -> GMRESResult<Magnitude>
    where Operator.Scalar == Scalar, Scalar.Magnitude == Magnitude {
        precondition(linearOperator.rows == linearOperator.columns, "GMRES requires a square linear operator")
        precondition(linearOperator.rows > 0, "GMRES requires a non-empty linear operator")
        precondition(b.count == linearOperator.rows && solution.count == linearOperator.columns, "Vector dimensions do not match")
        precondition(restart > 0, "Restart must be positive")
        precondition(maxIterations >= 0, "Maximum iteration count must not be negative")
        precondition(relativeTolerance.isFinite && relativeTolerance >= .zero, "Relative tolerance must be finite and non-negative")
        precondition(absoluteTolerance.isFinite && absoluteTolerance >= .zero, "Absolute tolerance must be finite and non-negative")

        let dimension = linearOperator.rows
        let restartLength = min(restart, dimension)
        let leadingDimension = restartLength + 1
        let breakdownRelativeTolerance = 10 * Magnitude.ulpOfOne
        let reorthogonalizationThreshold: Magnitude = 717 / 1000

        // Basis vectors are rows so every vector is contiguous in memory.
        let basis: UniqueMatrix<Scalar> = .zeros(rows: leadingDimension, columns: dimension)
        var residual: UniqueVector<Scalar> = .zero(dimension)
        var work: UniqueVector<Scalar> = .zero(dimension)

        // The Hessenberg matrix is column-major here because GMRES constructs
        // and rotates one column at a time.
        var hessenberg = [Scalar](repeating: .zero, count: leadingDimension * restartLength)
        var cosines = [Scalar](repeating: .zero, count: restartLength)
        var sines = [Scalar](repeating: .zero, count: restartLength)
        var projectedRightHandSide = [Scalar](repeating: .zero, count: leadingDimension)
        var coefficients = [Scalar](repeating: .zero, count: restartLength)

        var iterations = 0
        var operatorApplications = 0
        var restartCycles = 0
        var residualNormHistory: [Magnitude] = []

        let rightHandSideNorm = _gmresNorm(b.components, count: dimension)
        let convergenceThreshold = max(absoluteTolerance, relativeTolerance * rightHandSideNorm)

        linearOperator.apply(solution, into: &work)
        operatorApplications += 1
        residual.copyComponents(from: b)
        residual.subtract(work)
        var residualNorm = _gmresNorm(residual.components, count: dimension)
        residualNormHistory.append(residualNorm)

        guard residualNorm.isFinite && rightHandSideNorm.isFinite else {
            return _gmresResult(
                iterations: iterations,
                operatorApplications: operatorApplications,
                restartCycles: restartCycles,
                residualNorm: residualNorm,
                rightHandSideNorm: rightHandSideNorm,
                residualNormHistory: residualNormHistory,
                reason: .nonFiniteResidual
            )
        }
        if residualNorm <= convergenceThreshold {
            return _gmresResult(
                iterations: iterations,
                operatorApplications: operatorApplications,
                restartCycles: restartCycles,
                residualNorm: residualNorm,
                rightHandSideNorm: rightHandSideNorm,
                residualNormHistory: residualNormHistory,
                reason: .converged
            )
        }

        while iterations < maxIterations {
            restartCycles += 1

            for i in hessenberg.indices { hessenberg[i] = .zero }
            for i in cosines.indices {
                cosines[i] = .zero
                sines[i] = .zero
                coefficients[i] = .zero
            }
            for i in projectedRightHandSide.indices { projectedRightHandSide[i] = .zero }

            let inverseResidualNorm = makeScalar(1 / residualNorm)
            for i in 0..<dimension {
                basis.elements[i] = Relaxed.product(residual.components[i], inverseResidualNorm)
            }
            projectedRightHandSide[0] = makeScalar(residualNorm)

            let innerIterationLimit = min(restartLength, maxIterations - iterations)
            var completedInnerIterations = 0
            var encounteredBreakdown = false

            for column in 0..<innerIterationLimit {
                let currentBasisVector = basis.elements.advanced(by: column * dimension)
                UniqueVector<Scalar>.withUnsafeComponents(currentBasisVector, count: dimension) { vector in
                    linearOperator.apply(vector, into: &work)
                }
                operatorApplications += 1

                let normBeforeOrthogonalization = _gmresNorm(work.components, count: dimension)
                guard normBeforeOrthogonalization.isFinite else {
                    return _gmresResult(
                        iterations: iterations,
                        operatorApplications: operatorApplications,
                        restartCycles: restartCycles,
                        residualNorm: residualNorm,
                        rightHandSideNorm: rightHandSideNorm,
                        residualNormHistory: residualNormHistory,
                        reason: .nonFiniteResidual
                    )
                }

                // One modified Gram-Schmidt pass.
                for row in 0...column {
                    let basisVector = basis.elements.advanced(by: row * dimension)
                    let projection = _gmresInner(basisVector, work.components, count: dimension)
                    hessenberg[column * leadingDimension + row] = projection
                    _gmresAdd(work.components, basisVector, multiplied: -projection, count: dimension)
                }

                let normAfterFirstPass = _gmresNorm(work.components, count: dimension)
                let shouldReorthogonalize = switch reorthogonalization {
                case .never:
                    false
                case .whenNeeded:
                    normAfterFirstPass <= reorthogonalizationThreshold * normBeforeOrthogonalization
                case .always:
                    true
                }

                if shouldReorthogonalize {
                    for row in 0...column {
                        let basisVector = basis.elements.advanced(by: row * dimension)
                        let correction = _gmresInner(basisVector, work.components, count: dimension)
                        let index = column * leadingDimension + row
                        hessenberg[index] = Relaxed.sum(hessenberg[index], correction)
                        _gmresAdd(work.components, basisVector, multiplied: -correction, count: dimension)
                    }
                }

                let nextBasisNorm = _gmresNorm(work.components, count: dimension)
                guard nextBasisNorm.isFinite else {
                    return _gmresResult(
                        iterations: iterations,
                        operatorApplications: operatorApplications,
                        restartCycles: restartCycles,
                        residualNorm: residualNorm,
                        rightHandSideNorm: rightHandSideNorm,
                        residualNormHistory: residualNormHistory,
                        reason: .nonFiniteResidual
                    )
                }

                hessenberg[column * leadingDimension + column + 1] = makeScalar(nextBasisNorm)
                encounteredBreakdown = normBeforeOrthogonalization == .zero
                    || nextBasisNorm <= breakdownRelativeTolerance * normBeforeOrthogonalization

                if !encounteredBreakdown {
                    let inverseNextBasisNorm = makeScalar(1 / nextBasisNorm)
                    let nextBasisVector = basis.elements.advanced(by: (column + 1) * dimension)
                    for i in 0..<dimension {
                        nextBasisVector[i] = Relaxed.product(work.components[i], inverseNextBasisNorm)
                    }
                }

                // Apply the rotations from all previous Arnoldi steps.
                for row in 0..<column {
                    let firstIndex = column * leadingDimension + row
                    let secondIndex = firstIndex + 1
                    let rotated = _gmresApplyGivens(
                        cosine: cosines[row],
                        sine: sines[row],
                        first: hessenberg[firstIndex],
                        second: hessenberg[secondIndex]
                    )
                    hessenberg[firstIndex] = rotated.first
                    hessenberg[secondIndex] = rotated.second
                }

                // Eliminate the new subdiagonal Hessenberg element.
                let diagonalIndex = column * leadingDimension + column
                let subdiagonalIndex = diagonalIndex + 1
                let rotation = _gmresGivens(
                    first: hessenberg[diagonalIndex],
                    second: hessenberg[subdiagonalIndex],
                    makeScalar: makeScalar
                )
                cosines[column] = rotation.cosine
                sines[column] = rotation.sine
                hessenberg[diagonalIndex] = rotation.result
                hessenberg[subdiagonalIndex] = .zero

                let rotatedRightHandSide = _gmresApplyGivens(
                    cosine: rotation.cosine,
                    sine: rotation.sine,
                    first: projectedRightHandSide[column],
                    second: projectedRightHandSide[column + 1]
                )
                projectedRightHandSide[column] = rotatedRightHandSide.first
                projectedRightHandSide[column + 1] = rotatedRightHandSide.second

                iterations += 1
                completedInnerIterations = column + 1
                let estimatedResidualNorm = projectedRightHandSide[column + 1].magnitude
                residualNormHistory.append(estimatedResidualNorm)

                guard estimatedResidualNorm.isFinite else {
                    return _gmresResult(
                        iterations: iterations,
                        operatorApplications: operatorApplications,
                        restartCycles: restartCycles,
                        residualNorm: residualNorm,
                        rightHandSideNorm: rightHandSideNorm,
                        residualNormHistory: residualNormHistory,
                        reason: .nonFiniteResidual
                    )
                }
                if estimatedResidualNorm <= convergenceThreshold || encounteredBreakdown {
                    break
                }
            }

            guard completedInnerIterations > 0 else { break }
            guard _gmresBackSubstitute(
                hessenberg: hessenberg,
                leadingDimension: leadingDimension,
                rightHandSide: projectedRightHandSide,
                count: completedInnerIterations,
                relativeTolerance: breakdownRelativeTolerance,
                into: &coefficients
            ) else {
                return _gmresResult(
                    iterations: iterations,
                    operatorApplications: operatorApplications,
                    restartCycles: restartCycles,
                    residualNorm: residualNorm,
                    rightHandSideNorm: rightHandSideNorm,
                    residualNormHistory: residualNormHistory,
                    reason: .breakdown
                )
            }

            // x += V_k y. Basis vectors are contiguous rows of `basis`.
            for row in 0..<completedInnerIterations {
                let basisVector = basis.elements.advanced(by: row * dimension)
                _gmresAdd(solution.components, basisVector, multiplied: coefficients[row], count: dimension)
            }

            // Recompute the true residual before accepting convergence or
            // beginning a restarted cycle.
            linearOperator.apply(solution, into: &work)
            operatorApplications += 1
            residual.copyComponents(from: b)
            residual.subtract(work)
            residualNorm = _gmresNorm(residual.components, count: dimension)
            residualNormHistory.append(residualNorm)

            guard residualNorm.isFinite else {
                return _gmresResult(
                    iterations: iterations,
                    operatorApplications: operatorApplications,
                    restartCycles: restartCycles,
                    residualNorm: residualNorm,
                    rightHandSideNorm: rightHandSideNorm,
                    residualNormHistory: residualNormHistory,
                    reason: .nonFiniteResidual
                )
            }
            if residualNorm <= convergenceThreshold {
                return _gmresResult(
                    iterations: iterations,
                    operatorApplications: operatorApplications,
                    restartCycles: restartCycles,
                    residualNorm: residualNorm,
                    rightHandSideNorm: rightHandSideNorm,
                    residualNormHistory: residualNormHistory,
                    reason: .converged
                )
            }
            if encounteredBreakdown {
                return _gmresResult(
                    iterations: iterations,
                    operatorApplications: operatorApplications,
                    restartCycles: restartCycles,
                    residualNorm: residualNorm,
                    rightHandSideNorm: rightHandSideNorm,
                    residualNormHistory: residualNormHistory,
                    reason: .breakdown
                )
            }
        }

        return _gmresResult(
            iterations: iterations,
            operatorApplications: operatorApplications,
            restartCycles: restartCycles,
            residualNorm: residualNorm,
            rightHandSideNorm: rightHandSideNorm,
            residualNormHistory: residualNormHistory,
            reason: .maximumIterations
        )
    }

    @inlinable
    internal static func _gmresResult<Magnitude: Real>(
        iterations: Int,
        operatorApplications: Int,
        restartCycles: Int,
        residualNorm: Magnitude,
        rightHandSideNorm: Magnitude,
        residualNormHistory: [Magnitude],
        reason: GMRESResult<Magnitude>.Reason
    ) -> GMRESResult<Magnitude> {
        let relativeResidualNorm: Magnitude
        if rightHandSideNorm == .zero {
            relativeResidualNorm = residualNorm == .zero ? .zero : .infinity
        } else {
            relativeResidualNorm = residualNorm / rightHandSideNorm
        }
        return .init(
            iterations: iterations,
            operatorApplications: operatorApplications,
            restartCycles: restartCycles,
            residualNorm: residualNorm,
            relativeResidualNorm: relativeResidualNorm,
            residualNormHistory: residualNormHistory,
            reason: reason
        )
    }
}

@inlinable
@inline(always)
internal func _gmresInner<Scalar: ConjugatableScalar>(
    _ lhs: UnsafePointer<Scalar>,
    _ rhs: UnsafePointer<Scalar>,
    count: Int
) -> Scalar {
    var result: Scalar = .zero
    for i in 0..<count {
        result = Relaxed.multiplyAdd(lhs[i].conjugate, rhs[i], result)
    }
    return result
}

@inlinable
@inline(always)
internal func _gmresAdd<Scalar: AlgebraicField>(
    _ result: UnsafeMutablePointer<Scalar>,
    _ vector: UnsafePointer<Scalar>,
    multiplied: Scalar,
    count: Int
) {
    for i in 0..<count {
        result[i] = Relaxed.multiplyAdd(multiplied, vector[i], result[i])
    }
}

@inlinable
internal func _gmresNorm<Scalar: AlgebraicField, Magnitude: Real>(
    _ vector: UnsafePointer<Scalar>,
    count: Int
) -> Magnitude where Scalar.Magnitude == Magnitude {
    // Scaled sum of squares, avoiding avoidable overflow and underflow.
    var scale: Magnitude = .zero
    var sumOfSquares: Magnitude = 1
    for i in 0..<count {
        let magnitude = vector[i].magnitude
        if !magnitude.isFinite { return magnitude }
        if magnitude == .zero { continue }
        if scale < magnitude {
            let ratio = scale / magnitude
            sumOfSquares = 1 + sumOfSquares * ratio * ratio
            scale = magnitude
        } else {
            let ratio = magnitude / scale
            sumOfSquares += ratio * ratio
        }
    }
    return scale == .zero ? .zero : scale * Magnitude.sqrt(sumOfSquares)
}

@inlinable
@inline(always)
internal func _gmresApplyGivens<Scalar: ConjugatableScalar>(
    cosine: Scalar,
    sine: Scalar,
    first: Scalar,
    second: Scalar
) -> (first: Scalar, second: Scalar) {
    (
        Relaxed.sum(Relaxed.product(cosine, first), Relaxed.product(sine, second)),
        Relaxed.sum(Relaxed.product(-sine.conjugate, first), Relaxed.product(cosine, second))
    )
}

@inlinable
internal func _gmresGivens<Scalar: ConjugatableScalar, Magnitude: Real>(
    first: Scalar,
    second: Scalar,
    makeScalar: (Magnitude) -> Scalar
) -> (cosine: Scalar, sine: Scalar, result: Scalar)
where Scalar.Magnitude == Magnitude {
    let firstMagnitude = first.magnitude
    let secondMagnitude = second.magnitude

    if secondMagnitude == .zero {
        return (makeScalar(1), .zero, first)
    }
    if firstMagnitude == .zero {
        let secondMagnitudeScalar = makeScalar(secondMagnitude)
        return (.zero, second.conjugate / secondMagnitudeScalar, secondMagnitudeScalar)
    }

    let upper = max(firstMagnitude, secondMagnitude)
    let lower = min(firstMagnitude, secondMagnitude)
    let ratio = lower / upper
    let norm = upper * Magnitude.sqrt(1 + ratio * ratio)
    let normScalar = makeScalar(norm)
    let phase = first / makeScalar(firstMagnitude)

    return (
        makeScalar(firstMagnitude / norm),
        phase * second.conjugate / normScalar,
        phase * normScalar
    )
}

@inlinable
internal func _gmresBackSubstitute<Scalar: ConjugatableScalar, Magnitude: Real>(
    hessenberg: [Scalar],
    leadingDimension: Int,
    rightHandSide: [Scalar],
    count: Int,
    relativeTolerance: Magnitude,
    into result: inout [Scalar]
) -> Bool where Scalar.Magnitude == Magnitude {
    var largestDiagonalMagnitude: Magnitude = .zero
    for i in 0..<count {
        largestDiagonalMagnitude = max(
            largestDiagonalMagnitude,
            hessenberg[i * leadingDimension + i].magnitude
        )
    }
    let threshold = relativeTolerance * largestDiagonalMagnitude

    for i in stride(from: count - 1, through: 0, by: -1) {
        let diagonal = hessenberg[i * leadingDimension + i]
        guard diagonal.magnitude > threshold else { return false }

        var value = rightHandSide[i]
        if i + 1 < count {
            for column in (i + 1)..<count {
                value = Relaxed.sum(
                    value,
                    -Relaxed.product(hessenberg[column * leadingDimension + i], result[column])
                )
            }
        }
        result[i] = value / diagonal
    }
    return true
}
