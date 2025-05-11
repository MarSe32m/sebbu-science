//
//  Matrix+Subtraction.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions


//MARK: Subtraction for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self) {
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
        _subtract(other)
    }

    @inlinable
    mutating func _subtract(_ other: Self) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        var i = 0
        while i &+ 4 <= elements.count {
            elements[i] = Relaxed.sum(elements[i], -other.elements[i])
            elements[i] = Relaxed.sum(elements[i &+ 1], -other.elements[i &+ 1])
            elements[i] = Relaxed.sum(elements[i &+ 2], -other.elements[i &+ 2])
            elements[i] = Relaxed.sum(elements[i &+ 3], -other.elements[i &+ 3])
            i &+= 4
        }
        while i < elements.count {
            elements[i] = Relaxed.sum(elements[i], -other.elements[i])
            i &+= 1
        }
    }
}

//MARK: Subtraction for Double
public extension Matrix<Double> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self) {
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
public extension Matrix<Float> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self) {
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
public extension Matrix<Complex<Double>> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self) {
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
    mutating func subtract(_ other: Self, multiplied: Double) {
        add(other, multiplied: Complex(-multiplied))
    }
}

//MARK: Subtraction for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self) {
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
    mutating func subtract(_ other: Self, multiplied: Float) {
        add(other, multiplied: Complex(-multiplied))
    }
}
