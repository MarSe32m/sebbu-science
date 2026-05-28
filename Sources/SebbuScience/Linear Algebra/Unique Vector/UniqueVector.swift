//
//  UniqueVector.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import Numerics

@frozen
public struct UniqueVector<T: ~Copyable>: ~Copyable {
    public let components: UnsafeMutablePointer<T>
    public let count: Int
    
    @inlinable
    @inline(always)
    @_transparent
    public var span: Span<T> {
        _read { yield Span(_unsafeStart: components, count: count) }
    }
    
    @inlinable
    @inline(always)
    @_transparent
    public var mutableSpan: MutableSpan<T> {
        _read { yield MutableSpan(_unsafeStart: components, count: count) }
        _modify {
            var span = MutableSpan(_unsafeStart: components, count: count)
            yield &span
        }
    }
    
    @inlinable
    public init(_ components: [T]) where T: Copyable {
        self.components = .allocate(capacity: components.count)
        self.count = components.count
        self.components.initialize(from: components, count: count)
    }
    
    @inlinable
    public init(copying vector: Vector<T>) where T: Copyable {
        self.init(copying: vector, count: vector.count)
    }
    
    @inlinable
    public init(copying vector: Vector<T>, count: Int) where T: Copyable {
        assert(count <= vector.count, "Count must not exceed the vector's count.")
        self.components = .allocate(capacity: count)
        self.count = count
        self.components.initialize(from: vector.components, count: count)
    }
    
    @inlinable
    public init(copying vector: borrowing Self) where T: Copyable {
        self.init(copying: vector, count: vector.count)
    }
    
    @inlinable
    public init(copying vector: borrowing Self, count: Int) where T: Copyable {
        assert(count <= vector.count, "Count must not exceed vector's count.")
        let newComponents: UnsafeMutablePointer<T> = .allocate(capacity: count)
        newComponents._unsafeCopy(from: vector.components, count: count)
        self.init(_unsafeComponents: newComponents, count: count)
    }
    
    @inlinable
    @_disfavoredOverload
    public init(_unsafeComponents: consuming UnsafeMutablePointer<T>, count: Int) {
        self.components = _unsafeComponents
        self.count = count
    }
    
    @inlinable
    public init(count: Int, _ initializingElementsWith: (UnsafeMutableBufferPointer<T>) throws -> Void) rethrows {
        self.count = count
        self.components = .allocate(capacity: count)
        try initializingElementsWith(.init(start: components, count: count))
    }
    
    @inlinable
    public subscript(_ index: Int) -> T {
        @_transparent
        _read {
            precondition(index < count)
            yield components[index]
        }
        @_transparent
        _modify {
            precondition(index < count)
            yield &components[index]
        }
    }
    
    //TODO: Would unsafeAddress / unsafeMutableAddress be more performant?
    @inlinable
    public subscript(unchecked index: Int) -> T {
        @_transparent
        _read {
            yield components[index]
        }
        
        @_transparent
        _modify {
            yield &components[index]
        }
    }
    
    @inlinable
    public mutating func copyComponents(from other: borrowing Self) where T: Copyable {
        precondition(count == other.count)
        components._unsafeCopy(from: other.components, count: count)
    }
    
    @inlinable
    public consuming func consumeComponents() -> UnsafeMutablePointer<T> {
        let components = self.components
        discard self
        return components
    }
    
    @inlinable
    public func copy() -> Self where T: Copyable  {
        .init(copying: self)
    }
    
    @inlinable
    deinit {
        components.deinitialize(count: count)
        components.deallocate()
    }
}

//extension UniqueVector: ExpressibleByArrayLiteral {
//    public typealias ArrayLiteralElement = T
//    
//    @inlinable
//    public init(arrayLiteral elements: ArrayLiteralElement...) {
//        self.components = Array(elements)
//    }
//}

//extension UniqueVector: Equatable where T: Equatable {}
//extension UniqueVector: Hashable where T: Hashable {}
//extension UniqueVector: Codable where T: Codable {}
extension UniqueVector: @unchecked Sendable where T: Sendable {}

extension UniqueVector where T: AlgebraicField, T.Magnitude: FloatingPoint {
    @inlinable
    func isApproximatelyEqual(to: borrowing Self) -> Bool {
        if count != to.count { return false }
        for i in 0..<count {
            if !self[i].isApproximatelyEqual(to: to[i]) {
                return false
            }
        }
        return true
    }
}
