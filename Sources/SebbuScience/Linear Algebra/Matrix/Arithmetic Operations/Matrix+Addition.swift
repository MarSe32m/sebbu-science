//
//  Matrix+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Addition for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }

    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: T) {
        _add(other, multiplied: multiplied)
    }

    @inlinable
    mutating func _add(_ other: Self, multiplied: T) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        var i = 0
        while i &+ 4 <= elements.count {
            elements[i] = Relaxed.multiplyAdd(multiplied, other.elements[i], elements[i])
            elements[i &+ 1] = Relaxed.multiplyAdd(multiplied, other.elements[i &+ 1], elements[i &+ 1])
            elements[i &+ 2] = Relaxed.multiplyAdd(multiplied, other.elements[i &+ 2], elements[i &+ 2])
            elements[i &+ 3] = Relaxed.multiplyAdd(multiplied, other.elements[i &+ 3], elements[i &+ 3])
            i &+= 4
        }
        while i < elements.count {
            elements[i] = Relaxed.multiplyAdd(multiplied, other.elements[i], elements[i])
            i &+= 1
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        precondition(self.rows == other.rows)
        precondition(self.columns == other.columns)
        var i = 0
        while i &+ 4 <= elements.count {
            elements[i] = Relaxed.sum(other.elements[i], elements[i])
            elements[i &+ 1] = Relaxed.sum(other.elements[i &+ 1], elements[i &+ 1])
            elements[i &+ 2] = Relaxed.sum(other.elements[i &+ 2], elements[i &+ 2])
            elements[i &+ 3] = Relaxed.sum(other.elements[i &+ 3], elements[i &+ 3])
            i &+= 4
        }
        while i < elements.count {
            elements[i] = Relaxed.sum(other.elements[i], elements[i])
            i &+= 1
        }
    }
}

//MARK: Addition for Double
public extension Matrix<Double> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }

    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if let daxpy = BLAS.daxpy {
            precondition(rows == other.rows)
            precondition(columns == other.columns)
            let N = cblas_int(elements.count)
            daxpy(N, multiplied, other.elements, 1, &elements, 1)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: 1.0)
    }
}

//MARK: Addition for Float
public extension Matrix<Float> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }

    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if let saxpy = BLAS.saxpy {
            precondition(rows == other.rows)
            precondition(columns == other.columns)
            let N = cblas_int(elements.count)
            saxpy(N, multiplied, other.elements, 1, &elements, 1)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: 1.0)
    }
}

//MARK: Addition for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }

    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if let zaxpy = BLAS.zaxpy {
            precondition(rows == other.rows)
            precondition(columns == other.columns)
            let N = cblas_int(elements.count)
            withUnsafePointer(to: multiplied) { alpha in
                zaxpy(N, alpha, other.elements, 1, &elements, 1)
            }
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: .one)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Double) {
        add(other, multiplied: Complex(multiplied))
    }
}

//MARK: Addition for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var resultMatrix: Self = Self(elements: Array(lhs.elements), rows: lhs.rows, columns: lhs.columns)
        resultMatrix.add(rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }

    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: T) {
        if let caxpy = BLAS.caxpy {
            precondition(rows == other.rows)
            precondition(columns == other.columns)
            let N = cblas_int(elements.count)
            withUnsafePointer(to: multiplied) { alpha in
                caxpy(N, alpha, other.elements, 1, &elements, 1)
            }
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        add(other, multiplied: .one)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: Float) {
        add(other, multiplied: Complex(multiplied))
    }
}
