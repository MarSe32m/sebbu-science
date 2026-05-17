//
//  Vector+Float.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule

public extension Vector<Float> {
    @inlinable
    var norm: Float {
        normSquared.squareRoot()
    }
    
    @inlinable
    var normSquared: Float {
        self.inner(self)
    }
    
    @inlinable
    mutating func copyComponents(from other: Self) {
        var span = components.mutableSpan
        let otherSpan = other.components.span
        for i in span.indices {
            span[unchecked: i] = otherSpan[unchecked: i]
        }
    }

    @inlinable
    mutating func copyComponents(from other: Self, adding: Self, multiplied: Float) {
        var mutableSpan = components.mutableSpan
        let otherSpan = other.components.span
        let addingSpan = adding.components.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, addingSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
    
    @inlinable
    mutating func copyComponents(from other: Self, multiplied: Float) {
        var mutableSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.product(otherSpan[unchecked: i], multiplied)
        }
    }

    @inlinable
    @_transparent
    mutating func copyComponentsBLAS(from other: Self) {
        BLAS.scopy(count, other.components, 1, &components, 1)
    }
    
    @inlinable
    @_transparent
    mutating func zeroComponents() {
        var span = components.mutableSpan
        for i in span.indices {
            span[unchecked: i] = .zero
        }
    }
}
