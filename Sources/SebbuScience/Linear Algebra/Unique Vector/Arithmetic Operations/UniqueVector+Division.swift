//
//  UniqueVector+Division.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import NumericsExtensions

//MARK: Division for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    @inlinable
    static func /(lhs: borrowing Self, rhs: T) -> Self {
        if let reciprocal = rhs.reciprocal {
            return UniqueVector(copying: lhs, multiplied: reciprocal)
        }
        var result = UniqueVector(copying: lhs)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        components._unsafeDivide(by: by, count: count)
    }
}

//MARK: Scaling for Double
public extension UniqueVector<Double> {
    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.dscal(count, reciprocal, components, 1)
        } else {
            divide(by: by)
        }
    }
}

//MARK: Scaling for Float
public extension UniqueVector<Float> {
    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.sscal(count, reciprocal, components, 1)
        } else {
            divide(by: by)
        }
    }
}

//MARK: Scaling for Complex<Double>
public extension UniqueVector<Complex<Double>> {
    @inlinable
    static func /(lhs: borrowing Self, rhs: Double) -> Self {
        if let reciprocal = rhs.reciprocal {
            return UniqueVector(copying: lhs, multiplied: reciprocal)
        }
        var result = UniqueVector(copying: lhs)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Double) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: Double) {
        components._unsafeDivide(by: by, count: count)
    }

    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.zscal(count, reciprocal, components, 1)
        } else {
            divide(by: by)
        }
    }

    @inlinable
    mutating func divideBLAS(by: Double) {
        if let reciprocal = by.reciprocal {
            BLAS.zdscal(count, reciprocal, components, 1)
        } else {
            divide(by: by)
        }
    }
}

//MARK: Scaling for Complex<Float>
public extension UniqueVector<Complex<Float>> {
    @inlinable
    static func /(lhs: borrowing Self, rhs: Float) -> Self {
        if let reciprocal = rhs.reciprocal {
            return UniqueVector(copying: lhs, multiplied: reciprocal)
        }
        var result = UniqueVector(copying: lhs)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Float) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: Float) {
        components._unsafeDivide(by: by, count: count)
    }

    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.cscal(count, reciprocal, components, 1)
        } else {
            divide(by: by)
        }
    }

    @inlinable
    mutating func divideBLAS(by: Float) {
        if let reciprocal = by.reciprocal {
            BLAS.csscal(count, reciprocal, components, 1)
        } else {
            divide(by: by)
        }
    }
}
