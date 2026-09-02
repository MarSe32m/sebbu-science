// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

public protocol PDPState: ~Copyable, FixedStepODESolverState {
    /// Integral of the total intensity since the last jump.
    var cumulativeHazard: Double { get set }
}

public protocol PDPJumpKernel: ~Copyable, ~Escapable {
    associatedtype State: ~Copyable, PDPState
    associatedtype Mark = Void
    associatedtype Failure: Error = Never

    /// Samples from the post-jump kernel and modifies `state` in place.
    ///
    /// The state is the pre-jump state at `time`. The cumulative hazard is
    /// reset by ``UniquePDPSolver`` after this method succeeds.
    mutating func sampleAndApplyJump<
        RNG: RandomNumberGenerator
    >(
        at time: Double,
        to state: inout State,
        using rng: inout RNG
    ) throws(Failure) -> Mark
}

@frozen
public struct PendingPDPJump: Sendable, Equatable {
    /// Located jump time.
    public let time: Double

    /// Sampled unit-exponential hazard threshold.
    public let hazardThreshold: Double

    /// Accepted ODE step containing the jump.
    public let containingStep: ODEStep
    
    @inlinable
    init(time: Double, hazardThreshold: Double, containingStep: ODEStep) {
        self.time = time
        self.hazardThreshold = hazardThreshold
        self.containingStep = containingStep
    }
}

@frozen
public enum PDPStep: Sendable, Equatable {
    /// A complete deterministic step with no jump.
    case accepted(ODEStep)

    /// The external state has been interpolated to the pre-jump state.
    /// Dense output for `containingStep` remains available.
    case jumpPending(PendingPDPJump)
}

@frozen
public enum PDPSolverError: Error, Equatable, Sendable {
    case deterministic(ODESolverError)

    case invalidCumulativeHazard(
        time: Double,
        value: Double
    )

    case eventNotBracketed(
        stepStart: Double,
        stepEnd: Double,
        lowerHazard: Double,
        upperHazard: Double,
        threshold: Double
    )

    case eventLocationDidNotConverge(
        stepStart: Double,
        stepEnd: Double,
        iterations: Int
    )
}

@usableFromInline
internal struct CumulativeHazardFunctional<
    State: ~Copyable & PDPState
>: ODEStateLinearFunctional {
    @inlinable
    init() {}
    
    @inline(always)
    @inlinable
    func evaluate(_ state: borrowing State) -> Double {
        state.cumulativeHazard
    }
}

/// Allocation-free event-driven integration of a piecewise-deterministic
/// process.
///
/// The deterministic solver advances an augmented state whose cumulative
/// hazard component is the integral of the total jump intensity since the
/// previous jump. The PDP solver draws a unit-exponential threshold and
/// locates the first crossing using the dense output of the deterministic
/// solver.
///
/// A crossing is handled in two phases. The ``step(y:upTo:)`` method
/// interpolates the external state to the pre-jump state and returns a pending
/// jump while retaining the dense output of the accepted ODE step. This allows
/// callers to sample every requested time strictly before the jump. Applying
/// the pending jump then invokes the post-jump kernel, resets the cumulative
/// hazard, samples the next threshold, and restarts the deterministic solver
/// at the event time.
///
/// The state buffers owned by the deterministic solver and the state passed
/// to ``step(y:upTo:)`` must have distinct writable storage.
public struct UniquePDPSolver<
    Deterministic: ~Copyable & ~Escapable & UniqueDenseOutputODESolver,
    JumpKernel: ~Copyable & ~Escapable & PDPJumpKernel
