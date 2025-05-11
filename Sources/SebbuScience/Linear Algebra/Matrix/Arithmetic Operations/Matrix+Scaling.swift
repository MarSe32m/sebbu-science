//
//  Matrix+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Scaling for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
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
        var i = 0
        while i &+ 4 <= elements.count {
            elements[i] = Relaxed.product(by, elements[i])
            elements[i &+ 1] = Relaxed.product(by, elements[i &+ 1])
            elements[i &+ 2] = Relaxed.product(by, elements[i &+ 2])
            elements[i &+ 3] = Relaxed.product(by, elements[i &+ 3])
            i &+= 4
        }
        while i < elements.count {
            elements[i] = Relaxed.product(by, elements[i])
            i &+= 1
        }
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
    
    @inlinable
    func _multiply(by: T, into: inout Self) {
        precondition(into.elements.count == elements.count)
        var i = 0
        while i &+ 4 <= into.elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
            into.elements[i &+ 1] = Relaxed.product(elements[i &+ 1], by)
            into.elements[i &+ 2] = Relaxed.product(elements[i &+ 2], by)
            into.elements[i &+ 3] = Relaxed.product(elements[i &+ 3], by)
            i &+= 4
        }
        while i < into.elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
            i &+= 1
        }
    }
}

//MARK: Scaling for Double
public extension Matrix<Double> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let dscal = BLAS.dscal {
            let N = cblas_int(elements.count)
            dscal(N, by, &elements, 1)
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
}

//MARK: Scaling for Float
public extension Matrix<Float> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let sscal = BLAS.sscal {
            let N = cblas_int(elements.count)
            sscal(N, by, &elements, 1)
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
}

//MARK: Scaling for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    static func *(lhs: Double, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: Double) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    mutating func multiply(by: T) {
        if let zscal = BLAS.zscal {
            let N = cblas_int(elements.count)
            withUnsafePointer(to: by) { alpha in
                zscal(N, alpha, &elements, 1)
            }
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        if let zdscal = BLAS.zdscal {
            let N = cblas_int(elements.count)
            zdscal(N, by, &elements, 1)
        } else {
            for i in 0..<elements.count {
                elements[i].real = Relaxed.product(elements[i].real, by)
                elements[i].imaginary = Relaxed.product(elements[i].imaginary, by)
            }
        }
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
    
    @inlinable
    func multiply(by: Double, into: inout Self) {
        var i = 0
        while i &+ 4 <= elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
            into.elements[i &+ 1] = Relaxed.product(elements[i &+ 1], by)
            into.elements[i &+ 2] = Relaxed.product(elements[i &+ 2], by)
            into.elements[i &+ 3] = Relaxed.product(elements[i &+ 3], by)
        }
        while i < elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
            i &+= 1
        }
    }
}

//MARK: Scaling for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    static func *(lhs: T, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func *=(lhs: inout Self, rhs: T) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    static func *(lhs: Float, rhs: Self) -> Self {
        var resultMatrix: Self = Matrix(elements: rhs.elements, rows: rhs.rows, columns: rhs.columns)
        resultMatrix.multiply(by: lhs)
        return resultMatrix
    }
    
    @inlinable
    static func *=(lhs: inout Self, rhs: Float) {
        lhs.multiply(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func multiply(by: T) {
        if let cscal = BLAS.cscal {
            let N = cblas_int(elements.count)
            withUnsafePointer(to: by) { alpha in
                cscal(N, alpha, &elements, 1)
            }
        } else {
            _multiply(by: by)
        }
    }
    
    mutating func multiply(by: Float) {
        if let csscal = BLAS.csscal {
            let N = cblas_int(elements.count)
            csscal(N, by, &elements, 1)
        } else {
            for i in 0..<elements.count {
                elements[i].real = Relaxed.product(elements[i].real, by)
                elements[i].imaginary = Relaxed.product(elements[i].imaginary, by)
            }
        }
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
    
    @inlinable
    func multiply(by: Float, into: inout Self) {
        var i = 0
        while i &+ 4 <= elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
            into.elements[i &+ 1] = Relaxed.product(elements[i &+ 1], by)
            into.elements[i &+ 2] = Relaxed.product(elements[i &+ 2], by)
            into.elements[i &+ 3] = Relaxed.product(elements[i &+ 3], by)
            i &+= 4
        }
        while i < elements.count {
            into.elements[i] = Relaxed.product(elements[i], by)
            i &+= 1
        }
    }
}
