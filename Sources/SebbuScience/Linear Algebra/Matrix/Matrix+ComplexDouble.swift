//
//  Matrix+ComplexDouble.swift
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
import NumericsExtensions

public extension Matrix<Complex<Double>> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    @inlinable
    var inverse: Self? {
        if rows != columns { return nil }
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        var a = elements
        var m = rows
        var lda = columns
        var ipiv: [lapack_int] = .init(repeating: .zero, count: m)
        var info = a.withUnsafeMutableBufferPointer { a in 
            LAPACKE_zgetrf(LAPACK_ROW_MAJOR, .init(m), .init(m), .init(a.baseAddress), .init(lda), &ipiv)
        }
        if info != 0 { return nil }
        info = a.withUnsafeMutableBufferPointer { a in 
            LAPACKE_zgetri(LAPACK_ROW_MAJOR, .init(m), .init(a.baseAddress), .init(lda), ipiv)
        }
        if info != 0 { return nil }
        return .init(elements: a, rows: rows, columns: columns)
        #elseif canImport(Accelerate)
        var a: [Complex<Double>] = []
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
        a.withUnsafeMutableBufferPointer { a in
            zgetrf_(&m, &n, OpaquePointer(a.baseAddress), &lda, &ipiv, &info)
        }
        if info != 0 { return nil }

        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                zgetri_(&n, OpaquePointer(a.baseAddress), &lda, &ipiv, OpaquePointer(work.baseAddress!), &lwork, &info)
            }
        }
        if info != 0 { return nil }
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                zgetri_(&n, OpaquePointer(a.baseAddress), &lda, &ipiv, OpaquePointer(work.baseAddress!), &lwork, &info)
            }
        }
        if info != 0 { return nil }
        return .init(rows: rows, columns: columns) { buffer in
            for i in 0..<rows {
                for j in 0..<columns {
                    buffer[i * n + j] = a[j * n + i]
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
        BLAS.zcopy(elements.count, other.elements, 1, &elements, 1)
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
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeHermitian(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Double], eigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        var eigenValues: [Double] = .init(repeating: .zero, count: N)
        var _A: [Complex<Double>] = Array(A.elements)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let U = Int8(bitPattern: UInt8(ascii: "U"))
        let info = _A.withUnsafeMutableBufferPointer { A in 
            LAPACKE_zheevd(LAPACK_COL_MAJOR, V, U, .init(N), .init(A.baseAddress), .init(lda), &eigenValues)
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var eigenVectors = [Vector<Complex<Double>>](repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                eigenVectors[i][j] = _A[N * i + j]
            }
        }
        return (eigenValues, eigenVectors)
        #elseif canImport(Accelerate)
        var a: [Complex<Double>] = []
        
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        // LAPACK takes column-major order, so the leading order is the rows of the matrix
        var lda = A.rows
        var eigenValues: [Double] = .init(repeating: .zero, count: Int(n))
        
        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        
        var rwork: [Double] = [.zero]
        var lrwork = -1
        
        var iwork: [Int] = [.zero]
        var liwork = -1
        
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                zheevd_("V", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        lrwork = Int(rwork[0])
        liwork = iwork[0]
        
        work = .init(repeating: .zero, count: lwork)
        rwork = .init(repeating: .zero, count: lrwork)
        iwork = .init(repeating: .zero, count: liwork)

        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                zheevd_("V", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
            }
        }
        var eigenVectors = [Vector<Complex<Double>>](repeating: .zero(n), count: n)
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

    /// Computes the eigenvalues of the given hermitian matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    //@inlinable
    static func eigenValuesHermitian(_ A: Matrix<Complex<Double>>) throws -> [Double] {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        var eigenValues: [Double] = .init(repeating: .zero, count: N)
        var _A: [Complex<Double>] = Array(A.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let U = Int8(bitPattern: UInt8(ascii: "U"))
        let info = _A.withUnsafeMutableBufferPointer { A in 
            LAPACKE_zheevd(LAPACK_COL_MAJOR, _N, U, .init(N), .init(A.baseAddress), .init(lda), &eigenValues)
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return eigenValues
        #elseif canImport(Accelerate)
        var a: [Complex<Double>] = []
        
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        // LAPACK takes column-major order, so the leading order is the rows of the matrix
        var lda = A.rows
        var eigenValues: [Double] = .init(repeating: .zero, count: Int(n))
        
        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        
        var rwork: [Double] = [.zero]
        var lrwork = -1
        
        var iwork: [Int] = [.zero]
        var liwork = -1
        
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                zheevd_("N", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        lrwork = Int(rwork[0])
        liwork = iwork[0]
        
        work = .init(repeating: .zero, count: lwork)
        rwork = .init(repeating: .zero, count: lrwork)
        iwork = .init(repeating: .zero, count: liwork)

        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                zheevd_("N", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
            }
        }
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
    static func diagonalize(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        var vr: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let info = _A.withUnsafeMutableBufferPointer { A in 
            eigenValues.withUnsafeMutableBufferPointer { eigenValues in
                vl.withUnsafeMutableBufferPointer { vl in 
                    vr.withUnsafeMutableBufferPointer { vr in 
                        LAPACKE_zgeev(LAPACK_ROW_MAJOR, V, V, .init(N), .init(A.baseAddress), .init(lda), .init(eigenValues.baseAddress), .init(vl.baseAddress), .init(ldvl), .init(vr.baseAddress), .init(ldvr))
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                leftEigenVectors[j][i] = vl[N * i + j]
                rightEigenVectors[j][i] = vr[N * i + j]
            }
        }
        return (eigenValues, leftEigenVectors, rightEigenVectors)
        #elseif canImport(Accelerate)
        var n = A.rows
        var a: [Complex<Double>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: n)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: n*n)
        var ldvl = A.rows
        var vr: [Complex<Double>] = .init(repeating: .zero, count: n*n)
        var ldvr = A.rows
        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        var rwork: [Double] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vl.withUnsafeMutableBufferPointer { vl in
                    vr.withUnsafeMutableBufferPointer { vr in
                        work.withUnsafeMutableBufferPointer { work in
                            zgeev_("V", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                        }
                    }
                }
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vl.withUnsafeMutableBufferPointer { vl in
                    vr.withUnsafeMutableBufferPointer { vr in
                        work.withUnsafeMutableBufferPointer { work in
                            zgeev_("V", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                        }
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                leftEigenVectors[j][i] = vl[n * i + j]
                rightEigenVectors[j][i] = vr[n * i + j]
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
    static func diagonalizeLeft(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in 
            eigenValues.withUnsafeMutableBufferPointer { eigenValues in 
                vl.withUnsafeMutableBufferPointer { vl in 
                    LAPACKE_zgeev(LAPACK_ROW_MAJOR, V, _N, numericCast(N), .init(A.baseAddress), .init(lda), .init(eigenValues.baseAddress), .init(vl.baseAddress), .init(ldvl), nil, .init(ldvr))
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                leftEigenVectors[j][i] = vl[N * i + j]
            }
        }
        return (eigenValues, leftEigenVectors)
        #elseif canImport(Accelerate)
        var n = A.rows
        var a: [Complex<Double>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: n)
        var vl: [Complex<Double>] = .init(repeating: .zero, count: n*n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        var rwork: [Double] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vl.withUnsafeMutableBufferPointer { vl in
                    work.withUnsafeMutableBufferPointer { work in
                        zgeev_("V", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                    }
                }
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vl.withUnsafeMutableBufferPointer { vl in
                    work.withUnsafeMutableBufferPointer { work in
                        zgeev_("V", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var leftEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                leftEigenVectors[j][i] = vl[n * i + j]
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
    static func diagonalizeRight(_ A: Matrix<Complex<Double>>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [Vector<Complex<Double>>]) {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: N)
        var vr: [Complex<Double>] = .init(repeating: .zero, count: N*N)
        let V = Int8(bitPattern: UInt8(ascii: "V"))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in 
            eigenValues.withUnsafeMutableBufferPointer { eigenValues in 
                vr.withUnsafeMutableBufferPointer { vr in 
                    LAPACKE_zgeev(LAPACK_ROW_MAJOR, _N, V, .init(N), .init(A.baseAddress), .init(lda), .init(eigenValues.baseAddress), nil, .init(ldvl), .init(vr.baseAddress), .init(ldvr))
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(N), count: N)
        for i in 0..<N {
            for j in 0..<N {
                rightEigenVectors[j][i] = vr[N * i + j]
            }
        }
        return (eigenValues, rightEigenVectors)
        #elseif canImport(Accelerate)
        var n = A.rows
        var a: [Complex<Double>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var vr: [Complex<Double>] = .init(repeating: .zero, count: n*n)
        var ldvr = A.rows
        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        var rwork: [Double] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vr.withUnsafeMutableBufferPointer { vr in
                    work.withUnsafeMutableBufferPointer { work in
                        zgeev_("N", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                    }
                }
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vr.withUnsafeMutableBufferPointer { vr in
                    work.withUnsafeMutableBufferPointer { work in
                        zgeev_("N", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var rightEigenVectors: [Vector<Complex<Double>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                rightEigenVectors[j][i] = vr[n * i + j]
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
    static func eigenValues(_ A: Matrix<Complex<Double>>) throws -> [Complex<Double>] {
        precondition(A.rows == A.columns)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = lapack_int(A.rows)
        let lda = N
        let ldvl = N
        let ldvr = N
        var _A = Array(A.elements)
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: Int(N))
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in 
            eigenValues.withUnsafeMutableBufferPointer { eigenValues in
                LAPACKE_zgeev(LAPACK_ROW_MAJOR, _N, _N, N, .init(A.baseAddress), .init(lda), .init(eigenValues.baseAddress), nil, .init(ldvl), nil, .init(ldvr))
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return eigenValues
        #elseif canImport(Accelerate)
        var n = A.rows
        var a: [Complex<Double>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Double>] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Complex<Double>] = [.zero]
        var lwork = -1
        var rwork: [Double] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                work.withUnsafeMutableBufferPointer { work in
                    zgeev_("N", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                }
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                work.withUnsafeMutableBufferPointer { work in
                    zgeev_("N", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return eigenValues
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    //TODO: TEST
    //@inlinable
    static func solve(A: Matrix<Complex<Double>>, b: Vector<Complex<Double>>) throws -> Vector<Complex<Double>> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = A.rows
        let nrhs: lapack_int = 1
        let lda: lapack_int = numericCast(N)
        let ldb: lapack_int = 1
        var ipiv = [lapack_int](repeating: .zero, count: N)
        var _A = Array(A.elements)
        var _b = Array(b.components)
        let info = _A.withUnsafeMutableBufferPointer { A in
            _b.withUnsafeMutableBufferPointer { b in 
                LAPACKE_zgesv(LAPACK_ROW_MAJOR, .init(N), nrhs, .init(A.baseAddress), lda, &ipiv, .init(b.baseAddress), ldb)
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info))}
        return Vector(_b)
        #elseif canImport(Accelerate)
        var a: [Complex<Double>] = []
        a.reserveCapacity(A.elements.count)
        // Convert to columns major order
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var _b = b.components
        var N = A.rows
        var nrhs = 1
        var lda = A.columns
        var ldb = b.count
        var ipiv: [Int] = .init(repeating: .zero, count: N)
        var info = 0
        a.withUnsafeMutableBufferPointer { A in
            _b.withUnsafeMutableBufferPointer { b in
                zgesv_(&N, &nrhs, OpaquePointer(A.baseAddress), &lda, &ipiv, OpaquePointer(b.baseAddress), &ldb, &info)
            }
        }
        if info != 0 { throw MatrixOperationError.info(info) }
        return Vector(_b)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    //TODO: TEST
    //@inlinable
    static func solve(A: Matrix<Complex<Double>>, B: Matrix<Complex<Double>>) throws -> Matrix<Complex<Double>> {
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
                LAPACKE_zgesv(LAPACK_ROW_MAJOR, .init(N), nrhs, .init(A.baseAddress), lda, &ipiv, .init(b.baseAddress), ldb)
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
                zgesv_(&N, &nrhs, .init(A.baseAddress), &lda, &ipiv, .init(B.baseAddress), &ldb, &info)
            }
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(info) }
        return .init(elements: b, rows: B.columns, columns: N).transpose
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }

    //TODO: TEST
    //@inlinable
    static func singularValueDecomposition(A: Matrix<Complex<Double>>) throws -> (U: Matrix<Complex<Double>>, singularValues: [Double], VH: Matrix<Complex<Double>>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        var _A = Array(A.elements)
        var U: Matrix<Complex<Double>> = .zeros(rows: A.rows, columns: A.rows)
        var VH: Matrix<Complex<Double>> = .zeros(rows: A.columns, columns: A.columns)
        var singularValues: [Double] = .init(repeating: 0.0, count: Int(min(m, n)))
        var superb: [Double] = .init(repeating: 0.0, count: Int(min(m, n)))
        let AChar = Int8(bitPattern: UInt8(ascii: "A"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            U.elements.withUnsafeMutableBufferPointer { U in
                VH.elements.withUnsafeMutableBufferPointer { VH in
                    LAPACKE_zgesvd(LAPACK_ROW_MAJOR, 
                                    AChar, AChar, 
                                    m, n, 
                                    .init(A.baseAddress), n, 
                                    &singularValues, 
                                    .init(U.baseAddress), m, 
                                    .init(VH.baseAddress), n, 
                                    &superb)
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return (U, singularValues, VH)
        #elseif canImport(Accelerate)
        var a = A.transpose.elements
        var m = A.rows
        var n = A.columns
        var lda = m

        var U: Matrix<Complex<Double>> = .zeros(rows: m, columns: m)
        var ldu = m
        var VH: Matrix<Complex<Double>> = .zeros(rows: n, columns: n)
        var ldvt = n
        var singularValues: [Double] = .init(repeating: .zero, count: Int(min(m, n)))
        var jobu = Int8(bitPattern: UInt8(ascii: "A"))
        var jobvt = Int8(bitPattern: UInt8(ascii: "A"))

        var info = 0
        var lwork = -1
        var rwork: [Double] = .init(repeating: .zero, count: 5 * min(m, n))
        var wkopt: Complex<Double> = .zero
        a.withUnsafeMutableBufferPointer { A in
            singularValues.withUnsafeMutableBufferPointer { S in 
                U.elements.withUnsafeMutableBufferPointer { U in 
                    VH.elements.withUnsafeMutableBufferPointer { VH in 
                        withUnsafeMutablePointer(to: &wkopt) { wkopt in 
                            zgesvd_(&jobu, &jobvt, 
                                    &m, &n, .init(A.baseAddress), &lda, 
                                    .init(S.baseAddress), .init(U.baseAddress), &ldu, .init(VH.baseAddress), &ldvt,
                                    .init(wkopt), &lwork, &rwork, &info)
                        }
                    }
                }
            }
        }
        lwork = Int(wkopt.real)
        var work: [Complex<Double>] = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { A in
            singularValues.withUnsafeMutableBufferPointer { S in 
                U.elements.withUnsafeMutableBufferPointer { U in 
                    VH.elements.withUnsafeMutableBufferPointer { VH in 
                        work.withUnsafeMutableBufferPointer { work in 
                            zgesvd_(&jobu, &jobvt, 
                                    &m, &n, .init(A.baseAddress), &lda, 
                                    .init(S.baseAddress), .init(U.baseAddress), &ldu, .init(VH.baseAddress), &ldvt,
                                    .init(work.baseAddress!), &lwork, &rwork, &info)
                        }
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        return (U: U.transpose, singularValues: singularValues, VH: VH.transpose)
#else
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
