// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Symmetric Matrix-Vector multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func symmetricDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, into: &result)
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
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.dsymv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }

    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.dsymv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = 1.0
        BLAS.dsymv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.dsymv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
}

//MARK: Hermitian Matrix-Vector multiplication for Complex<Float>
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
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.ssymv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }

    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.ssymv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = 1.0
        BLAS.ssymv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    @inlinable
    func symmetricDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    func _symmetricDotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.ssymv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
}

@inlinable
public func symmetricMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.dsymv(layout: .rowMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func symmetricMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.ssymv(layout: .rowMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}
