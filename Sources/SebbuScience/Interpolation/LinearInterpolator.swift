//
//  LinearInterpolator.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

import Numerics

public struct LinearInterpolator<Element> {
    public let x: [Double]
    public let y: [Element]
    
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
    func callAsFunction(_ t: Double) -> Double {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return (1 - t_) * y[k] + t_ * y[k + 1]
    }
    
    @inlinable
    func sample(_ t: Double) -> Element {
        self(t)
    }
}

public extension LinearInterpolator<Complex<Double>> {
    @inlinable
    func callAsFunction(_ t: Double) -> Element {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return (1 - t_) * y[k] + t_ * y[k + 1]
    }
    
    @inlinable
    func sample(_ t: Double) -> Element {
        self(t)
    }
}

public extension LinearInterpolator<Vector<Double>> {
    @inlinable
    func callAsFunction(_ t: Double) -> Element {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], scaling: _t)
        return result
    }
    
    @inlinable
    func sample(_ t: Double) -> Element {
        self(t)
    }
}

public extension LinearInterpolator<Vector<Complex<Double>>> {
    @inlinable
    func callAsFunction(_ t: Double) -> Element {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], scaling: _t)
        return result
    }
    
    @inlinable
    func sample(_ t: Double) -> Element {
        self(t)
    }
}

public extension LinearInterpolator<Matrix<Double>> {
    @inlinable
    func callAsFunction(_ t: Double) -> Element {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], multiplied: _t)
        return result
    }
    
    @inlinable
    func sample(_ t: Double) -> Element {
        self(t)
    }
}

public extension LinearInterpolator<Matrix<Complex<Double>>> {
    @inlinable
    func callAsFunction(_ t: Double) -> Element {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let _t = (t - x[k]) / (x[k + 1] - x[k])
        var result = (1 - _t) * y[k]
        result.add(y[k + 1], multiplied: _t)
        return result
    }
    
    @inlinable
    func sample(_ t: Double) -> Element {
        self(t)
    }
}
