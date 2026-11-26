// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
import SebbuScience

struct ScalarSearchTests {
    typealias SearchError = Optimize.ScalarSearchError
    private enum ObjectiveError: Error, Equatable { case failed }

    @Test("Golden section brackets the minimum and reuses function evaluations")
    func interiorMinimum() throws {
        let optimum = 0.317
        var visited: Set<Double> = []
        let result = try Optimize.goldenSection(.minimum, in: -2.0...3.0, absoluteTolerance: 1e-9) { x in
            let inserted = visited.insert(x).inserted
            #expect(inserted)
            return Swift.abs(x - optimum)
        }
        #expect(result.bracket.contains(optimum))
        #expect(result.bracket.contains(result.location))
        #expect(result.bracket.upperBound - result.bracket.lowerBound <= 1e-9)
        #expect(result.value == Swift.abs(result.location - optimum))
        #expect(result.value <= 1e-9)
        #expect(result.functionEvaluations == visited.count)
        #expect(result.functionEvaluations == result.iterations + 3)
    }

    @Test("Float maximization returns the original objective value")
    func floatMaximum() throws {
        let peak: Float = 1.375
        func rate(_ x: Float) -> Float { 4 - Swift.abs(x - peak) }
        let result = try Optimize.goldenSection(
            .maximum, in: Float(0)...3, absoluteTolerance: 1e-4, of: rate
        )
        #expect(result.bracket.contains(peak))
        #expect(Swift.abs(result.location - peak) <= 1e-4)
        #expect(result.value == rate(result.location))
    }

    @Test("Monotone objectives can attain their extrema at either endpoint")
    func endpointExtrema() throws {
        let lo = try Optimize.goldenSection(.minimum, in: 0.0...2.0, absoluteTolerance: 1e-8) { $0 }
        let hi = try Optimize.goldenSection(.maximum, in: 0.0...2.0, absoluteTolerance: 1e-8) { $0 }
        #expect(lo.location == 0 && lo.value == 0)
        #expect(hi.location == 2 && hi.value == 2)
    }

    @Test("A flat optimum admits any point on its plateau")
    func plateau() throws {
        let result = try Optimize.goldenSection(.minimum, in: -2.0...2.0, absoluteTolerance: 1e-8) {
            Swift.max(0, Swift.abs($0) - 0.25)
        }
        #expect((-0.25...0.25).contains(result.location))
        #expect(result.value == 0)
        #expect(result.bracket.contains(result.location))
    }

    @Test("Bisection returns a midpoint and its evaluated residual for a zero target")
    func defaultTarget() throws {
        var visited: Set<Double> = []
        let result = try Optimize.bisection(in: 1.0...2.0, absoluteTolerance: 1e-10) { x in
            let inserted = visited.insert(x).inserted
            #expect(inserted)
            return x * x - 2
        }
        let expected = Double(2).squareRoot()
        #expect(result.bracket.contains(expected))
        #expect(result.bracket.upperBound - result.bracket.lowerBound <= 1e-10)
        #expect(abs(result.location - expected) <= 5.1e-11)
        #expect(result.location == (result.bracket.lowerBound + result.bracket.upperBound) / 2)
        #expect(result.value == result.location * result.location - 2)
        #expect(result.functionEvaluations == visited.count)
        #expect(result.functionEvaluations == result.iterations + 3)
    }

    @Test("Two level crossings recover the full width at half maximum")
    func spectralLinewidth() throws {
        let centre = 2.03
        let halfWidth = 0.025
        func rate(_ energy: Double) -> Double {
            let detuning = (energy - centre) / halfWidth
            return 8 / (1 + detuning * detuning)
        }
        let peak = try Optimize.goldenSection(
            .maximum, in: 1.9...2.18, absoluteTolerance: 1e-8, of: rate
        )
        let half = peak.value / 2
        let left = try Optimize.bisection(
            in: 1.9...peak.location, target: half, absoluteTolerance: 1e-10, of: rate
        )
        let right = try Optimize.bisection(
            in: peak.location...2.18, target: half, absoluteTolerance: 1e-10, of: rate
        )
        #expect(Swift.abs(peak.location - centre) < 1e-8)
        #expect(Swift.abs(left.location - (centre - halfWidth)) < 1e-10)
        #expect(Swift.abs(right.location - (centre + halfWidth)) < 1e-10)
        #expect(Swift.abs(right.location - left.location - 2 * halfWidth) < 2e-10)
        #expect(left.value == rate(left.location))
        #expect(right.value == rate(right.location))
    }

