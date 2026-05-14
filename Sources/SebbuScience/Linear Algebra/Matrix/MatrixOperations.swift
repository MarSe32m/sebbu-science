//
//  MatrixOperations.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.10.2024.
//

import RealModule
import ComplexModule
import SebbuCollections

public enum MatrixOperations {
    public enum MatrixOperationError: Error {
        case info(Int)
    }
    
    /// Takagi factorization for a real symmetric matrix
    @inlinable
    public static func takagiSymmetric(_ A: Matrix<Double>) throws -> (absoluteValues: [Double], QP: [[Complex<Double>]]) {
        // Find the singularvalues (eigenvalues) of A and the corresponding eigenvectors
        let (singularValues, eigenVectors) = try diagonalizeSymmetric(A)
        // Construct an auxiliary matrix from the phases of the singular values
        let singularValuePhases = singularValues.map { Complex<Double>($0).phase }
        let P: Matrix<Complex<Double>> = .diagonal(from: singularValuePhases.map { Complex<Double>.exp(Complex(imaginary: -$0 / 2))})
        // Store the absolute values of the singular values
        let values = singularValues.enumerated().map { ($0.offset, abs($0.element)) }
        let complexEigenVectors = eigenVectors.map {
            $0.components.map { value in
                Complex(value)
            }
        }
        // Compute QP
        let Q: Matrix<Complex<Double>> = .from(columns: complexEigenVectors)
        let QP = Q.dot(P)
        // Sort the absolute values in decending order
        let sortedValues = values.sorted { $0.1 > $1.1 }
        // Reorder columns of QP to match the sorted singular values
        let scratchColumns = QP.extractColumns()
        var resultingColumns: [[Complex<Double>]] = []
        for (index, _) in sortedValues {
            resultingColumns.append(scratchColumns[index])
        }
        return (sortedValues.map {$0.1}, resultingColumns)
    }
    
    @inlinable
    public static func partialTrace<T: AlgebraicField>(_ A: Matrix<T>, dimensions: [Int], keep: [Int], into: inout Matrix<T>) {
        let totalDim = dimensions.reduce(1, *)
        precondition(A.rows == totalDim)
        precondition(A.columns == totalDim)
        if keep.isEmpty {
            into[0, 0] = A.trace
            return
        }
        let n = dimensions.count
        let traced = (0..<n).filter { !keep.contains($0) }
        
        let keptDims = keep.map { dimensions[$0] }
        let reducedDim = keptDims.reduce(1, *)
        precondition(reducedDim >= 1, "Can't trace a matrix with negative dimensions")
        precondition(into.rows == reducedDim)
        precondition(into.columns == reducedDim)
        
        let tracedDims = traced.map { dimensions[$0] }
        let tracedTotal = tracedDims.reduce(1, *)
        
        var rowFull = [Int](repeating: 0, count: n)
        var colFull = [Int](repeating: 0, count: n)
        
        @inline(__always)
        func unravelIndex(_ index: Int, dims: [Int]) -> [Int] {
            var result = [Int](repeating: 0, count: dims.count)
            var idx = index
            for i in (0..<dims.count).reversed() {
                result[i] = idx % dims[i]
                idx /= dims[i]
            }
            return result
        }
        
        @inline(__always)
        func ravelIndex(_ multi: [Int], dims: [Int]) -> Int {
            var flat = 0
            for i in 0..<dims.count {
                flat = flat * dims[i] + multi[i]
            }
            return flat
        }
        
        for aFlat in 0..<reducedDim {
            let aMultiKept = unravelIndex(aFlat, dims: keptDims)
            for bFlat in 0..<reducedDim {
                let bMultiKept = unravelIndex(bFlat, dims: keptDims)
                
                var sum: T = .zero
                
                // Sum over traced indices
                for t in 0..<tracedTotal {
                    let tMulti = unravelIndex(t, dims: tracedDims)
                    
                    var ki = 0
                    var ti = 0
                    for i in 0..<n {
                        if keep.contains(i) {
                            rowFull[i] = aMultiKept[ki]
                            colFull[i] = bMultiKept[ki]
                            ki += 1
                        } else {
                            rowFull[i] = tMulti[ti]
                            colFull[i] = tMulti[ti]
                            ti += 1
                        }
                    }
                    
                    let rowFlat = ravelIndex(rowFull, dims: dimensions)
                    let colFlat = ravelIndex(colFull, dims: dimensions)
                    sum += A[rowFlat, colFlat]
                }
                into[aFlat, bFlat] = sum
            }
        }
    }
    
