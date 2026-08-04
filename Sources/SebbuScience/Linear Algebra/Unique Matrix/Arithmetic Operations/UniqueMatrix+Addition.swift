// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions

//MARK: Addition for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    static func +(lhs: borrowing Self, rhs: borrowing Self) -> Self {
        UniqueMatrix(copying: lhs, adding: rhs)
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
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.daxpy(count, multiplied, other.elements, 1, elements, 1)
    }
}

//MARK: Addition for Float
public extension UniqueMatrix<Float> {
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.saxpy(count, multiplied, other.elements, 1, elements, 1)
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
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.zaxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(count, multiplied, other.elements, 1, elements, 1)
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
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.caxpy(count, multiplied, other.elements, 1, elements, 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(count, multiplied, other.elements, 1, elements, 1)
    }
}

