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
        precondition(elements.count == other.elements.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _copyElementsBLAS(from: other)
        } else {
            _copyElements(from: other)
        }
    }

    @inlinable
    @_transparent
    mutating func _copyElements(from other: Self) {
        var span = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in span.indices {
            span[unchecked: i] = otherSpan[unchecked: i]
        }
    }

    @inlinable
    @_transparent
    mutating func _copyElementsBLAS(from other: Self) {
        BLAS.dcopy(elements.count, other.elements, 1, &elements, 1)
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
        lwork = max(1, Int(work[0]))
        work = .init(repeating: .zero, count: lwork)
        dgeev_("V", "V", &n, &a, &lda, &eigenReal, &eigenImaginary, &vl, &ldvl, &vr, &ldvr, &work, &lwork, &info)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
        var _leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        var i = 0
        while i < n {
            for j in 0..<n {
                if eigenImaginary[i] == .zero {
                    _leftEigenVectors[i][j] = Complex<Double>(vl[i * n + j])
                    rightEigenVectors[i][j] = Complex<Double>(vr[i * n + j])
                } else {
                    _leftEigenVectors[i][j] = Complex<Double>(vl[i * n + j], vl[(i + 1) * n + j])
                    _leftEigenVectors[i + 1][j] = _leftEigenVectors[i][j].conjugate
                    rightEigenVectors[i][j] = Complex<Double>(vr[i * n + j], vr[(i + 1) * n + j])
                    rightEigenVectors[i + 1][j] = rightEigenVectors[i][j].conjugate
                }
            }
            i += (eigenImaginary[i] == .zero ? 1 : 2)
        }
        let leftEigenVectors = _leftEigenVectors.indices.map { i in
            let s = _leftEigenVectors[i].inner(rightEigenVectors[i])
            return _leftEigenVectors[i].conjugate / s
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
                    leftEigenVectors[j + 1][i] = Complex<Double>(vl[i * N + j], -vl[i * N + j + 1])
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
        var i = 0
        while i < n {
            for j in 0..<n {
                if eigenImaginary[i] == .zero {
                    leftEigenVectors[i][j] = Complex<Double>(vl[i * n + j])
                } else {
                    leftEigenVectors[i][j] = Complex<Double>(vl[i * n + j], vl[(i + 1) * n + j])
                    leftEigenVectors[i + 1][j] = leftEigenVectors[i][j].conjugate
                }
            }
            i += (eigenImaginary[i] == .zero ? 1 : 2)
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
                    rightEigenVectors[j + 1][i] = Complex<Double>(vr[i * N + j], -vr[i * N + j + 1])
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
        var i = 0
        while i < n {
            for j in 0..<n {
                if eigenImaginary[i] == .zero {
                    rightEigenVectors[i][j] = Complex<Double>(vr[i * n + j])
                } else {
                    rightEigenVectors[i][j] = Complex<Double>(vr[i * n + j], vr[(i + 1) * n + j])
                    rightEigenVectors[i + 1][j] = rightEigenVectors[i][j].conjugate
                }
            }
            i += (eigenImaginary[i] == .zero ? 1 : 2)
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

    //TODO: TEST
    @inlinable
    static func solve(A: Matrix<Double>, B: Matrix<Double>) throws -> Matrix<Double> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let nrhs: lapack_int = numericCast(B.columns)
        let lda: lapack_int = numericCast(N)
        let ldb: lapack_int = nrhs
        var ipiv = [lapack_int](repeating: .zero, count: N)
        var _A = Array(A.elements)
        var _B = Array(B.elements)
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { b in 
                LAPACKE_dgesv(LAPACK_ROW_MAJOR, .init(N), nrhs, .init(A.baseAddress), lda, &ipiv, .init(b.baseAddress), ldb)
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info))}
        return .init(elements: _B, rows: N, columns: B.columns)
        #elseif canImport(Accelerate)
        var a = A.transpose.elements
        var b = B.transpose.elements
        var N = A.rows
        var nrhs = B.columns
        var lda = A.rows
        var ldb = B.rows
        var ipiv: [Int] = .init(repeating: .zero, count: N)
        var info = 0
        a.withUnsafeMutableBufferPointer { A in
            b.withUnsafeMutableBufferPointer { B in
                dgesv_(&N, &nrhs, .init(A.baseAddress), &lda, &ipiv, .init(B.baseAddress), &ldb, &info)
            }
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(info) }
        return .init(elements: b, rows: B.columns, columns: N).transpose
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    @inlinable
    static func singularValueDecomposition(A: Matrix<Double>) throws -> (U: Matrix<Double>, singularValues: [Double], VT: Matrix<Double>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        var _A = Array(A.elements)
        var U: Matrix<Double> = .zeros(rows: A.rows, columns: A.rows)
        var VT: Matrix<Double> = .zeros(rows: A.columns, columns: A.columns)
        var singularValues: [Double] = .init(repeating: 0.0, count: Int(min(m, n)))
        var superb: [Double] = .init(repeating: 0.0, count: Int(min(m, n)))
        let AChar = Int8(bitPattern: UInt8(ascii: "A"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            U.elements.withUnsafeMutableBufferPointer { U in
                VT.elements.withUnsafeMutableBufferPointer { VT in
                    LAPACKE_dgesvd(LAPACK_ROW_MAJOR, 
                                    AChar, AChar, 
                                    m, n, 
                                    .init(A.baseAddress), n, 
                                    &singularValues, 
                                    .init(U.baseAddress), m, 
                                    .init(VT.baseAddress), n, 
                                    &superb)
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return (U, singularValues, VT)
        #elseif canImport(Accelerate)
        var a = A.transpose.elements
        var m = A.rows
        var n = A.columns
        var lda = m

        var U: Matrix<Double> = .zeros(rows: m, columns: m)
        var ldu = m
        var VT: Matrix<Double> = .zeros(rows: n, columns: n)
        var ldvt = n
        var singularValues: [Double] = .init(repeating: .zero, count: Int(min(m, n)))
        var jobu = Int8(bitPattern: UInt8(ascii: "A"))
        var jobvt = Int8(bitPattern: UInt8(ascii: "A"))

        var info = 0
        var lwork = -1
        var wkopt: Double = .zero
        a.withUnsafeMutableBufferPointer { A in
            singularValues.withUnsafeMutableBufferPointer { S in 
                U.elements.withUnsafeMutableBufferPointer { U in 
                    VT.elements.withUnsafeMutableBufferPointer { VH in 
                        withUnsafeMutablePointer(to: &wkopt) { wkopt in 
                            dgesvd_(&jobu, &jobvt, 
                                    &m, &n, .init(A.baseAddress), &lda, 
                                    .init(S.baseAddress), .init(U.baseAddress), &ldu, .init(VH.baseAddress), &ldvt,
                                    .init(wkopt), &lwork, &info)
                        }
                    }
                }
            }
        }
        lwork = Int(wkopt)
        var work: [Double] = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { A in
            singularValues.withUnsafeMutableBufferPointer { S in 
                U.elements.withUnsafeMutableBufferPointer { U in 
                    VT.elements.withUnsafeMutableBufferPointer { VT in 
                        work.withUnsafeMutableBufferPointer { work in 
                            dgesvd_(&jobu, &jobvt, 
                                    &m, &n, .init(A.baseAddress), &lda, 
                                    .init(S.baseAddress), .init(U.baseAddress), &ldu, .init(VT.baseAddress), &ldvt,
                                    .init(work.baseAddress!), &lwork, &info)
                        }
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        return (U: U.transpose, singularValues: singularValues, VT: VT.transpose)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    //@inlinable
    static func schurDecomposition(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], U: Matrix<Double>, Q: Matrix<Double>) {
        precondition(A.rows == A.columns, "Schur decomposition can only be calculated for square matrices")
#if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let VChar = Int8(bitPattern: UInt8(ascii: "V"))
        let NChar = Int8(bitPattern: UInt8(ascii: "N"))
        let n = lapack_int(A.rows)
        var sdim: lapack_int = .zero
        var eigenValuesReal: [Double] = .init(repeating: .zero, count: A.rows)
        var eigenValuesImaginary: [Double] = .init(repeating: .zero, count: A.rows)
        var schurVectors: [Double] = .init(repeating: .zero, count: A.elements.count)
        var AElements = Array(A.elements)
        let info = LAPACKE_dgees(LAPACK_ROW_MAJOR, VChar, NChar, nil, n, &AElements, n, &sdim, &eigenValuesReal, &eigenValuesImaginary, &schurVectors, n)
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        let U = Matrix<Double>(elements: AElements, rows: A.rows, columns: A.columns)
        let Q = Matrix<Double>(elements: schurVectors, rows: A.rows, columns: A.columns)
        return (zip(eigenValuesReal, eigenValuesImaginary).map { Complex($0, $1) }, U, Q)
#elseif canImport(Accelerate)
        var VChar = Int8(bitPattern: UInt8(ascii: "V"))
        var NChar = Int8(bitPattern: UInt8(ascii: "N"))
        var n = lapack_int(A.rows)
        var AElements = A.transpose.elements
        
        var sdim: lapack_int = .zero
        var eigenValuesReal: [Double] = .init(repeating: .zero, count: A.rows)
        var eigenValuesImaginary: [Double] = .init(repeating: .zero, count: A.rows)
        var schurVectors: [Double] = .init(repeating: .zero, count: A.elements.count)
        
        var work: [Double] = [.zero]
        var lwork: Int = -1
        var info: Int = 0
        
        dgees_(&VChar, &NChar, nil, &n, &AElements, &n, &sdim, &eigenValuesReal, &eigenValuesImaginary, &schurVectors, &n, &work, &lwork, nil, &info)
        
        lwork = Swift.max(Int(work[0]), 1)
        work = .init(repeating: .zero, count: lwork)
        dgees_(&VChar, &NChar, nil, &n, &AElements, &n, &sdim, &eigenValuesReal, &eigenValuesImaginary, &schurVectors, &n, &work, &lwork, nil, &info)
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        let U = Matrix<Double>(elements: AElements, rows: A.rows, columns: A.columns).transpose
        let Q = Matrix<Double>(elements: schurVectors, rows: A.rows, columns: A.columns).transpose
        return (zip(eigenValuesReal, eigenValuesImaginary).map { Complex($0, $1) }, U, Q)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
