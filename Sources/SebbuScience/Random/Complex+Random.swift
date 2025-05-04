//
//  Complex+Random.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics

public extension Complex where RealType: BinaryFloatingPoint, RealType.RawSignificand: FixedWidthInteger {
    @inlinable
    static func random<T>(realIn: Range<RealType>, imaginaryIn: Range<RealType>, using: inout T) -> Self where T: RandomNumberGenerator {
        return Complex(.random(in: realIn, using: &using), .random(in: realIn, using: &using))
    }

    @inlinable
    static func random<T>(count: Int, realIn: Range<RealType>, imaginaryIn: Range<RealType>, using: inout T) -> [Self] where T: RandomNumberGenerator {
        var result: [Self] = []
        result.reserveCapacity(count)
        let nextReals = RealType.random(count: count, in: realIn, using: &using)
        let nextImaginaries = RealType.random(count: count, in: imaginaryIn, using: &using)
        for i in 0..<count {
            result.append(Complex(nextReals[i], nextImaginaries[i]))
        }
        return result
    }

    @inlinable
    static func random(realIn: Range<RealType>, imaginaryIn: Range<RealType>) -> Self {
        var generator = SystemRandomNumberGenerator()
        return random(realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random(count: Int, realIn: Range<RealType>, imaginaryIn: Range<RealType>) -> [Self] {
        var generator = SystemRandomNumberGenerator()
        return random(count: count, realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random<T>(realIn: ClosedRange<RealType>, imaginaryIn: Range<RealType>, using: inout T) -> Self where T: RandomNumberGenerator {
        return Complex(.random(in: realIn, using: &using), .random(in: realIn, using: &using))
    }

    @inlinable
    static func random<T>(count: Int, realIn: ClosedRange<RealType>, imaginaryIn: Range<RealType>, using: inout T) -> [Self] where T: RandomNumberGenerator {
        var result: [Self] = []
        result.reserveCapacity(count)
        let nextReals = RealType.random(count: count, in: realIn, using: &using)
        let nextImaginaries = RealType.random(count: count, in: imaginaryIn, using: &using)
        for i in 0..<count {
            result.append(Complex(nextReals[i], nextImaginaries[i]))
        }
        return result
    }

    @inlinable
    static func random(realIn: ClosedRange<RealType>, imaginaryIn: Range<RealType>) -> Self {
        var generator = SystemRandomNumberGenerator()
        return random(realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random(count:Int, realIn: ClosedRange<RealType>, imaginaryIn: Range<RealType>) -> [Self] {
        var generator = SystemRandomNumberGenerator()
        return random(count: count, realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random<T>(realIn: Range<RealType>, imaginaryIn: ClosedRange<RealType>, using: inout T) -> Self where T: RandomNumberGenerator {
        return Complex(.random(in: realIn, using: &using), .random(in: realIn, using: &using))
    }

    @inlinable
    static func random<T>(count: Int, realIn: Range<RealType>, imaginaryIn: ClosedRange<RealType>, using: inout T) -> [Self] where T: RandomNumberGenerator {
        var result: [Self] = []
        result.reserveCapacity(count)
        let nextReals = RealType.random(count: count, in: realIn, using: &using)
        let nextImaginaries = RealType.random(count: count, in: imaginaryIn, using: &using)
        for i in 0..<count {
            result.append(Complex(nextReals[i], nextImaginaries[i]))
        }
        return result
    }

    @inlinable
    static func random(realIn: Range<RealType>, imaginaryIn: ClosedRange<RealType>) -> Self {
        var generator = SystemRandomNumberGenerator()
        return .random(realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random(count: Int, realIn: Range<RealType>, imaginaryIn: ClosedRange<RealType>) -> [Self] {
        var generator = SystemRandomNumberGenerator()
        return random(count: count, realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random<T>(realIn: ClosedRange<RealType>, imaginaryIn: ClosedRange<RealType>, using: inout T) -> Self where T: RandomNumberGenerator {
        return Complex(.random(in: realIn, using: &using), .random(in: realIn, using: &using))
    }

    @inlinable
    static func random<T>(count: Int, realIn: ClosedRange<RealType>, imaginaryIn: ClosedRange<RealType>, using: inout T) -> [Self] where T: RandomNumberGenerator {
        var result: [Self] = []
        result.reserveCapacity(count)
        let nextReals = RealType.random(count: count, in: realIn, using: &using)
        let nextImaginaries = RealType.random(count: count, in: imaginaryIn, using: &using)
        for i in 0..<count {
            result.append(Complex(nextReals[i], nextImaginaries[i]))
        }
        return result
    }

    @inlinable
    static func random(realIn: ClosedRange<RealType>, imaginaryIn: ClosedRange<RealType>) -> Self {
        var generator = SystemRandomNumberGenerator()
        return random(realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random(count:Int, realIn: ClosedRange<RealType>, imaginaryIn: ClosedRange<RealType>) -> [Self] {
        var generator = SystemRandomNumberGenerator()
        return random(count: count, realIn: realIn, imaginaryIn: imaginaryIn, using: &generator)
    }

    @inlinable
    static func random<T>(in range: Range<RealType>, using: inout T) -> Self where T: RandomNumberGenerator {
        return Complex(.random(in: range, using: &using), .random(in: range, using: &using))
    }

    @inlinable
    static func random<T>(count: Int, in range: Range<RealType>, using: inout T) -> [Self] where T: RandomNumberGenerator {
        var result: [Self] = []
        result.reserveCapacity(count)
        let nextReals = RealType.random(count: count, in: range, using: &using)
        let nextImaginaries = RealType.random(count: count, in: range, using: &using)
        for i in 0..<count {
            result.append(Complex(nextReals[i], nextImaginaries[i]))
        }
        return result
    }

    @inlinable
    static func random(in range: Range<RealType>) -> Self {
        var generator = SystemRandomNumberGenerator()
        return random(realIn: range, imaginaryIn: range, using: &generator)
    }

    @inlinable
    static func random(count: Int, in range: Range<RealType>) -> [Self] {
        var generator = SystemRandomNumberGenerator()
        return random(count: count, realIn: range, imaginaryIn: range, using: &generator)
    }

    @inlinable
    static func random<T>(in range: ClosedRange<RealType>, using: inout T) -> Self where T: RandomNumberGenerator {
        return Complex(.random(in: range, using: &using), .random(in: range, using: &using))
    }

    @inlinable
    static func random<T>(count: Int, in range: ClosedRange<RealType>, using: inout T) -> [Self] where T: RandomNumberGenerator {
        var result: [Self] = []
        result.reserveCapacity(count)
        let nextReals = RealType.random(count: count, in: range, using: &using)
        let nextImaginaries = RealType.random(count: count, in: range, using: &using)
        for i in 0..<count {
            result.append(Complex(nextReals[i], nextImaginaries[i]))
        }
        return result
    }

    @inlinable
    static func random(in range: ClosedRange<RealType>) -> Self {
        var generator = SystemRandomNumberGenerator()
        return random(realIn: range, imaginaryIn: range, using: &generator)
    }

    @inlinable
    static func random(count: Int, in range: ClosedRange<RealType>) -> [Self] {
        var generator = SystemRandomNumberGenerator()
        return random(count: count, realIn: range, imaginaryIn: range, using: &generator)
    }
}
