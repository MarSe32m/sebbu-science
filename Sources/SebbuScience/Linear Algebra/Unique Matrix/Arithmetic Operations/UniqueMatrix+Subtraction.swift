// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Addition for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    static func -(lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var resultMatrix: Self = UniqueMatrix(copying: lhs)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    static func -=(lhs: inout Self, rhs: borrowing Self) {
        lhs.subtract(rhs)
    }

    @inlinable
    mutating func subtract(_ other: borrowing Self, multiplied: T) {
        elements._unsafeSubtract(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtract(_ other: Matrix<T>, multiplied: T) {
        elements._unsafeSubtract(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtract(_ other: borrowing Self) {
        elements._unsafeSubtract(other.elements, count: count)
    }
    
    @inlinable
    mutating func subtract(_ other: Matrix<T>) {
        elements._unsafeSubtract(other.elements, count: count)
    }
}

//MARK: Addition for Double
public extension UniqueMatrix<Double> {
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.daxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: Matrix<T>, multiplied: T = 1.0) {
        BLAS.daxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

//MARK: Addition for Float
public extension UniqueMatrix<Float> {
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.saxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: Matrix<T>, multiplied: T = 1.0) {
        BLAS.saxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

//MARK: Addition for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    mutating func subtract(_ other: borrowing Self, multiplied: Double) {
        elements._unsafeSubtract(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtract(_ other: Matrix<T>, multiplied: Double) {
        elements._unsafeSubtract(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.zaxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: Matrix<T>, multiplied: T = .one) {
        BLAS.zaxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(n: count, alpha: -Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: Matrix<T>, multiplied: Double) {
        BLAS.zaxpy(n: count, alpha: -Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

//MARK: Addition for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    mutating func subtract(_ other: borrowing Self, multiplied: Float) {
        elements._unsafeSubtract(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtract(_ other: Matrix<T>, multiplied: Float) {
        elements._unsafeSubtract(other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.caxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: Matrix<T>, multiplied: T = .one) {
        BLAS.caxpy(n: count, alpha: -multiplied, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(n: count, alpha: -Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: Matrix<T>, multiplied: Float) {
        BLAS.caxpy(n: count, alpha: -Complex(multiplied), x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

