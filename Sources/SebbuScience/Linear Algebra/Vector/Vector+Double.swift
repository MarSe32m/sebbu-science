//
//  Vector+Double.swift
//  swift-phd-toivonen
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

#if canImport(COpenBLAS)
import COpenBLAS
#endif
#if canImport(CLAPACK)
import CLAPACK
#endif
import RealModule

public extension Vector<Double> {
    @inline(__always)
    var norm: Double {
        normSquared.squareRoot()
    }
    
    @inline(__always)
    var normSquared: Double {
        self.inner(self)
    }

    //MARK: Scaling
    @inline(__always)
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    mutating func multiply(by: T) {
        if let cblas_dscal = BLAS.dscal {
            let N: Int32 = numericCast(count)
            cblas_dscal(N, by, &components, 1)
        } else {
            _multiply(by: by)
        }
    }
    
    //MARK: Division
    @inline(__always)
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inline(__always)
    @_transparent
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
    
    //MARK: Addition
    @inline(__always)
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func add(_ other: Self, scaling: T) {
        if let cblas_daxpy = BLAS.daxpy {
            precondition(other.components.count == self.components.count)
            cblas_daxpy(numericCast(count), scaling, other.components, 1, &components, 1)
        } else {
            _add(other, scaling: scaling)
        }
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, scaling: 1.0)
    }
    
    // MARK: Subtraction
    @inline(__always)
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inline(__always)
    @inlinable
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, scaling: T) {
        add(other, scaling: -scaling)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        subtract(other, scaling: 1.0)
    }
    
    //MARK: Dot product
    /// Computes the Euclidian dot product.
    @inlinable
    @inline(__always)
    @_transparent
    func dot(_ other: Self) -> T {
        if let cblas_ddot = BLAS.ddot {
            precondition(count == other.count)
            return cblas_ddot(numericCast(count), components, 1, other.components, 1)
        } else {
            return _dot(other)
        }
    }
    
    //MARK: Vector matrix multiply
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @inline(__always)
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @inline(__always)
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if let cblas_dgemv = BLAS.dgemv {
            precondition(matrix.rows == self.count)
            precondition(matrix.columns == into.count)
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m: Int32 = numericCast(matrix.rows)
            let n: Int32 = numericCast(matrix.columns)
            let lda: Int32 = n
            cblas_dgemv(layout, trans, m, n, multiplied, matrix.elements, lda, components, 1, .zero, &into.components, 1)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
}