// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// xoshiro256**
/// 
/// 256-bit-state PRNG by Blackman and Vigna.
/// 
/// Period: 2^256 - 1
/// 
/// The all-zero state is invalid. The `seed:` initializer uses SplitMix64
/// to expand a 64-bit seed into a valid 256-bit state.
public struct Xoshiro256StarStar: RandomNumberGenerator, Sendable {
    @usableFromInline
    internal var state: Xoshiro256State

    @inlinable
    public init(seed: UInt64) {
        var splitMix = SplitMix64(seed: seed)
        var state: [4 of UInt64] = [splitMix.next(), splitMix.next(), splitMix.next(), splitMix.next()]
        // SplitMix64 cannot normally produce four zero outputs in succesion from distinct states,
        // but maintaining the invariant explicitly costs essentially nothing.
        if (state[0] | state[1] | state[2] | state[3]) == 0 {
            state[0] = 1
        }
        self.state = Xoshiro256State(state: state)
    }

    /// Initializes directly from a complete xoshiro state.
    /// 
    /// The four words must not all be zero.
    @inlinable
    public init(state: (UInt64, UInt64, UInt64, UInt64)) {
        precondition(
            (state.0 | state.1 | state.2 | state.3) != 0,
            "The all-zero xoshiro256 state is invalid"
        )
        self.state = Xoshiro256State(state: state)
    }

    /// Initializes directly from a complete xoshiro state.
    /// 
    /// The four words must not all be zero.
    @inlinable
    public init(state: [4 of UInt64]) {
        precondition(
            (state[0] | state[1] | state[2] | state[3]) != 0,
            "The all-zero xoshiro256 state is invalid"
        )
        self.state = Xoshiro256State(state: state)
    }

    @inlinable
    public mutating func next() -> UInt64 {
        let result = Xoshiro256State.rotateLeft(state[1] &* 5, by: 7) &* 9
        state.advance()
        return result
    }

    @inlinable
    @inline(always)
    public mutating func jump() {
        state.jump()
    }

    @inlinable
    @inline(always)
    public mutating func longJump() {
        state.longJump()
    }
}

/// xoshiro256++
/// 
/// 256-bit-state PRNG by Blackman and Vigna.
/// 
/// Period: 2^256 - 1
/// 
/// The all-zero state is invalid. The `seed:` initializer uses SplitMix64
/// to expand a 64-bit seed into a valid 256-bit state.
public struct Xoshiro256PlusPlus: RandomNumberGenerator, Sendable {
    @usableFromInline
    internal var state: Xoshiro256State

    @inlinable
    public init(seed: UInt64) {
        var splitMix = SplitMix64(seed: seed)
        var state: [4 of UInt64] = [splitMix.next(), splitMix.next(), splitMix.next(), splitMix.next()]
        // SplitMix64 cannot normally produce four zero outputs in succesion from distinct states,
        // but maintaining the invariant explicitly costs essentially nothing.
        if (state[0] | state[1] | state[2] | state[3]) == 0 {
            state[0] = 1
        }
        self.state = Xoshiro256State(state: state)
    }

    /// Initializes directly from a complete xoshiro state.
    /// 
    /// The four words must not all be zero.
    @inlinable
    public init(state: (UInt64, UInt64, UInt64, UInt64)) {
        precondition(
            (state.0 | state.1 | state.2 | state.3) != 0,
            "The all-zero xoshiro256 state is invalid"
        )
        self.state = Xoshiro256State(state: state)
    }

    /// Initializes directly from a complete xoshiro state.
    /// 
    /// The four words must not all be zero.
    @inlinable
    public init(state: [4 of UInt64]) {
        precondition(
            (state[0] | state[1] | state[2] | state[3]) != 0,
            "The all-zero xoshiro256 state is invalid"
        )
        self.state = Xoshiro256State(state: state)
    }

