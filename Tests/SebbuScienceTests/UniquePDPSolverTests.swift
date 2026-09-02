// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import SebbuScience

@Suite("Unique PDP solver")
struct UniquePDPSolverTests {
    @Test("DOPRI locates a jump and preserves dense output until it is applied")
    func dopriJumpAndDenseOutput() throws {
        let thresholdBits: UInt64 = 1 << 63
        let jumpBits: UInt64 = 0x0123_4567_89AB_CDEF
        let nextThresholdBits: UInt64 = 1 << 62
        var rng = ScriptedRNG([
            thresholdBits,
            jumpBits,
            nextThresholdBits,
        ])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueDOPRISolver(
                t: 0,
                dt: 1,
                maxStep: 1,
                rhs: ConstantPDPDynamics(drift: 1, intensity: 2),
                y4: PDPTestState(),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                k5: PDPTestState(),
                k6: PDPTestState(),
                k7: PDPTestState(),
                temporary: PDPTestState(),
                absoluteTolerance: 1e-12,
                relativeTolerance: 1e-12
            ),
            jumpKernel: AdditiveJumpKernel(increment: 10),
            eventTimeTolerance: 1e-12,
            using: &rng
        )
        var state = PDPTestState()

        let threshold = exponentialThreshold(for: thresholdBits)
        #expect(solver.hazardThreshold == threshold)
        #expect(rng.drawCount == 1)

        let result = try solver.step(y: &state, upTo: 1)
        guard case .jumpPending(let pending) = result else {
            Issue.record("The threshold crossing did not produce a pending jump")
            return
        }

        let expectedJumpTime = threshold / 2
        #expect(pending.containingStep.startTime == 0)
        #expect(pending.containingStep.endTime == 1)
        #expect(abs(pending.time - expectedJumpTime) < 1e-12)
        #expect(pending.hazardThreshold == threshold)
        #expect(solver.pendingJump == pending)
        #expect(solver.t == pending.time)
        #expect(solver.lastStep == pending.containingStep)
        #expect(solver.jumpCount == 0)
        #expect(abs(state.value - pending.time) < 2e-12)
        #expect(state.cumulativeHazard == threshold)
        #expect(rng.drawCount == 1)

        let sampleTime = 0.5 * pending.time
        var interpolated = PDPTestState()
        solver.interpolateLastStep(at: sampleTime, into: &interpolated)
        #expect(abs(interpolated.value - sampleTime) < 2e-12)
        #expect(abs(interpolated.cumulativeHazard - 2 * sampleTime) < 2e-12)

        let scalarValue = solver.interpolateLastStep(
            at: sampleTime,
            linearFunctional: PDPValueFunctional()
        )
        let complexValue = solver.interpolateLastStep(
            at: sampleTime,
            linearFunctional: PDPComplexFunctional()
        )
        #expect(abs(scalarValue - sampleTime) < 2e-12)
        #expect(abs(complexValue.real - sampleTime) < 2e-12)
        #expect(abs(complexValue.imaginary - 2 * sampleTime) < 2e-12)