>: ~Copyable, ~Escapable
where
    Deterministic.State: PDPState,
    JumpKernel.State == Deterministic.State
{
    public typealias State = Deterministic.State

    @usableFromInline
    internal var deterministicSolver: Deterministic
    @usableFromInline
    internal var jumpKernel: JumpKernel

    public var eventTimeTolerance: Double
    public var maximumEventIterations: Int

    @usableFromInline
    internal var _hazardThreshold: Double
    @usableFromInline
    internal var _pendingJump: PendingPDPJump? = nil
    @usableFromInline
    internal var _jumpCount: Int = 0

    /// Event time while a jump is pending; otherwise deterministic solver time.
    public var t: Double {
        _pendingJump?.time ?? deterministicSolver.t
    }

    /// The last accepted deterministic step.
    ///
    /// While a jump is pending, this is the step which contains the event and
    /// may extend beyond the public time. Dense output must only be sampled
    /// through the pending jump time.
    public var lastStep: ODEStep? {
        deterministicSolver.lastStep
    }

    public var hazardThreshold: Double {
        _hazardThreshold
    }

    public var pendingJump: PendingPDPJump? {
        _pendingJump
    }

    public var jumpCount: Int {
        _jumpCount
    }

    @_lifetime(copy deterministicSolver, copy jumpKernel)
    public init<RNG: RandomNumberGenerator>(
        deterministicSolver: consuming Deterministic,
        jumpKernel: consuming JumpKernel,
        eventTimeTolerance: Double = 1e-10,
        maximumEventIterations: Int = 64,
        using rng: inout RNG
    ) {
        precondition(
            eventTimeTolerance.isFinite && eventTimeTolerance > .zero,
            "The PDP event-time tolerance must be positive and finite"
        )
        precondition(
            maximumEventIterations > 0,
            "The maximum PDP event-iteration count must be positive"
        )

        self.deterministicSolver = deterministicSolver
        self.jumpKernel = jumpKernel
        self.eventTimeTolerance = eventTimeTolerance
        self.maximumEventIterations = maximumEventIterations
        self._hazardThreshold = Self.sampleHazardThreshold(using: &rng)
    }

    /// Advances by at most one accepted deterministic step.
    ///
    /// If a threshold crossing occurs, `y` is interpolated back to the
    /// pre-jump state and a pending jump is returned.
    @inlinable
    public mutating func step(
        y: inout State,
        upTo endTime: Double
    ) throws(PDPSolverError) -> PDPStep {
        precondition(
            _pendingJump == nil,
            "The pending PDP jump must be applied before advancing again"
        )
        precondition(
            eventTimeTolerance.isFinite && eventTimeTolerance > .zero,
            "The PDP event-time tolerance must be positive and finite"
        )
        precondition(
            maximumEventIterations > 0,
            "The maximum PDP event-iteration count must be positive"
        )

        let stepStartTime = deterministicSolver.t
        let stepStartHazard = y.cumulativeHazard
        guard stepStartHazard.isFinite && stepStartHazard >= .zero else {
            throw .invalidCumulativeHazard(
                time: stepStartTime,
                value: stepStartHazard
            )
        }
        guard stepStartHazard < _hazardThreshold else {
            throw .eventNotBracketed(
                stepStart: stepStartTime,
                stepEnd: stepStartTime,
                lowerHazard: stepStartHazard,
                upperHazard: stepStartHazard,
                threshold: _hazardThreshold
            )
        }

        let containingStep: ODEStep
        do {
            containingStep = try deterministicSolver.step(
                y: &y,
                upTo: endTime
            )
        } catch {
            throw .deterministic(error)
        }

        let stepEndHazard = y.cumulativeHazard
        guard stepEndHazard.isFinite && stepEndHazard >= .zero else {
            throw .invalidCumulativeHazard(
                time: containingStep.endTime,
                value: stepEndHazard
            )
        }

        let hazardTolerance = Self.hazardComparisonTolerance(
            _hazardThreshold,
            stepStartHazard,
            stepEndHazard
        )
        guard stepEndHazard + hazardTolerance >= stepStartHazard else {
            throw .invalidCumulativeHazard(
                time: containingStep.endTime,
                value: stepEndHazard
            )
        }
        if stepEndHazard < _hazardThreshold {
            return .accepted(containingStep)
        }

        let functional = CumulativeHazardFunctional<State>()
        let lowerHazard = deterministicSolver.interpolateLastStep(
            at: containingStep.startTime,
            linearFunctional: functional
        )
        let upperHazard = deterministicSolver.interpolateLastStep(
            at: containingStep.endTime,
            linearFunctional: functional
        )
        guard lowerHazard.isFinite && lowerHazard >= -hazardTolerance else {
            throw .invalidCumulativeHazard(
                time: containingStep.startTime,
                value: lowerHazard
            )
        }
        guard upperHazard.isFinite && upperHazard >= -hazardTolerance else {
            throw .invalidCumulativeHazard(
                time: containingStep.endTime,
                value: upperHazard
            )
        }

        var lowerTime = containingStep.startTime
        var upperTime = containingStep.endTime
        let lowerValue = lowerHazard - _hazardThreshold
        let upperValue = upperHazard - _hazardThreshold
        let jumpTime: Double

        if abs(lowerValue) <= hazardTolerance {
            jumpTime = lowerTime
        } else if abs(upperValue) <= hazardTolerance {
            jumpTime = upperTime
        } else {
            guard lowerValue < .zero && upperValue > .zero else {
                throw .eventNotBracketed(
                    stepStart: containingStep.startTime,
                    stepEnd: containingStep.endTime,
                    lowerHazard: lowerHazard,
                    upperHazard: upperHazard,
                    threshold: _hazardThreshold
                )
            }

            let timeScale = Swift.max(
                1,
                Swift.max(
                    abs(containingStep.startTime),
                    abs(containingStep.endTime)
                )
            )
            let effectiveTimeTolerance = Swift.max(
                eventTimeTolerance,
                64 * Double.ulpOfOne * timeScale
            )

            var iterations = 0
            while upperTime - lowerTime > effectiveTimeTolerance {
                guard iterations < maximumEventIterations else {
                    throw .eventLocationDidNotConverge(
                        stepStart: containingStep.startTime,
                        stepEnd: containingStep.endTime,
                        iterations: iterations
                    )
                }

                let middleTime = 0.5 * (lowerTime + upperTime)
                if middleTime == lowerTime || middleTime == upperTime {
                    break
                }
                let middleHazard = deterministicSolver.interpolateLastStep(
                    at: middleTime,
                    linearFunctional: functional
                )
                guard
                    middleHazard.isFinite,
                    middleHazard >= -hazardTolerance
                else {
                    throw .invalidCumulativeHazard(
                        time: middleTime,
                        value: middleHazard
                    )
                }

                let middleValue = middleHazard - _hazardThreshold
                iterations &+= 1
                if middleValue == .zero {
                    lowerTime = middleTime
                    upperTime = middleTime
                    break
                }
                if middleValue < .zero {
                    lowerTime = middleTime
                } else {
                    upperTime = middleTime
                }
            }

            guard
                upperTime - lowerTime <= effectiveTimeTolerance
                    || lowerTime.nextUp >= upperTime
            else {
                throw .eventLocationDidNotConverge(
                    stepStart: containingStep.startTime,
                    stepEnd: containingStep.endTime,
                    iterations: iterations
                )
            }
            jumpTime = 0.5 * (lowerTime + upperTime)
        }

        deterministicSolver.interpolateLastStep(
            at: jumpTime,
            into: &y
        )
        y.cumulativeHazard = _hazardThreshold

        let pendingJump = PendingPDPJump(
            time: jumpTime,
            hazardThreshold: _hazardThreshold,
            containingStep: containingStep
        )
        _pendingJump = pendingJump
        return .jumpPending(pendingJump)
    }

    /// Applies the pending jump, resets the cumulative hazard, samples the
    /// next threshold, and restarts the deterministic solver at the jump time.
    @discardableResult
    public mutating func applyPendingJump<
        RNG: RandomNumberGenerator
    >(
        y: inout State,
        using rng: inout RNG
    ) throws(JumpKernel.Failure) -> JumpKernel.Mark {
        guard let pendingJump = _pendingJump else {
            preconditionFailure("No PDP jump is pending")
        }

        let mark = try jumpKernel.sampleAndApplyJump(
            at: pendingJump.time,
            to: &y,
            using: &rng
        )

        y.cumulativeHazard = .zero
        deterministicSolver.restart(at: pendingJump.time)
        _pendingJump = nil
        _jumpCount &+= 1
        _hazardThreshold = Self.sampleHazardThreshold(using: &rng)
        return mark
    }

    /// Invalidates deterministic caches after an external discontinuity
    /// without resetting the current hazard clock.
    public mutating func stateDidChange() {
        precondition(
            _pendingJump == nil,
            "A pending PDP jump must be applied before changing the state"
        )
        deterministicSolver.stateDidChange()
    }

    public func interpolateLastStep(
        at time: Double,
        into result: inout State
    ) {
        preconditionInterpolationTime(time)
        deterministicSolver.interpolateLastStep(at: time, into: &result)
    }

    public func interpolateLastStep<
        Functional: ODEStateLinearFunctional
    >(
        at time: Double,
        linearFunctional: borrowing Functional
    ) -> Double where Functional.State == State {
        preconditionInterpolationTime(time)
        return deterministicSolver.interpolateLastStep(
            at: time,
            linearFunctional: linearFunctional
        )
    }

    public func interpolateLastStep<
        Functional: ODEStateComplexLinearFunctional
    >(
        at time: Double,
        linearFunctional: borrowing Functional
    ) -> Complex<Double> where Functional.State == State {
        preconditionInterpolationTime(time)
        return deterministicSolver.interpolateLastStep(
            at: time,
            linearFunctional: linearFunctional
        )
    }

    @inline(__always)
    private func preconditionInterpolationTime(_ time: Double) {
        if let pendingJump = _pendingJump {
            precondition(
                time <= pendingJump.time,
                "Dense output beyond a pending PDP jump is not part of the trajectory"
            )
        }
    }

    @inline(always)
    @inlinable
    internal static func hazardComparisonTolerance(
        _ values: Double...
    ) -> Double {
        var scale = 0.0
        for value in values {
            scale = Swift.max(scale, abs(value))
        }
        return 64 * Double.ulpOfOne * scale
    }

    @inline(always)
    @inlinable
    internal static func sampleHazardThreshold<
        RNG: RandomNumberGenerator
    >(
        using rng: inout RNG
    ) -> Double {
        let significand = rng.next() >> 11
        let midpointScale = 0x1.0p-53
        let halfSignificandRange: UInt64 = 1 << 52
        let maximumSignificand: UInt64 = (1 << 53) - 1

        let threshold: Double
        if significand < halfSignificandRange {
            let uniform = (Double(significand) + 0.5) * midpointScale
            threshold = -Double.log(uniform)
        } else {
            // Evaluating log(1 - x) through log(onePlus:) preserves thresholds
            // near zero which would otherwise round their uniform variate to 1.
            let distanceFromOne = (
                Double(maximumSignificand - significand) + 0.5
            ) * midpointScale
            threshold = -Double.log(onePlus: -distanceFromOne)
        }
        precondition(
            threshold.isFinite && threshold > .zero,
            "A unit-exponential PDP threshold must be positive and finite"
        )
        return threshold
    }
}
