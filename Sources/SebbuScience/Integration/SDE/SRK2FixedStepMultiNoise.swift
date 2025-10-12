////
////  SRK2FixedStep.swift
////  sebbu-science
////
////  Created by Sebastian Toivonen on 4.5.2025.
////
//
//import Numerics
//import NumericsExtensions
//import DequeModule
//
//// Method based on the improved Euler/Heun method: https://arxiv.org/pdf/1210.0933
//// This is the Stratonovich version!
//public struct SRK2FixedStepMultiNoise<T, NoiseType> {
//    public var t: Double
//    public let dt: Double
//    
//    @usableFromInline
//    internal let sqrtDt: Double
//    
//    public var currentState: T
//    
//    @usableFromInline
//    internal var borrowedState: T
//    
//    // Drift term
//    @usableFromInline
//    internal let f: (_ t: Double, _ state: T) -> T
//    
//    // Diffusion terms
//    @usableFromInline
//    internal let g: [(_ t: Double, _ state: T) -> T]
//    
//    // White noises
//    @usableFromInline
//    internal let w: [(_ t: Double) -> NoiseType]
//    
//    @usableFromInline
//    internal var auxiliaryState: T
//    
//    @usableFromInline
//    internal var gty0Cache: T
//    
//    @inlinable
//    public init(initialState: T, t0: Double, dt: Double, f: @escaping (_ t: Double, _ currentState: T) -> T, g: [(_ t: Double, _ currentState: T) -> T], w: [(Double) -> NoiseType]) {
//        precondition(g.count == w.count, "The number of diffusion functions must equal the number of white noises.")
//        self.t = t0
//        self.dt = dt
//        self.sqrtDt = dt.squareRoot()
//        self.currentState = initialState
//        self.borrowedState = initialState
//        self.auxiliaryState = initialState
//        self.gCache = initialState
//        self.f = f
//        self.g = g
//        self.w = w
//    }
//    
//    public mutating func reset(initialState: T, t0: Double) {
//        self.currentState = initialState
//        self.t = t0
//    }
//}
//
//extension SRK2FixedStepMultiNoise<Double, Double> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let y0 = currentState
//        let fty0 = f(t, y0)
//        var gty0: Double = .zero
//        for i in g.indices {
//            gty0 += g[i](t, y0) * w[i](t)
//        }
//        let yAux = y0 + fty0 * dt + gty0 * sqrtDt
//        
//        let fty1 = f(t + dt, yAux)
//        var gty1: Double = .zero
//        for i in g.indices {
//            gty1 += g[i](t + dt, yAux) * w[i](t)
//        }
//        currentState = y0 + 0.5 * (fty0 + fty1) * dt + 0.5 * (gty0 + gty1) * sqrtDt
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<[Double], Double> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dtPer2 = 0.5 * dt
//        let sqrtDtPer2 = 0.5 * sqrtDt
//        
//        let fty0 = f(t, currentState)
//        
//        for j in g.indices {
//            let gty0 = g[j](t, currentState)
//            let dW = w[j](t)
//            for i in gty0Cache.indices {
//                gty0Cache[i] = j == 0 ? Relaxed.product(gty0[i], dW) : Relaxed.multiplyAdd(gty0[i], dW, gty0Cache[i])
//            }
//        }
//        
//        for i in auxiliaryState.indices {
//            auxiliaryState[i] = Relaxed.multiplyAdd(dt, fty0[i], currentState[i])
//            auxiliaryState[i] = Relaxed.multiplyAdd(sqrtDt, gty0Cache[i], auxiliaryState[i])
//        }
//        
//        let ftyAux = f(t + dt, auxiliaryState)
//        for i in currentState.indices {
//            currentState[i] = Relaxed.multiplyAdd(dtPer2, fty0[i], currentState[i])
//            currentState[i] = Relaxed.multiplyAdd(dtPer2, ftyAux[i], currentState[i])
//        }
//        
//        for j in g.indices {
//            let gtyAux = g[j](t + dt, auxiliaryState)
//            let dW = w[j](t)
//            for i in 0..<currentState.count {
//                currentState[i] = Relaxed.multiplyAdd(sqrtDtPer2, gty0Cache[i], currentState[i])
//                currentState[i] = Relaxed.multiplyAdd(Relaxed.product(sqrtDtPer2, dW), gtyAux[i], currentState[i])
//            }
//        }
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<Complex<Double>, Complex<Double>> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        swap(&borrowedState, &currentState)
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let y0 = currentState
//        let dW = sqrtDt * w(t)
//        let fty0 = f(t, y0)
//        let gty0 = g(t, y0)
//        let yAux = y0 + dt * fty0 + gty0 * dW
//        let ftyAux = f(t + dt, yAux)
//        let gtyAux = g(t + dt, yAux)
//        currentState += 0.5 * dt * (fty0 + ftyAux)
//        currentState += 0.5 * (gty0 + gtyAux) * dW
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<[Complex<Double>], Complex<Double>> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let dtPer2 = 0.5 * dt
//        let dWPer2 = 0.5 * dW
//        let fty0 = f(t, currentState)
//        let gty0 = g(t, currentState)
//        for i in 0..<auxiliaryState.count {
//            auxiliaryState[i] = Relaxed.multiplyAdd(dt, fty0[i], currentState[i])
//            auxiliaryState[i] = Relaxed.multiplyAdd(dW, gty0[i], auxiliaryState[i])
//        }
//        let ftyAux = f(t + dt, auxiliaryState)
//        let gtyAux = g(t + dt, auxiliaryState)
//        for i in 0..<currentState.count {
//            currentState[i] = Relaxed.multiplyAdd(dtPer2, fty0[i], currentState[i])
//            currentState[i] = Relaxed.multiplyAdd(dtPer2, ftyAux[i], currentState[i])
//            currentState[i] = Relaxed.multiplyAdd(dWPer2, gty0[i], currentState[i])
//            currentState[i] = Relaxed.multiplyAdd(dWPer2, gtyAux[i], currentState[i])
//        }
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<Vector<Double>, Double> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState.copyComponents(from: currentState)
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        //yAux = currentState + dt * fty0 + dW * gty0
//        auxiliaryState.copyComponents(from: currentState)
//        auxiliaryState.add(fty0, multiplied: dt)
//        auxiliaryState.add(gty0, multiplied: dW)
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        // currentState += halfdt * (fty0 + ftyAux) + halfdW * (gty0 + gtyAux)
//        currentState.add(fty0, multiplied: halfdt)
//        currentState.add(ftyAux, multiplied: halfdt)
//        currentState.add(gty0, multiplied: halfdW)
//        currentState.add(gtyAux, multiplied: halfdW)
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<[Vector<Double>], Double> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        //yAux = currentState + dt * fty0 + dW * gty0
//        for i in 0..<auxiliaryState.count {
//            auxiliaryState[i].copyComponents(from: currentState[i])
//            auxiliaryState[i].add(fty0[i], multiplied: dt)
//            auxiliaryState[i].add(gty0[i], multiplied: dW)
//        }
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        for i in 0..<currentState.count {
//            currentState[i].add(fty0[i], multiplied: halfdt)
//            currentState[i].add(ftyAux[i], multiplied: halfdt)
//            currentState[i].add(gty0[i], multiplied: halfdW)
//            currentState[i].add(gtyAux[i], multiplied: halfdW)
//        }
//        
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<Vector<Complex<Double>>, Complex<Double>> {
//    @inlinable
//    @inline(__always)
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState.copyComponents(from: currentState)
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        //yAux = currentState + dt * fty0 + dW * gty0
//        auxiliaryState.copyComponents(from: currentState)
//        auxiliaryState.add(fty0, multiplied: dt)
//        auxiliaryState.add(gty0, multiplied: dW)
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        // currentState += halfdt * (fty0 + ftyAux) + halfdW * (gty0 + gtyAux)
//        currentState.add(fty0, multiplied: halfdt)
//        currentState.add(ftyAux, multiplied: halfdt)
//        currentState.add(gty0, multiplied: halfdW)
//        currentState.add(gtyAux, multiplied: halfdW)
//        
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<[Vector<Complex<Double>>], Complex<Double>> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        //yAux = currentState + dt * fty0 + dW * gty0
//        for i in 0..<auxiliaryState.count {
//            auxiliaryState[i].copyComponents(from: currentState[i])
//            auxiliaryState[i].add(fty0[i], multiplied: dt)
//            auxiliaryState[i].add(gty0[i], multiplied: dW)
//        }
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        for i in 0..<currentState.count {
//            currentState[i].add(fty0[i], multiplied: halfdt)
//            currentState[i].add(ftyAux[i], multiplied: halfdt)
//            currentState[i].add(gty0[i], multiplied: halfdW)
//            currentState[i].add(gtyAux[i], multiplied: halfdW)
//        }
//        
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<Matrix<Double>, Double> {
//    @inlinable
//    @inline(__always)
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState.copyElements(from: currentState)
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        // yAux = currentState + dt * fty0 + dW * gty0
//        auxiliaryState.copyElements(from: currentState)
//        auxiliaryState.add(fty0, multiplied: dt)
//        auxiliaryState.add(gty0, multiplied: dW)
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        // currentState = halfdt * (fty0 + ftyAux) + halfDw * (gty0 + gtyAux)
//        currentState.add(fty0, multiplied: halfdt)
//        currentState.add(ftyAux, multiplied: halfdt)
//        currentState.add(gty0, multiplied: halfdW)
//        currentState.add(gtyAux, multiplied: halfdW)
//        
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<[Matrix<Double>], Double> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        //yAux = currentState + dt * fty0 + dW * gty0
//        for i in 0..<auxiliaryState.count {
//            auxiliaryState[i].copyElements(from: currentState[i])
//            auxiliaryState[i].add(fty0[i], multiplied: dt)
//            auxiliaryState[i].add(gty0[i], multiplied: dW)
//        }
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        for i in 0..<currentState.count {
//            currentState[i].add(fty0[i], multiplied: halfdt)
//            currentState[i].add(ftyAux[i], multiplied: halfdt)
//            currentState[i].add(gty0[i], multiplied: halfdW)
//            currentState[i].add(gtyAux[i], multiplied: halfdW)
//        }
//        
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<Matrix<Complex<Double>>, Complex<Double>> {
//    @inlinable
//    @inline(__always)
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState.copyElements(from: currentState)
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        // yAux = currentState + dt * fty0 + dW * gty0
//        auxiliaryState.copyElements(from: currentState)
//        auxiliaryState.add(fty0, multiplied: dt)
//        auxiliaryState.add(gty0, multiplied: dW)
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        // currentState = halfdt * (fty0 + ftyAux) + halfDw * (gty0 + gtyAux)
//        currentState.add(fty0, multiplied: halfdt)
//        currentState.add(ftyAux, multiplied: halfdt)
//        currentState.add(gty0, multiplied: halfdW)
//        currentState.add(gtyAux, multiplied: halfdW)
//        
//        t += dt
//    }
//}
//
//extension SRK2FixedStepMultiNoise<[Matrix<Complex<Double>>], Complex<Double>> {
//    @inlinable
//    public mutating func step() -> (t: Double, element: T) {
//        borrowedState = currentState
//        let result = (t, borrowedState)
//        _step()
//        return result
//    }
//    
//    @inlinable
//    internal mutating func _step() {
//        let dW = sqrtDt * w(t)
//        let halfdt = 0.5 * dt
//        let halfdW = 0.5 * dW
//        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
//        let gty0 = g(t, currentState) // Returns non-cachable and non-modifiable state!
//        
//        //yAux = currentState + dt * fty0 + dW * gty0
//        for i in 0..<auxiliaryState.count {
//            auxiliaryState[i].copyElements(from: currentState[i])
//            auxiliaryState[i].add(fty0[i], multiplied: dt)
//            auxiliaryState[i].add(gty0[i], multiplied: dW)
//        }
//        
//        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        let gtyAux = g(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
//        
//        for i in 0..<currentState.count {
//            currentState[i].add(fty0[i], multiplied: halfdt)
//            currentState[i].add(ftyAux[i], multiplied: halfdt)
//            currentState[i].add(gty0[i], multiplied: halfdW)
//            currentState[i].add(gtyAux[i], multiplied: halfdW)
//        }
//        
//        t += dt
//    }
//}
