//
//  Matrix Dot Vector Hermitian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import NumericsExtensions

//MARK: Hermitian and Symmetric Matrix-Vector multiplication for Complex<Double>
public extension UniqueMatrix where T: ConjugatableScalar {
    @inlinable
    func symmetricDot(_ vector: borrowing UniqueVector<T>) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        symmetricDot(vector, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: borrowing UniqueVector<T>, multiplied: T) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ vector: borrowing UniqueVector<T>) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        hermitianDot(vector, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDot(_ vector: borrowing UniqueVector<T>, multiplied: T) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: borrowing UniqueVector<T>, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, into: into.components)
    }
    
    @inlinable
    func symmetricDot(_ vector: borrowing UniqueVector<T>, multiplied: T, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func symmetricDot(_ vector: borrowing UniqueVector<T>, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, addingInto: into.components)
    }
    
    @inlinable
    func symmetricDot(_ vector: borrowing UniqueVector<T>, multiplied: T, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func hermitianDot(_ vector: borrowing UniqueVector<T>, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, into: into.components)
    }
    
    @inlinable
    func hermitianDot(_ vector: borrowing UniqueVector<T>, multiplied: T, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func hermitianDot(_ vector: borrowing UniqueVector<T>, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, addingInto: into.components)
    }
    
    @inlinable
    func hermitianDot(_ vector: borrowing UniqueVector<T>, multiplied: T, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeDot(vector.components, multiplied: multiplied, addingInto: into.components)
    }
}

//MARK: Matrix-Vector multiplication for Double
public extension UniqueMatrix<Double> {
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0) -> UniqueVector<T> {
        symmetricDotBLAS(vector, multiplied: multiplied)
    }
    
    @inlinable
    func symmetricDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        symmetricDotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeSymmetricDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func symmetricDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeSymmetricDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeSymmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.dsymv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeSymmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = 1.0
        BLAS.dsymv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}

//MARK: Matrix-Vector multiplication for Float
public extension UniqueMatrix<Float> {
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0) -> UniqueVector<T> {
        symmetricDotBLAS(vector, multiplied: multiplied)
    }
    
    @inlinable
    func symmetricDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        symmetricDotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeSymmetricDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func symmetricDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = 1.0, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeSymmetricDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeSymmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.ssymv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeSymmetricDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = 1.0, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = 1.0
        BLAS.ssymv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}

//MARK: Matrix-Vector multiplication for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        hermitianDotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeHermitianDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeHermitianDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeHermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.zhemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeHermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .one
        BLAS.zhemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}

//MARK: Matrix-Vector multiplication for Complex<Float>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one) -> UniqueVector<T> {
        var result: UniqueVector<T> = .zero(rows)
        hermitianDotBLAS(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeHermitianDotBLAS(vector.components, multiplied: multiplied, into: into.components)
    }
    
    @inlinable
    func hermitianDotBLAS(_ vector: borrowing UniqueVector<T>, multiplied: T = .one, addingInto into: inout UniqueVector<T>) {
        precondition(vector.count == columns && into.count == rows, "Vector dimensions do not match")
        unsafeHermitianDotBLAS(vector.components, multiplied: multiplied, addingInto: into.components)
    }
    
    @inlinable
    func unsafeHermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .zero
        BLAS.chemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
    
    @inlinable
    func unsafeHermitianDotBLAS(_ vector: UnsafePointer<T>, multiplied: T = .one, addingInto into: UnsafeMutablePointer<T>) {
        let order: BLAS.Order = .rowMajor
        let uplo: BLAS.UpLo = .upper
        let N = rows
        let lda = N
        let beta: T = .one
        BLAS.chemv(order, uplo, N, multiplied, elements, lda, vector, 1, beta, into, 1)
    }
}
