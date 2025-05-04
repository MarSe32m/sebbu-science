//
//  BinaryFloatingPointer+Random.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import SebbuCollections

public extension BinaryFloatingPoint where Self.RawSignificand: FixedWidthInteger {
    @inlinable
    static func random<T: RandomNumberGenerator>(
        count: Int,
        in range: Range<Self>,
        using generator: inout T
    ) -> [Self] {
        precondition(!range.isEmpty, "Can't get random values with an empty range")
        let delta = range.upperBound - range.lowerBound
        precondition(delta.isFinite, "There is no uniform distribution on an infinite range")

        let rands: [Self.RawSignificand]
        if Self.RawSignificand.bitWidth == Self.significandBitCount + 1 {
            rands = generator.next(count: count)
        } else {
            let significandCount = Self.significandBitCount + 1
            let maxSignificand: Self.RawSignificand = 1 << significandCount
            rands = generator.next(count: count).map { $0 & (maxSignificand - 1) }
        }
        return rands.betterMap { rand in
            let unitRandom = Self.init(rand) * (Self.ulpOfOne / 2)
            let randFloat = delta * unitRandom + range.lowerBound
            if randFloat == range.upperBound {
                return Self.random(in: range, using: &generator)
            }
            return randFloat
        }
    }


    @inlinable
    static func random(count: Int, in range: Range<Self>) -> [Self] {
        var g = SystemRandomNumberGenerator()
        return Self.random(count: count, in: range, using: &g)
    }
    
    @inlinable
    static func random<T: RandomNumberGenerator>(
        count: Int,
        in range: ClosedRange<Self>,
        using generator: inout T
    ) -> [Self] {
        precondition(!range.isEmpty, "Can't get random value with an empty range")
        let delta = range.upperBound - range.lowerBound
        precondition(delta.isFinite, "There is no uniform distribution on an infinite range")
        if Self.RawSignificand.bitWidth == Self.significandBitCount + 1 {
            let tmps: [UInt8] = generator.next(count: count)
            return generator.next(count: count).enumerated().map { index, rand in
                let tmp: UInt8 = tmps[index] & 1
                if rand == Self.RawSignificand.max && tmp == 1 {
                    return range.upperBound
                }
                let unitRandom = Self.init(rand) * (Self.ulpOfOne / 2)
                let randFloat = delta * unitRandom + range.lowerBound
                return randFloat
            }
        } else {
            let significandCount = Self.significandBitCount + 1
            let maxSignificand: Self.RawSignificand = 1 << significandCount
            return generator.next(count: count, upperBound: maxSignificand + 1).betterMap { rand in
                if rand == maxSignificand { return range.upperBound }
                let unitRandom = Self.init(rand) * (Self.ulpOfOne / 2)
                let randFloat = delta * unitRandom + range.lowerBound
                return randFloat
            }
        }
    }
    
    @inlinable
    static func random(count: Int, in range: ClosedRange<Self>) -> [Self] {
        var g = SystemRandomNumberGenerator()
        return Self.random(count: count, in: range, using: &g)
    }
}
