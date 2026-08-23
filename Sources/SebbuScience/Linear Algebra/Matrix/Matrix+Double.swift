// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import SebbuBLAS
import SebbuLAPACK

import RealModule
import ComplexModule

public extension Matrix<Double> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    @inlinable
    var inverse: Self? {
        if !isSquare { return nil }
        var a = elements
        var ipiv: [Int] = .init(repeating: .zero, count: rows)
        var info = LAPACK.dgetrf(layout: .rowMajor, m: rows, n: columns, a: &a, lda: columns, ipiv: &ipiv)
        if info != 0 { return nil }
        info = LAPACK.dgetri(layout: .rowMajor, n: columns, a: &a, lda: columns, ipiv: ipiv)
        if info != 0 { return nil }
        return .init(elements: a, rows: rows, columns: columns)
    }
    
    @inlinable
    var pseudoInverse: Self? {
        //TODO: Should we check wherther the matrix is a special case, for example diagonal etc?
        guard let (U, S, VT) = try? MatrixOperations.singularValueDecomposition(A: self) else { return nil }
        //FIXME: Can S be empty here?
        // Tolerance for the pseudoinverse of S
        let tolerance = Double(Swift.max(rows, columns)) * Double.ulpOfOne * S.max()!
        var sigma: Self = .zeros(rows: columns, columns: rows)
        for i in 0..<min(rows, columns) {
            if S[i] > tolerance {
                sigma[i, i] = 1 / S[i]
            }
        }
        return VT.transpose.dot(sigma).dot(U.transpose)
    }
    
    
}

