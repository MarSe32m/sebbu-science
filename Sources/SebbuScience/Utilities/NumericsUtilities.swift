import Numerics

public extension Complex {
    @inline(__always)
    @inlinable
    @_transparent
    static func +(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs + rhs.real, rhs.imaginary)
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func +(lhs: Self, rhs: RealType) -> Self {
        rhs + lhs
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func -(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs - rhs.real, -rhs.imaginary)
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func -(lhs: Self, rhs: RealType) -> Self {
        Complex(lhs.real - rhs, lhs.imaginary)
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func *(lhs: RealType, rhs: Self) -> Self {
        Complex(lhs * rhs.real, lhs * rhs.imaginary)
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func *(lhs: Self, rhs: RealType) -> Self {
        rhs * lhs
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: RealType) {
        lhs.real *= rhs
        lhs.imaginary *= rhs
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func /(lhs: Self, rhs: RealType) -> Self {
        Complex(lhs.real / rhs, lhs.imaginary / rhs)
    }

    @inline(__always)
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: RealType) {
        lhs.real /= rhs
        lhs.imaginary /= rhs
    }
}