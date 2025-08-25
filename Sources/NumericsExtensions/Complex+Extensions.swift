//
//  ComplexExtensions.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 29.4.2025.
//

import Numerics
import CMath

public extension Complex {
    @inlinable
    @_transparent
    static func +(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs + rhs.real, rhs.imaginary)
    }
    
    @inlinable
    @_transparent
    static func +(lhs: Self, rhs: RealType) -> Self {
        rhs + lhs
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: RealType) {
        lhs.real += rhs
    }
    
    @inlinable
    @_transparent
    static func -(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs - rhs.real, -rhs.imaginary)
    }
    
    @inlinable
    @_transparent
    static func -(lhs: Self, rhs: RealType) -> Self {
        Complex(lhs.real - rhs, lhs.imaginary)
    }
    
    @inlinable
    @_transparent
    static func -=(lhs: inout Self, rhs: RealType) {
        lhs.real -= rhs
    }
    
    @inlinable
    @_transparent
    static func *(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs * rhs.real, lhs * rhs.imaginary)
    }
    
    @inlinable
    @_transparent
    static func *(lhs: Self, rhs: RealType) -> Self {
        rhs * lhs
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: RealType) {
        lhs.real *= rhs
        lhs.imaginary *= rhs
    }
    
    @inlinable
    @_transparent
    static func /(lhs: Self, rhs: RealType) -> Self {
        Complex(lhs.real / rhs, lhs.imaginary / rhs)
    }
    
    @inlinable
    @_transparent
    static func /(rhs: RealType, lhs: Self) -> Self {
        let lengthSquared = lhs.lengthSquared
        return Complex(rhs * lhs.real / lengthSquared, -rhs * lhs.imaginary / lengthSquared)
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: RealType) {
        lhs.real /= rhs
        lhs.imaginary /= rhs
    }
}

//MARK: Special functions
public extension Complex<Double> {
    @inlinable
    @_transparent
    static func faddeeva_w(_ z: Self, relativeError: Double = 0.000001) -> Self {
        let wrapped = Faddeeva_w_shim(z.real, z.imaginary, relativeError)
        return Complex(wrapped.real, wrapped.imaginary)
    }

    @inlinable
    @_transparent
    static func erfcx(_ z: Self, relativeError: Double = 0.000001) -> Self {
        let wrapped = Faddeeva_erfc_shim(z.real, z.imaginary, relativeError)
        return Complex(wrapped.real, wrapped.imaginary)
    }

    @inlinable
    @_transparent
    static func erf(_ z: Self, relativeError: Double = 0.000001) -> Self {
        let wrapped = Faddeeva_erf_shim(z.real, z.imaginary, relativeError)
        return Complex(wrapped.real, wrapped.imaginary)
    }

    @inlinable
    @_transparent
    static func erfi(_ z: Self, relativeError: Double = 0.000001) -> Self {
        let wrapped = Faddeeva_erfi_shim(z.real, z.imaginary, relativeError)
        return Complex(wrapped.real, wrapped.imaginary)
    }

    @inlinable
    @_transparent
    static func erfc(_ z: Self, relativeError: Double = 0.000001) -> Self {
        let wrapped = Faddeeva_erfc_shim(z.real, z.imaginary, relativeError)
        return Complex(wrapped.real, wrapped.imaginary)
    }

    @inlinable
    @_transparent
    static func dawson(_ z: Self, relativeError: Double = 0.0000001) -> Self {
        let wrapped = Faddeeva_Dawson_shim(z.real, z.imaginary, relativeError)
        return Complex(wrapped.real, wrapped.imaginary)
    }
}

public extension Complex<Float> {
    @inlinable
    @_transparent
    static func faddeeva_w(_ z: Self, relativeError: Float = 0.000001) -> Self {
        let wrapped = Faddeeva_w_shim(Double(z.real), Double(z.imaginary), Double(relativeError))
        return Complex(Float(wrapped.real), Float(wrapped.imaginary))
    }

