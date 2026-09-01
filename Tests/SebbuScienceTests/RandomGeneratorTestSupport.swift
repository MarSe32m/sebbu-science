// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

@testable import SebbuScience

func drawValues<Generator: RandomNumberGenerator>(
    from generator: inout Generator,
    count: Int
) -> [UInt64] {
    (0..<count).map { _ in generator.next() }
}

func deterministicSmokeStatistics<Generator: RandomNumberGenerator>(
    for generator: inout Generator,
    sampleCount: Int = 8_192
) -> (setBitFraction: Double, byteChiSquared: Double) {
    precondition(sampleCount > 0)

    var setBitCount = 0
    var byteHistogram = Array(repeating: 0, count: 256)

    for _ in 0..<sampleCount {
        let value = generator.next()
        setBitCount += value.nonzeroBitCount

        for shift in stride(from: 0, to: UInt64.bitWidth, by: 8) {
            let byte = Int((value >> shift) & 0xFF)
            byteHistogram[byte] += 1
        }
    }

    let totalBits = Double(sampleCount * UInt64.bitWidth)
    let setBitFraction = Double(setBitCount) / totalBits
    let expectedByteCount = Double(sampleCount * MemoryLayout<UInt64>.size) / 256.0
    let byteChiSquared = byteHistogram.reduce(into: 0.0) { result, observed in
        let difference = Double(observed) - expectedByteCount
        result += difference * difference / expectedByteCount
    }

    return (setBitFraction, byteChiSquared)
}

func requireSendable<Value: Sendable>(_: Value) {}
