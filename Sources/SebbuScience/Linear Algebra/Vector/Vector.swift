//
//  Vector.swift
//  swift-phd-toivonen
//
//  Created by Sebastian Toivonen on 13.10.2024.
//

import RealModule
import ComplexModule

public struct Vector<T> {
    public var components: [T]
    
    @_transparent
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
    
    @inline(__always)
    public subscript(_ index: Int) -> T {
        _read {
            yield components[index]
        }
        _modify {
            yield &components[index]
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
