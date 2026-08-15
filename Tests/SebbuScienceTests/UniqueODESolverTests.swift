// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import SebbuScience

@Suite("Unique ODE solvers")
struct UniqueODESolverTests {
    @Test("RK4 integrates, clamps to a bound, and provides dense output")
    func rk4DenseOutput() {
        var solver = UniqueRK4Solver(
            t: 0,
            dt: 0.2,
            rhs: DecayRHS(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            temporary: ODETestState()
        )
        var state = ODETestState(value: 1)

        let step = solver.step(y: &state, upTo: 0.15)
        let startTime = step.startTime
        #expect(startTime == 0)
        let endTime = step.endTime
        #expect(endTime == 0.15)
        let stepSize = step.stepSize
        #expect(stepSize == 0.15)
        let errorNorm = step.errorNorm
        #expect(errorNorm == nil)
        let rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 4)
        #expect(abs(state.value - exp(-0.15)) < 2e-6)

        var interpolated = ODETestState()
        solver.interpolateLastStep(at: 0.075, into: &interpolated)
        #expect(abs(interpolated.value - exp(-0.075)) < 1e-5)

        solver.truncateLastStep(at: 0.075, restoring: &state)
        let t = solver.t
        #expect(t == 0.075)
        let lastStep = solver.lastStep
        #expect(lastStep == nil)
        #expect(abs(state.value - exp(-0.075)) < 1e-5)
    }

