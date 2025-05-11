//
//  CubicHermiteInterpolator.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

import Numerics
import SebbuCollections

public struct CubicHermiteSpline<Element> {
    public let x: [Double]
    
    public let y: [Element]
    
    @usableFromInline
    internal let m: [Element]
    
    @usableFromInline
    internal let a: [Element]
    
    @usableFromInline
    internal let b: [Element]
}

extension CubicHermiteSpline: Sendable where Element: Sendable {}

extension CubicHermiteSpline<Double> {
    @inlinable
    public init(x: [Double], y: [Double], tangents: [Double]) {
        precondition(!x.isEmpty, "The x-axis cannot be empty.")
        precondition(!y.isEmpty, "The y-axis cannot be empty.")
        precondition(x.count == y.count, "The x-axis and y-axis have to match in size.")
        for i in 1..<x.count {
            assert(x[i - 1] < x[i], "The x-axis needs to be monotonically increasing with no duplicates.")
        }
        self.x = x
        self.y = y
        self.m = tangents
        var a: [Double] = []
        var b: [Double] = []
        for i in 0..<x.count - 1 {
            let dx = x[i + 1] - x[i]
            a.append(2.0 * y[i] + dx * tangents[i] - 2.0 * y[i + 1] + dx * tangents[i + 1])
            b.append(-3.0 * y[i] + 3.0 * y[i + 1] - 2.0 * dx * tangents[i] - dx * tangents[i + 1])
        }
        a.append(0)
        b.append(0)
        self.a = a
        self.b = b
    }
    
    @inlinable
    public init(x: [Double], y: [Double]) {
        let m = (0..<x.count).map { k in
            if k == 0 {
                let yDiff = y[k + 1] - y[k]
                let xDiff = x[k + 1] - x[k]
                return yDiff / xDiff
            }
            if k == x.count - 1 {
                let yDiff = y[k] - y[k - 1]
                let xDiff = x[k] - x[k - 1]
                return yDiff / xDiff
            }
            
            let start = (y[k + 1] - y[k]) / (x[k + 1] - x[k])
            let end = (y[k] - y[k - 1]) / (x[k] - x[k - 1])
            return (start + end) / 2
        }
        self = .init(x: x, y: y, tangents: m)
    }
    
    @inlinable
    public subscript(_ t: Double) -> Double { sample(t) }
    
    @inlinable
    public subscript(_ t: [Double]) -> [Double] { sample(t) }
    
    @inlinable
    public func sample(_ t: Double) -> Double {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return p(k: k, t: t_)
    }
    
    @_transparent
    @usableFromInline
    internal func p(k: Int, t: Double) -> Double {
        assert(k >= 0 && k < x.count - 1)
        let t2 = t * t
        let t3 = t2 * t
        return t3 * a[k] + t2 * b[k] + t * m[k] + y[k]
    }
    
    @inlinable
    public func sample(_ t: [Double]) -> [Double] {
        t.betterMap { sample($0) }
    }
}

// Complex<Double>
extension CubicHermiteSpline<Complex<Double>> {
    @inlinable
    public init(x: [Double], y: [Complex<Double>], tangents: [Complex<Double>]) {
        precondition(!x.isEmpty, "The x-axis cannot be empty.")
        precondition(!y.isEmpty, "The y-axis cannot be empty.")
        precondition(x.count == y.count, "The x-axis and y-axis have to match in size.")
        for i in 1..<x.count {
            assert(x[i - 1] < x[i], "The x-axis needs to be monotonically increasing with no duplicates.")
        }
        self.x = x
        self.y = y
        self.m = tangents
        var a: [Complex<Double>] = []
        var b: [Complex<Double>] = []
        for i in 0..<x.count - 1 {
            let dx = x[i + 1] - x[i]
            var resA = 2.0 * y[i]
            resA += dx * tangents[i]
            resA -= 2.0 * y[i + 1]
            resA += dx * tangents[i + 1]
            a.append(resA)
            var resB = -3.0 * y[i]
            resB += 3.0 * y[i + 1]
            resB -= 2.0 * dx * tangents[i]
            resB -= dx * tangents[i + 1]
            b.append(resB)
        }
        a.append(.zero)
        b.append(.zero)
        self.a = a
        self.b = b
    }
    
