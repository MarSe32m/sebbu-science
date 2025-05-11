//
//  Matrix Dot Matrix Symmetric.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Symmetric Matrix-Matrix multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self) -> Self {
        dot(symmetricSide: .left, other)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self) -> Self {
        dot(symmetricSide: .right, other)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    func dot(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, addingInto: &into)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        if let dsymm = BLAS.dsymm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = symmetricSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = symmetricSide == .left ? self : other
            let B = symmetricSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let lda = cblas_int(columns), ldb = n, ldc = n
            dsymm(order, _side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, .zero, &into.elements, ldc)
        } else {
            //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        if let dsymm = BLAS.dsymm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = symmetricSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = symmetricSide == .left ? self : other
            let B = symmetricSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let lda = cblas_int(columns), ldb = n, ldc = n
            dsymm(order, _side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, 1.0, &into.elements, ldc)
        } else {
            //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }
}

//MARK: Symmetric Matrix-Matrix multiplication for Float
public extension Matrix<Float> {
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self) -> Self {
        dot(symmetricSide: .left, other)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self) -> Self {
        dot(symmetricSide: .right, other)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    @_transparent
    func dot(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(symmetricSide: SymmetricSide, _ other: Self, addingInto into: inout Self) {
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, addingInto: &into)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ other: Self, multiplied: T, addingInto into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, addingInto: &into)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        if let ssymm = BLAS.ssymm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = symmetricSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = symmetricSide == .left ? self : other
            let B = symmetricSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let lda = cblas_int(columns), ldb = n, ldc = n
            ssymm(order, _side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, .zero, &into.elements, ldc)
        } else {
            //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        if let ssymm = BLAS.ssymm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = symmetricSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = symmetricSide == .left ? self : other
            let B = symmetricSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let lda = cblas_int(columns), ldb = n, ldc = n
            ssymm(order, _side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, 1.0, &into.elements, ldc)
        } else {
            //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }
}
