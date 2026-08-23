// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import SebbuBLAS
import SebbuLAPACK

import RealModule
import ComplexModule
import NumericsExtensions

public extension Matrix<Complex<Double>> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    @inlinable
    var inverse: Self? {
        if !isSquare { return nil }
        var a = elements
        var ipiv: [Int] = .init(repeating: .zero, count: rows)
        var info = LAPACK.zgetrf(layout: .rowMajor, m: rows, n: columns, a: &a, lda: columns, ipiv: &ipiv)
        if info != 0 { return nil }
        info = LAPACK.zgetri(layout: .rowMajor, n: columns, a: &a, lda: columns, ipiv: ipiv)
        if info != 0 { return nil }
        return .init(elements: a, rows: rows, columns: columns)
    }
    
    @inlinable
    var pseudoInverse: Self? {
        //TODO: Should we check wherther the matrix is a special case, for example diagonal etc?
        guard let (U, S, VH) = try? MatrixOperations.singularValueDecomposition(A: self) else { return nil }
        //FIXME: Can S be empty here?
        // Tolerance for the pseudoinverse of S
        let tolerance = Double(Swift.max(rows, columns)) * Double.ulpOfOne * S.max()!
        var sigma: Self = .zeros(rows: columns, columns: rows)
        for i in 0..<min(rows, columns) {
            if S[i] > tolerance {
                sigma[i, i] = Complex(1 / S[i])
            }
        }
        return VH.conjugateTranspose.dot(sigma).dot(U.conjugateTranspose)
    }
}

//MARK: Copying and zeroing elements
public extension Matrix<Complex<Double>> {
    @inlinable
    @_transparent
    mutating func copyElements(from other: Self) {
        var span = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in span.indices {
            span[unchecked: i] = otherSpan[unchecked: i]
        }
    }

    @inlinable
    mutating func copyElements(from other: Self, adding: Self, multiplied: Complex<Double>) {
        precondition(elements.count == other.elements.count)
        precondition(elements.count == adding.elements.count)
        var mutableSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        let addingSpan = adding.elements.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, addingSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
    
    @inlinable
    mutating func copyElements(from other: Self, multiplied: Complex<Double>) {
        precondition(elements.count == other.elements.count)
        var mutableSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.product(otherSpan[unchecked: i], multiplied)
        }
    }
    
