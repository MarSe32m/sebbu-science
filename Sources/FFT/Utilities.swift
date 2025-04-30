//
//  Utilities.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//

internal extension FixedWidthInteger {
    @inlinable
    var nextPowerOfTwo: Self {
        guard self != 0 else {
            return 1
        }
        return 1 << (Self.bitWidth - (self - 1).leadingZeroBitCount)
    }
    
    @inlinable
    var log2: Int {
        precondition(self > 0)
        return bitWidth - leadingZeroBitCount - 1
    }
}
