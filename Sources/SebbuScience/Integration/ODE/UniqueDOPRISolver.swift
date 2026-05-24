//
//  UniqueRK4FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import Numerics

public struct UniqueDOPRISolver<State: ~Copyable & AdaptiveStepODESolverState, RHS: ODERHSFunction>: ~Copyable, ~Escapable where RHS.State == State {
    public var t: Double
    public var dt: Double
    public var maxStep: Double
    public var absoluteTolerance: Double
    public var relativeTolerance: Double
    
    public var hasCachedK1: Bool = false
    
    @usableFromInline
    internal var rhs: RHS
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
    internal var k7 :State
    @usableFromInline
    internal var temporary: State
    
    @_lifetime(borrow owner)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        maxStep: Double,
        rhs: RHS,
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
        owner: Void = ()
    ) {
        precondition(dt > .zero, "Time-step must be positive")
        self.t = t
        self.dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
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
    
    @inlinable
    public mutating func step(y: inout State) -> Double {
        while true {
            if hasCachedK1 { rhs.evaluate(t: t, y: y, dy: &k1) }
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(1.0 / 5.0, dt))
            rhs.evaluate(t: Relaxed.multiplyAdd(1.0 / 5.0, dt, t), y: temporary, dy: &k2)
            
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(3.0 / 40.0, dt))
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, dt))
            rhs.evaluate(t: Relaxed.multiplyAdd(3.0 / 10.0, dt, t), y: temporary, dy: &k3)
            
            
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(44.0 / 45.0, dt))
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, dt))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, dt))
            rhs.evaluate(t: Relaxed.multiplyAdd(4.0 / 5.0, dt, t), y: temporary, dy: &k4)
            
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(19372.0 / 6561.0, dt))
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, dt))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, dt))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, dt))
            rhs.evaluate(t: Relaxed.multiplyAdd(8.0 / 9.0, dt, t), y: temporary, dy: &k5)
            
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(9017.0 / 3168.0, dt))
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, dt))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, dt))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, dt))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, dt))
            rhs.evaluate(t: Relaxed.sum(dt, t), y: temporary, dy: &k6)
            
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(35.0 / 384.0, dt))
            //temporary.add(k2, multiplied: 0.0 * dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, dt))
            rhs.evaluate(t: Relaxed.sum(dt, t), y: temporary, dy: &k7)
            
            y4.assign(y, adding: k1, multipliedBy: Relaxed.product(5179.0 / 57600.0, dt))
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, dt))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, dt))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, dt))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, dt))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, dt))
            
            temporary.assign(y, adding: k1, multipliedBy: Relaxed.product(35.0 / 384.0, dt))
            //temporary.add(k2, multiplied: 0.0 * dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, dt))
            //temporary.add(k7, multiplied: 0.0 * dt)
            
            let error = temporary.distance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.norm
            if error > errorScale {
                // Reject step
                hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                dt = Swift.min(maxStep, dt)
                continue
            }
            // Accept step
            t += dt
            y.assign(temporary)
            k1.assign(k7)
            hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            dt = Swift.min(maxStep, dt)
            return t
        }
    }
}

