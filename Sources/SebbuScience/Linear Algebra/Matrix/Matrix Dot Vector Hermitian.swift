//
//  Matrix Dot Vector Hermitian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

//MARK: Hermitian Matrix-Vector multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func hermitianDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        hermitianDot(vector, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        hermitianDot(vector, into: &result)
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
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, multiplied: multiplied, into: into)
        } else {
            _dot(vector, multiplied: multiplied, into: into)
        }
    }
    
    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.zhemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }

    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, into: into)
        } else {
            _dot(vector, into: into)
        }
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .zero
        BLAS.zhemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, multiplied: multiplied, addingInto: into)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .one
        BLAS.zhemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, addingInto: into)
        } else {
            _dot(vector, addingInto: into)
        }
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .one
        BLAS.zhemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, multiplied: multiplied, into: into)
        } else {
            _dot(vector, multiplied: multiplied, into: into)
        }
    }
    
    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.chemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }

    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, into: into)
        } else {
            _dot(vector, into: into)
        }
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .zero
        BLAS.chemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, multiplied: multiplied, addingInto: into)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .one
        BLAS.chemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _hermitianDotBLAS(vector, addingInto: into)
        } else {
            _dot(vector, addingInto: into)
        }
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .one
        BLAS.chemv(order, uplo, N, alpha, elements, lda, vector, 1, beta, into, 1)
    }
}

@inlinable
public func hermitianMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.zhemv(.rowMajor, .upper, matrixRows, multiplier, matrix, matrixRows, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func hermitianMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.chemv(.rowMajor, .upper, matrixRows, multiplier, matrix, matrixRows, vector, 1, resultMultiplier, resultVector, 1)
}
