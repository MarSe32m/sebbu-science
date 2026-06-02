//
//  PointerUtilities.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 22.5.2026.
//

import Numerics

extension UnsafeMutablePointer where Pointee: AlgebraicField {
    @inlinable
    @inline(always)
    func _unsafeAdd(_ other: Self, count: Int) {
        for i in 0..<count { self[i] = Relaxed.sum(self[i], other[i]) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeAdd(_ other: Self, multiplied: Pointee, count: Int) {
        for i in 0..<count { self[i] = Relaxed.multiplyAdd(other[i], multiplied, self[i]) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeAdd(_ scalar: Pointee, count: Int) {
        for i in 0..<count { self[i] = Relaxed.sum(scalar, self[i]) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeSubtract(_ other: Self, count: Int) {
        for i in 0..<count { self[i] = Relaxed.sum(self[i], -other[i]) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeSubtract(_ other: Self, multiplied: Pointee, count: Int) {
        for i in 0..<count { self[i] = Relaxed.multiplyAdd(-other[i], multiplied, self[i]) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeSubtract(_ scalar: Pointee, count: Int) {
        _unsafeAdd(-scalar, count: count)
    }
    
    @inlinable
    @inline(always)
    func _unsafeMultiply(by: Pointee, count: Int) {
        for i in 0..<count { self[i] = Relaxed.product(self[i], by) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeDivide(by: Pointee, count: Int) {
        if let reciprocal = by.reciprocal {
            _unsafeMultiply(by: reciprocal, count: count)
        } else {
            for i in 0..<count { self[i] = self[i] / by }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeZeroElements(count: Int) {
        for i in 0..<count { self[i] = .zero }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, multiplied: Pointee, count: Int) {
        for i in 0..<count { self[i] = Relaxed.product(from[i], multiplied) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, adding: Self, count: Int) {
        for i in 0..<count { self[i] = Relaxed.sum(from[i], adding[i]) }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, adding: Self, multiplied: Pointee, count: Int) {
        for i in 0..<count { self[i] = Relaxed.multiplyAdd(adding[i], multiplied, from[i]) }
    }
}

extension UnsafeMutablePointer where Pointee == Complex<Double> {
    @inlinable
    @inline(always)
    func _unsafeAdd(_ other: Self, multiplied: Double, count: Int) {
        self.withMemoryRebound(to: Double.self, capacity: 2 &* count) { elements in
            other.withMemoryRebound(to: Double.self, capacity: 2 &* count) { other in
                for i in 0..<2 &* count { elements[i] = Relaxed.multiplyAdd(other[i], multiplied, elements[i]) }
            }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeAdd(_ scalar: Double, count: Int) {
        self.withMemoryRebound(to: Double.self, capacity: 2 &* count) { elements in
            for i in 0..<2 &* count { elements[i] = Relaxed.sum(elements[i], scalar) }
        }
    }

    @inlinable
    @inline(always)
    func _unsafeSubtract(_ other: Self, multiplied: Double, count: Int) {
        self.withMemoryRebound(to: Double.self, capacity: 2 &* count) { elements in
            other.withMemoryRebound(to: Double.self, capacity: 2 &* count) { other in
                for i in 0..<2 &* count { elements[i] = Relaxed.multiplyAdd(-other[i], multiplied, elements[i]) }
            }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeSubtract(_ scalar: Double, count: Int) {
        _unsafeAdd(-scalar, count: count)
    }
    
    @inlinable
    @inline(always)
    func _unsafeMultiply(by: Double, count: Int) {
        self.withMemoryRebound(to: Double.self, capacity: 2 &* count) { elements in
            for i in 0..<2 &* count { elements[i] = Relaxed.product(elements[i], by)  }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeDivide(by: Double, count: Int) {
        if let reciprocal = by.reciprocal {
            _unsafeMultiply(by: reciprocal, count: count)
        } else {
            for i in 0..<count { self[i] = self[i] / by }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, multiplied: Double, count: Int) {
        self.withMemoryRebound(to: Double.self, capacity: 2 &* count) { elements in
            from.withMemoryRebound(to: Double.self, capacity: 2 &* count) { other in
                for i in 0..<2 &* count { elements[i] = Relaxed.product(other[i], multiplied) }
            }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, adding: Self, multiplied: Double, count: Int) {
        self.withMemoryRebound(to: Double.self, capacity: 2 &* count) { elements in
            from.withMemoryRebound(to: Double.self, capacity: 2 &* count) { from in
                adding.withMemoryRebound(to: Double.self, capacity: 2 &* count) { adding in
                    for i in 0..<2 &* count { elements[i] = Relaxed.multiplyAdd(adding[i], multiplied, from[i]) }
                }
            }
        }
    }
}

extension UnsafeMutablePointer where Pointee == Complex<Float> {
    @inlinable
    @inline(always)
    func _unsafeAdd(_ other: Self, multiplied: Float, count: Int) {
        self.withMemoryRebound(to: Float.self, capacity: 2 &* count) { elements in
            other.withMemoryRebound(to: Float.self, capacity: 2 &* count) { other in
                for i in 0..<2 &* count { elements[i] = Relaxed.multiplyAdd(other[i], multiplied, elements[i]) }
            }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeAdd(_ scalar: Float, count: Int) {
        self.withMemoryRebound(to: Float.self, capacity: 2 &* count) { elements in
            for i in 0..<2 &* count { elements[i] = Relaxed.sum(elements[i], scalar) }
        }
    }

    @inlinable
    @inline(always)
    func _unsafeSubtract(_ other: Self, multiplied: Float, count: Int) {
        self.withMemoryRebound(to: Float.self, capacity: 2 &* count) { elements in
            other.withMemoryRebound(to: Float.self, capacity: 2 &* count) { other in
                for i in 0..<2 &* count { elements[i] = Relaxed.multiplyAdd(-other[i], multiplied, elements[i]) }
            }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeSubtract(_ scalar: Float, count: Int) {
        _unsafeAdd(-scalar, count: count)
    }
    
    @inlinable
    @inline(always)
    func _unsafeMultiply(by: Float, count: Int) {
        self.withMemoryRebound(to: Float.self, capacity: 2 &* count) { elements in
            for i in 0..<2 &* count { elements[i] = Relaxed.product(elements[i], by)  }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeDivide(by: Float, count: Int) {
        if let reciprocal = by.reciprocal {
            _unsafeMultiply(by: reciprocal, count: count)
        } else {
            for i in 0..<count { self[i] = self[i] / by }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, multiplied: Float, count: Int) {
        self.withMemoryRebound(to: Float.self, capacity: 2 &* count) { elements in
            from.withMemoryRebound(to: Float.self, capacity: 2 &* count) { other in
                for i in 0..<2 &* count { elements[i] = Relaxed.product(other[i], multiplied) }
            }
        }
    }
    
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, adding: Self, multiplied: Float, count: Int) {
        self.withMemoryRebound(to: Float.self, capacity: 2 &* count) { elements in
            from.withMemoryRebound(to: Float.self, capacity: 2 &* count) { from in
                adding.withMemoryRebound(to: Float.self, capacity: 2 &* count) { adding in
                    for i in 0..<2 &* count { elements[i] = Relaxed.multiplyAdd(adding[i], multiplied, from[i]) }
                }
            }
        }
    }
}

extension UnsafeMutablePointer {
    @inlinable
    @inline(always)
    func _unsafeCopy(from: Self, count: Int) {
        for i in 0..<count { self[i] = from[i] }
    }
}
