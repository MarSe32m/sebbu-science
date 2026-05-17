//
//  UniqueRK4FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import Numerics

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
    
    @_lifetime(borrow owner)
    @inlinable
    public init(t0: Double, initialState: consuming T, scratchSpace: UnsafeMutableBufferPointer<T>, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
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
            temporary.assign(y5, adding: k1, multipliedBy: 1.0 / 5.0 * _dt)
            update(t0 + 1.0 / 5.0 * _dt, temporary, &k2)
            
            temporary.assign(y5, adding: k1, multipliedBy: 3.0 / 40.0 * _dt)
            temporary.add(k2, multiplied: 9.0 / 40.0 * _dt)
            update(t0 + 3.0 / 10.0 * _dt, temporary, &k3)
            
            temporary.assign(y5, adding: k1, multipliedBy: 44.0 / 45.0 * _dt)
            temporary.add(k2, multiplied: -56.0 / 15.0 * _dt)
            temporary.add(k3, multiplied: 32.0 / 9.0 * _dt)
            update(t0 + 4.0 / 5.0 * _dt, temporary, &k4)
            
            temporary.assign(y5, adding: k1, multipliedBy: 19372.0 / 6561.0 * _dt)
            temporary.add(k2, multiplied: -25360.0 / 2187.0 * _dt)
            temporary.add(k3, multiplied: 64448.0 / 6561.0 * _dt)
            temporary.add(k4, multiplied: -212.0 / 729.0 * _dt)
            update(t0 + 8.0 / 9.0 * _dt, temporary, &k5)
            
            temporary.assign(y5, adding: k1, multipliedBy: 9017.0 / 3168.0 * _dt)
            temporary.add(k2, multiplied: -355.0 / 33.0 * _dt)
            temporary.add(k3, multiplied: 46732.0 / 5247.0 * _dt)
            temporary.add(k4, multiplied: 49.0 / 176.0 * _dt)
            temporary.add(k5, multiplied: -5103.0 / 18656.0 * _dt)
            update(t0 + _dt, temporary, &k6)
            
            temporary.assign(y5, adding: k1, multipliedBy: 35.0 / 384.0 * _dt)
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: 500.0 / 1113.0 * _dt)
            temporary.add(k4, multiplied: 125.0 / 192.0 * _dt)
            temporary.add(k5, multiplied: -2187.0 / 6784.0 * _dt)
            temporary.add(k6, multiplied: 11.0 / 84.0 * _dt)
            update(t0 + _dt, temporary, &k7)
            
            y4.assign(y5, adding: k1, multipliedBy: 5179.0 / 57600.0 * _dt)
            //y4.add(k2, multiplied: 0.0)
            y4.add(k3, multiplied: 7571.0 / 16695.0 * _dt)
            y4.add(k4, multiplied: 393.0 / 640.0 * _dt)
            y4.add(k5, multiplied: -92097.0 / 339200.0 * _dt)
            y4.add(k6, multiplied: 187.0 / 2100.0 * _dt)
            y4.add(k7, multiplied: 1.0 / 40.0 * _dt)
            
            temporary.assign(y5, adding: k1, multipliedBy: 35.0 / 384.0 * _dt)
            //temporary.add(k2, multiplied: 0.0 * _dt)
            temporary.add(k3, multiplied: 500.0 / 1113.0 * _dt)
            temporary.add(k4, multiplied: 125.0 / 192.0 * _dt)
            temporary.add(k5, multiplied: -2187.0 / 6784.0 * _dt)
            temporary.add(k6, multiplied: 11.0 / 84.0 * _dt)
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
            temporary = y5 + 1.0 / 5.0 * k1 * _dt
            update(t0 + 1.0 / 5.0 * _dt, temporary, &k2)
            
            temporary = y5 + (3.0 / 40.0 * k1 + 9.0 / 40.0 * k2) * _dt
            update(t0 + 3.0 / 10.0 * _dt, temporary, &k3)
            
            temporary = y5 + (44.0 / 45.0 * k1 - 56.0 / 15.0 * k2 + 32.0 / 9.0 * k3) * _dt
            update(t0 + 4.0 / 5.0 * _dt, temporary, &k4)
            
            temporary = y5 + (19372.0 / 6561.0 * k1 - 25360.0 / 2187.0 * k2 + 64448.0 / 6561.0 * k3 - 212.0 / 729.0 * k4) * _dt
            update(t0 + 8.0 / 9.0 * _dt, temporary, &k5)
                        
            temporary = y5 + (9017.0 / 3168.0 * k1 - 355.0 / 33.0 * k2 + 46732.0 / 5247.0 * k3 + 49.0 / 176.0 * k4 - 5103.0 / 18656.0 * k5) * _dt
            update(t0 + _dt, temporary, &k6)
            
            temporary = y5 + (35.0 / 384.0 * k1 /*+ 0.0 * k2*/ + 500.0 / 1113.0 * k3 + 125.0 / 192.0 * k4 - 2187.0 / 6784.0 * k5 + 11.0 / 84.0 * k6) * _dt
            update(t0 + _dt, temporary, &k7)
            
            y4 = y5 + (5179.0 / 57600.0 * k1 /* + 0.0 * k2 */ + 7571.0 / 16695.0 * k3 + 393.0 / 640.0 * k4 - 92097.0 / 339200.0 * k5 + 187.0 / 2100.0 * k6 + 1.0 / 40.0 * k7) * _dt
            temporary = y5 + (35.0 / 384.0 * k1 /*+ 0.0 * k2*/ + 500.0 / 1113.0 * k3 + 125.0 / 192.0 * k4 - 2187.0 / 6784.0 * k5 + 11.0 / 84.0 * k6 /*+ 0.0 * k7*/) * _dt
            
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

