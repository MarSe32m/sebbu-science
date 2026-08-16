// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Foundation
import Testing
@testable import SebbuScience

@Suite("Unique SDE solver")
struct UniqueSDESolverTests {
    @Test("Stochastic Heun reduces to deterministic Heun and clamps its step")
    func deterministicLimit() {
        var noiseStorage: [Double] = []
        let noiseSpan = noiseStorage.mutableSpan
        var solver = UniqueSRK2Solver(
            t: 0,
            dt: 0.2,
            rhs: DecaySDE(),
            drift0: SDETestState(),
            drift1: SDETestState(),
            noise0: SDETestState(),
            noise1: SDETestState(),
            temporary: SDETestState(),
            noises: noiseSpan
        )
        var state = SDETestState(value: 1)

        let step = solver.step(y: &state, upTo: 0.15)
        let startTime = step.startTime
        #expect(startTime == 0)
        let endTime = step.endTime
        #expect(endTime == 0.15)
        let stepSize = step.stepSize
        #expect(stepSize == 0.15)
        let errorNorm = step.errorNorm
        #expect(errorNorm == nil)
        #expect(abs(state.value - 0.86125) < 1e-14)
        var acceptedStepCount = solver.acceptedStepCount
        #expect(acceptedStepCount == 1)
        let driftEvaluationCount = solver.driftEvaluationCount
        #expect(driftEvaluationCount == 2)
        let diffusionEvaluationCount = solver.diffusionEvaluationCount
        #expect(diffusionEvaluationCount == 0)
        var rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 2)
        var noiseSamplingCallCount = solver.noiseSamplingCallCount
        #expect(noiseSamplingCallCount == 1)
        let noiseChannelCount = solver.noiseChannelCount
        #expect(noiseChannelCount == 0)

        solver.stateDidChange()
        let lastStep = solver.lastStep
        #expect(lastStep == nil)
        var t = solver.t
        #expect(t == 0.15)

        solver.restart(at: 0.1)
        t = solver.t
        #expect(t == 0.1)

        solver.resetStatistics()
        acceptedStepCount = solver.acceptedStepCount
        #expect(acceptedStepCount == 0)
        rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 0)
        noiseSamplingCallCount = solver.noiseSamplingCallCount
        #expect(noiseSamplingCallCount == 0)
    }

    @Test("The actual shortened step scales the normalized Wiener value")
    func shortenedNoiseStep() {
        var noiseStorage = [0.0]
        let noiseSpan = noiseStorage.mutableSpan
        var solver = UniqueSRK2Solver(
            t: 0.5,
            dt: 1,
            rhs: StepAwareAdditiveNoiseSDE(),
            drift0: SDETestState(),
            drift1: SDETestState(),
            noise0: SDETestState(),
            noise1: SDETestState(),
            temporary: SDETestState(),
            noises: noiseSpan
        )
        var state = SDETestState(value: 1)

        let step = solver.step(y: &state, upTo: 0.75)

        #expect(step.startTime == 0.5)
        #expect(step.endTime == 0.75)
        #expect(step.stepSize == 0.25)
        // The sampler receives (t, h) = (0.5, 0.25), hence xi = 0.75.
        // The solver then applies Delta W = sqrt(0.25) * xi = 0.375.
        #expect(abs(state.value - 1.375) < 1e-14)
        let driftEvaluationCount = solver.driftEvaluationCount
        #expect(driftEvaluationCount == 2)
        let diffusionEvaluationCount = solver.diffusionEvaluationCount
        #expect(diffusionEvaluationCount == 2)
        let rhsEvaluationCount = solver.rhsEvaluationCount
        #expect(rhsEvaluationCount == 4)
    }

    @Test("Both Heun stages reuse the same multiplicative-noise increment")
    func multiplicativeNoise() {
        var noiseStorage = [0.0]
        let noiseSpan = noiseStorage.mutableSpan
        var solver = UniqueSRK2Solver(
            t: 0,
            dt: 0.25,
            rhs: MultiplicativeNoiseSDE(normalizedNoise: 0.4),
            drift0: SDETestState(),
            drift1: SDETestState(),
            noise0: SDETestState(),
            noise1: SDETestState(),
            temporary: SDETestState(),
            noises: noiseSpan
        )
        var state = SDETestState(value: 1)

        _ = solver.step(y: &state)

        // Delta W = sqrt(0.25) * 0.4 = 0.2. The predictor is 1.2 and
        // the Heun result is 1 + 0.5 * (1 + 1.2) * 0.2 = 1.22.
        #expect(abs(state.value - 1.22) < 1e-14)
    }

    @Test("Multiple diffusion channels are accumulated without extra state scaling")
    func multipleNoiseChannels() {
        var noiseStorage = [0.0, 0.0]
        let noiseSpan = noiseStorage.mutableSpan
        var solver = UniqueSRK2Solver(
            t: 0,
            dt: 0.25,
            rhs: TwoChannelAdditiveSDE(),
            drift0: SDETestState(),
            drift1: SDETestState(),
            noise0: SDETestState(),
            noise1: SDETestState(),
            temporary: SDETestState(),
            noises: noiseSpan
        )
        var state = SDETestState(value: 1)

        _ = solver.step(y: &state)

        // Drift contribution: 2 * 0.25 = 0.5.
        // Noise contribution: sqrt(0.25) * (1 * 0.5 + 2 * -0.1) = 0.15.
        #expect(abs(state.value - 1.65) < 1e-14)
        let diffusionEvaluationCount = solver.diffusionEvaluationCount
        #expect(diffusionEvaluationCount == 4)
        let noiseChannelCount = solver.noiseChannelCount
        #expect(noiseChannelCount == 2)
    }
}

