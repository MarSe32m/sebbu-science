//
//  Matrix Dot Vector.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

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
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, into: into)
        } else {
            _dot(vector, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.dgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, into: into)
        } else {
            _dot(vector, multiplied: multiplied, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.dgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, addingInto: into)
        } else {
            _dot(vector, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.dgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, 1.0, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, addingInto: into)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.dgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, 1.0, into, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, into: into)
        } else {
            _dot(vector, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.sgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, into: into)
        } else {
            _dot(vector, multiplied: multiplied, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.sgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, addingInto: into)
        } else {
            _dot(vector, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = 1.0
        BLAS.sgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, 1.0, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, addingInto: into)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.sgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, 1.0, into, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, into: into)
        } else {
            _dot(vector, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.zgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, into: into)
        } else {
            _dot(vector, multiplied: multiplied, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.zgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, addingInto: into)
        } else {
            _dot(vector, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.zgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .one, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, addingInto: into)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.zgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .one, into, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, into: into)
        } else {
            _dot(vector, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.cgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, into: into)
        } else {
            _dot(vector, multiplied: multiplied, into: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.cgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .zero, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, addingInto: into)
        } else {
            _dot(vector, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let alpha: T = .one
        BLAS.cgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .one, into, 1)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        if BLAS.isAvailable {
            //TODO: Benchmark when to dispatch to BLAS
            _dotBLAS(vector, multiplied: multiplied, addingInto: into)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        BLAS.cgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .one, into, 1)
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
    BLAS.dgemv(.rowMajor, .noTranspose, matrixRows, matrixColumns, multiplier, matrix, vectorComponents, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>,  resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.sgemv(.rowMajor, .noTranspose, matrixRows, matrixColumns, multiplier, matrix, vectorComponents, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.zgemv(.rowMajor, .noTranspose, matrixRows, matrixColumns, multiplier, matrix, vectorComponents, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    BLAS.cgemv(.rowMajor, .noTranspose, matrixRows, matrixColumns, multiplier, matrix, vectorComponents, vector, 1, resultMultiplier, resultVector, 1)
}
