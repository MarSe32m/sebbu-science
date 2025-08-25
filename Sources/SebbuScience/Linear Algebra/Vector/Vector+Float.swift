//
//  Vector+Float.swift
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
        precondition(count == other.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        cblas_scopy(N, other.components, 1, &components, 1)
        #elseif canImport(Accelerate)
        #error("TODO: Implement")
        if let scopy = BLAS.scopy {
            let N = cblas_int(count)
            scopy(N, other.components, 1, &components, 1)
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
