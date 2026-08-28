// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

public extension RandomNumberGenerator {
    /// Uniform random Double in [0, 1), using 53 random bits.
    @inlinable
    @inline(always)
    mutating func nextUnitDouble() -> Double {
        Double(next() >> 11) * 0x1.0p-53
    }

    /// Uniform random Double in open range (0, 1), using 53 random bits.
    @inlinable
    @inline(always)
    mutating func nextUnitDoubleOpen() -> Double {
        (Double(next() >> 11) + 0.5) * 0x1.0p-53
    }

    /// Uniform random Double in [-1, 1).
    @inlinable
    mutating func nextSignedUnitDouble() -> Double {
        Double(next() >> 11) * 0x1.0p-52 - 1.0
    }
}