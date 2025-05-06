//
//  CSRMatrix.swift
//  
//
//  Created by Sebastian Toivonen on 23.8.2023.
//

import RealModule
import ComplexModule
import NumericsExtensions
import SebbuCollections

public struct CSRMatrix<T: Sendable>: SparseMatrix, Sendable where T: AlgebraicField {
    @usableFromInline
    internal var values: [T]
    
    @usableFromInline
    internal var columnIndices: [Int]
    
    @usableFromInline
    internal var rowIndices: [Int]
    
    public let columns: Int
    public let rows: Int
    
    public init(rows: Int, columns: Int, values: [T], rowIndices: [Int], columnIndices: [Int]) {
        self.rows = rows
        self.columns = columns
        self.values = values
        self.columnIndices = columnIndices
        self.rowIndices = rowIndices
    }
    
    public init<S: SparseMatrix>(from matrix: S) where S.T == T {
        self.init(rows: matrix.rows, columns: matrix.columns, values: [], rowIndices: [], columnIndices: [])
        setValuesFromRowColumnValueTuples(tuples: matrix.rowColumnValueTuples())
    }
    
    @inlinable
    @_optimize(speed)
    public func dot(_ matrix: CSRMatrix<T>) -> Matrix<T> {
        var _ = CSRMatrix<T>(rows: self.rows, columns: self.columns, values: [], rowIndices: [], columnIndices: [])
        fatalError("TODO: Implement")
    }
    
    @inlinable
    @_optimize(speed)
    public subscript(row: Int, column: Int) -> T {
        _read {
            let row = extract(row: row)
            var result: T? = nil
            for (col, value) in row {
                if col > column { break }
                if col == column {
                    result = value
                    break
                }
            }
            if let result = result {
                yield result
            } else {
                yield .zero
            }
        }
        _modify {
            //TODO: Do we want to be able to modify?
            fatalError("Not implemented")
        }
    }
    
    @inlinable
    public func rowColumnValueTuples() -> [(row: Int, column: Int, value: T)] {
        var result: [(row: Int, column: Int, value: T)] = []
        for row in 0..<rows {
            result.append(contentsOf: extract(row: row).map {(row, $0.column, $0.value)})
        }
        return result
    }
    
    @inlinable
    internal func extract(row: Int) -> [(column: Int, value: T)] {
        let rowStartIndex = rowIndices[row]
        let rowEndIndex = rowIndices[row + 1]
        return Array(zip(columnIndices[rowStartIndex..<rowEndIndex], values[rowStartIndex..<rowEndIndex]))
    }
    
    private mutating func setValuesFromRowColumnValueTuples(tuples: [(row: Int, column: Int, value: T)]) {
        // Sort tuples by row and then by column
        let sortedTuples = tuples.sorted { $0.row == $1.row ? $0.column < $1.column : $0.row < $1.row }

        var values: [T] = []
        var columnIndices: [Int] = []
        var rowIndices: [Int] = Array(repeating: 0, count: rows + 1)

        var currentRow = 0

        for (row, column, value) in sortedTuples {
            while currentRow < row {
                rowIndices[currentRow + 1] = values.count
                currentRow += 1
            }
            values.append(value)
            columnIndices.append(column)
        }

        // Finalize the rowIndices array for any remaining rows
        while currentRow < rows {
            rowIndices[currentRow + 1] = values.count
            currentRow += 1
        }

        self.values = values
        self.columnIndices = columnIndices
        self.rowIndices = rowIndices
    }
}

public extension CSRMatrix where T == Complex<Double> {
    var conjugate: CSRMatrix<T> {
        CSRMatrix(rows: rows, columns: columns, values: values.map { $0.conjugate }, rowIndices: rowIndices, columnIndices: columnIndices)
    }
    
    var transpose: CSRMatrix<T> {
        //TODO: Is there a way to optimize this?
        var tuples = rowColumnValueTuples()
        tuples = tuples.map { ($0.column, $0.row, $0.value) }
        var result = self
        result.setValuesFromRowColumnValueTuples(tuples: tuples)
        return result
    }
}

