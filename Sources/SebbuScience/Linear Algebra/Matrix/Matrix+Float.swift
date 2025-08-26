//
//  Matrix+Float.swift
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

public extension Matrix<Float> {
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
        var info = LAPACKE_sgetrf(LAPACK_ROW_MAJOR, .init(m), .init(m), &a, .init(lda), &ipiv)
        if info != 0 { return nil }
        info = LAPACKE_sgetri(LAPACK_ROW_MAJOR, .init(m), &a, .init(lda), ipiv)
        if info != 0 { return nil }
        return .init(elements: a, rows: rows, columns: columns)
        #elseif canImport(Accelerate)
        var a: [Float] = []
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
        sgetrf_(&m, &n, &a, &lda, &ipiv, &info)
        if info != 0 { return nil }
        
        var work: [Float] = [.zero]
        var lwork = -1
        
        sgetri_(&n, &a, &lda, &ipiv, &work, &lwork, &info)
        if info != 0 { return nil }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        sgetri_(&n, &a, &lda, &ipiv, &work, &lwork, &info)
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
    var frobeniusNorm: Float {
        elements.reduce(.zero) { $0 + $1 * $1 }.squareRoot()
    }
}

//MARK: Copying elements
public extension Matrix<Float> {
    //@inlinable
    mutating func copyElements(from other: Self) {
        precondition(elements.count == other.elements.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(elements.count)
        cblas_scopy(N, other.elements, 1, &elements, 1)
        #else
        for i in 0..<elements.count {
            elements[i] = other.elements[i]
        }
        #endif
    }
}

public extension MatrixOperations {
    /// Diagonalizes the given symmetric matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeSymmetric(_ A: Matrix<Float>) throws -> (eigenValues: [Float], eigenVectors: [Vector<Float>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        var eigenValues: [Float] = .init(repeating: .zero, count: N)
        var _A: [Float] = Array(A.elements)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let U = Int8(bitPattern: UInt8(ascii: "U"))
        let info = LAPACKE_ssyevd(LAPACK_COL_MAJOR, V, U, .init(N), &_A, .init(lda), &eigenValues)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var eigenVectors = [Vector<Float>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                eigenVectors[i][j] = _A[N * i + j]
            }
        }
        return (eigenValues, eigenVectors)
        #elseif canImport(Accelerate)
        var a: [Float] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenValues: [Float] = .init(repeating: .zero, count: n)
        
