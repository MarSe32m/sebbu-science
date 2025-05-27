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
    
    @inlinable
    public init(seed: UInt64) {
        state = seed
    }
    
    @inlinable
    public mutating func next() -> UInt64 {
        state &+= 0xa0761d6478bd642f
        let mul = state.multipliedFullWidth(by: state ^ 0xe7037ed1a0b428db)
        return mul.high ^ mul.low
    }
}
