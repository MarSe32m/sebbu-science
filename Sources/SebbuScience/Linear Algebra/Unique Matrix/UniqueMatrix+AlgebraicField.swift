//
//  UniqueMatrix+AlgebraicField.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 22.5.2026.
//
import RealModule
import ComplexModule
import SebbuCollections

public extension UniqueMatrix where T: AlgebraicField {
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
    init(copying: borrowing Self, multiplied: T) {
        let newElements = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newElements._unsafeCopy(from: copying.elements, multiplied: multiplied, count: copying.count)
        self.init(_unsafeElements: newElements, rows: copying.rows, columns: copying.columns)
    }
    
    @inlinable
    static func diagonal(from: [T]) -> Self {
        let N = from.count
        var elements = [T](repeating: .zero, count: N*N)
        for i in 0..<N { elements[i * N + i] = from[i] }
        return UniqueMatrix(elements: elements, rows: N, columns: N)
    }
    
    @inlinable
    static func identity(rows: Int) -> Self {
        let N = rows
        var elements = [T](repeating: .zero, count: N*N)
        for i in 0..<N { elements[i * N + i] = T(exactly: 1)! }
        return UniqueMatrix(elements: elements, rows: N, columns: N)
    }
    
    @inlinable
    static func zeros(rows: Int, columns: Int) -> Self {
        UniqueMatrix(rows: rows, columns: columns) { buffer in
            for i in buffer.indices { buffer[i] = .zero }
        }
    }
    
    @inlinable
    @_transparent
    mutating func zeroElements() {
        elements._unsafeZeroElements(count: count)
    }
    
