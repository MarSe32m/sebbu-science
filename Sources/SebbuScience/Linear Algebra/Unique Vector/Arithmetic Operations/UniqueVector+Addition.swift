//
//  UniqueVector+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import NumericsExtensions
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
        BLAS.daxpy(count, multiplied, other.components, 1, components, 1)
    }
}

//MARK: Addition for Float
public extension UniqueVector<Float> {
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: T = 1.0) {
        BLAS.saxpy(count, multiplied, other.components, 1, components, 1)
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
        BLAS.zaxpy(count, multiplied, other.components, 1, components, 1)
    }
    
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: Double) {
        BLAS.zaxpy(count, multiplied, other.components, 1, components, 1)
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
        BLAS.caxpy(count, multiplied, other.components, 1, components, 1)
    }
    
    @inlinable
    @inline(always)
    mutating func addBLAS(_ other: borrowing Self, multiplied: Float) {
        BLAS.caxpy(count, multiplied, other.components, 1, components, 1)
    }
}
