//
//  Vector Dot Matrix Symmetric.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import NumericsExtensions

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
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.dsymv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.dsymv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.dsymv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = 1.0
        BLAS.dsymv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotSymmetricBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.ssymv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.ssymv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.ssymv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotSymmetricBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = 1.0
        BLAS.ssymv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }
}

@inlinable
public func vecSymmetricMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.dsymv(.columnMajor, .upper, matrixRows, multiplier, matrix, matrixRows, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func vecSymmetricMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.ssymv(.columnMajor, .upper, matrixRows, multiplier, matrix, matrixRows, vector, 1, resultMultiplier, resultVector, 1)
}
