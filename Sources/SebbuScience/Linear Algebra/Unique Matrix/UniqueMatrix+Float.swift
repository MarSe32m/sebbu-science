// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import SebbuBLAS
import SebbuLAPACK

import RealModule
import ComplexModule

public extension UniqueMatrix<Float> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    //@inlinable
    var inverse: Self? {
        if isSquare { return nil }
        let a: UniqueMatrix<Float> = .init(copying: self)
        let N = rows
        var ipiv: [Int] = .init(repeating: .zero, count: N)
        var info = LAPACK.sgetrf(layout: .rowMajor, m: N, n: N, a: a.elements, lda: N, ipiv: &ipiv)
        if info != 0 { return nil }
        info = LAPACK.sgetri(layout: .rowMajor, n: N, a: a.elements, lda: N, ipiv: ipiv)
        if info != 0 { return nil }
        return a
    }
    
    @inlinable
    var pseudoInverse: Self? {
        //TODO: Should we check wherther the matrix is a special case, for example diagonal etc?
        guard let (U, S, VT) = try? MatrixOperations.singularValueDecomposition(A: self) else { return nil }
        //FIXME: Can S be empty here?
        // Tolerance for the pseudoinverse of S
        let tolerance = Float(Swift.max(rows, columns)) * Float.ulpOfOne * S.max()!
        var sigma: Matrix<Float> = .zeros(rows: columns, columns: rows)
        for i in 0..<min(rows, columns) {
            if S[i] > tolerance {
                sigma[i, i] = 1 / S[i]
            }
        }
        return UniqueMatrix(copying: VT.transpose.dot(sigma).dot(U.transpose))
    }
    
    
}

//MARK: Copying elements and zeroing elements
public extension UniqueMatrix<Float> {
    @inlinable
    mutating func copyElementsBLAS(from other: borrowing Self) {
        BLAS.scopy(n: count, x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

public extension MatrixOperations {
    /// Diagonalizes a symmetric matrix in place.
    ///
    /// On return, the columns of `A` contain the orthonormal eigenvectors and
    /// the returned eigenvalues are in ascending order. LAPACK only reads the
    /// upper triangle of `A`.
    ///
    /// This overload is useful for large temporary matrices because it avoids
    /// copying a `UniqueMatrix` through the copyable `Matrix` representation.
    ///
    /// - Parameter A: The symmetric matrix to diagonalize. It is overwritten
    ///   by its eigenvectors.
    /// - Returns: The eigenvalues in ascending order.
    /// - Throws: ``MatrixOperationError`` if LAPACK reports a failure.
    static func diagonalizeSymmetricInPlace(
        _ A: inout UniqueMatrix<Float>
    ) throws -> [Float] {
        precondition(A.isSquare, "Diagonalization requires a square matrix")
        let N = A.rows
        var eigenValues: [Float] = .init(repeating: .zero, count: N)
        let info = LAPACK.ssyev(layout: .rowMajor, job: .vectors, triangle: .upper, n: N, a: A.elements, lda: N, w: &eigenValues)
        if info != 0 { throw MatrixOperationError.info(info) }
        return eigenValues
    }
    
    /// Diagonalizes the given symmetric matrix, i.e., computes it's eigenvalues and eigenvectors
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    @inlinable
    static func diagonalizeSymmetric(_ A: borrowing UniqueMatrix<Float>) throws -> (eigenValues: [Float], eigenVectors: [Vector<Float>]) {
        //TODO: Implement properly
        try diagonalizeSymmetric(Matrix(copying: A))
    }

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValuesSymmetric(_ A: borrowing UniqueMatrix<Float>) throws -> [Float] {
        //TODO: Implement properly
        try eigenValuesSymmetric(Matrix(copying: A))
    }

    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors and right eigenvectors
    @inlinable
    static func diagonalize(_ A: borrowing UniqueMatrix<Float>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>], rightEigenVectors: [Vector<Complex<Float>>]) {
        //TODO: Implement properly
        try diagonalize(Matrix(copying: A))
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeLeft(_ A: borrowing UniqueMatrix<Float>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>]) {
        //TODO: Implement properly
        try diagonalizeLeft(Matrix(copying: A))
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and right eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeRight(_ A: borrowing UniqueMatrix<Float>) throws -> (eigenValues: [Complex<Float>], rightEigenVectors: [Vector<Complex<Float>>]) {
        //TODO: Implement properly
        try diagonalizeRight(Matrix(copying: A))
    }

    /// Computes the eigenvalues of the given matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValues(_ A: borrowing UniqueMatrix<Float>) throws -> [Complex<Float>] {
        //TODO: Implement properly
        try eigenValues(Matrix(copying: A))
    }
    
    //TODO: Test!
    @inlinable
    static func solve(A: borrowing UniqueMatrix<Float>, b: borrowing UniqueVector<Float>) throws -> Vector<Float> {
        //TODO: Implement properly
        try solve(A: Matrix(copying: A), b: Vector(copying: b))
    }

    //TODO: TEST
    @inlinable
    static func solve(A: borrowing UniqueMatrix<Float>, B: borrowing UniqueMatrix<Float>) throws -> Matrix<Float> {
        //TODO: Implement properly
        try solve(A: Matrix(copying: A), B: Matrix(copying: B))
    }

    @inlinable
    static func singularValueDecomposition(A: borrowing UniqueMatrix<Float>) throws -> (U: Matrix<Float>, singularValues: [Float], VT: Matrix<Float>) {
        //TODO: Implement properly
        try singularValueDecomposition(A: Matrix(copying: A))
    }

    @inlinable
    static func schurDecomposition(_ A: borrowing UniqueMatrix<Float>) throws -> (eigenValues: [Complex<Float>], U: Matrix<Float>, Q: Matrix<Float>) {
        //TODO: Implement properly
        try schurDecomposition(Matrix(copying: A))
    }
}
