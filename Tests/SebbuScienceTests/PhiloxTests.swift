// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

@Suite("Philox4x64 generator")
struct Philox4x64Tests {
    @Test("Known answer test")
    func knownAnswerTest() {
        let result = Philox4x64.generate(
            counter: .zero,
            key: .init(0, 0)
        )

        #expect(result.0 == 0x16554D9ECA36314C)
        #expect(result.1 == 0xDB20FE9D672D0FDC)
        #expect(result.2 == 0xD7E772CEE186176B)
        #expect(result.3 == 0x7E68B68AEC7BA23B)
    }
}

@Suite
struct Philox4x32Tests {
    @Test("Known answer test")
    func knownAnswerTest() {
        let result = Philox4x32.generate(
            counter: .zero,
            key: .init(0, 0)
        )
        #expect(result.0 == 0x6627E8D5)
        #expect(result.1 == 0xE169C58D)
        #expect(result.2 == 0xBC57AC4C)
        #expect(result.3 == 0x9B00DBD8)
    }
}
