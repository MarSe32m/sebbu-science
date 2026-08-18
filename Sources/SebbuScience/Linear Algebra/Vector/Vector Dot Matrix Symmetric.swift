// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Symmetric Vector-Matrix multiplication for Double
public extension Vector<Double> {
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotSymmetric(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotSymmetric(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, into: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, into: &into)
    }

    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, addingInto: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.dsymv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.dsymv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.dsymv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = 1.0
        BLAS.dsymv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }
}

//MARK: Symmetric Vector-Matrix multiplication for Float
public extension Vector<Float> {
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotSymmetric(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotSymmetric(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, into: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, into: &into)
    }

    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, addingInto: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.ssymv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.ssymv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.ssymv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = 1.0
        BLAS.ssymv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }
}

@inlinable
public func vecSymmetricMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.dsymv(layout: .columnMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func vecSymmetricMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.ssymv(layout: .columnMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}
