//
//  Vector+ComplexDouble.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule
import ComplexModule
import SebbuCollections
import NumericsExtensions

public extension Vector<Complex<Double>> {
    @inlinable
    var norm: Double {
        normSquared.squareRoot()
    }
    
    @inlinable
    var normSquared: Double {
        self.inner(self).real
    }
    
    @inlinable
    var conjugate: Self { Vector(components.betterMap { $0.conjugate }) }
    
    @inlinable
    mutating func copyComponents(from other: Self) {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _copyComponentsBLAS(from: other)
        } else {
            _copyComponents(from: other)
        }
    }

    @inlinable
    @_transparent
    mutating func _copyComponents(from other: Self) {
        var span = components.mutableSpan
        let otherSpan = other.components.span
        for i in span.indices {
            span[unchecked: i] = otherSpan[unchecked: i]
        }
    }

    @inlinable
    @_transparent
    mutating func _copyComponentsBLAS(from other: Self) {
        BLAS.zcopy(count, other.components, 1, &components, 1)
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
