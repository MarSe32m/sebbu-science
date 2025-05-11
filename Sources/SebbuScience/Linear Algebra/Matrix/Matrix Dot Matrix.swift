//
//  Matrix Dot Matrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
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
        _dot(other, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        _dot(other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto: inout Self) {
        _dot(other, addingInto: &addingInto)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, multiplied: T, addingInto: inout Self) {
        _dot(other, multiplied: multiplied, addingInto: &addingInto)
    }
    
    @inlinable
    func _dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
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
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
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
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
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
    @_transparent
    func dot(_ other: Self, into: inout Self) {
        dot(other, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        if let dgemm = BLAS.dgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto: inout Self) {
        dot(other, multiplied: 1.0, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        if let dgemm = BLAS.dgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 1.0, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
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
    @_transparent
    func dot(_ other: Self, into: inout Self) {
        dot(other, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        if let sgemm = BLAS.sgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            sgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto: inout Self) {
        dot(other, multiplied: 1.0, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        if let sgemm = BLAS.sgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            sgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 1.0, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
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
    @_transparent
    func dot(_ other: Self, into: inout Self) {
        dot(other, multiplied: .one, into: &into)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        if let zgemm = BLAS.zgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zgemm(layout, transA, transB, m, n, k, alpha, elements, lda, other.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto: inout Self) {
        dot(other, multiplied: .one, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        if let zgemm = BLAS.zgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zgemm(layout, transA, transB, m, n, k, alpha, elements, lda, other.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
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
    @_transparent
    func dot(_ other: Self, into: inout Self) {
        dot(other, multiplied: .one, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        if let cgemm = BLAS.cgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cgemm(layout, transA, transB, m, n, k, alpha, elements, lda, other.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, addingInto: inout Self) {
        dot(other, multiplied: .one, addingInto: &addingInto)
    }
    
    @inlinable
    @_transparent
    func dot(_ other: Self, multiplied: T, addingInto into: inout Self) {
        if let cgemm = BLAS.cgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cgemm(layout, transA, transB, m, n, k, alpha, elements, lda, other.elements, ldb, beta, &into.elements, ldc)
                }
            }
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
}

//MARK: Matrix-matrix multiplication global functions
@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Double, _ leftMatrix: UnsafePointer<Double>, _ rightMatrix: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultMatrix: UnsafeMutablePointer<Double>) {
    assert(leftColumns == rightRows)
    if let dgemm = BLAS.dgemm {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let transB = BLAS.Transpose.noTranspose.rawValue
        dgemm(order, transA, transB, cblas_int(leftRows), cblas_int(rightColumns), cblas_int(leftColumns), multiplier, leftMatrix, cblas_int(leftColumns), rightMatrix, cblas_int(rightColumns), resultMultiplier, resultMatrix, cblas_int(leftColumns))
    }
}

@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Float, _ leftMatrix: UnsafePointer<Float>, _ rightMatrix: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultMatrix: UnsafeMutablePointer<Float>) {
    assert(leftColumns == rightRows)
    if let sgemm = BLAS.sgemm {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let transB = BLAS.Transpose.noTranspose.rawValue
        sgemm(order, transA, transB, cblas_int(leftRows), cblas_int(rightColumns), cblas_int(leftColumns), multiplier, leftMatrix, cblas_int(leftColumns), rightMatrix, cblas_int(rightColumns), resultMultiplier, resultMatrix, cblas_int(leftColumns))
    }
}

@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Complex<Double>, _ leftMatrix: UnsafePointer<Complex<Double>>, _ rightMatrix: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultMatrix: UnsafeMutablePointer<Double>) {
    assert(leftColumns == rightRows)
    if let zgemm = BLAS.zgemm {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let transB = BLAS.Transpose.noTranspose.rawValue
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                zgemm(order, transA, transB, cblas_int(leftRows), cblas_int(rightColumns), cblas_int(leftColumns), alpha, leftMatrix, cblas_int(leftColumns), rightMatrix, cblas_int(rightColumns), beta, resultMatrix, cblas_int(leftColumns))
            }
        }
    }
}

@inlinable
public func matMul(_ leftRows: Int, _ leftColumns: Int, _ rightRows: Int, _ rightColumns: Int, _ multiplier: Complex<Float>, _ leftMatrix: UnsafePointer<Complex<Float>>, _ rightMatrix: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultMatrix: UnsafeMutablePointer<Double>) {
    assert(leftColumns == rightRows)
    if let cgemm = BLAS.cgemm {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let transB = BLAS.Transpose.noTranspose.rawValue
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cgemm(order, transA, transB, cblas_int(leftRows), cblas_int(rightColumns), cblas_int(leftColumns), alpha, leftMatrix, cblas_int(leftColumns), rightMatrix, cblas_int(rightColumns), beta, resultMatrix, cblas_int(leftColumns))
            }
        }
    }
}
