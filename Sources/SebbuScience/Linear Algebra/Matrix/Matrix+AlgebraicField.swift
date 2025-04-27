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
        _add(other, scaling: scaling)
    }

    @inlinable
    internal mutating func _add(_ other: Self, scaling: T) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        for i in 0..<elements.count {
            elements[i] = Relaxed.multiplyAdd(scaling, other.elements[i], elements[i])
        }
    }
    
    @inlinable
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        for i in 0..<elements.count {
            elements[i] = Relaxed.sum(other.elements[i], elements[i])
        }
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
        _subtract(other)
    }

    @inlinable
    mutating func _subtract(_ other: Self) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        for i in 0..<elements.count {
            elements[i] = Relaxed.sum(elements[i], -other.elements[i])
        }
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
    
    @inlinable
    mutating func multiply(by: T) {
        _multiply(by: by)
    }
    
    @inlinable
    mutating func _multiply(by: T) {
        for i in 0..<elements.count {
            elements[i] = Relaxed.product(by, elements[i])
        }
    }
    
    @inlinable
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
    
    @inlinable
    func _multiply(by: T, into: inout Self) {
        for i in 0..<into.elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
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
        _divide(by: by)
    }

    @inlinable
    mutating func _divide(by: T) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal)
        } else {
            for i in 0..<elements.count {
                elements[i] /= by
            }
        }
    }
    
    @inlinable
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }

    @inlinable
    func _divide(by: T, into: inout Self) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal, into: &into)
        } else {
            for i in 0..<elements.count {
                into.elements[i] = elements[i] / by
            }
        }
    }
}

//MARK: Matrix-Vector and Matrix-Matrix operations
public extension Matrix where T: AlgebraicField {
    @inlinable
    func dot(_ other: Self) -> Self {
        //FIXME: Is this safe? Anything conforming to AlgebraicField ought to be quite trivial... So we can leave the memory uninitialized
        var result: Self = .init(rows: rows, columns: other.columns) { _ in }
        dot(other, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T) -> Self {
        //FIXME: Is this safe? Anything conforming to AlgebraicField ought to be quite trivial... So we can leave the memory uninitialized
        var result: Self = Self.init(rows: rows, columns: other.columns) { _ in }
        dot(other, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ other: Self, into: inout Self) {
        _dot(other, into: &into)
    }

    @inlinable
    func _dot(_ other: Self, into: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
        for i in 0..<rows {
            for j in 0..<other.columns { into[i, j] = .zero }
            for k in 0..<columns {
                let A = self[i, k]
                for j in 0..<other.columns {
                    into[i, j] = Relaxed.multiplyAdd(A, other[k, j], into[i, j])
                }
            }
        }
    }
    
    @inlinable
    func dot(_ other: Self, multiplied: T, into: inout Self) {
        _dot(other, multiplied: multiplied, into: &into)
    }

    @inlinable
    func _dot(_ other: Self, multiplied: T, into: inout Self) {
        precondition(columns == other.rows)
        precondition(rows == into.rows)
        precondition(other.columns == into.columns)
        for i in 0..<rows {
            for j in 0..<other.columns { into[i, j] = .zero }
            for k in 0..<columns {
                let A = Relaxed.product(self[i, k], multiplied)
                for j in 0..<other.columns {
                    into[i, j] = Relaxed.multiplyAdd(A, other[k, j], into[i, j])
                }
            }
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
        _dot(vector, into: &into)
    }

    @inlinable
    func _dot(_ vector: Vector<T>, into: inout Vector<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1]))
            into[1] = Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3]))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = result
        }
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        _dot(vector, multiplied: multiplied, into: &into)
    }

    @inlinable
    func _dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1])))
            into[1] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3])))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.product(result, multiplied)
        }
    }
}

public extension Matrix where T: AlgebraicField {
    @inlinable
    var transpose: Self {
        var result: Self = .init(rows: columns, columns: rows, {_ in })
        for i in 0..<columns {
            for j in 0..<rows {
                result[i, j] = self[j, i]
            }
        }
        return result
    }
    
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
