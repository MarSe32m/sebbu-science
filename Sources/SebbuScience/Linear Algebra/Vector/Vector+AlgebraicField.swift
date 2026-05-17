//
//  Vector+AlgebraicField.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule
import ComplexModule

public extension Vector where T: AlgebraicField {
    @inlinable
    static func zero(_ count: Int) -> Vector<T> {
        Vector(count: count) { buffer in
            var i = 0
            while i < count {
                buffer[i] = .zero
                i &+= 1
            }
        }
    }
    
    @inlinable
    @_transparent
    mutating func zeroComponents() {
        var span = components.mutableSpan
        for i in span.indices {
            span[unchecked: i] = .zero
        }
    }
    
    @inlinable
    mutating func copyComponents(from other: Self, adding: Self, multiplied: T) {
        precondition(components.count == other.components.count)
        precondition(components.count == adding.components.count)
        var mutableSpan = components.mutableSpan
        let otherSpan = other.components.span
        let addingSpan = adding.components.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, addingSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
    
    @inlinable
    mutating func copyComponents(from other: Self, multiplied: T) {
        precondition(components.count == other.components.count)
        var mutableSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.product(otherSpan[unchecked: i], multiplied)
        }
    }
}

public extension Vector where T: AlgebraicField, T.Magnitude: FloatingPoint {
    @inlinable @inline(__always)
    func isApproximatelyEqual( to other: Self, absoluteTolerance: T.Magnitude, relativeTolerance: T.Magnitude = 0) -> Bool {
        if count != other.count { return false }
        for i in 0..<count {
            if !components[i].isApproximatelyEqual(to: other[i], absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance, norm: \.magnitude) { return false }
        }
        return true
    }
}
