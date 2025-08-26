//
//  Matrix+Double.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

import RealModule
import ComplexModule

public extension Matrix<Double> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    //@inlinable
    var inverse: Self? {
        if rows != columns { return nil }
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
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
        a.reserveCapacity(elements.count)
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
}

//MARK: Copying elements
public extension Matrix<Double> {
    @inlinable
    mutating func copyElements(from other: Self) {
        precondition(elements.count == other.elements.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(elements.count)
        cblas_dcopy(N, other.elements, 1, &elements, 1)
        #else
        for i in 0..<elements.count {
            elements[i] = other.elements[i]
        }
        #endif
    }
}

public extension MatrixOperations {
    /// Diagonalizes the given symmetric matrix, i.e., computes it's eigenvalues and eigenvectors
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeSymmetric(_ A: Matrix<Double>) throws -> (eigenValues: [Double], eigenVectors: [Vector<Double>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        var eigenValues: [Double] = .init(repeating: .zero, count: N)
        var _A: [Double] = Array(A.elements)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let U = Int8(bitPattern: UInt8(ascii: "U"))
        let info = LAPACKE_dsyevd(LAPACK_COL_MAJOR, V, U, .init(N), &_A, .init(lda), &eigenValues)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var eigenVectors = [Vector<Double>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                eigenVectors[i][j] = _A[N * i + j]
            }
        }
        return (eigenValues, eigenVectors)
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenValues: [Double] = .init(repeating: .zero, count: n)
        
        var work: [Double] = [.zero]
        var lwork = -1
        var iwork: [Int] = [.zero]
        var liwork = -1
        var info = 0
        dsyevd_("V", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        liwork = Int(iwork[0])
        iwork = .init(repeating: .zero, count: liwork)
        dsyevd_("V", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        var eigenVectors = [Vector<Double>](repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                eigenVectors[i][j] = a[n * i + j]
            }
        }
        return (eigenValues, eigenVectors)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    //@inlinable
    static func eigenValuesSymmetric(_ A: Matrix<Double>) throws -> [Double] {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        var eigenValues: [Double] = .init(repeating: .zero, count: N)
        var _A: [Double] = Array(A.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let U = Int8(bitPattern: UInt8(ascii: "U"))
        let info = LAPACKE_dsyevd(LAPACK_COL_MAJOR, _N, U, .init(N), &_A, .init(lda), &eigenValues)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return eigenValues
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenValues: [Double] = .init(repeating: .zero, count: n)
        
        var work: [Double] = [.zero]
        var lwork = -1
        var iwork: [Int] = [.zero]
        var liwork = -1
        var info = 0
        dsyevd_("N", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        liwork = Int(iwork[0])
        iwork = .init(repeating: .zero, count: liwork)
        dsyevd_("N", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        
        return eigenValues
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors and right eigenvectors
    //TODO: TESTS!
    //@inlinable
    static func diagonalize(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vl: [Double] = .init(repeating: .zero, count: N*N)
        var vr: [Double] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, V, V, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, &vl, .init(ldvl), &vr, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j], vl[i * N + j + 1])
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j], -vl[i * N + j + 1])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j], vr[i * N + j + 1])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j], -vr[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, leftEigenVectors, rightEigenVectors)
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Double] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: n)
        var vl: [Double] = .init(repeating: .zero, count: n * n)
        var ldvl = A.rows
        var vr: [Double] = .init(repeating: .zero, count: n * n)
        var ldvr = A.rows
        var work: [Double] = [.zero]
        var lwork = -1
        var info = 0
        dgeev_("V", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        dgeev_("V", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            var j = 0
            while j < n {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * n + j])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * n + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * n + j], vl[i * n + j + 1])
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * n + j], -vl[i * n + j + 1])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * n + j], vr[i * n + j + 1])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * n + j], -vr[i * n + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, leftEigenVectors, rightEigenVectors)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeLeft(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vl: [Double] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, V, _N, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, &vl, .init(ldvl), nil, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Double>>] =  .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j], vl[i * N + j + 1])
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * N + j], -vl[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, leftEigenVectors)
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Double] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: n)
        var vl: [Double] = .init(repeating: .zero, count: n * n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Double] = [.zero]
        var lwork = -1
        var info = 0
        dgeev_("V", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, nil, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        dgeev_("V", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, nil, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            var j = 0
            while j < n {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * n + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * n + j], vl[i * n + j + 1])
                    leftEigenVectors[j][i] = Complex<Double>(vl[i * n + j], -vl[i * n + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, leftEigenVectors)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and right eigenvectors
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeRight(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        var vr: [Double] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, _N, V, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, nil, .init(ldvl), &vr, .init(ldvr))
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
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * N + j], -vr[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, rightEigenVectors)
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Double] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var vr: [Double] = .init(repeating: .zero, count: n * n)
        var ldvr = A.rows
        var work: [Double] = [.zero]
        var lwork = -1
        var info = 0
        dgeev_("N", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        dgeev_("N", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            var j = 0
            while j < n {
                if eigenImaginary[j] == .zero {
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * n + j])
                    j += 1
                } else {
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * n + j], vr[i * n + j + 1])
                    rightEigenVectors[j][i] = Complex<Double>(vr[i * n + j], -vr[i * n + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, rightEigenVectors)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    /// Computes the eigenvalues of the given matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    //@inlinable
    static func eigenValues(_ A: Matrix<Double>) throws -> [Complex<Double>] {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Double] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, _N, _N, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, nil, .init(ldvl), nil, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        return eigenValues
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Double] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Double] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Double] = [.zero]
        var lwork = -1
        var info = 0
        dgeev_("N", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, nil, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        dgeev_("N", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, nil, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        return eigenValues
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    //TODO: Test!
    //@inlinable
    static func solve(A: Matrix<Double>, b: Vector<Double>) throws -> Vector<Double> {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let nrhs: lapack_int = 1
        let lda: lapack_int = lapack_int(N)
        let ldb: lapack_int = 1
        var ipiv = [lapack_int](repeating: .zero, count: N)
        var _A = Array(A.elements)
        var _b = Array(b.components)
        let info = LAPACKE_dgesv(LAPACK_ROW_MAJOR, .init(N), nrhs, &_A, lda, &ipiv, &_b, ldb)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return Vector(_b)
        #elseif canImport(Accelerate)
        var a: [Double] = []
        a.reserveCapacity(A.rows * A.columns)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var _b = b.components
        var n = A.rows
        var nrhs = 1
        var lda = A.rows
        var ipiv: [Int] = .init(repeating: .zero, count: n)
        var ldb = b.count
        var info = 0
        dgesv_(&n, &nrhs, &a, &lda, &ipiv, &_b, &ldb, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return Vector(_b)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
