//
//  SRK2FixedStep.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics
import NumericsExtensions

// Method based on the improved Euler/Heun method: https://arxiv.org/pdf/1210.0933
// This is the Stratonovich version!
public struct SRK2FixedStep<T, NoiseType> {
    public var t: Double
    public let dt: Double
    
    @usableFromInline
    internal let sqrtDt: Double
    
    public var currentState: T
    
    @usableFromInline
    internal var borrowedState: T
    
    // Drift term
    @usableFromInline
    internal let f: (_ t: Double, _ state: T) -> T
    
    // Diffusion term
    @usableFromInline
    internal let g: (_ t: Double, _ state: T) -> T
    
    // White noise
    @usableFromInline
    internal let w: (_ t: Double) -> NoiseType
    
    @usableFromInline
    internal var auxiliaryState: T
    
    @inlinable
    public init(initialState: T, t0: Double, dt: Double, f: @escaping (_ t: Double, _ currentState: T) -> T, g: @escaping (_ t: Double, _ currentState: T) -> T, w: @escaping (Double) -> NoiseType) {
        self.t = t0
        self.dt = dt
        self.sqrtDt = dt.squareRoot()
        self.currentState = initialState
        self.borrowedState = initialState
        self.auxiliaryState = initialState
        self.f = f
        self.g = g
        self.w = w
    }
    
    public mutating func reset(initialState: T, t0: Double) {
        self.currentState = initialState
        self.t = t0
    }
}

extension SRK2FixedStep<Double, Double> {
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
        let dW = sqrtDt * w(t)
        let fty0 = f(t, y0)
        let gty0 = g(t, y0)
        let yAux = y0 + fty0 * dt + gty0 * dW
        let y = y0 + 0.5 * (fty0 + f(t + dt, yAux)) * dt + 0.5 * (gty0 + g(t + dt, yAux)) * dW
        currentState = y
        t += dt
    }
}

extension SRK2FixedStep<[Double], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let dtPer2 = 0.5 * dt
        let dWPer2 = 0.5 * dW
        let fty0 = f(t, currentState)
        let gty0 = g(t, currentState)
        for i in 0..<auxiliaryState.count {
            auxiliaryState[i] = Relaxed.multiplyAdd(dt, fty0[i], currentState[i])
            auxiliaryState[i] = Relaxed.multiplyAdd(dW, gty0[i], auxiliaryState[i])
        }
        let ftyAux = f(t + dt, auxiliaryState)
        let gtyAux = g(t + dt, auxiliaryState)
        for i in 0..<currentState.count {
            currentState[i] = Relaxed.multiplyAdd(dtPer2, fty0[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer2, ftyAux[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dWPer2, gty0[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dWPer2, gtyAux[i], currentState[i])
        }
        t += dt
    }
}

extension SRK2FixedStep<Complex<Double>, Complex<Double>> {
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
        let dW = sqrtDt * w(t)
        let fty0 = f(t, y0)
        let gty0 = g(t, y0)
        let yAux = y0 + dt * fty0 + gty0 * dW
        let ftyAux = f(t + dt, yAux)
        let gtyAux = g(t + dt, yAux)
        currentState += 0.5 * dt * (fty0 + ftyAux)
        currentState += 0.5 * (gty0 + gtyAux) * dW
        t += dt
    }
}

extension SRK2FixedStep<[Complex<Double>], Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let dtPer2 = 0.5 * dt
        let dWPer2 = 0.5 * dW
        let fty0 = f(t, currentState)
        let gty0 = g(t, currentState)
        for i in 0..<auxiliaryState.count {
            auxiliaryState[i] = Relaxed.multiplyAdd(dt, fty0[i], currentState[i])
            auxiliaryState[i] = Relaxed.multiplyAdd(dW, gty0[i], auxiliaryState[i])
        }
        let ftyAux = f(t + dt, auxiliaryState)
        let gtyAux = g(t + dt, auxiliaryState)
        for i in 0..<currentState.count {
            currentState[i] = Relaxed.multiplyAdd(dtPer2, fty0[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer2, ftyAux[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dWPer2, gty0[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dWPer2, gtyAux[i], currentState[i])
        }
        t += dt
    }
}

extension SRK2FixedStep<Vector<Double>, Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState.copyComponents(from: currentState)
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        //yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyComponents(from: currentState)
        auxiliaryState.add(fty0, scaling: dt)
        auxiliaryState.add(gty0, scaling: dW)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        // currentState += halfdt * (fty0 + ftyAux) + halfdW * (gty0 + gtyAux)
        currentState.add(fty0, scaling: halfdt)
        currentState.add(ftyAux, scaling: halfdt)
        currentState.add(gty0, scaling: halfdW)
        currentState.add(gtyAux, scaling: halfdW)
        t += dt
    }
}

