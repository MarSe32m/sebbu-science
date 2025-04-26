//
//  Vector+Float.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import BLAS

import RealModule

public extension Vector<Float> {
    @inlinable
    var norm: Float {
        normSquared.squareRoot()
    }
    
    @inlinable
    var normSquared: Float {
        self.inner(self)
    }

    //MARK: Scaling
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let sscal = BLAS.sscal {
            let N = cblas_int(count)
            sscal(N, by, &components, 1)
        } else {
            _multiply(by: by)
        }
    }
    
    //MARK: Division
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
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
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    
    @inlinable
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    //@inlinable
    mutating func add(_ other: Self, scaling: T) {
        if let saxpy = BLAS.saxpy {
            precondition(count == other.count)
            let N = cblas_int(count)
            saxpy(N, scaling, other.components, 1, &components, 1)
        } else {
            _add(other, scaling: scaling)
        }
    }
    
    @inlinable
    mutating func add(_ other: Self) {
        add(other, scaling: 1.0)
    }

    // MARK: Subtraction
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.components.count == rhs.components.count)
        var result = Vector(Array(lhs.components))
        result.subtract(rhs)
        return result
    }
    
    @inlinable
    static func -=(lhs: inout Self, rhs: Self){
        lhs.subtract(rhs)
    }
    
    @inlinable
    mutating func subtract(_ other: Self, scaling: T) {
        add(other, scaling: -scaling)
    }
    
    @inlinable
    mutating func subtract(_ other: Self) {
        subtract(other, scaling: 1.0)
    }
    
    //MARK: Dot product
    /// Computes the Euclidian dot product.
    @inlinable
    func dot(_ other: Self) -> T {
        if let sdot = BLAS.sdot {
            precondition(count == other.count)
            let N = cblas_int(count)
            return sdot(N, components, 1, other.components, 1)
        } else {
            return _dot(other)
        }
    }
    
    //MARK: Vector matrix multiply
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
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if let sgemv = BLAS.sgemv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.transpose.rawValue
            let m = cblas_int(matrix.rows)
            let n = cblas_int(matrix.columns)
            let lda = n
            let beta: T = .zero
            sgemv(layout, trans, m, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
    
    //MARK: Vector - symmetrix matrix multiply
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotSymmetric(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotSymmetric(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, into: inout Self) {
        dotSymmetric(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if let ssymv = BLAS.ssymv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            // Use lower since we want X*A
            let uplo = BLAS.UpperLower.lower.rawValue
            let n = cblas_int(matrix.rows)
            let lda = n
            let beta: T = .zero
            ssymv(layout, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
        } else {
            //TODO: Implement vector - hermitian matrix multiply (default implementation)
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
}

//MARK: Copying components
public extension Vector<Float> {
    @inlinable
    mutating func copyComponents(from other: Self) {
        precondition(count == other.count)
        if let scopy = BLAS.scopy {
            let N = cblas_int(count)
            scopy(N, other.components, 1, &components, 1)
        } else {
            for i in 0..<count {
                components[i] = other.components[i]
            }
        }
    }
}