    @inlinable
    public init(x: [Double], y: [Complex<Double>]) {
        let m = (0..<x.count).map { k in
            if k == 0 {
                let yDiff = y[k + 1] - y[k]
                let xDiff = x[k + 1] - x[k]
                return yDiff / xDiff
            }
            if k == x.count - 1 {
                let yDiff = y[k] - y[k - 1]
                let xDiff = x[k] - x[k - 1]
                return yDiff / xDiff
            }
            
            let start = (y[k + 1] - y[k]) / (x[k + 1] - x[k])
            let end = (y[k] - y[k - 1]) / (x[k] - x[k - 1])
            return (start + end) / 2.0
        }
        self = .init(x: x, y: y, tangents: m)
    }
    
    @inlinable
    public subscript(_ t: Double) -> Complex<Double> { sample(t) }
    
    @inlinable
    public subscript(_ t: [Double]) -> [Complex<Double>] { sample(t) }
    
    @inlinable
    public func sample(_ t: Double) -> Complex<Double> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return p(k: k, t: t_)
    }
    
    @_transparent
    @usableFromInline
    internal func p(k: Int, t: Double) -> Complex<Double> {
        assert(k >= 0 && k < x.count - 1)
        let t2 = t * t
        let t3 = t2 * t
        let dx = x[k + 1] - x[k]
        return t3 * a[k] + t2 * b[k] + t * dx * m[k] + y[k]
    }
    
    @inlinable
    public func sample(_ t: [Double]) -> [Complex<Double>] {
        t.betterMap { sample($0) }
    }
}
// Vector<T>
extension CubicHermiteSpline<Vector<Double>> {
    @inlinable
    public init(x: [Double], y: [Vector<Double>], tangents: [Vector<Double>]) {
        precondition(!x.isEmpty, "The x-axis cannot be empty.")
        precondition(!y.isEmpty, "The y-axis cannot be empty.")
        precondition(x.count == y.count, "The x-axis and y-axis have to match in size.")
        for i in 1..<x.count {
            assert(x[i - 1] < x[i], "The x-axis needs to be monotonically increasing with no duplicates.")
        }
        self.x = x
        self.y = y
        self.m = tangents
        var a: [Vector<Double>] = []
        var b: [Vector<Double>] = []
        for i in 0..<x.count - 1 {
            let dx = x[i + 1] - x[i]
            a.append(2.0 * y[i] + dx * tangents[i] - 2.0 * y[i + 1] + dx * tangents[i + 1])
            b.append(-3.0 * y[i] + 3.0 * y[i + 1] - 2.0 * dx * tangents[i] - dx * tangents[i + 1])
        }
        a.append(Vector(.init(repeating: .zero, count: y[0].components.count)))
        b.append(Vector(.init(repeating: .zero, count: y[0].components.count)))
        self.a = a
        self.b = b
    }
    
    @inlinable
    public init(x: [Double], y: [Vector<Double>]) {
        let m = (0..<x.count).map { k in
            if k == 0 {
                let yDiff = y[k + 1] - y[k]
                let xDiff = x[k + 1] - x[k]
                return yDiff / xDiff
            }
            if k == x.count - 1 {
                let yDiff = y[k] - y[k - 1]
                let xDiff = x[k] - x[k - 1]
                return yDiff / xDiff
            }
            
            let start = (y[k + 1] - y[k]) / (x[k + 1] - x[k])
            let end = (y[k] - y[k - 1]) / (x[k] - x[k - 1])
            return (start + end) / 2
        }
        self = .init(x: x, y: y, tangents: m)
    }
    
    @inlinable
    public subscript(_ t: Double) -> Vector<Double> { sample(t) }
    
    @inlinable
    public subscript(_ t: [Double]) -> [Vector<Double>] { sample(t) }
    
    @inlinable
    public func sample(_ t: Double) -> Vector<Double> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return p(k: k, t: t_)
    }
    
    @_transparent
    @usableFromInline
    internal func p(k: Int, t: Double) -> Vector<Double> {
        assert(k >= 0 && k < x.count - 1)
        let t2 = t * t
        let t3 = t2 * t
        let dx = x[k + 1] - x[k]
        var result = t3 * a[k]
        result.add(b[k], scaling: t2)
        result.add(m[k], scaling: t * dx)
        result.add(y[k])
        return result
    }
    
    @inlinable
    public func sample(_ t: [Double]) -> [Vector<Double>] {
        t.betterMap { sample($0) }
    }
}
 

