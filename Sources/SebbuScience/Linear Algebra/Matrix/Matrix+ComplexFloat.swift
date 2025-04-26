//
//  Matrix+ComplexFloat.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

#if canImport(COpenBLAS)
import COpenBLAS
#endif
#if canImport(CLAPACK)
import CLAPACK
#endif

#if canImport(Accelerate)
import Accelerate
#endif

import RealModule
import ComplexModule

public extension Matrix<Complex<Float>> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    //@inlinable
    var inverse: Self? {
#if os(Windows) || os(Linux)
        if let LAPACKE_cgetrf = LAPACKE.cgetrf, 
           let LAPACKE_cgetri = LAPACKE.cgetri {
            if rows != columns { return nil }
            var a = elements
            var m = rows
            var lda = columns
            var ipiv: [Int32] = .init(repeating: .zero, count: m)
            var info = LAPACKE_cgetrf(LAPACK_ROW_MAJOR, numericCast(m), numericCast(m), &a, numericCast(lda), &ipiv)
            if info != 0 { return nil }
            info = LAPACKE_cgetri(LAPACK_ROW_MAJOR, numericCast(m), &a, numericCast(lda), ipiv)
            if info != 0 { return nil }
            return .init(elements: a, rows: rows, columns: columns)
        }
        fatalError("TODO: Not yet implemented")
#elseif os(macOS)
        if rows != columns { return nil }
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
        fatalError("TODO: Not yet implemented")
#endif
    }
    
    //MARK: Addition
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    
    @inlinable
    
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    //@inlinable
    mutating func add(_ other: Self, scaling: T) {
#if os(Windows) || os(Linux)
        if let cblas_caxpy = BLAS.caxpy {
            precondition(self.rows == other.rows)
            precondition(self.columns == other.columns)
            var alpha: T = scaling
            let N: Int32 = numericCast(elements.count)
            cblas_caxpy(N, &alpha, other.elements, 1, &elements, 1)
        } else {
            _add(other, scaling: scaling)
        }
#elseif os(macOS)
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        var alpha: T = scaling
        let N = elements.count
        withUnsafeMutablePointer(to: &alpha) { alpha in
            other.elements.withUnsafeBufferPointer { X in
                elements.withUnsafeMutableBufferPointer { Y in
                    cblas_caxpy(numericCast(N),
                                OpaquePointer(alpha),
                                OpaquePointer(X.baseAddress),
                                1,
                                OpaquePointer(Y.baseAddress),
                                1)
                }
            }
        }
#else
        _add(other, scaling: scaling)
#endif
    }
    
    @inlinable
    mutating func add(_ other: Self) {
        add(other, scaling: Complex(1.0))
    }
    
    //MARK: Subtraction
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inlinable
    static func -=(lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }
    
    @inlinable
    mutating func subtract(_ other: Self, scaling: T) {
        add(other, scaling: -scaling)
    }
    
    @inlinable
    mutating func subtract(_ other: Self) {
        subtract(other, scaling: Complex(1.0))
    }
    
    //MARK: Scaling
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    
    @inlinable
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    //@inlinable
    mutating func multiply(by: T) {
#if os(Windows) || os(Linux)
        if let cblas_cscal = BLAS.cscal {
            let N: Int32 = numericCast(elements.count)
            var alpha = by
            cblas_cscal(N, &alpha, &elements, 1)
        } else {
            _multiply(by: by)
        }
#elseif os(macOS)
        withUnsafePointer(to: by) { alpha in
            elements.withUnsafeMutableBufferPointer { X in
                cblas_cscal(X.count,
                            OpaquePointer(alpha),
                            OpaquePointer(X.baseAddress),
                            1)
            }
        }
#else
        _multiply(by: by)
#endif
    }
    
    //MARK: Division
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    
    @inlinable
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in elements.indices {
                elements[i] /= by
            }
        }
    }
}

//MARK: Matrix-Vector and Matrix-Matrix operations
public extension Matrix<Complex<Float>> {
    @inlinable
    func dot(_ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, into: inout Self) {
        dot(other, multiplied: .one, into: &into)
    }
    
