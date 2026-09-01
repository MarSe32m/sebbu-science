// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

@Suite("Philox4x64 generator")
struct Philox4x64Tests {
    @Test("Matches Random123 known-answer vectors")
    func knownAnswerVectors() {
        // Random123 tests/kat_vectors, Philox4x64-10:
        // https://github.com/DEShawResearch/random123/blob/main/tests/kat_vectors
        let vectors: [
            (
                counter: Philox4x64.Counter,
                key: Philox4x64.Key,
                expected: [UInt64]
            )
        ] = [
            (
                .zero,
                .init(0, 0),
                [
                    0x16554D9ECA36314C,
                    0xDB20FE9D672D0FDC,
                    0xD7E772CEE186176B,
                    0x7E68B68AEC7BA23B,
                ]
            ),
            (
                .init(.max, .max, .max, .max),
                .init(.max, .max),
                [
                    0x87B092C3013FE90B,
                    0x438C3C67BE8D0224,
                    0x9CC7D7C69CD777B6,
                    0xA09CAEBF594F0BA0,
                ]
            ),
            (
                .init(
                    0x243F6A8885A308D3,
                    0x13198A2E03707344,
                    0xA4093822299F31D0,
                    0x082EFA98EC4E6C89
                ),
                .init(0x452821E638D01377, 0xBE5466CF34E90C6C),
                [
                    0xA528F45403E61D95,
                    0x38C72DBD566E9788,
                    0xA5A1610E72FD18B5,
                    0x57BD43B5E52B7FE6,
                ]
            ),
        ]

        for vector in vectors {
            let result = Philox4x64.generate(counter: vector.counter, key: vector.key)
            #expect([result.0, result.1, result.2, result.3] == vector.expected)
        }
    }

    @Test("Streaming interface emits complete blocks and advances x0")
    func streamingAcrossBlockBoundary() {
        let key = Philox4x64.Key(0x0123456789ABCDEF, 0xFEDCBA9876543210)
        let firstCounter = Philox4x64.Counter(7, 11, 13, 17)
        let secondCounter = Philox4x64.Counter(8, 11, 13, 17)
        let firstBlock = Philox4x64.generate(counter: firstCounter, key: key)
        let secondBlock = Philox4x64.generate(counter: secondCounter, key: key)
        let expected = [
            firstBlock.0, firstBlock.1, firstBlock.2, firstBlock.3,
            secondBlock.0, secondBlock.1, secondBlock.2, secondBlock.3,
        ]
        var generator = Philox4x64(key: key, counter: firstCounter)

        #expect(drawValues(from: &generator, count: 8) == expected)
        #expect(generator.counter == .init(9, 11, 13, 17))
        #expect(generator.bufferIndex == 4)
    }

    @Test("Counter increment carries through every word")
    func counterCarry() {
        let cases: [(start: Philox4x64.Counter, expected: Philox4x64.Counter)] = [
            (.init(.max, 3, 5, 7), .init(0, 4, 5, 7)),
            (.init(.max, .max, 5, 7), .init(0, 0, 6, 7)),
            (.init(.max, .max, .max, 7), .init(0, 0, 0, 8)),
            (.init(.max, .max, .max, .max), .zero),
        ]

        for testCase in cases {
            var generator = Philox4x64(key: .init(0, 0), counter: testCase.start)
            _ = generator.next()
            #expect(generator.counter == testCase.expected)
        }
    }

    @Test("Seed initializer uses the first two SplitMix64 outputs as its key")
    func seedExpansion() {
        let counter = Philox4x64.Counter(1, 2, 3, 4)
        let expectedKey = Philox4x64.Key(0xE220A8397B1DCDAF, 0x6E789E6AA1B965F4)
        var seeded = Philox4x64(seed: 0, counter: counter)
        var keyed = Philox4x64(key: expectedKey, counter: counter)

        #expect(seeded.key == expectedKey)
        let seededValues = drawValues(from: &seeded, count: 12)
        let keyedValues = drawValues(from: &keyed, count: 12)
        #expect(seededValues == keyedValues)
    }

    @Test("Copying preserves buffered words and an independent continuation")
    func valueSemantics() {
        var original = Philox4x64(seed: 0x0123456789ABCDEF)
        _ = drawValues(from: &original, count: 3)
        var copy = original

        let originalContinuation = drawValues(from: &original, count: 17)
        let copiedContinuation = drawValues(from: &copy, count: 17)
        #expect(originalContinuation == copiedContinuation)
    }
}

@Suite("Philox4x32 generator")
struct Philox4x32Tests {
    @Test("Matches Random123 known-answer vectors")
    func knownAnswerVectors() {
        // Random123 tests/kat_vectors, Philox4x32-10:
        // https://github.com/DEShawResearch/random123/blob/main/tests/kat_vectors
        let vectors: [
            (
                counter: Philox4x32.Counter,
                key: Philox4x32.Key,
                expected: [UInt32]
            )
        ] = [
            (
                .zero,
                .init(0, 0),
                [0x6627E8D5, 0xE169C58D, 0xBC57AC4C, 0x9B00DBD8]
            ),
            (
                .init(.max, .max, .max, .max),
                .init(.max, .max),
                [0x408F276D, 0x41C83B0E, 0xA20BC7C6, 0x6D5451FD]
            ),
            (
                .init(0x243F6A88, 0x85A308D3, 0x13198A2E, 0x03707344),
                .init(0xA4093822, 0x299F31D0),
                [0xD16CFE09, 0x94FDCCEB, 0x5001E420, 0x24126EA1]
            ),
        ]

        for vector in vectors {
            let result = Philox4x32.generate(counter: vector.counter, key: vector.key)
            #expect([result.0, result.1, result.2, result.3] == vector.expected)
        }
    }

