//
//  Matrix+Division.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import NumericsExtensions

//MARK: Division for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
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
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
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
        precondition(elements.count == into.elements.count)
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal, into: &into)
        } else {
            let elementsSpan = elements.span
            var intoSpan = into.elements.mutableSpan
            var i = 0
            while i &+ 4 <= elementsSpan.count {
                intoSpan[unchecked: i] = elementsSpan[unchecked: i] / by
                intoSpan[unchecked: i &+ 1] = elementsSpan[unchecked: i &+ 1] / by
                intoSpan[unchecked: i &+ 2] = elementsSpan[unchecked: i &+ 2] / by
                intoSpan[unchecked: i &+ 3] = elementsSpan[unchecked: i &+ 3] / by
                i &+= 4
            }
            while i < elementsSpan.count {
                intoSpan[unchecked: i] = elementsSpan[unchecked: i] / by
                i &+= 1
            }
        }
    }
}

//MARK: Division for Double
public extension Matrix<Double> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
            }
        }
    }
    
    @inlinable
    @_transparent
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }
}

//MARK: Division for Float
public extension Matrix<Float> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
            }
        }
    }
    
    @inlinable
    @_transparent
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }
}

//MARK: Division for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    static func /(lhs: Self, rhs: Double) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Double) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
            }
        }
    }
    
    @inlinable
    mutating func divide(by: Double) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
            }
        }
    }
    
    @inlinable
    @_transparent
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }
    
    @inlinable
    func divide(by: Double, into: inout Self) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal, into: &into)
        } else {
            precondition(elements.count == into.elements.count)
            let elementsSpan = elements.span
            var intoSpan = into.elements.mutableSpan
            var i = 0
            while i &+ 4 <= elementsSpan.count {
                intoSpan[unchecked: i] = elementsSpan[unchecked: i] / by
                intoSpan[unchecked: i] = elementsSpan[unchecked: i &+ 1] / by
                intoSpan[unchecked: i] = elementsSpan[unchecked: i &+ 2] / by
                intoSpan[unchecked: i] = elementsSpan[unchecked: i &+ 3] / by
                i &+= 4
            }
            while i < elementsSpan.count {
                intoSpan[unchecked: i] = elementsSpan[unchecked: i] / by
                i &+= 1
            }
        }
    }
}


//MARK: Division for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    static func /(lhs: Self, rhs: T) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    @_transparent
    static func /=(lhs: inout Self, rhs: T) {
        lhs.divide(by: rhs)
    }
    
    
    @inlinable
    static func /(lhs: Self, rhs: Float) -> Self {
        var resultMatrix: Self = Matrix(elements: lhs.elements, rows: lhs.rows, columns: lhs.columns)
        resultMatrix.divide(by: rhs)
        return resultMatrix
    }
    
    @inlinable
    static func /=(lhs: inout Self, rhs: Float) {
        lhs.divide(by: rhs)
    }
    
    @inlinable
    @_transparent
    mutating func divide(by: T) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
            }
        }
    }
    
    
    @inlinable
    mutating func divide(by: Float) {
        if let recip = by.reciprocal {
            multiply(by: recip)
        } else {
            var span = elements.mutableSpan
            var i = 0
            while i &+ 4 <= span.count {
                span[unchecked: i] /= by
                span[unchecked: i &+ 1] /= by
                span[unchecked: i &+ 2] /= by
                span[unchecked: i &+ 3] /= by
                i &+= 4
            }
            while i < span.count {
                span[unchecked: i] /= by
                i &+= 1
            }
        }
    }
    
    @inlinable
    @_transparent
    func divide(by: T, into: inout Self) {
        _divide(by: by, into: &into)
    }
    
    @inlinable
    func divide(by: Float, into: inout Self) {
        if let reciprocal = by.reciprocal {
            multiply(by: reciprocal, into: &into)
        } else {
            precondition(elements.count == into.elements.count)
            let elementsSpan = elements.span
            var intoSpan = into.elements.mutableSpan
            var i = 0
            while i &+ 4 <= elementsSpan.count {
                intoSpan[unchecked: i] = elementsSpan[unchecked: i] / by
                intoSpan[unchecked: i] = elementsSpan[unchecked: i &+ 1] / by
                intoSpan[unchecked: i] = elementsSpan[unchecked: i &+ 2] / by
                intoSpan[unchecked: i] = elementsSpan[unchecked: i &+ 3] / by
                i &+= 4
            }
            while i < elementsSpan.count {
                intoSpan[unchecked: i] = elementsSpan[unchecked: i] / by
                i &+= 1
            }
        }
    }
}
