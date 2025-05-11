//
//  Vector+ComplexFloat.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//
import BLAS

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
        if let ccopy = BLAS.ccopy {
            let N = cblas_int(count)
            ccopy(N, other.components, 1, &components, 1)
        } else {
            for i in 0..<count {
                components[i] = other.components[i]
            }
        }
    }
    
    @inlinable
    mutating func zeroComponents() {
        for i in 0..<components.count {
            components[i] = .zero
        }
    }
}
