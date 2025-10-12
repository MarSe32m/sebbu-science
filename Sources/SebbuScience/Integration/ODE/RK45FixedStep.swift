//
//  RK45FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics
import NumericsExtensions

public struct RK45FixedStep<T> {
    public var t: Double
    public let dt: Double
    
    public var currentState: T
    
    @usableFromInline
    internal var stepCount: Int = 0
    
    @usableFromInline
    internal let f: (_ t: Double, _ state: T) -> T
    
    // Scratch vectors
    @usableFromInline
    internal var k2Argument: T
    
    @usableFromInline
    internal var k3Argument: T
    
    @usableFromInline
    internal var k4Argument: T
    
    @inlinable
    public init(initialState: T, t0: Double, dt: Double, f: @escaping (_ t: Double, _ currentState: T) -> T) {
        self.t = t0
        self.dt = dt
        self.currentState = initialState
        self.k2Argument = initialState
        self.k3Argument = initialState
        self.k4Argument = initialState
        self.f = f
    }
    
    public mutating func reset(initialState: T, t0: Double) {
        self.currentState = initialState
        self.t = t0
    }
}

extension RK45FixedStep<Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let t0 = t
        let k1 = f(t0, y0)
        let k2 = f(t0 + dt / 2, y0 + dt * k1 / 2)
        let k3 = f(t0 + dt / 2, y0 + dt * k2 / 2)
        let k4 = f(t0 + dt, y0 + dt * k3)
        currentState = y0 + dt / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
        t += dt
    }
}

extension RK45FixedStep<[Double]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6
        
        let k1 = f(t0, currentState)
        for i in 0..<k2Argument.count {
            k2Argument[i] = Relaxed.multiplyAdd(dtPer2, k1[i], currentState[i])
        }
        let k2 = f(t0 + dtPer2, k2Argument)
        for i in 0..<k3Argument.count {
            k3Argument[i] = Relaxed.multiplyAdd(dtPer2, k2[i], currentState[i])
        }
        let k3 = f(t0 + dtPer2, k3Argument)
        for i in 0..<k4Argument.count {
            k4Argument[i] = Relaxed.multiplyAdd(dt, k3[i], currentState[i])
        }
        let k4 = f(t0 + dt, k4Argument)
        for i in 0..<currentState.count {
            currentState[i] = Relaxed.multiplyAdd(dtPer6, k1[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer3, k2[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer3, k3[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer6, k4[i], currentState[i])
        }
        t += dt
    }
}

extension RK45FixedStep<Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let t0 = t
        let k1 = f(t0, y0)
        let k2 = f(t0 + dt / 2.0, y0 + dt * k1 / 2.0)
        let k3 = f(t0 + dt / 2.0, y0 + dt * k2 / 2.0)
        let k4 = f(t0 + dt, y0 + dt * k3)
        currentState = y0 + dt / 6.0 * (k1 + 2.0 * k2 + 2.0 * k3 + k4)
        t += dt
    }
}

extension RK45FixedStep<[Complex<Double>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6
        
        let k1 = f(t0, currentState)
        for i in 0..<k2Argument.count {
            k2Argument[i] = Relaxed.multiplyAdd(dtPer2, k1[i], currentState[i])
        }
        let k2 = f(t0 + dtPer2, k2Argument)
        for i in 0..<k3Argument.count {
            k3Argument[i] = Relaxed.multiplyAdd(dtPer2, k2[i], currentState[i])
        }
        let k3 = f(t0 + dtPer2, k3Argument)
        for i in 0..<k4Argument.count {
            k4Argument[i] = Relaxed.multiplyAdd(dt, k3[i], currentState[i])
        }
        let k4 = f(t0 + dt, k4Argument)
        for i in 0..<currentState.count {
            currentState[i] = Relaxed.multiplyAdd(dtPer6, k1[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer3, k2[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer3, k3[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer6, k4[i], currentState[i])
        }
        t += dt
    }
}

extension RK45FixedStep<Vector<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2.0
        let dtPer3 = dt / 3.0
        let dtPer6 = dt / 6.0
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        
        k2Argument.copyComponents(from: currentState)
        k3Argument.copyComponents(from: currentState)
        k4Argument.copyComponents(from: currentState)
        
        // k2Argument = y0 + dtPer2 * k1
        k2Argument.add(k1, multiplied: dtPer2)
        let k2 = f(t0 + dtPer2, k2Argument) // Do not modify, this is cached in the calling code
        
        // k3Arguments = y0 + dtPer2 * k2
        k3Argument.add(k2, multiplied: dtPer2)
        let k3 = f(t0 + dtPer2, k3Argument) // Do not modify, this is cached in the calling code
        
        // k4Argument = y0 + dy * k3
        k4Argument.add(k3, multiplied: dt)
        let k4 = f(t0 + dt, k4Argument) // Do not modify, this is cached in the calling code
        
        // currentState += dtPer6 * (k1 + 2 * k2 + 2 * k3 + k4)
        currentState.add(k1, multiplied: dtPer6)
        currentState.add(k2, multiplied: dtPer3)
        currentState.add(k3, multiplied: dtPer3)
        currentState.add(k4, multiplied: dtPer6)
        
        t += dt
    }
}

