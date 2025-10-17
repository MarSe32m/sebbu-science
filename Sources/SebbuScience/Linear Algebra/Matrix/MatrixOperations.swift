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
    public static func partialTrace<T: AlgebraicField>(_ A: Matrix<T>, dimensions: [Int], keep: [Int]) -> Matrix<T> {
        let totalDim = dimensions.reduce(1, *)
        precondition(A.rows == totalDim)
        precondition(A.columns == totalDim)
        if keep.isEmpty { return .init(elements: [A.trace], rows: 1, columns: 1) }
        let n = dimensions.count
        let traced = (0..<n).filter { !keep.contains($0) }
        
        let keptDims = keep.map { dimensions[$0] }
        let reducedDim = keptDims.reduce(1, *)
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
}
