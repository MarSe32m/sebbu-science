// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Scaling for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: borrowing Self) -> Self {
        UniqueMatrix(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        elements._unsafeMultiply(by: by, count: count)
    }
}

//MARK: Scaling for Double
public extension UniqueMatrix<Double> {
    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.dscal(n: count, alpha: by, x: elements, incX: 1)
    }
}

//MARK: Scaling for Float
public extension UniqueMatrix<Float> {
    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.sscal(n: count, alpha: by, x: elements, incX: 1)
    }
}

//MARK: Scaling for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    static func *(lhs: Double, rhs: borrowing Self) -> Self {
        UniqueMatrix(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        elements._unsafeMultiply(by: by, count: count)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.zscal(n: count, alpha: by, x: elements, incX: 1)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: Double) {
        BLAS.zdscal(n: count, alpha: by, x: elements, incX: 1)
    }
}

//MARK: Scaling for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    static func *(lhs: Float, rhs: borrowing Self) -> Self {
        UniqueMatrix(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Float) {
        elements._unsafeMultiply(by: by, count: count)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.cscal(n: count, alpha: by, x: elements, incX: 1)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: Float) {
        BLAS.csscal(n: count, alpha: by, x: elements, incX: 1)
    }
}