        var work: [Float] = [.zero]
        var lwork = -1
        var iwork: [Int] = [.zero]
        var liwork = -1
        var info = 0
        ssyevd_("V", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        liwork = Int(iwork[0])
        iwork = .init(repeating: .zero, count: liwork)
        ssyevd_("V", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        var eigenVectors = [Vector<Float>](repeating: .zero(n), count: n)
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
    static func eigenValuesSymmetric(_ A: Matrix<Float>) throws -> [Float] {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        var eigenValues: [Float] = .init(repeating: .zero, count: N)
        var _A: [Float] = Array(A.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let U = Int8(bitPattern: UInt8(ascii: "U"))
        let info = LAPACKE_ssyevd(LAPACK_COL_MAJOR, _N, U, .init(N), &_A, .init(lda), &eigenValues)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return eigenValues
        #elseif canImport(Accelerate)
        var a: [Float] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenValues: [Float] = .init(repeating: .zero, count: n)
        
        var work: [Float] = [.zero]
        var lwork = -1
        var iwork: [Int] = [.zero]
        var liwork = -1
        var info = 0
        ssyevd_("N", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        liwork = Int(iwork[0])
        iwork = .init(repeating: .zero, count: liwork)
        ssyevd_("N", "U", &n, &a, &lda, &eigenValues, &work, &lwork, &iwork, &liwork, &info)
        
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
    /// - Returns: A tuple containing the eigenvalues, left eigenvectors and right eigenvectors
    /// - Note: If you know your matrix is symmetric, consider using ```diagonalizeSymmetric(_:,rows:)``` method instead.
    //TODO: TESTS!
    //@inlinable
    static func diagonalize(_ A: Matrix<Float>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>], rightEigenVectors: [Vector<Complex<Float>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Float] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: N)
        var vl: [Float] = .init(repeating: .zero, count: N*N)
        var vr: [Float] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let info = LAPACKE_sgeev(LAPACK_ROW_MAJOR, V, V, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, &vl, .init(ldvl), &vr, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(N), count: N)
        var rightEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * N + j])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * N + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * N + j], vl[i * N + j + 1])
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * N + j], -vl[i * N + j + 1])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * N + j], vr[i * N + j + 1])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * N + j], -vr[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, leftEigenVectors, rightEigenVectors)
        #elseif canImport(Accelerate)
        var a: [Float] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Float] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: n)
        var vl: [Float] = .init(repeating: .zero, count: n * n)
        var ldvl = A.rows
        var vr: [Float] = .init(repeating: .zero, count: n * n)
        var ldvr = A.rows
        var work: [Float] = [.zero]
        var lwork = -1
        var info = 0
        sgeev_("V", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        sgeev_("V", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        var rightEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            var j = 0
            while j < n {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * n + j])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * n + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * n + j], vl[i * n + j + 1])
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * n + j], -vl[i * n + j + 1])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * n + j], vr[i * n + j + 1])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * n + j], -vr[i * n + j + 1])
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
    /// - Note: If you know your matrix is symmetric, consider using ```diagonalizeSymmetric(_:,rows:)``` method instead.
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeLeft(_ A: Matrix<Float>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Float] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: N)
        var vl: [Float] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = LAPACKE_sgeev(LAPACK_ROW_MAJOR, V, _N, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, &vl, .init(ldvl), nil, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Float>>] = [Vector<Complex<Float>>](repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * N + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * N + j], vl[i * N + j + 1])
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * N + j], -vl[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, leftEigenVectors)
        #elseif canImport(Accelerate)
        var a: [Float] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Float] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: n)
        var vl: [Float] = .init(repeating: .zero, count: n * n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Float] = [.zero]
        var lwork = -1
        var info = 0
        sgeev_("V", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, nil, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        sgeev_("V", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, nil, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        var leftEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            var j = 0
            while j < n {
                if eigenImaginary[j] == .zero {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * n + j])
                    j += 1
                } else {
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * n + j], vl[i * n + j + 1])
                    leftEigenVectors[j][i] = Complex<Float>(vl[i * n + j], -vl[i * n + j + 1])
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
    /// - Note: If you know your matrix is symmetric, consider using ```diagonalizeSymmetric(_:,rows:)``` method instead.
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeRight(_ A: Matrix<Float>) throws -> (eigenValues: [Complex<Float>], rightEigenVectors: [Vector<Complex<Float>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Float] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: N)
        var vr: [Float] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = LAPACKE_sgeev(LAPACK_ROW_MAJOR, _N, V, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, nil, .init(ldvl), &vr, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        var rightEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            var j = 0
            while j < N {
                if eigenImaginary[j] == .zero {
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * N + j])
                    j += 1
                } else {
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * N + j], vr[i * N + j + 1])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * N + j], -vr[i * N + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, rightEigenVectors)
        #elseif canImport(Accelerate)
        var a: [Float] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Float] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var vr: [Float] = .init(repeating: .zero, count: n * n)
        var ldvr = A.rows
        var work: [Float] = [.zero]
        var lwork = -1
        var info = 0
        sgeev_("N", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        sgeev_("N", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        var rightEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            var j = 0
            while j < n {
                if eigenImaginary[j] == .zero {
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * n + j])
                    j += 1
                } else {
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * n + j], vr[i * n + j + 1])
                    rightEigenVectors[j][i] = Complex<Float>(vr[i * n + j], -vr[i * n + j + 1])
                    j += 2
                }
            }
        }
        return (eigenValues, rightEigenVectors)
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
    static func eigenValues(_ A: Matrix<Float>) throws -> [Complex<Float>] {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenReal: [Float] = .init(repeating: .zero, count: N)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: N)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = LAPACKE_sgeev(LAPACK_ROW_MAJOR, _N, _N, .init(N), &_A, .init(lda), &eigenReal, &eigenImaginary, nil, .init(ldvl), nil, .init(ldvr))
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        return eigenValues
        #elseif canImport(Accelerate)
        precondition(A.rows == A.columns)
        var a: [Float] = []
        a.reserveCapacity(A.elements.count)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        var lda = A.rows
        var eigenReal: [Float] = .init(repeating: .zero, count: n)
        var eigenImaginary: [Float] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Float] = [.zero]
        var lwork = -1
        var info = 0
        sgeev_("N", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, nil, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        lwork = Int(work[0])
        work = .init(repeating: .zero, count: lwork)
        sgeev_("N", "N", &n, &a, &lda, &eigenReal, &eigenImaginary, nil, &ldvl, nil, &ldvr, &work, &lwork, &info)
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Float>($0, $1) })
        return eigenValues
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    //TODO: TEST!
    //@inlinable
    static func solve(A: Matrix<Float>, b: Vector<Float>) throws -> Vector<Float> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let nrhs: lapack_int = 1
        let lda: lapack_int = lapack_int(N)
        let ldb: lapack_int = 1
        var ipiv = [lapack_int](repeating: .zero, count: N)
        var _A = Array(A.elements)
        var _b = Array(b.components)
        let info = LAPACKE_sgesv(LAPACK_ROW_MAJOR, .init(N), nrhs, &_A, lda, &ipiv, &_b, ldb)
        if info != 0 { throw MatrixOperationError.info(Int(info))}
        return Vector(_b)
        #elseif canImport(Accelerate)
        precondition(A.rows == A.columns)
        var a: [Float] = []
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
        sgesv_(&n, &nrhs, &a, &lda, &ipiv, &_b, &ldb, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return Vector(_b)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
