//
//  Double+SpecialFunctions.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//
import CMath
import RealModule

public extension Double {
    @inlinable
    @_transparent
    static func coth(_ x: Self) -> Self {
        if x == .infinity || x >= 50 { return 1.0 }
        if x == .zero { return .infinity }
        return .cosh(x) / .sinh(x)
    }
    
    @inlinable
    @_transparent
    static func faddeeva_w_imaginary(_ x: Self) -> Self {
        Faddeeva_w_im(x)
    }

    @inlinable
    @_transparent
    /// Computes erfcx(x) = exp(x^2) erfc(x)
    static func erfcx(_ x: Self) -> Self {
        Faddeeva_erfcx_re(x)
    }

    @inlinable
    @_transparent
    /// Computes erfi(x) = -i erf(ix)
    static func erfi(_ x: Self) -> Self {
        Faddeeva_erfi_re(x)
    }

    @inlinable
    @_transparent
    /// Computes the Dawson integral Dawson(x) = sqrt(pi)/2  *  exp(-x^2) * erfi(x)
    static func dawson(_ x: Self) -> Self {
        Faddeeva_Dawson_re(x)
    }

    @inlinable
    @_transparent
    static func ei(_ x: Self) -> Self {
        CMath.ei(x)
    }
        
    @inlinable
    @_transparent
    /// Computes the hyperbolic sine and cosine integrals
    static func shichi(_ x: Self) -> (shi: Self, chi: Self) {
        var _shi: Double = 0
        var _chi: Double = 0
        let result = CMath.shichi(x, &_shi, &_chi)
        assert(result == 0)
        return (_shi, _chi)
    }

    @inlinable
    @_transparent
    /// Computes the hyperbolic sine integral
    static func shi(_ x: Self) -> Self {
        shichi(x).shi
    }

    @inlinable
    @_transparent
    /// Computes the hyperbolic cosine integral
    static func chi(_ x: Self) -> Self {
        shichi(x).chi
    }
    
    @inlinable
    @_transparent
    /// Computes the sine and cosine integrals
    static func sici(_ x: Self) -> (si: Self, ci: Self) {
        var _si: Double = 0
        var _ci: Double = 0
        let result = CMath.sici(x, &_si, &_ci)
        assert(result == 0)
        return (_si, _ci)
    }

    @inlinable
    @_transparent
    /// Computes the sine integral
    static func si(_ x: Self) -> Self {
        sici(x).si
    }

    @inlinable
    @_transparent
    /// Computes the cosine integral
    static func ci(_ x: Self) -> Self {
        sici(x).ci
    }
}
