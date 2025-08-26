//
//  Vector Dot Matrix.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 11.5.2025.
//

#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

import NumericsExtensions

//MARK: Vector-Matrix multiplication for AlgebraicField
public extension Vector where T: AlgebraicField {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        _dot(matrix, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto: inout Self) {
        _dot(matrix, addingInto: &addingInto)
    }

    @inlinable
    func _dot(_ matrix: Matrix<T>, into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2]))
            into[1] = Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3]))
            return
        }
        for i in 0..<into.count { into[i] = .zero }
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(self[j], matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto: inout Self) {
        _dot(matrix, multiplied: multiplied, addingInto: &addingInto)
    }

    @inlinable
    func _dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2])))
            into[1] = Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3])))
            return
        }
        for i in 0..<into.count { into[i] = .zero }
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[j], multiplied)
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(C, matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    func _dot(_ matrix: Matrix<T>, addingInto into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2])))
            into[1] = Relaxed.sum(into[1], Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3])))
            return
        }
        for j in 0..<matrix.rows {
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(self[j], matrix[j, i], into[i])
            }
        }
    }
    
    @inlinable
    func _dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(count == matrix.rows)
        if matrix.rows == 2 && matrix.columns == 2 {
            into[0] = Relaxed.sum(into[0], Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[0]), Relaxed.product(components[1], matrix.elements[2]))))
            into[1] = Relaxed.sum(into[1], Relaxed.product(multiplied, Relaxed.sum(Relaxed.product(components[0], matrix.elements[1]), Relaxed.product(components[1], matrix.elements[3]))))
            return
        }
        for j in 0..<matrix.rows {
            let C = Relaxed.product(self[j], multiplied)
            for i in 0..<matrix.columns {
                into[i] = Relaxed.multiplyAdd(C, matrix[j, i], into[i])
            }
        }
    }
}

//MARK: Vector-Matrix multiplication for Double
public extension Vector<Double> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto: inout Self) {
        dot(matrix, multiplied: 1.0, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .zero
            cblas_dgemv(layout, trans, m, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
            return
        } 
        #endif
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = 1.0
            cblas_dgemv(layout, trans, m, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }
}

//MARK: Vector-Matrix multiplication for Float
public extension Vector<Float> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: 1.0, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto: inout Self) {
        dot(matrix, multiplied: 1.0, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .zero
            cblas_sgemv(layout, trans, m, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = 1.0
            cblas_sgemv(layout, trans, m, n, multiplied, matrix.elements, lda, components, 1, beta, &into.components, 1)
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }
}

//MARK: Vector-Matrix multiplication for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: .one, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, addingInto: inout Self) {
        dot(matrix, multiplied: .one, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in 
                                cblas_zgemv(layout, trans, m, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in 
                                cblas_zgemv(layout, trans, m, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }
}

//MARK: Vector-Matrix multiplication for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    func dot(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dot(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, into: inout Self) {
        dot(matrix, multiplied: .one, into: &into)
    }
    
    @inlinable
    @_transparent
    func dot(_ matrix: Matrix<T>, addingInto: inout Self) {
        dot(matrix, multiplied: .one, addingInto: &addingInto)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in 
                                cblas_cgemv(layout, trans, m, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dot(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_cgemv(layout, trans, m, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasTrans
            let m = blasint(matrix.rows)
            let n = blasint(matrix.columns)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in 
                                cblas_cgemv(layout, trans, m, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, _ resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        cblas_dgemv(order, transA, m, n, multiplier, matrix, n, vector, 1, resultMultiplier, resultVector, 1)
        return
    }
    #endif
    var result: Double = .zero
    for i in 0..<matrixRows {
        result = .zero
        for j in 0..<matrixColumns {
            result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
        }
        resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
    }
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>, _ resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        cblas_sgemv(order, transA, m, n, multiplier, matrix, n, vector, 1, resultMultiplier, resultVector, 1)
        return
    }
    #endif
    var result: Float = .zero
    for i in 0..<matrixRows {
        result = .zero
        for j in 0..<matrixColumns {
            result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
        }
        resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
    }
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_zgemv(order, transA, m, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
        return
    }
    #elseif canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_zgemv(order, transA, m, n, .init(alpha), .init(matrix), n, .init(vector), 1, .init(beta), .init(resultVector), 1)
            }
        }
        return
    }
    #endif
    var result: Complex<Double> = .zero
    for i in 0..<matrixRows {
        result = .zero
        for j in 0..<matrixColumns {
            result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
        }
        resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
    }
}

@inlinable
public func vecMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_cgemv(order, transA, m, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
        return
    }
    #elseif canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_cgemv(order, transA, m, n, .init(alpha), .init(matrix), n, .init(vector), 1, .init(beta), .init(resultVector), 1)
            }
        }
        return
    }
    #endif
    var result: Complex<Float> = .zero
    for i in 0..<matrixRows {
        result = .zero
        for j in 0..<matrixColumns {
            result = Relaxed.multiplyAdd(resultVector[j], matrix[i &* matrixColumns &+ j], result)
        }
        resultVector[i] = Relaxed.multiplyAdd(resultMultiplier, resultVector[i], Relaxed.product(multiplier, resultVector[i]))
    }
}
