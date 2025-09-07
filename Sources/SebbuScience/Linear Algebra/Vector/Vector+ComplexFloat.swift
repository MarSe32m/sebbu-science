//
//  Vector+ComplexFloat.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule
import ComplexModule
import SebbuCollections
import NumericsExtensions

public extension Vector<Complex<Float>> {
    @inlinable
    var norm: Float {
        normSquared.squareRoot()
    }
    
    @inlinable
    var normSquared: Float {
        self.inner(self).real
    }
    
    @inlinable
    var conjugate: Self { Vector(components.map { $0.conjugate }) }
    
    @inlinable
    mutating func copyComponents(from other: Self) {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            BLAS.ccopy(count, other.components, 1, &components, 1)
        } else {
            var span = components.mutableSpan
            let otherSpan = other.components.span
            for i in span.indices {
                span[unchecked: i] = otherSpan[unchecked: i]
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
}