/*
public extension UniqueDOPRISolver where T == Complex<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming Complex<Double>, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
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
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        temporary = y + dtPer2 * k1
        update(t0 + dtPer2, temporary, &k2)

        temporary = y + dtPer2 * k2
        update(t0 + dtPer2, temporary, &k3)

        temporary = y + _dt * k3
        update(t0 + _dt, temporary, &k4)
        
        y += k1 * dtPer6
        y += k2 * dtPer3
        y += k3 * dtPer3
        y += k4 * dtPer6
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Vector<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
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
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        temporary.copyComponents(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)

        temporary.copyComponents(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)

        temporary.copyComponents(from: y, adding: k3, multiplied: _dt)
        update(t0 + _dt, temporary, &k4)

        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Vector<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
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
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        temporary.copyComponents(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)

        temporary.copyComponents(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)

        temporary.copyComponents(from: y, adding: k3, multiplied: _dt)
        update(t0 + _dt, temporary, &k4)

        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Matrix<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
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
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        temporary.copyElements(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)

        temporary.copyElements(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)

        temporary.copyElements(from: y, adding: k3, multiplied: _dt)
        update(t0 + _dt, temporary, &k4)

        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Matrix<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
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
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        temporary.copyElements(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)

        temporary.copyElements(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)

        temporary.copyElements(from: y, adding: k3, multiplied: _dt)
        update(t0 + _dt, temporary, &k4)

        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Array<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
        self.k1 = .init(repeating: 0, count: initialState.count)
        self.k2 = .init(repeating: 0, count: initialState.count)
        self.k3 = .init(repeating: 0, count: initialState.count)
        self.k4 = .init(repeating: 0, count: initialState.count)
        self.k5 = .init(repeating: 0, count: initialState.count)
        self.k6 = .init(repeating: 0, count: initialState.count)
        self.k7 = .init(repeating: 0, count: initialState.count)
        self.temporary = .init(repeating: 0, count: initialState.count)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        for i in temporary.indices {
            temporary[i] = y[i] + k1[i] * dtPer2
        }
        update(t0 + dtPer2, temporary, &k2)
        
        for i in temporary.indices {
            temporary[i] = y[i] + k2[i] * dtPer2
        }
        update(t0 + dtPer2, temporary, &k3)
        
        for i in temporary.indices {
            temporary[i] = y[i] + k3[i] * _dt
        }
        update(t0 + _dt, temporary, &k4)
        
        for i in y.indices {
            y[i] += k1[i] * dtPer6 + k2[i] * dtPer3 + k3[i] * dtPer3 + k4[i] * dtPer6
        }
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Array<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
        self.k1 = .init(repeating: 0, count: initialState.count)
        self.k2 = .init(repeating: 0, count: initialState.count)
        self.k3 = .init(repeating: 0, count: initialState.count)
        self.k4 = .init(repeating: 0, count: initialState.count)
        self.k5 = .init(repeating: 0, count: initialState.count)
        self.k6 = .init(repeating: 0, count: initialState.count)
        self.k7 = .init(repeating: 0, count: initialState.count)
        self.temporary = .init(repeating: 0, count: initialState.count)
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        for i in temporary.indices {
            temporary[i] = y[i] + k1[i] * dtPer2
        }
        update(t0 + dtPer2, temporary, &k2)
        
        for i in temporary.indices {
            temporary[i] = y[i] + k2[i] * dtPer2
        }
        update(t0 + dtPer2, temporary, &k3)
        
        for i in temporary.indices {
            temporary[i] = y[i] + k3[i] * _dt
        }
        update(t0 + _dt, temporary, &k4)
        
        for i in y.indices {
            y[i] += k1[i] * dtPer6 + k2[i] * dtPer3 + k3[i] * dtPer3 + k4[i] * dtPer6
        }
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Array<Vector<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for vector in initialState {
            self.k1.append(.zero(vector.count))
            self.k2.append(.zero(vector.count))
            self.k3.append(.zero(vector.count))
            self.k4.append(.zero(vector.count))
            self.k5.append(.zero(vector.count))
            self.k6.append(.zero(vector.count))
            self.k7.append(.zero(vector.count))
            self.temporary.append(.zero(vector.count))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        for i in temporary.indices {
            temporary[i].copyComponents(from: y[i], adding: k1[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k2)
        
        for i in temporary.indices {
            temporary[i].copyComponents(from: y[i], adding: k2[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k3)
        
        for i in temporary.indices {
            temporary[i].copyComponents(from: y[i], adding: k3[i], multiplied: _dt)
        }
        update(t0 + _dt, temporary, &k4)
        
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += _dt
    }
}


public extension UniqueDOPRISolver where T == Array<Vector<Complex<Double>>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for vector in initialState {
            self.k1.append(.zero(vector.count))
            self.k2.append(.zero(vector.count))
            self.k3.append(.zero(vector.count))
            self.k4.append(.zero(vector.count))
            self.k5.append(.zero(vector.count))
            self.k6.append(.zero(vector.count))
            self.k7.append(.zero(vector.count))
            self.temporary.append(.zero(vector.count))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        for i in temporary.indices {
            temporary[i].copyComponents(from: y[i], adding: k1[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k2)
        
        for i in temporary.indices {
            temporary[i].copyComponents(from: y[i], adding: k2[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k3)
        
        for i in temporary.indices {
            temporary[i].copyComponents(from: y[i], adding: k3[i], multiplied: _dt)
        }
        update(t0 + _dt, temporary, &k4)
        
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Array<Matrix<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for matrix in initialState {
            precondition(matrix.isSquare)
            self.k1.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k2.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k3.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k4.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k5.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k6.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k7.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.temporary.append(.zeros(rows: matrix.rows, columns: matrix.columns))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        for i in temporary.indices {
            temporary[i].copyElements(from: y[i], adding: k1[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k2)
        
        for i in temporary.indices {
            temporary[i].copyElements(from: y[i], adding: k2[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k3)
        
        for i in temporary.indices {
            temporary[i].copyElements(from: y[i], adding: k3[i], multiplied: _dt)
        }
        update(t0 + _dt, temporary, &k4)
        
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += _dt
    }
}

public extension UniqueDOPRISolver where T == Array<Matrix<Complex<Double>>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, maxStep: Double, absoluteTolerance: Double = 1e-6, relativeTolerance: Double = 1e-3, owner: Void = ()) {
        self._t = t0
        self._dt = dt
        self.maxStep = maxStep
        self.absoluteTolerance = absoluteTolerance
        self.relativeTolerance = relativeTolerance
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.k5 = []
        self.k6 = []
        self.k7 = []
        self.temporary = []
        for matrix in initialState {
            precondition(matrix.isSquare)
            self.k1.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k2.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k3.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k4.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k5.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k6.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k7.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.temporary.append(.zeros(rows: matrix.rows, columns: matrix.columns))
        }
    }
    
    @inlinable
    mutating func step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(update)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ update: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void
    ) {
        let dtPer2 = _dt / 2
        let dtPer3 = _dt / 3
        let dtPer6 = _dt / 6

        let t0 = _t

        update(t0, y, &k1)
        
        for i in temporary.indices {
            temporary[i].copyElements(from: y[i], adding: k1[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k2)
        
        for i in temporary.indices {
            temporary[i].copyElements(from: y[i], adding: k2[i], multiplied: dtPer2)
        }
        update(t0 + dtPer2, temporary, &k3)
        
        for i in temporary.indices {
            temporary[i].copyElements(from: y[i], adding: k3[i], multiplied: _dt)
        }
        update(t0 + _dt, temporary, &k4)
        
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += _dt
    }
}
*/
