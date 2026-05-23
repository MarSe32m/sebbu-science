//
//  UniqueMatrix dot UniqueMatrix Symmetric.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions
import Numerics

public extension UniqueMatrix where T: AlgebraicField {
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: borrowing Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, into: &result)
        return result
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: borrowing Self, into: inout Self) {
        //TODO: Implement an optimized version utilizing the symmetry property
        dot(other, into: &into)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T, into: inout Self) {
        //TODO: Implement an optimized version utilizing the symmetry property
        dot(other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: borrowing Self, addingInto into: inout Self) {
        //TODO: Implement an optimized version utilizing the symmetry property
        dot(other, addingInto: &into)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T, addingInto into: inout Self) {
        //TODO: Implement an optimized version utilizing the symmetry property
        dot(other, multiplied: multiplied, addingInto: &into)
    }
}

//MARK: Symmetric Matrix-Matrix multiplication for Double
public extension UniqueMatrix<Double> {
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = 1.0) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = 1.0, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = .zero
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.dsymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.dsymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }

    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = 1.0, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = 1.0
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.dsymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.dsymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }
}

//MARK: Symmetric Matrix-Matrix multiplication for Float
public extension UniqueMatrix<Float> {
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = 1.0) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = 1.0, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = .zero
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.ssymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.ssymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }

    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = 1.0, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = 1.0
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.ssymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.ssymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }
}

//MARK: Symmetric Matrix-Matrix multiplication for Complex<Double>
public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = .one) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = .one, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = .zero
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zsymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zsymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }

    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = .one, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = .one
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zsymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.zsymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }
}

//MARK: Symmetric Matrix-Matrix multiplication for Complex<Double>
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = .one) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dotBLAS(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = .one, into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = .zero
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.csymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.csymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }

    @inlinable
    func dotBLAS(symmetricSide: SymmetricSide, _ other: borrowing Self, multiplied: T = .one, addingInto into: inout Self) {
        let order: BLAS.Order = .rowMajor
        let side: BLAS.Side = symmetricSide == .left ? .left : .right
        let uplo: BLAS.UpLo = .upper
        let beta: T = .one
        switch symmetricSide {
        case .left:
            let m = self.rows, n = other.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.csymm(order, side, uplo, m, n, multiplied, self.elements, lda, other.elements, ldb, beta, into.elements, ldc)
        case .right:
            let m = other.rows, n = self.columns
            let lda = columns, ldb = n, ldc = n
            BLAS.csymm(order, side, uplo, m, n, multiplied, other.elements, lda, self.elements, ldb, beta, into.elements, ldc)
        }
    }
}
