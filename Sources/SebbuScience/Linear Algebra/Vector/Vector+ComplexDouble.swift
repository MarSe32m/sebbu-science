//
//  Vector+ComplexDouble.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

#if canImport(COpenBLAS)
import COpenBLAS
#endif

#if canImport(Accelerate)
import Accelerate
#endif

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
    
    //@inlinable
    mutating func multiply(by: T) {
#if os(Windows) || os(Linux)
        if let cblas_zscal = BLAS.zscal {
            var alpha: T = by
            cblas_zscal(numericCast(count), &alpha, &components, 1)
        } else {
            _multiply(by: by)
        }
#elseif os(macOS)
        withUnsafePointer(to: by) { alpha in
            components.withUnsafeMutableBufferPointer { X in
                cblas_zscal(X.count, OpaquePointer(alpha), OpaquePointer(X.baseAddress), 1)
            }
        }
#else
        _multiply(by: by)
#endif
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
    
    
    //@inlinable
    mutating func add(_ other: Self, scaling: T) {
#if os(Windows) || os(Linux)
        if let cblas_zaxpy = BLAS.zaxpy {
            precondition(other.count == self.count)
            let N: Int32 = numericCast(count)
            var alpha: T = scaling
            cblas_zaxpy(N, &alpha, other.components, 1, &components, 1)
        } else {
            _add(other, scaling: scaling)
        }
#elseif os(macOS)
        precondition(other.count == self.count)
        let N = count
        withUnsafePointer(to: scaling) { alpha in
            other.components.withUnsafeBufferPointer { X in
                components.withUnsafeMutableBufferPointer { Y in
                    cblas_zaxpy(N,
                                OpaquePointer(alpha),
                                OpaquePointer(X.baseAddress),
                                1,
                                OpaquePointer(Y.baseAddress),
                                1)
                }
            }
        }
#else
        _add(other, scaling: scaling)
#endif
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
#if os(Windows) || os(Linux)
        if let cblas_zdotu_sub = BLAS.zdotu_sub {
            precondition(other.count == count)
            let N: Int32 = numericCast(count)
            var result: T = .zero
            cblas_zdotu_sub(N, components, 1, other.components, 1, &result)
            return result
        } else {
            return _dot(other)
        }
#elseif os(macOS)
        precondition(other.count == count)
        var result: T = .zero
        withUnsafeMutablePointer(to: &result) { result in
            components.withUnsafeBufferPointer { X in
                other.components.withUnsafeBufferPointer { Y in
                    cblas_zdotu_sub(count,
                                    OpaquePointer(X.baseAddress),
                                    1,
                                    OpaquePointer(Y.baseAddress),
                                    1,
                                    OpaquePointer(result))
                }
            }
        }
        return result
#else
        _dot(other)
#endif
    }
    
    //MARK: Inner product
    //@inlinable
    func inner(_ other: Self) -> T {
#if os(Windows) || os(Linux)
        if let cblas_zdotc_sub = BLAS.zdotc_sub {
            precondition(other.count == count)
            let N: Int32 = numericCast(count)
            var result: T = .zero
            cblas_zdotc_sub(N, components, 1, other.components, 1, &result)
            return result
        } else {
            return _inner(other)
        }
#elseif os(macOS)
        precondition(other.count == count)
        var result: T = .zero
        withUnsafeMutablePointer(to: &result) { result in
            components.withUnsafeBufferPointer { X in
                other.components.withUnsafeBufferPointer { Y in
                    cblas_zdotc_sub(count,
                                    OpaquePointer(X.baseAddress),
                                    1,
                                    OpaquePointer(Y.baseAddress),
                                    1,
                                    OpaquePointer(result))
                }
            }
        }
        return result
#else
        _inner(other)
#endif
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
    
    //@inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
#if os(Windows) || os(Linux)
        if let cblas_zgemv = BLAS.zgemv {
            precondition(matrix.rows == self.count)
            precondition(matrix.columns == into.count)
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m: Int32 = numericCast(matrix.rows)
            let n: Int32 = numericCast(matrix.columns)
            let lda: Int32 = n
            var alpha: T = multiplied
            var beta: T = .zero
            cblas_zgemv(layout, trans, m, n, &alpha, matrix.elements, lda, components, 1, &beta, &into.components, 1)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
#elseif os(macOS)
        let beta: T = .zero
        let lda = matrix.columns
        withUnsafePointer(to: multiplied) { alpha in
            withUnsafePointer(to: beta) { beta in
                matrix.elements.withUnsafeBufferPointer { A in
                    components.withUnsafeBufferPointer { X in
                        into.components.withUnsafeMutableBufferPointer { Y in
                            cblas_zgemv(CblasRowMajor,
                                        CblasTrans,
                                        matrix.rows,
                                        matrix.columns,
                                        OpaquePointer(alpha),
                                        OpaquePointer(A.baseAddress),
                                        lda,
                                        OpaquePointer(X.baseAddress),
                                        1,
                                        OpaquePointer(beta),
                                        OpaquePointer(Y.baseAddress),
                                        1)
                        }
                    }
                }
            }
        }
#else
        _dot(matrix, multiplied: multiplied, into: &into)
#endif
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
    
    //@inlinable
    mutating func multiply(by: Double) {
#if os(Windows) || os(Linux)
        if let cblas_zdscal = BLAS.zdscal {
            cblas_zdscal(numericCast(components.count), by, &components, 1)
        } else {
            multiply(by: Complex(by))
        }
#elseif os(macOS)
        components.withUnsafeMutableBufferPointer { X in
            cblas_zdscal(X.count, by, OpaquePointer(X.baseAddress), 1)
        }
#else
        multiply(by: Complex(by))
#endif
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
