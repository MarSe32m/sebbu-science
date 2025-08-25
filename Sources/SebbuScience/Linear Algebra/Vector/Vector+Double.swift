//
//  Vector+Double.swift
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        cblas_dcopy(N, other.components, 1, &components, 1)
        #elseif canImport(Accelerate)
        #error("TODO: Implement")
        if let dcopy = BLAS.dcopy {
            let N = cblas_int(count)
            dcopy(N, other.components, 1, &components, 1)
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