    @inlinable
    public mutating func next() -> UInt64 {
        let result = Xoshiro256State.rotateLeft(state[0] &+ state[3], by: 23) &+ state[0]
        state.advance()
        return result
    }

    @inlinable
    @inline(always)
    public mutating func jump() {
        state.jump()
    }

    @inlinable
    @inline(always)
    public mutating func longJump() {
        state.longJump()
    }
}

@usableFromInline
internal struct Xoshiro256State: Sendable {
    @usableFromInline
    internal var state: [4 of UInt64]

    @inlinable
    @inline(always)
    internal subscript(index: Int) -> UInt64 {
        _read { yield state[unchecked: index] }
    }

    /// Initializes directly from a complete xoshiro state.
    /// 
    /// The four words must not all be zero.
    @inlinable
    internal init(state: (UInt64, UInt64, UInt64, UInt64)) {
        precondition(
            (state.0 | state.1 | state.2 | state.3) != 0,
            "The all-zero xoshiro256 state is invalid"
        )
        self.state = [state.0, state.1, state.2, state.3]
    }

    /// Initializes directly from a complete xoshiro state.
    /// 
    /// The four words must not all be zero.
    @inlinable
    internal init(state: [4 of UInt64]) {
        precondition(
            (state[0] | state[1] | state[2] | state[3]) != 0,
            "The all-zero xoshiro256 state is invalid"
        )
        self.state = state
    }

    @inline(always)
    @inlinable
    static internal func rotateLeft(_ value: UInt64, by amount: UInt64) -> UInt64 {
        (value << amount) | (value >> (64 - amount))
    }

    @inline(always)
    @inlinable
    internal mutating func advance() {
        let t = state[1] << 17
        state[2] ^= state[0]
        state[3] ^= state[1]
        state[1] ^= state[2]
        state[0] ^= state[3]
        state[2] ^= t
        state[3] = Self.rotateLeft(state[3], by: 45)
    }

    @inlinable
    @inline(always)
    internal mutating func jump() {
        applyJump(
            0x180EC6D33CFD0ABA,
            0xD5A61266F0C9392C,
            0xA9582618E03FC9AA,
            0x39ABDC4529B1661C
        )
    }

    @inlinable
    @inline(always)
    internal mutating func longJump() {
        applyJump(
            0x76E15D3EFEFDCBBF,
            0xC5004E441C522FB3,
            0x77710069854EE241,
            0x39109BB02ACBE635
        )
    }

    @inlinable
    internal mutating func applyJump(
        _ j0: UInt64,
        _ j1: UInt64,
        _ j2: UInt64,
        _ j3: UInt64
    ) {
        var r0: UInt64 = 0
        var r1: UInt64 = 0
        var r2: UInt64 = 0
        var r3: UInt64 = 0

        // j0
        for bit in 0..<64 {
            if (j0 & (UInt64(1) << bit)) != 0 {
                r0 ^= state[0]
                r1 ^= state[1]
                r2 ^= state[2]
                r3 ^= state[3]
            }
            advance()
        }

        // j1
        for bit in 0..<64 {
            if (j1 & (UInt64(1) << bit)) != 0 {
                r0 ^= state[0]
                r1 ^= state[1]
                r2 ^= state[2]
                r3 ^= state[3]
            }
            advance()
        }

        // j2
        for bit in 0..<64 {
            if (j2 & (UInt64(1) << bit)) != 0 {
                r0 ^= state[0]
                r1 ^= state[1]
                r2 ^= state[2]
                r3 ^= state[3]
            }
            advance()
        }

        // j3
        for bit in 0..<64 {
            if (j3 & (UInt64(1) << bit)) != 0 {
                r0 ^= state[0]
                r1 ^= state[1]
                r2 ^= state[2]
                r3 ^= state[3]
            }
            advance()
        }

        state[0] = r0
        state[1] = r1
        state[2] = r2
        state[3] = r3
    }
}