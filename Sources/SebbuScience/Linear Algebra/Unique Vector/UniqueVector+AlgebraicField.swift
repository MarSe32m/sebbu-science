//
//  UniqueVector+AlgebraicField.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import Numerics
import NumericsExtensions

public extension UniqueVector where T: AlgebraicField, T.Magnitude: FloatingPoint {
    @inlinable @inline(__always)
    func isApproximatelyEqual( to other: borrowing Self, absoluteTolerance: T.Magnitude, relativeTolerance: T.Magnitude = 0) -> Bool {
        if count != other.count { return false }
        for i in 0..<count {
            if !components[i].isApproximatelyEqual(to: other[i], absoluteTolerance: absoluteTolerance, relativeTolerance: relativeTolerance, norm: \.magnitude) { return false }
        }
        return true
    }
}


public extension UniqueVector where T: AlgebraicField {
    @inlinable
    init(copying: borrowing Self, multiplied: T) {
        let newComponents = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newComponents._unsafeCopy(from: copying.components, multiplied: multiplied, count: copying.count)
        self.init(_unsafeComponents: newComponents, count: copying.count)
    }
    
    @inlinable
    init(copying: borrowing Self, adding: borrowing Self) where T: Copyable {
        let newComponents = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newComponents._unsafeCopy(from: copying.components, adding: adding.components, count: copying.count)
        self.init(_unsafeComponents: newComponents, count: copying.count)
    }
    
    @inlinable
    static func zero(_ count: Int) -> UniqueVector<T> {
        UniqueVector(count: count) { $0.initialize(repeating: .zero) }
    }
    
    @inlinable
    mutating func zeroComponents() {
        components._unsafeZeroElements(count: count)
    }
    
    @inlinable
    mutating func copyComponents(from other: borrowing Self, multiplied: T) {
        precondition(count == other.count)
        components._unsafeCopy(from: other.components, multiplied: multiplied, count: count)
    }
    
    @inlinable
    mutating func copyComponents(from other: borrowing Self, adding: borrowing Self) {
        precondition(count == other.count && count == adding.count)
        components._unsafeCopy(from: other.components, adding: adding.components, count: count)
    }
    @inlinable
    mutating func copyComponents(from other: borrowing Self, adding: borrowing Self, multiplied: T) {
        precondition(count == other.count && count == adding.count)
        components._unsafeCopy(from: other.components, adding: adding.components, multiplied: multiplied, count: count)
    }
}

public extension UniqueVector where T: ConjugatableScalar {
    @inlinable
    var conjugate: Self {
        let newComponents: UnsafeMutablePointer<T> = .allocate(capacity: count)
        for i in 0..<count {
            newComponents[i] = components[i].conjugate
        }
        return .init(_unsafeComponents: newComponents, count: count)
    }
}

public extension UniqueVector<Double> {
    @inlinable
    func squaredEuclideanDistance(to other: borrowing Self) -> Double {
        precondition(count == other.count, "The vectors must have the same dimensions")
        var result: Double = .zero
        for i in 0..<count {
            let diff = Relaxed.sum(components[i], -other.components[i])
            result = Relaxed.sum(diff * diff, result)
        }
        return result
    }
    
    @inlinable
    func euclideanDistance(to other: borrowing Self) -> Double {
        .sqrt(squaredEuclideanDistance(to: other))
    }
}

public extension UniqueVector<Float> {
    @inlinable
    func squaredEuclideanDistance(to other: borrowing Self) -> Float {
        precondition(count == other.count, "The vectors must have the same dimensions")
        var result: Float = .zero
        for i in 0..<count {
            let diff = Relaxed.sum(components[i], -other.components[i])
            result = Relaxed.sum(diff * diff, result)
        }
        return result
    }
    
    @inlinable
    func euclideanDistance(to other: borrowing Self) -> Float {
        .sqrt(squaredEuclideanDistance(to: other))
    }
}

public extension UniqueVector<Complex<Double>> {
    @inlinable
    init(copying: borrowing Self, multiplied: Double) {
        let newComponents = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newComponents._unsafeCopy(from: copying.components, multiplied: multiplied, count: copying.count)
        self.init(_unsafeComponents: newComponents, count: copying.count)
    }
    
    @inlinable
    func squaredEuclideanDistance(to other: borrowing Self) -> Double {
        precondition(count == other.count, "The vectors must have the same dimensions")
        var result: Double = .zero
        for i in 0..<count {
            let diff = Relaxed.sum(components[i], -other.components[i])
            result = Relaxed.sum(diff.lengthSquared, result)
        }
        return result
    }
    
    @inlinable
    func euclideanDistance(to other: borrowing Self) -> Double {
        .sqrt(squaredEuclideanDistance(to: other))
    }
}

public extension UniqueVector<Complex<Float>> {
    @inlinable
    init(copying: borrowing Self, multiplied: Float) {
        let newComponents = UnsafeMutablePointer<T>.allocate(capacity: copying.count)
        newComponents._unsafeCopy(from: copying.components, multiplied: multiplied, count: copying.count)
        self.init(_unsafeComponents: newComponents, count: copying.count)
    }
    
    @inlinable
    func squaredEuclideanDistance(to other: borrowing Self) -> Float {
        precondition(count == other.count, "The vectors must have the same dimensions")
        var result: Float = .zero
        for i in 0..<count {
            let diff = Relaxed.sum(components[i], -other.components[i])
            result = Relaxed.sum(diff.lengthSquared, result)
        }
        return result
    }
    
    @inlinable
    func euclideanDistance(to other: borrowing Self) -> Float {
        .sqrt(squaredEuclideanDistance(to: other))
    }
}
