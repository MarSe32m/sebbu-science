// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// Allocation-free, two-stage stochastic Heun integration for Stratonovich
/// stochastic differential equations.
///
/// For scalar, diagonal, additive, or otherwise commutative noise, the method
/// has strong order one. For general noncommutative multi-channel noise its
/// strong order is one half; the `2` in `SRK2` denotes the two-stage Heun
/// construction and its deterministic order, not stochastic strong order two.
/// See <https://arxiv.org/abs/1210.0933>.
///
/// The state buffers supplied at initialization, and the state passed to
/// ``step(y:upTo:)``, must have distinct writable storage. The solver does not
/// provide deterministic dense output: interpolation inside a stochastic step
/// requires the driving path, normally through a Brownian bridge or a
/// noise-process-specific interpolant.
///
/// The length of `noises` supplied to the initializer defines the number of
/// diffusion channels. Every step samples that span once and reuses exactly
/// the same values at both Heun stages.
@frozen
public struct UniqueSRK2Solver<
    State: ~Copyable & FixedStepSDESolverState,
    RHS: ~Copyable & ~Escapable & SDERHSFunction
>: ~Copyable, ~Escapable where RHS.State == State {
    @usableFromInline
    internal var _t: Double
    public var dt: Double

    @usableFromInline
    internal var _lastStep: SDEStep? = nil
    @usableFromInline
    internal var _acceptedStepCount: Int = 0
    @usableFromInline
    internal var _driftEvaluationCount: Int = 0
    @usableFromInline
    internal var _diffusionEvaluationCount: Int = 0
    @usableFromInline
    internal var _noiseSamplingCallCount: Int = 0

    @inlinable
    public var t: Double { _t }
    @inlinable
    public var lastStep: SDEStep? { _lastStep }
    @inlinable
    public var acceptedStepCount: Int { _acceptedStepCount }
    @inlinable
    public var driftEvaluationCount: Int { _driftEvaluationCount }
    @inlinable
    public var diffusionEvaluationCount: Int { _diffusionEvaluationCount }
    @inlinable
    public var rhsEvaluationCount: Int {
        _driftEvaluationCount &+ _diffusionEvaluationCount
    }
    @inlinable
    public var noiseSamplingCallCount: Int { _noiseSamplingCallCount }
    @inlinable
    public var noiseChannelCount: Int { noises.count }

    @usableFromInline
    internal var rhs: RHS

    @usableFromInline
    internal var drift0: State
    @usableFromInline
    internal var drift1: State
    @usableFromInline
    internal var noise0: State
    @usableFromInline
    internal var noise1: State
    @usableFromInline
    internal var temporary: State

    /// Dimensionless normalized noise values retained for both Heun stages.
    @usableFromInline
    internal var noises: MutableSpan<State.NoiseType>

    @_lifetime(copy rhs, copy noises)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        rhs: consuming RHS,
        drift0: consuming State,
        drift1: consuming State,
        noise0: consuming State,
        noise1: consuming State,
        temporary: consuming State,
        noises: consuming MutableSpan<State.NoiseType>
    ) {
        precondition(t.isFinite, "Initial time must be finite")
        precondition(
            dt.isFinite && dt > .zero,
            "Time-step must be positive and finite"
        )

        self._t = t
        self.dt = dt
        self.rhs = rhs
        self.drift0 = drift0
        self.drift1 = drift1
        self.noise0 = noise0
        self.noise1 = noise1
        self.temporary = temporary
        self.noises = noises
    }

    /// Advances by one stochastic Heun step without passing `endTime`.
    ///
    /// A shorter final step draws a fresh normalized noise vector and scales it
    /// by the square root of the actual step size. The nominal ``dt`` remains
    /// unchanged. The same noise vector is used for the predictor and
    /// corrector evaluations, as required by stochastic Heun.
    @inlinable
    public mutating func step(
        y: inout State,
        upTo endTime: Double = .infinity
    ) -> SDEStep {
        precondition(
            endTime > t,
            "The step bound must be later than the current time"
        )
        precondition(
            dt.isFinite && dt > .zero,
            "Time-step must be positive and finite"
        )

        _lastStep = nil

        let startTime = t
        let stepSize = Swift.min(dt, endTime - startTime)
        precondition(
            stepSize.isFinite
                && stepSize > .zero
                && startTime + stepSize > startTime,
            "Time-step is too small to advance time"
        )

        let stepEndTime = startTime + stepSize
        let squareRootStepSize = stepSize.squareRoot()

        rhs.sampleNormalizedNoises(
            t: startTime,
            stepSize: stepSize,
            into: &noises
        )
        _noiseSamplingCallCount &+= 1

        rhs.drift(t: startTime, y: y, into: &drift0)
        _driftEvaluationCount &+= 1

        noise0.zero()
        for channel in noises.indices {
            rhs.diffusion(
                t: startTime,
                y: y,
                channel: channel,
                into: &temporary
            )
            _diffusionEvaluationCount &+= 1
            noise0.add(
                temporary,
                scaledBy: noises[unchecked: channel]
            )
        }

        // Predictor = y_n + h * drift0 + sqrt(h) * noise0.
        temporary.assign(
            y,
            adding: drift0,
            multipliedBy: stepSize
        )
        temporary.add(noise0, multiplied: squareRootStepSize)

        // Apply the first half of the corrector before reusing noise0 as the
        // second-stage diffusion scratch buffer.
        y.add(drift0, multiplied: 0.5 * stepSize)
        y.add(noise0, multiplied: 0.5 * squareRootStepSize)

        rhs.drift(t: stepEndTime, y: temporary, into: &drift1)
        _driftEvaluationCount &+= 1

        noise1.zero()
        for channel in noises.indices {
            rhs.diffusion(
                t: stepEndTime,
                y: temporary,
                channel: channel,
                into: &noise0
            )
            _diffusionEvaluationCount &+= 1
            noise1.add(
                noise0,
                scaledBy: noises[unchecked: channel]
            )
        }

        y.add(drift1, multiplied: 0.5 * stepSize)
        y.add(noise1, multiplied: 0.5 * squareRootStepSize)

        _t = stepEndTime
        _acceptedStepCount &+= 1

        let result = SDEStep(
            startTime: startTime,
            endTime: stepEndTime,
            suggestedNextStepSize: dt
        )
        _lastStep = result
        return result
    }

    /// Restarts the solver clock after a discontinuity at a step boundary.
    ///
    /// This does not rewind the random generator held by `rhs`. Restarting from
    /// inside an accepted stochastic step requires a Brownian bridge or an
    /// explicitly replayable noise source and is intentionally not provided.
    @inlinable
    public mutating func restart(at time: Double) {
        precondition(time.isFinite, "Restart time must be finite")
        _t = time
        _lastStep = nil
    }

    /// Invalidates step metadata after a discontinuous state change at `t`.
    @inlinable
    public mutating func stateDidChange() {
        _lastStep = nil
    }

    @inlinable
    public mutating func resetStatistics() {
        _acceptedStepCount = 0
        _driftEvaluationCount = 0
        _diffusionEvaluationCount = 0
        _noiseSamplingCallCount = 0
    }
}
