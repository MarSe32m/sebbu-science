// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

/// Adaptive integration on a finite interval using the embedded 10-point
/// Gauss and 21-point Kronrod rules.
public enum GaussKronrod21 {
    /// Information about a completed integration.
    public struct Result<Value: AlgebraicField> {
        public enum Reason: Sendable, Equatable {
            /// The sum of the local error estimates satisfied the requested
            /// absolute or relative tolerance.
            case converged
            /// Refinement would exceed `maximumSubintervals`.
            case maximumSubintervals
            /// The largest-error interval could no longer be bisected in the
            /// floating-point representation used for the integration axis.
            case intervalTooSmall
            /// The integrand or the quadrature arithmetic produced a
            /// non-finite value.
            case nonFiniteIntegrand
        }

        /// The best available approximation to the integral.
        public let value: Value
        /// Sum of the estimated absolute errors of the final subintervals.
        public let estimatedAbsoluteError: Value.Magnitude
        /// Approximation to the integral of the norm of the integrand.
        public let absoluteIntegral: Value.Magnitude
        /// Number of calls made to the integrand.
        public let functionEvaluations: Int
        /// Number of subintervals in the final adaptive partition.
        public let subintervals: Int
        public let reason: Reason

        @inlinable
        public var converged: Bool { reason == .converged }

        @inlinable
        public init(
            value: Value,
            estimatedAbsoluteError: Value.Magnitude,
            absoluteIntegral: Value.Magnitude,
            functionEvaluations: Int,
            subintervals: Int,
            reason: Reason
        ) {
            self.value = value
            self.estimatedAbsoluteError = estimatedAbsoluteError
            self.absoluteIntegral = absoluteIntegral
            self.functionEvaluations = functionEvaluations
            self.subintervals = subintervals
            self.reason = reason
        }
    }

    /// Integrates a real double-precision function over a finite interval.
    @inlinable
    public static func integrate(
        a: Double,
        b: Double,
        absoluteTolerance: Double = 1e-10,
        relativeTolerance: Double = 1e-10,
        maximumSubintervals: Int = 1024,
        f: (Double) -> Double
    ) -> Result<Double> {
        _integrate(
            a: a,
            b: b,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            maximumSubintervals: maximumSubintervals,
            rule: doubleRule,
            makeValue: { $0 },
            norm: { Swift.abs($0) },
            f: f
        )
    }

    /// Integrates a complex double-precision function over a finite interval.
    /// Error control uses the Euclidean modulus of complex values.
    @inlinable
    public static func integrate(
        a: Double,
        b: Double,
        absoluteTolerance: Double = 1e-10,
        relativeTolerance: Double = 1e-10,
        maximumSubintervals: Int = 1024,
        f: (Double) -> Complex<Double>
    ) -> Result<Complex<Double>> {
        _integrate(
            a: a,
            b: b,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            maximumSubintervals: maximumSubintervals,
            rule: doubleRule,
            makeValue: { Complex<Double>($0) },
            norm: { $0.length },
            f: f
        )
    }

    /// Integrates a real single-precision function over a finite interval.
    @inlinable
    public static func integrate(
        a: Float,
        b: Float,
        absoluteTolerance: Float = 1e-5,
        relativeTolerance: Float = 1e-5,
        maximumSubintervals: Int = 1024,
        f: (Float) -> Float
    ) -> Result<Float> {
        _integrate(
            a: a,
            b: b,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            maximumSubintervals: maximumSubintervals,
            rule: floatRule,
            makeValue: { $0 },
            norm: { Swift.abs($0) },
            f: f
        )
    }

    /// Integrates a complex single-precision function over a finite interval.
    /// Error control uses the Euclidean modulus of complex values.
    @inlinable
    public static func integrate(
        a: Float,
        b: Float,
        absoluteTolerance: Float = 1e-5,
        relativeTolerance: Float = 1e-5,
        maximumSubintervals: Int = 1024,
        f: (Float) -> Complex<Float>
    ) -> Result<Complex<Float>> {
        _integrate(
            a: a,
            b: b,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            maximumSubintervals: maximumSubintervals,
            rule: floatRule,
            makeValue: { Complex<Float>($0) },
            norm: { $0.length },
            f: f
        )
    }
}

extension GaussKronrod21.Result: Sendable
where Value: Sendable, Value.Magnitude: Sendable {}

