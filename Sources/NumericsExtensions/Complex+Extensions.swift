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

public extension Complex {
    /// 1 - exp(-z), computed in such a way as to maintain accuracy for small x.
    @inlinable
    static func oneMinusExpMinus(_ z: Complex) -> Complex {
        // 1 - exp(-(x + iy))
        //   = 1 - exp(-x) cos(y) + i exp(-x) sin(y)
        //
        // The real part is the delicate part when x and y are small:
        //
        //     1 - exp(-x) cos(y)
        //       = 1 - exp(-x) + exp(-x)(1 - cos(y))
        //       = -expm1(-x) + exp(-x) * 2 sin²(y/2).
        //
        // This avoids cancellation in both 1 - exp(-x) and 1 - cos(y).

        guard z.real.isFinite && z.imaginary.isFinite else {
            return Complex(.nan, .nan)
        }

        let x = z.real
        let y = z.imaginary

        let expMinusX: RealType = .exp(-x)
        let sinHalfY: RealType = .sin(y / 2)

        let real =
            -RealType.expMinusOne(-x)
            + expMinusX * 2 * sinHalfY * sinHalfY

        let imaginary =
            expMinusX * .sin(y)

        return Complex(real, imaginary)
    }
    
    /// (1 - exp(-z)) / z, computed in such a way as to maintain accuracy for small z.
    @inlinable
    static func phiOneMinusExpMinus(_ z: Complex) -> Complex {
        // phi(z) = (1 - exp(-z)) / z
        //
        // Directly evaluating
        //
        //     (1 - exp(-z)) / z
        //
        // is numerically delicate near z = 0 because both numerator and
        // denominator vanish. The removable singularity has value 1, so near
        // zero we use the Taylor expansion:
        //
        //     (1 - exp(-z)) / z
        //       = 1 - z/2 + z^2/6 - z^3/24 + z^4/120 - ...
        //
        // Away from zero, we compute 1 - exp(-z) using the stable expm1
        // and divide by z.

        guard z.real.isFinite && z.imaginary.isFinite else {
            return Complex(.nan, .nan)
        }

        let absZ = z.length

        // The threshold is deliberately conservative. For |z| ~ 1e-4, the
        // first omitted term after z^6 is ~1e-32, far below Double precision.
        let threshold: RealType = (Self.one / 10000).real
        if absZ < threshold {
            let z2 = z * z
            let z3 = z2 * z
            let z4 = z2 * z2
            let z5 = z4 * z
            let z6 = z3 * z3
            var result = Self.one
            result -= z/2
            result += z2/6
            result -= z3/24
            result += z4/120
            result -= z5/720
            result += z6/5040
            return result
        }

        return Self.oneMinusExpMinus(z) / z
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