    @inlinable
    mutating func copyElements(from other: Self, adding: Self, multiplied: Double) {
        precondition(elements.count == other.elements.count)
        precondition(elements.count == adding.elements.count)
        var mutableSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        let addingSpan = adding.elements.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, addingSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
    
    @inlinable
    mutating func copyElements(from other: Self, multiplied: Double) {
        precondition(elements.count == other.elements.count)
        var mutableSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.product(otherSpan[unchecked: i], multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func copyElementsBLAS(from other: Self) {
        BLAS.zcopy(n: elements.count, x: other.elements, incX: 1, y: &elements, incY: 1)
    }

    @inlinable
    @_transparent
    mutating func zeroElements() {
        var span = elements.mutableSpan
        for i in span.indices {
            span[unchecked: i] = .zero
        }
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
    static func diagonalizeHermitian(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Double], eigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenValues: [Double] = .init(repeating: .zero, count: A.rows)
        let info = LAPACK.zheev(layout: .rowMajor, job: .vectors, triangle: .upper, n: N, a: &a, lda: N, w: &eigenValues)
        if info != 0 { throw MatrixOperationError.info(info) }
        var eigenVectors = [Vector<Complex<Double>>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                eigenVectors[j][i] = a[N * i + j]
            }
        }
        return (eigenValues, eigenVectors)
    }

    /// Computes the eigenvalues of the given hermitian matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    @inlinable
    static func eigenValuesHermitian(_ A: Matrix<Complex<Double>>) throws -> [Double] {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenValues: [Double] = .init(repeating: .zero, count: N)
        let info = LAPACK.zheev(layout: .rowMajor, job: .none, triangle: .upper, n: N, a: &a, lda: N, w: &eigenValues)
        if info != 0 { throw MatrixOperationError.info(info) }
        return eigenValues
    }

    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors and right eigenvectors
    @inlinable
    static func diagonalize(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        var vr: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.zgeev(layout: .rowMajor, jobVL: .vectors, jobVR: .vectors, n: N, a: &a, lda: N, w: &eigenValues, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(info) }
        var _leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                _leftEigenVectors[j][i] = vl[N * i + j]
                rightEigenVectors[j][i] = vr[N * i + j]
            }
        }
        let leftEigenVectors = _leftEigenVectors.indices.map { i in
            let s = _leftEigenVectors[i].inner(rightEigenVectors[i])
            return _leftEigenVectors[i].conjugate / s
        }
        return (eigenValues, leftEigenVectors, rightEigenVectors)
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors
    @inlinable
    static func diagonalizeLeft(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        var vr: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.zgeev(layout: .rowMajor, jobVL: .vectors, jobVR: .none, n: N, a: &a, lda: N, w: &eigenValues, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(info) }
        var leftEigenVectors: [Vector<Complex<Double>>] = [Vector<Complex<Double>>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                leftEigenVectors[j][i] = vl[N * i + j]
            }
        }
        return (eigenValues, leftEigenVectors)
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and right eigenvectors
    @inlinable
    static func diagonalizeRight(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare)
        let N = A.rows
        var a = A.elements
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        var vr: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.zgeev(layout: .rowMajor, jobVL: .none, jobVR: .vectors, n: N, a: &a, lda: N, w: &eigenValues, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(info) }
        var rightEigenVectors: [Vector<Complex<Double>>] = [Vector<Complex<Double>>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                rightEigenVectors[j][i] = vl[N * i + j]
            }
        }
        return (eigenValues, rightEigenVectors)
    }

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    @inlinable
    static func eigenValues(_ A: Matrix<Complex<Double>>) throws -> [Complex<Double>] {
        precondition(A.isSquare)
        let N = A.rows
        var a = A.elements
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        var vr: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.zgeev(layout: .rowMajor, jobVL: .none, jobVR: .none, n: N, a: &a, lda: N, w: &eigenValues, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(info) }
        return eigenValues
    }
    
    @inlinable
    static func solve(A: Matrix<Complex<Double>>, b: Vector<Complex<Double>>) throws -> Vector<Complex<Double>> {
        let N = A.rows
        var a = A.elements
        var b = b.components
        var ipiv = [Int](repeating: .zero, count: N)
        let info = LAPACK.zgesv(layout: .rowMajor, n: N, nrhs: 1, a: &a, lda: N, ipiv: &ipiv, b: &b, ldb: 1)
        if info != 0 { throw MatrixOperationError.info(info) }
        return Vector(b)
    }

    @inlinable
    static func solve(A: Matrix<Complex<Double>>, B: Matrix<Complex<Double>>) throws -> Matrix<Complex<Double>> {
        let N = A.rows
        let nrhs = B.columns
        var a = A.elements
        var b = B.elements
        var ipiv = [Int](repeating: .zero, count: N)
        let info = LAPACK.zgesv(layout: .rowMajor, n: N, nrhs: nrhs, a: &a, lda: N, ipiv: &ipiv, b: &b, ldb: nrhs)
        if info != 0 { throw MatrixOperationError.info(info) }
        return .init(elements: b, rows: N, columns: B.columns)
    }

    @inlinable
    static func singularValueDecomposition(A: Matrix<Complex<Double>>) throws -> (U: Matrix<Complex<Double>>, singularValues: [Double], VH: Matrix<Complex<Double>>) {
        let m = A.rows
        let n = A.columns
        var a = A.elements
        var U: Matrix<Complex<Double>> = .zeros(rows: A.rows, columns: A.rows)
        var VH: Matrix<Complex<Double>> = .zeros(rows: A.columns, columns: A.columns)
        var singularValues: [Double] = .init(repeating: .zero, count: min(m, n))
        var superb: [Double] = .init(repeating: .zero, count: min(m, n))
        let info = LAPACK.zgesvd(layout: .rowMajor, jobU: .all, jobVT: .all, m: m, n: n, a: &a, lda: n, s: &singularValues, u: &U.elements, ldu: m, vt: &VH.elements, ldvt: n, superb: &superb)
        if info != 0 { throw MatrixOperationError.info(info) }
        return (U, singularValues, VH)
    }

    @inlinable
    static func schurDecomposition(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], U: Matrix<Complex<Double>>, Q: Matrix<Complex<Double>>) {
        precondition(A.isSquare, "Schur decomposition can only be calculated for square matrices")
        let N = A.rows
        var sdim = 0
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var schurVectors: [Complex<Double>] = .init(repeating: .zero, count: A.elements.count)
        var a = A.elements
        let info = LAPACK.zgees(layout: .rowMajor, jobVS: .vectors, sort: .none, n: N, a: &a, lda: N, sdim: &sdim, w: &eigenValues, vs: &schurVectors, ldvs: N)
        if info != 0 { throw MatrixOperationError.info(info) }
        let U = Matrix<Complex<Double>>(elements: a, rows: A.rows, columns: A.columns)
        let Q = Matrix<Complex<Double>>(elements: schurVectors, rows: A.rows, columns: A.columns)
        return (eigenValues, U, Q)
    }
    
    @inlinable
    static func positiveSemidefiniteSquareRoot(
        _ A: Matrix<Complex<Double>>
    ) -> Matrix<Complex<Double>> {
        let Q = symmetrizedHermitian(A)

        guard let result = try? MatrixOperations.diagonalizeHermitian(Q) else {
            fatalError("Failed to diagonalize")
        }
        var eigenValues = result.eigenValues
        let eigenVectors = result.eigenVectors

        var scale = 0.0
        for lambda in eigenValues {
            precondition(lambda.isFinite, "Matrix has a non-finite eigenvalue: \(lambda)")
            scale = max(scale, abs(lambda))
        }

        let eps = Double.ulpOfOne
        let tol = 100.0 * eps * Double(eigenValues.count) * max(scale, Double.leastNormalMagnitude)

        for i in 0..<eigenValues.count {
            if eigenValues[i] < -tol {
                fatalError("Matrix is not positive semidefinite. λ_min = \(eigenValues[i]), tolerance = \(tol)")
            }

            if eigenValues[i] < 0.0 {
                eigenValues[i] = 0.0
            }
        }

        let sqrtD: Matrix<Complex<Double>> = .diagonal(
            from: eigenValues.map { Complex($0.squareRoot()) }
        )

        let U: Matrix<Complex<Double>> = .from(
            columns: eigenVectors.map { $0.components }
        )

        return U.dot(sqrtD)
    }
}
