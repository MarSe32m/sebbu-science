//
//  Vector Dot Matrix Hermitian.swift
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

//MARK: Hermitian Vector-Matrix multiplication for Complex<Double>
public extension Vector<Complex<Double>> {
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, into: inout Self) {
        dotHermitian(matrix, multiplied: .one, into: &into)
    }
    
    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, addingInto into: inout Self) {
        dotHermitian(matrix, multiplied: .one, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            // We use column major since we want to use the transpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zhemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            // We use column major since we want to use the transpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in 
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in
                                cblas_zhemv(order, uplo, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        //TODO: Implement vector - hermitian matrix multiply (default implementation)
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            // We use column major since we want to use the transpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zhemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            precondition(matrix.rows == count)
            precondition(matrix.columns == into.count)
            // We use column major since we want to use the transpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in 
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in
                                cblas_zhemv(order, uplo, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        //TODO: Implement vector - hermitian matrix multiply (default implementation)
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }
}

//MARK: Hermitian Vector-Matrix multiplication for Complex<Float>
public extension Vector<Complex<Float>> {
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, into: &result)
        return result
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T) -> Self {
        var result: Self = .zero(matrix.columns)
        dotHermitian(matrix, multiplied: multiplied, into: &result)
        return result
    }
    
    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, into: inout Self) {
        dotHermitian(matrix, multiplied: .one, into: &into)
    }
    
    @inlinable
    @_transparent
    func dotHermitian(_ matrix: Matrix<T>, addingInto into: inout Self) {
        dotHermitian(matrix, multiplied: .one, addingInto: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            // We use column major since we want the tranpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_chemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            // We use column major since we want the tranpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .zero
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in 
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in
                                cblas_chemv(order, uplo, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        //TODO: Implement vector - hermitian matrix multiply (default implementation)
        _dot(matrix, multiplied: multiplied, into: &into)
    }
    
    @inlinable
    func dotHermitian(_ matrix: Matrix<T>, multiplied: T, addingInto into: inout Self) {
        precondition(matrix.rows == count)
        precondition(matrix.columns == into.count)
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if matrix.rows &* matrix.columns > 400 {
            // We use column major since we want the tranpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_chemv(order, uplo, n, alpha, matrix.elements, lda, components, 1, beta, &into.components, 1)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if matrix.rows &* matrix.columns > 400 {
            // We use column major since we want the tranpose of the matrix here
            let order = CblasColMajor
            let uplo = CblasUpper
            let n = blasint(matrix.rows)
            let lda = n
            let beta: T = .one
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    matrix.elements.withUnsafeBufferPointer { matrix in 
                        components.withUnsafeBufferPointer { components in 
                            into.components.withUnsafeMutableBufferPointer { intoComponents in
                                cblas_chemv(order, uplo, n, .init(alpha), .init(matrix.baseAddress), lda, .init(components.baseAddress), 1, .init(beta), .init(intoComponents.baseAddress), 1)
                            }
                        }
                    }
                }
            }
            return
        }
        #endif
        //TODO: Implement vector - hermitian matrix multiply (default implementation)
        _dot(matrix, multiplied: multiplied, addingInto: &into)
    }
}

@inlinable
public func vecHermitianMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasColMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_zhemv(order, uplo, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
        return
    }
    #elseif canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasColMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_zhemv(order, uplo, n, .init(alpha), .init(matrix), n, .init(vector), 1, .init(beta), .init(resultVector), 1)
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
public func vecHermitianMatMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }

    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasColMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_chemv(order, uplo, n, alpha, matrix, n, vector, 1, beta, resultVector, 1)
            }
        }
        return
    }
    #elseif canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasColMajor
        let uplo = CblasUpper
        let n = blasint(matrixRows)
        withUnsafePointer(to: multiplier) { alpha in
            withUnsafePointer(to: resultMultiplier) { beta in
                cblas_chemv(order, uplo, n, .init(alpha), .init(matrix), n, .init(vector), 1, .init(beta), .init(resultVector), 1)
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
