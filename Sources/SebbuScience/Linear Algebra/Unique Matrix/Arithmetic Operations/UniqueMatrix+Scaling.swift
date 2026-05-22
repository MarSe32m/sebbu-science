//
//  UniqueMatrix+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 22.5.2026.
//

import NumericsExtensions

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
        BLAS.dscal(count, by, elements, 1)
    }
}

//MARK: Scaling for Float
public extension UniqueMatrix<Float> {
    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.sscal(count, by, elements, 1)
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
        BLAS.zscal(count, by, elements, 1)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: Double) {
        BLAS.zdscal(count, by, elements, 1)
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
        BLAS.cscal(count, by, elements, 1)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: Float) {
        BLAS.csscal(count, by, elements, 1)
    }
}
