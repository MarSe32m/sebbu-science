//
//  LILMatrix.swift
//  
//
//  Created by Sebastian Toivonen on 23.8.2023.
//

import RealModule
import ComplexModule

public struct LILMatrix<T: Sendable>: SparseMatrix, Sendable where T: AlgebraicField {
    @usableFromInline
    var rowList: [[(column: Int, value: T)]]
    
    public let rows: Int
    public let columns: Int
    
    public init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        rowList = [[(column: Int, value: T)]](repeating: [], count: rows)
    }
    
    public init<S: SparseMatrix>(from matrix: S) where S.T == T {
        self.init(rows: matrix.rows, columns: matrix.columns)
        for (row, column, value) in matrix.rowColumnValueTuples() {
            self[row, column] = value
        }
    }
    
    public subscript(row: Int, column: Int) -> T {
        get {
            assert(row >= 0 && row < rows)
            assert(column >= 0 && column < columns)
            return rowList[row].first(where: { $0.column == column })?.value ?? .zero
        }
        set {
            assert(row >= 0 && row < rows)
            assert(column >= 0 && column < columns)
            if newValue == .zero {
                rowList[row].removeAll(where: {$0.column == column})
            } else if let index = rowList[row].firstIndex(where: {$0.column == column}) {
                rowList[row][index].value = newValue
            } else {
                rowList[row].append((column: column, value: newValue))
            }
            rowList[row].sort(by: { $0.column < $1.column })
        }
    }
    
    @inlinable
    public func dot(_ vector: Vector<T>) -> Vector<T> {
        fatalError("TODO: Not implemented!")
    }
    
    @inlinable
    public func dot(_ matrix: LILMatrix<T>) -> Matrix<T> {
        fatalError("TODO: Not implemented!")
    }
    
    @inlinable
    public static func * (lhs: T, rhs: LILMatrix<T>) -> LILMatrix<T> {
        fatalError("TODO: Not implemented!")
    }
    
    @inlinable
    public static func * (lhs: Double, rhs: LILMatrix<T>) -> LILMatrix<T> where T == Complex<Double> {
        fatalError("TODO: Not implemented!")
    }
    
    public func rowColumnValueTuples() -> [(row: Int, column: Int, value: T)] {
        rowList.enumerated().flatMap { (row: Int, column: [(column: Int, value: T)]) in
            column.map { (column: Int, value: T) in
                (row: row, column: column, value: value)
            }
        }
    }
}
