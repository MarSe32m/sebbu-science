//
//  Vector+ComplexFloat.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//
#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        cblas_ccopy(N, other.components, 1, &components, 1)
        #elseif canImport(Accelerate)
        let N = blasint(count)
        other.components.withUnsafeBufferPointer { otherComponents in 
            components.withUnsafeMutableBufferPointer { components in 
                cblas_ccopy(N, .init(otherComponents.baseAddress), 1, .init(components.baseAddress), 1)
            }
        }
        #else
        for i in 0..<count {
            components[i] = other.components[i]
        }
        #endif
    }
    
    @inlinable
    mutating func zeroComponents() {
        for i in 0..<components.count {
            components[i] = .zero
        }
    }
}
