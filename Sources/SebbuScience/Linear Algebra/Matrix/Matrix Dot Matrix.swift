//
//  Matrix Dot Matrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

//MARK: Matrix-Matrix multiplication for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    func dot(_ other: Self) -> Self {
        //FIXME: Is this safe? Anything conforming to AlgebraicField ought to be quite trivial... So we can leave the memory uninitialized
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        //FIXME: Is this safe? Anything conforming to AlgebraicField ought to be quite trivial... So we can leave the memory uninitialized
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
        _dot(other, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
        _dot(other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == addingInto.rows)
        precondition(other.columns == addingInto.columns)
        _dot(other, addingInto: &addingInto)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, multiplied: T, addingInto: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == addingInto.rows)
        precondition(other.columns == addingInto.columns)
        _dot(other, multiplied: multiplied, addingInto: &addingInto)
    }
    
    @inlinable
    func _dot(_ other: Self, into: inout Self) {
        for i in 0..<rows {
            for j in 0..<other.columns { into[i, j] = .zero }
            for k in 0..<columns {
                let A = self[i, k]
                for j in 0..<other.columns {
                    into[i, j] = Relaxed.multiplyAdd(A, other[k, j], into[i, j])
                }
            }
        }
    }

    @inlinable
    func _dot(_ other: Self, multiplied: T, into: inout Self) {
        for i in 0..<rows {
            for j in 0..<other.columns { into[i, j] = .zero }
            for k in 0..<columns {
                let A = Relaxed.product(self[i, k], multiplied)
                for j in 0..<other.columns {
                    into[i, j] = Relaxed.multiplyAdd(A, other[k, j], into[i, j])
                }
            }
        }
    }
    
    @inlinable
    func _dot(_ other: Self, addingInto into: inout Self) {
        for i in 0..<rows {
            for k in 0..<columns {
                let A = self[i, k]
                for j in 0..<other.columns {
                    into[i, j] = Relaxed.multiplyAdd(A, other[k, j], into[i, j])
                }
            }
        }
    }
    
    @inlinable
    func _dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
        for i in 0..<rows {
            for k in 0..<columns {
                let A = Relaxed.product(self[i, k], multiplied)
                for j in 0..<other.columns {
                    into[i, j] = Relaxed.multiplyAdd(A, other[k, j], into[i, j])
                }
            }
        }
    }
}

//MARK: Matrix-Matrix multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func dot(_ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: 1.0, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, &into.elements, ldc)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: 1.0, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 1.0, &into.elements, ldc)
    }
}

//MARK: Matrix-Matrix multiplication for Float
public extension Matrix<Float> {
    @inlinable
    func dot(_ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: 1.0, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.sgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, &into.elements, ldc)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: 1.0, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.sgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 1.0, &into.elements, ldc)
    }
}

//MARK: Matrix-Matrix multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func dot(_ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: .one, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.zgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .zero, &into.elements, ldc)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: .one, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.zgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .one, &into.elements, ldc)
    }
}

//MARK: Matrix-Matrix multiplication for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    func dot(_ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: .one, into: &into)
        } else {
            _dot(other, into: &into)
        }
    }

    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, into: &into)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.cgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .zero, &into.elements, ldc)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: .one, addingInto: &into)
        } else {
            _dot(other, addingInto: &into)
        }
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        precondition(columns == other.rows)
        precondition(into.rows == rows)
        precondition(into.columns == other.columns)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold for BLAS dispatch
            _dotBLAS(other, multiplied: multiplied, addingInto: &into)
        } else {
            _dot(other, multiplied: multiplied, addingInto: &into)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self, multiplied: T, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let transA: BLAS.Transpose = .noTranspose
        let transB: BLAS.Transpose = .noTranspose
        let m = rows, n = other.columns, k = columns
        let lda = k, ldb = n, ldc = n
        BLAS.cgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, .one, &into.elements, ldc)
    }
}

//MARK: Matrix-matrix multiplication global functions
@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Double, _ leftMatrix: UnsafePointer<Double>, _ rightMatrix: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultMatrix: UnsafeMutablePointer<Double>) {
    assert(leftColumns == rightRows)
    BLAS.dgemm(.rowMajor, .noTranspose, .noTranspose, leftRows, rightColumns, leftColumns, multiplier, leftMatrix, leftColumns, rightMatrix, rightColumns, resultMultiplier, resultMatrix, leftColumns)
}

@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Float, _ leftMatrix: UnsafePointer<Float>, _ rightMatrix: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultMatrix: UnsafeMutablePointer<Float>) {
    assert(leftColumns == rightRows)
    BLAS.sgemm(.rowMajor, .noTranspose, .noTranspose, leftRows, rightColumns, leftColumns, multiplier, leftMatrix, leftColumns, rightMatrix, rightColumns, resultMultiplier, resultMatrix, leftColumns)
}

@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Complex<Double>, _ leftMatrix: UnsafePointer<Complex<Double>>, _ rightMatrix: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultMatrix: UnsafeMutablePointer<Complex<Double>>) {
    assert(leftColumns == rightRows)
    BLAS.zgemm(.rowMajor, .noTranspose, .noTranspose, leftRows, rightColumns, leftColumns, multiplier, leftMatrix, leftColumns, rightMatrix, rightColumns, resultMultiplier, resultMatrix, leftColumns)
}

@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Complex<Float>, _ leftMatrix: UnsafePointer<Complex<Float>>, _ rightMatrix: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultMatrix: UnsafeMutablePointer<Complex<Float>>) {
    assert(leftColumns == rightRows)
    BLAS.cgemm(.rowMajor, .noTranspose, .noTranspose, leftRows, rightColumns, leftColumns, multiplier, leftMatrix, leftColumns, rightMatrix, rightColumns, resultMultiplier, resultMatrix, leftColumns)
}
