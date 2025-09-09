//
//  Vector Dot Vector.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

import NumericsExtensions

//MARK: Dot, inner and outer product for AlgebraicField
public extension Vector where T: AlgebraicField {
    /// Computes the Euclidian dot product. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>``` and ```Vector<Complex<Double>>``` use ```inner(_:)``` for a proper inner product
    @inlinable
    @_transparent
    func dot(_ other: Self) -> T {
        _dot(other)
    }

    @inlinable
    func _dot(_ other: Self) -> T {
        precondition(other.count == count)
        var result: T = .zero
        for i in 0..<components.count {
            result = Relaxed.multiplyAdd(components[i], other.components[i], result)
        }
        return result
    }
    
    /// Computes the Euclidian dot product with a metric. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>```and ```Vector<Complex<Double>>```use ```inner(_:,metric:)``` for a proper inner product.
    @inlinable
    @_transparent
    func dot(_ other: Self, metric: Matrix<T>) -> T {
        _dot(other, metric: metric)
    }

    @inlinable
    func _dot(_ other: Self, metric: Matrix<T>) -> T {
        precondition(other.count == metric.columns)
        precondition(count == metric.rows)
        var result: T = .zero
        for i in 0..<components.count {
            for j in 0..<other.components.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i], metric[i ,j]), other[j], result)
            }
        }
        return result
    }
    
    //MARK: Inner product
    @inlinable
    @_transparent
    func inner(_ other: Self) -> T {
        _inner(other)
    }

    @inlinable
    @_transparent
    func _inner(_ other: Self) -> T {
        _dot(other)
    }
    
    @inlinable
    @_transparent
    func inner(_ other: Self, metric: Matrix<T>) -> T {
        dot(other, metric: metric)
    }

    @inlinable
    @_transparent
    func _inner(_ other: Self, metric: Matrix<T>) -> T {
        dot(other, metric: metric)
    }
    
    //MARK: Outer product
    @inlinable
    func outer(_ other: Self) -> Matrix<T> {
        var result: Matrix<T> = .zeros(rows: count, columns: other.count)
        outer(other, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func outer(_ other: Self, into: inout Matrix<T>) {
        _outer(other, into: &into)
    }

    @inlinable
    func _outer(_ other: Self, into: inout Matrix<T>) {
        precondition(into.rows == count && into.columns == other.count)
        for i in 0..<count {
            for j in 0..<other.count {
                into[i, j] = Relaxed.product(components[i], other.components[j])
            }
        }
    }
}

//MARK: Dot, inner and outer product for Double
public extension Vector<Double> {
    @inlinable
    func dot(_ other: Self) -> T {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            return _dotBLAS(other)
        } else {
            return _dot(other)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self) -> T {
        BLAS.ddot(count, components, 1, other.components, 1)
    }

    @inlinable
    @_transparent
    func inner(_ other: Self) -> T {
        dot(other)
    }
}

//MARK: Dot, inner and outer product for Float
public extension Vector<Float> {
    @inlinable
    func dot(_ other: Self) -> T {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            return _dotBLAS(other)
        } else {
            return _dot(other)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self) -> T {
        BLAS.sdot(count, components, 1, other.components, 1)
    }

    @inlinable
    @_transparent
    func inner(_ other: Self) -> T {
        dot(other)
    }
}

//MARK: Dot, inner and outer product for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    func dot(_ other: Self) -> T {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            return _dotBLAS(other)
        } else {
            return _dot(other)
        }
    }

    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self) -> T {
        BLAS.zdotu(count, components, 1, other.components, 1)
    }
    
    @inlinable
    func inner(_ other: Self) -> T {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            return _innerBLAS(other)
        } else {
            return _inner(other)
        }
    }

    @inlinable
    @_transparent
    func _innerBLAS(_ other: Self) -> T {
        BLAS.zdotc(count, components, 1, other.components, 1)
    }

    @inlinable
    func _inner(_ other: Self) -> T {
        precondition(self.count == other.count)
        var result: T = .zero
        for i in 0..<self.count {
            result = Relaxed.multiplyAdd(self[i].conjugate, other[i], result)
        }
        return result
    }
    
    @inlinable
    func inner(_ other: Self, metric: Matrix<T>) -> T {
        precondition(other.count == metric.columns)
        precondition(count == metric.rows)
        var result: T = .zero
        for i in 0..<components.count {
            for j in 0..<other.components.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i].conjugate, metric[i ,j]), other[j], result)
            }
        }
        return result
    }
}

//MARK: Dot, inner and outer product for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    func dot(_ other: Self) -> T {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            return _dotBLAS(other)
        } else {
            return _dot(other)
        }
    }
    
    @inlinable
    @_transparent
    func _dotBLAS(_ other: Self) -> T {
        BLAS.cdotu(count, components, 1, other.components, 1)
    }

    @inlinable
    func inner(_ other: Self) -> T {
        precondition(count == other.count)
        if BLAS.isAvailable {
            //TODO: Benchmark threshold
            return _innerBLAS(other)
        } else {
            return _inner(other)
        }
    }

    @inlinable
    @_transparent
    func _innerBLAS(_ other: Self) -> T {
        BLAS.cdotc(count, components, 1, other.components, 1)
    }

    @inlinable
    internal func _inner(_ other: Self) -> T {
        precondition(self.count == other.count)
        var result: T = .zero
        for i in 0..<self.count {
            result = Relaxed.multiplyAdd(self[i].conjugate, other[i], result)
        }
        return result
    }
    
    @inlinable
    func inner(_ other: Self, metric: Matrix<T>) -> T {
        precondition(other.count == metric.columns)
        precondition(count == metric.rows)
        var result: T = .zero
        for i in 0..<components.count {
            for j in 0..<other.components.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i].conjugate, metric[i ,j]), other[j], result)
            }
        }
        return result
    }
}
