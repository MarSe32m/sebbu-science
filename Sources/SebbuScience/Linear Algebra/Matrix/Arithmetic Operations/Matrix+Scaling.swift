//
//  Matrix+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

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
        var span = elements.mutableSpan
        for i in span.indices {
            span[unchecked: i] = Relaxed.product(by, span[unchecked: i])
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
        if BLAS.isAvailable {
            //TODO: Benchmark against basic implementation and find threshold
            _multiplyBLAS(by: by)
        } else {
            _multiply(by: by)
        }
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.dscal(elements.count, by, &elements, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark against basic implementation and find threshold
            _multiplyBLAS(by: by)
        } else {
            _multiply(by: by)
        }
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.sscal(elements.count, by, &elements, 1)
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
        if BLAS.isAvailable {
            //TODO: Benchmark against basic implementation and find threshold
            _multiplyBLAS(by: by)
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        if BLAS.isAvailable {
            //TODO: Benchmark against basic implementation and find threshold
            _multiplyBLAS(by: by)
        } else {
            _multiply(by: by)
        }
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: Double) {
        var elementsSpan = elements.mutableSpan
        elementsSpan.withUnsafeMutableBufferPointer { elements in 
            let count = 2 * elements.count
            elements.baseAddress?.withMemoryRebound(to: Double.self, capacity: count) { elements in 
                for i in 0..<count {
                    elements[i] = Relaxed.product(elements[i], by)
                }
            }
        }
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.zscal(elements.count, by, &elements, 1)
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: Double) {
        BLAS.zdscal(elements.count, by, &elements, 1)
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
    mutating func multiply(by: T) {
        if BLAS.isAvailable {
            //TODO: Benchmark against basic implementation and find threshold
            _multiplyBLAS(by: by)
        } else {
            _multiply(by: by)
        }
    }
    
    @inlinable
    mutating func multiply(by: Float) {
        if BLAS.isAvailable {
            //TODO: Benchmark against basic implementation and find threshold
            _multiplyBLAS(by: by)
        } else {
            _multiply(by: by)
        }
    }

    @inlinable
    @_transparent
    mutating func _multiply(by: Float) {
        var elementsSpan = elements.mutableSpan
        elementsSpan.withUnsafeMutableBufferPointer { elements in 
            let count = 2 * elements.count
            elements.baseAddress?.withMemoryRebound(to: Float.self, capacity: count) { elements in 
                for i in 0..<count {
                    elements[i] = Relaxed.product(elements[i], by)
                }
            }
        }
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: T) {
        BLAS.cscal(elements.count, by, &elements, 1)
    }

    @inlinable
    @_transparent
    mutating func _multiplyBLAS(by: Float) {
        BLAS.csscal(elements.count, by, &elements, 1)
    }
}
