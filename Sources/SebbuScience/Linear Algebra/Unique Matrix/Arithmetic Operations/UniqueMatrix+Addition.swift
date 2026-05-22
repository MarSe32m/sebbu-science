//
//  UniqueMatrix+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import NumericsExtensions

//MARK: Addition for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    static func +(lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var resultMatrix: Self = .zeros(rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: borrowing Self) {
        lhs.add(rhs)
    }

    @inlinable
    @_transparent
    mutating func add(_ other: borrowing Self, multiplied: T) {
        elements._unsafeAdd(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: borrowing Self) {
        elements._unsafeAdd(other.elements, count: count)
    }
}

//MARK: Addition for Double
public extension UniqueMatrix<Double> {
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T) {
        BLAS.daxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self) {
        BLAS.daxpy(count, 1, other.elements, 1, elements, 1)
    }
}

//MARK: Addition for Float
public extension UniqueMatrix<Float> {
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T) {
        BLAS.saxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self) {
        BLAS.saxpy(count, 1, other.elements, 1, elements, 1)
    }
}

//MARK: Addition for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    @_transparent
    mutating func add(_ other: borrowing Self, multiplied: Double) {
        elements._unsafeAdd(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T) {
        BLAS.zaxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self) {
        BLAS.zaxpy(count, .one, other.elements, 1, elements, 1)
    }
}

//MARK: Addition for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    @_transparent
    mutating func add(_ other: borrowing Self, multiplied: Float) {
        elements._unsafeAdd(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T) {
        BLAS.caxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self) {
        BLAS.caxpy(count, .one, other.elements, 1, elements, 1)
    }
}