    //@inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
#if os(Windows) || os(Linux)
        if let cblas_cgemm = BLAS.cgemm {
            precondition(self.columns == other.rows, "The matrices are incompatible for multiplication")
            precondition(into.rows == self.rows, "The resulting matrix has incompatible rows")
            precondition(into.columns == other.columns, "The resulting matrix has incompatible columns")
            let layout: CBLAS_ORDER = CblasRowMajor
            let transa: CBLAS_TRANSPOSE = CblasNoTrans
            let transb: CBLAS_TRANSPOSE = CblasNoTrans
            let m: Int32 = numericCast(self.rows)
            let n: Int32 = numericCast(other.columns)
            let k: Int32 = numericCast(self.columns)
            var alpha: T = multiplied
            let lda: Int32 = k
            var beta: T = .zero
            let ldb: Int32 = n
            let ldc: Int32 = n
            cblas_cgemm(layout, transa, transb, m, n, k, &alpha, elements, lda, other.elements, ldb, &beta, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
#elseif os(macOS)
        let lda = columns
        let ldb = other.columns
        let ldc = into.columns
        let beta: T = .zero
        withUnsafePointer(to: multiplied) { alpha in
            withUnsafePointer(to: beta) { beta in
                elements.withUnsafeBufferPointer { A in
                    other.elements.withUnsafeBufferPointer { B in
                        into.elements.withUnsafeMutableBufferPointer { C in
                            cblas_cgemm(CblasRowMajor,
                                        CblasNoTrans,
                                        CblasNoTrans,
                                        self.rows,
                                        other.columns,
                                        self.columns,
                                        OpaquePointer(alpha),
                                        OpaquePointer(A.baseAddress),
                                        lda,
                                        OpaquePointer(B.baseAddress),
                                        ldb, OpaquePointer(beta),
                                        OpaquePointer(C.baseAddress),
                                        ldc)
                        }
                    }
                }
            }
        }
#else
        _dot(other, multiplied: multiplied, into: &into)
#endif
    }
    
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        dot(vector, multiplied: .one, into: &into)
    }
    
    //@inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
#if os(Windows) || os(Linux)
        if let cblas_cgemv = BLAS.cgemv {
            precondition(self.columns == vector.components.count)
            precondition(self.rows == into.components.count)
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m: Int32 = numericCast(self.rows)
            let n: Int32 = numericCast(self.columns)
            var alpha: T = multiplied
            let lda: Int32 = n
            let incx: Int32 = 1
            let incy: Int32 = 1
            var beta: T = .zero
            cblas_cgemv(layout, trans, m, n, &alpha, elements, lda, vector.components, incx, &beta, &into.components, incy)
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
        }
#elseif os(macOS)
        let lda = columns
        let beta: T = .zero
        withUnsafePointer(to: multiplied) { alpha in
            withUnsafePointer(to: beta) { beta in
                elements.withUnsafeBufferPointer { A in
                    vector.components.withUnsafeBufferPointer { X in
                        into.components.withUnsafeMutableBufferPointer { Y in
                            cblas_cgemv(CblasRowMajor,
                                        CblasNoTrans,
                                        rows,
                                        columns,
                                        OpaquePointer(alpha),
                                        OpaquePointer(A.baseAddress),
                                        lda,
                                        OpaquePointer(X.baseAddress),
                                        1,
                                        OpaquePointer(beta),
                                        OpaquePointer(Y.baseAddress),
                                        1)
                        }
                    }
                }
            }
        }
#else
        _dot(vector, multiplied: multiplied, into: &into)
#endif
    }
    //TODO: Hermitean dot! chemv
}

public extension Matrix<Complex<Float>> {
    //MARK: Addition
    @inlinable
    mutating func add(_ other: Self, scaling: Float) {
        add(other, scaling: Complex(scaling))
    }
    
    //MARK: Subtraction
    @inlinable
    mutating func subtract(_ other: Self, scaling: Float) {
        add(other, scaling: Complex(-scaling))
    }
    
    //MARK: Scaling
    @inlinable
    static func *(lhs: Float, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    //@inlinable
    mutating func multiply(by: Float) {
#if os(Windows) || os(Linux)
        if let cblas_csscal = BLAS.csscal {
            cblas_csscal(numericCast(elements.count), by, &elements, 1)
        } else {
            multiply(by: Complex(by))
        }
#elseif os(macOS)
        elements.withUnsafeMutableBufferPointer { X in
            cblas_csscal(X.count, by, OpaquePointer(X.baseAddress), 1)
        }
#else
        multiply(by: Complex(by))
#endif
    }
    
    //MARK: Division
    @inlinable
    static func /(lhs: Self, rhs: Float) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Float) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: Float) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in elements.indices {
                elements[i] /= by
            }
        }
    }
}

