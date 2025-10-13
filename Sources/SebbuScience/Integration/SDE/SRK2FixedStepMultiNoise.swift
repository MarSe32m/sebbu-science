//
//  SRK2FixedStepMultiNoise.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics
import NumericsExtensions
import DequeModule

// Method based on the improved Euler/Heun method: https://arxiv.org/pdf/1210.0933
// This is the Stratonovich version!
public struct SRK2FixedStepMultiNoise<T, NoiseType> {
    public var t: Double
    public let dt: Double
    
    @usableFromInline
    internal let sqrtDt: Double
    
    public var currentState: T
    
    @usableFromInline
    internal var stepCount: Int = 0
    
    // Drift term
    @usableFromInline
    internal let f: (_ t: Double, _ state: T) -> T
    
    // Diffusion terms
    @usableFromInline
    internal let g: [(_ t: Double, _ state: T) -> T]
    
    // White noises
    @usableFromInline
    internal let w: [(_ t: Double) -> NoiseType]
    
    @usableFromInline
    internal var auxiliaryState: T
    
    @usableFromInline
    internal var gty0Cache: T
    
    @inlinable
    public init(initialState: T, t0: Double, dt: Double, f: @escaping (_ t: Double, _ currentState: T) -> T, g: [(_ t: Double, _ currentState: T) -> T], w: [(Double) -> NoiseType]) {
        precondition(g.count == w.count, "The number of diffusion functions must equal the number of white noises.")
        self.t = t0
        self.dt = dt
        self.sqrtDt = dt.squareRoot()
        self.currentState = initialState
        self.auxiliaryState = initialState
        self.gty0Cache = initialState
        self.f = f
        self.g = g
        self.w = w
    }
    
    public mutating func reset(initialState: T, t0: Double) {
        self.currentState = initialState
        self.t = t0
        self.stepCount = 0
    }
}

