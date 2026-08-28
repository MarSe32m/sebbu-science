//
//  UniformDequeLinearInterpolator.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 28.8.2026.
//

import Numerics
import DequeModule

@frozen
public struct UniformDequeLinearInterpolator<Element> {
    @usableFromInline
    internal var _start: Double
        
    public let step: Double
    
    @usableFromInline
    internal let inverseStep: Double
    
    @usableFromInline
    internal var _y: Deque<Element>
    
    @inlinable
    public var start: Double { _start }
    
    @inlinable
    public var end: Double { _start + Double(_y.count - 1) * step }
    
    @inlinable
    public var count: Int {
        _y.count
    }
    
    @inlinable
    public init(start: Double, step: Double, y: [Element]) {
        precondition(step > 0, "step must be more than zero")
        precondition(!y.isEmpty, "`y` must not be empty")
        self._start = start
        self.step = step
        self.inverseStep = 1.0 / step
        self._y = .init(y)
    }
    
    @inlinable
    public mutating func popFirst() -> Element? {
        if _y.count == 1 { return nil }
        _start += step
        return _y.popFirst()
    }
    
    @inlinable
    public mutating func popLast() -> Element? {
        if _y.count == 1 { return nil }
        _start -= step
        return _y.popLast()
    }
    
    @inlinable
    public mutating func prepend(_ element: Element) {
        _y.prepend(element)
        _start -= step
    }
    
    @inlinable
    public mutating func append(_ element: Element) {
        _y.append(element)
        _start += step
    }
}

public extension UniformDequeLinearInterpolator<Double> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Double? {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Double? {
        if t < _start { return nil }
        if t == _start { return _y[0] }
        let u = (t - _start) * inverseStep
        var k = Int(u)
        if k > _y.count - 1 { return nil }
        if k == _y.count - 1 { return _y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        return (1.0 - theta) * _y[k] + theta * _y[k + 1]
    }
}

public extension UniformDequeLinearInterpolator<Complex<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Complex<Double>? {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Complex<Double>? {
        if t < _start { return nil }
        if t == _start { return _y[0] }
        let u = (t - _start) * inverseStep
        var k = Int(u)
        if k > _y.count - 1 { return nil }
        if k == _y.count - 1 { return _y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        return (1.0 - theta) * _y[k] + theta * _y[k + 1]
    }
}

public extension UniformDequeLinearInterpolator<Vector<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Vector<Double>? {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Vector<Double>? {
        if t < _start { return nil }
        if t == _start { return _y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k > _y.count - 1 { return nil }
        if k == _y.count - 1 { return _y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * _y[k]
        result.add(_y[k + 1], multiplied: theta)
        return result
    }
}

public extension UniformDequeLinearInterpolator<Vector<Complex<Double>>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Vector<Complex<Double>>? {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Vector<Complex<Double>>? {
        if t < _start { return nil }
        if t == _start { return _y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k > _y.count - 1 { return nil }
        if k == _y.count - 1 { return _y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * _y[k]
        result.add(_y[k + 1], multiplied: theta)
        return result
    }
}

public extension UniformDequeLinearInterpolator<Matrix<Double>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Matrix<Double>? {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Matrix<Double>? {
        if t < _start { return nil }
        if t == _start { return _y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k > _y.count - 1 { return nil }
        if k == _y.count - 1 { return _y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * _y[k]
        result.add(_y[k + 1], multiplied: theta)
        return result
    }
}

public extension UniformDequeLinearInterpolator<Matrix<Complex<Double>>> {
    @inlinable
    @inline(always)
    func callAsFunction(_ t: Double) -> Matrix<Complex<Double>>? {
        sample(t)
    }
    
    @inlinable
    func sample(_ t: Double) -> Matrix<Complex<Double>>? {
        if t < _start { return nil }
        if t == _start { return _y[0] }
        let u = (t - start) * inverseStep
        var k = Int(u)
        if k > _y.count - 1 { return nil }
        if k == _y.count - 1 { return _y.last! }
        if k < 0 { k = 0 }
        let theta = u - Double(k)
        var result = (1.0 - theta) * _y[k]
        result.add(_y[k + 1], multiplied: theta)
        return result
    }
}
