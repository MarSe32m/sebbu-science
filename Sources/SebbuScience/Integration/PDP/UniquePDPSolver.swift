// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

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
    /// reset by `UniquePDPSolver` after this method succeeds.
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

/*
public struct UniquePDPSolver<
    Deterministic: ~Copyable & ~Escapable & UniqueDenseOutputODESolver,
    JumpKernel: ~Copyable & ~Escapable & PDPJumpKernel
>: ~Copyable, ~Escapable
where
    Deterministic.State: PDPState,
    JumpKernel.State == Deterministic.State
{
    public typealias State = Deterministic.State

    public var eventTimeTolerance: Double
    public var maximumEventIterations: Int

    /// Event time while a jump is pending; otherwise deterministic solver time.
    public var t: Double { get }

    public var lastStep: ODEStep? { get }
    public var hazardThreshold: Double { get }
    public var pendingJump: PendingPDPJump? { get }
    public var jumpCount: Int { get }

    public init<RNG: RandomNumberGenerator>(
        deterministicSolver: consuming Deterministic,
        jumpKernel: consuming JumpKernel,
        eventTimeTolerance: Double = 1e-10,
        maximumEventIterations: Int = 64,
        using rng: inout RNG
    )

    /// Advances by at most one accepted deterministic step.
    ///
    /// If a threshold crossing occurs, `y` is interpolated back to the
    /// pre-jump state and a pending jump is returned.
    public mutating func step(
        y: inout State,
        upTo endTime: Double
    ) throws(PDPSolverError) -> PDPStep

    /// Applies the pending jump, resets the cumulative hazard, samples the
    /// next threshold, and restarts the deterministic solver at the jump time.
    @discardableResult
    public mutating func applyPendingJump<
        RNG: RandomNumberGenerator
    >(
        y: inout State,
        using rng: inout RNG
    ) throws(JumpKernel.Failure) -> JumpKernel.Mark

    /// Invalidates deterministic caches after an external discontinuity
    /// without resetting the current hazard clock.
    public mutating func stateDidChange()

    public func interpolateLastStep(
        at time: Double,
        into result: inout State
    )

    public func interpolateLastStep<
        Functional: ODEStateLinearFunctional
    >(
        at time: Double,
        linearFunctional: borrowing Functional
    ) -> Double where Functional.State == State
}
*/
