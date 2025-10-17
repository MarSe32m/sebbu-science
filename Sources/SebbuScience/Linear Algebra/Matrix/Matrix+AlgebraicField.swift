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
    
    @inlinable
    func kronecker(_ other: Self) -> Self {
        var result: Self = .zeros(rows: rows * other.rows, columns: columns * other.columns)
        kronecker(other, into: &result)
        return result
    }
    
    @inlinable
    func kronecker(_ other: Self, multiplied: T) -> Self {
        var result: Self = .zeros(rows: rows * other.rows, columns: columns * other.columns)
        kronecker(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func kronecker(_ other: Self, into: inout Self) {
        precondition(into.rows == rows * other.rows)
        precondition(into.columns == columns * other.columns)
        for r in 0..<rows {
            for v in 0..<other.rows {
                for s in 0..<columns {
                    for w in 0..<other.columns {
                        into[other.rows * r + v, other.columns * s + w] = self[r, s] * other[v, w]
                    }
                }
            }
        }
    }
    
    @inlinable
    func kronecker(_ other: Self, multiplied: T, into: inout Self) {
        precondition(into.rows == rows * other.rows)
        precondition(into.columns == columns * other.columns)
        for r in 0..<rows {
            for v in 0..<other.rows {
                for s in 0..<columns {
                    for w in 0..<other.columns {
                        into[other.rows * r + v, other.columns * s + w] = multiplied * self[r, s] * other[v, w]
                    }
                }
            }
        }
    }
    
    @inlinable
    func kronecker(_ other: Self, addingInto into: inout Self) {
        precondition(into.rows == rows * other.rows)
        precondition(into.columns == columns * other.columns)
        for r in 0..<rows {
            for v in 0..<other.rows {
                for s in 0..<columns {
                    for w in 0..<other.columns {
                        into[other.rows * r + v, other.columns * s + w] += self[r, s] * other[v, w]
                    }
                }
            }
        }
    }
    
    @inlinable
    func kronecker(_ other: Self, multiplied: T, addingInto into: inout Self) {
        precondition(into.rows == rows * other.rows)
        precondition(into.columns == columns * other.columns)
        for r in 0..<rows {
            for v in 0..<other.rows {
                for s in 0..<columns {
                    for w in 0..<other.columns {
                        into[other.rows * r + v, other.columns * s + w] += multiplied * self[r, s] * other[v, w]
                    }
                }
            }
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

public extension Matrix where T: AlgebraicField {
    /// Solves the system of equations Ax=b with the [Gauss-Seidel method](https://en.wikipedia.org/wiki/Gauss–Seidel_method)
    /// - Parameters:
    ///   - A: The matrix A in the system of equations Ax=b. Must be a square matrix with non-zero diagonals
    ///   - b: The vector b in the system of equatoins Ax=b
    ///   - result: On entry contains the intial guess. On exit it is the solution ´x´
    ///   - iterations: Number of iterations to perform
    @inlinable
    static func solveGaussSeidel(A: Self, b: Vector<T>, result: inout Vector<T>, iterations: Int) {
        precondition(A.rows == A.columns, "A must be a square matrix")
        precondition(A.rows == b.count)
        for _ in 0..<iterations {
            for i in 0..<A.columns {
                //TODO: What should we do in this case?
                if A[i, i] == .zero { continue }
                result[i] = b[i]
                for j in 0..<A.rows where j != i {
                    result[i] -= A[i, j] * result[j]
                }
                result[i] /= A[i, i]
            }
        }
    }
    
    /// Solves the system of equations Ax=b with the [Gauss-Seidel method](https://en.wikipedia.org/wiki/Gauss–Seidel_method)
    /// - Parameters:
    ///   - A: The matrix A in the system of equations Ax=b. Must be a square matrix with non-zero diagonals
    ///   - b: The vector b in the system of equatoins Ax=b
    ///   - initalGuess: Initial guess of the solution
    ///   - iterations: Number of iterations to perform
    /// - Returns: The solution x after the given iterations
    @inlinable
    static func solveGaussSeidel(A: Self, b: Vector<T>, initialGuess: Vector<T>, iterations: Int) -> Vector<T> {
        var result = initialGuess
        solveGaussSeidel(A: A, b: b, result: &result, iterations: iterations)
        return result
    }
    
    /// Solves the system of equations Ax=b with the [Jacobi method](https://en.wikipedia.org/wiki/Jacobi_method)
    /// result contains the initial guess on entry and the result on exit
    @inlinable
    static func solveJacobi(A: Self, b: Vector<T>, result: inout Vector<T>, iterations: Int) {
        precondition(A.rows == A.columns, "A must be a square matrix")
        precondition(A.rows == b.count)
        var x: Vector<T> = .zero(result.count)
        swap(&x, &result)
        for _ in 0..<iterations {
            for i in 0..<A.columns {
                //TODO: What should we do in this case?
                if A[i, i] == .zero { continue }
                var delta: T = .zero
                for j in 0..<A.rows where j != i {
                    delta += A[i, j] * x[j]
                }
                result[i] = (b[i] - delta) / A[i, i]
            }
            swap(&x, &result)
        }
        swap(&x, &result)
    }
    
    @inlinable
    static func solveJacobi(A: Self, b: Vector<T>, initialGuess: Vector<T>, iterations: Int) -> Vector<T> {
        var result = initialGuess
        solveJacobi(A: A, b: b, result: &result, iterations: iterations)
        return result
    }
}