    @inlinable
    @_transparent
    static func erfcx(_ z: Self, relativeError: Float = 0.000001) -> Self {
        let wrapped = Faddeeva_erfc_shim(Double(z.real), Double(z.imaginary), Double(relativeError))
        return Complex(Float(wrapped.real), Float(wrapped.imaginary))
    }

    @inlinable
    @_transparent
    static func erf(_ z: Self, relativeError: Float = 0.000001) -> Self {
        let wrapped = Faddeeva_erf_shim(Double(z.real), Double(z.imaginary), Double(relativeError))
        return Complex(Float(wrapped.real), Float(wrapped.imaginary))
    }

    @inlinable
    @_transparent
    static func erfi(_ z: Self, relativeError: Float = 0.000001) -> Self {
        let wrapped = Faddeeva_erfi_shim(Double(z.real), Double(z.imaginary), Double(relativeError))
        return Complex(Float(wrapped.real), Float(wrapped.imaginary))
    }

    @inlinable
    @_transparent
    static func erfc(_ z: Self, relativeError: Float = 0.000001) -> Self {
        let wrapped = Faddeeva_erfc_shim(Double(z.real), Double(z.imaginary), Double(relativeError))
        return Complex(Float(wrapped.real), Float(wrapped.imaginary))
    }

    @inlinable
    @_transparent
    static func dawson(_ z: Self, relativeError: Float = 0.0000001) -> Self {
        let wrapped = Faddeeva_Dawson_shim(Double(z.real), Double(z.imaginary), Double(relativeError))
        return Complex(Float(wrapped.real), Float(wrapped.imaginary))
    }
}

public extension Relaxed {
    @inlinable
    @_transparent
    static func sum<T: Real>(_ a: Complex<T>, _ b: T) -> Complex<T> {
        Complex(Relaxed.sum(a.real, b), a.imaginary)
    }
    
    @inlinable
    @_transparent
    static func sum<T: Real>(_ a: T, _ b: Complex<T>) -> Complex<T> {
        Complex(Relaxed.sum(b.real, a), b.imaginary)
    }
    
    @inlinable
    @_transparent
    static func product<T: Real>(_ a: T, _ b: Complex<T>) -> Complex<T> {
        Complex(Relaxed.product(a, b.real), Relaxed.product(a, b.imaginary))
    }
    
    @inlinable
    @_transparent
    static func product<T: Real>(_ a: Complex<T>, _ b: T) -> Complex<T> {
        Complex(Relaxed.product(a.real, b), Relaxed.product(a.imaginary, b))
    }
    
    @inlinable
    @_transparent
    static func multiplyAdd<T: Real>(
      _ a: Complex<T>, _ b: Complex<T>, _ c: T
    ) -> Complex<T> {
        Relaxed.sum(c, Relaxed.product(a, b))
    }
    
    @inlinable
    @_transparent
    static func multiplyAdd<T: Real>(
      _ a: Complex<T>, _ b: T, _ c: Complex<T>
    ) -> Complex<T> {
        Relaxed.sum(c, Relaxed.product(a, b))
    }
    
    @inlinable
    @_transparent
    static func multiplyAdd<T: Real>(
      _ a: Complex<T>, _ b: T, _ c: T
    ) -> Complex<T> {
        Relaxed.sum(c, Relaxed.product(a, b))
    }
    
    @inlinable
    @_transparent
    static func multiplyAdd<T: Real>(
      _ a: T, _ b: Complex<T>, _ c: Complex<T>
    ) -> Complex<T> {
        Relaxed.sum(c, Relaxed.product(a, b))
    }
    
    @inlinable
    @_transparent
    static func multiplyAdd<T: Real>(
      _ a: T, _ b: Complex<T>, _ c: T
    ) -> Complex<T> {
        Relaxed.sum(c, Relaxed.product(a, b))
    }
    
    @inlinable
    @_transparent
    static func multiplyAdd<T: Real>(
      _ a: T, _ b: T, _ c: Complex<T>
    ) -> Complex<T> {
        Relaxed.sum(c, Relaxed.product(a, b))
    }
}
