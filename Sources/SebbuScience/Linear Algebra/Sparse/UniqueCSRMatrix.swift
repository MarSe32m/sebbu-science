//
//  CSRMatrix.swift
//  
//
//  Created by Sebastian Toivonen on 23.8.2023.
//

//#if canImport(COpenBLAS)
//import COpenBLAS
//#elseif canImport(Accelerate)
//import Accelerate
//#endif

import NumericsExtensions
import BasicContainers

public struct UniqueCSRMatrix<T>: ~Copyable {
    @usableFromInline
    internal var values: UniqueArray<T>
    
    @usableFromInline
    internal var columnIndices: UniqueArray<Int>
    
    @usableFromInline
    internal var rowIndices: UniqueArray<Int>
    
    public let columns: Int
    public let rows: Int
    
    @inlinable
    var transpose: UniqueCSRMatrix<T> {
        //TODO: Is there a way to optimize this?
        var tuples = rowColumnValueTuples()
        tuples = tuples.map { ($0.column, $0.row, $0.value) }
        var result = UniqueCSRMatrix(rows: self.columns, columns: self.rows, values: .init(), rowIndices: .init(), columnIndices: .init())
        result.setValuesFromRowColumnValueTuples(tuples: tuples)
        return result
    }
    
    @inlinable
    public init(rows: Int, columns: Int, values: consuming UniqueArray<T>, rowIndices: consuming UniqueArray<Int>, columnIndices: consuming UniqueArray<Int>) {
        self.rows = rows
        self.columns = columns
        self.values = values
        self.columnIndices = columnIndices
        self.rowIndices = rowIndices
    }
    
    @inlinable
    public init<S: SparseMatrix>(from matrix: S) where S.T == T {
        self.init(rows: matrix.rows, columns: matrix.columns, values: .init(), rowIndices: .init(), columnIndices: .init())
        setValuesFromRowColumnValueTuples(tuples: matrix.rowColumnValueTuples())
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
        var result: [(column: Int, value: T)] = []
        for i in rowStartIndex..<rowEndIndex {
            result.append((columnIndices[i], values[i]))
        }
        return result
    }
    
    @inlinable
    internal mutating func setValuesFromRowColumnValueTuples(tuples: [(row: Int, column: Int, value: T)]) {
        // Sort tuples by row and then by column
        let sortedTuples = tuples.sorted { $0.row == $1.row ? $0.column < $1.column : $0.row < $1.row }

        var values: UniqueArray<T> = .init()
        var columnIndices: UniqueArray<Int> = .init()
        var rowIndices: UniqueArray<Int> = .init(repeating: 0, count: rows + 1)

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
    
    @inlinable
    public func withValues<R>(_ body: ((borrowing UniqueArray<T>) throws -> R)) rethrows -> R {
        try body(values)
    }
    
    @inlinable
    public func withColumnIndices<R>(_ body: ((borrowing UniqueArray<Int>) throws -> R)) rethrows -> R {
        try body(columnIndices)
    }
    
    @inlinable
    public func withRowIndices<R>(_ body: ((borrowing UniqueArray<Int>) throws -> R)) rethrows -> R {
        try body(rowIndices)
    }
}

public extension UniqueCSRMatrix where T: AlgebraicField {
    @inlinable
    @_optimize(speed)
    func dot(_ matrix: borrowing UniqueCSRMatrix<T>) -> Matrix<T> {
        fatalError("TODO: Implement")
    }
    
    @inlinable
    @_optimize(speed)
    subscript(row: Int, column: Int) -> T {
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
}

public extension UniqueCSRMatrix where T == Complex<Double> {
    @inlinable
    init(from matrix: Matrix<T>, relativeTolerance: T.Magnitude = .ulpOfOne.squareRoot()) {
        var rowColumnValueTuples: [(row: Int, column: Int, value: T)] = []
        for i in 0..<matrix.rows {
            for j in 0..<matrix.columns {
                if matrix[i, j].isApproximatelyEqual(to: .zero)  {
                    rowColumnValueTuples.append((i, j, matrix[i, j]))
                }
            }
        }
        self = .zero(rows: matrix.rows, columns: matrix.columns)
        setValuesFromRowColumnValueTuples(tuples: rowColumnValueTuples)
    }
    
    @inlinable
    var conjugate: UniqueCSRMatrix<T> {
        let newValues: UniqueArray<T> = .init(capacity: values.count) { span in
            for i in values.indices {
                span.append(values[i].conjugate)
            }
        }
        let newRowIndices: UniqueArray<Int> = .init(capacity: rowIndices.count) { span in
            for i in rowIndices.indices {
                span.append(rowIndices[i])
            }
        }
        let newColumnIndices: UniqueArray<Int> = .init(capacity: columnIndices.count) { span in
            for i in columnIndices.indices {
                span.append(columnIndices[i])
            }
        }

        return UniqueCSRMatrix(rows: rows, columns: columns, values: newValues, rowIndices: newRowIndices, columnIndices: newColumnIndices)
    }
    
