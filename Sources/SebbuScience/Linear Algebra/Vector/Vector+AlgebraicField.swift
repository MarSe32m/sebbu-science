//
//  Vector+AlgebraicField.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 11.4.2025.
//

import RealModule
import ComplexModule

public extension Vector where T: AlgebraicField {
    @inlinable
    static func zero(_ count: Int) -> Vector<T> {
        Vector(count: count) { buffer in
            var i = 0
            while i < count {
                buffer[i] = .zero
                i &+= 1
            }
        }
    }
    
    @inlinable
    mutating func zeroComponents() {
        for i in 0..<components.count {
            components[i] = .zero
        }
    }
}

public extension Vector where T: AlgebraicField, T.Magnitude: FloatingPoint {
    @inlinable @inline(__always)
    func isApproximatelyEqual( to other: Self, absoluteTolerance: T.Magnitude, relativeTolerance: T.Magnitude = 0) -> Bool {
        if count != other.count { return false }
        for i in 0..<count {
            if !components[i].isApproximatelyEqual(to: other[i], absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance, norm: \.magnitude) { return false }
        }
        return true
    }
}
