//
//  Vector+ComplexDouble.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import BLAS

import RealModule
import ComplexModule
import SebbuCollections

public extension Vector<Complex<Double>> {
    @inlinable
    var norm: Double {
        normSquared.squareRoot()
    }
    
    @inlinable
    var normSquared: Double {
        self.inner(self).real
    }
    
    @inlinable
    var conjugate: Self { Vector(components.map { $0.conjugate }) }
    
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
        if let zscal = BLAS.zscal {
            let N = cblas_int(count)
            withUnsafePointer(to: by) { alpha in
                zscal(N, alpha, &components, 1)
            }
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
            for i in 0..<components.count {
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
    
    
    @inlinable
    mutating func add(_ other: Self, scaling: T) {
        if let zaxpy = BLAS.zaxpy {
            let N = cblas_int(count)
            withUnsafePointer(to: scaling) { alpha in
                zaxpy(N, alpha, other.components, 1, &components, 1)
            }
        } else {
            _add(other, scaling: scaling)
        }
    }
    
    @inlinable
    mutating func add(_ other: Self) {
        add(other, scaling: .one)
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
        subtract(other, scaling: .one)
    }
    
    //MARK: Dot product
    /// Computes the Euclidian dot product. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>``` and ```Vector<Complex<Double>>``` use ```inner(_:)``` for a proper inner product
    //@inlinable
    func dot(_ other: Self) -> T {
        if let zdotu_sub = BLAS.zdotu_sub {
            precondition(count == other.count)
            let N = cblas_int(count)
            var result: T = .zero
            zdotu_sub(N, components, 1, other.components, 1, &result)
            return result
        } else {
            return _dot(other)
        }
    }
    
    //MARK: Inner product
    //@inlinable
    func inner(_ other: Self) -> T {
        if let zdotc_sub = BLAS.zdotc_sub {
            precondition(count == other.count)
            let N = cblas_int(count)
            var result: T = .zero
            zdotc_sub(N, components, 1, other.components, 1, &result)
            return result
        } else {
            return _inner(other)
        }
    }

    @inlinable
    internal func _inner(_ other: Self) -> T {
        precondition(self.count == other.count)
        var result: T = .zero
        for i in 0..<self.count {
            result = Relaxed.multiplyAdd(self[i].conjugate, other[i], result)
        }
        return result
    }
    
    @inlinable
    func inner(_ other: Self, metric: Matrix<T>) -> T {
        precondition(other.count == metric.columns)
        precondition(count == metric.rows)
        var result: T = .zero
        for i in 0..<components.count {
            for j in 0..<other.components.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i].conjugate, metric[i ,j]), other[j], result)
            }
        }
        return result
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
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: .one, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if let zgemv = BLAS.zgemv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.transpose.rawValue
            let m = cblas_int(matrix.rows)
            let n = cblas_int(matrix.columns)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
    
    //MARK: Vector - hermitian matrix multiply
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, into: inout Self) {
        dotHermitian(matrix, multiplied: .one, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if let zhemv = BLAS.zhemv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            // We use column major since we want to use the transpose of the matrix here
            let order = BLAS.Layout.columnMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let n = cblas_int(matrix.rows)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zhemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
        } else {
            //TODO: Implement vector - hermitian matrix multiply (default implementation)
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
}

public extension Vector<Complex<Double>> {
    //MARK: Addition
    @inlinable
    mutating func add(_ other: Self, scaling: Double) {
        add(other, scaling: Complex(scaling))
    }
    
    //MARK: Subtract
    @inlinable
    mutating func subtract(_ other: Self, scaling: Double) {
        add(other, scaling: Complex(-scaling))
    }
    
    //MARK: Scaling
    @inlinable
    static func *(lhs: Double, rhs: Self) -> Self {
        var result = Vector(Array(rhs.components))
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        if let zdscal = BLAS.zdscal {
            let N = cblas_int(count)
            zdscal(N, by, &components, 1)
        } else {
            for i in 0..<components.count {
                components[i].real = Relaxed.product(components[i].real, by)
                components[i].imaginary = Relaxed.product(components[i].imaginary, by)
            }
        }
    }
    
    //MARK: Division
    @inlinable
    static func /(lhs: Self, rhs: Double) -> Self {
        var result = Vector(Array(lhs.components))
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Double) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: Double) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
}

//MARK: Copying components
public extension Vector<Complex<Double>> {
    @inlinable
    mutating func copyComponents(from other: Self) {
        precondition(count == other.count)
        if let zcopy = BLAS.zcopy {
            let N = cblas_int(count)
            zcopy(N, other.components, 1, &components, 1)
        } else {
            for i in 0..<count {
                components[i] = other.components[i]
            }
        }
    }
}
