//
//  UniqueRK4FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import Numerics

public struct UniqueRK4Solver<T: ~Copyable>: ~Copyable, ~Escapable {
    @_transparent
    @inlinable
    public var t: Double { _t }
    
    @usableFromInline
    internal var _t: Double
    
    public let dt: Double
    
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
    internal var y: T
    
    @usableFromInline
    internal var k1: T
    
    @usableFromInline
    internal var k2: T
    
    @usableFromInline
    internal var k3: T
    
    @usableFromInline
    internal var k4: T
    
    @usableFromInline
    internal var temporary: T
    
    @_lifetime(borrow owner)
    @inlinable
    public init(t0: Double, initialState: consuming T, scratchSpace: UnsafeMutableBufferPointer<T>, dt: Double, owner: Void = ()) {
        precondition(scratchSpace.count == 6, "Scratch space must have exactly 6 elements")
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = scratchSpace.moveElement(from: 0)
        self.k2 = scratchSpace.moveElement(from: 1)
        self.k3 = scratchSpace.moveElement(from: 2)
        self.k4 = scratchSpace.moveElement(from: 3)
        self.temporary = scratchSpace.moveElement(from: 4)
        scratchSpace.deallocate()
    }
    
    public mutating func reset(initialState: consuming T, t0: Double) {
        self.y = initialState
        self._t = t0
        self.stepCount = 0
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

public extension UniqueRK4Solver where T: UniqueODESolverState {
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
    }
}

public extension UniqueRK4Solver where T == Double {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming Double, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = 0
        self.k2 = 0
        self.k3 = 0
        self.k4 = 0
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)
        temporary = y + dtPer2 * k1
        update(t0 + dtPer2, temporary, &k2)
        temporary = y + dtPer2 * k2
        update(t0 + dtPer2, temporary, &k3)
        temporary = y + dt * k3
        update(t0 + dt, temporary, &k4)
        y += dtPer6 * k1
        y += dtPer3 * k2
        y += dtPer3 * k3
        y += dtPer6 * k4
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Complex<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming Complex<Double>, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = 0
        self.k2 = 0
        self.k3 = 0
        self.k4 = 0
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)
        temporary = y + dtPer2 * k1
        update(t0 + dtPer2, temporary, &k2)
        temporary = y + dtPer2 * k2
        update(t0 + dtPer2, temporary, &k3)
        temporary = y + dt * k3
        update(t0 + dt, temporary, &k4)
        y += k1 * dtPer6
        y += k2 * dtPer3
        y += k3 * dtPer3
        y += k4 * dtPer6
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Vector<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = .zero(initialState.count)
        self.k2 = .zero(initialState.count)
        self.k3 = .zero(initialState.count)
        self.k4 = .zero(initialState.count)
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)
        temporary.copyComponents(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)
        temporary.copyComponents(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)
        temporary.copyComponents(from: y, adding: k3, multiplied: dt)
        update(t0 + dt, temporary, &k4)
        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Vector<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = .zero(initialState.count)
        self.k2 = .zero(initialState.count)
        self.k3 = .zero(initialState.count)
        self.k4 = .zero(initialState.count)
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)
        temporary.copyComponents(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)
        temporary.copyComponents(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)
        temporary.copyComponents(from: y, adding: k3, multiplied: dt)
        update(t0 + dt, temporary, &k4)
        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Matrix<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        precondition(initialState.isSquare)
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k2 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k3 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k4 = .zeros(rows: initialState.rows, columns: initialState.columns)
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)
        temporary.copyElements(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)
        temporary.copyElements(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)
        temporary.copyElements(from: y, adding: k3, multiplied: dt)
        update(t0 + dt, temporary, &k4)
        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Matrix<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        precondition(initialState.isSquare)
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k2 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k3 = .zeros(rows: initialState.rows, columns: initialState.columns)
        self.k4 = .zeros(rows: initialState.rows, columns: initialState.columns)
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

        let t0 = _t

        update(t0, y, &k1)
        temporary.copyElements(from: y, adding: k1, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k2)
        temporary.copyElements(from: y, adding: k2, multiplied: dtPer2)
        update(t0 + dtPer2, temporary, &k3)
        temporary.copyElements(from: y, adding: k3, multiplied: dt)
        update(t0 + dt, temporary, &k4)
        y.add(k1, multiplied: dtPer6)
        y.add(k2, multiplied: dtPer3)
        y.add(k3, multiplied: dtPer3)
        y.add(k4, multiplied: dtPer6)
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Array<Double> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = .init(repeating: 0, count: initialState.count)
        self.k2 = .init(repeating: 0, count: initialState.count)
        self.k3 = .init(repeating: 0, count: initialState.count)
        self.k4 = .init(repeating: 0, count: initialState.count)
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

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
            temporary[i] = y[i] + k3[i] * dt
        }
        update(t0 + dt, temporary, &k4)
        for i in y.indices {
            y[i] += k1[i] * dtPer6 + k2[i] * dtPer3 + k3[i] * dtPer3 + k4[i] * dtPer6
        }
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Array<Complex<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = .init(repeating: 0, count: initialState.count)
        self.k2 = .init(repeating: 0, count: initialState.count)
        self.k3 = .init(repeating: 0, count: initialState.count)
        self.k4 = .init(repeating: 0, count: initialState.count)
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

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
            temporary[i] = y[i] + k3[i] * dt
        }
        update(t0 + dt, temporary, &k4)
        for i in y.indices {
            y[i] += k1[i] * dtPer6 + k2[i] * dtPer3 + k3[i] * dtPer3 + k4[i] * dtPer6
        }
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Array<Vector<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.temporary = []
        for vector in initialState {
            self.k1.append(.zero(vector.count))
            self.k2.append(.zero(vector.count))
            self.k3.append(.zero(vector.count))
            self.k4.append(.zero(vector.count))
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

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
            temporary[i].copyComponents(from: y[i], adding: k3[i], multiplied: dt)
        }
        update(t0 + dt, temporary, &k4)
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += dt
    }
}


