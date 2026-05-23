//
//  UniqueMatrix dot UniqueMatrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 22.5.2026.
//

import NumericsExtensions

//MARK: Matrix-Matrix multiplication for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    func dot(_ other: borrowing Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: borrowing Self, multiplied: T) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: borrowing Self, into: inout Self) {
        precondition(columns == other.rows && rows == into.rows && other.columns == into.columns)
        for i in 0..<rows {
            for j in 0..<other.columns { into[unchecked: i, unchecked: j] = .zero }
            for k in 0..<columns {
                let A = self[unchecked: i, unchecked: k]
                for j in 0..<other.columns {
                    into[unchecked: i, unchecked: j] = Relaxed.multiplyAdd(A, other[unchecked: k, unchecked: j], into[unchecked: i, unchecked: j])
                }
            }
        }
    }
    
    @inlinable
    func dot(_ other: borrowing Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows && rows == into.rows && other.columns == into.columns)
        for i in 0..<rows {
            for j in 0..<other.columns { into[unchecked: i, unchecked: j] = .zero }
            for k in 0..<columns {
                let A = Relaxed.product(self[unchecked: i, unchecked: k], multiplied)
                for j in 0..<other.columns {
                    into[unchecked: i, unchecked: j] = Relaxed.multiplyAdd(A, other[unchecked: k, unchecked: j], into[unchecked: i, unchecked: j])
                }
            }
        }
    }
    
    @inlinable
    func dot(_ other: borrowing Self, addingInto into: inout Self) {
        precondition(columns == other.rows && rows == into.rows && other.columns == into.columns)
        for i in 0..<rows {
            for k in 0..<columns {
                let A = self[unchecked: i, unchecked: k]
                for j in 0..<other.columns {
                    into[unchecked: i, unchecked: j] = Relaxed.multiplyAdd(A, other[unchecked: k, unchecked: j], into[unchecked: i, unchecked: j])
                }
            }
        }
    }
    
    @inlinable
    func dot(_ other: borrowing Self, multiplied: T, addingInto into: inout Self) {
        precondition(columns == other.rows && rows == into.rows && other.columns == into.columns)
        for i in 0..<rows {
            for k in 0..<columns {
                let A = Relaxed.product(self[unchecked: i, unchecked: k], multiplied)
                for j in 0..<other.columns {
                    into[unchecked: i, unchecked: j] = Relaxed.multiplyAdd(A, other[unchecked: k, unchecked: j], into[unchecked: i, unchecked: j])
                }
            }
        }
    }
}

//MARK: Matrix-Matrix multiplication for Double
public extension UniqueMatrix<Double> {
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = 1.0) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = 1.0, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, into.elements, ldc)
    }

    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = 1.0, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 1.0, into.elements, ldc)
    }
}

//MARK: Matrix-Matrix multiplication for Float
public extension UniqueMatrix<Float> {
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = 1.0) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.sgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, into.elements, ldc)
    }
    
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.sgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 1.0, into.elements, ldc)
    }
}

//MARK: Matrix-Matrix multiplication for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = .one) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = .one, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.zgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .zero, into.elements, ldc)
    }

    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = .one, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.zgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .one, into.elements, ldc)
    }
}

//MARK: Matrix-Matrix multiplication for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = .one) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = .one, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.cgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .zero, into.elements, ldc)
    }
    
    @inlinable
    func dotBLAS(_ other: borrowing Self, multiplied: T = .one, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.cgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .one, into.elements, ldc)
    }
}

