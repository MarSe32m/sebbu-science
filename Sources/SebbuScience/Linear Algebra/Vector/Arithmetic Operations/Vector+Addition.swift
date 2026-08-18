// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Addition for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: T) {
        precondition(other.components.count == self.components.count)
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    mutating func _add(_ other: Self, multiplied: T) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in componentSpan.indices {
            componentSpan[i] = Relaxed.multiplyAdd(multiplied, otherSpan[i], componentSpan[i])
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(other.components.count == self.components.count)
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in componentSpan.indices {
            componentSpan[unchecked: i] = Relaxed.sum(componentSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
}

//MARK: Addition for Double
public extension Vector<Double> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.daxpy(n: components.count, alpha: multiplied, x: other.components, incX: 1, y: &components, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.daxpy(n: components.count, alpha: 1.0, x: other.components, incX: 1, y: &components, incY: 1)
    }
}

//MARK: Addition for Float
public extension Vector<Float> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.saxpy(n: components.count, alpha: multiplied, x: other.components, incX: 1, y: &components, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.saxpy(n: components.count, alpha: 1.0, x: other.components, incX: 1, y: &components, incY: 1)
    }
}

//MARK: Addition for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Double) {
        _add(other, multiplied: multiplied)
    }

    @inlinable
    @_transparent
    mutating func _add(_ other: Self, multiplied: Double) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        componentSpan.withUnsafeMutableBufferPointer { components in 
            otherSpan.withUnsafeBufferPointer { otherComponents in 
                let count = 2 * components.count
                components.baseAddress?.withMemoryRebound(to: Double.self, capacity: count) { components in 
                    otherComponents.baseAddress?.withMemoryRebound(to: Double.self, capacity: count) { otherComponents in 
                        for i in 0..<count {
                            components[i] = Relaxed.multiplyAdd(otherComponents[i], multiplied, components[i])
                        }
                    }
                }
            }
        }
        // This leads to unoptimal code...
        //var componentSpan = components.mutableSpan
        //let otherSpan = other.components.span
        //for i in componentSpan.indices {
        //    componentSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], componentSpan[unchecked: i])
        //}
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.zaxpy(n: components.count, alpha: multiplied, x: other.components, incX: 1, y: &components, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: Double) {
        BLAS.zaxpy(n: components.count, alpha: Complex(multiplied), x: other.components, incX: 1, y: &components, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.zaxpy(n: components.count, alpha: .one, x: other.components, incX: 1, y: &components, incY: 1)
    }
}

//MARK: Addition for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Float) {
        _add(other, multiplied: multiplied)
    }

    @inlinable
    @_transparent
    mutating func _add(_ other: Self, multiplied: Float) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        componentSpan.withUnsafeMutableBufferPointer { components in 
            otherSpan.withUnsafeBufferPointer { otherComponents in 
                let count = 2 * components.count
                components.baseAddress?.withMemoryRebound(to: Float.self, capacity: count) { components in 
                    otherComponents.baseAddress?.withMemoryRebound(to: Float.self, capacity: count) { otherComponents in 
                        for i in 0..<count {
                            components[i] = Relaxed.multiplyAdd(otherComponents[i], multiplied, components[i])
                        }
                    }
                }
            }
        }
        // This leads to unoptimal code...
        //var componentSpan = components.mutableSpan
        //let otherSpan = other.components.span
        //for i in componentSpan.indices {
        //    componentSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], componentSpan[unchecked: i])
        //}
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.caxpy(n: components.count, alpha: multiplied, x: other.components, incX: 1, y: &components, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: Float) {
        BLAS.caxpy(n: components.count, alpha: Complex(multiplied), x: other.components, incX: 1, y: &components, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.caxpy(n: components.count, alpha: .one, x: other.components, incX: 1, y: &components, incY: 1)
    }
}
