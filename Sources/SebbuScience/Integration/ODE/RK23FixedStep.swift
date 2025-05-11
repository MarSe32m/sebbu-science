//
//  RK23FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics
import NumericsExtensions

public struct RK23FixedStep<T> {
    public var t: Double
    public let dt: Double
    
    public var currentState: T
    
    @usableFromInline
    internal var borrowedState: T
    
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
        self.borrowedState = initialState
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

extension RK23FixedStep<Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let k1 = f(t0, y0)
        let k2 = f(t0 + dt23, y0 + dt23 * k1)
        currentState = y0 + dt * (0.25 * k1 + 0.75 * k2)
        t += dt
    }
}

extension RK23FixedStep<[Double]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        let k1 = f(t0, y0)
        for i in 0..<currentState.count {
            k2Argument[i] = Relaxed.multiplyAdd(dt23, k1[i], currentState[i])
        }
        let k2 = f(t0 + dt23, k2Argument)
        for i in 0..<currentState.count {
            currentState[i] = Relaxed.multiplyAdd(dt14, k1[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dt34, k2[i], currentState[i])
        }
        t += dt
    }
}

extension RK23FixedStep<Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let k1 = f(t0, y0)
        let k2 = f(t0 + dt23, y0 + dt23 * k1)
        currentState = y0 + dt * (0.25 * k1 + 0.75 * k2)
        t += dt
    }
}

extension RK23FixedStep<[Complex<Double>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        let k1 = f(t0, y0)
        for i in 0..<currentState.count {
            k2Argument[i] = Relaxed.multiplyAdd(dt23, k1[i], currentState[i])
        }
        let k2 = f(t0 + dt23, k2Argument)
        for i in 0..<currentState.count {
            currentState[i] = Relaxed.multiplyAdd(dt14, k1[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dt34, k2[i], currentState[i])
        }
        t += dt
    }
}

extension RK23FixedStep<Vector<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState.copyComponents(from: currentState)
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        k2Argument.copyComponents(from: currentState)
        k2Argument.add(k1, scaling: dt23)
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        currentState.add(k1, scaling: dt14)
        currentState.add(k2, scaling: dt34)
        t += dt
    }
}

extension RK23FixedStep<[Vector<Double>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        for i in 0..<k2Argument.count {
            k2Argument[i].copyComponents(from: currentState[i])
            k2Argument[i].add(k1[i], scaling: dt23)
        }
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], scaling: dt14)
            currentState[i].add(k2[i], scaling: dt34)
        }
        t += dt
    }
}

extension RK23FixedStep<Vector<Complex<Double>>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        borrowedState.copyComponents(from: currentState)
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        k2Argument.copyComponents(from: currentState)
        k2Argument.add(k1, scaling: dt23)
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        currentState.add(k1, scaling: dt14)
        currentState.add(k2, scaling: dt34)
        t += dt
    }
}

extension RK23FixedStep<[Vector<Complex<Double>>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        for i in 0..<k2Argument.count {
            k2Argument[i].copyComponents(from: currentState[i])
            k2Argument[i].add(k1[i], scaling: dt23)
        }
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], scaling: dt14)
            currentState[i].add(k2[i], scaling: dt34)
        }
        t += dt
    }
}

extension RK23FixedStep<Matrix<Double>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        borrowedState.copyElements(from: currentState)
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        k2Argument.copyElements(from: currentState)
        k2Argument.add(k1, multiplied: dt23)
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        currentState.add(k1, multiplied: dt14)
        currentState.add(k2, multiplied: dt34)
        t += dt
    }
}

extension RK23FixedStep<[Matrix<Double>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        for i in 0..<k2Argument.count {
            k2Argument[i].copyElements(from: currentState[i])
            k2Argument[i].add(k1[i], multiplied: dt23)
        }
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], multiplied: dt14)
            currentState[i].add(k2[i], multiplied: dt34)
        }
        t += dt
    }
}

extension RK23FixedStep<Matrix<Complex<Double>>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        borrowedState.copyElements(from: currentState)
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        k2Argument.copyElements(from: currentState)
        k2Argument.add(k1, multiplied: dt23)
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        currentState.add(k1, multiplied: dt14)
        currentState.add(k2, multiplied: dt34)
        t += dt
    }
}

extension RK23FixedStep<[Matrix<Complex<Double>>]> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let t0 = t
        let dt23 = dt * 2.0 / 3.0
        let dt14 = dt * 0.25
        let dt34 = dt * 0.75
        let k1 = f(t0, currentState) // Do not modify, this is cached in the calling code
        for i in 0..<k2Argument.count {
            k2Argument[i].copyElements(from: currentState[i])
            k2Argument[i].add(k1[i], multiplied: dt23)
        }
        let k2 = f(t0 + dt23, k2Argument) // Do not modify, this is cached in the calling code
        for i in 0..<currentState.count {
            currentState[i].add(k1[i], multiplied: dt14)
            currentState[i].add(k2[i], multiplied: dt34)
        }
        t += dt
    }
}
