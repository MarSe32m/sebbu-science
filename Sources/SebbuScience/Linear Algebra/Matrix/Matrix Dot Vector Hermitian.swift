//
//  Matrix Dot Vector Hermitian.swift
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
    @_transparent
    func hermitianDot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func hermitianDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func hermitianDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func hermitianDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        //TODO: Benchmark when it is worth calling blas functions for this
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zhemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zhemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, multiplied: multiplied, into: into)
        #endif
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .zero
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zhemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            _dot(vector, into: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .zero
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zhemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            _dot(vector, into: into)
        }
        #else
        _dot(vector, into: into)
        #endif
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zhemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zhemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, multiplied: multiplied, addingInto: into)
        #endif
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .one
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zhemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, addingInto: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .one
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zhemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, addingInto: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, addingInto: into)
        #endif
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
    @_transparent
    func hermitianDot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func hermitianDot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func hermitianDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func hermitianDot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(rows == columns)
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        //TODO: Benchmark when it is worth calling blas functions for this
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_chemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_chemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, multiplied: multiplied, into: into)
        #endif
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        //TODO: Benchmark when it is worth calling blas functions for this
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .zero
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_chemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, into: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .zero
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_chemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, into: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, into: into)
        #endif
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_chemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_chemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, multiplied: multiplied, addingInto: into)
        #endif
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .one
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_chemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, addingInto: into)
        }
        #elseif canImport(Accelerate)
        if rows * columns > 400 {
            let order = CblasRowMajor
            let uplo = CblasUpper
            let N = blasint(rows)
            let lda = N
            let alpha: T = .one
            let beta: T = .one
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_chemv(order, uplo, N, .init(alpha), .init(elements.baseAddress), lda, .init(vector), 1, .init(beta), .init(into), 1)
                    }
                }
            }
        } else {
            //TODO: Implement hermitian matrix-vector multiplication (default implementation)
            _dot(vector, addingInto: into)
        }
        #else
        //TODO: Implement hermitian matrix-vector multiplication (default implementation)
        _dot(vector, addingInto: into)
        #endif
    }
}

@inlinable
public func hermitianMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_zhemv(order, uplo, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
        return
    }
    #elseif canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_zhemv(order, uplo, n, .init(alpha), .init(matrix), n, .init(vector), 1, .init(beta), .init(resultVector), 1)
            }
        }
        return
    }
    #endif
    var result: Complex<Double> = .zero
    for i in 0..<matrixRows {
        result = .zero
        for j in 0..<matrixColumns {
            result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
        }
        resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
    }
}

@inlinable
public func hermitianMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_chemv(order, uplo, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
        return
    }
    #elseif canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_chemv(order, uplo, n, .init(alpha), .init(matrix), n, .init(vector), 1, .init(beta), .init(resultVector), 1)
            }
        }
        return
    }
    #endif
    var result: Complex<Float> = .zero
    for i in 0..<matrixRows {
        result = .zero
        for j in 0..<matrixColumns {
            result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
        }
        resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
    }
}
