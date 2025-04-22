//
//  NumericsUtilities.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.10.2024.
//
import Numerics

public extension Complex {
    
    @inlinable
    static func +(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs + rhs.real, rhs.imaginary)
    }

    
    @inlinable
    static func +(lhs: Self, rhs: RealType) -> Self {
        rhs + lhs
    }

    
    @inlinable
    static func -(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs - rhs.real, -rhs.imaginary)
    }

    
    @inlinable
    static func -(lhs: Self, rhs: RealType) -> Self {
        Complex(lhs.real - rhs, lhs.imaginary)
    }

    
    @inlinable
    static func *(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs * rhs.real, lhs * rhs.imaginary)
    }

    
    @inlinable
    static func *(lhs: Self, rhs: RealType) -> Self {
        rhs * lhs
    }

    
    @inlinable
    static func *=(lhs: inout Self, rhs: RealType) {
        lhs.real *= rhs
        lhs.imaginary *= rhs
    }

    
    @inlinable
    static func /(lhs: Self, rhs: RealType) -> Self {
        Complex(lhs.real / rhs, lhs.imaginary / rhs)
    }

    
    @inlinable
    static func /=(lhs: inout Self, rhs: RealType) {
        lhs.real /= rhs
        lhs.imaginary /= rhs
    }
}

extension Complex: @retroactive ExpressibleByFloatLiteral where RealType: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = RealType.FloatLiteralType
    public init(floatLiteral value: RealType.FloatLiteralType) {
        self = Complex(RealType(floatLiteral: value))
    }
}
