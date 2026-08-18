// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

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
        _dot(other, into: &into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: alpha, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        _dot(other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        _dot(other, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: alpha, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        _dot(other, multiplied: multiplied, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.dsymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
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
        _dot(other, into: &into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: alpha, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        _dot(other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = .zero
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        _dot(other, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let alpha: T = 1.0
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: alpha, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }

    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        _dot(other, multiplied: multiplied, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = A.rows, n = B.columns
        let beta: T = 1.0
        let lda = columns, ldb = n, ldc = n
        BLAS.ssymm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: A.elements, lda: lda, b: B.elements, ldb: ldb, beta: beta, c: &into.elements, ldc: ldc)
    }
}
