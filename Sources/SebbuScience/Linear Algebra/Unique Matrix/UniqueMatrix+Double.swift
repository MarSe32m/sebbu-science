//
//  Matrix+Double.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(Accelerate)
import Accelerate
#endif

import RealModule
import ComplexModule

public extension UniqueMatrix<Double> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    //@inlinable
    var inverse: Self? {
        if rows != columns { return nil }
        #if canImport(COpenBLAS)
        var a = elements
        var m = rows
        var lda = columns
        var ipiv: [lapack_int] = .init(repeating: .zero, count: m)
        var info = LAPACKE_dgetrf(LAPACK_ROW_MAJOR, .init(m), .init(m), &a, .init(lda), &ipiv)
        if info != 0 { return nil }
        info = LAPACKE_dgetri(LAPACK_ROW_MAJOR, .init(m), &a, .init(lda), ipiv)
        if info != 0 { return nil }
        return .init(elements: a, rows: rows, columns: columns)
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(count)
        for j in 0..<columns {
            for i in 0..<rows {
                a.append(self[i, j])
            }
        }
        var m = rows
        var n = columns
        var lda = rows
        var ipiv: [Int] = .init(repeating: .zero, count: Swift.min(m, n))
        var info = 0
        dgetrf_(&m, &n, &a, &lda, &ipiv, &info)
        if info != 0 { return nil }
        
        var work: [Double] = [.zero]
        var lwork = -1
        
        dgetri_(&n, &a, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 { return nil }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        dgetri_(&n, &a, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 { return nil }
        return .init(rows: rows, columns: columns) { buffer in
            for i in 0..<rows {
                for j in 0..<columns {
                    buffer[i * n + j] = a[j * n + i]
                }
            }
        }
#else
        fatalError("TODO: Not yet implemented")
#endif
    }
    
    @inlinable
    var pseudoInverse: Self? {
        //TODO: Should we check wherther the matrix is a special case, for example diagonal etc?
        guard let (U, S, VT) = try? MatrixOperations.singularValueDecomposition(A: self) else { return nil }
        //FIXME: Can S be empty here?
        // Tolerance for the pseudoinverse of S
        let tolerance = Double(Swift.max(rows, columns)) * Double.ulpOfOne * S.max()!
        var sigma: Matrix<Double> = .zeros(rows: columns, columns: rows)
        for i in 0..<min(rows, columns) {
            if S[i] > tolerance {
                sigma[i, i] = 1 / S[i]
            }
        }
        return UniqueMatrix(copying: VT.transpose.dot(sigma).dot(U.transpose))
    }
    
    
}

//MARK: Copying elements and zeroing elements
public extension UniqueMatrix<Double> {
    @inlinable
    mutating func copyElementsBLAS(from other: borrowing Self) {
        BLAS.dcopy(count, other.elements, 1, elements, 1)
    }
}

public extension MatrixOperations {
    /// Diagonalizes the given symmetric matrix, i.e., computes it's eigenvalues and eigenvectors
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    @inlinable
    static func diagonalizeSymmetric(_ A: borrowing UniqueMatrix<Double>) throws -> (eigenValues: [Double], eigenVectors: [Vector<Double>]) {
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
    static func eigenValuesSymmetric(_ A: borrowing UniqueMatrix<Double>) throws -> [Double] {
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
    static func diagonalize(_ A: borrowing UniqueMatrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>], rightEigenVectors: [Vector<Complex<Double>>]) {
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
    static func diagonalizeLeft(_ A: borrowing UniqueMatrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>]) {
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
    static func diagonalizeRight(_ A: borrowing UniqueMatrix<Double>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [Vector<Complex<Double>>]) {
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
    static func eigenValues(_ A: borrowing UniqueMatrix<Double>) throws -> [Complex<Double>] {
        //TODO: Implement properly
        try eigenValues(Matrix(copying: A))
    }
    
    //TODO: Test!
    @inlinable
    static func solve(A: borrowing UniqueMatrix<Double>, b: borrowing UniqueVector<Double>) throws -> Vector<Double> {
        //TODO: Implement properly
        try solve(A: Matrix(copying: A), b: Vector(copying: b))
    }

    //TODO: TEST
    @inlinable
    static func solve(A: borrowing UniqueMatrix<Double>, B: borrowing UniqueMatrix<Double>) throws -> Matrix<Double> {
        //TODO: Implement properly
        try solve(A: Matrix(copying: A), B: Matrix(copying: B))
    }

    @inlinable
    static func singularValueDecomposition(A: borrowing UniqueMatrix<Double>) throws -> (U: Matrix<Double>, singularValues: [Double], VT: Matrix<Double>) {
        //TODO: Implement properly
        try singularValueDecomposition(A: Matrix(copying: A))
    }

    @inlinable
    static func schurDecomposition(_ A: borrowing UniqueMatrix<Double>) throws -> (eigenValues: [Complex<Double>], U: Matrix<Double>, Q: Matrix<Double>) {
        //TODO: Implement properly
        try schurDecomposition(Matrix(copying: A))
    }
}
