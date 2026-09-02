// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

/// Allocation-free Verner 7(6) integration with sixth-order dense output.
///
/// The seventh-order solution is advanced while the embedded sixth-order
/// solution controls the step size. Three accepted-step stages construct
/// Verner's sixth-order continuous extension; its endpoint derivative is
/// reused as the first stage of the next step. Rejected trials retain the
/// initial derivative and leave the external state unchanged.
///
/// Dense output remains valid until the next call to ``step(y:upTo:)`` or
/// until the solver is restarted. The state buffers supplied at
/// initialization, and the state passed to ``step(y:upTo:)``, must have
/// distinct writable storage.
///
/// The Runge--Kutta pair and interpolant coefficients are due to James H.
/// Verner and are copyrighted by him. They are used here with the
/// acknowledgment required by their source. This implementation uses set
/// `RKV76.IIa.Efficient.000003389335684.240711`, published as *An even more
/// “efficient” Runge--Kutta (7)6 Pair with Interpolants* at
/// [Jim Verner's Refuge for Runge-Kutta Pairs](https://www.sfu.ca/~jverner/).
/// See also J. H. Verner, *Numerically optimal Runge--Kutta pairs with
/// interpolants*, Numerical Algorithms 53 (2010), 383--396.
@frozen
public struct UniqueVerner76Solver<
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

    /// Embedded sixth-order estimate during a trial, interpolation-stage
    /// scratch after acceptance, and the step-start state for dense output.
    @usableFromInline
    internal var y6: State

    @usableFromInline
    internal var k1: State

    /// Stage 2 during a trial and interpolation stage 11 after acceptance.
    @usableFromInline
    internal var k2OrK11: State

    /// Stage 3 during a trial and interpolation stage 12 after acceptance.
    @usableFromInline
    internal var k3OrK12: State

    @usableFromInline
    internal var k4: State
    @usableFromInline
    internal var k5: State
    @usableFromInline
    internal var k6: State
    @usableFromInline
    internal var k7: State
    @usableFromInline
    internal var k8: State
    @usableFromInline
    internal var k9: State

    /// Stage 10 during a trial and interpolation stage 13 after acceptance.
    @usableFromInline
    internal var k10OrK13: State

    /// Seventh-order trial solution, general stage scratch, and accepted
    /// step-end state retained for exact endpoint interpolation.
    @usableFromInline
    internal var temporary: State

    @_lifetime(copy rhs)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        maxStep: Double,
        rhs: consuming RHS,
        y6: consuming State,
        k1: consuming State,
        k2: consuming State,
        k3: consuming State,
        k4: consuming State,
        k5: consuming State,
        k6: consuming State,
        k7: consuming State,
        k8: consuming State,
        k9: consuming State,
        k10: consuming State,
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
        self.y6 = y6
        self.k1 = k1
        self.k2OrK11 = k2
        self.k3OrK12 = k3
        self.k4 = k4
        self.k5 = k5
        self.k6 = k6
        self.k7 = k7
        self.k8 = k8
        self.k9 = k9
        self.k10OrK13 = k10
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

        // After an accepted step, k2OrK11 holds f(t, y). Dense output is no
        // longer required once a new step begins, so swap it into k1 without
        // copying a potentially large state.
        if _hasCachedFirstDerivative {
            Swift.swap(&k1, &k2OrK11)
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

            // Stage 2.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(0.069, trialStep)
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(0.069, trialStep, startTime),
                y: temporary,
                dy: &k2OrK11
            )
            _rhsEvaluationCount &+= 1

            // Stage 3.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    0.01710144927536231884057971014492753623188,
                    trialStep
                )
            )
            temporary.add(
                k2OrK11,
                multiplied: Relaxed.product(
                    0.1008985507246376811594202898550724637681,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(0.118, trialStep, startTime),
                y: temporary,
                dy: &k3OrK12
            )
            _rhsEvaluationCount &+= 1

            // Stage 4.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(0.04425, trialStep)
            )
            temporary.add(k3OrK12, multiplied: Relaxed.product(0.13275, trialStep))
            rhs.evaluate(
                t: Relaxed.multiplyAdd(0.177, trialStep, startTime),
                y: temporary,
                dy: &k4
            )
            _rhsEvaluationCount &+= 1

            // Stage 5.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    0.7353445130709566216604424016087331226659,
                    trialStep
                )
            )
            temporary.add(
                k3OrK12,
                multiplied: Relaxed.product(
                    -2.830160657856937661591496696351623096811,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    2.595816144785981039931054294742889974145,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(0.501, trialStep, startTime),
                y: temporary,
                dy: &k5
            )
            _rhsEvaluationCount &+= 1

            // Stage 6.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    -12.21580485360407974005910916471598682362,
                    trialStep
                )
            )
            temporary.add(
                k3OrK12,
                multiplied: Relaxed.product(
                    48.82665485823736062335980699373053427134,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    -38.55615592319928364666616600329792491404,
                    trialStep
                )
            )
            temporary.add(
                k5,
                multiplied: Relaxed.product(
                    2.719085830096535863737044703969626233400,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(
                    0.7737799115305331003715765296862487670813,
                    trialStep,
                    startTime
                ),
                y: temporary,
                dy: &k6
            )
            _rhsEvaluationCount &+= 1

            // Stage 7.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    108.8614188704176574066699618897203578466,
                    trialStep
                )
            )
            temporary.add(
                k3OrK12,
                multiplied: Relaxed.product(
                    -432.4521181775777896358931629332707752654,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    343.9115281800118289547200158889409233641,
                    trialStep
                )
            )
            temporary.add(
                k5,
                multiplied: Relaxed.product(
                    -20.55041135925273709189369488701721016265,
                    trialStep
                )
            )
            temporary.add(
                k6,
                multiplied: Relaxed.product(
                    1.223582486401040366396880041626704217305,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(0.994, trialStep, startTime),
                y: temporary,
                dy: &k7
            )
            _rhsEvaluationCount &+= 1

            // Stage 8.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    113.4755131883738522204615568160304033854,
                    trialStep
                )
            )
            temporary.add(
                k3OrK12,
                multiplied: Relaxed.product(
                    -450.8122021555997002820400438087344405365,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    358.5132765190089889943579090008312808216,
                    trialStep
                )
            )
            temporary.add(
                k5,
                multiplied: Relaxed.product(
                    -21.45046667648445540174055882443151176550,
                    trialStep
                )
            )
            temporary.add(
                k6,
                multiplied: Relaxed.product(
                    1.274053318605952891766776667539031508649,
                    trialStep
                )
            )
            temporary.add(
                k7,
                multiplied: Relaxed.product(
                    -0.002174193904638422805639851234763413667602,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.multiplyAdd(0.998, trialStep, startTime),
                y: temporary,
                dy: &k8
            )
            _rhsEvaluationCount &+= 1

            // Stage 9.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    115.6996223324232534824963925993127275021,
                    trialStep
                )
            )
            temporary.add(
                k3OrK12,
                multiplied: Relaxed.product(
                    -459.6635446100248030478961869239726305957,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    365.5534717131745930309149378867953890507,
                    trialStep
                )
            )
            temporary.add(
                k5,
                multiplied: Relaxed.product(
                    -21.88511586349784824146225495848432937529,
                    trialStep
                )
            )
            temporary.add(
                k6,
                multiplied: Relaxed.product(
                    1.298718109698721459187976480852777474315,
                    trialStep
                )
            )
            temporary.add(
                k7,
                multiplied: Relaxed.product(
                    -0.00005318700918481883515898878747322241917739,
                    trialStep
                )
            )
            temporary.add(
                k8,
                multiplied: Relaxed.product(
                    -0.003098494764731864405706095716460833640254,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.sum(trialStep, startTime),
                y: temporary,
                dy: &k9
            )
            _rhsEvaluationCount &+= 1

            // Stage 10 is used only by the embedded sixth-order estimate.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    124.1543935612464600014576130437603883332,
                    trialStep
                )
            )
            temporary.add(
                k3OrK12,
                multiplied: Relaxed.product(
                    -493.2318713314597046194663569971348299332,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    392.2086219315800762927575562172365337929,
                    trialStep
                )
            )
            temporary.add(
                k5,
                multiplied: Relaxed.product(
                    -23.48641564290853341361596821616234280392,
                    trialStep
                )
            )
            temporary.add(
                k6,
                multiplied: Relaxed.product(
                    1.362322948908907509911149920532561575254,
                    trialStep
                )
            )
            temporary.add(
                k7,
                multiplied: Relaxed.product(
                    -0.007051467367205771043993968232310964220061,
                    trialStep
                )
            )
            rhs.evaluate(
                t: Relaxed.sum(trialStep, startTime),
                y: temporary,
                dy: &k10OrK13
            )
            _rhsEvaluationCount &+= 1

            // Seventh-order propagating solution.
            temporary.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    0.05163520172057869163393251056217968836723,
                    trialStep
                )
            )
            temporary.add(
                k4,
                multiplied: Relaxed.product(
                    0.2767172535461648728769641534539952501983,
                    trialStep
                )
            )
            temporary.add(
                k5,
                multiplied: Relaxed.product(
                    0.3374175285287150670818592701488271741753,
                    trialStep
                )
            )
            temporary.add(
                k6,
                multiplied: Relaxed.product(
                    0.1884488267810967803491085059046161195540,
                    trialStep
                )
            )
            temporary.add(
                k7,
                multiplied: Relaxed.product(
                    24.54134121634868026791753618430192161716,
                    trialStep
                )
            )
            temporary.add(
                k8,
                multiplied: Relaxed.product(
                    -68.81190284469011946382716084194838780382,
                    trialStep
                )
            )
            temporary.add(
                k9,
                multiplied: Relaxed.product(
                    44.41634281776488378396776021757684795437,
                    trialStep
                )
            )

            // Embedded sixth-order estimate.
            y6.assign(
                y,
                adding: k1,
                multipliedBy: Relaxed.product(
                    0.05089676583692947576073561095512200263213,
                    trialStep
                )
            )
            y6.add(
                k4,
                multiplied: Relaxed.product(
                    0.2793777374763233901369432426263934138476,
                    trialStep
                )
            )
            y6.add(
                k5,
                multiplied: Relaxed.product(
                    0.3281330142746535239936396881369403928344,
                    trialStep
                )
            )
            y6.add(
                k6,
                multiplied: Relaxed.product(
                    0.2241721218186151033581794837350130009230,
                    trialStep
                )
            )
            y6.add(
                k7,
                multiplied: Relaxed.product(
                    0.7874574778015076584344903106189416715189,
                    trialStep
                )
            )
            y6.add(
                k10OrK13,
                multiplied: Relaxed.product(
                    -0.6700371172080291516839883360724104817561,
                    trialStep
                )
            )

            let errorNorm = temporary.normalizedError(
                comparedTo: y6,
                relativeTo: y,
                absoluteTolerance: absoluteTolerance,
                relativeTolerance: relativeTolerance
            )

            if errorNorm.isFinite && errorNorm >= .zero && errorNorm <= 1 {
                var scale = maximumScaleFactor
                if errorNorm > .zero {
                    scale = safetyFactor * Double.pow(errorNorm, -1.0 / 7.0)
                    scale = Swift.max(
                        minimumScaleFactor,
                        Swift.min(scale, maximumScaleFactor)
                    )
                }
                if rejectionsThisStep > 0 {
                    scale = Swift.min(1.0, scale)
                }

                // Interpolation stage 11 is the endpoint derivative and is
                // also the cached first derivative for the following step.
                rhs.evaluate(
                    t: Relaxed.sum(trialStep, startTime),
                    y: temporary,
                    dy: &k2OrK11
                )
                _rhsEvaluationCount &+= 1

                // Interpolation stage 12. y6 is no longer needed as the
                // embedded estimate and can be reused for the stage state.
                y6.assign(
                    y,
                    adding: k1,
                    multipliedBy: Relaxed.product(
                        0.05595947882055415742583956081637901452552,
                        trialStep
                    )
                )
                y6.add(
                    k4,
                    multiplied: Relaxed.product(
                        0.2481262830322509327139022005325437452965,
                        trialStep
                    )
                )
                y6.add(
                    k5,
                    multiplied: Relaxed.product(
                        0.02103052990591148013587987543073879445482,
                        trialStep
                    )
                )
                y6.add(
                    k6,
                    multiplied: Relaxed.product(
                        -0.01086652415454008449407261022406674546105,
                        trialStep
                    )
                )
                y6.add(
                    k7,
                    multiplied: Relaxed.product(
                        5.710311335454033086222886871347348898943,
                        trialStep
                    )
                )
                y6.add(
                    k8,
                    multiplied: Relaxed.product(
                        -16.59749151785386284126327966975768025349,
                        trialStep
                    )
                )
                y6.add(
                    k9,
                    multiplied: Relaxed.product(
                        10.90440686603898964031684903021468235733,
                        trialStep
                    )
                )
                y6.add(
                    k2OrK11,
                    multiplied: Relaxed.product(
                        -0.01078447695690422224268752339872593914865,
                        trialStep
                    )
                )
                rhs.evaluate(
                    t: Relaxed.multiplyAdd(
                        0.3206919742864321488153177349612198724445,
                        trialStep,
                        startTime
                    ),
                    y: y6,
                    dy: &k3OrK12
                )
                _rhsEvaluationCount &+= 1

                // Interpolation stage 13.
                y6.assign(
                    y,
                    adding: k1,
                    multipliedBy: Relaxed.product(
                        0.05365176199729764566758655497507692759771,
                        trialStep
                    )
                )
                y6.add(
                    k4,
                    multiplied: Relaxed.product(
                        0.09828513377552059696782507697799478414148,
                        trialStep
                    )
                )
                y6.add(
                    k5,
                    multiplied: Relaxed.product(
                        0.02236190536978546688920574502539925812364,
                        trialStep
                    )
                )
                y6.add(
                    k6,
                    multiplied: Relaxed.product(
                        -0.003196168594283279436559562148268690316884,
                        trialStep
                    )
                )
                y6.add(
                    k7,
                    multiplied: Relaxed.product(
                        0.5451003257307239985591851329642383758416,
                        trialStep
                    )
                )
                y6.add(
                    k8,
                    multiplied: Relaxed.product(
                        -1.638732002009432676897859879241483267007,
                        trialStep
                    )
                )
                y6.add(
                    k9,
                    multiplied: Relaxed.product(
                        1.093896392979466849054156189707873746269,
                        trialStep
                    )
                )
                y6.add(
                    k2OrK11,
                    multiplied: Relaxed.product(
                        -0.00004657483105197485920611507484730881742515,
                        trialStep
                    )
                )
                y6.add(
                    k3OrK12,
                    multiplied: Relaxed.product(
                        -0.06432077441802662594433314318598382583251,
                        trialStep
                    )
                )
                rhs.evaluate(
                    t: Relaxed.multiplyAdd(0.107, trialStep, startTime),
                    y: y6,
                    dy: &k10OrK13
                )
                _rhsEvaluationCount &+= 1

                // Retain both endpoints for dense output, then advance the
                // caller's state with the seventh-order solution.
                y6.assign(y)
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
                    Swift.min(1.0, safetyFactor * Double.pow(errorNorm, -1.0 / 7.0))
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
    /// Dense output and the cached endpoint derivative are invalidated.
    @inlinable
    public mutating func truncateLastStep(
        at time: Double,
        restoring state: inout State,
        proposedStepSize: Double? = nil
    ) {
        interpolateLastStep(at: time, into: &state)
        restart(at: time, proposedStepSize: proposedStepSize)
    }

    /// Invalidates the cached endpoint derivative and dense output after an
    /// in-place discontinuous modification of the state or right-hand side at
    /// the current time.
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
    internal static func denseOutputPolynomial(
        at theta: Double,
        _ c1: Double,
        _ c2: Double,
        _ c3: Double,
        _ c4: Double,
        _ c5: Double,
        _ c6: Double
    ) -> Double {
        let p5 = Relaxed.multiplyAdd(theta, c6, c5)
        let p4 = Relaxed.multiplyAdd(theta, p5, c4)
        let p3 = Relaxed.multiplyAdd(theta, p4, c3)
        let p2 = Relaxed.multiplyAdd(theta, p3, c2)
        let p1 = Relaxed.multiplyAdd(theta, p2, c1)
        return theta * p1
    }

    @inlinable
    @inline(always)
    internal static func denseOutputWeights(
        at theta: Double
    ) -> (
        b1: Double,
        b4: Double,
        b5: Double,
        b6: Double,
        b7: Double,
        b8: Double,
        b9: Double,
        b11: Double,
        b12: Double,
        b13: Double
    ) {
        let b1 = denseOutputPolynomial(
            at: theta,
            1,
            -7.582446684249578716313054661512721933240,
            21.65339697937461679177171822544604176620,
            -26.50313170111562393346845843813196066333,
            13.68567041142918450667757590934976189120,
            -2.201853803718019957033848524588941372473
        )
        let b4 = denseOutputPolynomial(
            at: theta,
            0,
            5.889034278272535871631390961135086381406,
            -57.96960154935775491821473273509196795388,
            174.1066668861731135303452708623511580529,
            -196.2003627160861165553101224432427862687,
            74.45098035454438694442515750830250503840
        )
        let b5 = denseOutputPolynomial(
            at: theta,
            0,
            3.196839349796654162957352828525358112148,
            -31.32397572700528310044209947396113560366,
            93.05298102970384392438258309708366195791,
            -102.8968871064061647967771234654923865084,
            38.30845998243966487696114628399332921615
        )
        let b6 = denseOutputPolynomial(
            at: theta,
            0,
            -0.08787886596190119861699566896289502028596,
            1.013797983077119427760544302767092045959,
            -4.100173002382458810769471031390844351476,
            6.641160480067744814819942865759689363544,
            -3.278457768019407452844911962268425918186
        )
        let b7 = denseOutputPolynomial(
            at: theta,
            0,
            -208.3972099204096382331570396018818793788,
            2077.909119755834934676745809403064182251,
            -6428.966291404445362174964426975619327549,
            7605.042110521116554859824801255385155563,
            -3021.046387735747808860531607896646209269
        )
        let b8 = denseOutputPolynomial(
            at: theta,
            0,
            594.3593292228751204027648218620251141015,
            -5925.388971699224459341618710912833599773,
            18326.52193738665917733083306878451733081,
            -21667.18569363528617503083225733032464553,
            8602.881495880286217175025916754667412586
        )
        let b9 = denseOutputPolynomial(
            at: theta,
            0,
            -386.8811915634934821635422144581019035900,
            3856.672838888456624774287551141874741487,
            -11926.20151472972403478718897872831668331,
            14096.40733595464142660949072316887784424,
            -5595.581125732115650649079320906757150875
        )
        let b11 = denseOutputPolynomial(
            at: theta,
            0,
            0.6111099397023196267050121119527364301482,
            -6.151956371109289894189681549817017604566,
            19.45873699463664083616118469228645171564,
            -23.90604463475469049657337318293279633818,
            9.988154071525019927896857928510625796953
        )
        let b12 = denseOutputPolynomial(
            at: theta,
            0,
            -8.007634773786193306062361780345514409318,
            74.60031392403404792779391526165329391946,
            -199.6748294772657466686035644277447081048,
            207.5792562775741227780748301919115920885,
            -74.49710595055623073120281924547466349383
        )
        let b13 = denseOutputPolynomial(
            at: theta,
            0,
            6.900049017254163553633088407166619306472,
            -11.01496218408055634389431366310163053450,
            -27.69438198223954924672720783503507856034,
            60.83345444770411331060500303070857149829,
            -29.02415929863817127361656993973848170993
        )
        return (b1, b4, b5, b6, b7, b8, b9, b11, b12, b13)
    }

    /// Evaluates Verner's sixth-order continuous extension of the last step.
    @inlinable
    public func interpolateLastStep(at time: Double, into result: inout State) {
        guard let lastStep = _lastStep else {
            preconditionFailure("Dense output is unavailable before an accepted step")
        }
        precondition(
            time >= lastStep.startTime && time <= lastStep.endTime,
            "Dense-output time lies outside the last accepted step"
        )

        if time == lastStep.startTime {
            result.assign(y6)
            return
        }
        if time == lastStep.endTime {
            result.assign(temporary)
            return
        }

        let theta = (time - lastStep.startTime) / lastStep.stepSize
        let weights = Self.denseOutputWeights(at: theta)

        result.assign(y6)
        result.add(k1, multiplied: lastStep.stepSize * weights.b1)
        result.add(k4, multiplied: lastStep.stepSize * weights.b4)
        result.add(k5, multiplied: lastStep.stepSize * weights.b5)
        result.add(k6, multiplied: lastStep.stepSize * weights.b6)
        result.add(k7, multiplied: lastStep.stepSize * weights.b7)
        result.add(k8, multiplied: lastStep.stepSize * weights.b8)
        result.add(k9, multiplied: lastStep.stepSize * weights.b9)
        result.add(k2OrK11, multiplied: lastStep.stepSize * weights.b11)
        result.add(k3OrK12, multiplied: lastStep.stepSize * weights.b12)
        result.add(k10OrK13, multiplied: lastStep.stepSize * weights.b13)
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

        if time == lastStep.startTime {
            return linearFunctional.evaluate(y6)
        }
        if time == lastStep.endTime {
            return linearFunctional.evaluate(temporary)
        }

        let theta = (time - lastStep.startTime) / lastStep.stepSize
        let weights = Self.denseOutputWeights(at: theta)

        return linearFunctional.evaluate(y6)
            + lastStep.stepSize * (
                weights.b1 * linearFunctional.evaluate(k1)
                    + weights.b4 * linearFunctional.evaluate(k4)
                    + weights.b5 * linearFunctional.evaluate(k5)
                    + weights.b6 * linearFunctional.evaluate(k6)
                    + weights.b7 * linearFunctional.evaluate(k7)
                    + weights.b8 * linearFunctional.evaluate(k8)
                    + weights.b9 * linearFunctional.evaluate(k9)
                    + weights.b11 * linearFunctional.evaluate(k2OrK11)
                    + weights.b12 * linearFunctional.evaluate(k3OrK12)
                    + weights.b13 * linearFunctional.evaluate(k10OrK13)
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

        if time == lastStep.startTime {
            return linearFunctional.evaluate(y6)
        }
        if time == lastStep.endTime {
            return linearFunctional.evaluate(temporary)
        }

        let theta = (time - lastStep.startTime) / lastStep.stepSize
        let weights = Self.denseOutputWeights(at: theta)

        var accumulator: Complex<Double> = .zero
        accumulator += weights.b1 * linearFunctional.evaluate(k1)
        accumulator += weights.b4 * linearFunctional.evaluate(k4)
        accumulator += weights.b5 * linearFunctional.evaluate(k5)
        accumulator += weights.b6 * linearFunctional.evaluate(k6)
        accumulator += weights.b7 * linearFunctional.evaluate(k7)
        accumulator += weights.b8 * linearFunctional.evaluate(k8)
        accumulator += weights.b9 * linearFunctional.evaluate(k9)
        accumulator += weights.b11 * linearFunctional.evaluate(k2OrK11)
        accumulator += weights.b12 * linearFunctional.evaluate(k3OrK12)
        accumulator += weights.b13 * linearFunctional.evaluate(k10OrK13)
        return linearFunctional.evaluate(y6) + lastStep.stepSize * accumulator
    }
}
