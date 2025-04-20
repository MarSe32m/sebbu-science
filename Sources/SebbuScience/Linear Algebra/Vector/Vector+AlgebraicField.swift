//
//  Vector+AlgebraicField.swift
//  swift-phd-toivonen
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule
import ComplexModule
import SebbuCollections

public extension Vector where T: AlgebraicField {
    @inline(__always)
    @inlinable
    static func zero(_ count: Int) -> Vector<T> {
        Vector(.init(repeating: .zero, count: count))
    }
    
    //MARK: Scaling
    @inline(__always)
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inline(__always)
    @_transparent
    @inlinable
    internal mutating func _multiply(by: T) {
        for i in 0..<components.count {
            components[i] = Relaxed.product(components[i], by)
        }
    }

    @inline(__always)
    @_transparent
    @inlinable
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }

    @inline(__always)
    @_transparent
    @inlinable
    internal func _multiply(by: T, into: inout Self) {
        for i in 0..<components.count {
            into[i] = Relaxed.product(components[i], by)
        }
    }
    
    //MARK: Division
    @inline(__always)
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    mutating func divide(by: T) {
        _divide(by: by)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    internal mutating func _divide(by: T) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }

    @inline(__always)
    @_transparent
    @inlinable
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    internal func _divide(by: T, into: inout Self) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal, into: &into)
        } else {
            for i in components.indices {
                into[i] = components[i] / by
            }
        }
    }
    
    //MARK: Addition
    @inline(__always)
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }

    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func add(_ other: Self, scaling: T) {
        _add(other, scaling: scaling)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    internal mutating func _add(_ other: Self, scaling: T) {
        precondition(other.components.count == self.components.count)
        for i in 0..<components.count {
            components[i] = Relaxed.multiplyAdd(scaling, other.components[i], components[i])
        }
    }
    
    @inline(__always)
    @inlinable
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inline(__always)
    @inlinable
    @_transparent
    internal mutating func _add(_ other: Self) {
        precondition(other.components.count == self.components.count)
        for i in 0..<components.count {
            components[i] = Relaxed.sum(components[i], other.components[i])
        }
    }
    
    // MARK: Subtraction
    @inline(__always)
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    mutating func subtract(_ other: Self, scaling: T) {
        _subtract(other, scaling: scaling)
    }

    @inline(__always)
    @_transparent
    @inlinable
    internal mutating func _subtract(_ other: Self, scaling: T) {
        add(other, scaling: -scaling)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    mutating func subtract(_ other: Self) {
        _subtract(other)
    }

    @inline(__always)
    @_transparent
    @inlinable
    internal mutating func _subtract(_ other: Self) {
        precondition(other.components.count == self.components.count)
        for i in 0..<components.count {
            components[i] = Relaxed.sum(components[i], -other.components[i])
        }
    }
    
    //MARK: Dot product
    /// Computes the Euclidian dot product. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>``` and ```Vector<Complex<Double>>``` use ```inner(_:)``` for a proper inner product
    @inline(__always)
    @inlinable
    @_transparent
    func dot(_ other: Self) -> T {
        _dot(other)
    }

    @inlinable
    internal func _dot(_ other: Self) -> T {
        precondition(other.count == count)
        var result: T = .zero
        for i in 0..<components.count {
            result = Relaxed.multiplyAdd(components[i], other.components[i], result)
        }
        return result
    }
    
    /// Computes the Euclidian dot product with a metric. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>```and ```Vector<Complex<Double>>```use ```inner(_:,metric:)``` for a proper inner product.
    @inline(__always)
    @inlinable
    @_transparent
    func dot(_ other: Self, metric: Matrix<T>) -> T {
        _dot(other, metric: metric)
    }

    @inlinable
    internal func _dot(_ other: Self, metric: Matrix<T>) -> T {
        precondition(other.count == metric.columns)
        precondition(count == metric.rows)
        var result: T = .zero
        for i in 0..<components.count {
            for j in 0..<other.components.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i], metric[i ,j]), other[j], result)
            }
        }
        return result
    }
    
    //MARK: Inner product
    @inlinable
    @inline(__always)
    @_transparent
    func inner(_ other: Self) -> T {
        _inner(other)
    }

    @inlinable
    @inline(__always)
    @_transparent
    internal func _inner(_ other: Self) -> T {
        dot(other)
    }
    
    @inlinable
    @inline(__always)
    @_transparent
    func inner(_ other: Self, metric: Matrix<T>) -> T {
        dot(other, metric: metric)
    }

    @inlinable
    @inline(__always)
    @_transparent
    internal func _inner(_ other: Self, metric: Matrix<T>) -> T {
        dot(other, metric: metric)
    }
    
    //MARK: Outer product
    @inlinable
    func outer(_ other: Self) -> Matrix<T> {
        var result: Matrix<T> = .zeros(rows: count, columns: other.count)
        outer(other, into: &result)
        return result
    }
    
    @inlinable
    @inline(__always)
    @_transparent
    func outer(_ other: Self, into: inout Matrix<T>) {
        _outer(other, into: &into)
    }

    @inlinable
    @inline(__always)
    internal func _outer(_ other: Self, into: inout Matrix<T>) {
        precondition(into.rows == count && into.columns == other.count)
        for i in 0..<count {
            for j in 0..<other.count {
                into[i, j] = Relaxed.product(components[i], other.components[j])
            }
        }
    }
    
    //MARK: Vector matrix multiply
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @inline(__always)
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        _dot(matrix, into: &into)
    }

    @inlinable
    @inline(__always)
    internal func _dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(count == matrix.rows)
        for i in 0..<into.count { into[i] = .zero }
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(self[j], matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    @inline(__always)
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        _dot(matrix, multiplied: multiplied, into: &into)
    }

    @inlinable
    @inline(__always)
    internal func _dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(count == matrix.rows)
        for i in 0..<into.count { into[i] = .zero }
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[j], multiplied)
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(C, matrix[j, i], into[i])
            }
        }
    }
}
