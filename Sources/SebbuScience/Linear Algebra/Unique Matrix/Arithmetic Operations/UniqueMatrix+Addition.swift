// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

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
    mutating func add(_ other: Matrix<T>, multiplied: T) {
        elements._unsafeAdd(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: borrowing Self) {
        elements._unsafeAdd(other.elements, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Matrix<T>) {
        elements._unsafeAdd(other.elements, count: count)
    }
}

//MARK: Addition for Double
public extension UniqueMatrix<Double> {
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.daxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: Matrix<T>, multiplied: T = 1.0) {
        BLAS.daxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

//MARK: Addition for Float
public extension UniqueMatrix<Float> {
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.saxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: Matrix<T>, multiplied: T = 1.0) {
        BLAS.saxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
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
    mutating func add(_ other: Matrix<T>, multiplied: Double) {
        elements._unsafeAdd(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.zaxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: Matrix<T>, multiplied: T = .one) {
        BLAS.zaxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(n: count, alpha: Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: Matrix<T>, multiplied: Double) {
        BLAS.zaxpy(n: count, alpha: Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
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
    mutating func add(_ other: Matrix<T>, multiplied: Float) {
        elements._unsafeAdd(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.caxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: Matrix<T>, multiplied: T = .one) {
        BLAS.caxpy(n: count, alpha: multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(n: count, alpha: Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    @_transparent
    mutating func addBLAS(_ other: Matrix<T>, multiplied: Float) {
        BLAS.caxpy(n: count, alpha: Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

