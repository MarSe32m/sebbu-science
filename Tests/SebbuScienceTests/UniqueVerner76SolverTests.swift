// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import SebbuScience

@Suite("Unique Verner 7(6) solver")
struct UniqueVerner76SolverTests {
    @Test("The adaptive step and sixth-order dense output follow a nonautonomous solution")
    func adaptiveStepAndDenseOutput() throws {
        var solver = UniqueVerner76Solver(
            t: 0,
            dt: 0.4,
            maxStep: 0.4,
            rhs: TimeDependentGrowthRHS(),
            y6: VernerTestState(),
            k1: VernerTestState(),
            k2: VernerTestState(),
            k3: VernerTestState(),
            k4: VernerTestState(),
            k5: VernerTestState(),
            k6: VernerTestState(),
            k7: VernerTestState(),
            k8: VernerTestState(),
            k9: VernerTestState(),
            k10: VernerTestState(),
            temporary: VernerTestState(),
            absoluteTolerance: 1e-6,
            relativeTolerance: 1e-6
        )
        var state = VernerTestState(value: 1)

        let step = try solver.step(y: &state, upTo: 0.4)
        #expect(step.startTime == 0)
        #expect(step.endTime == 0.4)
        #expect((step.errorNorm ?? .infinity) <= 1)
        #expect(step.rejectedStepCount == 0)
        #expect(solver.rhsEvaluationCount == 13)

        let midpoint = 0.5 * (step.startTime + step.endTime)
        var denseStart = VernerTestState()
        var denseMiddle = VernerTestState()
        var denseEnd = VernerTestState()
        solver.interpolateLastStep(at: step.startTime, into: &denseStart)
        solver.interpolateLastStep(at: midpoint, into: &denseMiddle)
        solver.interpolateLastStep(at: step.endTime, into: &denseEnd)

        #expect(denseStart.value == 1)
        #expect(abs(state.value - exp(0.5 * step.endTime * step.endTime)) < 5e-9)
        #expect(abs(denseMiddle.value - exp(0.5 * midpoint * midpoint)) < 1e-8)
        #expect(denseEnd.value == state.value)
    }

    @Test("The propagating formula exhibits seventh-order convergence")
    func seventhOrderConvergence() throws {
        func oneStepError(stepSize: Double) throws -> Double {
            var solver = UniqueVerner76Solver(
                t: 0,
                dt: stepSize,
                maxStep: stepSize,
                rhs: ExponentialGrowthRHS(),
                y6: VernerTestState(),
                k1: VernerTestState(),
                k2: VernerTestState(),
                k3: VernerTestState(),
                k4: VernerTestState(),
                k5: VernerTestState(),
                k6: VernerTestState(),
                k7: VernerTestState(),
                k8: VernerTestState(),
                k9: VernerTestState(),
                k10: VernerTestState(),
                temporary: VernerTestState(),
                absoluteTolerance: 1,
                relativeTolerance: 0
            )
            var state = VernerTestState(value: 1)
            _ = try solver.step(y: &state, upTo: stepSize)
            return abs(state.value - exp(stepSize))
        }

        let coarseError = try oneStepError(stepSize: 0.8)
        let fineError = try oneStepError(stepSize: 0.4)

        #expect(coarseError > 1e-8)
        #expect(fineError < 5e-10)
        #expect(coarseError > 300 * fineError)
    }

