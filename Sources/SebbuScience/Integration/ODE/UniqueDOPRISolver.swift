// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

/// Allocation-free Dormand--Prince 5(4) integration with quartic dense output.
///
/// The fifth-order solution is advanced while the embedded fourth-order
/// solution controls the step size. The FSAL derivative is reused across
/// accepted steps and the initial derivative is retained across rejected
/// trials. Dense output remains valid until the next call to
/// ``step(y:upTo:)`` or until the solver is restarted.
/// The state buffers supplied at initialization, and the state passed to
/// ``step(y:upTo:)``, must have distinct writable storage.
@frozen
public struct UniqueDOPRISolver<
    State: ~Copyable & AdaptiveStepODESolverState,
    RHS: ~Copyable & ~Escapable & ODERHSFunction
>: ~Copyable, ~Escapable, UniqueAdaptiveStepODESolver where RHS.State == State {
    @usableFromInline
    internal var _t: Double

    /// Proposed size of the next step.
    public var dt: Double
    public var minimumStep: Double
    public var maxStep: Double

    public var absoluteTolerance: Double
    public var relativeTolerance: Double

    public var safetyFactor: Double
    public var minimumScaleFactor: Double
    public var maximumScaleFactor: Double
    public var maximumStepAttempts: Int

    @usableFromInline
    internal var _lastStep: ODEStep? = nil
    @usableFromInline
    internal var _acceptedStepCount: Int = 0
    @usableFromInline
    internal var _rejectedStepCount: Int = 0
    @usableFromInline
    internal var _rhsEvaluationCount: Int = 0
    @usableFromInline
    internal var _hasCachedFirstDerivative: Bool = false

    @inlinable
    public var t: Double { _t }
    @inlinable
    public var lastStep: ODEStep? { _lastStep }
    @inlinable
    public var acceptedStepCount: Int { _acceptedStepCount }
    @inlinable
    public var rejectedStepCount: Int { _rejectedStepCount }
    @inlinable
    public var rhsEvaluationCount: Int { _rhsEvaluationCount }
    @inlinable
    public var hasCachedFirstDerivative: Bool { _hasCachedFirstDerivative }

    @usableFromInline
    internal var rhs: RHS

    /// Embedded fourth-order estimate during a trial and the step-start state
    /// after an accepted step.
    @usableFromInline
    internal var y4: State

    @usableFromInline
    internal var k1: State
    @usableFromInline
    internal var k2: State
    @usableFromInline
    internal var k3: State
    @usableFromInline
    internal var k4: State
    @usableFromInline
    internal var k5: State
    @usableFromInline
    internal var k6: State
    @usableFromInline
    internal var k7: State

    /// Fifth-order trial solution and general stage scratch.
    @usableFromInline
    internal var temporary: State

    @_lifetime(copy rhs)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        maxStep: Double,
        rhs: consuming RHS,
        y4: consuming State,
        k1: consuming State,
        k2: consuming State,
        k3: consuming State,
        k4: consuming State,
        k5: consuming State,
        k6: consuming State,
        k7: consuming State,
        temporary: consuming State,
        absoluteTolerance: Double = 1e-6,
        relativeTolerance: Double = 1e-3,
        minimumStep: Double = 0,
        safetyFactor: Double = 0.9,
        minimumScaleFactor: Double = 0.2,
        maximumScaleFactor: Double = 10,
        maximumStepAttempts: Int = 100
    ) {
        precondition(t.isFinite, "Initial time must be finite")
        precondition(dt.isFinite && dt > .zero, "Initial time-step must be positive and finite")
        precondition(maxStep > .zero, "Maximum time-step must be positive")
        precondition(minimumStep.isFinite && minimumStep >= .zero, "Minimum time-step must be finite and nonnegative")
        precondition(minimumStep <= maxStep, "Minimum time-step cannot exceed the maximum time-step")
        precondition(absoluteTolerance.isFinite && absoluteTolerance >= .zero, "Absolute tolerance must be finite and nonnegative")
        precondition(relativeTolerance.isFinite && relativeTolerance >= .zero, "Relative tolerance must be finite and nonnegative")
        precondition(absoluteTolerance > .zero || relativeTolerance > .zero, "At least one tolerance must be positive")
        precondition(safetyFactor.isFinite && safetyFactor > .zero && safetyFactor <= 1, "Safety factor must lie in (0, 1]")
        precondition(minimumScaleFactor.isFinite && minimumScaleFactor > .zero && minimumScaleFactor <= 1, "Minimum scale factor must lie in (0, 1]")
        precondition(maximumScaleFactor.isFinite && maximumScaleFactor >= 1, "Maximum scale factor must be at least one")
        precondition(maximumStepAttempts > 0, "Maximum step attempts must be positive")

        self._t = t
        self.dt = Swift.max(minimumStep, Swift.min(dt, maxStep))
        self.minimumStep = minimumStep
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.safetyFactor = safetyFactor
        self.minimumScaleFactor = minimumScaleFactor
        self.maximumScaleFactor = maximumScaleFactor
        self.maximumStepAttempts = maximumStepAttempts
        self.rhs = rhs
        self.y4 = y4
        self.k1 = k1
        self.k2 = k2
        self.k3 = k3
        self.k4 = k4
        self.k5 = k5
        self.k6 = k6
        self.k7 = k7
        self.temporary = temporary
    }

    /// Advances by one accepted adaptive step without passing `endTime`.
    ///
    /// The external state is unchanged while trial steps are rejected.
    @inlinable
    public mutating func step(
        y: inout State,
        upTo endTime: Double = .infinity
    ) throws(ODESolverError) -> ODEStep {
        if endTime <= t {
            throw ODESolverError.requestedEndTimeReached(endTime: endTime, solverTime: t)
        }
        precondition(endTime > t, "The step bound must be later than the current time")
        precondition(dt.isFinite && dt > .zero, "Proposed time-step must be positive and finite")
        precondition(maxStep > .zero, "Maximum time-step must be positive")
        precondition(minimumStep.isFinite && minimumStep >= .zero && minimumStep <= maxStep, "Minimum time-step must be finite, nonnegative, and no larger than the maximum")
        precondition(absoluteTolerance.isFinite && absoluteTolerance >= .zero, "Absolute tolerance must be finite and nonnegative")
        precondition(relativeTolerance.isFinite && relativeTolerance >= .zero, "Relative tolerance must be finite and nonnegative")
        precondition(absoluteTolerance > .zero || relativeTolerance > .zero, "At least one tolerance must be positive")
        precondition(safetyFactor.isFinite && safetyFactor > .zero && safetyFactor <= 1, "Safety factor must lie in (0, 1]")
        precondition(minimumScaleFactor.isFinite && minimumScaleFactor > .zero && minimumScaleFactor <= 1, "Minimum scale factor must lie in (0, 1]")
        precondition(maximumScaleFactor.isFinite && maximumScaleFactor >= 1, "Maximum scale factor must be at least one")
        precondition(maximumStepAttempts > 0, "Maximum step attempts must be positive")

        _lastStep = nil

        let startTime = t
        let remaining = endTime - startTime
        let representableMinimum = 10 * (startTime.nextUp - startTime)
        let effectiveMinimum = Swift.max(minimumStep, representableMinimum)

        var trialStep = Swift.min(Swift.min(dt, maxStep), remaining)
        guard trialStep > .zero && startTime + trialStep > startTime else {
            throw ODESolverError.stepSizeUnderflow(
                time: startTime,
                stepSize: trialStep
            )
        }
        if trialStep < effectiveMinimum && trialStep < remaining {
            dt = trialStep
            throw ODESolverError.stepSizeUnderflow(
                time: startTime,
                stepSize: trialStep
            )
        }

        // Keep k1 from the previous accepted step until a new step begins.
        // Swapping the internal stage buffers preserves dense output between
        // calls and avoids copying an entire state merely to reuse FSAL.
        if _hasCachedFirstDerivative {
            Swift.swap(&k1, &k7)
        } else {
            rhs.evaluate(t: startTime, y: y, dy: &k1)
            _rhsEvaluationCount &+= 1
        }
        _hasCachedFirstDerivative = false

        var attempts = 0
        var rejectionsThisStep = 0

        while true {
            if trialStep < effectiveMinimum && trialStep < remaining {
                dt = trialStep
                throw ODESolverError.stepSizeUnderflow(
                    time: startTime,
                    stepSize: trialStep
                )
            }
            guard startTime + trialStep > startTime else {
                dt = trialStep
                throw ODESolverError.stepSizeUnderflow(
                    time: startTime,
                    stepSize: trialStep
                )
            }

            attempts &+= 1
            guard attempts <= maximumStepAttempts else {
                dt = trialStep
                throw ODESolverError.maximumStepAttemptsExceeded(
                    time: startTime,
                    attempts: attempts - 1
                )
            }

            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(1.0 / 5.0, trialStep)
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(1.0 / 5.0, trialStep, startTime),
                y: temporary,
                dy: &k2
            )
            _rhsEvaluationCount &+= 1

            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(3.0 / 40.0, trialStep)
            )
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, trialStep))
            rhs.evaluate(
                t: Relaxed.multiplyAdd(3.0 / 10.0, trialStep, startTime),
                y: temporary,
                dy: &k3
            )
            _rhsEvaluationCount &+= 1

            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(44.0 / 45.0, trialStep)
            )
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, trialStep))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, trialStep))
            rhs.evaluate(
                t: Relaxed.multiplyAdd(4.0 / 5.0, trialStep, startTime),
                y: temporary,
                dy: &k4
            )
            _rhsEvaluationCount &+= 1

            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(19372.0 / 6561.0, trialStep)
            )
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, trialStep))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, trialStep))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, trialStep))
            rhs.evaluate(
                t: Relaxed.multiplyAdd(8.0 / 9.0, trialStep, startTime),
                y: temporary,
                dy: &k5
            )
            _rhsEvaluationCount &+= 1

            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(9017.0 / 3168.0, trialStep)
            )
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, trialStep))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, trialStep))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, trialStep))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, trialStep))
            rhs.evaluate(
                t: Relaxed.sum(trialStep, startTime),
                y: temporary,
                dy: &k6
            )
            _rhsEvaluationCount &+= 1

            // Fifth-order solution. Keep this in `temporary`; evaluating the
            // right-hand side for k7 borrows it and does not require the same
            // large linear combination to be constructed a second time.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(35.0 / 384.0, trialStep)
            )
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, trialStep))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, trialStep))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, trialStep))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, trialStep))
            rhs.evaluate(
                t: Relaxed.sum(trialStep, startTime),
                y: temporary,
                dy: &k7
            )
            _rhsEvaluationCount &+= 1

            // Embedded fourth-order estimate.
            y4.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(5179.0 / 57600.0, trialStep)
            )
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, trialStep))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, trialStep))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, trialStep))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, trialStep))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, trialStep))

            let errorNorm = temporary.normalizedError(
                comparedTo: y4,
                relativeTo: y,
                absoluteTolerance: absoluteTolerance,
                relativeTolerance: relativeTolerance
            )

            if errorNorm.isFinite && errorNorm >= .zero && errorNorm <= 1 {
                var scale = maximumScaleFactor
                if errorNorm > .zero {
                    scale = safetyFactor * Double.pow(errorNorm, -1.0 / 5.0)
                    scale = Swift.max(
                        minimumScaleFactor,
                        Swift.min(scale, maximumScaleFactor)
                    )
                }
                if rejectionsThisStep > 0 {
                    scale = Swift.min(1.0, scale)
                }

                // y still contains the step-start state. Reuse y4 to retain it
                // after its embedded estimate has served the error test.
                y4.assign(y)
                y.assign(temporary)

                _t = startTime + trialStep
                dt = Swift.max(
                    minimumStep,
                    Swift.min(maxStep, trialStep * scale)
                )
                _hasCachedFirstDerivative = true
                _acceptedStepCount &+= 1

                let result = ODEStep(
                    startTime: startTime,
                    endTime: _t,
                    suggestedNextStepSize: dt,
                    errorNorm: errorNorm,
                    rejectedStepCount: rejectionsThisStep
                )
                _lastStep = result
                return result
            }

            _rejectedStepCount &+= 1
            rejectionsThisStep &+= 1

            let scale: Double
            if errorNorm.isFinite && errorNorm > .zero {
                scale = Swift.max(
                    minimumScaleFactor,
                    Swift.min(1.0, safetyFactor * Double.pow(errorNorm, -1.0 / 5.0))
                )
            } else {
                // NaN and infinity must never be accepted implicitly.
                scale = minimumScaleFactor
            }

            trialStep = Swift.min(remaining, trialStep * scale)
            dt = trialStep
            // k1 remains valid because neither t nor y changed.
        }
    }

    @inlinable
    @inline(always)
    public mutating func restart(at time: Double) {
        restart(at: time, proposedStepSize: nil)
    }
    
    /// Restarts the solver after a discontinuity or rollback.
    @inlinable
    public mutating func restart(
        at time: Double,
        proposedStepSize: Double?
    ) {
        precondition(time.isFinite, "Restart time must be finite")
        if let proposedStepSize {
            precondition(
                proposedStepSize.isFinite && proposedStepSize > .zero,
                "Proposed time-step must be positive and finite"
            )
            dt = Swift.max(
                minimumStep,
                Swift.min(proposedStepSize, maxStep)
            )
        }
        _t = time
        _hasCachedFirstDerivative = false
        _lastStep = nil
    }

    /// Restores the state at an interior point of the last accepted step and
    /// restarts integration there.
    ///
    /// This is the convenient, cache-safe operation to use after locating an
    /// event with ``locateLastStepCrossing(of:linearFunctional:timeTolerance:)``.
    /// Dense output and the FSAL derivative for the truncated step are
    /// invalidated.
    @inlinable
    public mutating func truncateLastStep(
        at time: Double,
        restoring state: inout State,
        proposedStepSize: Double? = nil
    ) {
        interpolateLastStep(at: time, into: &state)
        restart(at: time, proposedStepSize: proposedStepSize)
    }

    /// Invalidates the FSAL derivative and dense output after an in-place
    /// discontinuous modification of the state or right-hand side at the
    /// current time.
    @inlinable
    public mutating func stateDidChange() {
        _hasCachedFirstDerivative = false
        _lastStep = nil
    }

    @inlinable
    public mutating func resetStatistics() {
        _acceptedStepCount = 0
        _rejectedStepCount = 0
        _rhsEvaluationCount = 0
    }

    @inlinable
    @inline(always)
    internal static func denseOutputWeights(
        at theta: Double
    ) -> (b1: Double, b3: Double, b4: Double, b5: Double, b6: Double, b7: Double) {
        let theta2 = theta * theta
        let theta3 = theta2 * theta
        let theta4 = theta3 * theta

        let b1 = theta
            - (8048581381.0 / 2820520608.0) * theta2
            + (8663915743.0 / 2820520608.0) * theta3
            - (12715105075.0 / 11282082432.0) * theta4
        let b3 = (131558114200.0 / 32700410799.0) * theta2
            - (68118460800.0 / 10900136933.0) * theta3
            + (87487479700.0 / 32700410799.0) * theta4
        let b4 = -(1754552775.0 / 470086768.0) * theta2
            + (14199869525.0 / 1410260304.0) * theta3
            - (10690763975.0 / 1880347072.0) * theta4
        let b5 = (127303824393.0 / 49829197408.0) * theta2
            - (318862633887.0 / 49829197408.0) * theta3
            + (701980252875.0 / 199316789632.0) * theta4
        let b6 = -(282668133.0 / 205662961.0) * theta2
            + (2019193451.0 / 616988883.0) * theta3
            - (1453857185.0 / 822651844.0) * theta4
        let b7 = (40617522.0 / 29380423.0) * theta2
            - (110615467.0 / 29380423.0) * theta3
            + (69997945.0 / 29380423.0) * theta4
        return (b1, b3, b4, b5, b6, b7)
    }

    /// Evaluates the Shampine quartic continuous extension of the last step.
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
        let weights = Self.denseOutputWeights(at: theta)

        result.assign(y4)
        result.add(k1, multiplied: lastStep.stepSize * weights.b1)
        result.add(k3, multiplied: lastStep.stepSize * weights.b3)
        result.add(k4, multiplied: lastStep.stepSize * weights.b4)
        result.add(k5, multiplied: lastStep.stepSize * weights.b5)
        result.add(k6, multiplied: lastStep.stepSize * weights.b6)
        result.add(k7, multiplied: lastStep.stepSize * weights.b7)
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
        let weights = Self.denseOutputWeights(at: theta)

        return linearFunctional.evaluate(y4)
            + lastStep.stepSize * (
                weights.b1 * linearFunctional.evaluate(k1)
                    + weights.b3 * linearFunctional.evaluate(k3)
                    + weights.b4 * linearFunctional.evaluate(k4)
                    + weights.b5 * linearFunctional.evaluate(k5)
                    + weights.b6 * linearFunctional.evaluate(k6)
                    + weights.b7 * linearFunctional.evaluate(k7)
            )
    }

    /// Locates a bracketed crossing of a linear functional in the last step.
    ///
    /// This is intended for accumulated-hazard and other component events. A
    /// nonlinear event function should be evaluated from full dense states.
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
        let weights = Self.denseOutputWeights(at: theta)
        
        var accumulator: Complex<Double> = .zero
        accumulator += weights.b1 * linearFunctional.evaluate(k1)
        accumulator += weights.b3 * linearFunctional.evaluate(k3)
        accumulator += weights.b4 * linearFunctional.evaluate(k4)
        accumulator += weights.b5 * linearFunctional.evaluate(k5)
        accumulator += weights.b6 * linearFunctional.evaluate(k6)
        accumulator += weights.b7 * linearFunctional.evaluate(k7)
        return linearFunctional.evaluate(y4) + lastStep.stepSize * accumulator
    }
}