// Vector<Complex<T>>
extension CubicHermiteSpline<Vector<Complex<Double>>> {
    @inlinable
    public init(x: [Double], y: [Vector<Complex<Double>>], tangents: [Vector<Complex<Double>>]) {
        precondition(!x.isEmpty, "The x-axis cannot be empty.")
        precondition(!y.isEmpty, "The y-axis cannot be empty.")
        precondition(x.count == y.count, "The x-axis and y-axis have to match in size.")
        for i in 1..<x.count {
            assert(x[i - 1] < x[i], "The x-axis needs to be monotonically increasing with no duplicates.")
        }
        self.x = x
        self.y = y
        self.m = tangents
        var a: [Vector<Complex<Double>>] = []
        var b: [Vector<Complex<Double>>] = []
        for i in 0..<x.count - 1 {
            let dx = x[i + 1] - x[i]
            a.append(2.0 * y[i] + dx * tangents[i] - 2.0 * y[i + 1] + dx * tangents[i + 1])
            b.append(-3.0 * y[i] + 3.0 * y[i + 1] - 2.0 * dx * tangents[i] - dx * tangents[i + 1])
        }
        a.append(Vector(.init(repeating: .zero, count: y[0].components.count)))
        b.append(Vector(.init(repeating: .zero, count: y[0].components.count)))
        self.a = a
        self.b = b
    }
    
    @inlinable
    public init(x: [Double], y: [Vector<Complex<Double>>]) {
        let m = (0..<x.count).map { k in
            if k == 0 {
                let yDiff = y[k + 1] - y[k]
                let xDiff = x[k + 1] - x[k]
                return yDiff / xDiff
            }
            if k == x.count - 1 {
                let yDiff = y[k] - y[k - 1]
                let xDiff = x[k] - x[k - 1]
                return yDiff / xDiff
            }
            
            let start = (y[k + 1] - y[k]) / (x[k + 1] - x[k])
            let end = (y[k] - y[k - 1]) / (x[k] - x[k - 1])
            return (start + end) / 2.0
        }
        self = .init(x: x, y: y, tangents: m)
    }
    
    @inlinable
    public subscript(_ t: Double) -> Vector<Complex<Double>> { sample(t) }
    
    @inlinable
    public subscript(_ t: [Double]) -> [Vector<Complex<Double>>] { sample(t) }
    
    @inlinable
    public func sample(_ t: Double) -> Vector<Complex<Double>> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return p(k: k, t: t_)
    }
    
    @_transparent
    @usableFromInline
    internal func p(k: Int, t: Double) -> Vector<Complex<Double>> {
        assert(k >= 0 && k < x.count - 1)
        let t2 = t * t
        let t3 = t2 * t
        let dx = x[k + 1] - x[k]
        var result: Element = t3 * a[k]
        result.add(b[k], scaling: t2)
        result.add(m[k], scaling: t * dx)
        result.add(y[k])
        return result
    }
    
    @inlinable
    public func sample(_ t: [Double]) -> [Vector<Complex<Double>>] {
        t.betterMap { sample($0) }
    }
}

// Matrix<T>
extension CubicHermiteSpline<Matrix<Double>> {
    @inlinable
    public init(x: [Double], y: [Matrix<Double>], tangents: [Matrix<Double>]) {
        precondition(!x.isEmpty, "The x-axis cannot be empty.")
        precondition(!y.isEmpty, "The y-axis cannot be empty.")
        precondition(x.count == y.count, "The x-axis and y-axis have to match in size.")
        for i in 1..<x.count {
            assert(x[i - 1] < x[i], "The x-axis needs to be monotonically increasing with no duplicates.")
        }
        self.x = x
        self.y = y
        self.m = tangents
        var a: [Matrix<Double>] = []
        var b: [Matrix<Double>] = []
        for i in 0..<x.count - 1 {
            let dx = x[i + 1] - x[i]
            var resA = 2.0 * y[i]
            resA += dx * tangents[i]
            resA -= 2.0 * y[i + 1]
            resA += dx * tangents[i + 1]
            a.append(resA)
            var resB = -3.0 * y[i]
            resB += 3.0 * y[i + 1]
            resB -= 2.0 * dx * tangents[i]
            resB -= dx * tangents[i + 1]
            b.append(resB)
        }
        a.append(.zeros(rows: y[0].rows, columns: y[0].columns))
        b.append(.zeros(rows: y[0].rows, columns: y[0].columns))
        self.a = a
        self.b = b
    }
    
    @inlinable
    public init(x: [Double], y: [Matrix<Double>]) {
        let m = (0..<x.count).map { k in
            if k == 0 {
                let yDiff = y[k + 1] - y[k]
                let xDiff = x[k + 1] - x[k]
                return yDiff / xDiff
            }
            if k == x.count - 1 {
                let yDiff = y[k] - y[k - 1]
                let xDiff = x[k] - x[k - 1]
                return yDiff / xDiff
            }
            
            let start = (y[k + 1] - y[k]) / (x[k + 1] - x[k])
            let end = (y[k] - y[k - 1]) / (x[k] - x[k - 1])
            return (start + end) / 2
        }
        self = .init(x: x, y: y, tangents: m)
    }
    
