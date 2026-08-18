// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Scaling for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: T) {
        var componentsSpan = components.mutableSpan
        for i in componentsSpan.indices {
            componentsSpan[unchecked: i] = Relaxed.product(componentsSpan[unchecked: i], by)
        }
    }

    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }

    @inlinable
    func _multiply(by: T, into: inout Self) {
        for i in 0..<components.count {
            into[i] = Relaxed.product(components[i], by)
        }
    }
}

//MARK: Scaling for Double
public extension Vector<Double> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: T) {
        var componentsSpan = components.mutableSpan
        for i in componentsSpan.indices {
            componentsSpan[unchecked: i] = Relaxed.product(componentsSpan[unchecked: i], by)
        }
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.dscal(n: components.count, alpha: by, x: &components, incX: 1)
    }
}

//MARK: Scaling for Float
public extension Vector<Float> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: T) {
        var componentsSpan = components.mutableSpan
        for i in componentsSpan.indices {
            componentsSpan[unchecked: i] = Relaxed.product(componentsSpan[unchecked: i], by)
        }
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.sscal(n: components.count, alpha: by, x: &components, incX: 1)
    }
}

//MARK: Scaling for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }

    @inlinable
    static func *(lhs: Double, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }

    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    mutating func multiply(by: Double) {
        _multiply(by: by)
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: Double) {
        var componentSpan = components.mutableSpan
        componentSpan.withUnsafeMutableBufferPointer { components in 
            let count = 2 * components.count
            components.baseAddress?.withMemoryRebound(to: Double.self, capacity: count) { components in 
                for i in 0..<count {
                    components[i] = Relaxed.product(components[i], by)
                }
            }
        }
        // This leads to unoptimal code...
        //for i in componentSpan.indices {
        //    componentSpan[unchecked: i] = Relaxed.product(componentSpan[unchecked: i], by)
        //}
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.zscal(n: components.count, alpha: by, x: &components, incX: 1)
    }
    
    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: Double) {
        BLAS.zdscal(n: components.count, alpha: by, x: &components, incX: 1)
    }
}

//MARK: Scaling for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }

    @inlinable
    static func *(lhs: Float, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }

    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    mutating func multiply(by: Float) {
        _multiply(by: by)
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: Float) {
        var componentSpan = components.mutableSpan
        componentSpan.withUnsafeMutableBufferPointer { components in 
            let count = 2 * components.count
            components.baseAddress?.withMemoryRebound(to: Float.self, capacity: count) { components in 
                for i in 0..<count {
                    components[i] = Relaxed.product(components[i], by)
                }
            }
        }
        // This leads to unoptimal code...
        //for i in componentSpan.indices {
        //    componentSpan[unchecked: i] = Relaxed.product(componentSpan[unchecked: i], by)
        //}
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.cscal(n: components.count, alpha: by, x: &components, incX: 1)
    }
    
    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: Float) {
        BLAS.csscal(n: components.count, alpha: by, x: &components, incX: 1)
    }
}
