//
//  Vector+Double.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import BLAS

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
    mutating func copyComponents(from other: Self) {
        precondition(count == other.count)
        if let dcopy = BLAS.dcopy {
            let N = cblas_int(count)
            dcopy(N, other.components, 1, &components, 1)
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
