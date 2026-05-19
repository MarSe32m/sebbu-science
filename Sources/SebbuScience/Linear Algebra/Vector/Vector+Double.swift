//
//  Vector+Double.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule

public extension Vector<Double> {
    @inlinable
    var norm: Double {
        normSquared.squareRoot()
    }
    
    @inlinable
    var normSquared: Double {
        self.inner(self)
    }
    
    @inlinable
    func distanceSquared(to other: Self) -> Double {
        assert(count == other.count, "The vectors must have the same size")
        let span = components.span
        let otherSpan = other.components.span
        var result: Double = .zero
        for i in 0..<count {
            let diff = Relaxed.sum(span[unchecked: i], -otherSpan[unchecked: i])
            result = Relaxed.sum(Relaxed.product(diff, diff), result)
        }
        return result
    }
    
    @inlinable
    @inline(always)
    func distance(to other: Self) -> Double {
        distanceSquared(to: other).squareRoot()
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
    mutating func copyComponents(from other: Self, adding: Self, multiplied: Double) {
        var mutableSpan = components.mutableSpan
        let otherSpan = other.components.span
        let addingSpan = adding.components.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, addingSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
    
    @inlinable
    mutating func copyComponents(from other: Self, multiplied: Double) {
        var mutableSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in mutableSpan.indices {
            mutableSpan[unchecked: i] = Relaxed.product(otherSpan[unchecked: i], multiplied)
        }
    }

    @inlinable
    @_transparent
    mutating func copyComponentsBLAS(from other: Self) {
        BLAS.dcopy(count, other.components, 1, &components, 1)
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
