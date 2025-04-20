//
//  Matrix+ComplexFloat.swift
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

public extension Matrix<Complex<Float>> {
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
        if let cblas_caxpy = BLAS.caxpy {
            precondition(self.rows == other.rows)
            precondition(self.columns == other.columns)
            var alpha: T = scaling
            let N: Int32 = numericCast(elements.count)
            cblas_caxpy(N, &alpha, other.elements, 1, &elements, 1)
        } else {
            _add(other, scaling: scaling)
        }
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, scaling: Complex(1.0))
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
        subtract(other, scaling: Complex(1.0))
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
    mutating func multiply(by: T) {
        if let cblas_cscal = BLAS.cscal {
            let N: Int32 = numericCast(elements.count)
            var alpha = by
            cblas_cscal(N, &alpha, &elements, 1)
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
public extension Matrix<Complex<Float>> {
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
        dot(other, multiplied: .one, into: &into)
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
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
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
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
    }
}

public extension Matrix<Complex<Float>> {
    //MARK: Addition
    @inline(__always)
    @inlinable
    @_transparent
    mutating func add(_ other: Self, scaling: Float) {
        add(other, scaling: Complex(scaling))
    }
    
    //MARK: Subtraction
    @inline(__always)
    @inlinable
    @_transparent
    mutating func subtract(_ other: Self, scaling: Float) {
        add(other, scaling: Complex(-scaling))
    }
    
    //MARK: Scaling
    @inline(__always)
    @inlinable
    static func *(lhs: Float, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inline(__always)
    @inlinable
    mutating func multiply(by: Float) {
        if let cblas_csscal = BLAS.csscal {
            cblas_csscal(numericCast(elements.count), by, &elements, 1)
        } else {
            multiply(by: Complex(by))
        }
    }
    
    //MARK: Division
    @inline(__always)
    @inlinable
    static func /(lhs: Self, rhs: Float) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inline(__always)
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: Float) {
        lhs.divide(by: rhs)
    }
    
    @inline(__always)
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

public extension MatrixOperations {
    /// Diagonalizes the given hermitian matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: Symmteric matrix with a column-major layout. Only the lower triangular needs to be filled in.
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeHermitian(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Float], eigenVectors: [[Complex<Float>]]) {
        if  let LAPACKE_cheevd = LAPACKE.cheevd {
            let N = A.rows
            let lda = N
            var eigenValues: [Float] = .init(repeating: .zero, count: N)
            var _A: [Complex<Float>] = Array(A.elements)
            let V = Int8(bitPattern: UInt8(ascii: "V"))
            let U = Int8(bitPattern: UInt8(ascii: "U"))
            let info = LAPACKE_cheevd(LAPACK_COL_MAJOR, V, U, numericCast(N), &_A, numericCast(lda), &eigenValues)
            if info != 0 { throw MatrixOperationError.info(Int(info)) }
            var eigenVectors = [[Complex<Float>]](repeating: .init(repeating: .zero, count: N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    eigenVectors[i][j] = _A[N * i + j]
                }
            }
            return (eigenValues, eigenVectors)
        }
        fatalError("TODO: Default implementation not yet implemented")
    }

    /// Computes the eigenvalues of the given hermitian matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValuesHermitian(_ A: Matrix<Complex<Float>>) throws -> [Float] {
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
    }

    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors and right eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalize(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [[Complex<Float>]], rightEigenVectors: [[Complex<Float>]]) {
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
            var leftEigenVectors: [[Complex<Float>]] = [[Complex<Float>]](repeating: .init(repeating: .zero, count: N), count: N)
            var rightEigenVectors: [[Complex<Float>]] = [[Complex<Float>]](repeating: .init(repeating: .zero, count: N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    leftEigenVectors[j][i] = vl[N * i + j]
                    rightEigenVectors[j][i] = vr[N * i + j]
                }
            }
            return (eigenValues, leftEigenVectors, rightEigenVectors)
        }
        fatalError("TODO: Default implementation not yet implemented")
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and left eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeLeft(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], leftEigenVectors: [[Complex<Float>]]) {
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
            var leftEigenVectors: [[Complex<Float>]] = [[Complex<Float>]](repeating: .init(repeating: .zero, count: N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    leftEigenVectors[j][i] = vl[N * i + j]
                }
            }
            return (eigenValues, leftEigenVectors)
        }
        fatalError("TODO: Default implementation not yet implemented")
    }
    
    /// Diagonalizes the given matrix, i.e., computes it's eigenvalues and eigenvectors.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code if the diagonalization fails.
    /// - Returns: A tuple containing the eigenvalues and right eigenvectors
    //TODO: TESTS!
    @inlinable
    static func diagonalizeRight(_ A: Matrix<Complex<Float>>) throws -> (eigenValues: [Complex<Float>], rightEigenVectors: [[Complex<Float>]]) {
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
            var rightEigenVectors: [[Complex<Float>]] = [[Complex<Float>]](repeating: .init(repeating: .zero, count: N), count: N)
            for i in 0..<N {
                for j in 0..<N {
                    rightEigenVectors[j][i] = vr[N * i + j]
                }
            }
            return (eigenValues, rightEigenVectors)
        }
        fatalError("TODO: Default implementation not yet implemented")
    }

    /// Computes the eigenvalues of the given symmetric matrix.
    /// - Parameters:
    ///   - A: The matrix for which to compute the eigenvalues
    ///   - rows: Number of rows in the matrix.
    /// - Throws: ```MatrixOperationError``` with the LAPACK error code
    /// - Returns: An array containing the eigenvalues
    //TODO: TESTS!
    @inlinable
    static func eigenValues(_ A: Matrix<Complex<Float>>) throws -> [Complex<Float>] {
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
    }
    
    //TODO: TEST!
    @inlinable
    static func solve(A: Matrix<Complex<Float>>, b: Vector<Complex<Float>>) throws -> Vector<Complex<Float>> {
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
    }
}