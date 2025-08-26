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
        _subtract(other)
    }

    @inlinable
    mutating func _subtract(_ other: Self) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        var i = 0
        while i &+ 4 <= elementsSpan.count {
            elementsSpan[unchecked: i] = Relaxed.sum(elementsSpan[unchecked: i], -otherSpan[unchecked: i])
            elementsSpan[unchecked: i] = Relaxed.sum(elementsSpan[unchecked: i &+ 1], -otherSpan[unchecked: i &+ 1])
            elementsSpan[unchecked: i] = Relaxed.sum(elementsSpan[unchecked: i &+ 2], -otherSpan[unchecked: i &+ 2])
            elementsSpan[unchecked: i] = Relaxed.sum(elementsSpan[unchecked: i &+ 3], -otherSpan[unchecked: i &+ 3])
            i &+= 4
        }
        while i < elementsSpan.count {
            elementsSpan[unchecked: i] = Relaxed.sum(elementsSpan[unchecked: i], -otherSpan[unchecked: i])
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
