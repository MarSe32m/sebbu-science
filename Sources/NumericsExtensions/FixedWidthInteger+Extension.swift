//
//  FixedWidthInteger+Extension.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

package extension FixedWidthInteger {
    /// Returns the next power of two.
    @inline(__always)
    @inlinable
    var nextPowerOf2: Self {
        guard self != 0 else { return 1 }
        return 1 << (Self.bitWidth - (self - 1).leadingZeroBitCount)
    }
    
    @inline(__always)
    @inlinable
    var previousPowerOf2: Self {
        guard self > 0 else { return 0 }
        return 1 << (Self.bitWidth - self.leadingZeroBitCount - 1)
    }
    
    @inline(__always)
    @inlinable
    var log2: Int {
        precondition(self > 0)
        return bitWidth - leadingZeroBitCount - 1
    }

    @inlinable
    func partitions(maxTerms: Int = .max) -> [[Self]] {
        precondition(self >= .zero, "Integer partitions are defined only for positive integers.")
        if self <= 1 { return [[self]] }
        var result: [[Self]] = []
        var currentPartition: [Self] = []
        while currentPartition.count < self {
            currentPartition.append(.zero)
        }
        var k = 0
        currentPartition[k] = self

        while true {
            if k < maxTerms {
                result.append(Array(currentPartition[0...k]))
            }
            var removeValue: Self = .zero
            while k >= 0 && currentPartition[k] == 1 {
                removeValue += currentPartition[k]
                k -= 1
            }

            if k < 0 { break }

            currentPartition[k] -= 1
            removeValue += 1

            while removeValue > currentPartition[k] {
                currentPartition[k + 1] = currentPartition[k]
                removeValue -= currentPartition[k]
                k += 1
            }
            currentPartition[k + 1] = removeValue
            k += 1
        }
        return result
    }
}