    @inlinable
    public static func partialTrace<T: AlgebraicField>(_ A: Matrix<T>, dimensions: [Int], keep: [Int], addingInto into: inout Matrix<T>) {
        let totalDim = dimensions.reduce(1, *)
        precondition(A.rows == totalDim)
        precondition(A.columns == totalDim)
        if keep.isEmpty {
            into[0, 0] = A.trace
            return
        }
        let n = dimensions.count
        let traced = (0..<n).filter { !keep.contains($0) }
        
        let keptDims = keep.map { dimensions[$0] }
        let reducedDim = keptDims.reduce(1, *)
        precondition(reducedDim >= 1, "Can't trace a matrix with negative dimensions")
        precondition(into.rows == reducedDim)
        precondition(into.columns == reducedDim)
        
        let tracedDims = traced.map { dimensions[$0] }
        let tracedTotal = tracedDims.reduce(1, *)
        
        var rowFull = [Int](repeating: 0, count: n)
        var colFull = [Int](repeating: 0, count: n)
        
        @inline(__always)
        func unravelIndex(_ index: Int, dims: [Int]) -> [Int] {
            var result = [Int](repeating: 0, count: dims.count)
            var idx = index
            for i in (0..<dims.count).reversed() {
                result[i] = idx % dims[i]
                idx /= dims[i]
            }
            return result
        }
        
        @inline(__always)
        func ravelIndex(_ multi: [Int], dims: [Int]) -> Int {
            var flat = 0
            for i in 0..<dims.count {
                flat = flat * dims[i] + multi[i]
            }
            return flat
        }
        
        for aFlat in 0..<reducedDim {
            let aMultiKept = unravelIndex(aFlat, dims: keptDims)
            for bFlat in 0..<reducedDim {
                let bMultiKept = unravelIndex(bFlat, dims: keptDims)
                
                var sum: T = .zero
                
                // Sum over traced indices
                for t in 0..<tracedTotal {
                    let tMulti = unravelIndex(t, dims: tracedDims)
                    
                    var ki = 0
                    var ti = 0
                    for i in 0..<n {
                        if keep.contains(i) {
                            rowFull[i] = aMultiKept[ki]
                            colFull[i] = bMultiKept[ki]
                            ki += 1
                        } else {
                            rowFull[i] = tMulti[ti]
                            colFull[i] = tMulti[ti]
                            ti += 1
                        }
                    }
                    
                    let rowFlat = ravelIndex(rowFull, dims: dimensions)
                    let colFlat = ravelIndex(colFull, dims: dimensions)
                    sum += A[rowFlat, colFlat]
                }
                into[aFlat, bFlat] += sum
            }
        }
    }
    
