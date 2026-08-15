// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// Metadata for one accepted ODE step.
@frozen
public struct ODEStep: Sendable, Equatable {
    public let startTime: Double
    public let endTime: Double
    public let suggestedNextStepSize: Double

    /// The dimensionless embedded error norm for an adaptive step.
    ///
    /// Fixed-step methods set this to `nil`. Adaptive methods accept a step
    /// when this value is finite and no larger than one.
    public let errorNorm: Double?

    /// Number of rejected trial steps preceding this accepted step.
    public let rejectedStepCount: Int

    @inlinable
    public var stepSize: Double { endTime - startTime }

    @inlinable
    public init(
        startTime: Double,
        endTime: Double,
        suggestedNextStepSize: Double,
        errorNorm: Double? = nil,
        rejectedStepCount: Int = 0
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.suggestedNextStepSize = suggestedNextStepSize
        self.errorNorm = errorNorm
        self.rejectedStepCount = rejectedStepCount
    }
}

/// Failures which prevent an adaptive solver from producing an accepted step.
@frozen
public enum ODESolverError: Error, Equatable, Sendable {
    case stepSizeUnderflow(time: Double, stepSize: Double)
    case maximumStepAttemptsExceeded(time: Double, attempts: Int)
}

public protocol FixedStepODESolverState: ~Copyable {
    /// Replaces this value without changing its allocation or storage identity.
    mutating func assign(_ other: borrowing Self)

    mutating func add(_ other: borrowing Self, multiplied: Double)
    mutating func assign(
        _ base: borrowing Self,
        adding direction: borrowing Self,
        multipliedBy coefficient: Double
    )
}

public protocol AdaptiveStepODESolverState: ~Copyable, FixedStepODESolverState {
    /// A nonnegative norm used to scale the default adaptive error estimate.
    var norm: Double { get }

    /// Returns a nonnegative norm of `self - other`.
    ///
    /// This deliberately does not use the name `distance(to:)`: types such as
    /// `Double` already provide a signed `Strideable.distance(to:)`, which is
    /// not a valid local-error norm.
    func errorNorm(to other: borrowing Self) -> Double

    /// Returns a dimensionless local-error estimate. The step is accepted
    /// when the result is finite and no larger than one.
    ///
    /// The default implementation uses one global scale. States whose
    /// components have substantially different units or magnitudes should
    /// override this with a component-wise weighted RMS or maximum norm.
    /// Bookkeeping components such as an accumulated event hazard can also be
    /// given their own scale or excluded from physical-state error control. An
    /// override may fuse the scale and difference calculations into one pass.
    func normalizedError(
        comparedTo lowerOrderEstimate: borrowing Self,
        relativeTo stepStart: borrowing Self,
        absoluteTolerance: Double,
        relativeTolerance: Double
    ) -> Double
}

public extension AdaptiveStepODESolverState where Self: ~Copyable {
    @inlinable
    func normalizedError(
        comparedTo lowerOrderEstimate: borrowing Self,
        relativeTo stepStart: borrowing Self,
        absoluteTolerance: Double,
        relativeTolerance: Double
    ) -> Double {
        let scale = absoluteTolerance
            + relativeTolerance * Swift.max(norm, stepStart.norm)
        let error = errorNorm(to: lowerOrderEstimate)
        guard
            scale.isFinite,
            error.isFinite,
            scale >= .zero,
            error >= .zero
        else {
            return .infinity
        }
        if scale > .zero { return error / scale }
        return error == .zero ? .zero : .infinity
    }
}

/// A linear scalar functional of an ODE state.
///
/// Dense Runge--Kutta output is a linear combination of the step-start state
/// and stage derivatives. A conforming functional can therefore be evaluated
/// directly on those stored values without constructing a full interpolated
/// state. Component extraction, such as reading an accumulated hazard, is a
/// typical use. Nonlinear event functions must instead be evaluated after
/// interpolating the complete state.
public protocol ODEStateLinearFunctional: ~Copyable {
    associatedtype State: ~Copyable

    func evaluate(_ state: borrowing State) -> Double
}

public protocol ODERHSFunction: ~Copyable, ~Escapable {
    associatedtype State: ~Copyable

    /// Replaces `dy` with the derivative at `(t, y)`.
    ///
    /// Implementations must overwrite every relevant component of `dy`; the
    /// solver may pass a buffer containing a derivative from an earlier stage.
    mutating func evaluate(
        t: Double,
        y: borrowing State,
        dy: inout State
    )
}
