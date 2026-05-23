//
//  UniqueVector dot UniqueVector.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//

import Numerics
import NumericsExtensions

//MARK: Dot, inner and outer product for AlgebraicField
public extension UniqueVector where T: AlgebraicField {
    /// Computes the Euclidian dot product. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>``` and ```Vector<Complex<Double>>``` use ```inner(_:)``` for a proper inner product
    @inlinable
    func dot(_ other: borrowing Self) -> T {
        precondition(other.count == count)
        var result: T = .zero
        for i in 0..<count {
            result = Relaxed.multiplyAdd(components[i], other.components[i], result)
        }
        return result
    }
    
    /// Computes the Euclidian dot product with a metric. For complex vectors, this is not a proper inner product!
    /// Instead for ```Vector<Complex<Float>>```and ```Vector<Complex<Double>>```use ```inner(_:,metric:)``` for a proper inner product.
    @inlinable
    func dot(metric: borrowing UniqueMatrix<T>, _ other: borrowing Self) -> T {
        precondition(count == metric.rows && other.count == metric.columns)
        var result: T = .zero
        for i in 0..<count {
            for j in 0..<other.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i], metric[unchecked: i , unchecked: j]), other[unchecked: j], result)
            }
        }
        return result
    }
}

public extension UniqueVector where T: AlgebraicField {
    //MARK: Outer product
    @inlinable
    func outer(_ other: borrowing Self) -> UniqueMatrix<T> {
        var result: UniqueMatrix<T> = .zeros(rows: count, columns: other.count)
        outer(other, into: &result)
        return result
    }
    
    @inlinable
    func outer(_ other: borrowing Self, into: inout UniqueMatrix<T>) {
        precondition(into.rows == count && into.columns == other.count)
        for i in 0..<count {
            for j in 0..<other.count {
                into[unchecked: i, unchecked: j] = Relaxed.product(components[i], other.components[j])
            }
        }
    }
    
    @inlinable
    func outer(_ other: borrowing Self, multiplied: T, into: inout UniqueMatrix<T>) {
        precondition(into.rows == count && into.columns == other.count)
        for i in 0..<count {
            for j in 0..<other.count {
                into[i, j] = Relaxed.product(multiplied, Relaxed.product(components[i], other.components[j]))
            }
        }
    }
    
    @inlinable
    func outer(_ other: borrowing Self, addingInto into: inout UniqueMatrix<T>) {
        precondition(into.rows == count && into.columns == other.count)
        for i in 0..<count {
            for j in 0..<other.count {
                into[unchecked: i, unchecked: j] = Relaxed.multiplyAdd(components[i], other.components[j], into[i, j])
            }
        }
    }
    
    @inlinable
    func outer(_ other: borrowing Self, multiplied: T, addingInto into: inout UniqueMatrix<T>) {
        precondition(into.rows == count && into.columns == other.count)
        for i in 0..<count {
            for j in 0..<other.count {
                into[unchecked: i, unchecked: j] = Relaxed.multiplyAdd(Relaxed.product(multiplied, components[i]), other.components[j], into[i, j])
            }
        }
    }
}

public extension UniqueVector where T: ConjugatableScalar {
    //MARK: Inner product
    @inlinable
    func inner(_ other: borrowing Self) -> T {
        precondition(count == other.count)
        var result: T = .zero
        for i in 0..<self.count {
            result = Relaxed.multiplyAdd(self[unchecked: i].conjugate, other[unchecked: i], result)
        }
        return result
    }

    @inlinable
    func inner(metric: Matrix<T>, _ other: borrowing Self) -> T {
        precondition(other.count == metric.columns)
        precondition(count == metric.rows)
        var result: T = .zero
        for i in 0..<count {
            for j in 0..<other.count {
                result = Relaxed.multiplyAdd(Relaxed.product(components[i].conjugate, metric[unchecked: i , unchecked: j]), other[unchecked: j], result)
            }
        }
        return result
    }
}

//MARK: Dot, inner and outer product for Double
public extension Vector<Double> {
    @inlinable
    func dotBLAS(_ other: Self) -> T {
        BLAS.ddot(count, components, 1, other.components, 1)
    }
    
    @inlinable
    func innerBLAS(_ other: Self) -> T {
        BLAS.ddot(count, components, 1, other.components, 1)
    }
}

//MARK: Dot, inner and outer product for Float
public extension Vector<Float> {
    @inlinable
    func dotBLAS(_ other: Self) -> T {
        BLAS.sdot(count, components, 1, other.components, 1)
    }
    
    @inlinable
    func innerBLAS(_ other: Self) -> T {
        BLAS.sdot(count, components, 1, other.components, 1)
    }
}

//MARK: Dot, inner and outer product for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    func dotBLAS(_ other: Self) -> T {
        BLAS.zdotu(count, components, 1, other.components, 1)
    }

    @inlinable
    func innerBLAS(_ other: Self) -> T {
        BLAS.zdotc(count, components, 1, other.components, 1)
    }
}

//MARK: Dot, inner and outer product for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    func dotBLAS(_ other: Self) -> T {
        BLAS.cdotu(count, components, 1, other.components, 1)
    }

    @inlinable
    func innerBLAS(_ other: Self) -> T {
        BLAS.cdotc(count, components, 1, other.components, 1)
    }
}