    @Test("UInt32 streaming emits complete blocks and advances x0")
    func streamingAcrossBlockBoundary() {
        let key = Philox4x32.Key(0x01234567, 0x89ABCDEF)
        let firstCounter = Philox4x32.Counter(7, 11, 13, 17)
        let secondCounter = Philox4x32.Counter(8, 11, 13, 17)
        let firstBlock = Philox4x32.generate(counter: firstCounter, key: key)
        let secondBlock = Philox4x32.generate(counter: secondCounter, key: key)
        let expected = [
            firstBlock.0, firstBlock.1, firstBlock.2, firstBlock.3,
            secondBlock.0, secondBlock.1, secondBlock.2, secondBlock.3,
        ]
        var generator = Philox4x32(key: key, counter: firstCounter)
        let actual = (0..<8).map { _ in generator.nextUInt32() }

        #expect(actual == expected)
        #expect(generator.counter == .init(9, 11, 13, 17))
        #expect(generator.bufferIndex == 4)
    }

    @Test("RandomNumberGenerator output combines consecutive UInt32 words in order")
    func uint64WordOrdering() {
        var generator = Philox4x32(key: .init(0, 0))
        let secondBlock = Philox4x32.generate(counter: .init(1, 0, 0, 0), key: .init(0, 0))

        #expect(generator.next() == 0x6627E8D5E169C58D)
        #expect(generator.next() == 0xBC57AC4C9B00DBD8)
        let expected = (UInt64(secondBlock.0) << 32) | UInt64(secondBlock.1)
        #expect(generator.next() == expected)
    }

    @Test("UInt32 and UInt64 draws share one buffer without dropping words")
    func mixedWidthStreaming() {
        let key = Philox4x32.Key(0x01234567, 0x89ABCDEF)
        let firstBlock = Philox4x32.generate(counter: .zero, key: key)
        let secondBlock = Philox4x32.generate(counter: .init(1, 0, 0, 0), key: key)
        var generator = Philox4x32(key: key)
        let middleOfFirstBlock = (UInt64(firstBlock.1) << 32) | UInt64(firstBlock.2)
        let blockBoundary = (UInt64(firstBlock.3) << 32) | UInt64(secondBlock.0)

        #expect(generator.nextUInt32() == firstBlock.0)
        #expect(generator.next() == middleOfFirstBlock)
        #expect(generator.next() == blockBoundary)
        #expect(generator.nextUInt32() == secondBlock.1)
        #expect(generator.nextUInt32() == secondBlock.2)
        #expect(generator.nextUInt32() == secondBlock.3)
        #expect(generator.counter == .init(2, 0, 0, 0))
        #expect(generator.bufferIndex == 4)
    }

    @Test("Counter increment carries through every word")
    func counterCarry() {
        let cases: [(start: Philox4x32.Counter, expected: Philox4x32.Counter)] = [
            (.init(.max, 3, 5, 7), .init(0, 4, 5, 7)),
            (.init(.max, .max, 5, 7), .init(0, 0, 6, 7)),
            (.init(.max, .max, .max, 7), .init(0, 0, 0, 8)),
            (.init(.max, .max, .max, .max), .zero),
        ]

        for testCase in cases {
            var generator = Philox4x32(key: .init(0, 0), counter: testCase.start)
            _ = generator.nextUInt32()
            #expect(generator.counter == testCase.expected)
        }
    }

    @Test("UInt64 key initializer uses low word followed by high word")
    func uint64KeyInitializer() {
        let key = Philox4x32.Key(0x0123456789ABCDEF)

        #expect(key.k0 == 0x89ABCDEF)
        #expect(key.k1 == 0x01234567)
    }

    @Test("Seed initializer expands one SplitMix64 output into its key")
    func seedExpansion() {
        let counter = Philox4x32.Counter(1, 2, 3, 4)
        let expectedKey = Philox4x32.Key(0x7B1DCDAF, 0xE220A839)
        var seeded = Philox4x32(seed: 0, counter: counter)
        var keyed = Philox4x32(key: expectedKey, counter: counter)

        #expect(seeded.key == expectedKey)
        let seededValues = drawValues(from: &seeded, count: 12)
        let keyedValues = drawValues(from: &keyed, count: 12)
        #expect(seededValues == keyedValues)
    }

    @Test("Copying preserves a partially consumed block")
    func valueSemantics() {
        var original = Philox4x32(seed: 0x0123456789ABCDEF)
        _ = original.nextUInt32()
        var copy = original

        let originalContinuation = (0..<19).map { _ in original.nextUInt32() }
        let copiedContinuation = (0..<19).map { _ in copy.nextUInt32() }
        #expect(originalContinuation == copiedContinuation)
    }
}
