//
//  SparseMatrix.swift
//  swift-phd-toivonen
//
//  Created by Sebastian Toivonen on 22.10.2024.
//
import RealModule
import ComplexModule

public protocol SparseMatrix: CustomStringConvertible {
    associatedtype T: AlgebraicField
    
    var rows: Int { get }
    var columns: Int { get }
    
    func rowColumnValueTuples() -> [(row: Int, column: Int, value: T)]
}

extension SparseMatrix {
    public var description: String {
        //TODO: Better formatting
        var result = ""
        let tuples = rowColumnValueTuples().sorted(by: { $0.row < $1.row || ($0.row == $1.row && $0.column < $1.column)})
        let rowData = extractRows(tuples: tuples)
        for row in 0..<rows {
            defer { result += "\n" }
            let rowTuples = rowData[row]
            if rowTuples.isEmpty {
                result += String(repeating: "0 ", count: columns)
                continue
            }
            var currentColumn = 0
            for rowTuple in rowTuples {
                while rowTuple.column > currentColumn {
                    result += "0 "
                    currentColumn += 1
                }
                result += "\(rowTuple.value) "
            }
            
            while currentColumn < columns {
                result += "0 "
                currentColumn += 1
            }
        }
        return result
    }
    
    private func extractRows(tuples: [(row: Int, column: Int, value: T)]) -> [[(column: Int, value: T)]] {
        var result: [[(column: Int, value: T)]] = Array(repeating: [], count: rows)
        for tuple in tuples {
            result[tuple.row].append((tuple.column, tuple.value))
        }
        return result
    }
}

