//
//  Matrix Dot Vector.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 10.5.2025.
//

import BLAS
import NumericsExtensions

//MARK: Matrix-Vector multiplication for AlgebraicField
public extension Matrix where T: AlgebraicField {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        _dot(vector, into: &into)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        _dot(vector, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        _dot(vector, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto: inout Vector<T>) {
        _dot(vector, multiplied: multiplied, addingInto: &addingInto)
    }

    @inlinable
    func _dot(_ vector: Vector<T>, into: inout Vector<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1]))
            into[1] = Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3]))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = result
        }
    }
    
    @inlinable
    func _dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1])))
            into[1] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3])))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.product(result, multiplied)
        }
    }
    
    @inlinable
    func _dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1])))
            into[1] = Relaxed.sum(into[1], Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3])))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.sum(result, into[i])
        }
    }
    
    @inlinable
    func _dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows == 2 && columns == 2 {
            into[0] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[0]), Relaxed.product(vector[1], elements[1])))
            into[1] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(vector[0], elements[2]), Relaxed.product(vector[1], elements[3])))
            return
        }
        for i in 0..<rows {
            var result: T = .zero
            for j in 0..<columns {
                result = Relaxed.multiplyAdd(self[i, j], vector[j], result)
            }
            into[i] = Relaxed.multiplyAdd(result, multiplied, into[i])
        }
    }
}

//MARK: Matrix-Vector multiplication for Double
public extension Matrix<Double> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        dot(vector, multiplied: 1.0, into: &into)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Double> and take into as UnsafeMutablePointer<Double>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let dgemv = BLAS.dgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            dgemv(layout, trans, m, n, multiplied, elements, lda, vector.components, 1, .zero, &into.components, 1)
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        _dot(vector, addingInto: &addingInto)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Double> and take addingInto as UnsafeMutablePointer<Double>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let dgemv = BLAS.dgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            dgemv(layout, trans, m, n, multiplied, elements, lda, vector.components, 1, 1.0, &into.components, 1)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}

//MARK: Matrix-Vector multiplication for Float
public extension Matrix<Float> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        dot(vector, multiplied: 1.0, into: &into)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Float> and take into as UnsafeMutablePointer<Float>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let sgemv = BLAS.sgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            sgemv(layout, trans, m, n, multiplied, elements, lda, vector.components, 1, .zero, &into.components, 1)
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        _dot(vector, addingInto: &addingInto)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Float> and take addingInto as UnsafeMutablePointer<Float>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let sgemv = BLAS.sgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            sgemv(layout, trans, m, n, multiplied, elements, lda, vector.components, 1, 1.0, &into.components, 1)
        } else {
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}

//MARK: Matrix-Vector multiplication for Complex<Double>
public extension Matrix<Complex<Double>> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        dot(vector, multiplied: .one, into: &into)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take into as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let zgemv = BLAS.zgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            let beta: T = .zero
            let incx = cblas_int(1), incy = cblas_int(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zgemv(layout, trans, m, n, alpha, elements, lda, vector.components, incx, beta, &into.components, incy)
                }
            }
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        _dot(vector, addingInto: &addingInto)
    }
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Double>> and take addingIntp as UnsafeMutablePointer<Complex<Double>>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let zgemv = BLAS.zgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            let beta: T = .one
            let incx = cblas_int(1), incy = cblas_int(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    zgemv(layout, trans, m, n, alpha, elements, lda, vector.components, incx, beta, &into.components, incy)
                }
            }
        } else {
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}

//MARK: Matrix-Vector multiplication for Complex<Float>
public extension Matrix<Complex<Float>> {
    @inlinable
    func dot(_ vector: Vector<T>) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T) -> Vector<T> {
        var result = Vector<T>.init(count: rows) { _ in }
        dot(vector, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        dot(vector, multiplied: .one, into: &into)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Float>> and take into as UnsafeMutablePointer<Complex<Float>>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, into: &into)
            return
        }
        if let cgemv = BLAS.cgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            let beta: T = .zero
            let incx = cblas_int(1), incy = cblas_int(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cgemv(layout, trans, m, n, alpha, elements, lda, vector.components, incx, beta, &into.components, incy)
                }
            }
        } else {
            _dot(vector, multiplied: multiplied, into: &into)
        }
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, addingInto: inout Vector<T>) {
        _dot(vector, addingInto: &addingInto)
    }
    
    //TODO: Make a version that takes vector as a UnsafePointer<Complex<Float>> and take addingInto as UnsafeMutablePointer<Complex<Float>>
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        if rows * columns <= 1000 {
            _dot(vector, multiplied: multiplied, addingInto: &into)
            return
        }
        if let cgemv = BLAS.cgemv {
            precondition(columns == vector.count)
            precondition(rows == into.count)
            let layout = BLAS.Layout.rowMajor.rawValue
            let trans = BLAS.Transpose.noTranspose.rawValue
            let m = cblas_int(rows), n = cblas_int(columns)
            let lda = n
            let beta: T = .one
            let incx = cblas_int(1), incy = cblas_int(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cgemv(layout, trans, m, n, alpha, elements, lda, vector.components, incx, beta, &into.components, incy)
                }
            }
        } else {
            _dot(vector, multiplied: multiplied, addingInto: &into)
        }
    }
}

//MARK: General Matrix-Vector multiplication
@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let dgemv = BLAS.dgemv, matrixRows &* matrixColumns > 1000 {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let m = cblas_int(matrixRows)
        let n = cblas_int(matrixColumns)
        dgemv(order, transA, m, n, multiplier, matrix, n, vector, 1, resultMultiplier, resultVector, 1)
    } else {
        var result: Double = .zero
        for i in 0..<matrixRows {
            result = .zero
            for j in 0..<matrixColumns {
                result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
            }
            resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
        }
    }
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>,  resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let sgemv = BLAS.sgemv, matrixRows &* matrixColumns > 1000 {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let m = cblas_int(matrixRows)
        let n = cblas_int(matrixColumns)
        sgemv(order, transA, m, n, multiplier, matrix, n, vector, 1, .zero, resultVector, 1)
    } else {
        var result: Float = .zero
        for i in 0..<matrixRows {
            result = .zero
            for j in 0..<matrixColumns {
                result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
            }
            resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
        }
    }
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let zgemv = BLAS.zgemv, matrixRows &* matrixColumns > 1000 {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let m = cblas_int(matrixRows)
        let n = cblas_int(matrixColumns)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                zgemv(order, transA, m, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
    } else {
        var result: Complex<Double> = .zero
        for i in 0..<matrixRows {
            result = .zero
            for j in 0..<matrixColumns {
                result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
            }
            resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
        }
    }
}

@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
    } else if let cgemv = BLAS.cgemv, matrixRows &* matrixColumns > 1000 {
        let order = BLAS.Order.rowMajor.rawValue
        let transA = BLAS.Transpose.noTranspose.rawValue
        let m = cblas_int(matrixRows)
        let n = cblas_int(matrixColumns)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cgemv(order, transA, m, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
    } else {
        var result: Complex<Float> = .zero
        for i in 0..<matrixRows {
            result = .zero
            for j in 0..<matrixColumns {
                result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
            }
            resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
        }
    }
}
