//
//  ComplexExtensions.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 29.4.2025.
//

import Numerics

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
    static func /=(lhs: inout Self, rhs: RealType) {
        lhs.real /= rhs
        lhs.imaginary /= rhs
    }
}