    @Test("Exact level matches short-circuit and collapse the bracket")
    func exactMatches() throws {
        for (target, calls, iterations) in [(0.0, 1, 0), (4.0, 2, 0), (2.0, 3, 1)] {
            let result = try Optimize.bisection(in: 0.0...4.0, target: target, absoluteTolerance: 1e-9) { $0 }
            #expect(result.location == target && result.value == target)
            #expect(result.bracket == target...target)
            #expect(result.iterations == iterations)
            #expect(result.functionEvaluations == calls)
        }
    }

    @Test("Singletons evaluate once and a missing crossing is distinguishable")
    func singletonsAndUnbracketedTarget() throws {
        let one = 4.0...4.0
        let extremum = try Optimize.goldenSection(.maximum, in: one, absoluteTolerance: 1e-9, maxIterations: 0) { 2 * $0 }
        let crossing = try Optimize.bisection(in: one, target: 8, absoluteTolerance: 1e-9, maxIterations: 0) { 2 * $0 }
        for result in [extremum, crossing] {
            #expect(result.bracket == one)
            #expect(result.location == 4 && result.value == 8)
            #expect(result.iterations == 0 && result.functionEvaluations == 1)
        }
        #expect(throws: SearchError.targetNotBracketed) {
            try Optimize.bisection(in: one, absoluteTolerance: 1e-8) { $0 }
        }
        #expect(throws: SearchError.targetNotBracketed) {
            try Optimize.bisection(in: -1.0...1.0, target: 2, absoluteTolerance: 1e-8) { $0 * $0 }
        }
    }

    @Test("Relative tolerance uses the scale of the input coordinates")
    func relativeTolerance() throws {
        let interval = 1_000_000.0...1_000_004.0
        let root = try Optimize.bisection(in: interval, target: 1_000_001,
            absoluteTolerance: 0, relativeTolerance: 1e-5, maxIterations: 0) { $0 }
        let minimum = try Optimize.goldenSection(.minimum, in: interval,
            absoluteTolerance: 0, relativeTolerance: 1e-5, maxIterations: 0) { $0 }
        #expect(root.bracket == interval && root.iterations == 0)
        #expect(root.location == 1_000_002)
        #expect(minimum.bracket == interval && minimum.iterations == 0)
        #expect(minimum.location == interval.lowerBound)
    }

    @Test("Invalid inputs are rejected before evaluating the function")
    func invalidInputs() {
        var calls = 0
        func identity(_ x: Double) -> Double {
            calls += 1
            return x
        }
        for (absolute, relative) in [(0.0, 0.0), (-1, 0), (1, -1), (.nan, 0), (1, .infinity)] {
            #expect(throws: SearchError.invalidTolerance) {
                try Optimize.goldenSection(.minimum, in: 0.0...1.0, absoluteTolerance: absolute,
                                           relativeTolerance: relative, of: identity)
            }
        }
        #expect(throws: SearchError.invalidInterval) {
            try Optimize.bisection(in: 0.0...Double.infinity, absoluteTolerance: 1e-8, of: identity)
        }
        #expect(throws: SearchError.nonFiniteTarget) {
            try Optimize.bisection(in: 0.0...1.0, target: .nan, absoluteTolerance: 1e-8, of: identity)
        }
        #expect(throws: SearchError.invalidIterationLimit) {
            try Optimize.bisection(in: 0.0...1.0, absoluteTolerance: 1e-8, maxIterations: -1, of: identity)
        }
        #expect(calls == 0)
    }

    @Test("Nonfinite samples and errors thrown by the objective are distinguished")
    func evaluationFailures() {
        #expect(throws: SearchError.nonFiniteFunctionValue) {
            try Optimize.goldenSection(.minimum, in: 0.0...1.0, absoluteTolerance: 1e-8) {
                $0 > 0 && $0 < 1 ? .nan : $0
            }
        }
        #expect(throws: SearchError.nonFiniteFunctionValue) {
            try Optimize.bisection(in: -1.0...1.0, absoluteTolerance: 2) { $0 == 0 ? .infinity : $0 }
        }
        #expect(throws: ObjectiveError.failed) {
            try Optimize.goldenSection(.minimum, in: 0.0...1.0, absoluteTolerance: 1e-8) { x in
                if x > 0 && x < 1 { throw ObjectiveError.failed }
                return x
            }
        }
        #expect(throws: ObjectiveError.failed) {
            try Optimize.bisection(in: -1.0...1.0, absoluteTolerance: 1e-8) { x in
                if x == 0 { throw ObjectiveError.failed }
                return x
            }
        }
    }

    @Test("Exhausting the iteration budget reports failure")
    func iterationLimits() {
        #expect(throws: SearchError.iterationLimitReached) {
            try Optimize.goldenSection(.maximum, in: 0.0...1.0, absoluteTolerance: 1e-12, maxIterations: 1) { $0 }
        }
        #expect(throws: SearchError.iterationLimitReached) {
            try Optimize.bisection(in: 0.0...1.0, target: 0.25, absoluteTolerance: 1e-12, maxIterations: 1) { $0 }
        }
    }

    @Test("Finite bounds can have an overflowing sum or difference")
    func largeIntervals() throws {
        let m = Double.greatestFiniteMagnitude
        let peak = try Optimize.goldenSection(.maximum, in: -m...m, absoluteTolerance: 0, relativeTolerance: 1e-8) {
            -Swift.abs($0 / m - 0.25)
        }
        #expect(peak.bracket.contains(m / 4))
        #expect(Swift.abs(peak.location / m - 0.25) < 1e-8)
        let opposite = try Optimize.bisection(in: -m...m, absoluteTolerance: 1) { $0 }
        #expect(opposite.location == 0 && opposite.iterations == 1)
        let sameSign = try Optimize.bisection(in: (m / 2)...m, target: 0.75, absoluteTolerance: 0, relativeTolerance: 1e-10) { $0 / m }
        #expect(Swift.abs(sameSign.location / m - 0.75) < 1e-10)
        #expect(throws: SearchError.iterationLimitReached) {
            try Optimize.bisection(in: -m...m, target: m / 4, absoluteTolerance: 0,
                                   relativeTolerance: 1.5, maxIterations: 0) { $0 }
        }
    }

    @Test("Midpoints retain cancellation across zero and halve subnormal sums correctly")
    func roundedMidpoints() throws {
        let upper = 1.0.nextUp
        let tinyRoot = (upper - 1) / 2
        let first = try Optimize.bisection(in: -1.0...upper, target: tinyRoot, absoluteTolerance: 1e-20) { $0 }
        #expect(first.location == tinyRoot && first.iterations == 1)
        let unit = Double.leastNonzeroMagnitude
        let subnormal = try Optimize.bisection(in: unit...(5 * unit), target: 3 * unit, absoluteTolerance: unit) { $0 }
        #expect(subnormal.location == 3 * unit && subnormal.iterations == 1)
        #expect(throws: SearchError.precisionLimitReached) {
            try Optimize.bisection(in: 0.0...unit, target: 0.5, absoluteTolerance: 0, relativeTolerance: 0.75) {
                $0 / unit
            }
        }
    }

    @Test("Unattainable precision terminates and adjacent samples are reused")
    func finiteResolution() throws {
        let a: Float = 1
        let b = a.nextUp
        let c = b.nextUp
        func ramp(_ x: Float) -> Float { (x - a) / (b - a) }
        #expect(throws: SearchError.precisionLimitReached) {
            try Optimize.bisection(in: a...b, target: 0.5, absoluteTolerance: a.ulp / 2, of: ramp)
        }
        #expect(throws: SearchError.precisionLimitReached) {
            try Optimize.goldenSection(.minimum, in: a...b, absoluteTolerance: a.ulp / 2, of: ramp)
        }
        #expect(throws: SearchError.precisionLimitReached) {
            try Optimize.goldenSection(.minimum, in: a...c, absoluteTolerance: a.ulp) { abs($0 - b) }
        }
        let rounded = try Optimize.bisection(in: a...b, target: 0.5, absoluteTolerance: a.ulp, of: ramp)
        #expect(rounded.functionEvaluations == 2 && rounded.bracket == a...b)
        let edge = try Optimize.goldenSection(.minimum, in: a...c, absoluteTolerance: a.ulp, of: ramp)
        #expect(edge.location == a && edge.bracket == a...b)
        #expect(edge.functionEvaluations == 3)
    }
}