    @Test("Dormand-Prince dense output follows the accepted solution")
    func dopriDenseOutput() throws {
        var solver = UniqueDOPRISolver(
            t: 0,
            dt: 0.4,
            maxStep: 0.4,
            rhs: DecayRHS(),
            y4: ODETestState(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            k5: ODETestState(),
            k6: ODETestState(),
            k7: ODETestState(),
            temporary: ODETestState(),
            absoluteTolerance: 1e-11,
            relativeTolerance: 1e-11
        )
        var state = ODETestState(value: 1)

        let step = try solver.step(y: &state, upTo: 0.4)
        let middleTime = 0.5 * (step.startTime + step.endTime)
        var denseStart = ODETestState()
        var interpolated = ODETestState()
        var denseEnd = ODETestState()
        solver.interpolateLastStep(at: step.startTime, into: &denseStart)
        solver.interpolateLastStep(at: middleTime, into: &interpolated)
        solver.interpolateLastStep(at: step.endTime, into: &denseEnd)
        
        let errorNorm = step.errorNorm
        #expect(errorNorm != nil)
        #expect((errorNorm ?? .infinity) <= 1)
        #expect(abs(denseStart.value - 1) < 1e-14)
        #expect(abs(state.value - exp(-step.endTime)) < 2e-9)
        #expect(abs(interpolated.value - exp(-middleTime)) < 2e-9)
        #expect(abs(denseEnd.value - state.value) < 1e-13)
    }

    @Test("Dormand-Prince rejects an overlarge trial without changing the initial state")
    func dopriRejectsOverlargeTrial() throws {
        var solver = UniqueDOPRISolver(
            t: 0,
            dt: 1,
            maxStep: 1,
            rhs: DecayRHS(),
            y4: ODETestState(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            k5: ODETestState(),
            k6: ODETestState(),
            k7: ODETestState(),
            temporary: ODETestState(),
            absoluteTolerance: 1e-14,
            relativeTolerance: 1e-14
        )
        var state = ODETestState(value: 1)

        let step = try solver.step(y: &state, upTo: 1)
        #expect(step.rejectedStepCount > 0)
        let rejectedStepCount = solver.rejectedStepCount
        #expect(rejectedStepCount == step.rejectedStepCount)
        let rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(
            rhsEvaluationCount
                == 1 + 6 * (step.rejectedStepCount + 1)
        )
        #expect(step.endTime < 1)
        #expect(abs(state.value - exp(-step.endTime)) < 1e-11)
    }

    @Test("Dormand-Prince reuses its FSAL derivative")
    func dopriFSAL() throws {
        var solver = UniqueDOPRISolver(
            t: 0,
            dt: 0.01,
            maxStep: 0.01,
            rhs: DecayRHS(),
            y4: ODETestState(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            k5: ODETestState(),
            k6: ODETestState(),
            k7: ODETestState(),
            temporary: ODETestState(),
            absoluteTolerance: 1e-8,
            relativeTolerance: 1e-8
        )
        var state = ODETestState(value: 1)

        _ = try solver.step(y: &state)
        var rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 7)
        let hasCachedFirstDerivative = solver.hasCachedFirstDerivative
        #expect(hasCachedFirstDerivative)

        _ = try solver.step(y: &state)
        rhsEvaluationCount = solver.rhsEvaluationCount
        let acceptedStepCount = solver.acceptedStepCount
        let rejectedStepCount = solver.rejectedStepCount
        #expect(rhsEvaluationCount == 13)
        #expect(acceptedStepCount == 2)
        #expect(rejectedStepCount == 0)
    }

    @Test("Dormand-Prince never accepts a non-finite error estimate")
    func dopriRejectsNonFiniteTrials() {
        var solver = UniqueDOPRISolver(
            t: 0,
            dt: 0.1,
            maxStep: 0.1,
            rhs: NaNRHS(),
            y4: ODETestState(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            k5: ODETestState(),
            k6: ODETestState(),
            k7: ODETestState(),
            temporary: ODETestState(),
            maximumStepAttempts: 3
        )
        var state = ODETestState(value: 1)

        do {
            _ = try solver.step(y: &state)
            Issue.record("A non-finite trial was unexpectedly accepted")
        } catch let error as ODESolverError {
            #expect(
                error == .maximumStepAttemptsExceeded(time: 0, attempts: 3)
            )
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        #expect(state.value == 1)
        let acceptedStepCount = solver.acceptedStepCount
        #expect(acceptedStepCount == 0)
        let rejectedStepCount = solver.rejectedStepCount
        #expect(rejectedStepCount == 3)
        let rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 19)
    }

    @Test("Restart invalidates FSAL and dense-output state")
    func dopriRestart() throws {
        var solver = UniqueDOPRISolver(
            t: 0,
            dt: 0.01,
            maxStep: 0.01,
            rhs: DecayRHS(),
            y4: ODETestState(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            k5: ODETestState(),
            k6: ODETestState(),
            k7: ODETestState(),
            temporary: ODETestState(),
            absoluteTolerance: 1e-8,
            relativeTolerance: 1e-8
        )
        var state = ODETestState(value: 1)

        let step = try solver.step(y: &state)
        let restartTime = 0.5 * (step.startTime + step.endTime)
        solver.truncateLastStep(
            at: restartTime,
            restoring: &state,
            proposedStepSize: 0.01
        )
        let lastStep = solver.lastStep
        #expect(lastStep == nil)
        let hasCachedFirstDerivative = solver.hasCachedFirstDerivative
        #expect(!hasCachedFirstDerivative)
        let t = solver.t
        #expect(t == restartTime)
        #expect(abs(state.value - exp(-restartTime)) < 1e-11)

        _ = try solver.step(y: &state)
        let rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 14)
    }

    @Test("A linear accumulated hazard can be localized without full-state interpolation")
    func hazardCrossing() throws {
        var solver = UniqueDOPRISolver(
            t: 0,
            dt: 1,
            maxStep: 1,
            rhs: ConstantHazardRHS(rate: 2),
            y4: ODETestState(),
            k1: ODETestState(),
            k2: ODETestState(),
            k3: ODETestState(),
            k4: ODETestState(),
            k5: ODETestState(),
            k6: ODETestState(),
            k7: ODETestState(),
            temporary: ODETestState(),
            absoluteTolerance: 1e-12,
            relativeTolerance: 1e-12
        )
        var state = ODETestState()
        let target = 0.37

        let step = try solver.step(y: &state, upTo: 1)
        #expect(step.endTime == 1)
        #expect(abs(state.hazard - 2) < 1e-14)
        let eventTime = solver.locateLastStepCrossing(
            of: target,
            linearFunctional: HazardFunctional(),
            timeTolerance: 1e-12
        )

        #expect(eventTime != nil)
        guard let eventTime else { return }
        #expect(abs(eventTime - target / 2) < 1e-11)

        let scalarHazard = solver.interpolateLastStep(
            at: eventTime,
            linearFunctional: HazardFunctional()
        )
        var eventState = ODETestState()
        solver.interpolateLastStep(at: eventTime, into: &eventState)

        #expect(abs(scalarHazard - target) < 2e-12)
        #expect(abs(eventState.hazard - target) < 2e-12)

        solver.truncateLastStep(at: eventTime, restoring: &state)
        let t = solver.t
        #expect(t == eventTime)
        let lastStep = solver.lastStep
        #expect(lastStep == nil)
        let hasCachedFirstDerivative = solver.hasCachedFirstDerivative
        #expect(!hasCachedFirstDerivative)
        #expect(abs(state.hazard - target) < 2e-12)
    }
}

private struct ODETestState: AdaptiveStepODESolverState {
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

private struct DecayRHS: ODERHSFunction {
    func evaluate(
        t: Double,
        y: borrowing ODETestState,
        dy: inout ODETestState
    ) {
        dy.value = -y.value
        dy.hazard = 0
    }
}

private struct ConstantHazardRHS: ODERHSFunction {
    let rate: Double

    func evaluate(
        t: Double,
        y: borrowing ODETestState,
        dy: inout ODETestState
    ) {
        dy.value = 0
        dy.hazard = rate
    }
}

private struct NaNRHS: ODERHSFunction {
    func evaluate(
        t: Double,
        y: borrowing ODETestState,
        dy: inout ODETestState
    ) {
        dy.value = .nan
        dy.hazard = 0
    }
}

private struct HazardFunctional: ODEStateLinearFunctional {
    func evaluate(_ state: borrowing ODETestState) -> Double {
        state.hazard
    }
}
