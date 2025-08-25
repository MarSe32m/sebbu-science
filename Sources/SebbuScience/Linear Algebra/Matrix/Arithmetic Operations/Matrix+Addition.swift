//
//  Matrix+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

//import BLAS
#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#endif
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
        
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span

        var i = 0
        while i &+ 4 <= elementsSpan.count {
            elementsSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], elementsSpan[unchecked: i])
            elementsSpan[unchecked: i &+ 1] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i &+ 1], elementsSpan[unchecked: i &+ 1])
            elementsSpan[unchecked: i &+ 2] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i &+ 2], elementsSpan[unchecked: i &+ 2])
            elementsSpan[unchecked: i &+ 3] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i &+ 3], elementsSpan[unchecked: i &+ 3])
            i &+= 4
        }
        while i < elementsSpan.count {
            elementsSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], elementsSpan[unchecked: i])
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
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span

        var i = 0
        while i &+ 4 <= elementsSpan.count {
            elementsSpan[unchecked: i] = Relaxed.sum(otherSpan[unchecked: i], elementsSpan[unchecked: i])
            elementsSpan[unchecked: i &+ 1] = Relaxed.sum(otherSpan[unchecked: i &+ 1], elementsSpan[unchecked: i &+ 1])
            elementsSpan[unchecked: i &+ 2] = Relaxed.sum(otherSpan[unchecked: i &+ 2], elementsSpan[unchecked: i &+ 2])
            elementsSpan[unchecked: i &+ 3] = Relaxed.sum(otherSpan[unchecked: i &+ 3], elementsSpan[unchecked: i &+ 3])
            i &+= 4
        }
        while i < elementsSpan.count {
            elementsSpan[unchecked: i] = Relaxed.sum(otherSpan[unchecked: i], elementsSpan[unchecked: i])
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
        #if canImport(COpenBlas) || canImport(_COpenBLASWindows)
        let N = blasint(elements.count)
        cblas_daxpy(N, multiplied, other.elements, 1, &elements, 1)
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
        if let daxpy = BLAS.daxpy {
            precondition(rows == other.rows)
            precondition(columns == other.columns)
            let N = cblas_int(elements.count)
            daxpy(N, multiplied, other.elements, 1, &elements, 1)
        } else {
            _add(other, multiplied: multiplied)
        }
        #else
        _add(other, multiplied: multiplied)
        #endif
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
        precondition(rows == other.rows)
        precondition(columns == other.columns)
        #if canImport(COpenBlas) || canImport(_COpenBLASWindows)
        let N = blasint(elements.count)
        cblas_saxpy(N, multiplied, other.elements, 1, &elements, 1)
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
        if let saxpy = BLAS.saxpy {
            let N = cblas_int(elements.count)
            saxpy(N, multiplied, other.elements, 1, &elements, 1)
        } else {
            _add(other, multiplied: multiplied)
        }
        #else
        _add(other, multiplied: multiplied)
        #endif
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
        #if canImport(COpenBlas) || canImport(_COpenBLASWindows)
        precondition(rows == other.rows)
        precondition(columns == other.columns)
        let N = blasint(elements.count)
        withUnsafePointer(to: multiplied) { alpha in 
            cblas_zaxpy(N, alpha, other.elements, 1, &elements, 1)
        }
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
        if let zaxpy = BLAS.zaxpy {
            let N = cblas_int(elements.count)
            withUnsafePointer(to: multiplied) { alpha in
                zaxpy(N, alpha, other.elements, 1, &elements, 1)
            }
        } else {
            _add(other, multiplied: multiplied)
        }
        #else
        _add(other, multiplied: multiplied)
        #endif
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
        #if canImport(COpenBlas) || canImport(_COpenBLASWindows)
        precondition(rows == other.rows)
        precondition(columns == other.columns)
        let N = blasint(elements.count)
        withUnsafePointer(to: multiplied) { alpha in 
            cblas_caxpy(N, alpha, other.elements, 1, &elements, 1)
        }
        #elseif canImport(Accelerate)
        #error("TODO: Reimplement")
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
        #else
        _add(other, multiplied: multiplied)
        #endif
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
