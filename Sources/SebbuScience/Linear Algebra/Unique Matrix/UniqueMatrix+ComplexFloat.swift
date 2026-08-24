// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import SebbuBLAS
import SebbuLAPACK

import RealModule
import ComplexModule
import NumericsExtensions

public extension UniqueMatrix<Complex<Float>> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    @inlinable
    var inverse: Self? {
        if isSquare { return nil }
        let a: UniqueMatrix<Complex<Float>> = .init(copying: self)
        let N = rows
        var ipiv: [Int] = .init(repeating: .zero, count: N)
        var info = LAPACK.cgetrf(layout: .rowMajor, m: N, n: N, a: a.elements, lda: N, ipiv: &ipiv)
        if info != 0 { return nil }
        info = LAPACK.cgetri(layout: .rowMajor, n: N, a: a.elements, lda: N, ipiv: ipiv)
        if info != 0 { return nil }
        return a
    }
    
    @inlinable
    var pseudoInverse: Self? {
        //TODO: Should we check wherther the matrix is a special case, for example diagonal etc?
        guard let (U, S, VH) = try? MatrixOperations.singularValueDecomposition(A: self) else { return nil }
        //FIXME: Can S be empty here?
        // Tolerance for the pseudoinverse of S
        let tolerance = Float(Swift.max(rows, columns)) * Float.ulpOfOne * S.max()!
        var sigma: Matrix<Complex<Float>> = .zeros(rows: columns, columns: rows)
        for i in 0..<min(rows, columns) {
            if S[i] > tolerance {
                sigma[i, i] = Complex(1 / S[i])
            }
        }
        return UniqueMatrix(copying: VH.conjugateTranspose.dot(sigma).dot(U.conjugateTranspose))
    }
}

//MARK: Copying and zeroing elements
public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    mutating func copyElementsBLAS(from other: borrowing Self) {
        BLAS.ccopy(n: count, x: other.elements, incX: 1, y: elements, incY: 1)
    }
    
    @inlinable
    mutating func copyElementsBLAS(from other: Matrix<Complex<Float>>) {
        BLAS.ccopy(n: count, x: other.elements, incX: 1, y: elements, incY: 1)
    }
}

public extension MatrixOperations {
    /// Diagonalizes a Hermitian matrix in place.
    ///
    /// On return, the columns of `A` contain the orthonormal eigenvectors and
    /// the returned eigenvalues are in ascending order. LAPACK only reads the
    /// upper triangle of `A`.
    ///
    /// This overload is useful for large temporary matrices because it avoids
    /// copying a `UniqueMatrix` through the copyable `Matrix` representation.
    ///
    /// - Parameter A: The Hermitian matrix to diagonalize. It is overwritten
    ///   by its eigenvectors.
    /// - Returns: The eigenvalues in ascending order.
    /// - Throws: ``MatrixOperationError`` if LAPACK reports a failure.
    static func diagonalizeHermitianInPlace(
        _ A: inout UniqueMatrix<Complex<Float>>
    ) throws -> [Float] {
        precondition(A.isSquare, "Diagonalization requires a square matrix")
        let N = A.rows
        var eigenValues: [Float] = .init(repeating: .zero, count: N)
        let info = LAPACK.cheev(layout: .rowMajor, job: .vectors, triangle: .upper, n: N, a: A.elements, lda: N, w: &eigenValues)
        if info != 0 { throw MatrixOperationError.info(info) }
        return eigenValues
    }
    
    /// Diagonalizes the given hermitian matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    @inlinable
    static func diagonalizeHermitian(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> (eigenValues: [Float], eigenVectors: [Vector<Complex<Float>>]) {
        //TODO: Implement properly
        try diagonalizeHermitian(Matrix(copying: A))
    }

    /// Computes the eigenvalues of the given hermitian matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValuesHermitian(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> [Float] {
        //TODO: Implement properly
        try eigenValuesHermitian(Matrix(copying: A))
    }

    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors and right eigenvectors
    @inlinable
    static func diagonalize(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>], rightEigenVectors: [Vector<Complex<Float>>]) {
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
    static func diagonalizeLeft(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>]) {
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
    static func diagonalizeRight(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], rightEigenVectors: [Vector<Complex<Float>>]) {
        //TODO: Implement properly
        try diagonalizeRight(Matrix(copying: A))
    }

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValues(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> [Complex<Float>] {
        //TODO: Implement properly
        try eigenValues(Matrix(copying: A))
    }
    
    //TODO: TEST
    @inlinable
    static func solve(A: borrowing UniqueMatrix<Complex<Float>>, b: borrowing UniqueVector<Complex<Float>>) throws -> Vector<Complex<Float>> {
        //TODO: Implement properly
        try solve(A: Matrix(copying: A), b: Vector(copying: b))
    }

    //TODO: TEST
    @inlinable
    static func solve(A: borrowing UniqueMatrix<Complex<Float>>, B: borrowing UniqueMatrix<Complex<Float>>) throws -> Matrix<Complex<Float>> {
        //TODO: Implement properly
        try solve(A: Matrix(copying: A), B: Matrix(copying: B))
    }
    
    @inlinable
    static func singularValueDecomposition(A: borrowing UniqueMatrix<Complex<Float>>) throws -> (U: Matrix<Complex<Float>>, singularValues: [Float], VH: Matrix<Complex<Float>>) {
        //TODO: Implement properly
        fatalError("TODO: Implement")
    }

    @inlinable
    static func schurDecomposition(_ A: borrowing UniqueMatrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], U: Matrix<Complex<Float>>, Q: Matrix<Complex<Float>>) {
        //TODO: Implement properly
        try schurDecomposition(Matrix(copying: A))
    }
}
