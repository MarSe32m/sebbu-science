//
//  Vector+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Scaling for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        _multiply(by: by)
    }

    @inlinable
    mutating func _multiply(by: T) {
        for i in 0..<components.count {
            components[i] = Relaxed.product(components[i], by)
        }
    }

    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }

    @inlinable
    func _multiply(by: T, into: inout Self) {
        for i in 0..<components.count {
            into[i] = Relaxed.product(components[i], by)
        }
    }
}

//MARK: Scaling for Double
public extension Vector<Double> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let dscal = BLAS.dscal {
            let N = cblas_int(count)
            dscal(N, by, &components, 1)
        } else {
            _multiply(by: by)
        }
    }
}

//MARK: Scaling for Float
public extension Vector<Float> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let sscal = BLAS.sscal {
            let N = cblas_int(count)
            sscal(N, by, &components, 1)
        } else {
            _multiply(by: by)
        }
    }
}

//MARK: Scaling for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    
    @inlinable
    static func *(lhs: Double, rhs: Self) -> Self {
        var result = Vector(Array(rhs.components))
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let zscal = BLAS.zscal {
            let N = cblas_int(count)
            withUnsafePointer(to: by) { alpha in
                zscal(N, alpha, &components, 1)
            }
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        if let zdscal = BLAS.zdscal {
            let N = cblas_int(count)
            zdscal(N, by, &components, 1)
        } else {
            for i in 0..<components.count {
                components[i].real = Relaxed.product(components[i].real, by)
                components[i].imaginary = Relaxed.product(components[i].imaginary, by)
            }
        }
    }
}

//MARK: Scaling for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var result = Vector(rhs.components)
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    static func *(lhs: Float, rhs: Self) -> Self {
        var result = Vector(Array(rhs.components))
        result.multiply(by: lhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let cscal = BLAS.cscal {
            let N = cblas_int(count)
            withUnsafePointer(to: by) { alpha in
                cscal(N, alpha, &components, 1)
            }
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    mutating func multiply(by: Float) {
        if let csscal = BLAS.csscal {
            let N = cblas_int(count)
            csscal(N, by, &components, 1)
        } else {
            for i in 0..<count {
                components[i].real = Relaxed.product(components[i].real, by)
                components[i].imaginary = Relaxed.product(components[i].imaginary, by)
            }
        }
    }
}