public extension CSRMatrix {
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result: Vector<T> = .zero(rows)
        dot(vector, into: &result)
        return result
    }
    
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        dot(vector, multiplied: 1, into: &into)
    }
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        dot(vector, multiplied: 1, addingInto: &addingInto)
    }
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result: Vector<T> = .zero(rows)
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        into.components.withUnsafeMutableBufferPointer { into in
            rowIndices.withUnsafeBufferPointer { rowIndices in
                columnIndices.withUnsafeBufferPointer { columnIndices in
                    values.withUnsafeBufferPointer { values in
                        var tempValue: T = .zero
                        for i in 0..<rows {
                            tempValue = .zero
                            let elementCount = rowIndices[i + 1] - rowIndices[i]
                            if elementCount == 0 {
                                into[i] = .zero
                                continue
                            }
                            for j in rowIndices[i]..<rowIndices[i + 1] {
                                tempValue = Relaxed.multiplyAdd(values[j], vector[columnIndices[j]], tempValue)
                            }
                            into[i] = Relaxed.product(tempValue, multiplied)
                        }
                    }
                }
            }
        }
    }
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: Vector<T>, multiplied: T, addingInto: inout Vector<T>) {
        addingInto.components.withUnsafeMutableBufferPointer { into in
            rowIndices.withUnsafeBufferPointer { rowIndices in
                columnIndices.withUnsafeBufferPointer { columnIndices in
                    values.withUnsafeBufferPointer { values in
                        var tempValue: T = .zero
                        for i in 0..<rows {
                            tempValue = .zero
                            let elementCount = rowIndices[i + 1] - rowIndices[i]
                            if elementCount == 0 {
                                continue
                            }
                            for j in rowIndices[i]..<rowIndices[i + 1] {
                                tempValue = Relaxed.multiplyAdd(values[j], vector[columnIndices[j]], tempValue)
                            }
                            into[i] = Relaxed.multiplyAdd(tempValue, multiplied, into[i])
                        }
                    }
                }
            }
        }
    }
    
    
    @_optimize(speed)
    @inlinable
    static func *(lhs: T, rhs: CSRMatrix<T>) -> CSRMatrix<T> {
        let newValues = rhs.values.map { Relaxed.product($0, lhs) }
        return CSRMatrix(rows: rhs.rows, columns: rhs.columns, values: newValues, rowIndices: rhs.rowIndices, columnIndices: rhs.columnIndices)
    }
    
    
    @_optimize(speed)
    @inlinable
    
    static func *=(lhs: inout CSRMatrix<T>, rhs: T)  {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_optimize(speed)
    
    mutating func multiply(by: T) {
        for i in 0..<values.count {
            values[i] = Relaxed.product(values[i], by)
        }
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /(lhs: CSRMatrix<T>, rhs: T) -> CSRMatrix<T> {
        var result = copy lhs
        result.divide(by: rhs)
        return result
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /=(lhs: inout CSRMatrix<T>, rhs: T)  {
        lhs.divide(by: rhs)
    }
    
    
    @_optimize(speed)
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in values.indices {
                values[i] /= by
            }
        }
    }
}


public extension CSRMatrix<Complex<Double>> {
    @_optimize(speed)
    @inlinable
    static func *(lhs: Double, rhs: CSRMatrix<T>) -> Self {
        var result = CSRMatrix(rows: rhs.rows, columns: rhs.columns, values: rhs.values, rowIndices: rhs.rowIndices, columnIndices: rhs.columnIndices)
        result.multiply(by: lhs)
        return result
    }
    
    
    @_optimize(speed)
    @inlinable
    static func *=(lhs: inout CSRMatrix<T>, rhs: Double)  {
        lhs.multiply(by: rhs)
    }
    
    @_optimize(speed)
    @inlinable
    mutating func multiply(by: Double) {
        for i in 0..<values.count {
            values[i].real = Relaxed.product(values[i].real, by)
            values[i].imaginary = Relaxed.product(values[i].imaginary, by)
        }
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /(lhs: CSRMatrix<T>, rhs: Double) -> CSRMatrix<T> {
        var result = CSRMatrix(rows: lhs.rows, columns: lhs.columns, values: lhs.values, rowIndices: lhs.rowIndices, columnIndices: lhs.columnIndices)
        result.divide(by: rhs)
        return result
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /=(lhs: inout CSRMatrix<T>, rhs: Double)  {
        lhs.divide(by: Complex(rhs))
    }
    
    
    @_optimize(speed)
    @inlinable
    mutating func divide(by: Double) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in values.indices {
                values[i] /= by
            }
        }
    }
}
