//
//  Matrix Dot Matrix Symmetric.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

//MARK: Symmetric Matrix-Matrix multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ other: Self) -> Self {
        dot(symmetricSide: .left, other)
    }
    
    @inlinable
    func dotHermitian(_ other: Self) -> Self {
        dot(symmetricSide: .right, other)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, into: inout Self) {
        dot(symmetricSide: .left, other, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, into: inout Self) {
        dot(symmetricSide: .right, other, into: &into)
    }

    @inlinable
    func symmetricDot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, addingInto into: inout Self) {
        dot(symmetricSide: .left, other, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, addingInto into: inout Self) {
        dot(symmetricSide: .right, other, addingInto: &into)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }
}

//MARK: Symmetric Matrix-Matrix multiplication for Float
public extension Matrix<Float> {
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ other: Self) -> Self {
        dot(symmetricSide: .left, other)
    }
    
    @inlinable
    func dotHermitian(_ other: Self) -> Self {
        dot(symmetricSide: .right, other)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, into: inout Self) {
        dot(symmetricSide: .left, other, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, into: inout Self) {
        dot(symmetricSide: .right, other, into: &into)
    }

    @inlinable
    func symmetricDot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, addingInto into: inout Self) {
        dot(symmetricSide: .left, other, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ other: Self, addingInto into: inout Self) {
        dot(symmetricSide: .right, other, addingInto: &into)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(order, side, uplo, m, n, alpha, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, beta, &into.elements, ldc)
    }
}