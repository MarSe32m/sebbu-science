//
//  Matrix+ComplexFloat.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

import LAPACKE
import BLAS

#if canImport(Accelerate)
import Accelerate
#endif

import RealModule
import ComplexModule
import NumericsExtensions

public extension Matrix<Complex<Float>> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    //@inlinable
    var inverse: Self? {
        if rows != columns { return nil }
        #if os(macOS)
        var a: [Complex<Float>] = []
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
            cgetrf_(&m, &n, OpaquePointer(a.baseAddress), &lda, &ipiv, &info)
        }
        if info != 0 { return nil }
        
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                cgetri_(&n, OpaquePointer(a.baseAddress), &lda, &ipiv, OpaquePointer(work.baseAddress!), &lwork, &info)
            }
        }
        if info != 0 { return nil }
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                cgetri_(&n, OpaquePointer(a.baseAddress), &lda, &ipiv, OpaquePointer(work.baseAddress!), &lwork, &info)
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
        if let LAPACKE_cgetrf = LAPACKE.cgetrf,
           let LAPACKE_cgetri = LAPACKE.cgetri {
            var a = elements
            var m = rows
            var lda = columns
            var ipiv: [lapack_int] = .init(repeating: .zero, count: m)
            var info = LAPACKE_cgetrf(LAPACKE.MatrixLayout.rowMajor.rawValue, numericCast(m), numericCast(m), &a, numericCast(lda), &ipiv)
            if info != 0 { return nil }
            info = LAPACKE_cgetri(LAPACKE.MatrixLayout.rowMajor.rawValue, numericCast(m), &a, numericCast(lda), ipiv)
            if info != 0 { return nil }
            return .init(elements: a, rows: rows, columns: columns)
        }
        fatalError("TODO: Not yet implemented")
        #endif
    }
}

