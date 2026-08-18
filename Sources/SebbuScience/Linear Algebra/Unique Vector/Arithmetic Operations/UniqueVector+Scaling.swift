// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Scaling for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: borrowing Self) -> Self {
        UniqueVector(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @inline(always)
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @inline(always)
    mutating func multiply(by: T) {
        components._unsafeMultiply(by: by, count: count)
    }
}

//MARK: Scaling for Double
public extension UniqueVector<Double> {
    @inlinable
    @inline(always)
    mutating func multiplyBLAS(by: T) {
        BLAS.dscal(n: count, alpha: by, x: components, incX: 1)
    }
}

//MARK: Scaling for Float
public extension UniqueVector<Float> {
    @inlinable
    @inline(always)
    mutating func multiplyBLAS(by: T) {
        BLAS.sscal(n: count, alpha: by, x: components, incX: 1)
    }
}

//MARK: Scaling for Complex<Double>
public extension UniqueVector<Complex<Double>> {
    @inlinable
    static func *(lhs: Double, rhs: borrowing Self) -> Self {
        UniqueVector(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @inline(always)
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        components._unsafeMultiply(by: by, count: count)
    }

    @inlinable
    @inline(always)
    mutating func multiplyBLAS(by: T) {
        BLAS.zscal(n: count, alpha: by, x: components, incX: 1)
    }

    @inlinable
    @inline(always)
    mutating func multiplyBLAS(by: Double) {
        BLAS.zdscal(n: count, alpha: by, x: components, incX: 1)
    }
}

//MARK: Scaling for Complex<Float>
public extension UniqueVector<Complex<Float>> {
    @inlinable
    static func *(lhs: Float, rhs: borrowing Self) -> Self {
        UniqueVector(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @inline(always)
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Float) {
        components._unsafeMultiply(by: by, count: count)
    }

    @inlinable
    @inline(always)
    mutating func multiplyBLAS(by: T) {
        BLAS.cscal(n: count, alpha: by, x: components, incX: 1)
    }

    @inlinable
    @inline(always)
    mutating func multiplyBLAS(by: Float) {
        BLAS.csscal(n: count, alpha: by, x: components, incX: 1)
    }
}

