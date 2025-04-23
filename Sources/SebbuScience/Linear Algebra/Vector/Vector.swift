//
//  Vector.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

import RealModule
import ComplexModule

public struct Vector<T> {
    public var components: [T]
    
    @inlinable
    public var count: Int { components.count }
    
    public init(_ components: [T]) {
        self.components = components
    }
    
    @inlinable
    public init(count: Int, _ initializingElementsWith: (UnsafeMutableBufferPointer<T>) throws -> Void) rethrows {
        components = try .init(unsafeUninitializedCapacity: count, initializingWith: { buffer, initializedCount in
            initializedCount = count
            try initializingElementsWith(buffer)
        })
    }
    
    @inlinable
    public subscript(_ index: Int) -> T {
        _read {
            yield components[index]
        }
        _modify {
            yield &components[index]
        }
    }
    
    @inlinable
    public mutating func copyComponents(from other: Self) {
        precondition(count == other.count)
        for i in 0..<count {
            components[i] = other.components[i]
        }
    }
}

extension Vector: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = T
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.components = Array(elements)
    }
}

extension Vector: Equatable where T: Equatable {}
extension Vector: Hashable where T: Hashable {}
extension Vector: Codable where T: Codable {}
extension Vector: Sendable where T: Sendable {}

extension Vector where T: AlgebraicField, T.Magnitude: FloatingPoint {
    func isApproximatelyEqual(to: Self) -> Bool {
        if count != to.count { return false }
        for i in 0..<count {
            if !self[i].isApproximatelyEqual(to: to[i]) {
                return false
            }
        }
        return true
    }
}
