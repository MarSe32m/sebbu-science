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
}
