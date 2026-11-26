// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

public extension Optimize {
    enum Extremum: Equatable, Sendable {
        case minimum
        case maximum
        
        @inlinable
        internal func prefers<T: Comparable>(_ lhs: T, to rhs: T) -> Bool {
            switch self {
            case .minimum: return lhs < rhs
            case .maximum: return lhs > rhs
            }
        }
    }

    struct ScalarSearchResult<Scalar: BinaryFloatingPoint> {
        /// An evaluated point in the final bracket
        public let location: Scalar
        /// The original function evaluated at `location`, including for a level crossing
        public let value: Scalar
        /// The final interval, or a singleton for an exact level crossing
        public let bracket: ClosedRange<Scalar>
        /// Number of refinement steps. Initial samples and the final evaluation
        /// of a bisection midpoint do not count as refinement steps
        public let iterations: Int
        /// Total calls made to the supplied closure
        public let functionEvaluations: Int

        @inlinable
        init(
            location: Scalar,
            value: Scalar,
            bracket: ClosedRange<Scalar>,
            iterations: Int,
            functionEvaluations: Int
        ) {
            self.location = location
            self.value = value
            self.bracket = bracket
            self.iterations = iterations
            self.functionEvaluations = functionEvaluations
        }
    }

    enum ScalarSearchError: Error, Equatable {
        case invalidInterval
        case invalidTolerance
        case invalidIterationLimit
        case nonFiniteTarget
        case nonFiniteFunctionValue
        case targetNotBracketed
        case iterationLimitReached
        /// Further refinement is prevented by the spacing of representable points.
        case precisionLimitReached
    }

    /// Finds a minimum or maximum of a unimodal function on a finite closed interval.
    ///
    /// Supply an interval on which the objective moves strictly toward and away
    /// from the desired extremum. An extremum at either endpoint or a plateau at
    /// the optimum is supported. Both endpoints are candidates. The result is
    /// the best sampled point in the final bracket, with ties resolved arbitrarily.
    ///
    /// Stops when the bracket width is at most the larger of `absoluteTolerance`
    /// and `relativeTolerance * max(abs(lower), abs(upper))`. Both tolerances
    /// must be finite and nonnegative, with at least one positive. A budget of
    /// zero permits a result if the initial bracket meets the tolerance.
    /// Errors thrown by the objective propagate to the caller.
    @inlinable
    static func goldenSection<Scalar: BinaryFloatingPoint>(
        _ extremum: Extremum,
        in interval: ClosedRange<Scalar>,
        absoluteTolerance: Scalar,
        relativeTolerance: Scalar = 0,
        maxIterations: Int = 128,
        of objective: (Scalar) throws -> Scalar
    ) throws -> ScalarSearchResult<Scalar> {
        var search = try ScalarSearchWork(
            interval,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            maxIterations: maxIterations
        )
        var lower = try search.sample(interval.lowerBound, of: objective)
        if interval.lowerBound == interval.upperBound { return search.result(lower) }
        var upper = try search.sample(interval.upperBound, of: objective)

        // 1 / phi². Each step keeps one interior sample from the previous bracket
        let fraction = 2 / (3 + Scalar(5).squareRoot())
        guard let first = interiorPoint(from: lower.x, toward: upper.x, fraction: fraction) else {
            guard search.isNarrowEnough(lower.x, upper.x) else {
                throw ScalarSearchError.precisionLimitReached
            }
            let best = extremum.prefers(upper.value, to: lower.value) ? upper : lower
            return search.result(best, in: interval)
        }
        var retained = try search.sample(first, of: objective)

        while !search.isNarrowEnough(lower.x, upper.x) {
            try search.beginIteration()
            let midpoint = scalarMidpoint(lower.x, upper.x)
            let (far, near) = retained.x <= midpoint ? (upper, lower) : (lower, upper)
            let next = interiorPoint(from: retained.x, toward: far.x, fraction: fraction)
                ?? interiorPoint(from: retained.x, toward: near.x, fraction: fraction)

            guard let next else {
                // Only three representable points remain. A competitive endpoint
                // rules out the opposite side. A better middle point alone cannot.
                let end = extremum.prefers(upper.value, to: lower.value) ? upper : lower
                let narrow = Swift.min(end.x, retained.x) ... Swift.max(end.x, retained.x)
                guard !extremum.prefers(retained.value, to: end.value),
                      search.isNarrowEnough(narrow.lowerBound, narrow.upperBound) else {
                    throw ScalarSearchError.precisionLimitReached
                }
                return search.result(end, in: narrow)
            }

            let trial = try search.sample(next, of: objective)
            let (left, right) = trial.x < retained.x ? (trial, retained) : (retained, trial)
            if extremum.prefers(right.value, to: left.value) {
                lower = left
                retained = right
            } else {
                upper = right
                retained = left
            }
        }

        let end = extremum.prefers(upper.value, to: lower.value) ? upper : lower
        let best = extremum.prefers(retained.value, to: end.value) ? retained : end
        return search.result(best, in: lower.x...upper.x)
    }

