//
//  Vector Dot Matrix Hermitian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import NumericsExtensions

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
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .zero
        BLAS.zhemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.zhemv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .one
        BLAS.zhemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .one
        BLAS.zhemv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotHermitianBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .zero
        BLAS.chemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .zero
        BLAS.chemv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let alpha: T = .one
        let beta: T = .one
        BLAS.chemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotHermitianBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let order: BLAS.Order = .columnMajor
        let uplo: BLAS.UpLo = .upper
        let n = matrix.rows
        let lda = n
        let beta: T = .one
        BLAS.chemv(order, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }
}

@inlinable
public func vecHermitianMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.zhemv(.columnMajor, .upper, matrixRows, multiplier, matrix, matrixRows, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func vecHermitianMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.chemv(.columnMajor, .upper, matrixRows, multiplier, matrix, matrixRows, vector, 1, resultMultiplier, resultVector, 1)
}
