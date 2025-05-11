//
//  Vector+Division.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Division for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func divide(by: T) {
        _divide(by: by)
    }
    
    @inlinable
    mutating func _divide(by: T) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
    
    @inlinable
    @_transparent
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }
    
    @inlinable
    func _divide(by: T, into: inout Self) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal, into: &into)
        } else {
            for i in components.indices {
                into[i] = components[i] / by
            }
        }
    }
}

//MARK: Division for Double
public extension Vector<Double> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
}

//MARK: Division for Float
public extension Vector<Float> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
}

//MARK: Division for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    static func /(lhs: Self, rhs: Double) -> Self {
        var result = Vector(Array(lhs.components))
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: Double) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in 0..<components.count {
                components[i] /= by
            }
        }
    }
    
    @inlinable
    mutating func divide(by: Double) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
}

//MARK: Division for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var result = Vector(lhs.components)
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    static func /(lhs: Self, rhs: Float) -> Self {
        var result = Vector(Array(lhs.components))
        result.divide(by: rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: Float) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in 0..<components.count {
                components[i] /= by
            }
        }
    }
    
    @inlinable
    mutating func divide(by: Float) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            for i in components.indices {
                components[i] /= by
            }
        }
    }
}
