//
//  Vector+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import BLAS
import NumericsExtensions

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
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    mutating func _add(_ other: Self, multiplied: T) {
        precondition(other.components.count == self.components.count)
        var i = 0
        while i &+ 4 <= components.count {
            components[i] = Relaxed.multiplyAdd(multiplied, other.components[i], components[i])
            components[i &+ 1] = Relaxed.multiplyAdd(multiplied, other.components[i &+ 1], components[i &+ 1])
            components[i &+ 2] = Relaxed.multiplyAdd(multiplied, other.components[i &+ 2], components[i &+ 2])
            components[i &+ 3] = Relaxed.multiplyAdd(multiplied, other.components[i &+ 3], components[i &+ 3])
            i &+= 4
            
        }
        while i < components.count {
            components[i] = Relaxed.multiplyAdd(multiplied, other.components[i], components[i])
            i &+= 1
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        precondition(other.components.count == self.components.count)
        var i = 0
        while i &+ 4 <= components.count {
            components[i] = Relaxed.sum(components[i], other.components[i])
            components[i &+ 1] = Relaxed.sum(components[i &+ 1], other.components[i &+ 1])
            components[i &+ 2] = Relaxed.sum(components[i &+ 2], other.components[i &+ 2])
            components[i &+ 3] = Relaxed.sum(components[i &+ 3], other.components[i &+ 3])
            i &+= 4
        }
        while i < components.count {
            components[i] = Relaxed.sum(components[i], other.components[i])
            i &+= 1
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
        if let daxpy = BLAS.daxpy {
            precondition(count == other.count)
            let N = cblas_int(count)
            daxpy(N, multiplied, other.components, 1, &components, 1)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: 1.0)
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
        if let saxpy = BLAS.saxpy {
            precondition(count == other.count)
            let N = cblas_int(count)
            saxpy(N, multiplied, other.components, 1, &components, 1)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: 1.0)
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
        if let zaxpy = BLAS.zaxpy {
            let N = cblas_int(count)
            withUnsafePointer(to: multiplied) { alpha in
                zaxpy(N, alpha, other.components, 1, &components, 1)
            }
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Double) {
        add(other, multiplied: Complex(multiplied))
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
        if let caxpy = BLAS.caxpy {
            precondition(count == other.count)
            let N = cblas_int(count)
            withUnsafePointer(to: multiplied) { alpha in
                caxpy(N, alpha, other.components, 1, &components, 1)
            }
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Float) {
        add(other, multiplied: Complex(multiplied))
    }
}
