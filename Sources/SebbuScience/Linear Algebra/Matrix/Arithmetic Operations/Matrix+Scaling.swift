//
//  Matrix+Scaling.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//
#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

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
        var i = 0
        while i &+ 4 <= span.count {
            span[unchecked: i] = Relaxed.product(by, span[unchecked: i])
            span[unchecked: i &+ 1] = Relaxed.product(by, span[unchecked: i &+ 1])
            span[unchecked: i &+ 2] = Relaxed.product(by, span[unchecked: i &+ 2])
            span[unchecked: i &+ 3] = Relaxed.product(by, span[unchecked: i &+ 3])
            i &+= 4
        }
        while i < span.count {
            span[unchecked: i] = Relaxed.product(by, span[unchecked: i])
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
        let elementsSpan = elements.span
        var intoSpan = into.elements.mutableSpan
        var i = 0
        while i &+ 4 <= intoSpan.count {
            intoSpan[unchecked: i] = Relaxed.product(elementsSpan[unchecked: i], by)
            intoSpan[unchecked: i &+ 1] = Relaxed.product(elementsSpan[unchecked: i &+ 1], by)
            intoSpan[unchecked: i &+ 2] = Relaxed.product(elementsSpan[unchecked: i &+ 2], by)
            intoSpan[unchecked: i &+ 3] = Relaxed.product(elementsSpan[unchecked: i &+ 3], by)
            i &+= 4
        }
        while i < intoSpan.count {
            intoSpan[unchecked: i] = Relaxed.product(elementsSpan[unchecked: i], by)
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(elements.count)
        cblas_dscal(N, by, &elements, 1)
        #else
        _multiply(by: by)
        #endif
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        let N = blasint(elements.count)
        cblas_sscal(N, by, &elements, 1)
        #else
        _multiply(by: by)
        #endif
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(elements.count)
        withUnsafePointer(to: by) { alpha in 
            cblas_zscal(N, alpha, &elements, 1)
        }
        #elseif canImport(Accelerate)
        let N = blasint(elements.count)
        withUnsafePointer(to: by) { alpha in 
            elements.withUnsafeMutableBufferPointer { elements in 
                cblas_zscal(N, .init(alpha), .init(elements.baseAddress), 1)
            }
        }
        #else
        _multiply(by: by)
        #endif
    }
    
    @inlinable
    mutating func multiply(by: Double) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(elements.count)
        cblas_zdscal(N, by, &elements, 1)
        #elseif canImport(Accelerate)
        let N = blasint(elements.count)
        elements.withUnsafeMutableBufferPointer { elements in 
            cblas_zdscal(N, by, .init(elements.baseAddress), 1)
        }
        #else
        var span = elements.mutableSpan
        var i = 0
        while i &+ 4 < span.count {
            span[unchecked: i] = Relaxed.product(span[unchecked: i], by)
            span[unchecked: i &+ 1] = Relaxed.product(span[unchecked: i &+ 1], by)
            span[unchecked: i &+ 2] = Relaxed.product(span[unchecked: i &+ 2], by)
            span[unchecked: i &+ 3] = Relaxed.product(span[unchecked: i &+ 3], by)
            i &+= 4
        }
        while i < span.count {
            span[unchecked: i] = Relaxed.product(span[unchecked: i], by)
            i &+= 1
        }
        #endif
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
    
    @inlinable
    func multiply(by: Double, into: inout Self) {
        let elementsSpan = elements.span
        var intoSpan = into.elements.mutableSpan
        var i = 0
        while i &+ 4 <= elementsSpan.count {
            intoSpan[unchecked: i] = Relaxed.product(elementsSpan[unchecked: i], by)
            intoSpan[unchecked: i &+ 1] = Relaxed.product(elementsSpan[unchecked: i &+ 1], by)
            intoSpan[unchecked: i &+ 2] = Relaxed.product(elementsSpan[unchecked: i &+ 2], by)
            intoSpan[unchecked: i &+ 3] = Relaxed.product(elementsSpan[unchecked: i &+ 3], by)
            i &+= 4
        }
        while i < elementsSpan.count {
            intoSpan[unchecked: i] = Relaxed.product(elementsSpan[unchecked: i], by)
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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(elements.count)
        withUnsafePointer(to: by) { alpha in
            cblas_cscal(N, alpha, &elements, 1)
        }
        #elseif canImport(Accelerate)
        let N = blasint(elements.count)
        withUnsafePointer(to: by) { alpha in 
            elements.withUnsafeMutableBufferPointer { elements in 
                cblas_cscal(N, .init(alpha), .init(elements.baseAddress), 1)
            }
        }
        #else
        _multiply(by: by)
        #endif
    }
    
    mutating func multiply(by: Float) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let N = blasint(elements.count)
        cblas_csscal(N, by, &elements, 1)
        #elseif canImport(Accelerate)
        let N = blasint(elements.count)
        elements.withUnsafeMutableBufferPointer { elements in 
            cblas_csscal(N, by, .init(elements.baseAddress), 1)
        }
        #else
        var span = elements.mutableSpan
        var i = 0
        while i &+ 4 < span.count {
            span[unchecked: i] = Relaxed.product(span[unchecked: i], by)
            span[unchecked: i &+ 1] = Relaxed.product(span[unchecked: i &+ 1], by)
            span[unchecked: i &+ 2] = Relaxed.product(span[unchecked: i &+ 2], by)
            span[unchecked: i &+ 3] = Relaxed.product(span[unchecked: i &+ 3], by)
            i &+= 4
        }
        while i < span.count {
            span[unchecked: i] = Relaxed.product(span[unchecked: i], by)
            i &+= 1
        }
        #endif
    }
    
    @inlinable
    @_transparent
    func multiply(by: T, into: inout Self) {
        _multiply(by: by, into: &into)
    }
    
    @inlinable
    func multiply(by: Float, into: inout Self) {
        let elementsSpan = elements.span
        var intoSpan = into.elements.mutableSpan
        var i = 0
        while i &+ 4 <= elementsSpan.count {
            intoSpan[unchecked: i] = Relaxed.product(elementsSpan[unchecked: i], by)
            intoSpan[unchecked: i &+ 1] = Relaxed.product(elementsSpan[unchecked: i &+ 1], by)
            intoSpan[unchecked: i &+ 2] = Relaxed.product(elementsSpan[unchecked: i &+ 2], by)
            intoSpan[unchecked: i &+ 3] = Relaxed.product(elementsSpan[unchecked: i &+ 3], by)
            i &+= 4
        }
        while i < elementsSpan.count {
            intoSpan[unchecked: i] = Relaxed.product(elementsSpan[unchecked: i], by)
            i &+= 1
        }
    }
}
