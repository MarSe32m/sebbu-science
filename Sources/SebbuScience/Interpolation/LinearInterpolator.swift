//
//  LinearInterpolator.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

import Numerics

@frozen
public struct LinearInterpolator<Element> {
    public let x: [Double]
    public let y: [Element]
    
    @inlinable
    public init(x: [Double], y: [Element]) {
        precondition(
            {
                for i in 1..<x.count {
                    if x[i - 1] >= x[i] { return false }
                }
                return true
            }(),
            "The x-values must be in monotonically ascending order."
        )
        self.x = x
        self.y = y
    }
}

extension LinearInterpolator: Sendable where Element: Sendable {}

public extension LinearInterpolator<Double> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Double {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Double {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return (1 - t_) * y[k] + t_ * y[k + 1]
    }
}

public extension LinearInterpolator<Complex<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Complex<Double> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Complex<Double> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return (1 - t_) * y[k] + t_ * y[k + 1]
    }
}

public extension LinearInterpolator<Vector<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Vector<Double> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Vector<Double> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], multiplied: _t)
        return result
    }
}

public extension LinearInterpolator<Vector<Complex<Double>>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Vector<Complex<Double>> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Vector<Complex<Double>> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], multiplied: _t)
        return result
    }
}

public extension LinearInterpolator<Matrix<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Matrix<Double> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Matrix<Double> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], multiplied: _t)
        return result
    }
}

public extension LinearInterpolator<Matrix<Complex<Double>>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Matrix<Complex<Double>> {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Matrix<Complex<Double>> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], multiplied: _t)
        return result
    }
}