extension SRK2FixedStepMultiNoise<Double, Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let fty0 = f(t, y0)
        var gty0: T = .zero
        for i in g.indices {
            gty0 += g[i](t, y0) * w[i](t)
        }
        let yAux = y0 + fty0 * dt + gty0 * sqrtDt
        
        let fty1 = f(t + dt, yAux)
        var gty1: T = .zero
        for i in g.indices {
            gty1 += g[i](t + dt, yAux) * w[i](t)
        }
        currentState = y0 + 0.5 * (fty0 + fty1) * dt + 0.5 * (gty0 + gty1) * sqrtDt
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<[Double], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let dtPer2 = 0.5 * dt
        let sqrtDtPer2 = 0.5 * sqrtDt
        
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        for i in gty0Cache.indices { gty0Cache[i] = .zero }
        
        for j in g.indices {
            let gty0 = g[j](t, currentState) // Returns non-cachable and non-modifiable state!
            let dW = w[j](t)
            for i in gty0Cache.indices {
                gty0Cache[i] = Relaxed.multiplyAdd(gty0[i], dW, gty0Cache[i])
            }
        }
        
        for i in auxiliaryState.indices {
            auxiliaryState[i] = Relaxed.multiplyAdd(dt, fty0[i], currentState[i])
            auxiliaryState[i] = Relaxed.multiplyAdd(sqrtDt, gty0Cache[i], auxiliaryState[i])
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        for i in currentState.indices {
            currentState[i] = Relaxed.multiplyAdd(dtPer2, fty0[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer2, ftyAux[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(sqrtDtPer2, gty0Cache[i], currentState[i])
        }
        
        for j in g.indices {
            let gtyAux = g[j](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            let dW = w[j](t)
            for i in 0..<currentState.count {
                currentState[i] = Relaxed.multiplyAdd(Relaxed.product(sqrtDtPer2, dW), gtyAux[i], currentState[i])
            }
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<Complex<Double>, Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let y0 = currentState
        let fty0 = f(t, y0)
        var gty0: T = .zero
        for i in g.indices {
            gty0 += g[i](t, y0) * w[i](t)
        }
        let yAux = y0 + fty0 * dt + gty0 * sqrtDt
        
        let fty1 = f(t + dt, yAux)
        var gty1: T = .zero
        for i in g.indices {
            gty1 += g[i](t + dt, yAux) * w[i](t)
        }
        currentState = y0 + 0.5 * (fty0 + fty1) * dt + 0.5 * (gty0 + gty1) * sqrtDt
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<[Complex<Double>], Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let dtPer2 = 0.5 * dt
        let sqrtDtPer2 = 0.5 * sqrtDt
        
        let fty0 = f(t, currentState)
        
        for j in g.indices {
            let gty0 = g[j](t, currentState) // Returns non-cachable and non-modifiable state!
            let dW = w[j](t)
            for i in gty0Cache.indices {
                gty0Cache[i] = j == 0 ? Relaxed.product(gty0[i], dW) : Relaxed.multiplyAdd(gty0[i], dW, gty0Cache[i])
            }
        }
        
        for i in auxiliaryState.indices {
            auxiliaryState[i] = Relaxed.multiplyAdd(dt, fty0[i], currentState[i])
            auxiliaryState[i] = Relaxed.multiplyAdd(sqrtDt, gty0Cache[i], auxiliaryState[i])
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        for i in currentState.indices {
            currentState[i] = Relaxed.multiplyAdd(dtPer2, fty0[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(dtPer2, ftyAux[i], currentState[i])
            currentState[i] = Relaxed.multiplyAdd(sqrtDtPer2, gty0Cache[i], currentState[i])
        }
        
        for j in g.indices {
            let gtyAux = g[j](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            let dW = Relaxed.product(w[j](t), sqrtDtPer2)
            for i in 0..<currentState.count {
                currentState[i] = Relaxed.multiplyAdd(dW, gtyAux[i], currentState[i])
            }
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<Vector<Double>, Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        gty0Cache.zeroComponents()
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            gty0Cache.add(gty0, multiplied: dW)
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyComponents(from: currentState)
        auxiliaryState.add(fty0, multiplied: dt)
        auxiliaryState.add(gty0Cache, multiplied: halfSqrtDt)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        currentState.add(fty0, multiplied: halfdt)
        currentState.add(ftyAux, multiplied: halfdt)
        currentState.add(gty0Cache, multiplied: halfSqrtDt)
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            currentState.add(gtyAux, multiplied: dW)
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<[Vector<Double>], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        for i in gty0Cache.indices {
            gty0Cache[i].zeroComponents()
        }
        
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            for j in gty0Cache.indices {
                gty0Cache[j].add(gty0[j], multiplied: dW)
            }
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in auxiliaryState.indices {
            auxiliaryState[i].copyComponents(from: currentState[i])
            auxiliaryState[i].add(fty0[i], multiplied: dt)
            auxiliaryState[i].add(gty0Cache[i], multiplied: halfSqrtDt)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        for i in currentState.indices {
            currentState[i].add(fty0[i], multiplied: halfdt)
            currentState[i].add(ftyAux[i], multiplied: halfdt)
            currentState[i].add(gty0Cache[i], multiplied: halfSqrtDt)
        }
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            for j in gtyAux.indices {
                currentState[j].add(gtyAux[j], multiplied: dW)
            }
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<Vector<Complex<Double>>, Complex<Double>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        gty0Cache.zeroComponents()
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            gty0Cache.add(gty0, multiplied: dW)
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyComponents(from: currentState)
        auxiliaryState.add(fty0, multiplied: dt)
        auxiliaryState.add(gty0Cache, multiplied: halfSqrtDt)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        currentState.add(fty0, multiplied: halfdt)
        currentState.add(ftyAux, multiplied: halfdt)
        currentState.add(gty0Cache, multiplied: halfSqrtDt)
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            currentState.add(gtyAux, multiplied: dW)
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<[Vector<Complex<Double>>], Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        for i in gty0Cache.indices {
            gty0Cache[i].zeroComponents()
        }
        
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            for j in gty0Cache.indices {
                gty0Cache[j].add(gty0[j], multiplied: dW)
            }
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in auxiliaryState.indices {
            auxiliaryState[i].copyComponents(from: currentState[i])
            auxiliaryState[i].add(fty0[i], multiplied: dt)
            auxiliaryState[i].add(gty0Cache[i], multiplied: halfSqrtDt)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        for i in currentState.indices {
            currentState[i].add(fty0[i], multiplied: halfdt)
            currentState[i].add(ftyAux[i], multiplied: halfdt)
            currentState[i].add(gty0Cache[i], multiplied: halfSqrtDt)
        }
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            for j in gtyAux.indices {
                currentState[j].add(gtyAux[j], multiplied: dW)
            }
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<Matrix<Double>, Double> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        gty0Cache.zeroElements()
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            gty0Cache.add(gty0, multiplied: dW)
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyElements(from: currentState)
        auxiliaryState.add(fty0, multiplied: dt)
        auxiliaryState.add(gty0Cache, multiplied: sqrtDt)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        currentState.add(fty0, multiplied: halfdt)
        currentState.add(ftyAux, multiplied: halfdt)
        currentState.add(gty0Cache, multiplied: halfSqrtDt)
        
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            currentState.add(gtyAux, multiplied: dW)
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<[Matrix<Double>], Double> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        for i in gty0Cache.indices {
            gty0Cache[i].zeroElements()
        }
        
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            for j in gty0Cache.indices {
                gty0Cache[j].add(gty0[j], multiplied: dW)
            }
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in auxiliaryState.indices {
            auxiliaryState[i].copyElements(from: currentState[i])
            auxiliaryState[i].add(fty0[i], multiplied: dt)
            auxiliaryState[i].add(gty0Cache[i], multiplied: sqrtDt)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        for i in currentState.indices {
            currentState[i].add(fty0[i], multiplied: halfdt)
            currentState[i].add(ftyAux[i], multiplied: halfdt)
            currentState[i].add(gty0Cache[i], multiplied: halfSqrtDt)
        }
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            for j in gtyAux.indices {
                currentState[j].add(gtyAux[j], multiplied: dW)
            }
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<Matrix<Complex<Double>>, Complex<Double>> {
    @inlinable
    @inline(__always)
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        gty0Cache.zeroElements()
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            gty0Cache.add(gty0, multiplied: dW)
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        auxiliaryState.copyElements(from: currentState)
        auxiliaryState.add(fty0, multiplied: dt)
        auxiliaryState.add(gty0Cache, multiplied: sqrtDt)
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        currentState.add(fty0, multiplied: halfdt)
        currentState.add(ftyAux, multiplied: halfdt)
        currentState.add(gty0Cache, multiplied: halfSqrtDt)
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            currentState.add(gtyAux, multiplied: dW)
        }
        t += dt
    }
}

extension SRK2FixedStepMultiNoise<[Matrix<Complex<Double>>], Complex<Double>> {
    @inlinable
    public mutating func step() -> (t: Double, element: T) {
        defer { stepCount &+= 1 }
        if stepCount == 0 { return (t, currentState) }
        _step()
        return (t, currentState)
    }
    
    @inlinable
    internal mutating func _step() {
        let halfdt = 0.5 * dt
        let halfSqrtDt = 0.5 * sqrtDt
        let fty0 = f(t, currentState) // Returns non-cachable and non-modifiable state!
        
        for i in gty0Cache.indices {
            gty0Cache[i].zeroElements()
        }
        
        for i in g.indices {
            let dW = w[i](t)
            let gty0 = g[i](t, currentState) // Returns non-cachable and non-modifiable state!
            for j in gty0Cache.indices {
                gty0Cache[j].add(gty0[j], multiplied: dW)
            }
        }
        
        //yAux = currentState + dt * fty0 + dW * gty0
        for i in auxiliaryState.indices {
            auxiliaryState[i].copyElements(from: currentState[i])
            auxiliaryState[i].add(fty0[i], multiplied: dt)
            auxiliaryState[i].add(gty0Cache[i], multiplied: sqrtDt)
        }
        
        let ftyAux = f(t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
        for i in currentState.indices {
            currentState[i].add(fty0[i], multiplied: halfdt)
            currentState[i].add(ftyAux[i], multiplied: halfdt)
            currentState[i].add(gty0Cache[i], multiplied: halfSqrtDt)
        }
        for i in g.indices {
            let dW = Relaxed.product(w[i](t), halfSqrtDt)
            let gtyAux = g[i](t + dt, auxiliaryState) // Returns non-cachable and non-modifiable state!
            for j in gtyAux.indices {
                currentState[j].add(gtyAux[j], multiplied: dW)
            }
        }
        t += dt
    }
}
