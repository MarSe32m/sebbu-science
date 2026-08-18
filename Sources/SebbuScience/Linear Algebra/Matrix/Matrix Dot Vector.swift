// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions
import SebbuBLAS

//MARK: Matrix-Vector multiplication for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        _dot(vector, into: &into)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        _dot(vector, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        _dot(vector, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto: inout Vector<T>) {
        _dot(vector, multiplied: multiplied, addingInto: &addingInto)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: addingInto)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: addingInto)
    }

    @inlinable
    @_transparent
    func _dot(_ vector: Vector<T>, into: inout Vector<T>) {
        _dot(vector.components, into: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1]))
            into[1] = Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3]))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = result
        }
    }
    
    @inlinable
    @_transparent
    func _dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        _dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1])))
            into[1] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3])))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.product(result, multiplied)
        }
    }
    
    @inlinable
    @_transparent
    func _dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        _dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1])))
            into[1] = Relaxed.sum(into[1], Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3])))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.sum(result, into[i])
        }
    }
    
    @inlinable
    @_transparent
    func _dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        _dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1]))))
            into[1] = Relaxed.sum(into[1], Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3]))))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.multiplyAdd(result, multiplied, into[i])
        }
    }
}

//MARK: Matrix-Vector multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.dgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.dgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.dgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: 1.0, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.dgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: 1.0, y: into, incY: 1)
    }
}

//MARK: Matrix-Vector multiplication for Float
public extension Matrix<Float> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.sgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.sgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.sgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: 1.0, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.sgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: 1.0, y: into, incY: 1)
    }
}

//MARK: Matrix-Vector multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.zgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.zgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.zgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: .one, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.zgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: .one, y: into, incY: 1)
    }
}

//MARK: Matrix-Vector multiplication for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.cgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, into: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.cgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: .zero, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.cgemv(layout: layout, transpose: trans, m: m, n: n, alpha: alpha, a: elements, lda: lda, x: vector, incX: 1, beta: .one, y: into, incY: 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: into)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.cgemv(layout: layout, transpose: trans, m: m, n: n, alpha: multiplied, a: elements, lda: lda, x: vector, incX: 1, beta: .one, y: into, incY: 1)
    }
}

//MARK: General Matrix-Vector multiplication
@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.dgemv(layout: .rowMajor, transpose: .noTranspose, m: matrixRows, n: matrixColumns, alpha: multiplier, a: matrix, lda: vectorComponents, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>,  resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.sgemv(layout: .rowMajor, transpose: .noTranspose, m: matrixRows, n: matrixColumns, alpha: multiplier, a: matrix, lda: vectorComponents, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.zgemv(layout: .rowMajor, transpose: .noTranspose, m: matrixRows, n: matrixColumns, alpha: multiplier, a: matrix, lda: vectorComponents, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.cgemv(layout: .rowMajor, transpose: .noTranspose, m: matrixRows, n: matrixColumns, alpha: multiplier, a: matrix, lda: vectorComponents, x: vector, incX: 1, beta: resultMultiplier, y: resultVector, incY: 1)
}