extension RK45FixedStep<[Vector<Double>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6
        
        let k1 = f(t0, currentState)
        for i in 0..<k2Argument.count {
            k2Argument[i].copyComponents(from: currentState[i])
            k2Argument[i].add(k1[i], multiplied: dtPer2)
        }
        let k2 = f(t0 + dtPer2, k2Argument)
        for i in 0..<k3Argument.count {
            k3Argument[i].copyComponents(from: currentState[i])
            k3Argument[i].add(k2[i], multiplied: dtPer2)
        }
        let k3 = f(t0 + dtPer2, k3Argument)
        for i in 0..<k4Argument.count {
            k4Argument[i].copyComponents(from: currentState[i])
            k4Argument[i].add(k3[i], multiplied: dt)
        }
        let k4 = f(t0 + dt, k4Argument)
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], multiplied: dtPer6)
            currentState[i].add(k2[i], multiplied: dtPer3)
            currentState[i].add(k3[i], multiplied: dtPer3)
            currentState[i].add(k4[i], multiplied: dtPer6)
        }
        t += dt
    }
}

extension RK45FixedStep<Vector<Complex<Double>>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2.0
        let dtPer3 = dt / 3.0
        let dtPer6 = dt / 6.0
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        
        k2Argument.copyComponents(from: currentState)
        k3Argument.copyComponents(from: currentState)
        k4Argument.copyComponents(from: currentState)
        
        // k2Argument = y0 + dtPer2 * k1
        k2Argument.add(k1, multiplied: dtPer2)
        let k2 = f(t0 + dtPer2, k2Argument) // Do not modify, this is cached in the calling code
        
        // k3Arguments = y0 + dtPer2 * k2
        k3Argument.add(k2, multiplied: dtPer2)
        let k3 = f(t0 + dtPer2, k3Argument) // Do not modify, this is cached in the calling code
        
        // k4Argument = y0 + dt * k3
        k4Argument.add(k3, multiplied: dt)
        let k4 = f(t0 + dt, k4Argument) // Do not modify, this is cached in the calling code
        
        // currentState += dtPer6 * (k1 + 2 * k2 + 2 * k3 + k4)
        currentState.add(k1, multiplied: dtPer6)
        currentState.add(k2, multiplied: dtPer3)
        currentState.add(k3, multiplied: dtPer3)
        currentState.add(k4, multiplied: dtPer6)
        
        t += dt
    }
}

extension RK45FixedStep<[Vector<Complex<Double>>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6
        
        let k1 = f(t0, currentState)
        for i in 0..<k2Argument.count {
            k2Argument[i].copyComponents(from: currentState[i])
            k2Argument[i].add(k1[i], multiplied: dtPer2)
        }
        let k2 = f(t0 + dtPer2, k2Argument)
        for i in 0..<k3Argument.count {
            k3Argument[i].copyComponents(from: currentState[i])
            k3Argument[i].add(k2[i], multiplied: dtPer2)
        }
        let k3 = f(t0 + dtPer2, k3Argument)
        for i in 0..<k4Argument.count {
            k4Argument[i].copyComponents(from: currentState[i])
            k4Argument[i].add(k3[i], multiplied: dt)
        }
        let k4 = f(t0 + dt, k4Argument)
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], multiplied: dtPer6)
            currentState[i].add(k2[i], multiplied: dtPer3)
            currentState[i].add(k3[i], multiplied: dtPer3)
            currentState[i].add(k4[i], multiplied: dtPer6)
        }
        t += dt
    }
}

