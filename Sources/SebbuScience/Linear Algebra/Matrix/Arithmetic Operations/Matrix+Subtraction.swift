//
//  Matrix+Subtraction.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

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
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        _subtract(other)
    }

    @inlinable
    mutating func _subtract(_ other: Self) {
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in elementsSpan.indices {
            elementsSpan[unchecked: i] = Relaxed.sum(elementsSpan[unchecked: i], -otherSpan[unchecked: i])
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
        if BLAS.isAvailable {
            subtract(other, multiplied: 1.0)
        } else {
            _subtract(other)
        }
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
        add(other, multiplied: -multiplied)
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
        add(other, multiplied: -multiplied)
    }
}
