// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
import Numerics
@testable import SebbuScience

struct GaussKronrod21Tests {
    @Test("Double integration converges on a smooth function")
    func smoothDoubleIntegral() {
        let result: GaussKronrod21.Result<Double> =
            GaussKronrod21.integrate(
                a: 0,
                b: 1,
                absoluteTolerance: 1e-12,
                relativeTolerance: 1e-12
            ) { x in
                .exp(-x * x)
            }

        #expect(result.converged)
        #expect(result.reason == .converged)
        #expect(abs(result.value - 0.7468241328124271) < 1e-13)
        #expect(result.estimatedAbsoluteError <= 1e-12)
        #expect(result.functionEvaluations == 21)
        #expect(result.subintervals == 1)
    }

    @Test("The largest-error interval is refined adaptively")
    func adaptiveRefinement() {
        let center = 0.123
        let scale = 100.0
        let expected = (
            Double.atan(scale * (1 - center))
                - Double.atan(scale * (0 - center))
        ) / scale

        let result = GaussKronrod21.integrate(
            a: 0.0,
            b: 1.0,
            absoluteTolerance: 1e-11,
            relativeTolerance: 1e-11
        ) { x in
            let displacement = x - center
            let denominator: Double =
                1 + scale * scale * displacement * displacement
            return Double(1) / denominator
        }

        #expect(result.converged)
        #expect(result.subintervals > 1)
        #expect(
            result.functionEvaluations
                == 21 + 42 * (result.subintervals - 1)
        )
        #expect(abs(result.value - expected) < 1e-11)
    }

    @Test("Double integration preserves interval orientation")
    func reversedAndEmptyIntervals() {
        let forward = GaussKronrod21.integrate(a: 0.0, b: 2.0) {
            $0 * $0
        }
        let reverse = GaussKronrod21.integrate(a: 2.0, b: 0.0) {
            $0 * $0
        }
        let empty = GaussKronrod21.integrate(a: 1.0, b: 1.0) {
            $0
        }

        #expect(forward.converged)
        #expect(reverse.converged)
        #expect(abs(forward.value + reverse.value) < 1e-13)
        #expect(empty.value == 0)
        #expect(empty.estimatedAbsoluteError == 0)
        #expect(empty.functionEvaluations == 0)
        #expect(empty.subintervals == 0)
    }

    @Test("Complex Double integration controls the complex modulus")
    func complexDoubleIntegral() {
        let result: GaussKronrod21.Result<Complex<Double>> =
            GaussKronrod21.integrate(
                a: 0,
                b: .pi,
                absoluteTolerance: 1e-12,
                relativeTolerance: 1e-12
            ) { x in
                Complex(.cos(x), .sin(x))
            }

        #expect(result.converged)
        #expect(result.value.length.isFinite)
        #expect((result.value - Complex(0, 2)).length < 1e-12)
        #expect(result.estimatedAbsoluteError <= 1e-12)
    }

    @Test("Float integration uses Float result and error types")
    func floatIntegral() {
        let result: GaussKronrod21.Result<Float> =
            GaussKronrod21.integrate(
                a: Float(0),
                b: Float(1),
                absoluteTolerance: 1e-5,
                relativeTolerance: 1e-5
            ) { x in
                x * x * x * x
            }

        #expect(result.converged)
        #expect(abs(result.value - 0.2) < 1e-5)
        #expect(result.estimatedAbsoluteError <= 1e-5)
    }

    @Test("Complex Float integration uses Float error control")
    func complexFloatIntegral() {
        let result: GaussKronrod21.Result<Complex<Float>> =
            GaussKronrod21.integrate(
                a: Float(0),
                b: .pi,
                absoluteTolerance: 1e-5,
                relativeTolerance: 1e-5
            ) { x in
                Complex(.cos(x), .sin(x))
            }

        #expect(result.converged)
        #expect((result.value - Complex(0, 2)).length < 1e-5)
        let requestedError = max(1e-5, 1e-5 * result.value.length)
        #expect(result.estimatedAbsoluteError <= requestedError)
    }

    @Test("The subinterval limit is reported")
    func maximumSubintervals() {
        let result = GaussKronrod21.integrate(
            a: -1.0,
            b: 1.0,
            absoluteTolerance: 1e-15,
            relativeTolerance: 1e-15,
            maximumSubintervals: 1
        ) { x in
            var value = 1.0
            for _ in 0..<30 { value *= x }
            return value
        }

        #expect(!result.converged)
        #expect(result.reason == .maximumSubintervals)
        #expect(result.functionEvaluations == 21)
        #expect(result.subintervals == 1)
    }

    @Test("A non-finite integrand is reported")
    func nonFiniteIntegrand() {
        let result = GaussKronrod21.integrate(a: 0.0, b: 1.0) { x in
            x == 0.5 ? Double.nan : x
        }

        #expect(!result.converged)
        #expect(result.reason == .nonFiniteIntegrand)
        #expect(result.value.isNaN)
        #expect(result.estimatedAbsoluteError == .infinity)
        #expect(result.functionEvaluations == 1)
        #expect(result.subintervals == 0)
    }
}