internal extension GaussKronrod21 {
    @usableFromInline
    struct Rule<Scalar: Real & Sendable>: Sendable {
        @usableFromInline
        let nodes: [Scalar]
        @usableFromInline
        let gaussWeights: [Scalar]
        @usableFromInline
        let kronrodWeights: [Scalar]
    }

    @usableFromInline
    static let doubleRule = Rule<Double>(
        nodes: [
            0.9956571630258081,
            0.9739065285171717,
            0.9301574913557082,
            0.8650633666889845,
            0.7808177265864169,
            0.6794095682990244,
            0.5627571346686047,
            0.4333953941292472,
            0.2943928627014602,
            0.1488743389816312,
            0.0,
        ],
        gaussWeights: [
            0.06667134430868814,
            0.1494513491505806,
            0.2190863625159820,
            0.2692667193099964,
            0.2955242247147529,
        ],
        kronrodWeights: [
            0.01169463886737187,
            0.03255816230796473,
            0.05475589657435200,
            0.07503967481091995,
            0.09312545458369761,
            0.1093871588022976,
            0.1234919762620659,
            0.1347092173114733,
            0.1427759385770601,
            0.1477391049013385,
            0.1494455540029169,
        ]
    )

    @usableFromInline
    static let floatRule = Rule<Float>(
        nodes: doubleRule.nodes.map { Float($0) },
        gaussWeights: doubleRule.gaussWeights.map { Float($0) },
        kronrodWeights: doubleRule.kronrodWeights.map { Float($0) }
    )
    
    @usableFromInline
    struct Panel<Value: AlgebraicField, Scalar: Real> where Value.Magnitude == Scalar {
        @usableFromInline
        let lowerBound: Scalar
        @usableFromInline
        let upperBound: Scalar
        @usableFromInline
        let value: Value
        @usableFromInline
        let error: Scalar
        @usableFromInline
        let absoluteIntegral: Scalar
        