    @inlinable
    var conjugateTranspose: UniqueCSRMatrix<T> {
        //TODO: Is there a way to optimize this?
        var tuples = rowColumnValueTuples()
        tuples = tuples.map { ($0.column, $0.row, $0.value.conjugate) }
        var result: Self = .zero(rows: columns, columns: rows)
        result.setValuesFromRowColumnValueTuples(tuples: tuples)
        return result
    }
}

public extension UniqueCSRMatrix where T == Complex<Float> {
    
    @inlinable
    var conjugate: UniqueCSRMatrix<T> {
        let newValues: UniqueArray<T> = .init(capacity: values.count) { span in
            for i in values.indices {
                span.append(values[i].conjugate)
            }
        }
        let newRowIndices: UniqueArray<Int> = .init(capacity: rowIndices.count) { span in
            for i in rowIndices.indices {
                span.append(rowIndices[i])
            }
        }
        let newColumnIndices: UniqueArray<Int> = .init(capacity: columnIndices.count) { span in
            for i in columnIndices.indices {
                span.append(columnIndices[i])
            }
        }

        return UniqueCSRMatrix(rows: rows, columns: columns, values: newValues, rowIndices: newRowIndices, columnIndices: newColumnIndices)
    }
    
    @inlinable
    var conjugateTranspose: UniqueCSRMatrix<T> {
        //TODO: Is there a way to optimize this?
        var tuples = rowColumnValueTuples()
        tuples = tuples.map { ($0.column, $0.row, $0.value.conjugate) }
        var result: Self = .zero(rows: columns, columns: rows)
        result.setValuesFromRowColumnValueTuples(tuples: tuples)
        return result
    }
}

public extension UniqueCSRMatrix where T: AlgebraicField {
    @inlinable
    static func zero(rows: Int, columns: Int) -> Self {
        .init(rows: rows, columns: columns, values: .init(), rowIndices: .init(), columnIndices: .init())
    }
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
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        dot(vector, multiplied: 1, into: into)
    }
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        rowIndices.span.withUnsafeBufferPointer { rowIndices in
            columnIndices.span.withUnsafeBufferPointer { columnIndices in
                values.span.withUnsafeBufferPointer { values in
                    var tempValue: T = .zero
                    var i = 0
                    var j = 0
                    while i < rows {
                        let upperBound = rowIndices[i &+ 1]
                        j = rowIndices[i]
                        if j == upperBound {
                            into[i] = .zero
                            i &+= 1
                            continue
                        }
                        tempValue = .zero
                        while j &+ 2 <= upperBound {
                            tempValue = Relaxed.multiplyAdd(values[j], vector[columnIndices[j]], tempValue)
                            tempValue = Relaxed.multiplyAdd(values[j &+ 1], vector[columnIndices[j &+ 1]], tempValue)
                            j &+= 2
                        }
                        while j < upperBound {
                            tempValue = Relaxed.multiplyAdd(values[j], vector[columnIndices[j]], tempValue)
                            j &+= 1
                        }
                        into[i] = Relaxed.product(tempValue, multiplied)
                        i &+= 1
                    }
                }
            }
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto: inout Vector<T>) {
        dot(vector.components, multiplied: multiplied, addingInto: &addingInto.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        dot(vector, multiplied: 1, addingInto: into)
    }
    
    @inlinable
    @_optimize(speed)
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        rowIndices.span.withUnsafeBufferPointer { rowIndices in
            columnIndices.span.withUnsafeBufferPointer { columnIndices in
                values.span.withUnsafeBufferPointer { values in
                    var tempValue: T = .zero
                    var i = 0
                    var j = 0
                    while i < rows {
                        let upperBound = rowIndices[i &+ 1]
                        j = rowIndices[i]
                        if j == upperBound {
                            i &+= 1
                            continue
                        }
                        tempValue = .zero
                        while j &+ 2 <= upperBound {
                            tempValue = Relaxed.multiplyAdd(values[j], vector[columnIndices[j]], tempValue)
                            tempValue = Relaxed.multiplyAdd(values[j &+ 1], vector[columnIndices[j &+ 1]], tempValue)
                            j &+= 2
                        }
                        while j < upperBound {
                            tempValue = Relaxed.multiplyAdd(values[j], vector[columnIndices[j]], tempValue)
                            j &+= 1
                        }
                        into[i] = Relaxed.multiplyAdd(tempValue, multiplied, into[i])
                        i &+= 1
                    }
                }
            }
        }
    }
    
