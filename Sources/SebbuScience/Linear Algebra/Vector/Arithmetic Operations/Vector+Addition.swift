//
//  Vector+Addition.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import NumericsExtensions

//MARK: Addition for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: T) {
        precondition(other.components.count == self.components.count)
        _add(other, multiplied: multiplied)
    }
    
    @inlinable
    mutating func _add(_ other: Self, multiplied: T) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in componentSpan.indices {
            componentSpan[i] = Relaxed.multiplyAdd(multiplied, otherSpan[i], componentSpan[i])
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        precondition(other.components.count == self.components.count)
        _add(other)
    }

    @inlinable
    mutating func _add(_ other: Self) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        for i in componentSpan.indices {
            componentSpan[unchecked: i] = Relaxed.sum(componentSpan[unchecked: i], otherSpan[unchecked: i])
        }
    }
}

//MARK: Addition for Double
public extension Vector<Double> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other)
        } else {
            _add(other)
        }
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.daxpy(components.count, multiplied, other.components, 1, &components, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.daxpy(components.count, 1.0, other.components, 1, &components, 1)
    }
}

//MARK: Addition for Float
public extension Vector<Float> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other)
        } else {
            _add(other)
        }
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.saxpy(components.count, multiplied, other.components, 1, &components, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.saxpy(components.count, 1.0, other.components, 1, &components, 1)
    }
}

//MARK: Addition for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other)
        } else {
            _add(other)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Double) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }

    @inlinable
    @_transparent
    mutating func _add(_ other: Self, multiplied: Double) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        componentSpan.withUnsafeMutableBufferPointer { components in 
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
        //var componentSpan = components.mutableSpan
        //let otherSpan = other.components.span
        //for i in componentSpan.indices {
        //    componentSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], componentSpan[unchecked: i])
        //}
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.zaxpy(components.count, multiplied, other.components, 1, &components, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: Double) {
        BLAS.zaxpy(components.count, multiplied, other.components, 1, &components, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.zaxpy(components.count, 1.0, other.components, 1, &components, 1)
    }
}

//MARK: Addition for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var result = Vector(Array(lhs.components))
        result.add(rhs)
        return result
    }
    
    @inlinable
    @_transparent
    static func +=(lhs: inout Self, rhs: Self) {
        lhs.add(rhs)
    }
    
    @inlinable
    mutating func add(_ other: Self, multiplied: T) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other)
        } else {
            _add(other)
        }
    }
    
    @inlinable
    @_transparent
    mutating func add(_ other: Self, multiplied: Float) {
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            _addBLAS(other, multiplied: multiplied)
        } else {
            _add(other, multiplied: multiplied)
        }
    }

    @inlinable
    @_transparent
    mutating func _add(_ other: Self, multiplied: Float) {
        var componentSpan = components.mutableSpan
        let otherSpan = other.components.span
        componentSpan.withUnsafeMutableBufferPointer { components in 
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
        //var componentSpan = components.mutableSpan
        //let otherSpan = other.components.span
        //for i in componentSpan.indices {
        //    componentSpan[unchecked: i] = Relaxed.multiplyAdd(multiplied, otherSpan[unchecked: i], componentSpan[unchecked: i])
        //}
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: T) {
        BLAS.caxpy(components.count, multiplied, other.components, 1, &components, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self, multiplied: Float) {
        BLAS.caxpy(components.count, multiplied, other.components, 1, &components, 1)
    }

    @inlinable
    @_transparent
    mutating func _addBLAS(_ other: Self) {
        BLAS.caxpy(components.count, 1.0, other.components, 1, &components, 1)
    }
}
