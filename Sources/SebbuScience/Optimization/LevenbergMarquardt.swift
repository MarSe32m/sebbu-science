//
//  LevenbergMarquardt.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 7.6.2026.
//

public extension Optimize {
    struct LevenbergMarquardtResult<Value> {
        public enum Reason {
            case residualTolerance
            case stepTolerance
            case costTolerance
            case gradientTolerance
            case maxIterations
            case linearSolveFailed
            case dampingTooLarge
        }

        public var parameters: Vector<Value>
        public var cost: Value
        public var iterations: Int
        public var damping: Value
        public var converged: Bool
        public var reason: Reason
        
        @inlinable
        public init(parameters: Vector<Value>, cost: Value, iterations: Int, damping: Value, converged: Bool, reason: Reason) {
            self.parameters = parameters
            self.cost = cost
            self.iterations = iterations
            self.damping = damping
            self.converged = converged
            self.reason = reason
        }
    }

    @inlinable
    static func levenbergMarquardt(
        initial: Vector<Double>,
        maxIterations: Int = 200,
        residualTolerance: Double = 1e-10,
        stepTolerance: Double = 1e-10,
        costTolerance: Double = 1e-12,
        gradientTolerance: Double = 1e-10,
        initialDamping: Double = 1e-3,
        dampingIncrease: Double = 10.0,
        dampingDecrease: Double = 0.3,
        minDamping: Double = 1e-30,
        maxDamping: Double = 1e30,
        residuals: (_ parameters: Vector<Double>) -> Vector<Double>,
        jacobian: ((_ parameters: Vector<Double>) -> Matrix<Double>)? = nil
    ) -> LevenbergMarquardtResult<Double> {
        var x = initial
        var lambda = initialDamping

        var r = residuals(x)
        var cost = 0.5 * r.normSquared

        for iteration in 0..<max(1, maxIterations) {
            let J = if let jacobian {
                jacobian(x)
            } else {
                finiteDifferenceJacobian(parameters: x, residual: residuals)
            }

            precondition(J.rows == r.count)
            precondition(J.columns == x.count)

            if r.norm <= residualTolerance {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: iteration,
                    damping: lambda,
                    converged: true,
                    reason: .residualTolerance
                )
            }

            let gradient = J.transpose.dot(r)

            if gradient.components.map({ abs($0) }).max() ?? 0.0 <= gradientTolerance {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: iteration,
                    damping: lambda,
                    converged: true,
                    reason: .gradientTolerance
                )
            }

            let scales = columnScales(J)

            var accepted = false

