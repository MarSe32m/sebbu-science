//
//  Matrix Dot Vector Hermitian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Hermitian Matrix-Vector multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func hermitianDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        hermitianDot(vector, multiplied: .one, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        hermitianDot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, into: inout Vector<T>) {
        hermitianDot(vector, multiplied: .one, into: &into)
    }
    
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        hermitianDot(vector, multiplied: .one, addingInto: &into)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take into as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        //TODO: Benchmark when it is worth calling blas functions for this
        if let zhemv = BLAS.zhemv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zhemv(order, uplo, N, alpha, elements, lda, vector.components, 1, beta, &into.components, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        //TODO: Benchmark when it is worth calling blas functions for this
        if let zhemv = BLAS.zhemv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zhemv(order, uplo, N, alpha, elements, lda, vector.components, 1, beta, &into.components, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}

//MARK: Hermitian Matrix-Vector multiplication for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    func hermitianDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        hermitianDot(vector, multiplied: .one, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        hermitianDot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, into: inout Vector<T>) {
        hermitianDot(vector, multiplied: .one, into: &into)
    }
    
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        hermitianDot(vector, multiplied: .one, addingInto: &into)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Float>> and take into as UnsafeMutablePointer<Complex<Float>>
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let chemv = BLAS.chemv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    chemv(order, uplo, N, alpha, elements, lda, vector.components, 1, beta, &into.components, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Float>> and take into as UnsafeMutablePointer<Double>
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let chemv = BLAS.chemv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    chemv(order, uplo, N, alpha, elements, lda, vector.components, 1, beta, &into.components, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}
