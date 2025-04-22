//
//  Matrix.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

import RealModule
import ComplexModule

public struct Matrix<T> {
    public var elements: [T]
    public let rows: Int
    public let columns: Int
    
    @inlinable
    public init(elements: [T], rows: Int, columns: Int) {
        precondition(elements.count == rows * columns)
        self.elements = elements
        self.rows = rows
        self.columns = columns
    }
    
    @inlinable
    public init(rows: Int, columns: Int, _ initializingElementsWith: (UnsafeMutableBufferPointer<T>) throws -> Void) rethrows {
        self.rows = rows
        self.columns = columns
        elements = try .init(unsafeUninitializedCapacity: rows * columns, initializingWith: { buffer, initializedCount in
            initializedCount = rows * columns
            try initializingElementsWith(buffer)
        })
    }
    
    @inlinable
    public subscript(_ i: Int, _ j: Int) -> T {
        _read {
            let index = i * columns + j
            precondition(index < elements.count)
            yield elements[index]
        }
        
        _modify {
            let index = i * columns + j
            precondition(index < elements.count)
            yield &elements[index]
        }
    }
}

extension Matrix {
    @inlinable
    func extractColumns() -> [[T]] {
        var result = [[T]](repeating: [], count: columns)
        for i in 0..<rows {
            for j in 0..<columns {
                result[j].append(self[i, j])
            }
        }
        return result
    }
    
    @inlinable
    func extractRows() -> [[T]] {
        var result = [[T]](repeating: [], count: rows)
        for i in 0..<rows {
            for j in 0..<columns {
                result[i].append(self[i, j])
            }
        }
        return result
    }
    
    @inlinable
    static func from(columns cols: [[T]]) -> Self {
        if cols.isEmpty { return .init(elements: [], rows: 0, columns: 0) }
        let rows = cols[0].count
        let columns = cols.count
        return .init(rows: rows, columns: columns) { buffer in
            for j in 0..<columns {
                precondition(cols[j].count == rows)
                for i in 0..<rows {
                    buffer.initializeElement(at: i * columns + j, to: cols[j][i])
                }
            }
        }
    }
    
    @inlinable
    static func from(rows _rows: [[T]]) -> Self {
        if _rows.isEmpty { return .init(elements: [], rows: 0, columns: 0) }
        let rows = _rows.count
        let columns = _rows[0].count
        return .init(rows: rows, columns: columns) { buffer in
            for i in 0..<rows {
                precondition(_rows[i].count == columns)
                for j in 0..<columns {
                    buffer.initializeElement(at: i * columns + j, to: _rows[i][j])
                }
            }
        }
    }
    
    @inlinable
    static func hankel(firstRow: [T], lastColumn: [T]) -> Self where T: Equatable {
        precondition(firstRow.last == lastColumn.first, "The last element of the first row and the first element of the last column do not match")
        let rows = lastColumn.count
        let columns = firstRow.count
        return .init(rows: rows, columns: columns) { buffer in
            for i in 0..<rows {
                for j in 0..<columns {
                    if i + j < firstRow.count {
                        buffer[i * columns + j] = firstRow[i + j]
                    } else {
                        buffer[i * columns + j] = lastColumn[i + j - firstRow.count + 1]
                    }
                }
            }
        }
    }
}

extension Matrix: Equatable where T: Equatable {}
extension Matrix: Hashable where T: Hashable {}
extension Matrix: Codable where T: Codable {}
extension Matrix: Sendable where T: Sendable {}
