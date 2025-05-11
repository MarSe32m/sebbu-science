//
//  Vector+Subtraction.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Subtraction for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: T) {
        _subtract(other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func _subtract(_ other: Self, multiplied: T) {
        _add(other, multiplied: -multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        _subtract(other)
    }
    
    @inlinable
    mutating func _subtract(_ other: Self) {
        precondition(other.components.count == self.components.count)
        for i in 0..<components.count {
            components[i] = Relaxed.sum(components[i], -other.components[i])
        }
    }
}

//MARK: Subtraction for Double
public extension Vector<Double> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: T) {
        add(other, multiplied: -multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        subtract(other, multiplied: 1.0)
    }
}

//MARK: Subtraction for Float
public extension Vector<Float> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: T) {
        add(other, multiplied: -multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        subtract(other, multiplied: 1.0)
    }
}

//MARK: Subtraction for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: T) {
        add(other, multiplied: -multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        subtract(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: Double) {
        add(other, multiplied: Complex(-multiplied))
    }
}

//MARK: Subtraction for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: T) {
        add(other, multiplied: -multiplied)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        subtract(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, multiplied: Float) {
        add(other, multiplied: Complex(-multiplied))
    }
}