//MARK: Copying elements
public extension Matrix<Complex<Float>> {
    //@inlinable
    mutating func copyElements(from other: Self) {
        precondition(elements.count == other.elements.count)
        #if os(Windows) || os(Linux)
        fatalError("TODO: Implement on Windows / Linux")
        #elseif os(macOS)
        elements.withUnsafeMutableBufferPointer { Y in
            other.elements.withUnsafeBufferPointer { X in
                cblas_ccopy(X.count, OpaquePointer(X.baseAddress), 1, OpaquePointer(Y.baseAddress), 1)
            }
        }
        #else
        for i in 0..<elements.count {
            elements[i] = other.elements[i]
        }
        #endif
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
#if os(Windows) || os(Linux)
        if  let LAPACKE_cheevd = LAPACKE.cheevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Float] = .init(repeating: .zero, count: N)
            var _A: [Complex<Float>] = Array(A.elements)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_cheevd(LAPACK_COL_MAJOR, V, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
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
#elseif os(macOS)
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
#if os(Windows) || os(Linux)
        if  let LAPACKE_cheevd = LAPACKE.cheevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Float] = .init(repeating: .zero, count: N)
            var _A: [Complex<Float>] = Array(A.elements)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_cheevd(LAPACK_COL_MAJOR, _N, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return eigenValues
        }
        fatalError("TODO: Default implementation not yet implemented")
#elseif os(macOS)
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
#if os(Windows) || os(Linux)
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
            let info = LAPACKE_cgeev(LAPACK_ROW_MAJOR, V, V, numericCast(N), &_A, numericCast(lda), &eigenValues, &vl, numericCast(ldvl), &vr, numericCast(ldvr))
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
#elseif os(macOS)
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
#if os(Windows) || os(Linux)
        if  let LAPACKE_cgeev = LAPACKE.cgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: N)
            var vl: [Complex<Float>] = .init(repeating: .zero, count: N*N)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_cgeev(LAPACK_ROW_MAJOR, V, _N, numericCast(N), &_A, numericCast(lda), &eigenValues, &vl, numericCast(ldvl), nil, numericCast(ldvr))
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
#elseif os(macOS)
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
#if os(Windows) || os(Linux)
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
            let info = LAPACKE_cgeev(LAPACK_ROW_MAJOR, _N, V, numericCast(N), &_A, numericCast(lda), &eigenValues, nil, numericCast(ldvl), &vr, numericCast(ldvr))
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
#elseif os(macOS)
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
#if os(Windows) || os(Linux)
        if  let LAPACKE_cgeev = LAPACKE.cgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenValues: [Complex<Float>] = .init(repeating: .zero, count: N)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_cgeev(LAPACK_ROW_MAJOR, _N, _N, numericCast(N), &_A, numericCast(lda), &eigenValues, nil, numericCast(ldvl), nil, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return eigenValues
        }
        fatalError("TODO: Default implementation not yet implemented")
#elseif os(macOS)
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
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    //TODO: TEST!
    //@inlinable
    static func solve(A: Matrix<Complex<Float>>, b: Vector<Complex<Float>>) throws -> Vector<Complex<Float>> {
#if os(Windows) || os(Linux)
        if  let LAPACKE_cgesv = LAPACKE.cgesv {
            let N = A.rows
            let nrhs: Int32 = 1
            let lda: Int32 = numericCast(N)
            let ldb: Int32 = 1
            var ipiv = [Int32](repeating: .zero, count: N)
            var _A = Array(A.elements)
            var _b = Array(b.components)
            let info = LAPACKE_cgesv(LAPACK_ROW_MAJOR, numericCast(N), nrhs, &_A, lda, &ipiv, &_b, ldb)
            if info != 0 { throw MatrixOperationError.info(Int(info))}
            return Vector(_b)
        }
        fatalError("TODO: Default implementation not yet implemented")
#elseif os(macOS)
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
        var ldb = 1
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
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