    @_optimize(speed)
    @inlinable
    static func *(lhs: T, rhs: borrowing UniqueCSRMatrix<T>) -> UniqueCSRMatrix<T> {
        let newValues: UniqueArray<T> = .init(capacity: rhs.values.count) { span in
            for i in rhs.values.indices {
                span.append(Relaxed.product(lhs, rhs.values[i]))
            }
        }
        let newRowIndices: UniqueArray<Int> = .init(capacity: rhs.rowIndices.count) { span in
            for i in rhs.rowIndices.indices {
                span.append(rhs.rowIndices[i])
            }
        }
        let newColumnIndices: UniqueArray<Int> = .init(capacity: rhs.columnIndices.count) { span in
            for i in rhs.columnIndices.indices {
                span.append(rhs.columnIndices[i])
            }
        }
        return UniqueCSRMatrix(rows: rhs.rows, columns: rhs.columns, values: newValues, rowIndices: newRowIndices, columnIndices: newColumnIndices)
    }
    
    
    @_optimize(speed)
    @inlinable
    static func *=(lhs: inout UniqueCSRMatrix<T>, rhs: T)  {
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
    static func /(lhs: borrowing UniqueCSRMatrix<T>, rhs: T) -> UniqueCSRMatrix<T> {
        var result: UniqueCSRMatrix<T> = .zero(rows: lhs.rows, columns: lhs.columns)
        result.divide(by: rhs)
        return result
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /=(lhs: inout UniqueCSRMatrix<T>, rhs: T)  {
        lhs.divide(by: rhs)
    }
    
    
    @_optimize(speed)
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var mutableSpan = values.mutableSpan
            for i in mutableSpan.indices {
                mutableSpan[unchecked: i] /= by
            }
        }
    }
}

public extension UniqueCSRMatrix<Complex<Double>> {
    @_optimize(speed)
    @inlinable
    static func *(lhs: Double, rhs: borrowing UniqueCSRMatrix<T>) -> Self {
        let newValues: UniqueArray<T> = .init(capacity: rhs.values.count) { span in
            for i in rhs.values.indices {
                span.append(Relaxed.product(lhs, rhs.values[i]))
            }
        }
        let newRowIndices: UniqueArray<Int> = .init(capacity: rhs.rowIndices.count) { span in
            for i in rhs.rowIndices.indices {
                span.append(rhs.rowIndices[i])
            }
        }
        let newColumnIndices: UniqueArray<Int> = .init(capacity: rhs.columnIndices.count) { span in
            for i in rhs.columnIndices.indices {
                span.append(rhs.columnIndices[i])
            }
        }
        return UniqueCSRMatrix(rows: rhs.rows, columns: rhs.columns, values: newValues, rowIndices: newRowIndices, columnIndices: newColumnIndices)
    }
    
    
    @_optimize(speed)
    @inlinable
    static func *=(lhs: inout UniqueCSRMatrix<T>, rhs: Double)  {
        lhs.multiply(by: rhs)
    }
    
    @_optimize(speed)
    @inlinable
    mutating func multiply(by: Double) {
        var span = values.mutableSpan
        for i in 0..<span.count {
            span[unchecked: i] = Relaxed.product(span[unchecked: i], by)
        }
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /(lhs: borrowing UniqueCSRMatrix<T>, rhs: Double) -> UniqueCSRMatrix<T> {
        let newValues: UniqueArray<T> = .init(capacity: lhs.values.count) { span in
            for i in lhs.values.indices {
                span.append(lhs.values[i] / rhs)
            }
        }
        let newRowIndices: UniqueArray<Int> = .init(capacity: lhs.rowIndices.count) { span in
            for i in lhs.rowIndices.indices {
                span.append(lhs.rowIndices[i])
            }
        }
        let newColumnIndices: UniqueArray<Int> = .init(capacity: lhs.columnIndices.count) { span in
            for i in lhs.columnIndices.indices {
                span.append(lhs.columnIndices[i])
            }
        }
        return UniqueCSRMatrix(rows: lhs.rows, columns: lhs.columns, values: newValues, rowIndices: newRowIndices, columnIndices: newColumnIndices)
    }
    
    
    @_optimize(speed)
    @inlinable
    static func /=(lhs: inout UniqueCSRMatrix<T>, rhs: Double)  {
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

extension UniqueCSRMatrix: Sendable where T: Sendable {}
//extension UniqueCSRMatrix: Equatable where T: Equatable {}
//extension UniqueCSRMatrix: Hashable where T: Hashable {}
//extension UniqueCSRMatrix: Codable where T: Codable {}

