//
//  Matrix+Double.swift
//  swift-phd-toivonen
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

#if canImport(COpenBLAS)
import COpenBLAS
#endif
#if canImport(CLAPACK)
import CLAPACK
#endif
import RealModule
import ComplexModule

public extension Matrix<Double> {
    var inverse: Self { fatalError("TODO: Not yet implemented") }

    //MARK: Addition
    @inline(__always)
    @inlinable
    @_transparent
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inline(__always)
    @inlinable
    mutating func add(_ other: Self, scaling: T) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        if let cblas_daxpy = BLAS.daxpy {
            cblas_daxpy(numericCast(elements.count), scaling, other.elements, 1, &elements, 1)
        } else {
            _add(other, scaling: scaling)
        }
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, scaling: 1.0)
    }
    
    //MARK: Subtraction
    @inline(__always)
    @inlinable
    @_transparent
    static func -(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.subtract(rhs)
        return resultMatrix
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: Self) {
        lhs.subtract(rhs)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, scaling: T) {
        add(other, scaling: -scaling)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self) {
        subtract(other, scaling: 1.0)
    }
    
    //MARK: Scaling
    @inline(__always)
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        if let cblas_dscal = BLAS.dscal {
            cblas_dscal(numericCast(elements.count), by, &elements, 1)
        } else {
            _multiply(by: by)
        }
    }
    
    //MARK: Division
    @inline(__always)
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inline(__always)
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
    @inlinable
    @inline(__always)
    @_transparent
    func dot(_ other: Self) -> Self {
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    @inline(__always)
    @_transparent
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
        if let cblas_dgemm = BLAS.dgemm {
            precondition(columns == other.rows, "The matrices are incompatible for multiplication")
            precondition(into.rows == self.rows, "The resulting matrix has incompatible rows")
            precondition(into.columns == other.columns, "The resulting matrix has incompatible columns")
            let layout: CBLAS_ORDER = CblasRowMajor
            let transa: CBLAS_TRANSPOSE = CblasNoTrans
            let transb: CBLAS_TRANSPOSE = CblasNoTrans
            let m: Int32 = numericCast(rows)
            let n: Int32 = numericCast(other.columns)
            let k: Int32 = numericCast(columns)
            let alpha: T = multiplied
            let lda: Int32 = k
            let beta: T = .zero
            let ldb: Int32 = n
            let ldc: Int32 = n
            cblas_dgemm(layout, transa, transb, m, n, k, alpha, elements, lda, other.elements, ldb, beta, &into.elements, ldc)
        } else {
            _dot(other, multiplied: multiplied, into: &into)
        }
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
        dot(vector, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if let cblas_dgemv = BLAS.dgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m: Int32 = numericCast(self.rows)
            let n: Int32 = numericCast(self.columns)
            let alpha: T = multiplied
            let lda: Int32 = n
            let incx: Int32 = 1
            let incy: Int32 = 1
            let beta: T = 0.0
            cblas_dgemv(layout, trans, m, n, alpha, elements, lda, vector.components, incx, beta, &into.components, incy)
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
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
    @inlinable
    static func diagonalizeSymmetric(_ A: Matrix<Double>) throws -> (eigenValues: [Double], eigenVectors: [[Double]]) {
        if let LAPACKE_dsyevd = LAPACKE.dsyevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Double] = .init(repeating: .zero, count: N)
            var _A: [Double] = Array(A.elements)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_dsyevd(LAPACK_COL_MAJOR, V, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var eigenVectors = [[Double]](repeating: .init(repeating: .zero, count: N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    eigenVectors[i][j] = _A[N * i + j]
                }
            }
            return (eigenValues, eigenVectors)
        }
        fatalError("TODO: Default implementation not implemented yet.")
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
        if let LAPACKE_dsyevd = LAPACKE.dsyevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Double] = .init(repeating: .zero, count: N)
            var _A: [Double] = Array(A.elements)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_dsyevd(LAPACK_COL_MAJOR, _N, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return eigenValues
        }
        fatalError("TODO: Default implementation not implemented yet.")
    }

    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors and right eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalize(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [[Complex<Double>]], rightEigenVectors: [[Complex<Double>]]) {
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
            let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, V, V, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, &vl, numericCast(ldvl), &vr, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
            var leftEigenVectors: [[Complex<Double>]] = [[Complex<Double>]](repeating: .init(repeating: .zero, count: N), count: N)
            var rightEigenVectors: [[Complex<Double>]] = [[Complex<Double>]](repeating: .init(repeating: .zero, count: N), count: N)
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
        fatalError("TODO: Default implementation not implemented yet")
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeLeft(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], leftEigenVectors: [[Complex<Double>]]) {
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
            let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, V, _N, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, &vl, numericCast(ldvl), nil, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
            var leftEigenVectors: [[Complex<Double>]] = [[Complex<Double>]](repeating: .init(repeating: .zero, count: N), count: N)
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
        fatalError("TODO: Default implementation not implemented yet")
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and right eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeRight(_ A: Matrix<Double>) throws -> (eigenValues: [Complex<Double>], rightEigenVectors: [[Complex<Double>]]) {
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
            let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, _N, V, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, nil, numericCast(ldvl), &vr, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
            var rightEigenVectors: [[Complex<Double>]] = [[Complex<Double>]](repeating: .init(repeating: .zero, count: N), count: N)
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
        fatalError("TODO: Default implementation not implemented yet")
    }

    /// Computes the eigenvalues of the given matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValues(_ A: Matrix<Double>) throws -> [Complex<Double>] {
        if let LAPACKE_dgeev = LAPACKE.dgeev {
            let N = A.rows
            let lda = N
            let ldvl = N
            let ldvr = N
            var _A = Array(A.elements)
            var eigenReal: [Double] = .init(repeating: .zero, count: N)
            var eigenImaginary: [Double] = .init(repeating: .zero, count: N)
            let _N = Int8(bitPattern: UInt8(ascii: "N"))
            let info = LAPACKE_dgeev(LAPACK_ROW_MAJOR, _N, _N, numericCast(N), &_A, numericCast(lda), &eigenReal, &eigenImaginary, nil, numericCast(ldvl), nil, numericCast(ldvr))
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            let eigenValues = Array(zip(eigenReal, eigenImaginary).map { Complex<Double>($0, $1) })
            return eigenValues
        }
        fatalError("TODO: Default implementation not implemented yet")
    }
    
    //TODO: Test!
    @inlinable
    static func solve(A: Matrix<Double>, b: Vector<Double>) throws -> Vector<Double> {
        if let LAPACKE_dgesv = LAPACKE.dgesv {
            let N = A.rows
            let nrhs: Int32 = 1
            let lda: Int32 = numericCast(N)
            let ldb: Int32 = 1
            var ipiv = [Int32](repeating: .zero, count: N)
            var _A = Array(A.elements)
            var _b = Array(b.components)
            let info = LAPACKE_dgesv(LAPACK_ROW_MAJOR, numericCast(N), nrhs, &_A, lda, &ipiv, &_b, ldb)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            return Vector(_b)
        }
        fatalError("TODO: Default implementation not implemented yet")
    }
}