    @inlinable
    mutating func copyElements(from other: borrowing Self, adding: borrowing Self, multiplied: T) {
        precondition(count == other.count && count == adding.count, "The matrices must have the same size.")
        elements._unsafeCopy(from: other.elements, adding: adding.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func copyElements(from other: borrowing Self, multiplied: T) {
        precondition(count == other.count, "The matrices must have the same size")
        elements._unsafeCopy(from: other.elements, multiplied: multiplied, count: count)
    }
    
    @inlinable
    func kronecker(_ other: borrowing Self) -> Self {
        var result: Self = .zeros(rows: rows * other.rows, columns: columns * other.columns)
        kronecker(other, into: &result)
        return result
    }
    
    @inlinable
    func kronecker(_ other: borrowing Self, multiplied: T) -> Self {
        var result: Self = .zeros(rows: rows * other.rows, columns: columns * other.columns)
        kronecker(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func kronecker(_ other: borrowing Self, into: inout Self) {
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
    func kronecker(_ other: borrowing Self, multiplied: T, into: inout Self) {
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
    func kronecker(_ other: borrowing Self, addingInto into: inout Self) {
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
    func kronecker(_ other: borrowing Self, multiplied: T, addingInto into: inout Self) {
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

public extension UniqueMatrix where T: Real {
    @inlinable
    var conjugateTranspose: Self {
        transpose
    }
    
    @inlinable
    var conjugate: Self {
        _read { yield self }
    }
    
    @inlinable
    var frobeniusNorm: T {
        var result: T = .zero
        for i in 0..<count {
            result = Relaxed.multiplyAdd(elements[i], elements[i], result)
        }
        return result.squareRoot()
    }
    
    @inlinable
    var L1Norm: T {
        var result: T = .zero
        for i in 0..<count {
            result = Relaxed.sum(result, elements[i].magnitude)
        }
        return result
    }
    
    @inlinable
    var oneNorm: T {
        var maxColumnSum: T = .zero
        for j in 0..<columns {
            var columnSum: T = .zero
            for i in 0..<rows {
                columnSum += self[i, j].magnitude
            }
            maxColumnSum = Swift.max(maxColumnSum, columnSum)
        }
        return maxColumnSum
    }
    
    @inlinable
    func frobeniusDistanceSquared(to other: borrowing Self) -> T {
        assert(rows == other.rows && columns == other.columns, "The matrices must have the same dimensions")
        var result: T = .zero
        for i in 0..<count {
            let diff = Relaxed.sum(elements[i], -other.elements[i])
            result = Relaxed.sum(Relaxed.product(diff, diff), result)
        }
        return result
    }
    
    @inlinable
    func frobeniusDistance(to other: borrowing Self) -> T {
        frobeniusDistanceSquared(to: other).squareRoot()
    }
}

public extension UniqueMatrix where T == Float {
    @inlinable
    var L1NormAsDouble: Double {
        var result: Double = .zero
        for i in 0..<count {
            result = Relaxed.sum(result, Double(elements[i].magnitude))
        }
        return result
    }
    
    @inlinable
    var oneNormAsDouble: Double {
        var maxColumnSum: Double = .zero
        for j in 0..<columns {
            var columnSum: Double = .zero
            for i in 0..<rows {
                columnSum += Double(self[i, j].magnitude)
            }
            maxColumnSum = Swift.max(maxColumnSum, columnSum)
        }
        return maxColumnSum
    }
    
    @inlinable
    func frobeniusDistanceSquaredAsDouble(to other: borrowing Self) -> Double {
        Double(frobeniusDistanceSquared(to: other))
    }
    
    @inlinable
    func frobeniusDistanceAsDouble(to other: borrowing Self) -> Double {
        Double(frobeniusDistance(to: other))
    }
}

public extension UniqueMatrix<Complex<Double>> {
    @inlinable
    var conjugateTranspose: Self {
        var newElements: UnsafeMutablePointer<T> = .allocate(capacity: count)
        let newRows = self.columns
        let newColumns = self.rows
        for i in 0..<rows {
            for j in 0..<columns {
                newElements[rows &* j &+ i] = elements[columns &* i &+ j].conjugate
            }
        }
        return UniqueMatrix(_unsafeElements: newElements, rows: newRows, columns: newColumns)
    }
    
    @inlinable
    var conjugate: Self {
        let newElements: UnsafeMutablePointer<T> = .allocate(capacity: count)
        for i in 0..<count {
            newElements[i] = elements[i].conjugate
        }
        return .init(_unsafeElements: newElements, rows: rows, columns: columns)
    }
    
    @inlinable
    var frobeniusNorm: Double {
        var norm: Double = .zero
        for i in 0..<count {
            norm += elements[i].lengthSquared
        }
        return norm.squareRoot()
    }
    
    @inlinable
    var L1Norm: Double {
        var result: Double = .zero
        for i in 0..<count {
            result = Relaxed.sum(result, elements[i].length)
        }
        return result
    }
    
    @inlinable
    var oneNorm: Double {
        var maxColumnSum: Double = .zero
        for j in 0..<columns {
            var columnSum: Double = .zero
            for i in 0..<rows {
                columnSum += self[i, j].length
            }
            maxColumnSum = Swift.max(maxColumnSum, columnSum)
        }
        return maxColumnSum
    }
    
    @inlinable
    init(copying: borrowing Self, multiplied: Double) {
        let newElements = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newElements._unsafeCopy(from: copying.elements, multiplied: multiplied, count: copying.count)
        self.init(_unsafeElements: newElements, rows: copying.rows, columns: copying.columns)
    }
    
    @inlinable
    func frobeniusDistanceSquared(to other: borrowing Self) -> Double {
        assert(rows == other.rows && columns == other.columns, "The matrices must have the same dimensions")
        var result: Double = .zero
        for i in 0..<span.count {
            let diff = Relaxed.sum(elements[i], -other.elements[i])
            result = Relaxed.sum(diff.lengthSquared, result)
        }
        return result
    }
    
    @inlinable
    func frobeniusDistance(to other: borrowing Self) -> Double {
        frobeniusDistanceSquared(to: other).squareRoot()
    }
}

public extension UniqueMatrix<Complex<Float>> {
    @inlinable
    var conjugateTranspose: Self {
        var newElements: UnsafeMutablePointer<T> = .allocate(capacity: count)
        let newRows = self.columns
        let newColumns = self.rows
        for i in 0..<rows {
            for j in 0..<columns {
                newElements[rows &* j &+ i] = elements[columns &* i &+ j].conjugate
            }
        }
        return UniqueMatrix(_unsafeElements: newElements, rows: newRows, columns: newColumns)
    }
    
    @inlinable
    var conjugate: Self {
        let newElements: UnsafeMutablePointer<T> = .allocate(capacity: count)
        for i in 0..<count {
            newElements[i] = elements[i].conjugate
        }
        return .init(_unsafeElements: newElements, rows: rows, columns: columns)
    }
    
    @inlinable
    var frobeniusNorm: Float {
        var norm: Float = .zero
        for i in 0..<count {
            norm += elements[i].lengthSquared
        }
        return norm.squareRoot()
    }
    
    @inlinable
    var L1Norm: Float {
        var result: Float = .zero
        for i in 0..<count {
            result = Relaxed.sum(result, elements[i].length)
        }
        return result
    }
    
    @inlinable
    var oneNorm: Float {
        var maxColumnSum: Float = .zero
        for j in 0..<columns {
            var columnSum: Float = .zero
            for i in 0..<rows {
                columnSum += self[i, j].length
            }
            maxColumnSum = Swift.max(maxColumnSum, columnSum)
        }
        return maxColumnSum
    }
    
    @inlinable
    var L1NormAsDouble: Double {
        var result: Double = .zero
        for i in 0..<count {
            result = Relaxed.sum(result, Double(elements[i].length))
        }
        return result
    }
    
    @inlinable
    var oneNormAsDouble: Double {
        var maxColumnSum: Double = .zero
        for j in 0..<columns {
            var columnSum: Double = .zero
            for i in 0..<rows {
                columnSum += Double(self[i, j].length)
            }
            maxColumnSum = Swift.max(maxColumnSum, columnSum)
        }
        return maxColumnSum
    }
    
    @inlinable
    init(copying: borrowing Self, multiplied: Float) {
        let newElements = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newElements._unsafeCopy(from: copying.elements, multiplied: multiplied, count: copying.count)
        self.init(_unsafeElements: newElements, rows: copying.rows, columns: copying.columns)
    }
    
    @inlinable
    func frobeniusDistanceSquared(to other: borrowing Self) -> Float {
        assert(rows == other.rows && columns == other.columns, "The matrices must have the same dimensions")
        var result: Double = .zero
        for i in 0..<span.count {
            let diff = Relaxed.sum(elements[i], -other.elements[i])
            result = Relaxed.sum(Double(diff.lengthSquared), result)
        }
        return Float(result)
    }
    
    @inlinable
    func frobeniusDistance(to other: borrowing Self) -> Float {
        frobeniusDistanceSquared(to: other).squareRoot()
    }
    
    @inlinable
    func frobeniusDistanceSquaredAsDouble(to other: borrowing Self) -> Double {
        assert(rows == other.rows && columns == other.columns, "The matrices must have the same dimensions")
        var result: Double = .zero
        for i in 0..<span.count {
            let diff = Relaxed.sum(elements[i], -other.elements[i])
            result = Relaxed.sum(Double(diff.lengthSquared), result)
        }
        return result
    }
    
    @inlinable
    func frobeniusDistanceAsDouble(to other: borrowing Self) -> Double {
        frobeniusDistanceSquaredAsDouble(to: other).squareRoot()
    }
}

public extension UniqueMatrix where T: AlgebraicField, T.Magnitude: FloatingPoint {
    @inlinable @inline(__always)
    func isApproximatelyEqual( to other: borrowing Self, absoluteTolerance: T.Magnitude, relativeTolerance: T.Magnitude = 0) -> Bool {
        if rows != other.rows || columns != other.columns { return false }
        for i in 0..<count {
            if !elements[i].isApproximatelyEqual(to: other.elements[i], absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance, norm: \.magnitude) { return false }
        }
        return true
    }
    
    @inlinable
    var isDiagonal: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns where j != i {
                if !self[i, j].isApproximatelyEqual(to: .zero) {
                    return false
                }
            }
        }
        return true
    }
    
    @inlinable
    var isSymmetric: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns where j != i {
                if !self[i, j].isApproximatelyEqual(to: self[j, i]) {
                    return false
                }
            }
        }
        return true
    }
    
    @inlinable
    var isAntiSymmetric: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns {
                if !self[i, j].isApproximatelyEqual(to: -self[j, i]) { return false }
            }
        }
        return true
    }
}

public extension UniqueMatrix where T == Complex<Double> {
    @inlinable
    var isHermitian: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns {
                if !self[i, j].isApproximatelyEqual(to: self[j, i].conjugate) {
                    return false
                }
            }
        }
        return true
    }
    
    @inlinable
    var isAntiHermitian: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns {
                if !self[i, j].conjugate.isApproximatelyEqual(to: -self[j, i]) {
                    return false
                }
            }
        }
        return true
    }
}

