// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

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
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.zhemv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }

    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .zero
        BLAS.zhemv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = .one
        BLAS.zhemv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .one
        BLAS.zhemv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
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
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.chemv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }

    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .zero
        BLAS.chemv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingInto as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let beta: T = .one
        BLAS.chemv(layout: order, triangle: uplo, n: N, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
    
    @inlinable
    func hermitianDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    func _hermitianDotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Layout = .rowMajor
        let uplo: BLAS.Triangle = .upper
        let N = rows
        let lda = N
        let alpha: T = .one
        let beta: T = .one
        BLAS.chemv(layout: order, triangle: uplo, n: N, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: beta, y: into, incY: 1)
    }
}

@inlinable
public func hermitianMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.zhemv(layout: .rowMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func hermitianMatVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.chemv(layout: .rowMajor, triangle: .upper, n: matrixRows, alpha: multiplier, a: matrix, lda: matrixRows, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}