//MARK: Copying elements
public extension Matrix<Complex<Float>> {
    @inlinable
    mutating func copyElements(from other: Self) {
        precondition(elements.count == other.elements.count)
        if let ccopy = BLAS.ccopy {
            let N = cblas_int(elements.count)
            ccopy(N, other.elements, 1, &elements, 1)
        } else {
            for i in 0..<elements.count {
                elements[i] = other.elements[i]
            }
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
    static func diagonalizeHermitian(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Float], eigenVectors: [Vector<Complex<Float>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
        var a: [Complex<Float>] = []
        
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        // LAPACK takes column-major order, so the leading order is the rows of the matrix
        var lda = A.rows
        var eigenValues: [Float] = .init(repeating: .zero, count: Int(n))
        
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        
        var rwork: [Float] = [.zero]
        var lrwork = -1
        
        var iwork: [Int] = [.zero]
        var liwork = -1
        
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                cheevd_("V", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
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
                cheevd_("V", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
            }
        }
        var eigenVectors = [Vector<Complex<Float>>](repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                eigenVectors[i][j] = a[n * i + j]
            }
        }
        return (eigenValues, eigenVectors)
#else
        if  let LAPACKE_cheevd = LAPACKE.cheevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Float] = .init(repeating: .zero, count: N)
            var _A: [Complex<Float>] = Array(A.elements)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_cheevd(LAPACKE.MatrixLayout.columnMajor.rawValue, V, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var eigenVectors = [Vector<Complex<Float>>](repeating: .zero(N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    eigenVectors[i][j] = _A[N * i + j]
                }
            }
            return (eigenValues, eigenVectors)
        }
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
    static func eigenValuesHermitian(_ A: Matrix<Complex<Float>>) throws -> [Float] {
#if os(macOS)
        precondition(A.rows == A.columns)
        var a: [Complex<Float>] = []
        
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        var n = A.rows
        // LAPACK takes column-major order, so the leading order is the rows of the matrix
        var lda = A.rows
        var eigenValues: [Float] = .init(repeating: .zero, count: Int(n))
        
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        
        var rwork: [Float] = [.zero]
        var lrwork = -1
        
        var iwork: [Int] = [.zero]
        var liwork = -1
        
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            work.withUnsafeMutableBufferPointer { work in
                cheevd_("N", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
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
                cheevd_("V", "U", &n, OpaquePointer(a.baseAddress), &lda, &eigenValues, OpaquePointer(work.baseAddress!), &lwork, &rwork, &lrwork, &iwork, &liwork, &info)
            }
        }
        return eigenValues
#else
        if  let LAPACKE_cheevd = LAPACKE.cheevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Float] = .init(repeating: .zero, count: N)
            var _A: [Complex<Float>] = Array(A.elements)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_cheevd(LAPACKE.MatrixLayout.columnMajor.rawValue, _N, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return eigenValues
        }
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
    static func diagonalize(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>], rightEigenVectors: [Vector<Complex<Float>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
        var n = A.rows
        var a: [Complex<Float>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: n)
        var vl: [Complex<Float>] = .init(repeating: .zero, count: n*n)
        var ldvl = A.rows
        var vr: [Complex<Float>] = .init(repeating: .zero, count: n*n)
        var ldvr = A.rows
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        var rwork: [Float] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vl.withUnsafeMutableBufferPointer { vl in
                    vr.withUnsafeMutableBufferPointer { vr in
                        work.withUnsafeMutableBufferPointer { work in
                            cgeev_("V", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
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
                            cgeev_("V", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                        }
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var leftEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        var rightEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                leftEigenVectors[j][i] = vl[n * i + j]
                rightEigenVectors[j][i] = vr[n * i + j]
            }
        }
        return (eigenValues, leftEigenVectors, rightEigenVectors)
#else
        if  let LAPACKE_cgeev = LAPACKE.cgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: N)
            var vl: [Complex<Float>] = .init(repeating: .zero, count: N*N)
            var vr: [Complex<Float>] = .init(repeating: .zero, count: N*N)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let info = LAPACKE_cgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, V, V, numericCast(N), &_A, numericCast(lda), &eigenValues, &vl, numericCast(ldvl), &vr, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var leftEigenVectors: [Vector<Complex<Float>>] = [Vector<Complex<Float>>](repeating: .zero(N), count: N)
            var rightEigenVectors: [Vector<Complex<Float>>] = [Vector<Complex<Float>>](repeating: .zero(N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    leftEigenVectors[j][i] = vl[N * i + j]
                    rightEigenVectors[j][i] = vr[N * i + j]
                }
            }
            return (eigenValues, leftEigenVectors, rightEigenVectors)
        }
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
    static func diagonalizeLeft(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [Vector<Complex<Float>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
        var n = A.rows
        var a: [Complex<Float>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: n)
        var vl: [Complex<Float>] = .init(repeating: .zero, count: n*n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        var rwork: [Float] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vl.withUnsafeMutableBufferPointer { vl in
                    work.withUnsafeMutableBufferPointer { work in
                        cgeev_("V", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
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
                        cgeev_("V", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), OpaquePointer(vl.baseAddress), &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var leftEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                leftEigenVectors[j][i] = vl[n * i + j]
            }
        }
        return (eigenValues, leftEigenVectors)
#else
        if let LAPACKE_cgeev = LAPACKE.cgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: N)
            var vl: [Complex<Float>] = .init(repeating: .zero, count: N*N)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_cgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, V, _N, numericCast(N), &_A, numericCast(lda), &eigenValues, &vl, numericCast(ldvl), nil, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var leftEigenVectors: [Vector<Complex<Float>>] = [Vector<Complex<Float>>](repeating: .zero(N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    leftEigenVectors[j][i] = vl[N * i + j]
                }
            }
            return (eigenValues, leftEigenVectors)
        }
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
    static func diagonalizeRight(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], rightEigenVectors: [Vector<Complex<Float>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
        var n = A.rows
        var a: [Complex<Float>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var vr: [Complex<Float>] = .init(repeating: .zero, count: n*n)
        var ldvr = A.rows
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        var rwork: [Float] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                vr.withUnsafeMutableBufferPointer { vr in
                    work.withUnsafeMutableBufferPointer { work in
                        cgeev_("N", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
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
                        cgeev_("N", "V", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, OpaquePointer(vr.baseAddress), &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                    }
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        var rightEigenVectors: [Vector<Complex<Float>>] = .init(repeating: .zero(n), count: n)
        for i in 0..<n {
            for j in 0..<n {
                rightEigenVectors[j][i] = vr[n * i + j]
            }
        }
        return (eigenValues, rightEigenVectors)
#else
        if  let LAPACKE_cgeev = LAPACKE.cgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: N)
            var vr: [Complex<Float>] = .init(repeating: .zero, count: N*N)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_cgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, _N, V, numericCast(N), &_A, numericCast(lda), &eigenValues, nil, numericCast(ldvl), &vr, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var rightEigenVectors: [Vector<Complex<Float>>] = [Vector<Complex<Float>>](repeating: .zero(N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    rightEigenVectors[j][i] = vr[N * i + j]
                }
            }
            return (eigenValues, rightEigenVectors)
        }
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
    static func eigenValues(_ A: Matrix<Complex<Float>>) throws -> [Complex<Float>] {
#if os(macOS)
        precondition(A.rows == A.columns)
        var n = A.rows
        var a: [Complex<Float>] = []
        a.reserveCapacity(n * n)
        for j in 0..<A.columns {
            for i in 0..<A.rows {
                a.append(A[i, j])
            }
        }
        
        var lda = A.rows
        var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: n)
        var ldvl = A.rows
        var ldvr = A.rows
        var work: [Complex<Float>] = [.zero]
        var lwork = -1
        var rwork: [Float] = .init(repeating: .zero, count: 2*n)
        var info = 0
        
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                work.withUnsafeMutableBufferPointer { work in
                    cgeev_("N", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                }
            }
        }
        
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        
        lwork = Int(work[0].real)
        work = .init(repeating: .zero, count: lwork)
        a.withUnsafeMutableBufferPointer { a in
            eigenValues.withUnsafeMutableBufferPointer { w in
                work.withUnsafeMutableBufferPointer { work in
                    cgeev_("N", "N", &n, OpaquePointer(a.baseAddress), &lda, OpaquePointer(w.baseAddress), nil, &ldvl, nil, &ldvr, OpaquePointer(work.baseAddress!), &lwork, &rwork, &info)
                }
            }
        }
        if info != 0 { throw MatrixOperationError.info(Int(info)) }
        return eigenValues
#else
        if  let LAPACKE_cgeev = LAPACKE.cgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: N)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_cgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, _N, _N, numericCast(N), &_A, numericCast(lda), &eigenValues, nil, numericCast(ldvl), nil, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return eigenValues
        }
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    //TODO: TEST!
    //@inlinable
    static func solve(A: Matrix<Complex<Float>>, b: Vector<Complex<Float>>) throws -> Vector<Complex<Float>> {
#if os(macOS)
        var a: [Complex<Float>] = []
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
                cgesv_(&N, &nrhs, OpaquePointer(A.baseAddress), &lda, &ipiv, OpaquePointer(b.baseAddress), &ldb, &info)
            }
        }
        if info != 0 { throw MatrixOperationError.info(info) }
        return Vector(_b)
#else
        if  let LAPACKE_cgesv = LAPACKE.cgesv {
            let N = A.rows
            let nrhs: lapack_int = 1
            let lda: lapack_int = lapack_int(N)
            let ldb: lapack_int = 1
            var ipiv = [lapack_int](repeating: .zero, count: N)
            var _A = Array(A.elements)
            var _b = Array(b.components)
            let info = LAPACKE_cgesv(LAPACKE.MatrixLayout.rowMajor.rawValue, numericCast(N), nrhs, &_A, lda, &ipiv, &_b, ldb)
            if info != 0 { throw MatrixOperationError.info(Int(info))}
            return Vector(_b)
        }
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
