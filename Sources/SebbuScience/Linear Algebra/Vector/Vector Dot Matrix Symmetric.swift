//
//  Vector Dot Matrix Symmetric.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import BLAS
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
        dotSymmetric(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, addingInto into: inout Self) {
        dotSymmetric(matrix, multiplied: 1.0, addingInto: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if matrix.rows &* matrix.columns > 400, let dsymv = BLAS.dsymv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            // Use lower since we want X*A
            let uplo = BLAS.UpperLower.lower.rawValue
            let n = cblas_int(matrix.rows)
            let lda = n
            let beta: T = .zero
            dsymv(layout, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
        } else {
            //TODO: Implement vector - hermitian matrix multiply (default implementation)
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
   
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        if matrix.rows &* matrix.columns > 400, let dsymv = BLAS.dsymv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            // Use lower since we want X*A
            let uplo = BLAS.UpperLower.lower.rawValue
            let n = cblas_int(matrix.rows)
            let lda = n
            let beta: T = 1.0
            dsymv(layout, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
        } else {
            //TODO: Implement vector - hermitian matrix multiply (default implementation)
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
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
        dotSymmetric(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @_transparent
    func dotSymmetric(_ matrix: Matrix<T>, addingInto into: inout Self) {
        dotSymmetric(matrix, multiplied: 1.0, addingInto: &into)
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        if matrix.rows &* matrix.columns > 400, let ssymv = BLAS.ssymv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            // Use lower since we want X*A
            let uplo = BLAS.UpperLower.lower.rawValue
            let n = cblas_int(matrix.rows)
            let lda = n
            let beta: T = .zero
            ssymv(layout, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
        } else {
            //TODO: Implement vector - hermitian matrix multiply (default implementation)
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dotSymmetric(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        if matrix.rows &* matrix.columns > 400, let ssymv = BLAS.ssymv {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            // Use lower since we want X*A
            let uplo = BLAS.UpperLower.lower.rawValue
            let n = cblas_int(matrix.rows)
            let lda = n
            let beta: T = 1.0
            ssymv(layout, uplo, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
        } else {
            //TODO: Implement vector - hermitian matrix multiply (default implementation)
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }
}

@inlinable
public func vecSymmetricMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2, matrixRows &* matrixColumns > 1000 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let dsymv = BLAS.dsymv {
        let order = BLAS.Order.columnMajor.rawValue
        let uplo = BLAS.UpperLower.upper.rawValue
        let n = cblas_int(matrixRows)
        dsymv(order, uplo, n, multiplier, matrix, n, vector, 1, resultMultiplier, resultVector, 1)
    } else {
        var result: Double = .zero
        for i in 0..<matrixRows {
            result = .zero
            for j in 0..<matrixColumns {
                result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
            }
            resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
        }
    }
}

@inlinable
public func vecSymmetricMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2, matrixRows &* matrixColumns > 1000 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let ssymv = BLAS.ssymv {
        let order = BLAS.Order.columnMajor.rawValue
        let uplo = BLAS.UpperLower.upper.rawValue
        let n = cblas_int(matrixRows)
        ssymv(order, uplo, n, multiplier, matrix, n, vector, 1, resultMultiplier, resultVector, 1)
    } else {
        var result: Float = .zero
        for i in 0..<matrixRows {
            result = .zero
            for j in 0..<matrixColumns {
                result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
            }
            resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
        }
    }
}
