//
//  UniqueSRK2Solver.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 18.5.2026.
//

import Numerics
import NumericsExtensions
import DequeModule

/*
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
 */

public protocol UniqueSDESolverState: ~Copyable {
    associatedtype NoiseType
    
    //var norm: Double { get }
    
    //mutating func assign(_ a: borrowing Self)
    mutating func assign(_ a: borrowing Self, multiplied: Double)
    mutating func add(_ a: borrowing Self, multiplied: Double)
    mutating func add(_ a: borrowing Self)
    mutating func add(_ a: borrowing Self, multiplied dtSqrt: Double, noise: borrowing NoiseType)
    mutating func assign(_ base: borrowing Self, adding direction: borrowing Self)
    //mutating func assign(_ base: borrowing Self, adding direction: borrowing Self, multipliedBy c: Double)
    mutating func assign(_ base: borrowing Self, adding direction: borrowing Self, multipliedBy dtSqrt: Double, noise: borrowing NoiseType)
    mutating func scale(by: Double)
    //func distance(to: borrowing Self) -> Double
}

public struct UniqueSRK2Solver<T: ~Copyable, NoiseType>: ~Copyable, ~Escapable {
    @_transparent
    @inlinable
    public var t: Double { _t }
    
    @usableFromInline
    internal var _t: Double
    
    public let dt: Double
    
    @usableFromInline
    internal let sqrtDt: Double
    
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
    internal var temporary: T
    
#if swift(>=6.4)
    #error("Use UniqueArray<NoiseType> or RigidArray<NoiseType>")
#endif
    @usableFromInline
    internal var diffusionSpace: UnsafeMutableBufferPointer<T>
    
    @usableFromInline
    internal var noiseSpace: UnsafeMutableBufferPointer<NoiseType>
    
    @_lifetime(borrow owner)
    @inlinable
    public init(
        t0: Double,
        initialState: consuming T,
        k1: consuming T,
        k2: consuming T,
        temporary: consuming T,
        diffusionSpace: consuming UnsafeMutableBufferPointer<T>,
        noiseSpace: consuming UnsafeMutableBufferPointer<NoiseType>,
        dt: Double, owner: Void = ()
    ) {
        precondition(diffusionSpace.count == noiseSpace.count, "Diffusion and noisespace must be the same size")
        self._t = t0
        self.dt = dt
        self.sqrtDt = dt.squareRoot()
        self.y = initialState
        self.k1 = k1
        self.k2 = k2
        self.temporary = temporary
        self.diffusionSpace = diffusionSpace
        self.noiseSpace = noiseSpace
    }
    
    @_lifetime(borrow owner)
    @inlinable
    public init(
        t0: Double,
        initialState: T,
        diffusionSpace: consuming UnsafeMutableBufferPointer<T>,
        noiseSpace: consuming UnsafeMutableBufferPointer<NoiseType>,
        dt: Double, owner: Void = ()
    ) where T: Copyable {
        self._t = t0
        self.dt = dt
        self.sqrtDt = dt.squareRoot()
        self.y = initialState
        self.k1 = copy initialState
        self.k2 = copy initialState
        self.temporary = copy initialState
        self.diffusionSpace = diffusionSpace
        self.noiseSpace = noiseSpace
    }
    
    @inlinable
    public mutating func reset(initialState: consuming T, t0: Double) {
        self.y = initialState
        self._t = t0
        self.stepCount = 0
    }
    
    @inlinable
    deinit {
        diffusionSpace.deinitialize()
        diffusionSpace.deallocate()
        noiseSpace.deinitialize()
        noiseSpace.deallocate()
    }
}