/*
public struct UniqueDOPRISolver<T: ~Copyable>: ~Copyable, ~Escapable {
    @_transparent
    @inlinable
    public var t: Double { _t }
    
    @usableFromInline
    internal var _t: Double
    
    @usableFromInline
    internal var _dt: Double
    
    @usableFromInline
    internal var _hasCachedK1: Bool = false
    
    public var maxStep: Double
    
    public var absoluteTolerance: Double
    
    public var relativeTolerance: Double
    
    @usableFromInline
    internal var stepCount: Int = 0
    
#if swift(>=6.4)
    #warning("TODO: Check that this works!")
    @inlinable
    public var currentState: T {
        borrow { y }
    }
#endif
    @usableFromInline
    internal var y4: T
    @usableFromInline
    internal var y5: T
    @usableFromInline
    internal var k1: T
    @usableFromInline
    internal var k2: T
    @usableFromInline
    internal var k3: T
    @usableFromInline
    internal var k4: T
    @usableFromInline
    internal var k5: T
    @usableFromInline
    internal var k6: T
    @usableFromInline
    internal var k7: T
    @usableFromInline
    internal var temporary: T
    
#if swift(>=6.4)
    #error("TODO: Use UniqueArray or RigidArray for scratch space")
#endif
    @_lifetime(borrow owner)
    @inlinable
    public init(t0: Double, initialState: consuming T, scratchSpace: consuming UnsafeMutableBufferPointer<T>, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        precondition(scratchSpace.count == 9, "Scratch space must have exactly 9 elements")
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = scratchSpace.moveElement(from: 0)
        self.k1 = scratchSpace.moveElement(from: 1)
        self.k2 = scratchSpace.moveElement(from: 2)
        self.k3 = scratchSpace.moveElement(from: 3)
        self.k4 = scratchSpace.moveElement(from: 4)
        self.k5 = scratchSpace.moveElement(from: 5)
        self.k6 = scratchSpace.moveElement(from: 6)
        self.k7 = scratchSpace.moveElement(from: 7)
        self.temporary = scratchSpace.moveElement(from: 8)
        scratchSpace.deallocate()
    }
    
    @_lifetime(borrow owner)
    @inlinable
    public init(
        t0: Double,
        initialState: T,
        dt: Double,
        maxStep: Double,
        absoluteTolerance: Double = 1e-6,
        relativeTolerance: Double = 1e-3,
        owner: Void = ()
    ) where T: Copyable {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = copy initialState
        self.k1 = copy initialState
        self.k2 = copy initialState
        self.k3 = copy initialState
        self.k4 = copy initialState
        self.k5 = copy initialState
        self.k6 = copy initialState
        self.k7 = copy initialState
        self.temporary = copy initialState
    }
    
    @inlinable
    public mutating func reset(initialState: consuming T, t0: Double) {
        self.y5 = initialState
        self._t = t0
        self.stepCount = 0
        self._hasCachedK1 = false
    }

#if swift(>=6.4)
    #warning("Check whether the ARC calls are fixed")
    public struct StepResult: ~Copyable, ~Escapable {
        public let t: Double
        public let state: Ref<T>

        @_lifetime(borrow state)
        @inlinable
        internal init(t: Double, state: borrowing T) {
            self.t = t
            self.state = Ref(state)
        }
    }


    @_lifetime(&self)
    @inlinable
    public mutating func step(_ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void) -> StepResult {
        y0.assign(y)
        
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)

        temporary.assign(y, adding: k1, multipliedBy: dtPer2)
        update(t0 + dtPer2, temporary, &k2)

        temporary.assign(y, adding: k2, multipliedBy: dtPer2)
        update(t0 + dtPer2, temporary, &k3)

        temporary.assign(y, adding: k3, multipliedBy: dt)
        update(t0 + dt, temporary, &k4)

        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += dt
        return StepResult(t: t0, state: y0)
    }
#endif
}

public extension UniqueDOPRISolver where T: UniqueODESolverState {
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(1.0 / 5.0, _dt))
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(3.0 / 40.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, _dt))
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(44.0 / 45.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, _dt))
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(19372.0 / 6561.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(9017.0 / 3168.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            y4.assign(y5, adding: k1, multipliedBy: Relaxed.product(5179.0 / 57600.0, _dt))
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, _dt))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, _dt))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, _dt))
            
            temporary.assign(y5, adding: k1, multipliedBy: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            //temporary.add(k7, multiplied: 0.0 * _dt)
            
            let error = temporary.distance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.norm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5.assign(temporary)
            k1.assign(k7)
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}

public extension UniqueDOPRISolver where T == Double {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = 0
        self.k1 = 0
        self.k2 = 0
        self.k3 = 0
        self.k4 = 0
        self.k5 = 0
        self.k6 = 0
        self.k7 = 0
        self.temporary = 0
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            
            temporary = Relaxed.product(1.0 / 5.0, k1)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 1.0 / 5.0 * _dt, temporary, &k2)
            
            temporary = Relaxed.product(3.0 / 40.0, k1)
            temporary = Relaxed.multiplyAdd(9.0 / 40.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 3.0 / 10.0 * _dt, temporary, &k3)
            
            temporary = Relaxed.product(44.0 / 45.0,  k1)
            temporary = Relaxed.multiplyAdd(56.0 / 15.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(32.0 / 9.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 4.0 / 5.0 * _dt, temporary, &k4)
            
            temporary = Relaxed.product(19372.0 / 6561.0, k1)
            temporary = Relaxed.multiplyAdd(-25360.0 / 2187.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(64448.0 / 6561.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(-212.0 / 729.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 8.0 / 9.0 * _dt, temporary, &k5)
                        
            temporary = Relaxed.product(9017.0 / 3168.0, k1)
            temporary = Relaxed.multiplyAdd(-355.0 / 33.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(46732.0 / 5247.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(49.0 / 176.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(-5103.0 / 18656.0, k5, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + _dt, temporary, &k6)
            
            temporary = Relaxed.product(35.0 / 384.0, k1)
            //temporary = Relaxed.multiplyAdd(0.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(500.0 / 1113.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(125.0 / 192.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5, temporary)
            temporary = Relaxed.multiplyAdd(11.0 / 84.0, k6, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + _dt, temporary, &k7)
            
            y4 = Relaxed.product(5179.0 / 57600.0, k1)
            //y4 = Relaxed.multiplyAdd(0.0, k2, y4)
            y4 = Relaxed.multiplyAdd(7571.0 / 16695.0, k3, y4)
            y4 = Relaxed.multiplyAdd(393.0 / 640.0, k4, y4)
            y4 = Relaxed.multiplyAdd(-92097.0 / 339200.0, k5, y4)
            y4 = Relaxed.multiplyAdd(187.0 / 2100.0, k6, y4)
            y4 = Relaxed.multiplyAdd(1.0 / 40.0, k7, y4)
            y4 = Relaxed.multiplyAdd(y4, _dt, y5)
            
            temporary = Relaxed.product(35.0 / 384.0, k1)
            //temporary = Relaxed.multiplyAdd(0.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(500.0 / 1113.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(125.0 / 192.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5, temporary)
            temporary = Relaxed.multiplyAdd(11.0 / 84.0, k6, temporary)
            temporary = Relaxed.multiplyAdd(0.0, k7, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            
            let error = temporary.distance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.magnitude
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5 = temporary
            k1 = k7
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Complex<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .zero
        self.k1 = .zero
        self.k2 = .zero
        self.k3 = .zero
        self.k4 = .zero
        self.k5 = .zero
        self.k6 = .zero
        self.k7 = .zero
        self.temporary = .zero
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            temporary = Relaxed.product(1.0 / 5.0, k1)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 1.0 / 5.0 * _dt, temporary, &k2)
            
            temporary = Relaxed.product(3.0 / 40.0, k1)
            temporary = Relaxed.multiplyAdd(9.0 / 40.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 3.0 / 10.0 * _dt, temporary, &k3)
            
            temporary = Relaxed.product(44.0 / 45.0,  k1)
            temporary = Relaxed.multiplyAdd(56.0 / 15.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(32.0 / 9.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 4.0 / 5.0 * _dt, temporary, &k4)
            
            temporary = Relaxed.product(19372.0 / 6561.0, k1)
            temporary = Relaxed.multiplyAdd(-25360.0 / 2187.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(64448.0 / 6561.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(-212.0 / 729.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + 8.0 / 9.0 * _dt, temporary, &k5)
                        
            temporary = Relaxed.product(9017.0 / 3168.0, k1)
            temporary = Relaxed.multiplyAdd(-355.0 / 33.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(46732.0 / 5247.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(49.0 / 176.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(-5103.0 / 18656.0, k5, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + _dt, temporary, &k6)
            
            temporary = Relaxed.product(35.0 / 384.0, k1)
            //temporary = Relaxed.multiplyAdd(0.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(500.0 / 1113.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(125.0 / 192.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5, temporary)
            temporary = Relaxed.multiplyAdd(11.0 / 84.0, k6, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            update(t0 + _dt, temporary, &k7)
            
            y4 = Relaxed.product(5179.0 / 57600.0, k1)
            //y4 = Relaxed.multiplyAdd(0.0, k2, y4)
            y4 = Relaxed.multiplyAdd(7571.0 / 16695.0, k3, y4)
            y4 = Relaxed.multiplyAdd(393.0 / 640.0, k4, y4)
            y4 = Relaxed.multiplyAdd(-92097.0 / 339200.0, k5, y4)
            y4 = Relaxed.multiplyAdd(187.0 / 2100.0, k6, y4)
            y4 = Relaxed.multiplyAdd(1.0 / 40.0, k7, y4)
            y4 = Relaxed.multiplyAdd(y4, _dt, y5)
            
            temporary = Relaxed.product(35.0 / 384.0, k1)
            //temporary = Relaxed.multiplyAdd(0.0, k2, temporary)
            temporary = Relaxed.multiplyAdd(500.0 / 1113.0, k3, temporary)
            temporary = Relaxed.multiplyAdd(125.0 / 192.0, k4, temporary)
            temporary = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5, temporary)
            temporary = Relaxed.multiplyAdd(11.0 / 84.0, k6, temporary)
            temporary = Relaxed.multiplyAdd(0.0, k7, temporary)
            temporary = Relaxed.multiplyAdd(temporary, _dt, y5)
            
            let error = (temporary - y4).length
            let errorScale = absoluteTolerance + relativeTolerance * temporary.length
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5 = temporary
            k1 = k7
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Vector<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .zero(initialState.count)
        self.k1 = .zero(initialState.count)
        self.k2 = .zero(initialState.count)
        self.k3 = .zero(initialState.count)
        self.k4 = .zero(initialState.count)
        self.k5 = .zero(initialState.count)
        self.k6 = .zero(initialState.count)
        self.k7 = .zero(initialState.count)
        self.temporary = .zero(initialState.count)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(1.0 / 5.0, _dt))
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            temporary.copyComponents(from: y5, adding: k2, multiplied: Relaxed.product(3.0 / 40.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, _dt))
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(44.0 / 45.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, _dt))
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            y4.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, _dt))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, _dt))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, _dt))
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            //temporary.add(k7, multiplied: 0.0 * _dt)
            
            let error = temporary.distance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.norm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5.copyComponents(from: temporary)
            k1.copyComponents(from: k7)
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Vector<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .zero(initialState.count)
        self.k1 = .zero(initialState.count)
        self.k2 = .zero(initialState.count)
        self.k3 = .zero(initialState.count)
        self.k4 = .zero(initialState.count)
        self.k5 = .zero(initialState.count)
        self.k6 = .zero(initialState.count)
        self.k7 = .zero(initialState.count)
        self.temporary = .zero(initialState.count)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(1.0 / 5.0, _dt))
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            temporary.copyComponents(from: y5, adding: k2, multiplied: Relaxed.product(3.0 / 40.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, _dt))
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(44.0 / 45.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, _dt))
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            y4.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, _dt))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, _dt))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, _dt))
            
            temporary.copyComponents(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            //temporary.add(k7, multiplied: 0.0 * _dt)
            
            let error = temporary.distance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.norm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5.copyComponents(from: temporary)
            k1.copyComponents(from: k7)
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Matrix<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k1 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k2 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k3 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k4 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k5 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k6 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k7 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.temporary = .zeros(rows: initialState.rows, columns: initialState.columns)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(1.0 / 5.0, _dt))
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            temporary.copyElements(from: y5, adding: k2, multiplied: Relaxed.product(3.0 / 40.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, _dt))
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(44.0 / 45.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, _dt))
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            y4.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, _dt))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, _dt))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, _dt))
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            //temporary.add(k7, multiplied: 0.0 * _dt)
            
            let error: Double = temporary.frobeniusDistance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.frobeniusNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5.copyElements(from: temporary)
            k1.copyElements(from: k7)
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Matrix<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k1 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k2 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k3 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k4 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k5 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k6 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k7 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.temporary = .zeros(rows: initialState.rows, columns: initialState.columns)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(1.0 / 5.0, _dt))
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            temporary.copyElements(from: y5, adding: k2, multiplied: Relaxed.product(3.0 / 40.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(9.0 / 40.0, _dt))
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(44.0 / 45.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-56.0 / 15.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(32.0 / 9.0, _dt))
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
            temporary.add(k2, multiplied: Relaxed.product(-355.0 / 33.0, _dt))
            temporary.add(k3, multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(49.0 / 176.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            y4.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
            y4.add(k4, multiplied: Relaxed.product(393.0 / 640.0, _dt))
            y4.add(k5, multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
            y4.add(k6, multiplied: Relaxed.product(187.0 / 2100.0, _dt))
            y4.add(k7, multiplied: Relaxed.product(1.0 / 40.0, _dt))
            
            temporary.copyElements(from: y5, adding: k1, multiplied: Relaxed.product(35.0 / 384.0, _dt))
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: Relaxed.product(500.0 / 1113.0, _dt))
            temporary.add(k4, multiplied: Relaxed.product(125.0 / 192.0, _dt))
            temporary.add(k5, multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
            temporary.add(k6, multiplied: Relaxed.product(11.0 / 84.0, _dt))
            //temporary.add(k7, multiplied: 0.0 * _dt)
            
            let error: Double = temporary.frobeniusDistance(to: y4)
            let errorScale = absoluteTolerance + relativeTolerance * temporary.frobeniusNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            y5.copyElements(from: temporary)
            k1.copyElements(from: k7)
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Array<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .init(repeating: .zero, count: initialState.count)
        self.k1 = .init(repeating: .zero, count: initialState.count)
        self.k2 = .init(repeating: .zero, count: initialState.count)
        self.k3 = .init(repeating: .zero, count: initialState.count)
        self.k4 = .init(repeating: .zero, count: initialState.count)
        self.k5 = .init(repeating: .zero, count: initialState.count)
        self.k6 = .init(repeating: .zero, count: initialState.count)
        self.k7 = .init(repeating: .zero, count: initialState.count)
        self.temporary = .init(repeating: .zero, count: initialState.count)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(1.0 / 5.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 1.0 / 5.0 * _dt, temporary, &k2)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(3.0 / 40.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(9.0 / 40.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 3.0 / 10.0 * _dt, temporary, &k3)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(44.0 / 45.0,  k1[i])
                temporary[i] = Relaxed.multiplyAdd(56.0 / 15.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(32.0 / 9.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 4.0 / 5.0 * _dt, temporary, &k4)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(19372.0 / 6561.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(-25360.0 / 2187.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(64448.0 / 6561.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-212.0 / 729.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 8.0 / 9.0 * _dt, temporary, &k5)
                        
            for i in temporary.indices {
                temporary[i] = Relaxed.product(9017.0 / 3168.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(-355.0 / 33.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(46732.0 / 5247.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(49.0 / 176.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-5103.0 / 18656.0, k5[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + _dt, temporary, &k6)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(35.0 / 384.0, k1[i])
                //temporary[i] = Relaxed.multiplyAdd(0.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(500.0 / 1113.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(125.0 / 192.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(11.0 / 84.0, k6[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + _dt, temporary, &k7)
            
            for i in temporary.indices {
                y4[i] = Relaxed.product(5179.0 / 57600.0, k1[i])
                //y4[i] = Relaxed.multiplyAdd(0.0, k2[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(7571.0 / 16695.0, k3[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(393.0 / 640.0, k4[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(-92097.0 / 339200.0, k5[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(187.0 / 2100.0, k6[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(1.0 / 40.0, k7[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(y4[i], _dt, y5[i])
                
                temporary[i] = Relaxed.product(35.0 / 384.0, k1[i])
                //temporary[i] = Relaxed.multiplyAdd(0.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(500.0 / 1113.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(125.0 / 192.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(11.0 / 84.0, k6[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(0.0, k7[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            
            
            var error: Double = .zero
            var tempNorm: Double = .zero
            for i in temporary.indices {
                tempNorm += temporary[i] * temporary[i]
                let diff = temporary[i] - y4[i]
                error += diff * diff
            }
            error.formSquareRoot()
            tempNorm.formSquareRoot()
            let errorScale = absoluteTolerance + relativeTolerance * tempNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            for i in temporary.indices {
                y5[i] = temporary[i]
                k1[i] = k7[i]
            }
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}

public extension UniqueDOPRISolver where T == Array<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = .init(repeating: .zero, count: initialState.count)
        self.k1 = .init(repeating: .zero, count: initialState.count)
        self.k2 = .init(repeating: .zero, count: initialState.count)
        self.k3 = .init(repeating: .zero, count: initialState.count)
        self.k4 = .init(repeating: .zero, count: initialState.count)
        self.k5 = .init(repeating: .zero, count: initialState.count)
        self.k6 = .init(repeating: .zero, count: initialState.count)
        self.k7 = .init(repeating: .zero, count: initialState.count)
        self.temporary = .init(repeating: .zero, count: initialState.count)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(1.0 / 5.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 1.0 / 5.0 * _dt, temporary, &k2)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(3.0 / 40.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(9.0 / 40.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 3.0 / 10.0 * _dt, temporary, &k3)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(44.0 / 45.0,  k1[i])
                temporary[i] = Relaxed.multiplyAdd(56.0 / 15.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(32.0 / 9.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 4.0 / 5.0 * _dt, temporary, &k4)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(19372.0 / 6561.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(-25360.0 / 2187.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(64448.0 / 6561.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-212.0 / 729.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + 8.0 / 9.0 * _dt, temporary, &k5)
                        
            for i in temporary.indices {
                temporary[i] = Relaxed.product(9017.0 / 3168.0, k1[i])
                temporary[i] = Relaxed.multiplyAdd(-355.0 / 33.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(46732.0 / 5247.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(49.0 / 176.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-5103.0 / 18656.0, k5[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + _dt, temporary, &k6)
            
            for i in temporary.indices {
                temporary[i] = Relaxed.product(35.0 / 384.0, k1[i])
                //temporary[i] = Relaxed.multiplyAdd(0.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(500.0 / 1113.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(125.0 / 192.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(11.0 / 84.0, k6[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            update(t0 + _dt, temporary, &k7)
            
            for i in temporary.indices {
                y4[i] = Relaxed.product(5179.0 / 57600.0, k1[i])
                //y4[i] = Relaxed.multiplyAdd(0.0, k2[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(7571.0 / 16695.0, k3[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(393.0 / 640.0, k4[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(-92097.0 / 339200.0, k5[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(187.0 / 2100.0, k6[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(1.0 / 40.0, k7[i], y4[i])
                y4[i] = Relaxed.multiplyAdd(y4[i], _dt, y5[i])
                
                temporary[i] = Relaxed.product(35.0 / 384.0, k1[i])
                //temporary[i] = Relaxed.multiplyAdd(0.0, k2[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(500.0 / 1113.0, k3[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(125.0 / 192.0, k4[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(-2187.0 / 6784.0, k5[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(11.0 / 84.0, k6[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(0.0, k7[i], temporary[i])
                temporary[i] = Relaxed.multiplyAdd(temporary[i], _dt, y5[i])
            }
            
            
            var error: Double = .zero
            var tempNorm: Double = .zero
            for i in temporary.indices {
                tempNorm += temporary[i].lengthSquared
                let diff = temporary[i] - y4[i]
                error += diff.lengthSquared
            }
            error.formSquareRoot()
            tempNorm.formSquareRoot()
            let errorScale = absoluteTolerance + relativeTolerance * tempNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            for i in temporary.indices {
                y5[i] = temporary[i]
                k1[i] = k7[i]
            }
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}

public extension UniqueDOPRISolver where T == Array<Vector<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = []
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for y in initialState {
            self.y4.append(.zero(y.count))
            self.k1.append(.zero(y.count))
            self.k2.append(.zero(y.count))
            self.k3.append(.zero(y.count))
            self.k4.append(.zero(y.count))
            self.k5.append(.zero(y.count))
            self.k6.append(.zero(y.count))
            self.k7.append(.zero(y.count))
            self.temporary.append(.zero(y.count))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let indices = y5.indices
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(1.0 / 5.0, _dt))
            }
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k2[i], multiplied: Relaxed.product(3.0 / 40.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(9.0 / 40.0, _dt))
            }
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(44.0 / 45.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-56.0 / 15.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(32.0 / 9.0, _dt))
            }
            
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            }
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-355.0 / 33.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(49.0 / 176.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            for i in indices {
                y4[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
                //y4[i].add(k2[i], multiplied: 0.0)
                y4[i].add(k3[i], multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
                y4[i].add(k4[i], multiplied: Relaxed.product(393.0 / 640.0, _dt))
                y4[i].add(k5[i], multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
                y4[i].add(k6[i], multiplied: Relaxed.product(187.0 / 2100.0, _dt))
                y4[i].add(k7[i], multiplied: Relaxed.product(1.0 / 40.0, _dt))
                
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
                //temporary.add(k7[i], multiplied: 0.0 * _dt)
            }
            var tempNorm: Double = .zero
            var error: Double = .zero
            for i in indices {
                tempNorm += temporary[i].normSquared
                error += temporary[i].distanceSquared(to: y4[i])
            }
            tempNorm.formSquareRoot()
            error.formSquareRoot()
            let errorScale = absoluteTolerance + relativeTolerance * tempNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            for i in indices {
                y5[i].copyComponents(from: temporary[i])
                k1[i].copyComponents(from: k7[i])
            }
            
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Array<Vector<Complex<Double>>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = []
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for y in initialState {
            self.y4.append(.zero(y.count))
            self.k1.append(.zero(y.count))
            self.k2.append(.zero(y.count))
            self.k3.append(.zero(y.count))
            self.k4.append(.zero(y.count))
            self.k5.append(.zero(y.count))
            self.k6.append(.zero(y.count))
            self.k7.append(.zero(y.count))
            self.temporary.append(.zero(y.count))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let indices = y5.indices
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(1.0 / 5.0, _dt))
            }
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k2[i], multiplied: Relaxed.product(3.0 / 40.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(9.0 / 40.0, _dt))
            }
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(44.0 / 45.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-56.0 / 15.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(32.0 / 9.0, _dt))
            }
            
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            }
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-355.0 / 33.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(49.0 / 176.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            for i in indices {
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            for i in indices {
                y4[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
                //y4[i].add(k2[i], multiplied: 0.0)
                y4[i].add(k3[i], multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
                y4[i].add(k4[i], multiplied: Relaxed.product(393.0 / 640.0, _dt))
                y4[i].add(k5[i], multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
                y4[i].add(k6[i], multiplied: Relaxed.product(187.0 / 2100.0, _dt))
                y4[i].add(k7[i], multiplied: Relaxed.product(1.0 / 40.0, _dt))
                
                temporary[i].copyComponents(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
                //temporary.add(k7[i], multiplied: 0.0 * _dt)
            }
            var tempNorm: Double = .zero
            var error: Double = .zero
            for i in indices {
                tempNorm += temporary[i].normSquared
                error += temporary[i].distanceSquared(to: y4[i])
            }
            tempNorm.formSquareRoot()
            error.formSquareRoot()
            let errorScale = absoluteTolerance + relativeTolerance * tempNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            for i in indices {
                y5[i].copyComponents(from: temporary[i])
                k1[i].copyComponents(from: k7[i])
            }
            
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}

public extension UniqueDOPRISolver where T == Array<Matrix<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = []
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for y in initialState {
            self.y4.append(.zeros(rows: y.rows, columns: y.columns))
            self.k1.append(.zeros(rows: y.rows, columns: y.columns))
            self.k2.append(.zeros(rows: y.rows, columns: y.columns))
            self.k3.append(.zeros(rows: y.rows, columns: y.columns))
            self.k4.append(.zeros(rows: y.rows, columns: y.columns))
            self.k5.append(.zeros(rows: y.rows, columns: y.columns))
            self.k6.append(.zeros(rows: y.rows, columns: y.columns))
            self.k7.append(.zeros(rows: y.rows, columns: y.columns))
            self.temporary.append(.zeros(rows: y.rows, columns: y.columns))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let indices = y5.indices
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(1.0 / 5.0, _dt))
            }
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k2[i], multiplied: Relaxed.product(3.0 / 40.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(9.0 / 40.0, _dt))
            }
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(44.0 / 45.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-56.0 / 15.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(32.0 / 9.0, _dt))
            }
            
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            }
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-355.0 / 33.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(49.0 / 176.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            for i in indices {
                y4[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
                //y4[i].add(k2[i], multiplied: 0.0)
                y4[i].add(k3[i], multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
                y4[i].add(k4[i], multiplied: Relaxed.product(393.0 / 640.0, _dt))
                y4[i].add(k5[i], multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
                y4[i].add(k6[i], multiplied: Relaxed.product(187.0 / 2100.0, _dt))
                y4[i].add(k7[i], multiplied: Relaxed.product(1.0 / 40.0, _dt))
                
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
                //temporary.add(k7[i], multiplied: 0.0 * _dt)
            }
            var tempNorm: Double = .zero
            var error: Double = .zero
            for i in indices {
                let frobeniusNorm = temporary[i].frobeniusNorm
                tempNorm += frobeniusNorm * frobeniusNorm
                error += temporary[i].frobeniusDistanceSquared(to: y4[i])
            }
            tempNorm.formSquareRoot()
            error.formSquareRoot()
            let errorScale = absoluteTolerance + relativeTolerance * tempNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            for i in indices {
                y5[i].copyElements(from: temporary[i])
                k1[i].copyElements(from: k7[i])
            }
            
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}


public extension UniqueDOPRISolver where T == Array<Matrix<Complex<Double>>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T,  dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y5 = initialState
        self.y4 = []
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for y in initialState {
            self.y4.append(.zeros(rows: y.rows, columns: y.columns))
            self.k1.append(.zeros(rows: y.rows, columns: y.columns))
            self.k2.append(.zeros(rows: y.rows, columns: y.columns))
            self.k3.append(.zeros(rows: y.rows, columns: y.columns))
            self.k4.append(.zeros(rows: y.rows, columns: y.columns))
            self.k5.append(.zeros(rows: y.rows, columns: y.columns))
            self.k6.append(.zeros(rows: y.rows, columns: y.columns))
            self.k7.append(.zeros(rows: y.rows, columns: y.columns))
            self.temporary.append(.zeros(rows: y.rows, columns: y.columns))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            body(t, y5)
            update(t, y5, &k1)
            _hasCachedK1 = true
            return
        }
        _step(update)
        body(t, y5)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let indices = y5.indices
        let t0 = _t
        while true {
            if !_hasCachedK1 {
                update(t0, y5, &k1)
            }
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(1.0 / 5.0, _dt))
            }
            update(Relaxed.multiplyAdd(1.0 / 5.0, _dt, t0), temporary, &k2)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k2[i], multiplied: Relaxed.product(3.0 / 40.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(9.0 / 40.0, _dt))
            }
            update(Relaxed.multiplyAdd(3.0 / 10.0, _dt, t0), temporary, &k3)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(44.0 / 45.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-56.0 / 15.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(32.0 / 9.0, _dt))
            }
            
            update(Relaxed.multiplyAdd(4.0 / 5.0, _dt, t0), temporary, &k4)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(19372.0 / 6561.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-25360.0 / 2187.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(64448.0 / 6561.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(-212.0 / 729.0, _dt))
            }
            update(Relaxed.multiplyAdd(8.0 / 9.0, _dt, t0), temporary, &k5)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(9017.0 / 3168.0, _dt))
                temporary[i].add(k2[i], multiplied: Relaxed.product(-355.0 / 33.0, _dt))
                temporary[i].add(k3[i], multiplied: Relaxed.product(46732.0 / 5247.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(49.0 / 176.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-5103.0 / 18656.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k6)
            
            for i in indices {
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
            }
            update(Relaxed.sum(_dt, t0), temporary, &k7)
            
            for i in indices {
                y4[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(5179.0 / 57600.0, _dt))
                //y4[i].add(k2[i], multiplied: 0.0)
                y4[i].add(k3[i], multiplied: Relaxed.product(7571.0 / 16695.0, _dt))
                y4[i].add(k4[i], multiplied: Relaxed.product(393.0 / 640.0, _dt))
                y4[i].add(k5[i], multiplied: Relaxed.product(-92097.0 / 339200.0, _dt))
                y4[i].add(k6[i], multiplied: Relaxed.product(187.0 / 2100.0, _dt))
                y4[i].add(k7[i], multiplied: Relaxed.product(1.0 / 40.0, _dt))
                
                temporary[i].copyElements(from: y5[i], adding: k1[i], multiplied: Relaxed.product(35.0 / 384.0, _dt))
                //temporary[i].add(k2[i], multiplied: 0.0 * _dt)
                temporary[i].add(k3[i], multiplied: Relaxed.product(500.0 / 1113.0, _dt))
                temporary[i].add(k4[i], multiplied: Relaxed.product(125.0 / 192.0, _dt))
                temporary[i].add(k5[i], multiplied: Relaxed.product(-2187.0 / 6784.0, _dt))
                temporary[i].add(k6[i], multiplied: Relaxed.product(11.0 / 84.0, _dt))
                //temporary.add(k7[i], multiplied: 0.0 * _dt)
            }
            var tempNorm: Double = .zero
            var error: Double = .zero
            for i in indices {
                let frobeniusNorm = temporary[i].frobeniusNorm
                tempNorm += frobeniusNorm * frobeniusNorm
                error += temporary[i].frobeniusDistanceSquared(to: y4[i])
            }
            tempNorm.formSquareRoot()
            error.formSquareRoot()
            let errorScale = absoluteTolerance + relativeTolerance * tempNorm
            if error > errorScale {
                // Reject step
                _hasCachedK1 = false
                let scale = 0.9 * .pow(errorScale / error, 1 / 6.0)
                _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
                _dt = Swift.min(maxStep, _dt)
                continue
            }
            // Accept step
            _t += _dt
            for i in indices {
                y5[i].copyElements(from: temporary[i])
                k1[i].copyElements(from: k7[i])
            }
            
            _hasCachedK1 = true
            let scale = error <= 1e-10 ? 2.0 : 0.9 * .pow(errorScale / error, 0.2)
            _dt *= Swift.max(Swift.min(scale, 2.0), 0.1)
            _dt = Swift.min(maxStep, _dt)
            return
        }
    }
}

*/