    @inlinable
    public static func partialTrace<T: AlgebraicField>(_ A: Matrix<T>, dimensions: [Int], keep: [Int]) -> Matrix<T> {
        let totalDim = dimensions.reduce(1, *)
        precondition(A.rows == totalDim)
        precondition(A.columns == totalDim)
        if keep.isEmpty { return .init(elements: [A.trace], rows: 1, columns: 1) }
        let n = dimensions.count
        let traced = (0..<n).filter { !keep.contains($0) }
        
        let keptDims = keep.map { dimensions[$0] }
        let reducedDim = keptDims.reduce(1, *)
        precondition(reducedDim >= 1, "Can't trace a matrix with negative dimensions")
        var rhoReduced: Matrix<T> = .zeros(rows: reducedDim, columns: reducedDim)
        
        let tracedDims = traced.map { dimensions[$0] }
        let tracedTotal = tracedDims.reduce(1, *)
        
        var rowFull = [Int](repeating: 0, count: n)
        var colFull = [Int](repeating: 0, count: n)
        
        @inline(__always)
        func unravelIndex(_ index: Int, dims: [Int]) -> [Int] {
            var result = [Int](repeating: 0, count: dims.count)
            var idx = index
            for i in (0..<dims.count).reversed() {
                result[i] = idx % dims[i]
                idx /= dims[i]
            }
            return result
        }
        
        @inline(__always)
        func ravelIndex(_ multi: [Int], dims: [Int]) -> Int {
            var flat = 0
            for i in 0..<dims.count {
                flat = flat * dims[i] + multi[i]
            }
            return flat
        }
        
        for aFlat in 0..<reducedDim {
            let aMultiKept = unravelIndex(aFlat, dims: keptDims)
            for bFlat in 0..<reducedDim {
                let bMultiKept = unravelIndex(bFlat, dims: keptDims)
                
                var sum: T = .zero
                
                // Sum over traced indices
                for t in 0..<tracedTotal {
                    let tMulti = unravelIndex(t, dims: tracedDims)
                    
                    var ki = 0
                    var ti = 0
                    for i in 0..<n {
                        if keep.contains(i) {
                            rowFull[i] = aMultiKept[ki]
                            colFull[i] = bMultiKept[ki]
                            ki += 1
                        } else {
                            rowFull[i] = tMulti[ti]
                            colFull[i] = tMulti[ti]
                            ti += 1
                        }
                    }
                    
                    let rowFlat = ravelIndex(rowFull, dims: dimensions)
                    let colFlat = ravelIndex(colFull, dims: dimensions)
                    sum += A[rowFlat, colFlat]
                }
                rhoReduced[aFlat, bFlat] = sum
            }
        }
        return rhoReduced
    }
    
    public static func printMatrix(_ matrix: Matrix<Complex<Double>>, format: String = "%.3f") {
        for i in 0..<matrix.rows {
            for j in 0..<matrix.columns {
                print("( ", String(format: format, matrix[i,j].real), ", ", String(format: format, matrix[i, j].imaginary), " )", separator: "", terminator: " ")
            }
            print()
        }
    }
    
    public static func printMatrix(_ matrix: Matrix<Complex<Float>>, format: String = "%.3f") {
        for i in 0..<matrix.rows {
            for j in 0..<matrix.columns {
                print("( ", String(format: format, matrix[i,j].real), ", ", String(format: format, matrix[i, j].imaginary), " )", separator: "", terminator: " ")
            }
            print()
        }
    }
    
    public static func printMatrix(_ matrix: Matrix<Double>, format: String = "%.3f") {
        for i in 0..<matrix.rows {
            for j in 0..<matrix.columns {
                print(String(format: format, matrix[i,j]), separator: "", terminator: " ")
            }
            print()
        }
    }
    
    public static func printMatrix(_ matrix: Matrix<Float>, format: String = "%.3f") {
        for i in 0..<matrix.rows {
            for j in 0..<matrix.columns {
                print(String(format: format, matrix[i,j]), separator: "", terminator: " ")
            }
            print()
        }
    }
}

public extension MatrixOperations {
    enum MatrixExponentialError: Error {
        case nonSquareMatrix
        case info(Int)
    }
    