        @inlinable
        init(lowerBound: Scalar, upperBound: Scalar, value: Value, error: Scalar, absoluteIntegral: Scalar) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
            self.value = value
            self.error = error
            self.absoluteIntegral = absoluteIntegral
        }
    }

    @usableFromInline
    struct PanelMaxHeap<Value: AlgebraicField, Scalar: Real> where Value.Magnitude == Scalar {
        @usableFromInline
        var storage: [Panel<Value, Scalar>] = []
        
        @inlinable
        var count: Int { storage.count }
        
        @inlinable
        init() {}
        
        @inlinable
        mutating func insert(_ panel: Panel<Value, Scalar>) {
            storage.append(panel)

            var child = storage.count - 1
            while child > 0 {
                let parent = (child - 1) / 2
                guard storage[child].error > storage[parent].error else {
                    break
                }
                storage.swapAt(child, parent)
                child = parent
            }
        }

        @inlinable
        mutating func popMaximum() -> Panel<Value, Scalar>? {
            guard !storage.isEmpty else { return nil }
            guard storage.count > 1 else { return storage.removeLast() }

            let maximum = storage[0]
            let last = storage.removeLast()
            storage[0] = last

            var parent = 0
            while true {
                let left = 2 * parent + 1
                guard left < storage.count else { break }

                let right = left + 1
                var largerChild = left
                if right < storage.count,
                   storage[right].error > storage[left].error
                {
                    largerChild = right
                }

                guard storage[largerChild].error
                    > storage[parent].error
                else {
                    break
                }

                storage.swapAt(parent, largerChild)
                parent = largerChild
            }

            return maximum
        }
    }

    /// Kahan accumulation also applies component-wise to complex values.
    @usableFromInline
    struct CompensatedSum<Value: AlgebraicField> {
        @usableFromInline
        var sum: Value
        @usableFromInline
        var compensation: Value = .zero

        @inlinable
        init(_ initialValue: Value = .zero) {
            sum = initialValue
        }

        @inlinable
        var value: Value { sum }

        @inlinable
        mutating func add(_ value: Value) {
            let adjusted = value - compensation
            let updated = sum + adjusted
            compensation = (updated - sum) - adjusted
            sum = updated
        }
    }
    
    @inlinable
    static func _integrate<Value: AlgebraicField, Scalar: Real & Sendable>(
        a: Scalar,
        b: Scalar,
        absoluteTolerance: Scalar,
        relativeTolerance: Scalar,
        maximumSubintervals: Int,
        rule: Rule<Scalar>,
        makeValue: (Scalar) -> Value,
        norm: (Value) -> Scalar,
        f: (Scalar) -> Value
    ) -> Result<Value> where Value.Magnitude == Scalar {
        precondition(
            !a.isNaN && !b.isNaN && a.isFinite && b.isFinite,
            "GaussKronrod21 requires finite integration bounds."
        )
        precondition(
            absoluteTolerance.isFinite && absoluteTolerance >= .zero,
            "The absolute tolerance must be finite and nonnegative."
        )
        precondition(
            relativeTolerance.isFinite && relativeTolerance >= .zero,
            "The relative tolerance must be finite and nonnegative."
        )
        precondition(
            absoluteTolerance > .zero || relativeTolerance > .zero,
            "At least one tolerance must be positive."
        )
        precondition(
            maximumSubintervals >= 1,
            "At least one subinterval must be allowed."
        )

        guard a != b else {
            return Result(
                value: .zero,
                estimatedAbsoluteError: .zero,
                absoluteIntegral: .zero,
                functionEvaluations: 0,
                subintervals: 0,
                reason: .converged
            )
        }

        let reverseResult = a > b
        let lowerBound = Swift.min(a, b)
        let upperBound = Swift.max(a, b)

        var functionEvaluations = 0
        guard let initialPanel = estimatePanel(
            f,
            lowerBound: lowerBound,
            upperBound: upperBound,
            rule: rule,
            makeValue: makeValue,
            norm: norm,
            functionEvaluations: &functionEvaluations
        ) else {
            return Result(
                value: makeValue(.nan),
                estimatedAbsoluteError: .infinity,
                absoluteIntegral: .infinity,
                functionEvaluations: functionEvaluations,
                subintervals: 0,
                reason: .nonFiniteIntegrand
            )
        }

        var panels = PanelMaxHeap<Value, Scalar>()
        panels.insert(initialPanel)

        var valueSum = CompensatedSum(initialPanel.value)
        var errorSum = CompensatedSum(initialPanel.error)
        var absoluteSum = CompensatedSum(initialPanel.absoluteIntegral)
        var reason: Result<Value>.Reason = .converged

        while true {
            let totalValue = valueSum.value
            let totalError = Swift.max(.zero, errorSum.value)
            let totalNorm = norm(totalValue)

            guard totalNorm.isFinite && totalError.isFinite else {
                reason = .nonFiniteIntegrand
                break
            }

            let requestedError = Swift.max(
                absoluteTolerance,
                relativeTolerance * totalNorm
            )

            if totalError <= requestedError {
                reason = .converged
                break
            }

            if panels.count >= maximumSubintervals {
                reason = .maximumSubintervals
                break
            }

            guard let worstPanel = panels.popMaximum() else {
                reason = .intervalTooSmall
                break
            }

            let two: Scalar = 2
            let midpoint: Scalar =
                worstPanel.lowerBound / two
                + worstPanel.upperBound / two

            guard midpoint > worstPanel.lowerBound,
                  midpoint < worstPanel.upperBound
            else {
                panels.insert(worstPanel)
                reason = .intervalTooSmall
                break
            }

            guard let leftPanel = estimatePanel(
                f,
                lowerBound: worstPanel.lowerBound,
                upperBound: midpoint,
                rule: rule,
                makeValue: makeValue,
                norm: norm,
                functionEvaluations: &functionEvaluations
            ), let rightPanel = estimatePanel(
                f,
                lowerBound: midpoint,
                upperBound: worstPanel.upperBound,
                rule: rule,
                makeValue: makeValue,
                norm: norm,
                functionEvaluations: &functionEvaluations
            ) else {
                panels.insert(worstPanel)
                reason = .nonFiniteIntegrand
                break
            }

            valueSum.add(-worstPanel.value)
            valueSum.add(leftPanel.value)
            valueSum.add(rightPanel.value)

            errorSum.add(-worstPanel.error)
            errorSum.add(leftPanel.error)
            errorSum.add(rightPanel.error)

            absoluteSum.add(-worstPanel.absoluteIntegral)
            absoluteSum.add(leftPanel.absoluteIntegral)
            absoluteSum.add(rightPanel.absoluteIntegral)

            panels.insert(leftPanel)
            panels.insert(rightPanel)
        }

        if reason == .nonFiniteIntegrand {
            return Result(
                value: makeValue(.nan),
                estimatedAbsoluteError: .infinity,
                absoluteIntegral: .infinity,
                functionEvaluations: functionEvaluations,
                subintervals: panels.count,
                reason: reason
            )
        }

        return Result(
            value: reverseResult ? -valueSum.value : valueSum.value,
            estimatedAbsoluteError: Swift.max(.zero, errorSum.value),
            absoluteIntegral: Swift.max(.zero, absoluteSum.value),
            functionEvaluations: functionEvaluations,
            subintervals: panels.count,
            reason: reason
        )
    }

    @inlinable
    static func estimatePanel<
        Value: AlgebraicField,
        Scalar: Real & Sendable
    >(
        _ f: (Scalar) -> Value,
        lowerBound: Scalar,
        upperBound: Scalar,
        rule: Rule<Scalar>,
        makeValue: (Scalar) -> Value,
        norm: (Value) -> Scalar,
        functionEvaluations: inout Int
    ) -> Panel<Value, Scalar>? where Value.Magnitude == Scalar {
        let two: Scalar = 2
        let midpoint: Scalar = lowerBound / two + upperBound / two
        let halfWidth: Scalar = upperBound / two - lowerBound / two

        let midpointValue: Value = f(midpoint)
        functionEvaluations += 1
        guard norm(midpointValue).isFinite else { return nil }

        var gaussSum: Value = .zero
        var kronrodSum: Value =
            makeValue(rule.kronrodWeights[10]) * midpointValue
        var absoluteSum: Scalar =
            rule.kronrodWeights[10] * norm(midpointValue)

        var leftValues = Array(repeating: Value.zero, count: 10)
        var rightValues = Array(repeating: Value.zero, count: 10)

        for index in 0..<10 {
            let offset: Scalar = halfWidth * rule.nodes[index]
            let leftValue: Value = f(midpoint - offset)
            let rightValue: Value = f(midpoint + offset)
            functionEvaluations += 2

            let leftNorm: Scalar = norm(leftValue)
            let rightNorm: Scalar = norm(rightValue)
            guard leftNorm.isFinite && rightNorm.isFinite else { return nil }

            leftValues[index] = leftValue
            rightValues[index] = rightValue

            let pairSum: Value = leftValue + rightValue
            kronrodSum += makeValue(rule.kronrodWeights[index]) * pairSum
            let pairNorm: Scalar = leftNorm + rightNorm
            absoluteSum += rule.kronrodWeights[index] * pairNorm

            // Swift indices 1, 3, 5, 7 and 9 are the G10 nodes.
            if index % 2 == 1 {
                gaussSum += makeValue(rule.gaussWeights[index / 2])
                    * pairSum
            }
        }

        let oneHalf: Scalar = 1 / two
        let meanValue: Value = makeValue(oneHalf) * kronrodSum
        var deviationSum: Scalar = rule.kronrodWeights[10]
            * norm(midpointValue - meanValue)

        for index in 0..<10 {
            let pairDeviation: Scalar =
                norm(leftValues[index] - meanValue)
                + norm(rightValues[index] - meanValue)
            deviationSum += rule.kronrodWeights[index] * pairDeviation
        }

        let widthValue: Value = makeValue(halfWidth)
        let kronrodValue: Value = widthValue * kronrodSum
        let gaussValue: Value = widthValue * gaussSum
        let absoluteIntegral: Scalar = halfWidth * absoluteSum
        let meanAbsoluteDeviation: Scalar = halfWidth * deviationSum

        var error: Scalar = norm(kronrodValue - gaussValue)
        if meanAbsoluteDeviation != .zero && error != .zero {
            let twoHundred: Scalar = 200
            let threeHalves: Scalar = 3 / two
            let scale = Scalar.pow(
                twoHundred * error / meanAbsoluteDeviation,
                threeHalves
            )
            error = meanAbsoluteDeviation
                * Swift.min(Scalar(1), scale)
        }

        let roundoffFactor: Scalar = Scalar(50) * Scalar.ulpOfOne
        if absoluteIntegral
            > Scalar.leastNormalMagnitude / roundoffFactor
        {
            error = Swift.max(
                error,
                roundoffFactor * absoluteIntegral
            )
        }

        guard norm(kronrodValue).isFinite,
              norm(gaussValue).isFinite,
              error.isFinite,
              absoluteIntegral.isFinite,
              meanAbsoluteDeviation.isFinite
        else {
            return nil
        }

        return Panel(
            lowerBound: lowerBound,
            upperBound: upperBound,
            value: kronrodValue,
            error: error,
            absoluteIntegral: absoluteIntegral
        )
    }
}