    @inlinable
    public subscript(_ t: Double) -> Matrix<Double> { sample(t) }
    
    @inlinable
    public subscript(_ t: [Double]) -> [Matrix<Double>] { sample(t) }
    
    @inlinable
    public func sample(_ t: Double) -> Matrix<Double> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return p(k: k, t: t_)
    }
    
    @_transparent
    @usableFromInline
    internal func p(k: Int, t: Double) -> Matrix<Double> {
        assert(k >= 0 && k < x.count - 1)
        let t2 = t * t
        let t3 = t2 * t
        let dx = x[k + 1] - x[k]
        var result = t3 * a[k]
        result.add(b[k], multiplied: t2)
        result.add(m[k], multiplied: t * dx)
        result.add(y[k])
        return result
    }
    
    @inlinable
    public func sample(_ t: [Double]) -> [Matrix<Double>] {
        t.betterMap { sample($0) }
    }
}

// Matrix<Complex<T>>
extension CubicHermiteSpline<Matrix<Complex<Double>>> {
    @inlinable
    public init(x: [Double], y: [Matrix<Complex<Double>>], tangents: [Matrix<Complex<Double>>]) {
        precondition(!x.isEmpty, "The x-axis cannot be empty.")
        precondition(!y.isEmpty, "The y-axis cannot be empty.")
        precondition(x.count == y.count, "The x-axis and y-axis have to match in size.")
        for i in 1..<x.count {
            assert(x[i - 1] < x[i], "The x-axis needs to be monotonically increasing with no duplicates.")
        }
        self.x = x
        self.y = y
        self.m = tangents
        var a: [Matrix<Complex<Double>>] = []
        var b: [Matrix<Complex<Double>>] = []
        for i in 0..<x.count - 1 {
            let dx = x[i + 1] - x[i]
            var resA = 2.0 * y[i]
            resA += dx * tangents[i]
            resA -= 2.0 * y[i + 1]
            resA += dx * tangents[i + 1]
            a.append(resA)
            var resB = -3.0 * y[i]
            resB += 3.0 * y[i + 1]
            resB -= 2.0 * dx * tangents[i]
            resB -= dx * tangents[i + 1]
            b.append(resB)
        }
        a.append(.zeros(rows: y[0].rows, columns: y[0].columns))
        b.append(.zeros(rows: y[0].rows, columns: y[0].columns))
        self.a = a
        self.b = b
    }
    
    @inlinable
    public init(x: [Double], y: [Matrix<Complex<Double>>]) {
        let m = (0..<x.count).map { k in
            if k == 0 {
                let yDiff = y[k + 1] - y[k]
                let xDiff = x[k + 1] - x[k]
                return yDiff / xDiff
            }
            if k == x.count - 1 {
                let yDiff = y[k] - y[k - 1]
                let xDiff = x[k] - x[k - 1]
                return yDiff / xDiff
            }
            
            let start = (y[k + 1] - y[k]) / (x[k + 1] - x[k])
            let end = (y[k] - y[k - 1]) / (x[k] - x[k - 1])
            return (start + end) / 2.0
        }
        self = .init(x: x, y: y, tangents: m)
    }
    
    @inlinable
    public subscript(_ t: Double) -> Matrix<Complex<Double>> { sample(t) }
    
    @inlinable
    public subscript(_ t: [Double]) -> [Matrix<Complex<Double>>] { sample(t) }
    
    @inlinable
    public func sample(_ t: Double) -> Matrix<Complex<Double>> {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = (t - x[k]) / (x[k + 1] - x[k])
        return p(k: k, t: t_)
    }
    
    @_transparent
    @usableFromInline
    internal func p(k: Int, t: Double) -> Matrix<Complex<Double>> {
        assert(k >= 0 && k < x.count - 1)
        let t2 = t * t
        let t3 = t2 * t
        let dx = x[k + 1] - x[k]
        var result = t3 * a[k]
        result.add(b[k], multiplied: t2)
        result.add(m[k], multiplied: t * dx)
        result.add(y[k])
        return result
    }
    
    @inlinable
    public func sample(_ t: [Double]) -> [Matrix<Complex<Double>>] {
        t.betterMap { sample($0) }
    }
}
