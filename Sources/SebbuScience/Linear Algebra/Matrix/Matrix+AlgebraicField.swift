//
//  Matrix+AlgebraicField.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//
import RealModule
import ComplexModule
import SebbuCollections

public extension Matrix where T: AlgebraicField {
    /// The inverse of the matrix, if invertible.
    /// - Note: This operation is very expensive and will be calculated each time this variable is accessed.
    /// Thus you should store the inverse if you need it later again.
    var inverse: Self? { fatalError("TODO: Not yet implemented") }
    
    @inlinable
    var trace: T {
        var result: T = .zero
        let bound = min(rows, columns)
        for i in 0..<bound {
            result = Relaxed.sum(result, self[i, i])
        }
        return result
    }
    
    @inlinable
    static func diagonal(from: [T]) -> Self {
        let N = from.count
        var elements = [T](repeating: .zero, count: N*N)
        for i in 0..<N { elements[i * N + i] = from[i] }
        return Matrix(elements: elements, rows: N, columns: N)
    }
    
    @inlinable
    static func identity(rows: Int) -> Self {
        let N = rows
        var elements = [T](repeating: .zero, count: N*N)
        for i in 0..<N { elements[i * N + i] = T(exactly: 1)! }
        return Matrix(elements: elements, rows: N, columns: N)
    }
    
    @inlinable
    static func zeros(rows: Int, columns: Int) -> Self {
        Matrix(elements: .init(repeating: .zero, count: rows * columns), rows: rows, columns: columns)
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

public extension Matrix where T: Real {
    @inlinable
    var conjugateTranspose: Self {
        transpose
    }
    
    @inlinable
    var frobeniusNorm: T {
        var result: T = .zero
        for element in self.elements {
            result += element * element
        }
        return result.squareRoot()
    }
}

public extension Matrix<Complex<Double>> {
    @inlinable
    var conjugateTranspose: Self {
        var newElements = [T](repeating: .zero, count: elements.count)
        let newRows = self.columns
        let newColumns = self.rows
        for i in 0..<rows {
            for j in 0..<columns {
                newElements[rows * j + i] = elements[columns * i + j].conjugate
            }
        }
        return Matrix(elements: newElements, rows: newRows, columns: newColumns)
    }
    
    @inlinable
    var frobeniusNorm: Double {
        var norm: Double = .zero
        for element in elements {
            norm += element.lengthSquared
        }
        return norm.squareRoot()
    }
}

public extension Matrix<Complex<Float>> {
    @inlinable
    var conjugateTranspose: Self {
        var newElements = [T](repeating: .zero, count: elements.count)
        let newRows = self.columns
        let newColumns = self.rows
        for i in 0..<rows {
            for j in 0..<columns {
                newElements[rows * j + i] = elements[columns * i + j].conjugate
            }
        }
        return Matrix(elements: newElements, rows: newRows, columns: newColumns)
    }
    
    @inlinable
    var frobeniusNorm: Float {
        var norm: Float = .zero
        for element in elements {
            norm += element.lengthSquared
        }
        return norm.squareRoot()
    }
}

public extension Matrix where T: AlgebraicField, T.Magnitude: FloatingPoint {
    @inlinable @inline(__always)
    func isApproximatelyEqual( to other: Self, absoluteTolerance: T.Magnitude, relativeTolerance: T.Magnitude = 0) -> Bool {
        if rows != other.rows || columns != other.columns { return false }
        for i in 0..<elements.count {
            if !elements[i].isApproximatelyEqual(to: other.elements[i], absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance, norm: \.magnitude) { return false }
        }
        return true
    }
}