        let mark = solver.applyPendingJump(y: &state, using: &rng)
        #expect(mark.time == pending.time)
        #expect(mark.randomValue == jumpBits)
        #expect(abs(state.value - (pending.time + 10)) < 2e-12)
        #expect(state.cumulativeHazard == 0)
        #expect(solver.t == pending.time)
        #expect(solver.lastStep == nil)
        #expect(solver.pendingJump == nil)
        #expect(solver.jumpCount == 1)
        #expect(
            solver.hazardThreshold
                == exponentialThreshold(for: nextThresholdBits)
        )
        #expect(rng.drawCount == 3)
    }

    @Test("RK4 accepts non-event steps and invalidates dense output after a state change")
    func rk4AcceptedStepAndStateChange() throws {
        let thresholdBits: UInt64 = 1 << 61
        var rng = ScriptedRNG([thresholdBits])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueRK4Solver(
                t: 0,
                dt: 0.25,
                rhs: ConstantPDPDynamics(drift: 2, intensity: 1),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                temporary: PDPTestState()
            ),
            jumpKernel: NoOpJumpKernel(),
            using: &rng
        )
        var state = PDPTestState()
        let threshold = solver.hazardThreshold

        let result = try solver.step(y: &state, upTo: 0.25)
        guard case .accepted(let step) = result else {
            Issue.record("A step below the hazard threshold was not accepted")
            return
        }

        #expect(step.startTime == 0)
        #expect(step.endTime == 0.25)
        #expect(solver.t == 0.25)
        #expect(solver.lastStep == step)
        #expect(solver.pendingJump == nil)
        #expect(solver.hazardThreshold == threshold)
        #expect(rng.drawCount == 1)
        #expect(abs(state.value - 0.5) < 1e-14)
        #expect(abs(state.cumulativeHazard - 0.25) < 1e-14)

        var interpolated = PDPTestState()
        solver.interpolateLastStep(at: 0.125, into: &interpolated)
        #expect(abs(interpolated.value - 0.25) < 1e-14)
        #expect(abs(interpolated.cumulativeHazard - 0.125) < 1e-14)

        state.value = 42
        solver.stateDidChange()
        #expect(solver.t == 0.25)
        #expect(solver.lastStep == nil)
        #expect(solver.hazardThreshold == threshold)
        #expect(state.cumulativeHazard.isApproximatelyEqual(to: 0.25))

        let nextResult = try solver.step(y: &state, upTo: 0.5)
        guard case .accepted(let nextStep) = nextResult else {
            Issue.record("Integration did not resume after the state change")
            return
        }
        #expect(nextStep.startTime == 0.25)
        #expect(nextStep.endTime == 0.5)
        #expect(abs(state.value - 42.5) < 1e-14)
        #expect(abs(state.cumulativeHazard - 0.5) < 1e-14)
    }

    @Test("Verner 7(6) can be used as the deterministic solver")
    func vernerJump() throws {
        let thresholdBits: UInt64 = 1 << 63
        var rng = ScriptedRNG([thresholdBits])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueVerner76Solver(
                t: 0,
                dt: 1,
                maxStep: 1,
                rhs: ConstantPDPDynamics(drift: -0.5, intensity: 1),
                y6: PDPTestState(),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                k5: PDPTestState(),
                k6: PDPTestState(),
                k7: PDPTestState(),
                k8: PDPTestState(),
                k9: PDPTestState(),
                k10: PDPTestState(),
                temporary: PDPTestState(),
                absoluteTolerance: 1e-12,
                relativeTolerance: 1e-12
            ),
            jumpKernel: NoOpJumpKernel(),
            eventTimeTolerance: 1e-12,
            using: &rng
        )
        var state = PDPTestState(value: 2)

        let result = try solver.step(y: &state, upTo: 1)
        guard case .jumpPending(let pending) = result else {
            Issue.record("Verner dense output did not locate the jump")
            return
        }

        let expectedTime = exponentialThreshold(for: thresholdBits)
        #expect(abs(pending.time - expectedTime) < 2e-12)
        #expect(abs(state.value - (2 - 0.5 * pending.time)) < 2e-11)
        #expect(state.cumulativeHazard == pending.hazardThreshold)
        #expect(solver.t == pending.time)
    }

    @Test("A threshold near zero is localized instead of rounded to the step start")
    func nearZeroThreshold() throws {
        let thresholdBits = UInt64.max
        let intensity = 1e-9
        var rng = ScriptedRNG([thresholdBits])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueRK4Solver(
                t: 0,
                dt: 1,
                rhs: ConstantPDPDynamics(
                    drift: 0,
                    intensity: intensity
                ),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                temporary: PDPTestState()
            ),
            jumpKernel: NoOpJumpKernel(),
            eventTimeTolerance: 1e-12,
            using: &rng
        )
        var state = PDPTestState()

        let result = try solver.step(y: &state, upTo: 1)
        guard case .jumpPending(let pending) = result else {
            Issue.record("The near-zero threshold crossing was not located")
            return
        }

        let expectedTime = exponentialThreshold(for: thresholdBits) / intensity
        #expect(expectedTime > 1e-8)
        #expect(pending.time > 0)
        #expect(abs(pending.time - expectedTime) < 1e-12)
        #expect(state.cumulativeHazard == pending.hazardThreshold)
    }

    @Test("Adaptive deterministic errors are wrapped")
    func deterministicErrorIsWrapped() {
        var rng = ScriptedRNG([1 << 63])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueDOPRISolver(
                t: 0,
                dt: 0.1,
                maxStep: 0.1,
                rhs: ConstantPDPDynamics(drift: 0, intensity: 1),
                y4: PDPTestState(),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                k5: PDPTestState(),
                k6: PDPTestState(),
                k7: PDPTestState(),
                temporary: PDPTestState(),
                absoluteTolerance: 1e-12,
                relativeTolerance: 1e-12
            ),
            jumpKernel: NoOpJumpKernel(),
            using: &rng
        )
        var state = PDPTestState()

        do {
            _ = try solver.step(y: &state, upTo: 0)
            Issue.record("The deterministic end-time error was not thrown")
        } catch {
            #expect(
                error
                    == .deterministic(
                        .requestedEndTimeReached(endTime: 0, solverTime: 0)
                    )
            )
        }

        #expect(solver.t == 0)
        #expect(solver.lastStep == nil)
        #expect(state == PDPTestState())
    }

    @Test("A non-finite cumulative hazard is rejected")
    func invalidCumulativeHazard() {
        var rng = ScriptedRNG([1 << 63])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueRK4Solver(
                t: 0,
                dt: 0.1,
                rhs: ConstantPDPDynamics(drift: 0, intensity: .nan),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                temporary: PDPTestState()
            ),
            jumpKernel: NoOpJumpKernel(),
            using: &rng
        )
        var state = PDPTestState()

        do {
            _ = try solver.step(y: &state, upTo: 0.1)
            Issue.record("A non-finite cumulative hazard was accepted")
        } catch let error {
            guard case .invalidCumulativeHazard(let time, let value) = error else {
                Issue.record("Unexpected PDP error: \(error)")
                return
            }
            #expect(time == 0.1)
            #expect(value.isNaN)
        }
    }

    @Test("Event localization reports its iteration limit")
    func eventIterationLimit() {
        var rng = ScriptedRNG([1 << 63])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueRK4Solver(
                t: 0,
                dt: 1,
                rhs: ConstantPDPDynamics(drift: 0, intensity: 1),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                temporary: PDPTestState()
            ),
            jumpKernel: NoOpJumpKernel(),
            eventTimeTolerance: 1e-15,
            maximumEventIterations: 1,
            using: &rng
        )
        var state = PDPTestState()

        do {
            _ = try solver.step(y: &state, upTo: 1)
            Issue.record("Event localization unexpectedly converged")
        } catch {
            #expect(
                error
                    == .eventLocationDidNotConverge(
                        stepStart: 0,
                        stepEnd: 1,
                        iterations: 1
                    )
            )
        }

        #expect(solver.t == 1)
        #expect(solver.pendingJump == nil)
        #expect(solver.lastStep?.endTime == 1)
        #expect(state.cumulativeHazard.isApproximatelyEqual(to: 1))
    }

    @Test("A failed jump remains pending and does not renew the hazard clock")
    func failedJumpRemainsPending() throws {
        var rng = ScriptedRNG([1 << 63])
        var solver = UniquePDPSolver(
            deterministicSolver: UniqueRK4Solver(
                t: 0,
                dt: 1,
                rhs: ConstantPDPDynamics(drift: 1, intensity: 1),
                k1: PDPTestState(),
                k2: PDPTestState(),
                k3: PDPTestState(),
                k4: PDPTestState(),
                temporary: PDPTestState()
            ),
            jumpKernel: FailingJumpKernel(),
            eventTimeTolerance: 1e-12,
            using: &rng
        )
        var state = PDPTestState()

        let result = try solver.step(y: &state, upTo: 1)
        guard case .jumpPending(let pending) = result else {
            Issue.record("The expected jump was not located")
            return
        }
        let preJumpState = state
        let threshold = solver.hazardThreshold

        do {
            try solver.applyPendingJump(y: &state, using: &rng)
            Issue.record("The jump-kernel failure was not propagated")
        } catch {
            #expect(error == .expected)
        }

        #expect(state == preJumpState)
        #expect(solver.pendingJump == pending)
        #expect(solver.t == pending.time)
        #expect(solver.lastStep == pending.containingStep)
        #expect(solver.hazardThreshold == threshold)
        #expect(solver.jumpCount == 0)
        #expect(rng.drawCount == 1)

        var interpolated = PDPTestState()
        solver.interpolateLastStep(
            at: 0.5 * pending.time,
            into: &interpolated
        )
        #expect(abs(interpolated.value - 0.5 * pending.time) < 2e-12)
    }
}