extension SRK2FixedStep<[Vector<Double>], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in 0..<auxiliaryState.count {
            auxiliaryState[i].copyComponents(from: currentState[i])
            auxiliaryState[i].add(fty0[i], scaling: dt)
            auxiliaryState[i].add(gty0[i], scaling: dW)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        for i in 0..<currentState.count {
            currentState[i].add(fty0[i], scaling: halfdt)
            currentState[i].add(ftyAux[i], scaling: halfdt)
            currentState[i].add(gty0[i], scaling: halfdW)
            currentState[i].add(gtyAux[i], scaling: halfdW)
        }
        
        t += dt
    }
}

extension SRK2FixedStep<Vector<Complex<Double>>, Complex<Double>> {
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
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        //yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyComponents(from: currentState)
        auxiliaryState.add(fty0, scaling: dt)
        auxiliaryState.add(gty0, scaling: dW)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        // currentState += halfdt * (fty0 + ftyAux) + halfdW * (gty0 + gtyAux)
        currentState.add(fty0, scaling: halfdt)
        currentState.add(ftyAux, scaling: halfdt)
        currentState.add(gty0, scaling: halfdW)
        currentState.add(gtyAux, scaling: halfdW)
        
        t += dt
    }
}

extension SRK2FixedStep<[Vector<Complex<Double>>], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in 0..<auxiliaryState.count {
            auxiliaryState[i].copyComponents(from: currentState[i])
            auxiliaryState[i].add(fty0[i], scaling: dt)
            auxiliaryState[i].add(gty0[i], scaling: dW)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        for i in 0..<currentState.count {
            currentState[i].add(fty0[i], scaling: halfdt)
            currentState[i].add(ftyAux[i], scaling: halfdt)
            currentState[i].add(gty0[i], scaling: halfdW)
            currentState[i].add(gtyAux[i], scaling: halfdW)
        }
        
        t += dt
    }
}

extension SRK2FixedStep<Matrix<Double>, Double> {
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
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        // yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyElements(from: currentState)
        auxiliaryState.add(fty0, scaling: dt)
        auxiliaryState.add(gty0, scaling: dW)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        // currentState = halfdt * (fty0 + ftyAux) + halfDw * (gty0 + gtyAux)
        currentState.add(fty0, scaling: halfdt)
        currentState.add(ftyAux, scaling: halfdt)
        currentState.add(gty0, scaling: halfdW)
        currentState.add(gtyAux, scaling: halfdW)
        
        t += dt
    }
}

extension SRK2FixedStep<[Matrix<Double>], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in 0..<auxiliaryState.count {
            auxiliaryState[i].copyElements(from: currentState[i])
            auxiliaryState[i].add(fty0[i], scaling: dt)
            auxiliaryState[i].add(gty0[i], scaling: dW)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        for i in 0..<currentState.count {
            currentState[i].add(fty0[i], scaling: halfdt)
            currentState[i].add(ftyAux[i], scaling: halfdt)
            currentState[i].add(gty0[i], scaling: halfdW)
            currentState[i].add(gtyAux[i], scaling: halfdW)
        }
        
        t += dt
    }
}

extension SRK2FixedStep<Matrix<Complex<Double>>, Complex<Double>> {
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
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        // yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyElements(from: currentState)
        auxiliaryState.add(fty0, scaling: dt)
        auxiliaryState.add(gty0, scaling: dW)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        // currentState = halfdt * (fty0 + ftyAux) + halfDw * (gty0 + gtyAux)
        currentState.add(fty0, scaling: halfdt)
        currentState.add(ftyAux, scaling: halfdt)
        currentState.add(gty0, scaling: halfdW)
        currentState.add(gtyAux, scaling: halfdW)
        
        t += dt
    }
}

extension SRK2FixedStep<[Matrix<Complex<Double>>], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        borrowedState = currentState
        let result = (t, borrowedState)
        _step()
        return result
    }
    
    @inlinable
    internal mutating func _step() {
        let dW = sqrtDt * w(t)
        let halfdt = 0.5 * dt
        let halfdW = 0.5 * dW
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in 0..<auxiliaryState.count {
            auxiliaryState[i].copyElements(from: currentState[i])
            auxiliaryState[i].add(fty0[i], scaling: dt)
            auxiliaryState[i].add(gty0[i], scaling: dW)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        
        for i in 0..<currentState.count {
            currentState[i].add(fty0[i], scaling: halfdt)
            currentState[i].add(ftyAux[i], scaling: halfdt)
            currentState[i].add(gty0[i], scaling: halfdW)
            currentState[i].add(gtyAux[i], scaling: halfdW)
        }
        
        t += dt
    }
}