public extension UniqueMatrix where T == Complex<Float> {
    @inlinable
    var isHermitian: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns where j != i {
                if !self[i, j].isApproximatelyEqual(to: self[j, i].conjugate) {
                    return false
                }
            }
        }
        return true
    }
    @inlinable
    var isAntiHermitian: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns {
                if !self[i, j].conjugate.isApproximatelyEqual(to: -self[j, i]) {
                    return false
                }
            }
        }
        return true
    }
}

public extension UniqueMatrix where T: AlgebraicField & Real, T.Magnitude: FloatingPoint {
    @inlinable
    var isHermitian: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns where j != i {
                if !self[i, j].isApproximatelyEqual(to: self[j, i].conjugate) {
                    return false
                }
            }
        }
        return true
    }
    @inlinable
    var isAntiHermitian: Bool {
        if rows != columns { return false }
        for i in 0..<rows {
            for j in 0..<columns {
                if !self[i, j].conjugate.isApproximatelyEqual(to: -self[j, i]) {
                    return false
                }
            }
        }
        return true
    }
}

public extension UniqueMatrix where T: AlgebraicField {
    /// Solves the system of equations Ax=b with the [Gauss-Seidel method](https://en.wikipedia.org/wiki/Gauss–Seidel_method)
    /// - Parameters:
    ///   - A: The matrix A in the system of equations Ax=b. Must be a square matrix with non-zero diagonals
    ///   - b: The vector b in the system of equatoins Ax=b
    ///   - result: On entry contains the intial guess. On exit it is the solution ´x´
    ///   - iterations: Number of iterations to perform
    @inlinable
    static func solveGaussSeidel(A: borrowing Self, b: Vector<T>, result: inout Vector<T>, iterations: Int) {
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
    static func solveGaussSeidel(A: borrowing Self, b: Vector<T>, initialGuess: Vector<T>, iterations: Int) -> Vector<T> {
        var result = initialGuess
        solveGaussSeidel(A: A, b: b, result: &result, iterations: iterations)
        return result
    }
    
    /// Solves the system of equations Ax=b with the [Jacobi method](https://en.wikipedia.org/wiki/Jacobi_method)
    /// result contains the initial guess on entry and the result on exit
    @inlinable
    static func solveJacobi(A: borrowing Self, b: Vector<T>, result: inout Vector<T>, iterations: Int) {
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
    static func solveJacobi(A: borrowing Self, b: Vector<T>, initialGuess: Vector<T>, iterations: Int) -> Vector<T> {
        var result = initialGuess
        solveJacobi(A: A, b: b, result: &result, iterations: iterations)
        return result
    }
}