    /// Computes the matrix exponential `exp(A)` in single precision.
    ///
    /// This uses the same scaling-and-squaring Padé `[13/13]` algorithm as the
    /// double-precision implementation, but all matrix operations are performed
    /// in `Float`. The scaling exponent is selected from a `Double`-accumulated
    /// 1-norm for improved robustness.
    ///
    /// - Important: Single-precision results should be expected to have
    ///              significantly lower accuracy than the `Double` implementation,
    ///              especially for non-normal or ill-conditioned matrices.
    ///
    /// - Parameter A: A square dense matrix.
    /// - Returns: The matrix exponential `exp(A)`.
    /// - Throws: `MatrixExponentialError.nonSquareMatrix` if `A` is not square.
    ///          May also throw if the internal linear solve fails.
    ///
    /// - Complexity: `O(n^3)` for an `n × n` dense matrix.
    /// - Note: The Padé step solves `(V - U) R = V + U` using LAPACK rather than
    ///         explicitly forming an inverse.
    ///
    /// - References:
    ///   N. J. Higham, "The Scaling and Squaring Method for the Matrix
    ///   Exponential Revisited", SIAM J. Matrix Anal. Appl. 26(4), 1179–1193,
    ///   2005. DOI: 10.1137/04061101X.
    @inlinable
    static func expm(_ A: Matrix<Float>) throws -> Matrix<Float> {
        guard A.isSquare else { throw MatrixExponentialError.nonSquareMatrix }
        if A.isDiagonal {
            return .diagonal(from: (0..<A.rows).map { i in .exp(A[i, i]) })
        } else if A.isSymmetric {
            return try expmSymmetric(A)
        }
        let I: Matrix<Float> = .identity(rows: A.rows)
        let normA = A.oneNormAsDouble
        if normA == .zero { return I }
        let s: Int = scalingExponent(normA)

        let scale = Float(sign: .plus, exponent: -s, significand: 1.0)
        let As = scale * A

        let b: [_ of Float] = [
            64764752532480000.0,
            32382376266240000.0,
            7771770303897600.0,
            1187353796428800.0,
            129060195264000.0,
            10559470521600.0,
            670442572800.0,
            33522128640.0,
            1323241920.0,
            40840800.0,
            960960.0,
            16380.0,
            182.0,
            1.0
        ]

        var scratch = I

        let A2 = As.dot(As)
        let A4 = A2.dot(A2)
        let A6 = A2.dot(A4)

        var innerU = b[13] * A6
        innerU.add(A4, multiplied: b[11])
        innerU.add(A2, multiplied: b[9])

        A6.dot(innerU, into: &scratch)
        scratch.add(A6, multiplied: b[7])
        scratch.add(A4, multiplied: b[5])
        scratch.add(A2, multiplied: b[3])
        scratch.add(I, multiplied: b[1])

        let U = As.dot(scratch)

        var innerV = b[12] * A6
        innerV.add(A4, multiplied: b[10])
        innerV.add(A2, multiplied: b[8])

        var V = A6.dot(innerV)
        V.add(A6, multiplied: b[6])
        V.add(A4, multiplied: b[4])
        V.add(A2, multiplied: b[2])
        V.add(I, multiplied: b[0])

        let P = V + U
        let Q = V - U

        var R = try MatrixOperations.solve(A: Q, B: P)

        for _ in 0..<s {
            R = R.dot(R)
        }

        return R
    }
    
