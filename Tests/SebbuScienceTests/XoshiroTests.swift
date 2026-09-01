// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

@Suite("xoshiro256** generator")
struct Xoshiro256StarStarTests {
    @Test("Matches the published reference algorithm from an explicit state")
    func directStateReferenceVector() {
        // Generated from Blackman and Vigna's public-domain reference implementation:
        // https://prng.di.unimi.it/xoshiro256starstar.c
        let expected: [UInt64] = [
            0x0000000000002D00,
            0x0000000000000000,
            0x000000005A007080,
            0x10E0000000009D80,
            0x10E0B61CE1009D80,
            0x0870021CE143AD00,
            0xE071C3C2E143F089,
            0x75A1690EF7A20380,
            0x9309685B465C23F9,
            0x284F3CC2E13E3C88,
        ]
        var generator = Xoshiro256StarStar(state: (1, 2, 3, 4))

        #expect(drawValues(from: &generator, count: expected.count) == expected)
        #expect(generator.state[0] == 0x60046C12114362D3)
        #expect(generator.state[1] == 0x4058921A000402E6)
        #expect(generator.state[2] == 0x085C360011860022)
        #expect(generator.state[3] == 0x3C2EBC0094C0A2F9)
    }

    @Test("Seed initializer expands with SplitMix64")
    func seededReferenceVector() {
        let expected: [UInt64] = [
            0x99EC5F36CB75F2B4,
            0xBF6E1F784956452A,
            0x1A5F849D4933E6E0,
            0x6AA594F1262D2D2C,
            0xBBA5AD4A1F842E59,
            0xFFEF8375D9EBCACA,
            0x6C160DEED2F54C98,
            0x8920AD648FC30A3F,
        ]
        var generator = Xoshiro256StarStar(seed: 0)

        #expect(drawValues(from: &generator, count: expected.count) == expected)
    }

    @Test("Tuple and inline-array state initializers agree")
    func stateInitializersAgree() {
        let state: [4 of UInt64] = [1, 2, 3, 4]
        var tupleGenerator = Xoshiro256StarStar(state: (1, 2, 3, 4))
        var inlineArrayGenerator = Xoshiro256StarStar(state: state)

        let tupleValues = drawValues(from: &tupleGenerator, count: 32)
        let inlineArrayValues = drawValues(from: &inlineArrayGenerator, count: 32)
        #expect(tupleValues == inlineArrayValues)
    }

    @Test("Copying preserves an independent continuation")
    func valueSemantics() {
        var original = Xoshiro256StarStar(seed: 0x0123456789ABCDEF)
        _ = drawValues(from: &original, count: 7)
        var copy = original

        let originalContinuation = drawValues(from: &original, count: 32)
        let copiedContinuation = drawValues(from: &copy, count: 32)
        #expect(originalContinuation == copiedContinuation)
    }
}

@Suite("xoshiro256++ generator")
struct Xoshiro256PlusPlusTests {
    @Test("Matches the published reference algorithm from an explicit state")
    func directStateReferenceVector() {
        // Generated from Blackman and Vigna's public-domain reference implementation:
        // https://prng.di.unimi.it/xoshiro256plusplus.c
        let expected: [UInt64] = [
            0x0000000002800001,
            0x0000000003800067,
            0x000CC00003800067,
            0x000CC201994400B2,
            0x8012A2019AC433CD,
            0x8A69978ACDEE33BA,
            0xC271134733154ABD,
            0xAC2BA09179169E97,
            0xDBF3190A8F073FD8,
            0x9105F14AB2229220,
        ]
        var generator = Xoshiro256PlusPlus(state: (1, 2, 3, 4))

        #expect(drawValues(from: &generator, count: expected.count) == expected)
        #expect(generator.state[0] == 0x60046C12114362D3)
        #expect(generator.state[1] == 0x4058921A000402E6)
        #expect(generator.state[2] == 0x085C360011860022)
        #expect(generator.state[3] == 0x3C2EBC0094C0A2F9)
    }

    @Test("Seed initializer expands with SplitMix64")
    func seededReferenceVector() {
        let expected: [UInt64] = [
            0x53175D61490B23DF,
            0x61DA6F3DC380D507,
            0x5C0FDF91EC9A7BFC,
            0x02EEBF8C3BBE5E1A,
            0x7ECA04EBAF4A5EEA,
            0x0543C37757F08D9A,
            0xDB7490C75AB5026E,
            0xD87343E6464BC959,
        ]
        var generator = Xoshiro256PlusPlus(seed: 0)

        #expect(drawValues(from: &generator, count: expected.count) == expected)
    }

    @Test("Tuple and inline-array state initializers agree")
    func stateInitializersAgree() {
        let state: [4 of UInt64] = [1, 2, 3, 4]
        var tupleGenerator = Xoshiro256PlusPlus(state: (1, 2, 3, 4))
        var inlineArrayGenerator = Xoshiro256PlusPlus(state: state)

        let tupleValues = drawValues(from: &tupleGenerator, count: 32)
        let inlineArrayValues = drawValues(from: &inlineArrayGenerator, count: 32)
        #expect(tupleValues == inlineArrayValues)
    }

    @Test("Copying preserves an independent continuation")
    func valueSemantics() {
        var original = Xoshiro256PlusPlus(seed: 0x0123456789ABCDEF)
        _ = drawValues(from: &original, count: 7)
        var copy = original

        let originalContinuation = drawValues(from: &original, count: 32)
        let copiedContinuation = drawValues(from: &copy, count: 32)
        #expect(originalContinuation == copiedContinuation)
    }
}

@Suite("xoshiro256 state jumps")
struct Xoshiro256JumpTests {
    @Test("Jump matches the published 2^128 transition")
    func jumpReferenceVector() {
        var starStar = Xoshiro256StarStar(state: (1, 2, 3, 4))
        var plusPlus = Xoshiro256PlusPlus(state: (1, 2, 3, 4))

        starStar.jump()
        plusPlus.jump()

        let expected: [UInt64] = [
            0x8C7A153956B5F3D1,
            0x701F1A713401D85E,
            0x6527F66A65469085,
            0x8386B786C4408050,
        ]
        #expect((0..<4).map { starStar.state[$0] } == expected)
        #expect((0..<4).map { plusPlus.state[$0] } == expected)
        #expect(starStar.next() == 0xBBD2F312298443D8)
        #expect(plusPlus.next() == 0xEC879073673DF437)
    }

    @Test("Long jump matches the published 2^192 transition")
    func longJumpReferenceVector() {
        var starStar = Xoshiro256StarStar(state: (1, 2, 3, 4))
        var plusPlus = Xoshiro256PlusPlus(state: (1, 2, 3, 4))

        starStar.longJump()
        plusPlus.longJump()

        let expected: [UInt64] = [
            0x096A8EB71295A400,
            0xDBF84991E50F4516,
            0x534EE745810D2A0E,
            0x31655CA1A2215BF1,
        ]
        #expect((0..<4).map { starStar.state[$0] } == expected)
        #expect((0..<4).map { plusPlus.state[$0] } == expected)
        #expect(starStar.next() == 0x527752A1D792704D)
        #expect(plusPlus.next() == 0xB5C4EA370B330BF5)
    }
}
