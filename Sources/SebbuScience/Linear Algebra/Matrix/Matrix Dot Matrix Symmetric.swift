//
//  Matrix Dot Matrix Symmetric.swift
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = symmetricSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let lda = blasint(columns), ldb = n, ldc = n
        cblas_dsymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, .zero, &into.elements, ldc)
        #else
        //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, into: &into)
        #endif
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = symmetricSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let lda = blasint(columns), ldb = n, ldc = n
        cblas_dsymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, 1.0, &into.elements, ldc)
        #else
        //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, addingInto: &into)
        #endif
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = symmetricSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let lda = blasint(columns), ldb = n, ldc = n
        cblas_ssymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, .zero, &into.elements, ldc)
        #else
        //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, into: &into)
        #endif
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, addingInto into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        let order = CblasRowMajor
        let side = symmetricSide == .left ? CblasLeft : CblasRight
        let uplo = CblasUpper
        let A = symmetricSide == .left ? self : other
        let B = symmetricSide == .right ? self : other
        let m = blasint(A.rows), n = blasint(B.columns)
        let lda = blasint(columns), ldb = n, ldc = n
        cblas_ssymm(order, side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, 1.0, &into.elements, ldc)
        #else
        //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
        _dot(other, multiplied: multiplied, addingInto: &into)
        #endif
    }
}
