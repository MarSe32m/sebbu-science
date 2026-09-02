// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// Allocation-free classical fourth-order Runge--Kutta integration.
///
/// The solver retains the stages of the most recently accepted step and
/// provides a cubic continuous extension. Dense output remains valid until
/// the next call to ``step(y:upTo:)`` or ``restart(at:)``.
/// The state buffers supplied at initialization, and the state passed to
/// ``step(y:upTo:)``, must have distinct writable storage.
@frozen
public struct UniqueRK4Solver<
    State: ~Copyable & FixedStepODESolverState,
    RHS: ~Copyable & ~Escapable & ODERHSFunction
>: ~Copyable, ~Escapable, UniqueFixedStepODESolver where RHS.State == State {
    @usableFromInline
    internal var _t: Double
    public var dt: Double

    @usableFromInline
    internal var _lastStep: ODEStep? = nil
    @usableFromInline
    internal var _acceptedStepCount: Int = 0
    @usableFromInline
    internal var _rhsEvaluationCount: Int = 0

    @inlinable
    public var t: Double { _t }
    @inlinable
    public var lastStep: ODEStep? { _lastStep }
    @inlinable
    public var acceptedStepCount: Int { _acceptedStepCount }
    @inlinable
    public var rhsEvaluationCount: Int { _rhsEvaluationCount }

    @usableFromInline
    internal var rhs: RHS

    @usableFromInline
    internal var k1: State
    @usableFromInline
    internal var k2: State
    @usableFromInline
    internal var k3: State
    @usableFromInline
    internal var k4: State

    /// Stage scratch during a step and the step-start state after acceptance.
    @usableFromInline
    internal var temporary: State

    @_lifetime(copy rhs)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        rhs: consuming RHS,
        k1: consuming State,
        k2: consuming State,
        k3: consuming State,
        k4: consuming State,
        temporary: consuming State,
        owner: Void = ()
    ) {
        precondition(t.isFinite, "Initial time must be finite")
        precondition(dt.isFinite && dt > .zero, "Time-step must be positive and finite")
        self._t = t
        self.dt = dt
        self.rhs = rhs
        self.k1 = k1
        self.k2 = k2
        self.k3 = k3
        self.k4 = k4
        self.temporary = temporary
    }

    /// Advances by one step without passing `endTime`.
    ///
    /// Passing a finite bound permits a shorter final step while leaving the
    /// nominal value of ``dt`` unchanged.
    @inlinable
    public mutating func step(
        y: inout State,
        upTo endTime: Double = .infinity
    ) -> ODEStep {
        precondition(endTime > t, "The step bound must be later than the current time")
        precondition(dt.isFinite && dt > .zero, "Time-step must be positive and finite")

        _lastStep = nil

        let startTime = t
        let stepSize = Swift.min(dt, endTime - startTime)
        precondition(
            stepSize.isFinite && stepSize > .zero && startTime + stepSize > startTime,
            "Time-step is too small to advance time"
        )

        rhs.evaluate(t: startTime, y: y, dy: &k1)
        _rhsEvaluationCount &+= 1

        temporary.assign(y, adding: k1, multipliedBy: 0.5 * stepSize)
        rhs.evaluate(t: startTime + 0.5 * stepSize, y: temporary, dy: &k2)
        _rhsEvaluationCount &+= 1

        temporary.assign(y, adding: k2, multipliedBy: 0.5 * stepSize)
        rhs.evaluate(t: startTime + 0.5 * stepSize, y: temporary, dy: &k3)
        _rhsEvaluationCount &+= 1

        temporary.assign(y, adding: k3, multipliedBy: stepSize)
        rhs.evaluate(t: startTime + stepSize, y: temporary, dy: &k4)
        _rhsEvaluationCount &+= 1

        // Dense output needs the unmodified step-start state. The stage
        // scratch is no longer needed after k4 has been evaluated, so no
        // additional full-sized state buffer is required.
        temporary.assign(y)

        y.add(k1, multiplied: stepSize / 6)
        y.add(k2, multiplied: stepSize / 3)
        y.add(k3, multiplied: stepSize / 3)
        y.add(k4, multiplied: stepSize / 6)

        _t = startTime + stepSize
        _acceptedStepCount &+= 1

        let result = ODEStep(
            startTime: startTime,
            endTime: _t,
            suggestedNextStepSize: dt
        )
        _lastStep = result
        return result
    }

    /// Invalidates dense output and restarts integration at `time`.
    ///
    /// Call this after replacing the current state discontinuously, for
    /// example after applying a quantum jump.
    @inlinable
    public mutating func restart(at time: Double) {
        precondition(time.isFinite, "Restart time must be finite")
        _t = time
        _lastStep = nil
    }

    /// Restores the state at an interior point of the last accepted step and
    /// restarts integration there.
    ///
    /// This is the convenient, cache-safe operation to use after locating an
    /// event with ``locateLastStepCrossing(of:linearFunctional:timeTolerance:)``.
    /// Dense output for the truncated step is invalidated.
    @inlinable
    public mutating func truncateLastStep(
        at time: Double,
        restoring state: inout State
    ) {
        interpolateLastStep(at: time, into: &state)
        restart(at: time)
    }

    /// Invalidates dense output after a discontinuous state change at `t`.
    @inlinable
    public mutating func stateDidChange() {
        _lastStep = nil
    }

    @inlinable
    public mutating func resetStatistics() {
        _acceptedStepCount = 0
        _rhsEvaluationCount = 0
    }

    /// Evaluates the cubic continuous extension of the last accepted step.
    ///
    /// This interpolation is third-order accurate inside the step and agrees
    /// with the fourth-order RK value at the right endpoint.
    @inlinable
    public func interpolateLastStep(at time: Double, into result: inout State) {
        guard let lastStep = _lastStep else {
            preconditionFailure("Dense output is unavailable before an accepted step")
        }
        precondition(
            time >= lastStep.startTime && time <= lastStep.endTime,
            "Dense-output time lies outside the last accepted step"
        )

        let theta = (time - lastStep.startTime) / lastStep.stepSize
        let theta2 = theta * theta
        let theta3 = theta2 * theta

        let b1 = theta - 1.5 * theta2 + (2.0 / 3.0) * theta3
        let b23 = theta2 - (2.0 / 3.0) * theta3
        let b4 = -0.5 * theta2 + (2.0 / 3.0) * theta3

        result.assign(temporary)
        result.add(k1, multiplied: lastStep.stepSize * b1)
        result.add(k2, multiplied: lastStep.stepSize * b23)
        result.add(k3, multiplied: lastStep.stepSize * b23)
        result.add(k4, multiplied: lastStep.stepSize * b4)
    }

    /// Evaluates a linear scalar functional of the dense output without
    /// constructing an interpolated state.
    @inlinable
    public func interpolateLastStep<Functional: ODEStateLinearFunctional>(
        at time: Double,
        linearFunctional: borrowing Functional
    ) -> Double where Functional.State == State {
        guard let lastStep = _lastStep else {
            preconditionFailure("Dense output is unavailable before an accepted step")
        }
        precondition(
            time >= lastStep.startTime && time <= lastStep.endTime,
            "Dense-output time lies outside the last accepted step"
        )

        let theta = (time - lastStep.startTime) / lastStep.stepSize
        let theta2 = theta * theta
        let theta3 = theta2 * theta

        let b1 = theta - 1.5 * theta2 + (2.0 / 3.0) * theta3
        let b23 = theta2 - (2.0 / 3.0) * theta3
        let b4 = -0.5 * theta2 + (2.0 / 3.0) * theta3

        return linearFunctional.evaluate(temporary)
            + lastStep.stepSize * (
                b1 * linearFunctional.evaluate(k1)
                    + b23 * linearFunctional.evaluate(k2)
                    + b23 * linearFunctional.evaluate(k3)
                    + b4 * linearFunctional.evaluate(k4)
            )
    }

    /// Locates a bracketed crossing of a linear functional in the last step.
    ///
    /// Bisection is used because it is robust and each evaluation touches only
    /// the scalar functional of the stored RK stages. Returns `nil` when the
    /// target is not bracketed by the step endpoints.
    @inlinable
    public func locateLastStepCrossing<Functional: ODEStateLinearFunctional>(
        of target: Double,
        linearFunctional: borrowing Functional,
        timeTolerance: Double
    ) -> Double? where Functional.State == State {
        guard let lastStep = _lastStep else { return nil }
        precondition(
            timeTolerance.isFinite && timeTolerance > .zero,
            "Event time tolerance must be positive and finite"
        )

        var lowerTime = lastStep.startTime
        var upperTime = lastStep.endTime
        var lowerValue = interpolateLastStep(
            at: lowerTime,
            linearFunctional: linearFunctional
        ) - target
        let upperValue = interpolateLastStep(
            at: upperTime,
            linearFunctional: linearFunctional
        ) - target

        guard lowerValue.isFinite && upperValue.isFinite else { return nil }
        if lowerValue == 0 { return lowerTime }
        if upperValue == 0 { return upperTime }
        guard (lowerValue < 0) != (upperValue < 0) else { return nil }

        while upperTime - lowerTime > timeTolerance {
            let middleTime = 0.5 * (lowerTime + upperTime)
            if middleTime == lowerTime || middleTime == upperTime { break }
            let middleValue = interpolateLastStep(
                at: middleTime,
                linearFunctional: linearFunctional
            ) - target
            guard middleValue.isFinite else { return nil }
            if middleValue == 0 { return middleTime }

            if (lowerValue < 0) == (middleValue < 0) {
                lowerTime = middleTime
                lowerValue = middleValue
            } else {
                upperTime = middleTime
            }
        }

        return 0.5 * (lowerTime + upperTime)
    }
    
    /// Evaluates a linear complex functional of the dense output without
    /// constructing an interpolated state.
    @inlinable
    public func interpolateLastStep<Functional: ODEStateComplexLinearFunctional>(
        at time: Double,
        linearFunctional: borrowing Functional
    ) -> Complex<Double> where Functional.State == State {
        guard let lastStep = _lastStep else {
            preconditionFailure("Dense output is unavailable before an accepted step")
        }
        precondition(
            time >= lastStep.startTime && time <= lastStep.endTime,
            "Dense-output time lies outside the last accepted step"
        )

        let theta = (time - lastStep.startTime) / lastStep.stepSize
        let theta2 = theta * theta
        let theta3 = theta2 * theta

        let b1 = theta - 1.5 * theta2 + (2.0 / 3.0) * theta3
        let b23 = theta2 - (2.0 / 3.0) * theta3
        let b4 = -0.5 * theta2 + (2.0 / 3.0) * theta3
        var accumulator: Complex<Double> = .zero
        accumulator += b1 * linearFunctional.evaluate(k1)
        accumulator += b23 * linearFunctional.evaluate(k2)
        accumulator += b23 * linearFunctional.evaluate(k3)
        accumulator += b4 * linearFunctional.evaluate(k4)
        return linearFunctional.evaluate(temporary) + lastStep.stepSize * accumulator
    }
}
