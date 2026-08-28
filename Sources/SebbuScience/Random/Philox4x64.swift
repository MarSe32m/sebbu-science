// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// Philox4x64-10 counter-based pseudo-random number generator.
/// 
/// The fundamental Philox operation maps a 256-bit counter and
/// 128-bit key to four UInt64 outputs.
/// 
/// This type also conforms to RandomNumberGenerator by treating the
/// counter as a sequential block counter.
/// 
/// Philox is not cryptographically secure.
public struct Philox4x64: RandomNumberGenerator, Sendable {
    @usableFromInline
    internal var counter: Counter
    @usableFromInline
    internal let key: Key

    @usableFromInline
    internal var buffer: [4 of UInt64] = [0, 0, 0, 0]

    @usableFromInline
    internal var bufferIndex: Int = 4

    /// Construct a generator directly from a Philox key and counter.
    @inlinable
    public init(key: Key, counter: Counter = .zero) {
        self.key = key
        self.counter = counter
    }

    /// Construct a generator from a single 64-bit seed.
    /// 
    /// SplitMix64 is used to expand the seed into the
    /// 128-bit Philox key.
    @inlinable
    public init(seed: UInt64, counter: Counter = .zero) {
        var splitMix = SplitMix64(seed: seed)
        self.key = Key(splitMix.next(), splitMix.next())
        self.counter = counter
    }

    @inlinable
    public mutating func next() -> UInt64 {
        if bufferIndex == 4 { refill() }
        defer { bufferIndex &+= 1 }
        return buffer[bufferIndex]
    }

    @inline(always)
    @inlinable
    internal mutating func refill() {
        let newBuffer = Self.generate(counter: counter, key: key)
        buffer[0] = newBuffer.0
        buffer[1] = newBuffer.1
        buffer[2] = newBuffer.2
        buffer[3] = newBuffer.3
        counter.increment()
        bufferIndex = 0
    }

    /// Generates one Philox4x64-10 block.
    /// This operation is pure, i.e.
    ///     
    ///     output = Philox(counter, key)
    /// 
    /// The same counter/key pair always procues the same four UInt64s.
    @inlinable
    public static func generate(counter: Counter, key: Key) -> (UInt64, UInt64, UInt64, UInt64) {
        var c0 = counter.x0
        var c1 = counter.x1
        var c2 = counter.x2
        var c3 = counter.x3

        var k0 = key.k0
        var k1 = key.k1

        for round in 0..<10 {
            let p0 = UInt64(0xD2E7470EE14C6C93).multipliedFullWidth(by: c0)
            let p1 = UInt64(0xCA5A826395121157).multipliedFullWidth(by: c2)
            let n0 = p1.high ^ c1 ^ k0
            let n1 = p1.low
            let n2 = p0.high ^ c3 ^ k1
            let n3 = p0.low
            c0 = n0
            c1 = n1
            c2 = n2
            c3 = n3

            if round != 9 {
                k0 &+= 0x9E3779B97F4A7C15
                k1 &+= 0xBB67AE8584CAA73B
            }
        }
        return (c0, c1, c2, c3)
    }
}

public extension Philox4x64 {
    struct Counter: Sendable, Equatable {
        public var x0: UInt64
        public var x1: UInt64
        public var x2: UInt64
        public var x3: UInt64

        public static var zero: Counter { Counter() }

        // Use for QSD/MCWF/HOPS for example
        // Counter(block index (i.e. sample id), channel, trajectory, purpose)
        @inlinable
        public init(
            _ x0: UInt64 = 0,
            _ x1: UInt64 = 0,
            _ x2: UInt64 = 0,
            _ x3: UInt64 = 0
        ) {
            self.x0 = x0
            self.x1 = x1
            self.x2 = x2
            self.x3 = x3
        }

        @inline(always)
        @inlinable
        internal mutating func increment() {
            x0 &+= 1
            if x0 == 0 {
                x1 &+= 1
                if x1 == 0 {
                    x2 &+= 1
                    if x2 == 0 {
                        x3 &+= 1
                    }
                }
            }
        }
    }

    struct Key: Sendable, Equatable {
        public var k0: UInt64
        public var k1: UInt64

        @inlinable
        public init(_ k0: UInt64, _ k1: UInt64) {
            self.k0 = k0
            self.k1 = k1
        }
    }
}