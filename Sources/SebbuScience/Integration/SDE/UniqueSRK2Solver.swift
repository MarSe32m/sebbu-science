//
//  UniqueSRK2Solver.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 18.5.2026.
//

import Numerics
import NumericsExtensions
import DequeModule

public struct UniqueSRK2Solver<
    State: ~Copyable & FixedStepSDESolverState,
    RHS: ~Copyable & ~Escapable & SDERHSFunction
>: ~Copyable, ~Escapable
where RHS.State == State, RHS.NoiseType == State.NoiseType {

    public var t: Double
    public var dt: Double

    @usableFromInline
    internal var rhs: RHS

    @usableFromInline
    internal var drift0: State

    @usableFromInline
    internal var drift1: State

    @usableFromInline
    internal var noise0: State

    @usableFromInline
    internal var noise1: State

    @usableFromInline
    internal var temporary: State

    @usableFromInline
    internal var noises: MutableSpan<State.NoiseType>

    @_lifetime(copy rhs, copy noises)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        rhs: consuming RHS,
        drift0: consuming State,
        drift1: consuming State,
        noise0: consuming State,
        noise1: consuming State,
        temporary: consuming State,
        noises: consuming MutableSpan<State.NoiseType>
    ) {
        precondition(dt > .zero, "Time-step must be positive")

        self.t = t
        self.dt = dt
        self.rhs = rhs
        self.drift0 = drift0
        self.drift1 = drift1
        self.noise0 = noise0
        self.noise1 = noise1
        self.temporary = temporary
        self.noises = noises
    }

    @inlinable
    public mutating func step(y: inout State) -> Double {
        let t0 = t
        let h = dt
        let t1 = t0 + h
        let sqrtH = h.squareRoot()

        rhs.sampleWhiteNoise(t: t0, noises: &noises)

        rhs.drift(t: t0, y: y, into: &drift0)

        noise0.zero()
        for i in noises.indices {
            rhs.diffusion(
                t: t0,
                y: y,
                channel: i,
                into: &temporary
            )

            temporary.scale(by: noises[unchecked: i])
            noise0.add(temporary)
        }

        // temporary = predictor
        //           = y_n + h * drift0 + sqrt(h) * noise0
        temporary.assign(y, adding: drift0, multipliedBy: h)
        temporary.add(noise0, multiplied: sqrtH)

        y.add(drift0, multiplied: 0.5 * h)
        y.add(noise0, multiplied: 0.5 * sqrtH)

        rhs.drift(t: t1, y: temporary, into: &drift1)

        noise1.zero()

        for i in noises.indices {
            rhs.diffusion(
                t: t1,
                y: temporary,
                channel: i,
                into: &noise0 // reuse noise0 as scratch
            )

            noise0.scale(by: noises[unchecked: i])
            noise1.add(noise0)
        }

        // Second half of corrector
        y.add(drift1, multiplied: 0.5 * h)
        y.add(noise1, multiplied: 0.5 * sqrtH)

        t = t1
        return t
    }
}

/*
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
*/
