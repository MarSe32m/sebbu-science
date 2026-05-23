//
//  Matrix Dot Vector.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

//MARK: Matrix-Vector multiplication for AlgebraicField
public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    func dot(_ vector: borrowing UniqueVector<T>) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: borrowing UniqueVector<T>, multiplied: T) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: borrowing UniqueVector<T>, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, into: into.components)
    }
    
    @inlinable
    func dot(_ vector: borrowing UniqueVector<T>, multiplied: T, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func dot(_ vector: borrowing UniqueVector<T>, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, addingInto: into.components)
    }
    
    @inlinable
    func dot(_ vector: borrowing UniqueVector<T>, multiplied: T, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeDot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[unchecked: i, unchecked: j], vector[j], result)
            }
            into[i] = result
        }
    }
    
    @inlinable
    func unsafeDot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[unchecked: i, unchecked: j], vector[j], result)
            }
            into[i] = Relaxed.product(result, multiplied)
        }
    }
    
    @inlinable
    func unsafeDot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.sum(result, into[i])
        }
    }
    
    @inlinable
    func unsafeDot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
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
public extension UniqueMatrix<Double> {
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = .zero
        BLAS.dgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = 1.0
        BLAS.dgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}

//MARK: Matrix-Vector multiplication for Float
public extension UniqueMatrix<Float> {
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = .zero
        BLAS.sgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = 1.0
        BLAS.sgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}

//MARK: Matrix-Vector multiplication for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = .zero
        BLAS.zgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = .one
        BLAS.zgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}

//MARK: Matrix-Vector multiplication for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func dotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = .zero
        BLAS.cgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, addingInto into: UnsafeMutablePointer<T>) {
        let layout: BLAS.Layout = .rowMajor
        let trans: BLAS.Transpose = .noTranspose
        let m = rows, n = columns
        let lda = n
        let beta: T = .one
        BLAS.cgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}
