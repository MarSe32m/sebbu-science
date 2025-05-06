//
//  Matrix+Double.swift
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

public extension Matrix<Double> {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    //@inlinable
    var inverse: Self? {
        if rows != columns { return nil }
#if os(macOS)
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
        if let LAPACKE_dgetrf = LAPACKE.dgetrf,
           let LAPACKE_dgetri = LAPACKE.dgetri {
            var a = elements
            var m = rows
            var lda = columns
            var ipiv: [lapack_int] = .init(repeating: .zero, count: m)
            var info = LAPACKE_dgetrf(LAPACKE.MatrixLayout.rowMajor.rawValue, numericCast(m), numericCast(m), &a, numericCast(lda), &ipiv)
            if info != 0 { return nil }
            info = LAPACKE_dgetri(LAPACKE.MatrixLayout.rowMajor.rawValue, numericCast(m), &a, numericCast(lda), ipiv)
            if info != 0 { return nil }
            return .init(elements: a, rows: rows, columns: columns)
        }
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
    
    @inlinable
    mutating func add(_ other: Self, scaling: T) {
        if let daxpy = BLAS.daxpy {
            precondition(rows == other.rows)
            precondition(columns == other.columns)
            let N = cblas_int(elements.count)
            daxpy(N, scaling, other.elements, 1, &elements, 1)
        } else {
            _add(other, scaling: scaling)
        }
    }
    
    @inlinable
    mutating func add(_ other: Self) {
        add(other, scaling: 1.0)
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
        subtract(other, scaling: 1.0)
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
        if let dscal = BLAS.dscal {
            let N = cblas_int(elements.count)
            dscal(N, by, &elements, 1)
        } else {
            _multiply(by: by)
        }
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
public extension Matrix<Double> {
    //MARK: General matrix-matrix multiply
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
        dot(other, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        if let dgemm = BLAS.dgemm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let layout = BLAS.Layout.rowMajor.rawValue
            let transA = BLAS.Transpose.noTranspose.rawValue
            let transB = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(other.columns), k = cblas_int(columns)
            let lda = k, ldb = n, ldc = n
            dgemm(layout, transA, transB, m, n, k, multiplied, elements, lda, other.elements, ldb, 0.0, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    //MARK: Symmetric matrix-matrix multiply
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ other: Self) -> Self {
        dot(symmetricSide: .left, other)
    }
    
    @inlinable
    func dotSymmetric(_ other: Self) -> Self {
        dot(symmetricSide: .right, other)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T) -> Self {
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(symmetricSide: symmetricSide, other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .left, other, multiplied: multiplied)
    }
    
    @inlinable
    func dotSymmetric(_ other: Self, multiplied: T) -> Self {
        dot(symmetricSide: .right, other, multiplied: multiplied)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, into: inout Self) {
        dot(symmetricSide: symmetricSide, other, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func symmetricDot(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .left, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotSymmetric(_ other: Self, multiplied: T, into: inout Self) {
        dot(symmetricSide: .right, other, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(symmetricSide: SymmetricSide, _ other: Self, multiplied: T, into: inout Self) {
        if let dsymm = BLAS.dsymm {
            precondition(columns == other.rows)
            precondition(into.rows == rows)
            precondition(into.columns == other.columns)
            let order = BLAS.Order.rowMajor.rawValue
            let _side = symmetricSide == .left ? BLAS.Side.left.rawValue : BLAS.Side.right.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let A = symmetricSide == .left ? self : other
            let B = symmetricSide == .right ? self : other
            let m = cblas_int(A.rows), n = cblas_int(B.columns)
            let lda = cblas_int(columns), ldb = n, ldc = n
            dsymm(order, _side, uplo, m, n, multiplied, A.elements, lda, B.elements, ldb, .zero, &into.elements, ldc)
        } else {
            //TODO: Implement symmetric matrix-matrix multiplication, for now fall back to gemm
            _dot(other, multiplied: multiplied, into: &into)
        }
    }
    
    //MARK: General matrix-vector multiply
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
        dot(vector, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let dgemv = BLAS.dgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            dgemv(layout, trans, m, n, multiplied, elements, lda, vector.components, 1, .zero, &into.components, 1)
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    
    //MARK: Symmetric matrix-vector multiply
    @inlinable
    func symmetricDot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, multiplied: 1.0, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, into: inout Vector<T>) {
        symmetricDot(vector, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        symmetricDot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func symmetricDot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let dsymv = BLAS.dsymv {
            precondition(rows == columns)
            precondition(vector.count == columns)
            precondition(rows == into.count)
            let order = BLAS.Order.rowMajor.rawValue
            let uplo = BLAS.UpperLower.upper.rawValue
            let N = cblas_int(rows)
            let lda = N
            dsymv(order, uplo, N, multiplied, elements, lda, vector.components, 1, .zero, &into.components, 1)
        } else {
            //TODO: Implement symmetric matrix-vector multiplication (default implementation)
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
}

//MARK: Copying elements
public extension Matrix<Double> {
    @inlinable
    mutating func copyElements(from other: Self) {
        precondition(elements.count == other.elements.count)
        if let dcopy = BLAS.dcopy {
            let N = cblas_int(elements.count)
            dcopy(N, other.elements, 1, &elements, 1)
        } else {
            for i in 0..<elements.count {
                elements[i] = other.elements[i]
            }
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
    //TODO: TESTS!
    //@inlinable
    static func diagonalizeSymmetric(_ A: Matrix<Double>) throws -> (eigenValues: [Double], eigenVectors: [Vector<Double>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dsyevd = LAPACKE.dsyevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Double] = .init(repeating: .zero, count: N)
            var _A: [Double] = Array(A.elements)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_dsyevd(LAPACKE.MatrixLayout.rowMajor.rawValue, V, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var eigenVectors = [Vector<Double>](repeating: .zero(N), count: N)
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

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    //@inlinable
    static func eigenValuesSymmetric(_ A: Matrix<Double>) throws -> [Double] {
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dsyevd = LAPACKE.dsyevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Double] = .init(repeating: .zero, count: N)
            var _A: [Double] = Array(A.elements)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_dsyevd(LAPACKE.MatrixLayout.rowMajor.rawValue, _N, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
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
    static func diagonalize(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>], rightEigenVectors: [Vector<Complex<Double>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dgeev = LAPACKE.dgeev {
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
            let info = LAPACKE_dgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, V, V, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, &vl, numericCast(ldvl), &vr, numericCast(ldvr))
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
    static func diagonalizeLeft(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [Vector<Complex<Double>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dgeev = LAPACKE.dgeev {
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
            let info = LAPACKE_dgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, V, _N, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, &vl, numericCast(ldvl), nil, numericCast(ldvr))
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
    static func diagonalizeRight(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [Vector<Complex<Double>>]) {
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dgeev = LAPACKE.dgeev {
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
            let info = LAPACKE_dgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, _N, V, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, nil, numericCast(ldvl), &vr, numericCast(ldvr))
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
        }
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
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dgeev = LAPACKE.dgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenReal: [Double] = .init(repeating: .zero, count: N)
            var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_dgeev(LAPACKE.MatrixLayout.rowMajor.rawValue, _N, _N, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, nil, numericCast(ldvl), nil, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
            return eigenValues
        }
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
    
    //TODO: Test!
    //@inlinable
    static func solve(A: Matrix<Double>, b: Vector<Double>) throws -> Vector<Double> {
#if os(macOS)
        precondition(A.rows == A.columns)
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
        if let LAPACKE_dgesv = LAPACKE.dgesv {
            let N = A.rows
            let nrhs: lapack_int = 1
            let lda: lapack_int = lapack_int(N)
            let ldb: lapack_int = 1
            var ipiv = [lapack_int](repeating: .zero, count: N)
            var _A = Array(A.elements)
            var _b = Array(b.components)
            let info = LAPACKE_dgesv(LAPACKE.MatrixLayout.rowMajor.rawValue, numericCast(N), nrhs, &_A, lda, &ipiv, &_b, ldb)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return Vector(_b)
        }
        fatalError("TODO: Default implementation not yet implemented")
#endif
    }
}
