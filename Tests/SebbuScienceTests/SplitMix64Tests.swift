// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

@Suite("SplitMix64 generator")
struct SplitMix64Tests {
    @Test("Matches the published reference algorithm")
    func referenceVectors() {
        // Generated from Sebastiano Vigna's public-domain reference implementation:
        // https://prng.di.unimi.it/splitmix64.c
        let vectors: [(seed: UInt64, expected: [UInt64])] = [
            (
                0,
                [
                    0xE220A8397B1DCDAF,
                    0x6E789E6AA1B965F4,
                    0x06C45D188009454F,
                    0xF88BB8A8724C81EC,
                    0x1B39896A51A8749B,
                    0x53CB9F0C747EA2EA,
                    0x2C829ABE1F4532E1,
                    0xC584133AC916AB3C,
                ]
            ),
            (
                .max,
                [
                    0xE4D971771B652C20,
                    0xE99FF867DBF682C9,
                    0x382FF84CB27281E9,
                    0x6D1DB36CCBA982D2,
                    0xB4A0472E578069AE,
                    0xD31DADBDA438BB33,
                    0xF14F2CF802083FA5,
                    0x405DA438A39E8064,
                ]
            ),
        ]

        for vector in vectors {
            var generator = SplitMix64(seed: vector.seed)
            #expect(drawValues(from: &generator, count: vector.expected.count) == vector.expected)
        }
    }

    @Test("State addition wraps modulo 2^64")
    func stateWraparound() {
        // -0x9E3779B97F4A7C15 modulo 2^64. The first increment therefore reaches zero.
        var generator = SplitMix64(seed: 0x61C8864680B583EB)

        #expect(generator.next() == 0)
        #expect(generator.state == 0)
        #expect(generator.next() == 0xE220A8397B1DCDAF)
        #expect(generator.state == 0x9E3779B97F4A7C15)
    }

    @Test("Copying preserves an independent continuation")
    func valueSemantics() {
        var original = SplitMix64(seed: 0x0123456789ABCDEF)
        _ = drawValues(from: &original, count: 3)
        var copy = original

        let originalContinuation = drawValues(from: &original, count: 32)
        let copiedContinuation = drawValues(from: &copy, count: 32)

        #expect(originalContinuation == copiedContinuation)
    }
}