    @Test("Rejected trials do not advance the external state")
    func rejectsOverlargeTrial() throws {
        var solver = UniqueVerner76Solver(
            t: 0,
            dt: 1,
            maxStep: 1,
            rhs: VernerDecayRHS(),
            y6: VernerTestState(),
            k1: VernerTestState(),
            k2: VernerTestState(),
            k3: VernerTestState(),
            k4: VernerTestState(),
            k5: VernerTestState(),
            k6: VernerTestState(),
            k7: VernerTestState(),
            k8: VernerTestState(),
            k9: VernerTestState(),
            k10: VernerTestState(),
            temporary: VernerTestState(),
            absoluteTolerance: 1e-12,
            relativeTolerance: 1e-12
        )
        var state = VernerTestState(value: 1)

        let step = try solver.step(y: &state, upTo: 1)
        #expect(step.rejectedStepCount > 0)
        #expect(solver.rejectedStepCount == step.rejectedStepCount)
        #expect(
            solver.rhsEvaluationCount
                == 1 + 9 * (step.rejectedStepCount + 1) + 3
        )
        #expect(step.endTime < 1)
        #expect(abs(state.value - exp(-step.endTime)) < 1e-10)
    }

    @Test("The accepted endpoint derivative is reused across steps")
    func reusesEndpointDerivative() throws {
        var solver = UniqueVerner76Solver(
            t: 0,
            dt: 0.01,
            maxStep: 0.01,
            rhs: VernerDecayRHS(),
            y6: VernerTestState(),
            k1: VernerTestState(),
            k2: VernerTestState(),
            k3: VernerTestState(),
            k4: VernerTestState(),
            k5: VernerTestState(),
            k6: VernerTestState(),
            k7: VernerTestState(),
            k8: VernerTestState(),
            k9: VernerTestState(),
            k10: VernerTestState(),
            temporary: VernerTestState(),
            absoluteTolerance: 1e-8,
            relativeTolerance: 1e-8
        )
        var state = VernerTestState(value: 1)

        _ = try solver.step(y: &state)
        #expect(solver.rhsEvaluationCount == 13)
        let cachedAfterFirstStep = solver.hasCachedFirstDerivative
        #expect(cachedAfterFirstStep)

        _ = try solver.step(y: &state)
        #expect(solver.rhsEvaluationCount == 25)
        #expect(solver.acceptedStepCount == 2)
        #expect(solver.rejectedStepCount == 0)
        #expect(abs(state.value - exp(-solver.t)) < 1e-13)
    }

    @Test("A linear event is localized using Verner dense output")
    func hazardCrossing() throws {
        var solver = UniqueVerner76Solver(
            t: 0,
            dt: 1,
            maxStep: 1,
            rhs: VernerConstantHazardRHS(rate: 2),
            y6: VernerTestState(),
            k1: VernerTestState(),
            k2: VernerTestState(),
            k3: VernerTestState(),
            k4: VernerTestState(),
            k5: VernerTestState(),
            k6: VernerTestState(),
            k7: VernerTestState(),
            k8: VernerTestState(),
            k9: VernerTestState(),
            k10: VernerTestState(),
            temporary: VernerTestState(),
            absoluteTolerance: 1e-11,
            relativeTolerance: 1e-11
        )
        var state = VernerTestState()
        let target = 0.37

        let step = try solver.step(y: &state, upTo: 1)
        #expect(step.endTime == 1)
        #expect(abs(state.hazard - 2) < 1e-11)

        let eventTime = solver.locateLastStepCrossing(
            of: target,
            linearFunctional: VernerHazardFunctional(),
            timeTolerance: 1e-12
        )
        #expect(eventTime != nil)
        guard let eventTime else { return }

        #expect(abs(eventTime - target / 2) < 2e-11)
        let scalarHazard = solver.interpolateLastStep(
            at: eventTime,
            linearFunctional: VernerHazardFunctional()
        )
        let complexState = solver.interpolateLastStep(
            at: eventTime,
            linearFunctional: VernerComplexFunctional()
        )
        var eventState = VernerTestState()
        solver.interpolateLastStep(at: eventTime, into: &eventState)
        #expect(abs(scalarHazard - target) < 2e-11)
        #expect(abs(complexState.real) < 2e-11)
        #expect(abs(complexState.imaginary - target) < 2e-11)
        #expect(abs(eventState.hazard - target) < 2e-11)

        solver.truncateLastStep(at: eventTime, restoring: &state)
        #expect(solver.t == eventTime)
        #expect(solver.lastStep == nil)
        let cachedAfterTruncation = solver.hasCachedFirstDerivative
        #expect(!cachedAfterTruncation)
        #expect(abs(state.hazard - target) < 2e-11)
    }

    @Test("Non-finite trials are never accepted")
    func rejectsNonFiniteTrials() {
        var solver = UniqueVerner76Solver(
            t: 0,
            dt: 0.1,
            maxStep: 0.1,
            rhs: VernerNaNRHS(),
            y6: VernerTestState(),
            k1: VernerTestState(),
            k2: VernerTestState(),
            k3: VernerTestState(),
            k4: VernerTestState(),
            k5: VernerTestState(),
            k6: VernerTestState(),
            k7: VernerTestState(),
            k8: VernerTestState(),
            k9: VernerTestState(),
            k10: VernerTestState(),
            temporary: VernerTestState(),
            maximumStepAttempts: 3
        )
        var state = VernerTestState(value: 1)

        do {
            _ = try solver.step(y: &state)
            Issue.record("A non-finite trial was unexpectedly accepted")
        } catch {
            #expect(
                error == .maximumStepAttemptsExceeded(time: 0, attempts: 3)
            )
        }

        #expect(state.value == 1)
        #expect(solver.acceptedStepCount == 0)
        #expect(solver.rejectedStepCount == 3)
        #expect(solver.rhsEvaluationCount == 28)
    }
}

