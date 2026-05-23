//
//  Matrix+ComplexFloat.swift
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
import NumericsExtensions

public extension UniqueMatrix<Complex<Float>> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    @inlinable
    var inverse: Self? {
        if rows != columns { return nil }
        #if canImport(COpenBLAS)
        var a = elements
        var m = rows
        var lda = columns
        var ipiv: [lapack_int] = .init(repeating: .zero, count: m)
        var info = a.withUnsafeMutableBufferPointer { a in
            LAPACKE_cgetrf(LAPACK_ROW_MAJOR, .init(m), .init(m), .init(a.baseAddress), .init(lda), &ipiv)
        }
        if info != 0 { return nil }
        info = a.withUnsafeMutableBufferPointer { a in
            LAPACKE_cgetri(LAPACK_ROW_MAJOR, .init(m), .init(a.baseAddress), .init(lda), ipiv)
        }
        if info != 0 { return nil }
        return .init(elements: a, rows: rows, columns: columns)
        #elseif canImport(Accelerate)
        var m = rows
        var n = columns
        var lda = rows
        var info = 0
        return withUnsafeTemporaryAllocation(of: Complex<Float>.self, capacity: count) { a in
            var index = 0
            for j in 0..<columns {
                for i in 0..<rows {
                    a[index] = self[i, j]
                    index += 1
                }
            }
            return withUnsafeTemporaryAllocation(of: Int.self, capacity: Swift.min(m, n)) { ipiv in
                for i in 0..<Swift.min(m, n) { ipiv[i] = .zero }
                cgetrf_(&m, &n, OpaquePointer(a.baseAddress), &lda, ipiv.baseAddress, &info)
                if info != 0 { return nil }
                var work: Complex<Float> = .zero
                var lwork = -1
                withUnsafeMutablePointer(to: &work) { work in
                    cgetri_(&n, .init(a.baseAddress), &lda, ipiv.baseAddress, .init(work), &lwork, &info)
                }
                if info != 0 { return nil }
                lwork = Int(work.real)
                withUnsafeTemporaryAllocation(of: Complex<Float>.self, capacity: lwork) { work in
                    cgetri_(&n, .init(a.baseAddress), &lda, ipiv.baseAddress, .init(work.baseAddress!), &lwork, &info)
                }
                if info != 0 { return nil }
                return .init(rows: rows, columns: columns) { buffer in
                    for i in 0..<rows {
                        for j in 0..<columns {
                            buffer[i * n + j] = a[j * n + i]
                        }
                    }
                }
            }
        }
        #else
        fatalError("Default implementation not yet implemented")
        #endif
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
        BLAS.ccopy(count, other.elements, 1, elements, 1)
    }
}

public extension MatrixOperations {
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
