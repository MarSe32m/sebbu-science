//
//  FixedWidthInteger+Random Extensions.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import SebbuCollections

extension FixedWidthInteger {
    @inlinable
    public static func random<T: RandomNumberGenerator>(
        count: Int,
        in range: Range<Self>,
        using generator: inout T
    ) -> [Self] {
        precondition(!range.isEmpty, "Can't get random value with an empty range")
        let delta = Magnitude(truncatingIfNeeded: range.upperBound &- range.lowerBound)
        let rands: [Magnitude] = generator.next(count: count, upperBound: delta)
        let lowerBoundMagnitude = Magnitude(truncatingIfNeeded: range.lowerBound)
        return rands.betterMap { rand in
            Self(truncatingIfNeeded: lowerBoundMagnitude &+ rand)
        }
    }
  
    @inlinable
    public static func random(count: Int, in range: Range<Self>) -> [Self] {
        var g = SystemRandomNumberGenerator()
        return Self.random(count: count, in: range, using: &g)
    }

    @inlinable
    public static func random<T: RandomNumberGenerator>(
        count: Int,
        in range: ClosedRange<Self>,
        using generator: inout T
    ) -> [Self] {
        var delta = Magnitude(truncatingIfNeeded: range.upperBound &- range.lowerBound)
        if delta == Magnitude.max {
            return (generator.next(count: count) as [Magnitude]).map { Self(truncatingIfNeeded: $0) }
        }
        delta += 1
        let lowerBoundMagnitude = Magnitude(truncatingIfNeeded: range.lowerBound)
        return (generator.next(count: count, upperBound: delta) as [Magnitude]).map { rand in
            Self(truncatingIfNeeded: lowerBoundMagnitude &+ rand)
        }
    }
  
    @inlinable
    public static func random(count: Int, in range: ClosedRange<Self>) -> [Self] {
        var g = SystemRandomNumberGenerator()
        return Self.random(count: count, in: range, using: &g)
    }
}
