//
//  UniqueVector dot Matrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

//MARK: Vector-Matrix multiplication for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    @inlinable
    func dot(_ matrix: borrowing UniqueMatrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: borrowing UniqueMatrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: borrowing UniqueMatrix<T>, into: inout Self) {
        precondition(count == matrix.rows)
        for i in 0..<into.count { into[unchecked: i] = .zero }
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[unchecked: i] = Relaxed.multiplyAdd(self[unchecked: j], matrix[unchecked: j, unchecked: i], into[unchecked: i])
            }
        }
    }
    
    @inlinable
    func dot(_ matrix: borrowing UniqueMatrix<T>, addingInto into: inout Self) {
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[unchecked: i] = Relaxed.multiplyAdd(self[unchecked: j], matrix[unchecked: j, unchecked: i], into[unchecked: i])
            }
        }
    }
    
    @inlinable
    func dot(_ matrix: borrowing UniqueMatrix<T>, multiplied: T, into: inout Self) {
        precondition(count == matrix.rows)
        for i in 0..<into.count { into[unchecked: i] = .zero }
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[unchecked: j], multiplied)
            for i in 0..<matrix.columns {
                into[unchecked: i] = Relaxed.multiplyAdd(C, matrix[unchecked: j, unchecked: i], into[unchecked: i])
            }
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: borrowing UniqueMatrix<T>, multiplied: T, addingInto into: inout Self) {
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[unchecked: j], multiplied)
            for i in 0..<matrix.columns {
                into[unchecked: i] = Relaxed.multiplyAdd(C, matrix[unchecked: j, unchecked: i], into[unchecked: i])
            }
        }
    }
}

//MARK: Vector-Matrix multiplication for Double
public extension UniqueVector<Double> {
    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = 1.0) -> Self {
        var result: Self = .zero(matrix.columns)
        dotBLAS(matrix, multiplied: multiplied, into: &result)
        return result
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = 1.0, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.dgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = 1.0, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = 1.0
        BLAS.dgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }
}

//MARK: Vector-Matrix multiplication for Float
public extension UniqueVector<Float> {
    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = 1.0) -> Self {
        var result: Self = .zero(matrix.columns)
        dotBLAS(matrix, multiplied: multiplied, into: &result)
        return result
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = 1.0, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.sgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = 1.0, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = 1.0
        BLAS.sgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }
}

//MARK: Vector-Matrix multiplication for Complex<Double>
public extension UniqueVector<Complex<Double>> {
    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = .one) -> Self {
        var result: Self = .zero(matrix.columns)
        dotBLAS(matrix, multiplied: multiplied, into: &result)
        return result
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = .one, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = .one, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .one
        BLAS.zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }
}

//MARK: Vector-Matrix multiplication for Complex<Float>
public extension UniqueVector<Complex<Float>> {
    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = .one) -> Self {
        var result: Self = .zero(matrix.columns)
        dotBLAS(matrix, multiplied: multiplied, into: &result)
        return result
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = .one, into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .zero
        BLAS.cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }

    @inlinable
    func dotBLAS(_ matrix: borrowing UniqueMatrix<T>, multiplied: T = .one, addingInto into: inout Self) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .transpose
        let m = matrix.rows, n = matrix.columns
        let lda = matrix.columns
        let alpha: T = multiplied
        let beta: T = .one
        BLAS.cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, into.components, 1)
    }
}
