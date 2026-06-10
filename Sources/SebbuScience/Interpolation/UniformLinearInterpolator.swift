//
//  UniformLinearInterpolator.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.6.2026.
//

import Numerics

@frozen
public struct UniformLinearInterpolator<Element> {
    public let start: Double
    public let step: Double
    @usableFromInline
    internal let inverseStep: Double
    public let y: [Element]
    
    @inlinable
    public init(start: Double, step: Double, y: [Element]) {
        self.start = start
        self.step = step
        self.inverseStep = 1.0 / step
        self.y = y
    }
}

extension UniformLinearInterpolator: Sendable where Element: Sendable {}

public extension UniformLinearInterpolator<Double> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Double {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Double {
        if t <= start { return y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k >= y.count - 1 { return y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        return (1.0 - theta) * y[k] + theta * y[k + 1]
    }
}

public extension UniformLinearInterpolator<Complex<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Complex<Double> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Complex<Double> {
        if t <= start { return y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k >= y.count - 1 { return y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        return (1.0 - theta) * y[k] + theta * y[k + 1]
    }
}

public extension UniformLinearInterpolator<Vector<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Vector<Double> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Vector<Double> {
        if t <= start { return y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k >= y.count - 1 { return y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * y[k]
        result.add(y[k + 1], multiplied: theta)
        return result
    }
}

public extension UniformLinearInterpolator<Vector<Complex<Double>>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Vector<Complex<Double>> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Vector<Complex<Double>> {
        if t <= start { return y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k >= y.count - 1 { return y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * y[k]
        result.add(y[k + 1], multiplied: theta)
        return result
    }
}

public extension UniformLinearInterpolator<Matrix<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Matrix<Double> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Matrix<Double> {
        if t <= start { return y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k >= y.count - 1 { return y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * y[k]
        result.add(y[k + 1], multiplied: theta)
        return result
    }
}

public extension UniformLinearInterpolator<Matrix<Complex<Double>>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Matrix<Complex<Double>> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Matrix<Complex<Double>> {
        if t <= start { return y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k >= y.count - 1 { return y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * y[k]
        result.add(y[k + 1], multiplied: theta)
        return result
    }
}
