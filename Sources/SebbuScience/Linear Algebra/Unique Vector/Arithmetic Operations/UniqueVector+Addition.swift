// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Addition for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    @inlinable
    static func +(lhs: borrowing Self, rhs: borrowing Self) -> Self {
        UniqueVector(copying: lhs, adding: rhs)
    }
    
    @inlinable
    @inline(always)
    static func +=(lhs: inout Self, rhs: borrowing Self) {
        lhs.add(rhs)
    }

    @inlinable
    @inline(always)
    mutating func add(_ other: borrowing Self, multiplied: T) {
        components._unsafeAdd(other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @inline(always)
    mutating func add(_ other: borrowing Self) {
        components._unsafeAdd(other.components, count: count)
    }
    
    @inlinable
    @inline(always)
    mutating func add(_ scalar: T) {
        components._unsafeAdd(scalar, count: count)
    }
}

//MARK: Addition for Double
public extension UniqueVector<Double> {
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.daxpy(n: count, alpha: multiplied, x: other.components, incX: 1, y: components, incY: 1)
    }
}

//MARK: Addition for Float
public extension UniqueVector<Float> {
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.saxpy(n: count, alpha: multiplied, x: other.components, incX: 1, y: components, incY: 1)
    }
}

//MARK: Addition for Complex<Double>
public extension UniqueVector<Complex<Double>> {
    @inlinable
    @inline(always)
    mutating func add(_ other: borrowing Self, multiplied: Double) {
        components._unsafeAdd(other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @inline(always)
    mutating func add(_ scalar: Double) {
        components._unsafeAdd(scalar, count: count)
    }
    
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.zaxpy(n: count, alpha: multiplied, x: other.components, incX: 1, y: components, incY: 1)
    }
    
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(n: count, alpha: Complex(multiplied), x: other.components, incX: 1, y: components, incY: 1)
    }
}

//MARK: Addition for Complex<Float>
public extension UniqueVector<Complex<Float>> {
    @inlinable
    @inline(always)
    mutating func add(_ other: borrowing Self, multiplied: Float) {
        components._unsafeAdd(other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    @inline(always)
    mutating func add(_ scalar: Float) {
        components._unsafeAdd(scalar, count: count)
    }
    
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.caxpy(n: count, alpha: multiplied, x: other.components, incX: 1, y: components, incY: 1)
    }
    
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(n: count, alpha: Complex(multiplied), x: other.components, incX: 1, y: components, incY: 1)
    }
}