    @inlinable
    static func expmSymmetric(_ A: Matrix<Float>) throws -> Matrix<Float> {
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeSymmetric(A)
        let U: Matrix<Float> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let ew = Float.exp(eigenValues[j])
            for i in 0..<R.rows {
                R[i, j] *= ew
            }
        }
        return R.dot(U.transpose)
    }
    
    /// Computes the matrix exponential `exp(A)`.
    ///
    /// This implementation uses the scaling-and-squaring method with the
    /// fixed `[13/13]` Padé approximant. The input matrix is first scaled as
    /// `A / 2^s`, where `s` is chosen from the matrix 1-norm, then the Padé
    /// approximant is evaluated, and the result is squared `s` times.
    ///
    /// For diagonal matrices, the exponential is computed elementwise.
    ///
    /// - Parameter A: A square dense matrix.
    /// - Returns: The matrix exponential `exp(A)`.
    /// - Throws: `MatrixExponentialError.nonSquareMatrix` if `A` is not square.
    ///          May also throw if the internal linear solve fails.
    ///
    /// - Complexity: `O(n^3)` for an `n × n` dense matrix.
    /// - Note: The Padé step solves `(V - U) R = V + U` using LAPACK rather than
    ///         explicitly forming an inverse.
    ///
    /// - References:
    ///   N. J. Higham, "The Scaling and Squaring Method for the Matrix
    ///   Exponential Revisited", SIAM J. Matrix Anal. Appl. 26(4), 1179–1193,
    ///   2005. DOI: 10.1137/04061101X.
    @inlinable
    static func expm(_ A: Matrix<Double>) throws -> Matrix<Double> {
        guard A.isSquare else { throw MatrixExponentialError.nonSquareMatrix }
        if A.isDiagonal {
            return .diagonal(from: (0..<A.rows).map { i in .exp(A[i, i]) })
        } else if A.isSymmetric {
            return try expmSymmetric(A)
        }
        let I: Matrix<Double> = .identity(rows: A.rows)
        let normA = A.oneNorm
        if normA == .zero { return I }
        let s: Int = scalingExponent(normA)

        let scale = Double(sign: .plus, exponent: -s, significand: 1.0)
        let As = scale * A

        let b: [_ of Double] = [
            64764752532480000.0,
            32382376266240000.0,
            7771770303897600.0,
            1187353796428800.0,
            129060195264000.0,
            10559470521600.0,
            670442572800.0,
            33522128640.0,
            1323241920.0,
            40840800.0,
            960960.0,
            16380.0,
            182.0,
            1.0
        ]

        var scratch = I

        let A2 = As.dot(As)
        let A4 = A2.dot(A2)
        let A6 = A2.dot(A4)

        var innerU = b[13] * A6
        innerU.add(A4, multiplied: b[11])
        innerU.add(A2, multiplied: b[9])

        A6.dot(innerU, into: &scratch)
        scratch.add(A6, multiplied: b[7])
        scratch.add(A4, multiplied: b[5])
        scratch.add(A2, multiplied: b[3])
        scratch.add(I, multiplied: b[1])

        let U = As.dot(scratch)

        var innerV = b[12] * A6
        innerV.add(A4, multiplied: b[10])
        innerV.add(A2, multiplied: b[8])

        var V = A6.dot(innerV)
        V.add(A6, multiplied: b[6])
        V.add(A4, multiplied: b[4])
        V.add(A2, multiplied: b[2])
        V.add(I, multiplied: b[0])

        let P = V + U
        let Q = V - U

        var R = try MatrixOperations.solve(A: Q, B: P)

        for _ in 0..<s {
            R = R.dot(R)
        }

        return R
    }
    
    @inlinable
    static func expmSymmetric(_ A: Matrix<Double>) throws -> Matrix<Double> {
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeSymmetric(A)
        let U: Matrix<Double> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let ew = Double.exp(eigenValues[j])
            for i in 0..<R.rows {
                R[i, j] *= ew
            }
        }
        return R.dot(U.transpose)
    }
    
    /// Computes the matrix exponential `exp(A)` in single precision.
    ///
    /// This uses the same scaling-and-squaring Padé `[13/13]` algorithm as the
    /// double-precision implementation, but all matrix operations are performed
    /// in `Float`. The scaling exponent is selected from a `Double`-accumulated
    /// 1-norm for improved robustness.
    ///
    /// - Important: Single-precision results should be expected to have
    ///              significantly lower accuracy than the `Double` implementation,
    ///              especially for non-normal or ill-conditioned matrices.
    ///
    /// - Parameter A: A square dense matrix.
    /// - Returns: The matrix exponential `exp(A)`.
    /// - Throws: `MatrixExponentialError.nonSquareMatrix` if `A` is not square.
    ///          May also throw if the internal linear solve fails.
    ///
    /// - Complexity: `O(n^3)` for an `n × n` dense matrix.
    /// - Note: The Padé step solves `(V - U) R = V + U` using LAPACK rather than
    ///         explicitly forming an inverse.
    ///
    /// - References:
    ///   N. J. Higham, "The Scaling and Squaring Method for the Matrix
    ///   Exponential Revisited", SIAM J. Matrix Anal. Appl. 26(4), 1179–1193,
    ///   2005. DOI: 10.1137/04061101X.
    @inlinable
    static func expm(_ A: Matrix<Complex<Float>>) throws -> Matrix<Complex<Float>> {
        guard A.isSquare else { throw MatrixExponentialError.nonSquareMatrix }
        if A.isDiagonal {
            return .diagonal(from: (0..<A.rows).map { i in .exp(A[i, i]) })
        } else if A.isHermitian {
            return try expmHermitian(A)
        } else if A.isAntiHermitian {
            return try expmAntiHermitian(A)
        }
        let I: Matrix<Complex<Float>> = .identity(rows: A.rows)
        let normA = A.oneNormAsDouble
        if normA == .zero { return I }
        let s: Int = scalingExponent(normA)

        let scale = Float(sign: .plus, exponent: -s, significand: 1.0)
        let As = scale * A

        let b: [Float] = [
            64764752532480000.0,
            32382376266240000.0,
            7771770303897600.0,
            1187353796428800.0,
            129060195264000.0,
            10559470521600.0,
            670442572800.0,
            33522128640.0,
            1323241920.0,
            40840800.0,
            960960.0,
            16380.0,
            182.0,
            1.0
        ]

        var scratch = I

        let A2 = As.dot(As)
        let A4 = A2.dot(A2)
        let A6 = A2.dot(A4)   // Important: A^6, not A^8

        var innerU = b[13] * A6
        innerU.add(A4, multiplied: b[11])
        innerU.add(A2, multiplied: b[9])

        A6.dot(innerU, into: &scratch)
        scratch.add(A6, multiplied: b[7])
        scratch.add(A4, multiplied: b[5])
        scratch.add(A2, multiplied: b[3])
        scratch.add(I, multiplied: b[1])

        let U = As.dot(scratch)

        var innerV = b[12] * A6
        innerV.add(A4, multiplied: b[10])
        innerV.add(A2, multiplied: b[8])

        var V = A6.dot(innerV)
        V.add(A6, multiplied: b[6])
        V.add(A4, multiplied: b[4])
        V.add(A2, multiplied: b[2])
        V.add(I, multiplied: b[0])

        let P = V + U
        let Q = V - U

        var R = try MatrixOperations.solve(A: Q, B: P)

        for _ in 0..<s {
            R = R.dot(R)
        }

        return R
    }
    
    @inlinable
    static func expmHermitian(_ A: Matrix<Complex<Float>>) throws -> Matrix<Complex<Float>> {
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(A)
        let U: Matrix<Complex<Float>> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let ew = Float.exp(eigenValues[j])
            for i in 0..<R.rows {
                R[i, j] *= ew
            }
        }
        return R.dot(U.conjugateTranspose)
    }
    
    @inlinable
    static func expmAntiHermitian(_ A: Matrix<Complex<Float>>) throws -> Matrix<Complex<Float>> {
        let H = .i * A
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(H)
        let U: Matrix<Complex<Float>> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let theta = eigenValues[j]
            let phase = Complex<Float>(length: 1.0, phase: -theta)
            for i in 0..<R.rows {
                R[i, j] *= phase
            }
        }
        return R.dot(U.conjugateTranspose)
    }
    
    @inlinable
    static func expmIHt(_ H: Matrix<Complex<Float>>, t: Float) throws -> Matrix<Complex<Float>> {
        guard H.isSquare else { throw MatrixExponentialError.nonSquareMatrix }
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(H)
        let U: Matrix<Complex<Float>> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let theta = eigenValues[j] * t
            let phase = Complex<Float>(length: 1.0, phase: -theta)
            for i in 0..<R.rows {
                R[i, j] *= phase
            }
        }
        return R.dot(U.conjugateTranspose)
    }
    
    /// Computes the matrix exponential `exp(A)`.
    ///
    /// This implementation uses the scaling-and-squaring method with the
    /// fixed `[13/13]` Padé approximant. The input matrix is first scaled as
    /// `A / 2^s`, where `s` is chosen from the matrix 1-norm, then the Padé
    /// approximant is evaluated, and the result is squared `s` times.
    ///
    /// For diagonal matrices, the exponential is computed elementwise.
    ///
    /// - Parameter A: A square dense matrix.
    /// - Returns: The matrix exponential `exp(A)`.
    /// - Throws: `MatrixExponentialError.nonSquareMatrix` if `A` is not square.
    ///          May also throw if the internal linear solve fails.
    ///
    /// - Complexity: `O(n^3)` for an `n × n` dense matrix.
    /// - Note: The Padé step solves `(V - U) R = V + U` using LAPACK rather than
    ///         explicitly forming an inverse.
    ///
    /// - References:
    ///   N. J. Higham, "The Scaling and Squaring Method for the Matrix
    ///   Exponential Revisited", SIAM J. Matrix Anal. Appl. 26(4), 1179–1193,
    ///   2005. DOI: 10.1137/04061101X.
    @inlinable
    static func expm(_ A: Matrix<Complex<Double>>) throws -> Matrix<Complex<Double>> {
        guard A.isSquare else { throw MatrixExponentialError.nonSquareMatrix }
        if A.isDiagonal {
            return .diagonal(from: (0..<A.rows).map { i in .exp(A[i, i]) })
        } else if A.isHermitian {
            return try expmHermitian(A)
        } else if A.isAntiHermitian {
            return try expmAntiHermitian(A)
        }
        let I: Matrix<Complex<Double>> = .identity(rows: A.rows)
        let normA = A.oneNorm
        if normA == .zero { return I }
        let s: Int = scalingExponent(normA)

        let scale = Double(sign: .plus, exponent: -s, significand: 1.0)
        let As = scale * A

        let b: [Double] = [
            64764752532480000.0,
            32382376266240000.0,
            7771770303897600.0,
            1187353796428800.0,
            129060195264000.0,
            10559470521600.0,
            670442572800.0,
            33522128640.0,
            1323241920.0,
            40840800.0,
            960960.0,
            16380.0,
            182.0,
            1.0
        ]

        var scratch = I

        let A2 = As.dot(As)
        let A4 = A2.dot(A2)
        let A6 = A2.dot(A4)   // Important: A^6, not A^8

        var innerU = b[13] * A6
        innerU.add(A4, multiplied: b[11])
        innerU.add(A2, multiplied: b[9])

        A6.dot(innerU, into: &scratch)
        scratch.add(A6, multiplied: b[7])
        scratch.add(A4, multiplied: b[5])
        scratch.add(A2, multiplied: b[3])
        scratch.add(I, multiplied: b[1])

        let U = As.dot(scratch)

        var innerV = b[12] * A6
        innerV.add(A4, multiplied: b[10])
        innerV.add(A2, multiplied: b[8])

        var V = A6.dot(innerV)
        V.add(A6, multiplied: b[6])
        V.add(A4, multiplied: b[4])
        V.add(A2, multiplied: b[2])
        V.add(I, multiplied: b[0])

        let P = V + U
        let Q = V - U

        var R = try MatrixOperations.solve(A: Q, B: P)

        for _ in 0..<s {
            R = R.dot(R)
        }

        return R
    }
    
    @inlinable
    static func expmHermitian(_ A: Matrix<Complex<Double>>) throws -> Matrix<Complex<Double>> {
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(A)
        let U: Matrix<Complex<Double>> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let ew = Double.exp(eigenValues[j])
            for i in 0..<R.rows {
                R[i, j] *= ew
            }
        }
        return R.dot(U.conjugateTranspose)
    }
    
    @inlinable
    static func expmAntiHermitian(_ A: Matrix<Complex<Double>>) throws -> Matrix<Complex<Double>> {
        let H = .i * A
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(H)
        let U: Matrix<Complex<Double>> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let theta = eigenValues[j]
            let phase = Complex<Double>(length: 1.0, phase: -theta)
            for i in 0..<R.rows {
                R[i, j] *= phase
            }
        }
        return R.dot(U.conjugateTranspose)
    }
    
    @inlinable
    static func expmIHt(_ H: Matrix<Complex<Double>>, t: Double) throws -> Matrix<Complex<Double>> {
        guard H.isSquare else { throw MatrixExponentialError.nonSquareMatrix }
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(H)
        let U: Matrix<Complex<Double>> = .from(columns: eigenVectors.map { $0.components })
        var R = U
        for j in 0..<R.rows {
            let theta = eigenValues[j] * t
            let phase = Complex<Double>(length: 1.0, phase: -theta)
            for i in 0..<R.rows {
                R[i, j] *= phase
            }
        }
        return R.dot(U.conjugateTranspose)
    }
    
    @inline(always)
    @inlinable
    internal static func scalingExponent(_ norm: Double) -> Int {
        let theta13 = 5.371920351148152

        guard norm > theta13 else {
            return 0
        }

        var scaledNorm = norm
        var s = 0

        while scaledNorm > theta13 {
            scaledNorm *= 0.5
            s += 1
        }

        return s
    }
}