public extension UniqueRK4Solver where T == Array<Vector<Complex<Double>>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.temporary = []
        for vector in initialState {
            self.k1.append(.zero(vector.count))
            self.k2.append(.zero(vector.count))
            self.k3.append(.zero(vector.count))
            self.k4.append(.zero(vector.count))
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

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
            temporary[i].copyComponents(from: y[i], adding: k3[i], multiplied: dt)
        }
        update(t0 + dt, temporary, &k4)
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Array<Matrix<Double>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.temporary = []
        for matrix in initialState {
            precondition(matrix.isSquare)
            self.k1.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k2.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k3.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k4.append(.zeros(rows: matrix.rows, columns: matrix.columns))
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

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
            temporary[i].copyElements(from: y[i], adding: k3[i], multiplied: dt)
        }
        update(t0 + dt, temporary, &k4)
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += dt
    }
}

public extension UniqueRK4Solver where T == Array<Matrix<Complex<Double>>> {
    @inlinable
    @_lifetime(borrow owner)
    init(t0: Double, initialState: consuming T, dt: Double, owner: Void = ()) {
        self._t = t0
        self.dt = dt
        self.y = initialState
        self.k1 = []
        self.k2 = []
        self.k3 = []
        self.k4 = []
        self.temporary = []
        for matrix in initialState {
            precondition(matrix.isSquare)
            self.k1.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k2.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k3.append(.zeros(rows: matrix.rows, columns: matrix.columns))
            self.k4.append(.zeros(rows: matrix.rows, columns: matrix.columns))
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
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6

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
            temporary[i].copyElements(from: y[i], adding: k3[i], multiplied: dt)
        }
        update(t0 + dt, temporary, &k4)
        for i in y.indices {
            y[i].add(k1[i], multiplied: dtPer6)
            y[i].add(k2[i], multiplied: dtPer3)
            y[i].add(k3[i], multiplied: dtPer3)
            y[i].add(k4[i], multiplied: dtPer6)
        }
        _t += dt
    }
}
