//
//  Matrix Dot Vector Symmetric.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Symmetric Matrix-Vector multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func symmetricDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, multiplied: 1.0, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let dsymv = BLAS.dsymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, multiplied, elements, lda, vector, 1, .zero, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: into)
        }
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let dsymv = BLAS.dsymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, 1.0, elements, lda, vector, 1, .zero, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, into: into)
        }
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Double> and take addingInto as UnsafeMutablePointer<Double>
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let dsymv = BLAS.dsymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, multiplied, elements, lda, vector, 1, 1.0, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let dsymv = BLAS.dsymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, 1.0, elements, lda, vector, 1, 1.0, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, addingInto: into)
        }
    }
}

//MARK: Symmetric Matrix-Vector multiplication for Float
public extension Matrix<Float> {
    @inlinable
    func symmetricDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, multiplied: 1.0, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func symmetricDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let ssymv = BLAS.ssymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            ssymv(order, uplo, N, multiplied, elements, lda, vector, 1, .zero, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: into)
        }
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let ssymv = BLAS.ssymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            ssymv(order, uplo, N, 1.0, elements, lda, vector, 1, .zero, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, into: into)
        }
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Double> and take addingInto as UnsafeMutablePointer<Double>
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let ssymv = BLAS.ssymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            ssymv(order, uplo, N, multiplied, elements, lda, vector, 1, 1.0, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if rows * columns > 400, let ssymv = BLAS.ssymv {
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            ssymv(order, uplo, N, 1.0, elements, lda, vector, 1, 1.0, into, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, addingInto: into)
        }
    }
}

@inlinable
public func symmetricMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let dsymv = BLAS.dsymv, matrixRows &* matrixColumns > 1000 {
        let order = BLAS.Order.rowMajor.rawValue
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
public func symmetricMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2, matrixRows &* matrixColumns > 1000 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let ssymv = BLAS.ssymv {
        let order = BLAS.Order.rowMajor.rawValue
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