    /// Finds a crossing of a finite target by a continuous function on a finite bracket.
    ///
    /// An exact match returns a singleton bracket. Otherwise the initial endpoint
    /// values must straddle the target. The result is the midpoint of the final
    /// bracket, rounded to the scalar type, and its original function value.
    /// The default target of zero gives ordinary root finding.
    ///
    /// The tolerances and iteration budget have the same meaning as in golden
    /// section search. They control the input coordinate. Errors thrown by the
    /// supplied function propagate to the caller.
    @inlinable
    static func bisection<Scalar: BinaryFloatingPoint>(
        in bracket: ClosedRange<Scalar>,
        target: Scalar = 0,
        absoluteTolerance: Scalar,
        relativeTolerance: Scalar = 0,
        maxIterations: Int = 128,
        of function: (Scalar) throws -> Scalar
    ) throws -> ScalarSearchResult<Scalar> {
        var search = try ScalarSearchWork(
            bracket,
            absoluteTolerance: absoluteTolerance,
            relativeTolerance: relativeTolerance,
            maxIterations: maxIterations
        )
        guard target.isFinite else { throw ScalarSearchError.nonFiniteTarget }
        var lower = try search.sample(bracket.lowerBound, of: function)
        if lower.value == target { return search.result(lower) }
        guard bracket.lowerBound < bracket.upperBound else {
            throw ScalarSearchError.targetNotBracketed
        }
        var upper = try search.sample(bracket.upperBound, of: function)
        if upper.value == target { return search.result(upper) }
        let lowerIsBelow = lower.value < target
        guard lowerIsBelow != (upper.value < target) else {
            throw ScalarSearchError.targetNotBracketed
        }

        while !search.isNarrowEnough(lower.x, upper.x) {
            try search.beginIteration()
            let x = scalarMidpoint(lower.x, upper.x)
            guard lower.x < x, x < upper.x else {
                throw ScalarSearchError.precisionLimitReached
            }
            let middle = try search.sample(x, of: function)
            if middle.value == target { return search.result(middle) }
            if (middle.value < target) == lowerIsBelow {
                lower = middle
            } else {
                upper = middle
            }
        }

        let midpoint = scalarMidpoint(lower.x, upper.x)
        let finalBracket = lower.x...upper.x
        if midpoint <= lower.x { return search.result(lower, in: finalBracket) }
        if midpoint >= upper.x { return search.result(upper, in: finalBracket) }
        let middle = try search.sample(midpoint, of: function)
        if middle.value == target { return search.result(middle) }
        return search.result(middle, in: finalBracket)
    }
}

extension Optimize.ScalarSearchResult: Sendable where Scalar: Sendable {}

@usableFromInline
internal struct ScalarSearchWork<Scalar: BinaryFloatingPoint> {
    @usableFromInline typealias Sample = (x: Scalar, value: Scalar)

    @usableFromInline
    let absoluteTolerance: Scalar
    
    @usableFromInline
    let relativeTolerance: Scalar
    
    @usableFromInline
    let maxIterations: Int
    
    @usableFromInline
    var iterations = 0
    
    @usableFromInline
    var evaluations = 0

    @inlinable
    init(_ interval: ClosedRange<Scalar>, absoluteTolerance: Scalar,
         relativeTolerance: Scalar, maxIterations: Int) throws {
        guard interval.lowerBound.isFinite, interval.upperBound.isFinite,
              interval.lowerBound <= interval.upperBound else {
            throw Optimize.ScalarSearchError.invalidInterval
        }
        guard absoluteTolerance.isFinite, relativeTolerance.isFinite,
              absoluteTolerance >= 0, relativeTolerance >= 0,
              absoluteTolerance > 0 || relativeTolerance > 0 else {
            throw Optimize.ScalarSearchError.invalidTolerance
        }
        guard maxIterations >= 0 else { throw Optimize.ScalarSearchError.invalidIterationLimit }
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.maxIterations = maxIterations
    }

    @inlinable
    func isNarrowEnough(_ lower: Scalar, _ upper: Scalar) -> Bool {
        let width = upper - lower
        if width <= absoluteTolerance { return true }
        guard relativeTolerance > 0 else { return false }
        // Scaling the width avoids both overflow and rounding the requested
        // relative tolerance up to a whole subnormal spacing.
        let scale = Swift.max(Swift.abs(lower), Swift.abs(upper))
        if width.isFinite { return width / scale <= relativeTolerance }
        // Opposite-sign finite endpoints can have an unrepresentable difference.
        return upper / scale - lower / scale <= relativeTolerance
    }

    @inlinable
    mutating func beginIteration() throws {
        guard iterations < maxIterations else { throw Optimize.ScalarSearchError.iterationLimitReached }
        iterations += 1
    }

    @inlinable
    mutating func sample(_ x: Scalar, of function: (Scalar) throws -> Scalar) throws -> Sample {
        let value = try function(x)
        guard value.isFinite else { throw Optimize.ScalarSearchError.nonFiniteFunctionValue }
        evaluations += 1
        return (x, value)
    }

    @inlinable
    func result(_ sample: Sample, in bracket: ClosedRange<Scalar>? = nil)
        -> Optimize.ScalarSearchResult<Scalar> {
        .init(location: sample.x, value: sample.value, bracket: bracket ?? (sample.x...sample.x),
              iterations: iterations, functionEvaluations: evaluations)
    }
}

@inlinable
@inline(always)
internal func scalarMidpoint<T: BinaryFloatingPoint>(_ lower: T, _ upper: T) -> T {
    let sum = lower + upper
    if sum.isFinite { return sum / 2 }
    return lower / 2 + upper / 2
}

/// Returns a strictly interior point whenever one exists, even at subnormal spacing.
@inlinable
internal func interiorPoint<T: BinaryFloatingPoint>(from start: T, toward end: T, fraction: T) -> T? {
    let first = Swift.min(start, end).nextUp
    let last = Swift.max(start, end).nextDown
    guard first <= last else { return nil }
    let span = end - start
    let x = span.isFinite ? start.addingProduct(fraction, span)
                          : (1 - fraction) * start + fraction * end
    return Swift.min(last, Swift.max(first, x))
}