extension RK45FixedStep<Matrix<Double>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2.0
        let dtPer3 = dt / 3.0
        let dtPer6 = dt / 6.0
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        
        k2Argument.copyElements(from: currentState)
        k3Argument.copyElements(from: currentState)
        k4Argument.copyElements(from: currentState)
        
        // k2Argument = y0 + dtPer2 * k1
        k2Argument.add(k1, multiplied: dtPer2)
        let k2 = f(t0 + dtPer2, k2Argument) // Do not modify, this is cached in the calling code
        
        // k3Arguments = y0 + dtPer2 * k2
        k3Argument.add(k2, multiplied: dtPer2)
        let k3 = f(t0 + dtPer2, k3Argument) // Do not modify, this is cached in the calling code
        
        // k4Argument = y0 + dy * k3
        k4Argument.add(k3, multiplied: dt)
        let k4 = f(t0 + dt, k4Argument) // Do not modify, this is cached in the calling code
        
        // currentState += dtPer6 * (k1 + 2 * k2 + 2 * k3 + k4)
        currentState.add(k1, multiplied: dtPer6)
        currentState.add(k2, multiplied: dtPer3)
        currentState.add(k3, multiplied: dtPer3)
        currentState.add(k4, multiplied: dtPer6)
        
        t += dt
    }
}

extension RK45FixedStep<[Matrix<Double>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6
        
        let k1 = f(t0, currentState)
        for i in 0..<k2Argument.count {
            k2Argument[i].copyElements(from: currentState[i])
            k2Argument[i].add(k1[i], multiplied: dtPer2)
        }
        let k2 = f(t0 + dtPer2, k2Argument)
        for i in 0..<k3Argument.count {
            k3Argument[i].copyElements(from: currentState[i])
            k3Argument[i].add(k2[i], multiplied: dtPer2)
        }
        let k3 = f(t0 + dtPer2, k3Argument)
        for i in 0..<k4Argument.count {
            k4Argument[i].copyElements(from: currentState[i])
            k4Argument[i].add(k3[i], multiplied: dt)
        }
        let k4 = f(t0 + dt, k4Argument)
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], multiplied: dtPer6)
            currentState[i].add(k2[i], multiplied: dtPer3)
            currentState[i].add(k3[i], multiplied: dtPer3)
            currentState[i].add(k4[i], multiplied: dtPer6)
        }
        t += dt
    }
}

extension RK45FixedStep<Matrix<Complex<Double>>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2.0
        let dtPer3 = dt / 3.0
        let dtPer6 = dt / 6.0
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        
        k2Argument.copyElements(from: currentState)
        k3Argument.copyElements(from: currentState)
        k4Argument.copyElements(from: currentState)
        
        // k2Argument = y0 + dtPer2 * k1
        k2Argument.add(k1, multiplied: dtPer2)
        let k2 = f(t0 + dtPer2, k2Argument) // Do not modify, this is cached in the calling code
        
        // k3Arguments = y0 + dtPer2 * k2
        k3Argument.add(k2, multiplied: dtPer2)
        let k3 = f(t0 + dtPer2, k3Argument) // Do not modify, this is cached in the calling code
        
        // k4Argument = y0 + dy * k3
        k4Argument.add(k3, multiplied: dt)
        let k4 = f(t0 + dt, k4Argument) // Do not modify, this is cached in the calling code
        
        // currentState += dtPer6 * (k1 + 2 * k2 + 2 * k3 + k4)
        currentState.add(k1, multiplied: dtPer6)
        currentState.add(k2, multiplied: dtPer3)
        currentState.add(k3, multiplied: dtPer3)
        currentState.add(k4, multiplied: dtPer6)
        
        t += dt
    }
}

extension RK45FixedStep<[Matrix<Complex<Double>>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return (t, currentState)
        }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dtPer2 = dt / 2
        let dtPer3 = dt / 3
        let dtPer6 = dt / 6
        
        let k1 = f(t0, currentState)
        for i in 0..<k2Argument.count {
            k2Argument[i].copyElements(from: currentState[i])
            k2Argument[i].add(k1[i], multiplied: dtPer2)
        }
        let k2 = f(t0 + dtPer2, k2Argument)
        for i in 0..<k3Argument.count {
            k3Argument[i].copyElements(from: currentState[i])
            k3Argument[i].add(k2[i], multiplied: dtPer2)
        }
        let k3 = f(t0 + dtPer2, k3Argument)
        for i in 0..<k4Argument.count {
            k4Argument[i].copyElements(from: currentState[i])
            k4Argument[i].add(k3[i], multiplied: dt)
        }
        let k4 = f(t0 + dt, k4Argument)
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], multiplied: dtPer6)
            currentState[i].add(k2[i], multiplied: dtPer3)
            currentState[i].add(k3[i], multiplied: dtPer3)
            currentState[i].add(k4[i], multiplied: dtPer6)
        }
        t += dt
    }
}
