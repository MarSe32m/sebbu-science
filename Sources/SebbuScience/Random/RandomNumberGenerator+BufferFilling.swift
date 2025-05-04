//
//  RandomNumberGenerator+BufferFilling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

//TODO: Remove this when buffer filling api lands!
import SwiftOverlayShims

public extension RandomNumberGenerator {
    //TODO: Remove this once the buffer filling API lands
    mutating func fill(_ buffer: UnsafeMutableRawBufferPointer) {
        if buffer.count > 8 {
            buffer.withMemoryRebound(to: UInt64.self) { buffer in
                for i in buffer.indices {
                    buffer[i] = self.next()
                }
            }
        }
        let overage = buffer.count % 8
        for i in 0..<overage {
            buffer[buffer.endIndex - overage + i] = UInt8.random(in: .min ... .max, using: &self)
        }
    }

    mutating func next<T>(count: Int) -> [T] where T : FixedWidthInteger, T : UnsignedInteger {
        var result: [T] = [T](repeating: .zero, count: count)
        result.withUnsafeMutableBytes { fill($0) }
        return result
    }

    mutating func next<T>(count: Int, upperBound: T) -> [T] where T: FixedWidthInteger, T: UnsignedInteger {
        precondition(upperBound != 0, "upperBound cannot be zero.")
        // We use Lemire's "nearly divisionless" method for generating random
        // integers in an interval. For a detailed explanation, see:
        // https://arxiv.org/abs/1805.10941
        var randomBuffer: [T] = next(count: count)
        for i in randomBuffer.indices {
            var random = randomBuffer[i]
            var m = random.multipliedFullWidth(by: upperBound)
            if m.low < upperBound {
                let t = (0 &- upperBound) % upperBound
                while m.low < t {
                    random = next()
                    m = random.multipliedFullWidth(by: upperBound)
                }
            }
            randomBuffer[i] = m.high
        }
        return randomBuffer
    }
}

public extension SystemRandomNumberGenerator {
    //TODO: Remove when https://github.com/swiftlang/swift/pull/63511 lands
    mutating func fill(_ buffer: UnsafeMutableRawBufferPointer) {
        if let p = buffer.baseAddress {
            swift_stdlib_random(p, buffer.count)
        }
    }
}
