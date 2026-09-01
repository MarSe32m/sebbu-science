// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

@Suite("Random generator deterministic smoke checks")
struct RandomGeneratorStatisticalTests {
    // These fixed-seed checks catch gross failures such as stuck bits or a broken output word.
    // They are deliberately lightweight and are not a substitute for TestU01/PractRand.

    @Test("SplitMix64 bit and byte frequencies")
    func splitMix64() {
        var generator = SplitMix64(seed: 0x0123456789ABCDEF)
        let statistics = deterministicSmokeStatistics(for: &generator)

        #expect((0.49...0.51).contains(statistics.setBitFraction))
        #expect((128.0...384.0).contains(statistics.byteChiSquared))
    }

    @Test("xoshiro256** bit and byte frequencies")
    func xoshiro256StarStar() {
        var generator = Xoshiro256StarStar(seed: 0x0123456789ABCDEF)
        let statistics = deterministicSmokeStatistics(for: &generator)

        #expect((0.49...0.51).contains(statistics.setBitFraction))
        #expect((128.0...384.0).contains(statistics.byteChiSquared))
    }

    @Test("xoshiro256++ bit and byte frequencies")
    func xoshiro256PlusPlus() {
        var generator = Xoshiro256PlusPlus(seed: 0x0123456789ABCDEF)
        let statistics = deterministicSmokeStatistics(for: &generator)

        #expect((0.49...0.51).contains(statistics.setBitFraction))
        #expect((128.0...384.0).contains(statistics.byteChiSquared))
    }

    @Test("Philox4x64 bit and byte frequencies")
    func philox4x64() {
        var generator = Philox4x64(seed: 0x0123456789ABCDEF)
        let statistics = deterministicSmokeStatistics(for: &generator)

        #expect((0.49...0.51).contains(statistics.setBitFraction))
        #expect((128.0...384.0).contains(statistics.byteChiSquared))
    }

    @Test("Philox4x32 bit and byte frequencies")
    func philox4x32() {
        var generator = Philox4x32(seed: 0x0123456789ABCDEF)
        let statistics = deterministicSmokeStatistics(for: &generator)

        #expect((0.49...0.51).contains(statistics.setBitFraction))
        #expect((128.0...384.0).contains(statistics.byteChiSquared))
    }

    @Test("All generator values satisfy Sendable")
    func sendableConformance() {
        requireSendable(SplitMix64(seed: 0))
        requireSendable(Xoshiro256StarStar(seed: 0))
        requireSendable(Xoshiro256PlusPlus(seed: 0))
        requireSendable(Philox4x64(seed: 0))
        requireSendable(Philox4x32(seed: 0))
    }
}