private struct VernerTestState: AdaptiveStepODESolverState {
    var value: Double = 0
    var hazard: Double = 0

    var norm: Double {
        hypot(value, hazard)
    }

    mutating func assign(_ other: borrowing Self) {
        value = other.value
        hazard = other.hazard
    }

    mutating func add(_ other: borrowing Self, multiplied: Double) {
        value += other.value * multiplied
        hazard += other.hazard * multiplied
    }

    mutating func assign(
        _ base: borrowing Self,
        adding direction: borrowing Self,
        multipliedBy coefficient: Double
    ) {
        value = base.value + direction.value * coefficient
        hazard = base.hazard + direction.hazard * coefficient
    }

    func errorNorm(to other: borrowing Self) -> Double {
        hypot(value - other.value, hazard - other.hazard)
    }
}

private struct TimeDependentGrowthRHS: ODERHSFunction {
    func evaluate(
        t: Double,
        y: borrowing VernerTestState,
        dy: inout VernerTestState
    ) {
        dy.value = t * y.value
        dy.hazard = 0
    }
}

private struct ExponentialGrowthRHS: ODERHSFunction {
    func evaluate(
        t: Double,
        y: borrowing VernerTestState,
        dy: inout VernerTestState
    ) {
        dy.value = y.value
        dy.hazard = 0
    }
}

private struct VernerDecayRHS: ODERHSFunction {
    func evaluate(
        t: Double,
        y: borrowing VernerTestState,
        dy: inout VernerTestState
    ) {
        dy.value = -y.value
        dy.hazard = 0
    }
}

private struct VernerConstantHazardRHS: ODERHSFunction {
    let rate: Double

    func evaluate(
        t: Double,
        y: borrowing VernerTestState,
        dy: inout VernerTestState
    ) {
        dy.value = 0
        dy.hazard = rate
    }
}

private struct VernerNaNRHS: ODERHSFunction {
    func evaluate(
        t: Double,
        y: borrowing VernerTestState,
        dy: inout VernerTestState
    ) {
        dy.value = .nan
        dy.hazard = 0
    }
}

private struct VernerHazardFunctional: ODEStateLinearFunctional {
    func evaluate(_ state: borrowing VernerTestState) -> Double {
        state.hazard
    }
}

private struct VernerComplexFunctional: ODEStateComplexLinearFunctional {
    func evaluate(_ state: borrowing VernerTestState) -> Complex<Double> {
        Complex(state.value, state.hazard)
    }
}