private struct PDPTestState: AdaptiveStepODESolverState, PDPState, Equatable {
    var value: Double = 0
    var cumulativeHazard: Double = 0

    var norm: Double {
        hypot(value, cumulativeHazard)
    }

    mutating func assign(_ other: borrowing Self) {
        value = other.value
        cumulativeHazard = other.cumulativeHazard
    }

    mutating func add(_ other: borrowing Self, multiplied: Double) {
        value += other.value * multiplied
        cumulativeHazard += other.cumulativeHazard * multiplied
    }

    mutating func assign(
        _ base: borrowing Self,
        adding direction: borrowing Self,
        multipliedBy coefficient: Double
    ) {
        value = base.value + direction.value * coefficient
        cumulativeHazard = base.cumulativeHazard
            + direction.cumulativeHazard * coefficient
    }

    func errorNorm(to other: borrowing Self) -> Double {
        hypot(
            value - other.value,
            cumulativeHazard - other.cumulativeHazard
        )
    }
}

private struct ConstantPDPDynamics: ODERHSFunction {
    let drift: Double
    let intensity: Double

    func evaluate(
        t: Double,
        y: borrowing PDPTestState,
        dy: inout PDPTestState
    ) {
        dy.value = drift
        dy.cumulativeHazard = intensity
    }
}

