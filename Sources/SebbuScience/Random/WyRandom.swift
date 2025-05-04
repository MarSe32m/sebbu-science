//
//  WyRandom.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

/// Wyrand from https://github.com/lemire/testingRNG/blob/master/source/wyrand.h
public struct WyRandomNumberGenerator: RandomNumberGenerator {
    @usableFromInline
    internal var state: UInt64

    public init(seed: UInt64) {
        state = seed
    }

    public mutating func next() -> UInt64 {
        state &+= 0xa0761d6478bd642f
        let t = UInt128(state) &* UInt128(state ^ 0xe7037ed1a0b428db)
        return UInt64((t >> 64) ^ t)
    }
}