//MARK: Copying elements and zeroing elements
public extension Matrix<Double> {
    @inlinable
    mutating func copyElements(from other: Self) {
        var span = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in span.indices {
            span[unchecked: i] = otherSpan[unchecked: i]
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
    mutating func copyElementsBLAS(from other: Self) {
        BLAS.dcopy(n: elements.count, x: other.elements, incX: 1, y: &elements, incY: 1)
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
    /// Diagonalizes the given symmetric matrix, i.e., computes it's eigenvalues and eigenvectors
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    @inlinable
    static func diagonalizeSymmetric(_ A: Matrix<Double>) throws -> (eigenValues: [Double], eigenVectors: [Vector<Double>]) {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenValues: [Double] = .init(repeating: .zero, count: A.rows)
        let info = LAPACK.dsyev(layout: .rowMajor, job: .vectors, triangle: .upper, n: N, a: &a, lda: N, w: &eigenValues)
        if info != 0 { throw MatrixOperationError.info(info) }
        var eigenVectors = [Vector<Double>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                eigenVectors[j][i] = a[N * i + j]
            }
        }
        return (eigenValues, eigenVectors)
    }

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValuesSymmetric(_ A: Matrix<Double>) throws -> [Double] {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenValues: [Double] = .init(repeating: .zero, count: N)
        let info = LAPACK.dsyev(layout: .rowMajor, job: .none, triangle: .upper, n: N, a: &a, lda: N, w: &eigenValues)
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
    static func diagonalize(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare, "Diagnalizing only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vl: [Double] = .init(repeating: .zero, count: N*N)
        var vr: [Double] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.dgeev(layout: .rowMajor, jobVL: .vectors, jobVR: .vectors, n: N, a: &a, lda: N, wr: &eigenReal, wi: &eigenImaginary, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var _leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    _leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j])
                    j += 1
                } else {
                    _leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j], vl[i * N + j + 1])
                    _leftEigenVectors[j + 1][i] = Complex<Double>(vl[i * N + j], -vl[i * N + j + 1])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j], vr[i * N + j + 1])
                    rightEigenVectors[j + 1][i] = Complex<Double>(vr[i * N + j], -vr[i * N + j + 1])
                    j += 2
                }
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
    static func diagonalizeLeft(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vl: [Double] = .init(repeating: .zero, count: N*N)
        var vr: [Double] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.dgeev(layout: .rowMajor, jobVL: .vectors, jobVR: .none, n: N, a: &a, lda: N, wr: &eigenReal, wi: &eigenImaginary, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j], vl[i * N + j + 1])
                    leftEigenVectors[j + 1][i] = Complex<Double>(vl[i * N + j], -vl[i * N + j + 1])
                    j += 2
                }
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
    static func diagonalizeRight(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.isSquare, "Diagonalization only works for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vl: [Double] = .init(repeating: .zero, count: N*N)
        var vr: [Double] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.dgeev(layout: .rowMajor, jobVL: .none, jobVR: .vectors, n: N, a: &a, lda: N, wr: &eigenReal, wi: &eigenImaginary, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j])
                    j += 1
                } else {
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j], vr[i * N + j + 1])
                    rightEigenVectors[j + 1][i] = Complex<Double>(vr[i * N + j], -vr[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, rightEigenVectors)
    }

    /// Computes the eigenvalues of the given matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    @inlinable
    static func eigenValues(_ A: Matrix<Double>) throws -> [Complex<Double>] {
        precondition(A.isSquare, "Eigenvalues are available only for square matrices")
        let N = A.rows
        var a = A.elements
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vl: [Double] = .init(repeating: .zero, count: N*N)
        var vr: [Double] = .init(repeating: .zero, count: N*N)
        let info = LAPACK.dgeev(layout: .rowMajor, jobVL: .none, jobVR: .none, n: N, a: &a, lda: N, wr: &eigenReal, wi: &eigenImaginary, vl: &vl, ldvl: N, vr: &vr, ldvr: N)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        return eigenValues
    }
    
    @inlinable
    static func solve(A: Matrix<Double>, b: Vector<Double>) throws -> Vector<Double> {
        let N = A.rows
        var a = A.elements
        var b = b.components
        var ipiv = [Int](repeating: .zero, count: N)
        let info = LAPACK.dgesv(layout: .rowMajor, n: N, nrhs: 1, a: &a, lda: N, ipiv: &ipiv, b: &b, ldb: 1)
        if info != 0 { throw MatrixOperationError.info(info) }
        return Vector(b)
    }

    @inlinable
    static func solve(A: Matrix<Double>, B: Matrix<Double>) throws -> Matrix<Double> {
        let N = A.rows
        let nrhs = B.columns
        var a = A.elements
        var b = B.elements
        var ipiv = [Int](repeating: .zero, count: N)
        let info = LAPACK.dgesv(layout: .rowMajor, n: N, nrhs: nrhs, a: &a, lda: N, ipiv: &ipiv, b: &b, ldb: nrhs)
        if info != 0 { throw MatrixOperationError.info(info) }
        return .init(elements: b, rows: N, columns: B.columns)
    }

    @inlinable
    static func singularValueDecomposition(A: Matrix<Double>) throws -> (U: Matrix<Double>, singularValues: [Double], VT: Matrix<Double>) {
        let m = A.rows
        let n = A.columns
        var a = A.elements
        var U: Matrix<Double> = .zeros(rows: A.rows, columns: A.rows)
        var VT: Matrix<Double> = .zeros(rows: A.columns, columns: A.columns)
        var singularValues: [Double] = .init(repeating: .zero, count: min(m, n))
        var superb: [Double] = .init(repeating: .zero, count: min(m, n))
        let info = LAPACK.dgesvd(layout: .rowMajor, jobU: .all, jobVT: .all, m: m, n: n, a: &a, lda: n, s: &singularValues, u: &U.elements, ldu: m, vt: &VT.elements, ldvt: n, superb: &superb)
        if info != 0 { throw MatrixOperationError.info(info) }
        return (U, singularValues, VT)
    }

    @inlinable
    static func schurDecomposition(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], U: Matrix<Double>, Q: Matrix<Double>) {
        precondition(A.isSquare, "Schur decomposition can only be calculated for square matrices")
        let N = A.rows
        var sdim = 0
        var eigenValuesReal: [Double] = .init(repeating: .zero, count: N)
        var eigenValuesImaginary: [Double] = .init(repeating: .zero, count: N)
        var schurVectors: [Double] = .init(repeating: .zero, count: A.elements.count)
        var a = A.elements
        let info = LAPACK.dgees(layout: .rowMajor, jobVS: .vectors, sort: .none, n: N, a: &a, lda: N, sdim: &sdim, wr: &eigenValuesReal, wi: &eigenValuesImaginary, vs: &schurVectors, ldvs: N)
        if info != 0 { throw MatrixOperationError.info(info) }
        let U = Matrix<Double>(elements: a, rows: A.rows, columns: A.columns)
        let Q = Matrix<Double>(elements: schurVectors, rows: A.rows, columns: A.columns)
        return (zip(eigenValuesReal, eigenValuesImaginary).map { Complex($0, $1) }, U, Q)
    }
}