private struct TestJumpMark: Equatable {
    let time: Double
    let randomValue: UInt64
}

private struct AdditiveJumpKernel: PDPJumpKernel {
    typealias State = PDPTestState
    typealias Mark = TestJumpMark

    let increment: Double

    mutating func sampleAndApplyJump<RNG: RandomNumberGenerator>(
        at time: Double,
        to state: inout PDPTestState,
        using rng: inout RNG
    ) -> TestJumpMark {
        state.value += increment
        return TestJumpMark(time: time, randomValue: rng.next())
    }
}

private struct NoOpJumpKernel: PDPJumpKernel {
    typealias State = PDPTestState

    mutating func sampleAndApplyJump<RNG: RandomNumberGenerator>(
        at time: Double,
        to state: inout PDPTestState,
        using rng: inout RNG
    ) {}
}

private enum TestJumpError: Error, Equatable {
    case expected
}

private struct FailingJumpKernel: PDPJumpKernel {
    typealias State = PDPTestState
    typealias Failure = TestJumpError

    mutating func sampleAndApplyJump<RNG: RandomNumberGenerator>(
        at time: Double,
        to state: inout PDPTestState,
        using rng: inout RNG
    ) throws(TestJumpError) {
        throw .expected
    }
}

private struct ScriptedRNG: RandomNumberGenerator {
    let values: [UInt64]
    private(set) var drawCount = 0

    init(_ values: [UInt64]) {
        self.values = values
    }

    mutating func next() -> UInt64 {
        precondition(drawCount < values.count, "The scripted RNG is exhausted")
        defer { drawCount += 1 }
        return values[drawCount]
    }
}

private struct PDPValueFunctional: ODEStateLinearFunctional {
    func evaluate(_ state: borrowing PDPTestState) -> Double {
        state.value
    }
}

private struct PDPComplexFunctional: ODEStateComplexLinearFunctional {
    func evaluate(_ state: borrowing PDPTestState) -> Complex<Double> {
        Complex(state.value, state.cumulativeHazard)
    }
}

private func exponentialThreshold(for bits: UInt64) -> Double {
    let significand = bits >> 11
    let midpointScale = 0x1.0p-53
    let halfSignificandRange: UInt64 = 1 << 52
    if significand < halfSignificandRange {
        return -Double.log(
            (Double(significand) + 0.5) * midpointScale
        )
    }

    let maximumSignificand: UInt64 = (1 << 53) - 1
    let distanceFromOne = (
        Double(maximumSignificand - significand) + 0.5
    ) * midpointScale
    return -Double.log(onePlus: -distanceFromOne)
}
