//
//  Matrix Dot Matrix Hermitian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

import NumericsExtensions

//MARK: Hermitian Matrix-Matrix multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, multiplied: .one, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ other: Self) -> Self {
        dot(hermitianSide: .left, other)
    }
    
    @inlinable
    func dotHermitian(_ other: Self) -> Self {
        dot(hermitianSide: .right, other)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ other: Self, multiplied: T) -> Self {
        dot(hermitianSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T) -> Self {
        dot(hermitianSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, into: inout Self) {
        dot(hermitianSide: hermitianSide, other, multiplied: .one, into: &into)
    }
    
    @inlinable
    func hermitianDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, addingInto into: inout Self) {
        dot(hermitianSide: hermitianSide, other, multiplied: .one, addingInto: &into)
    }
    
    @inlinable
    func hermitianDot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(hermitianSide: .left, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(hermitianSide: .right, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide = .left, _ other: Self, multiplied: T, into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = hermitianSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let beta: T = .zero
        let lda = blasint(columns), ldb = n, ldc = n
        withUnsafePointer(to: multiplied) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_zhemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
            }

        }
        #elseif canImport(Accelerate)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        #error("TODO: Reimplement")
        if let zhemm = BLAS.zhemm {
            let order = BLAS.Order.rowMajor.rawValue
            let _side = hermitianSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = hermitianSide == .left ? self : other
            let B = hermitianSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let beta: T = .zero
            let lda = cblas_int(columns), ldb = n, ldc = n
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zhemm(order, _side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, into: &into)
        }
        #else
        //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, into: &into)
        #endif
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide = .left, _ other: Self, multiplied: T, addingInto into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = hermitianSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let beta: T = .one
        let lda = blasint(columns), ldb = n, ldc = n
        withUnsafePointer(to: multiplied) { alpha in
            withUnsafePointer(to: beta) { beta in
                cblas_zhemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
            }
        }
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
        if let zhemm = BLAS.zhemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = hermitianSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = hermitianSide == .left ? self : other
            let B = hermitianSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let beta: T = .one
            let lda = cblas_int(columns), ldb = n, ldc = n
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zhemm(order, _side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
        #else
        //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, addingInto: &into)
        #endif
    }
}

//MARK: Hermitian Matrix-Matrix multiplication for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, multiplied: .one, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ other: Self) -> Self {
        dot(hermitianSide: .left, other)
    }
    
    @inlinable
    func dotHermitian(_ other: Self) -> Self {
        dot(hermitianSide: .right, other)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ other: Self, multiplied: T) -> Self {
        dot(hermitianSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T) -> Self {
        dot(hermitianSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, into: inout Self) {
        dot(hermitianSide: hermitianSide, other, multiplied: .one, into: &into)
    }
    
    @inlinable
    func hermitianDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, addingInto into: inout Self) {
        dot(hermitianSide: hermitianSide, other, multiplied: .one, addingInto: &into)
    }
    
    @inlinable
    func hermitianDot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(hermitianSide: .left, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(hermitianSide: .right, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T, into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = hermitianSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let beta: T = .zero
        let lda = blasint(columns), ldb = n, ldc = n
        withUnsafePointer(to: multiplied) { alpha in
            withUnsafePointer(to: beta) { beta in
                cblas_chemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
            }
        }
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
        if let chemm = BLAS.chemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = hermitianSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = hermitianSide == .left ? self : other
            let B = hermitianSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let beta: T = .zero
            let lda = cblas_int(columns), ldb = n, ldc = n
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    chemm(order, _side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, into: &into)
        }
        #else
        //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, into: &into)
        #endif
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = hermitianSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let beta: T = .one
        let lda = blasint(columns), ldb = n, ldc = n
        withUnsafePointer(to: multiplied) { alpha in
            withUnsafePointer(to: beta) { beta in
                cblas_chemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
            }
        }
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
        if let chemm = BLAS.chemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = hermitianSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = hermitianSide == .left ? self : other
            let B = hermitianSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let beta: T = .one
            let lda = cblas_int(columns), ldb = n, ldc = n
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    chemm(order, _side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
        #else
        //TODO: Implement hermitian matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, addingInto: &into)
        #endif
    }
}
