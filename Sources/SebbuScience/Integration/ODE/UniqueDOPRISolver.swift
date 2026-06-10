//
//  UniqueRK4FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import Numerics

@frozen
public struct UniqueDOPRISolver<State: ~Copyable & AdaptiveStepODESolverState, RHS: ~Copyable & ~Escapable & ODERHSFunction>: ~Copyable, ~Escapable where RHS.State == State {
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
        relativeTolerance: Double = 1e-3
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
