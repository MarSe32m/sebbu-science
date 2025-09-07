//
//  Vector Dot Matrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import NumericsExtensions

//MARK: Vector-Matrix multiplication for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        _dot(matrix, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto: inout Self) {
        _dot(matrix, addingInto: &addingInto)
    }

    @inlinable
    func _dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2]))
            into[1] = Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3]))
            return
        }
        for i in 0..<into.count { into[i] = .zero }
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(self[j], matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto: inout Self) {
        _dot(matrix, multiplied: multiplied, addingInto: &addingInto)
    }

    @inlinable
    func _dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2])))
            into[1] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3])))
            return
        }
        for i in 0..<into.count { into[i] = .zero }
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[j], multiplied)
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(C, matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    func _dot(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2])))
            into[1] = Relaxed.sum(into[1], Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3])))
            return
        }
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(self[j], matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    func _dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2]))))
            into[1] = Relaxed.sum(into[1], Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3]))))
            return
        }
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[j], multiplied)
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(C, matrix[j, i], into[i])
            }
        }
    }
}

//MARK: Vector-Matrix multiplication for Double
public extension Vector<Double> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.dgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.dgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.dgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = 1.0
        BLAS.dgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }
}

//MARK: Vector-Matrix multiplication for Float
public extension Vector<Float> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = 1.0
        let beta: T = .zero
        BLAS.sgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.sgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = 1.0
        let beta: T = 1.0
        BLAS.sgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = 1.0
        BLAS.sgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }
}

//MARK: Vector-Matrix multiplication for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = .one
        let beta: T = .zero
        BLAS.zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = .one
        let beta: T = .one
        BLAS.zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .one
        BLAS.zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }
}

//MARK: Vector-Matrix multiplication for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, into: &into)
        } else {
            _dot(matrix, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, into: &into)
        } else {
            _dot(matrix, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, addingInto: &into)
        } else {
            _dot(matrix, addingInto: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _dotBLAS(matrix, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(matrix, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = .one
        let beta: T = .zero
        BLAS.cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = .one
        let beta: T = .one
        BLAS.cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .one
        BLAS.cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
    }
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.dgemv(.rowMajor, .transpose, matrixRows, matrixColumns, multiplier, matrix, matrixColumns, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.sgemv(.rowMajor, .transpose, matrixRows, matrixColumns, multiplier, matrix, matrixColumns, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.zgemv(.rowMajor, .transpose, matrixRows, matrixColumns, multiplier, matrix, matrixColumns, vector, 1, resultMultiplier, resultVector, 1)
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    BLAS.cgemv(.rowMajor, .transpose, matrixRows, matrixColumns, multiplier, matrix, matrixColumns, vector, 1, resultMultiplier, resultVector, 1)
}
