//
//  Vector+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

import NumericsExtensions

//MARK: Scaling for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    mutating func _multiply(by: T) {
        for i in 0..<components.count {
            components[i] = Relaxed.product(components[i], by)
        }
    }

    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }

    @inlinable
    func _multiply(by: T, into: inout Self) {
        for i in 0..<components.count {
            into[i] = Relaxed.product(components[i], by)
        }
    }
}

//MARK: Scaling for Double
public extension Vector<Double> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(count)
        cblas_dscal(N, by, &components, 1)
        #else
        _multiply(by: by)
        #endif
    }
}

//MARK: Scaling for Float
public extension Vector<Float> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(count)
        cblas_sscal(N, by, &components, 1)
        #else
        _multiply(by: by)
        #endif
    }
}

//MARK: Scaling for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    
    @inlinable
    static func *(lhs: Double, rhs: Self) -> Self {
        var result = Vector(Array(rhs.components))
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        withUnsafePointer(to: by) { alpha in
            cblas_zscal(N, alpha, &components, 1)
        }
        #elseif canImport(Accelerate)
        let N = blasint(count)
        withUnsafePointer(to: by) { alpha in
            components.withUnsafeMutableBufferPointer { components in 
                cblas_zscal(N, .init(alpha), .init(components.baseAddress), 1)
            }
        }
        #else
        _multiply(by: by)
        #endif
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        cblas_zdscal(N, by, &components, 1)
        #elseif canImport(Accelerate)
        let N = blasint(count)
        components.withUnsafeBufferPointer { components in 
            cblas_zdscal(N, by, .init(components.baseAddress), 1)
        }
        #else
        for i in 0..<components.count {
            components[i] = Relaxed.product(components[i], by)
        }
        #endif
    }
}

//MARK: Scaling for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    static func *(lhs: Float, rhs: Self) -> Self {
        var result = Vector(Array(rhs.components))
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        withUnsafePointer(to: by) { alpha in
            cblas_cscal(N, alpha, &components, 1)
        }
        #elseif canImport(Accelerate)
        let N = blasint(count)
        withUnsafePointer(to: by) { alpha in
            components.withUnsafeMutableBufferPointer { components in 
                cblas_cscal(N, .init(alpha), .init(components.baseAddress), 1)
            }
        }
        #else
        _multiply(by: by)
        #endif
    }
    
    @inlinable
    mutating func multiply(by: Float) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        cblas_csscal(N, by, &components, 1)
        #elseif canImport(Accelerate)
        let N = blasint(count)
        components.withUnsafeBufferPointer { components in 
            cblas_csscal(N, by, .init(components.baseAddress), 1)
        }
        #else
        for i in 0..<count {
            components[i] = Relaxed.product(components[i], by)
        }
        #endif
    }
}
