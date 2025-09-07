//
//  Matrix Dot Matrix Hermitian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

//MARK: Hermitian Matrix-Matrix multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, into: &result)
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
    func hermitianDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func hermitianDot(_ other: Self, into: inout Self) {
        dot(hermitianSide: .left, other, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, into: inout Self) {
        dot(hermitianSide: .right, other, into: &into)
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
    func hermitianDot(_ other: Self, addingInto into: inout Self) {
        dot(hermitianSide: .left, other, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, addingInto into: inout Self) {
        dot(hermitianSide: .right, other, addingInto: &into)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = .one
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.zhemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.zhemm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = .one
        let beta: T = .one
        let lda = columns, ldb = n, ldc = n
        BLAS.zhemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .one
        let lda = columns, ldb = n, ldc = n
        BLAS.zhemm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }
}

//MARK: Hermitian Matrix-Matrix multiplication for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, into: &result)
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
    func hermitianDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, into: inout Self) {
        dot(hermitianSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func hermitianDot(_ other: Self, into: inout Self) {
        dot(hermitianSide: .left, other, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, into: inout Self) {
        dot(hermitianSide: .right, other, into: &into)
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
    func hermitianDot(_ other: Self, addingInto into: inout Self) {
        dot(hermitianSide: .left, other, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, addingInto into: inout Self) {
        dot(hermitianSide: .right, other, addingInto: &into)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = .one
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.chemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.chemm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = .one
        let beta: T = .one
        let lda = columns, ldb = n, ldc = n
        BLAS.chemm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(hermitianSide: hermitianSide, other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(hermitianSide: HermitianSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = hermitianSide == .left ? self : other
        let B = hermitianSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .one
        let lda = columns, ldb = n, ldc = n
        BLAS.chemm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }
}