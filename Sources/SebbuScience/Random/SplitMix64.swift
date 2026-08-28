// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// SplitMix64 (Steele, Lea & Flood, *"Fast Splittable Pseudorandom Number Generators,"* OOPSLA 2014)
/// 
/// A small, fast 64-bit seedable PRNG that is also particularly useful for expanding
/// a single 64-bit seed into the larger state required by other generators.
/// 
/// Period: 2^64
public struct SplitMix64: RandomNumberGenerator, Sendable {
    @usableFromInline
    internal var state: UInt64

    @inlinable
    public init(seed: UInt64) {
        self.state = seed
    }

    @inlinable
    public mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        return mix(state)
    }

    @inlinable
    @inline(always)
    internal func mix(_ input: UInt64) -> UInt64 {
        var value = input
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
}