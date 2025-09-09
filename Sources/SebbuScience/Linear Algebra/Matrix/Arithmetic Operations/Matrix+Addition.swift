//
//  Matrix+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

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
        precondition(self.rows == other.rows && self.columns == other.columns, "The dimensions of the matrices do not match")
        _add(other, multiplied: multiplied)
    }

    @inlinable
    mutating func _add(_ other: Self, multiplied: T) {
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in elementsSpan.indices {
            elementsSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], elementsSpan[unchecked: i])
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(self.rows == other.rows && self.columns == other.columns, "The dimensions of the matrices do not match")
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        for i in elementsSpan.indices {
            elementsSpan[unchecked: i] = Relaxed.sum(otherSpan[unchecked: i], elementsSpan[unchecked: i])
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
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other)
        } else {
            _add(other)
        }
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.daxpy(elements.count, multiplied, other.elements, 1, &elements, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.daxpy(elements.count, 1, other.elements, 1, &elements, 1)
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
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other)
        } else {
            _add(other)
        }
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.saxpy(elements.count, multiplied, other.elements, 1, &elements, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.saxpy(elements.count, 1, other.elements, 1, &elements, 1)
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
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other)
        } else {
            _add(other)
        }
    }

    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Double) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }

    @inlinable
    @_transparent
    mutating func _add(_ other: Self, multiplied: Double) {
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        elementsSpan.withUnsafeMutableBufferPointer { components in 
            otherSpan.withUnsafeBufferPointer { otherComponents in 
                let count = 2 * components.count
                components.baseAddress?.withMemoryRebound(to: Double.self, capacity: count) { components in 
                    otherComponents.baseAddress?.withMemoryRebound(to: Double.self, capacity: count) { otherComponents in 
                        for i in 0..<count {
                            components[i] = Relaxed.multiplyAdd(otherComponents[i], multiplied, components[i])
                        }
                    }
                }
            }
        }
        // This leads to unoptimal code...
        //var elementsSpan = elements.mutableSpan
        //let otherSpan = other.elements.span
        //for i in elementsSpan.indices {
        //    elementsSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], elementsSpan[unchecked: i])
        //}
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.zaxpy(elements.count, multiplied, other.elements, 1, &elements, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        _addBLAS(other, multiplied: Double(1))
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: Double) {
        BLAS.zaxpy(elements.count, multiplied, other.elements, 1, &elements, 1)
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
    mutating func add(_ other: Self, multiplied: T) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other)
        } else {
            _add(other)
        }
    }

    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Float) {
        precondition(rows == other.rows && columns == other.columns, "The dimensions of the matrices do not match")
        if BLAS.isAvailable {
            //TODO: Benchmark threshold after which we dispatch to BLAS
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }

    @inlinable
    @_transparent
    mutating func _add(_ other: Self, multiplied: Float) {
        var elementsSpan = elements.mutableSpan
        let otherSpan = other.elements.span
        elementsSpan.withUnsafeMutableBufferPointer { components in 
            otherSpan.withUnsafeBufferPointer { otherComponents in 
                let count = 2 * components.count
                components.baseAddress?.withMemoryRebound(to: Float.self, capacity: count) { components in 
                    otherComponents.baseAddress?.withMemoryRebound(to: Float.self, capacity: count) { otherComponents in 
                        for i in 0..<count {
                            components[i] = Relaxed.multiplyAdd(otherComponents[i], multiplied, components[i])
                        }
                    }
                }
            }
        }
        // This leads to unoptimal code...
        //var elementsSpan = elements.mutableSpan
        //let otherSpan = other.elements.span
        //for i in elementsSpan.indices {
        //    elementsSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], elementsSpan[unchecked: i])
        //}
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.caxpy(elements.count, multiplied, other.elements, 1, &elements, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        _addBLAS(other, multiplied: Float(1))
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: Float) {
        BLAS.caxpy(elements.count, multiplied, other.elements, 1, &elements, 1)
    }
}
