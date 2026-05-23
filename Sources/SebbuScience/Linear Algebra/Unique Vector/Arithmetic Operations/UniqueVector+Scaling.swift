//
//  UniqueVector+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import NumericsExtensions

//MARK: Scaling for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: borrowing Self) -> Self {
        UniqueVector(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        components._unsafeMultiply(by: by, count: count)
    }
}

//MARK: Scaling for Double
public extension UniqueVector<Double> {
    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.dscal(count, by, components, 1)
    }
}

//MARK: Scaling for Float
public extension UniqueVector<Float> {
    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.sscal(count, by, components, 1)
    }
}

//MARK: Scaling for Complex<Double>
public extension UniqueVector<Complex<Double>> {
    @inlinable
    static func *(lhs: Double, rhs: borrowing Self) -> Self {
        UniqueVector(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        components._unsafeMultiply(by: by, count: count)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.zscal(count, by, components, 1)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: Double) {
        BLAS.zdscal(count, by, components, 1)
    }
}

//MARK: Scaling for Complex<Float>
public extension UniqueVector<Complex<Float>> {
    @inlinable
    static func *(lhs: Float, rhs: borrowing Self) -> Self {
        UniqueVector(copying: rhs, multiplied: lhs)
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Float) {
        components._unsafeMultiply(by: by, count: count)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: T) {
        BLAS.cscal(count, by, components, 1)
    }

    @inlinable
    @_transparent
    mutating func multiplyBLAS(by: Float) {
        BLAS.csscal(count, by, components, 1)
    }
}