            while !accepted {
                if lambda > maxDamping {
                    return .init(
                        parameters: x,
                        cost: cost,
                        iterations: iteration,
                        damping: lambda,
                        converged: false,
                        reason: .dampingTooLarge
                    )
                }

                let system = augmentedLevenbergMarquardtSystem(
                    J: J,
                    r: r,
                    damping: lambda,
                    scales: scales
                )

                let step: Vector<Double>
                do {
                    step = try Optimize.linearLeastSquares(A: system.A, system.b).result
                } catch {
                    return .init(
                        parameters: x,
                        cost: cost,
                        iterations: iteration,
                        damping: lambda,
                        converged: false,
                        reason: .linearSolveFailed
                    )
                }

                if step.norm <= stepTolerance * (x.norm + stepTolerance) {
                    return .init(
                        parameters: x,
                        cost: cost,
                        iterations: iteration,
                        damping: lambda,
                        converged: true,
                        reason: .stepTolerance
                    )
                }

                let trialX = x + step
                let trialR = residuals(trialX)
                let trialCost = 0.5 * trialR.normSquared

                if trialCost < cost {
                    let oldCost = cost

                    x = trialX
                    r = trialR
                    cost = trialCost

                    lambda = max(minDamping, lambda * dampingDecrease)
                    accepted = true

                    if abs(oldCost - cost) <= costTolerance * max(1.0, oldCost) {
                        return .init(
                            parameters: x,
                            cost: cost,
                            iterations: iteration + 1,
                            damping: lambda,
                            converged: true,
                            reason: .costTolerance
                        )
                    }
                } else {
                    lambda *= dampingIncrease
                }
            }
        }

        return .init(
            parameters: x,
            cost: cost,
            iterations: maxIterations,
            damping: lambda,
            converged: false,
            reason: .maxIterations
        )
    }
    
    @inlinable
    static func levenbergMarquardt(
        initial: Vector<Float>,
        maxIterations: Int = 200,
        residualTolerance: Float = 1e-5,
        stepTolerance: Float = 1e-5,
        costTolerance: Float = 1e-6,
        gradientTolerance: Float = 1e-5,
        initialDamping: Float = 1e-3,
        dampingIncrease: Float = 10.0,
        dampingDecrease: Float = 0.3,
        minDamping: Float = 1e-30,
        maxDamping: Float = 1e30,
        residuals: (_ parameters: Vector<Float>) -> Vector<Float>,
        jacobian: ((_ parameters: Vector<Float>) -> Matrix<Float>)? = nil
    ) -> LevenbergMarquardtResult<Float> {
        var x = initial
        var lambda = initialDamping

        var r = residuals(x)
        var cost = 0.5 * r.normSquared

        for iteration in 0..<max(1, maxIterations) {
            let J = if let jacobian {
                jacobian(x)
            } else {
                finiteDifferenceJacobian(parameters: x, residual: residuals)
            }

            precondition(J.rows == r.count)
            precondition(J.columns == x.count)

            if r.norm <= residualTolerance {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: iteration,
                    damping: lambda,
                    converged: true,
                    reason: .residualTolerance
                )
            }

            let gradient = J.transpose.dot(r)
            
            if gradient.components.map({ abs($0) }).max() ?? 0.0 <= gradientTolerance {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: iteration,
                    damping: lambda,
                    converged: true,
                    reason: .gradientTolerance
                )
            }

            let scales = columnScales(J)

            var accepted = false

            while !accepted {
                if lambda > maxDamping {
                    return .init(
                        parameters: x,
                        cost: cost,
                        iterations: iteration,
                        damping: lambda,
                        converged: false,
                        reason: .dampingTooLarge
                    )
                }

                let system = augmentedLevenbergMarquardtSystem(
                    J: J,
                    r: r,
                    damping: lambda,
                    scales: scales
                )

                let step: Vector<Float>
                do {
                    step = try Optimize.linearLeastSquares(A: system.A, system.b).result
                } catch {
                    return .init(
                        parameters: x,
                        cost: cost,
                        iterations: iteration,
                        damping: lambda,
                        converged: false,
                        reason: .linearSolveFailed
                    )
                }

                if step.norm <= stepTolerance * (x.norm + stepTolerance) {
                    return .init(
                        parameters: x,
                        cost: cost,
                        iterations: iteration,
                        damping: lambda,
                        converged: true,
                        reason: .stepTolerance
                    )
                }

                let trialX = x + step
                let trialR = residuals(trialX)
                let trialCost = 0.5 * trialR.normSquared

                if trialCost < cost {
                    let oldCost = cost

                    x = trialX
                    r = trialR
                    cost = trialCost

                    lambda = max(minDamping, lambda * dampingDecrease)
                    accepted = true

                    if abs(oldCost - cost) <= costTolerance * max(1.0, oldCost) {
                        return .init(
                            parameters: x,
                            cost: cost,
                            iterations: iteration + 1,
                            damping: lambda,
                            converged: true,
                            reason: .costTolerance
                        )
                    }
                } else {
                    lambda *= dampingIncrease
                }
            }
        }

        return .init(
            parameters: x,
            cost: cost,
            iterations: maxIterations,
            damping: lambda,
            converged: false,
            reason: .maxIterations
        )
    }
}

@inlinable
package func columnScales(_ J: Matrix<Double>) -> [Double] {
    var scales = [Double](repeating: 1.0, count: J.columns)

    for j in 0..<J.columns {
        var s = 0.0
        for i in 0..<J.rows {
            let Jij = J[i, j]
            s += Jij * Jij
        }

        scales[j] = max(s.squareRoot(), 1e-12)
    }

    return scales
}

@inlinable
package func augmentedLevenbergMarquardtSystem(
    J: Matrix<Double>,
    r: Vector<Double>,
    damping: Double,
    scales: [Double]
) -> (A: Matrix<Double>, b: Vector<Double>) {
    let m = J.rows
    let n = J.columns
    let sqrtDamping = damping.squareRoot()

    var A: Matrix<Double> = .zeros(rows: m + n, columns: n)
    var b:Vector<Double> = .zero(m + n)

    for i in 0..<m {
        for j in 0..<n {
            A[i, j] = J[i, j]
        }

        b[i] = -r[i]
    }

    for j in 0..<n {
        A[m + j, j] = sqrtDamping * scales[j]
    }

    return (A, b)
}

@inlinable
package func columnScales(_ J: Matrix<Float>) -> [Float] {
    var scales = [Float](repeating: 1.0, count: J.columns)

    for j in 0..<J.columns {
        var s: Float = 0.0
        for i in 0..<J.rows {
            let Jij = J[i, j]
            s += Jij * Jij
        }

        scales[j] = max(s.squareRoot(), 1e-12)
    }

    return scales
}

@inlinable
package func augmentedLevenbergMarquardtSystem(
    J: Matrix<Float>,
    r: Vector<Float>,
    damping: Float,
    scales: [Float]
) -> (A: Matrix<Float>, b: Vector<Float>) {
    let m = J.rows
    let n = J.columns
    let sqrtDamping = damping.squareRoot()

    var A: Matrix<Float> = .zeros(rows: m + n, columns: n)
    var b:Vector<Float> = .zero(m + n)

    for i in 0..<m {
        for j in 0..<n {
            A[i, j] = J[i, j]
        }

        b[i] = -r[i]
    }

    for j in 0..<n {
        A[m + j, j] = sqrtDamping * scales[j]
    }

    return (A, b)
}
