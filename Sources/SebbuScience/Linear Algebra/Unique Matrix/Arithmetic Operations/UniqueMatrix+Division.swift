// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions


//MARK: Division for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    static func /(lhs: borrowing Self, rhs: T) -> Self {
        if let reciprocal = rhs.reciprocal {
            return UniqueMatrix(copying: lhs, multiplied: reciprocal)
        }
        var result = UniqueMatrix(copying: lhs)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        elements._unsafeDivide(by: by, count: count)
    }
}

//MARK: Scaling for Double
public extension UniqueMatrix<Double> {
    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.dscal(count, reciprocal, elements, 1)
        } else {
            divide(by: by)
        }
    }
}

//MARK: Scaling for Float
public extension UniqueMatrix<Float> {
    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.sscal(count, reciprocal, elements, 1)
        } else {
            divide(by: by)
        }
    }
}

//MARK: Scaling for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    static func /(lhs: borrowing Self, rhs: Double) -> Self {
        if let reciprocal = rhs.reciprocal {
            return UniqueMatrix(copying: lhs, multiplied: reciprocal)
        }
        var result = UniqueMatrix(copying: lhs)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Double) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: Double) {
        elements._unsafeDivide(by: by, count: count)
    }

    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.zscal(count, reciprocal, elements, 1)
        } else {
            divide(by: by)
        }
    }

    @inlinable
    mutating func divideBLAS(by: Double) {
        if let reciprocal = by.reciprocal {
            BLAS.zdscal(count, reciprocal, elements, 1)
        } else {
            divide(by: by)
        }
    }
}

//MARK: Scaling for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    static func /(lhs: borrowing Self, rhs: Float) -> Self {
        if let reciprocal = rhs.reciprocal {
            return UniqueMatrix(copying: lhs, multiplied: reciprocal)
        }
        var result = UniqueMatrix(copying: lhs)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Float) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: Float) {
        elements._unsafeDivide(by: by, count: count)
    }

    @inlinable
    mutating func divideBLAS(by: T) {
        if let reciprocal = by.reciprocal {
            BLAS.cscal(count, reciprocal, elements, 1)
        } else {
            divide(by: by)
        }
    }

    @inlinable
    mutating func divideBLAS(by: Float) {
        if let reciprocal = by.reciprocal {
            BLAS.csscal(count, reciprocal, elements, 1)
        } else {
            divide(by: by)
        }
    }
}
