//
//  UniqueRK4FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import Numerics

public struct UniqueRK4Solver<State: ~Copyable & FixedStepODESolverState, RHS: ~Copyable & ~Escapable & ODERHSFunction>: ~Copyable, ~Escapable where RHS.State == State {
    public var t: Double
    public var dt: Double
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
        precondition(dt > .zero, "Time-step must be positive")
        self.t = t
        self.dt = dt
        self.rhs = rhs
        self.k1 = k1
        self.k2 = k2
        self.k3 = k3
        self.k4 = k4
        self.temporary = temporary
    }
    
    @inlinable
    public mutating func step(y: inout State) -> Double {
        rhs.evaluate(t: t, y: y, dy: &k1)

        temporary.assign(y, adding: k1, multipliedBy: 0.5 * dt)
        rhs.evaluate(t: t + 0.5 * dt, y: temporary, dy: &k2)

        temporary.assign(y, adding: k2, multipliedBy: 0.5 * dt)
        rhs.evaluate(t: t + 0.5 * dt, y: temporary, dy: &k3)

        temporary.assign(y, adding: k3, multipliedBy: dt)
        rhs.evaluate(t: t + dt, y: temporary, dy: &k4)

        y.add(k1, multiplied: dt / 6)
        y.add(k2, multiplied: dt / 3)
        y.add(k3, multiplied: dt / 3)
        y.add(k4, multiplied: dt / 6)
        
        t += dt
        return t
    }
}
