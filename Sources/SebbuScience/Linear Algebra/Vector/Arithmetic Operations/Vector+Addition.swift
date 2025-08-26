//
//  Vector+Addition.swift
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

//MARK: Addition for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: T) {
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    mutating func _add(_ other: Self, multiplied: T) {
        precondition(other.components.count == self.components.count)
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        var i = 0
        while i &+ 4 <= componentSpan.count {
            componentSpan[i] = Relaxed.multiplyAdd(multiplied, otherSpan[i], componentSpan[i])
            componentSpan[unchecked: i &+ 1] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i &+ 1], componentSpan[unchecked: i &+ 1])
            componentSpan[unchecked: i &+ 2] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i &+ 2], componentSpan[unchecked: i &+ 2])
            componentSpan[unchecked: i &+ 3] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i &+ 3], componentSpan[unchecked: i &+ 3])
            i &+= 4
            
        }
        while i < componentSpan.count {
            componentSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], componentSpan[unchecked: i])
            i &+= 1
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        precondition(other.components.count == self.components.count)
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        var i = 0
        while i &+ 4 <= componentSpan.count {
            componentSpan[unchecked: i] = Relaxed.sum(componentSpan[unchecked: i], otherSpan[unchecked: i])
            componentSpan[unchecked: i &+ 1] = Relaxed.sum(componentSpan[unchecked: i &+ 1], otherSpan[unchecked: i &+ 1])
            componentSpan[unchecked: i &+ 2] = Relaxed.sum(componentSpan[unchecked: i &+ 2], otherSpan[unchecked: i &+ 2])
            componentSpan[unchecked: i &+ 3] = Relaxed.sum(componentSpan[unchecked: i &+ 3], otherSpan[unchecked: i &+ 3])
            i &+= 4
        }
        while i < componentSpan.count {
            componentSpan[unchecked: i] = Relaxed.sum(componentSpan[unchecked: i], otherSpan[unchecked: i])
            i &+= 1
        }
    }
}

//MARK: Addition for Double
public extension Vector<Double> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        precondition(count == other.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(count)
        cblas_daxpy(N, multiplied, other.components, 1, &components, 1)
        #else
        _add(other, multiplied: multiplied)
        #endif
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: 1.0)
    }
}

//MARK: Addition for Float
public extension Vector<Float> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        precondition(count == other.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(count)
        cblas_saxpy(N, multiplied, other.components, 1, &components, 1)
        #else
        _add(other, multiplied: multiplied)
        #endif
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: 1.0)
    }
}

//MARK: Addition for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        precondition(count == other.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        withUnsafePointer(to: multiplied) { alpha in
            cblas_zaxpy(N, alpha, other.components, 1, &components, 1)
        }
        #elseif canImport(Accelerate)
        let N = blasint(count)
        withUnsafePointer(to: multiplied) { alpha in
            other.components.withUnsafeBufferPointer { otherComponents in 
                components.withUnsafeMutableBufferPointer { components in 
                    cblas_zaxpy(N, .init(alpha), .init(otherComponents.baseAddress), 1, .init(components.baseAddress), 1)
                }
            }
        }
        #else
        _add(other, multiplied: multiplied)
        #endif
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Double) {
        add(other, multiplied: Complex(multiplied))
    }
}

//MARK: Addition for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        precondition(count == other.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(count)
        withUnsafePointer(to: multiplied) { alpha in
            cblas_caxpy(N, alpha, other.components, 1, &components, 1)
        }
        #elseif canImport(Accelerate)
        let N = blasint(count)
        withUnsafePointer(to: multiplied) { alpha in
            other.components.withUnsafeBufferPointer { otherComponents in 
                components.withUnsafeMutableBufferPointer { components in 
                    cblas_caxpy(N, .init(alpha), .init(otherComponents.baseAddress), 1, .init(components.baseAddress), 1)
                }
            }
        }
        #else
        _add(other, multiplied: multiplied)
        #endif
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Float) {
        add(other, multiplied: Complex(multiplied))
    }
}