private struct SDETestState: FixedStepSDESolverState {
    typealias NoiseType = Double

    var value: Double = 0

    mutating func assign(_ other: borrowing Self) {
        value = other.value
    }

    mutating func add(_ other: borrowing Self, multiplied: Double) {
        value += other.value * multiplied
    }

    mutating func assign(
        _ base: borrowing Self,
        adding direction: borrowing Self,
        multipliedBy coefficient: Double
    ) {
        value = base.value + direction.value * coefficient
    }

    mutating func zero() {
        value = 0
    }

    mutating func add(
        _ other: borrowing Self,
        scaledBy noise: borrowing Double
    ) {
        value += other.value * noise
    }
}

private struct DecaySDE: SDERHSFunction {
    func drift(
        t: Double,
        y: borrowing SDETestState,
        into dy: inout SDETestState
    ) {
        dy.value = -y.value
    }

    func diffusion(
        t: Double,
        y: borrowing SDETestState,
        channel: Int,
        into dy: inout SDETestState
    ) {
        dy.value = 0
    }

    func sampleNormalizedNoises(
        t: Double,
        stepSize: Double,
        into noises: inout MutableSpan<Double>
    ) {}
}

private struct StepAwareAdditiveNoiseSDE: SDERHSFunction {
    func drift(
        t: Double,
        y: borrowing SDETestState,
        into dy: inout SDETestState
    ) {
        dy.value = 0
    }

    func diffusion(
        t: Double,
        y: borrowing SDETestState,
        channel: Int,
        into dy: inout SDETestState
    ) {
        dy.value = 1
    }

    func sampleNormalizedNoises(
        t: Double,
        stepSize: Double,
        into noises: inout MutableSpan<Double>
    ) {
        noises[unchecked: 0] = t + stepSize
    }
}

private struct MultiplicativeNoiseSDE: SDERHSFunction {
    let normalizedNoise: Double

    func drift(
        t: Double,
        y: borrowing SDETestState,
        into dy: inout SDETestState
    ) {
        dy.value = 0
    }

    func diffusion(
        t: Double,
        y: borrowing SDETestState,
        channel: Int,
        into dy: inout SDETestState
    ) {
        dy.value = y.value
    }

    func sampleNormalizedNoises(
        t: Double,
        stepSize: Double,
        into noises: inout MutableSpan<Double>
    ) {
        noises[unchecked: 0] = normalizedNoise
    }
}

private struct TwoChannelAdditiveSDE: SDERHSFunction {
    func drift(
        t: Double,
        y: borrowing SDETestState,
        into dy: inout SDETestState
    ) {
        dy.value = 2
    }

    func diffusion(
        t: Double,
        y: borrowing SDETestState,
        channel: Int,
        into dy: inout SDETestState
    ) {
        dy.value = channel == 0 ? 1 : 2
    }

    func sampleNormalizedNoises(
        t: Double,
        stepSize: Double,
        into noises: inout MutableSpan<Double>
    ) {
        noises[unchecked: 0] = 0.5
        noises[unchecked: 1] = -0.1
    }
}