public extension UniqueSRK2Solver where T: UniqueSDESolverState, T.NoiseType == NoiseType {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1.scale(by: dt)
        for i in diffusionSpan.indices {
            k1.add(diffusionSpan[unchecked: i], multiplied: sqrtDt, noise: noiseSpan[unchecked: i])
        }
        temporary.assign(y, adding: k1)
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2.scale(by: 0.5 * dt)
        for i in diffusionSpan.indices {
            k2.add(diffusionSpan[unchecked: i], multiplied: sqrtDt * 0.5, noise: noiseSpan[unchecked: i])
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y.add(k1, multiplied: 0.5)
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y.add(k2)
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<Double, Double> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1 *= dt
        for i in diffusionSpan.indices {
            k1 += diffusionSpan[unchecked: i] * sqrtDt * noiseSpan[unchecked: i]
        }
        temporary = y + k1
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2 *= 0.5 * dt
        for i in diffusionSpan.indices {
            k2 += diffusionSpan[unchecked: i] * sqrtDt * 0.5 * noiseSpan[unchecked: i]
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y += 0.5 * k1
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y += k2
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<Complex<Double>, Complex<Double>> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1 *= dt
        for i in diffusionSpan.indices {
            k1 += diffusionSpan[unchecked: i] * sqrtDt * noiseSpan[unchecked: i]
        }
        temporary = y + k1
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2 *= 0.5 * dt
        for i in diffusionSpan.indices {
            k2 += diffusionSpan[unchecked: i] * sqrtDt * 0.5 * noiseSpan[unchecked: i]
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y += 0.5 * k1
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y += k2
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<Vector<Double>, Double> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1.multiply(by: dt)
        for i in diffusionSpan.indices {
            k1.add(diffusionSpan[unchecked: i], multiplied: sqrtDt * noiseSpan[unchecked: i])
        }
        temporary.copyComponents(from: y)
        temporary.add(k1)
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2.multiply(by: 0.5 * dt)
        for i in diffusionSpan.indices {
            k2.add(diffusionSpan[unchecked: i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: i])
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y.add(k1, multiplied: 0.5)
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y.add(k2)
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<Vector<Complex<Double>>, Complex<Double>> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1.multiply(by: dt)
        for i in diffusionSpan.indices {
            k1.add(diffusionSpan[unchecked: i], multiplied: sqrtDt * noiseSpan[unchecked: i])
        }
        temporary.copyComponents(from: y)
        temporary.add(k1)
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2.multiply(by: 0.5 * dt)
        for i in diffusionSpan.indices {
            k2.add(diffusionSpan[unchecked: i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: i])
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y.add(k1, multiplied: 0.5)
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y.add(k2)
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<Matrix<Double>, Double> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1.multiply(by: dt)
        for i in diffusionSpan.indices {
            k1.add(diffusionSpan[unchecked: i], multiplied: sqrtDt * noiseSpan[unchecked: i])
        }
        temporary.copyElements(from: y)
        temporary.add(k1)
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2.multiply(by: 0.5 * dt)
        for i in diffusionSpan.indices {
            k2.add(diffusionSpan[unchecked: i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: i])
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y.add(k1, multiplied: 0.5)
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y.add(k2)
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<Matrix<Complex<Double>>, Complex<Double>> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        k1.multiply(by: dt)
        for i in diffusionSpan.indices {
            k1.add(diffusionSpan[unchecked: i], multiplied: sqrtDt * noiseSpan[unchecked: i])
        }
        temporary.copyElements(from: y)
        temporary.add(k1)
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        k2.multiply(by: 0.5 * dt)
        for i in diffusionSpan.indices {
            k2.add(diffusionSpan[unchecked: i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: i])
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        y.add(k1, multiplied: 0.5)
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        y.add(k2)
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<[Double], Double> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        let indices = y.indices
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        for i in indices {
            k1[i] *= dt
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k1[i] += diffusionSpan[unchecked: j][i] * sqrtDt * noiseSpan[unchecked: j]
            }
        }
        
        for i in indices {
            temporary[i] = y[i] + k1[i]
        }
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        for i in indices {
            k2[i] *= 0.5 * dt
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k2[i] += diffusionSpan[unchecked: j][i] * sqrtDt * 0.5 * noiseSpan[unchecked: j]
            }
        }
        
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        for i in indices {
            y[i] += 0.5 * k1[i] + k2[i]
        }
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<[Complex<Double>], Complex<Double>> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        let indices = y.indices
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        for i in indices {
            k1[i] *= dt
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k1[i] += diffusionSpan[unchecked: j][i] * sqrtDt * noiseSpan[unchecked: j]
            }
        }
        for i in indices {
            temporary[i] = y[i] + k1[i]
        }
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        for i in indices {
            k2[i] *= 0.5 * dt
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k2[i] += diffusionSpan[unchecked: j][i] * sqrtDt * 0.5 * noiseSpan[unchecked: j]
            }
        }
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        for i in indices {
            y[i] += 0.5 * k1[i] + k2[i]
        }
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<[Vector<Double>], Double> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        let indices = y.indices
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        for i in indices {
            k1[i].multiply(by: dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k1[i].add(diffusionSpan[unchecked: j][i], multiplied: sqrtDt * noiseSpan[unchecked: j])
            }
        }
        for i in indices {
            temporary[i].copyComponents(from: y[i])
            temporary[i].add(k1[i])
        }
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        for i in indices {
            k2[i].multiply(by: 0.5 * dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k2[i].add(diffusionSpan[unchecked: j][i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: j])
            }
        }
        
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        for i in indices {
            y[i].add(k1[i], multiplied: 0.5)
            y[i].add(k2[i])
        }
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<[Vector<Complex<Double>>], Complex<Double>> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        let indices = y.indices
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        for i in indices {
            k1[i].multiply(by: dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k1[i].add(diffusionSpan[unchecked: j][i], multiplied: sqrtDt * noiseSpan[unchecked: j])
            }
        }
        for i in indices {
            temporary[i].copyComponents(from: y[i])
            temporary[i].add(k1[i])
        }
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        for i in indices {
            k2[i].multiply(by: 0.5 * dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k2[i].add(diffusionSpan[unchecked: j][i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: j])
            }
        }
        
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        for i in indices {
            y[i].add(k1[i], multiplied: 0.5)
            y[i].add(k2[i])
        }
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<[Matrix<Double>], Double> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        let indices = y.indices
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        for i in indices {
            k1[i].multiply(by: dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k1[i].add(diffusionSpan[unchecked: j][i], multiplied: sqrtDt * noiseSpan[unchecked: j])
            }
        }
        for i in indices {
            temporary[i].copyElements(from: y[i])
            temporary[i].add(k1[i])
        }
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        for i in indices {
            k2[i].multiply(by: 0.5 * dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k2[i].add(diffusionSpan[unchecked: j][i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: j])
            }
        }
        
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        for i in indices {
            y[i].add(k1[i], multiplied: 0.5)
            y[i].add(k2[i])
        }
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}

public extension UniqueSRK2Solver<[Matrix<Complex<Double>>], Complex<Double>> {
    @inlinable
    mutating func step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
        yielding body: (_ t: Double, _ state: borrowing T) -> Void
    ) {
        defer { stepCount &+= 1 }
        if stepCount == 0 {
            return body(t, y)
        }
        _step(drift, diffusions, noises)
        body(t, y)
    }
    
    @inlinable
    internal mutating func _step(
        _ drift: (_ t: Double, _ state: borrowing T, _ result: inout T) -> Void,
        _ diffusions: (_ t: Double, _ state: borrowing T, _ result: inout MutableSpan<T>) -> Void,
        _ noises: (_ t: Double, _ result: inout MutableSpan<NoiseType>) -> Void,
    ) {
        let indices = y.indices
        var noiseSpan = noiseSpace.mutableSpan
        var diffusionSpan = diffusionSpace.mutableSpan
        let t0 = _t
        
        noises(t0, &noiseSpan)
        drift(t0, y, &k1)
        diffusions(t0, y, &diffusionSpan)
        for i in indices {
            k1[i].multiply(by: dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k1[i].add(diffusionSpan[unchecked: j][i], multiplied: sqrtDt * noiseSpan[unchecked: j])
            }
        }
        for i in indices {
            temporary[i].copyElements(from: y[i])
            temporary[i].add(k1[i])
        }
        drift(t0 + dt, temporary, &k2)
        diffusions(t0 + dt, temporary, &diffusionSpan)
        
        for i in indices {
            k2[i].multiply(by: 0.5 * dt)
        }
        for i in indices {
            for j in diffusionSpan.indices {
                k2[i].add(diffusionSpan[unchecked: j][i], multiplied: 0.5 * sqrtDt * noiseSpan[unchecked: j])
            }
        }
        
        // k1 = dt * f(t, y) + sqrtDt * \sum g_i(t, y) * W_i[t]
        for i in indices {
            y[i].add(k1[i], multiplied: 0.5)
            y[i].add(k2[i])
        }
        // k2 = 0.5 * (dt * f(t + dt, k1) + sqrtDt * \sum g_i(t + dt, k1) * W_i[t])
        // y_new = 0.5 * k1 + k2
        //       = y_old + 0.5 * (f(t, y) + f(t + dt, y_aux))
        //               + 0.5 * \sum_i (g_i(t, y) + g_i(t + dt, y_aux)) * W_i[t]
        _t += dt
    }
}
