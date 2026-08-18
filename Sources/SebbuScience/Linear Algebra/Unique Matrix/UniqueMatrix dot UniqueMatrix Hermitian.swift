// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import Numerics
import SebbuBLAS

public extension UniqueMatrix where T: ConjugatableScalar {
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: borrowing Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, into: &result)
        return result
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: borrowing Self, into: inout Self) {
        //TODO: Implement an optimized version utilizing the hermitian property
        dot(other, into: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T, into: inout Self) {
        //TODO: Implement an optimized version utilizing the hermitian property
        dot(other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: borrowing Self, addingInto into: inout Self) {
        //TODO: Implement an optimized version utilizing the hermitian property
        dot(other, addingInto: &into)
    }
    
    @inlinable
    func dot(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T, addingInto into: inout Self) {
        //TODO: Implement an optimized version utilizing the hermitian property
        dot(other, multiplied: multiplied, addingInto: &into)
    }
}

//MARK: Hermitian Matrix-Matrix multiplication for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    func dotBLAS(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T = .one) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &result)
        return result
    }

    @inlinable
    func dotBLAS(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T = .one, into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let beta: T = .zero
        switch hermitianSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zhemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: self.elements, lda: lda, b: other.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zhemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: other.elements, lda: lda, b: self.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        }
    }

    @inlinable
    func dotBLAS(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T = .one, addingInto into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let beta: T = .one
        switch hermitianSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zhemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: self.elements, lda: lda, b: other.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zhemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: other.elements, lda: lda, b: self.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        }
    }
}

//MARK: Hermitian Matrix-Matrix multiplication for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    func dotBLAS(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T = .one) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(hermitianSide: hermitianSide, other, multiplied: multiplied, into: &result)
        return result
    }

    @inlinable
    func dotBLAS(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T = .one, into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let beta: T = .zero
        switch hermitianSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.chemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: self.elements, lda: lda, b: other.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.chemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: other.elements, lda: lda, b: self.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        }
    }

    @inlinable
    func dotBLAS(hermitianSide: HermitianSide, _ other: borrowing Self, multiplied: T = .one, addingInto into: inout Self) {
        let order: BLAS.Layout = .rowMajor
        let side: BLAS.Side = hermitianSide == .left ? .left : .right
        let uplo: BLAS.Triangle = .upper
        let beta: T = .one
        switch hermitianSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.chemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: self.elements, lda: lda, b: other.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.chemm(layout: order, side: side, triangle: uplo, m: m, n: n, alpha: multiplied, a: other.elements, lda: lda, b: self.elements, ldb: ldb, beta: beta, c: into.elements, ldc: ldc)
        }
    }
}
