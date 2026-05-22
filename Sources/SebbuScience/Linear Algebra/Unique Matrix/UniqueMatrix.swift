//
//  UniqueMatrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 16.5.2026.
//

import RealModule
import ComplexModule

public struct UniqueMatrix<T: ~Copyable>: ~Copyable {
    public let elements: UnsafeMutablePointer<T>
    public let rows: Int
    public let columns: Int
    
    @usableFromInline
    internal var count: Int { rows &* columns }
    
    @inlinable
    @inline(always)
    @_transparent
    public var span: Span<T> {
        _read { yield Span(_unsafeStart: elements, count: count) }
    }
    
    @inlinable
    @inline(always)
    @_transparent
    public var mutableSpan: MutableSpan<T> {
        _read { yield MutableSpan(_unsafeStart: elements, count: count) }
        _modify {
            var span = MutableSpan(_unsafeStart: elements, count: count)
            yield &span
        }
    }
    
    @inlinable
    @inline(always)
    @_transparent
    public var isSquare: Bool {
        rows == columns
    }
    
    @inlinable
    public init(elements: [T], rows: Int, columns: Int) where T: Copyable {
        precondition(elements.count == rows &* columns)
        self.elements = .allocate(capacity: rows &* columns)
        self.elements.initialize(from: elements, count: rows &* columns)
        self.rows = rows
        self.columns = columns
    }
    
    @inlinable
    public init(copying: borrowing Self) where T: Copyable {
        let newElements = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newElements._unsafeCopy(from: copying.elements, count: copying.count)
        self.init(_unsafeElements: newElements, rows: copying.rows, columns: copying.columns)
    }
    
    @inlinable
    @_disfavoredOverload
    public init(_unsafeElements: UnsafeMutablePointer<T>, rows: Int, columns: Int) {
        self.elements = _unsafeElements
        self.rows = rows
        self.columns = columns
    }
    
    @inlinable
    deinit {
        elements.deinitialize(count: rows * columns)
        elements.deallocate()
    }
    
    @inlinable
    public init(rows: Int, columns: Int, _ initializingElementsWith: (UnsafeMutableBufferPointer<T>) throws -> Void) rethrows {
        self.rows = rows
        self.columns = columns
        self.elements = .allocate(capacity: rows &* columns)
        try initializingElementsWith(.init(start: elements, count: count))
    }
    
    @inlinable
    public subscript(_ i: Int, _ j: Int) -> T {
        @_transparent
        @inline(always)
        _read {
            let index = i &* columns &+ j
            precondition(index < count)
            yield elements[index]
        }

        @_transparent
        @inline(always)
        _modify {
            let index = i &* columns &+ j
            precondition(index < count)
            yield &elements[index]
        }
    }

    @inlinable
    public subscript(unchecked i: Int, unchecked j: Int) -> T {
        @_transparent
        @inline(always)
        _read {
            let index = i &* columns &+ j
            yield elements[index]
        }
        
        @_transparent
        @inline(always)
        _modify {
            let index = i &* columns &+ j
            yield &elements[index]
        }
    }
    
    @inlinable
    public mutating func copyElements(from other: borrowing Self) where T: Copyable {
        precondition(count == other.count)
        elements._unsafeCopy(from: other.elements, count: count)
    }
}

public extension UniqueMatrix where T: Copyable {
    @inlinable
    var transpose: Self {
        var result: Self = .init(rows: columns, columns: rows) { _ in }
        for i in 0..<columns {
            for j in 0..<rows {
                result[i, j] = self[j, i]
            }
        }
        return result
    }
    
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

//extension UniqueMatrix: Equatable where T: Equatable {}
//extension UniqueMatrix: Hashable where T: Hashable {}
//extension UniqueMatrix: Codable where T: Codable {}
extension UniqueMatrix: @unchecked Sendable where T: Sendable {}

public extension UniqueMatrix {
    /// Determines which side of the multiplication is hermitian
    enum HermitianSide {
        case left
        case right
    }
    
    /// Determines which side of the multiplication is symmetric
    enum SymmetricSide {
        case left
        case right
    }
}
