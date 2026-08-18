// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Hermitian Vector-Matrix multiplication for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, into: &into)
    }

    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .zero
        BLAS.zhemv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.zhemv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .one
        BLAS.zhemv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .one
        BLAS.zhemv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }
}

//MARK: Hermitian Vector-Matrix multiplication for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, into: &into)
    }

    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .zero
        BLAS.chemv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.chemv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .one
        BLAS.chemv(layout: order, triangle: uplo, n: n, alpha: alpha, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Layout = .columnMajor
        let uplo: BLAS.Triangle = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .one
        BLAS.chemv(layout: order, triangle: uplo, n: n, alpha: multiplied, a: matrix.elements, lda: lda, x: components, incX: 1, beta: beta, y: &into.components, incY: 1)
    }
}

@inlinable
public func vecHermitianMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.zhemv(layout: .columnMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func vecHermitianMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.chemv(layout: .columnMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}
