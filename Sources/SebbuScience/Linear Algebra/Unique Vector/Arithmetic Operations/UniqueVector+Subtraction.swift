//
//  UniqueVector+Subtraction.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import NumericsExtensions
//MARK: Addition for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    @inlinable
    static func -(lhs: borrowing Self, rhs: borrowing Self) -> Self {
        var resultMatrix: Self = UniqueVector(copying: lhs)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    static func -=(lhs: inout Self, rhs: borrowing Self) {
        lhs.subtract(rhs)
    }

    @inlinable
    mutating func subtract(_ other: borrowing Self, multiplied: T) {
        components._unsafeSubtract(other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtract(_ other: borrowing Self) {
        components._unsafeSubtract(other.components, count: count)
    }
}

//MARK: Addition for Double
public extension UniqueVector<Double> {
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.daxpy(count, -multiplied, other.components, 1, components, 1)
    }
}

//MARK: Addition for Float
public extension UniqueVector<Float> {
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.saxpy(count, -multiplied, other.components, 1, components, 1)
    }
}

//MARK: Addition for Complex<Double>
public extension UniqueVector<Complex<Double>> {
    @inlinable
    mutating func subtract(_ other: borrowing Self, multiplied: Double) {
        components._unsafeSubtract(other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.zaxpy(count, -multiplied, other.components, 1, components, 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(count, -multiplied, other.components, 1, components, 1)
    }
}

//MARK: Addition for Complex<Float>
public extension UniqueVector<Complex<Float>> {
    @inlinable
    mutating func subtract(_ other: borrowing Self, multiplied: Float) {
        components._unsafeSubtract(other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: T = .one) {
        BLAS.caxpy(count, -multiplied, other.components, 1, components, 1)
    }
    
    @inlinable
    mutating func subtractBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(count, -multiplied, other.components, 1, components, 1)
    }
}


