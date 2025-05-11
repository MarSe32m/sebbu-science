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
    func symmetricDot(_ vector: Vector<T>, into: inout Vector<T>) {
        symmetricDot(vector, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        symmetricDot(vector, multiplied: 1.0, addingInto: &into)
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Double> and take into as UnsafeMutablePointer<Double>
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let dsymv = BLAS.dsymv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, multiplied, elements, lda, vector.components, 1, .zero, &into.components, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Double> and take addingInto as UnsafeMutablePointer<Double>
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let dsymv = BLAS.dsymv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, multiplied, elements, lda, vector.components, 1, 1.0, &into.components, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: &into)
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
    func symmetricDot(_ vector: Vector<T>, into: inout Vector<T>) {
        symmetricDot(vector, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        symmetricDot(vector, multiplied: 1.0, addingInto: &into)
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Float> and take into as UnsafeMutablePointer<Float>
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let ssymv = BLAS.ssymv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            ssymv(order, uplo, N, multiplied, elements, lda, vector.components, 1, .zero, &into.components, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Float> and take addingInto as UnsafeMutablePointer<Float>
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let ssymv = BLAS.ssymv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            ssymv(order, uplo, N, multiplied, elements, lda, vector.components, 1, 1.0, &into.components, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}
