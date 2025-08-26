//
//  Matrix Dot Vector.swift
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
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        _dot(vector, into: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto: UnsafeMutablePointer<T>) {
        _dot(vector, addingInto: addingInto)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto: UnsafeMutablePointer<T>) {
        _dot(vector, multiplied: multiplied, addingInto: addingInto)
    }

    @inlinable
    @_transparent
    func _dot(_ vector: Vector<T>, into: inout Vector<T>) {
        _dot(vector.components, into: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
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
    @_transparent
    func _dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        _dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
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
    @_transparent
    func _dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        _dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
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
    @_transparent
    func _dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        _dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func _dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
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
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = 1.0
            cblas_dgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .zero, into, 1)
            return
        } 
        #endif
        _dot(vector, into: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            cblas_dgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .zero, into, 1)
            return
        }
        #endif
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = 1.0
            cblas_dgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, 1.0, into, 1)
            return
        }
        #endif
        _dot(vector, addingInto: into)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            cblas_dgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, 1.0, into, 1)
            return
        }
        #endif
        _dot(vector, multiplied: multiplied, addingInto: into)
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
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = 1.0
            cblas_sgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, .zero, into, 1)
            return
        }
        #endif
        _dot(vector, into: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            cblas_sgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, .zero, into, 1)
            return
        }
        #endif
        _dot(vector, multiplied: multiplied, into: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = 1.0
            cblas_sgemv(layout, trans, m, n, alpha, elements, lda, vector, 1, 1.0, into, 1)
            return
        }
        #endif
        _dot(vector, addingInto: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            cblas_sgemv(layout, trans, m, n, multiplied, elements, lda, vector, 1, 1.0, into, 1)
            return
        }
        #endif
        _dot(vector, multiplied: multiplied, addingInto: into)
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
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, into: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, into: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, addingInto: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_zgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_zgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, multiplied: multiplied, addingInto: into)
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
    @_transparent
    func dot(_ vector: Vector<T>, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, addingInto: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, into: &into.components)
    }
    
    @inlinable
    @_transparent
    func dot(_ vector: Vector<T>, multiplied: T, addingInto into: inout Vector<T>) {
        precondition(columns == vector.count)
        precondition(rows == into.count)
        dot(vector.components, multiplied: multiplied, addingInto: &into.components)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_cgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_cgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, into: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, multiplied: T, into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_cgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .zero
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_cgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, into: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_cgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let alpha: T = .one
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: alpha) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_cgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, addingInto: into)
    }
    
    @inlinable
    func dot(_ vector: UnsafePointer<T>, multiplied: T, addingInto into: UnsafeMutablePointer<T>) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    cblas_cgemv(layout, trans, m, n, alpha, elements, lda, vector, incx, beta, into, incy)
                }
            }
            return
        }
        #elseif canImport(Accelerate)
        if rows &* columns > 400 {
            let layout = CblasRowMajor
            let trans = CblasNoTrans
            let m = blasint(rows), n = blasint(columns)
            let lda = n
            let beta: T = .one
            let incx = blasint(1), incy = blasint(1)
            withUnsafePointer(to: multiplied) { alpha in
                withUnsafePointer(to: beta) { beta in
                    elements.withUnsafeBufferPointer { elements in 
                        cblas_cgemv(layout, trans, m, n, .init(alpha), .init(elements.baseAddress), lda, .init(vector), incx, .init(beta), .init(into), incy)
                    }
                }
            }
            return
        }
        #endif
        _dot(vector, multiplied: multiplied, addingInto: into)
    }
}

//MARK: General Matrix-Vector multiplication
@inlinable
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Double, _ matrix: UnsafePointer<Double>, _ vector: UnsafePointer<Double>, resultMultiplier: Double, _ resultVector: UnsafeMutablePointer<Double>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasNoTrans
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
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Float, _ matrix: UnsafePointer<Float>, _ vector: UnsafePointer<Float>,  resultMultiplier: Float, _ resultVector: UnsafeMutablePointer<Float>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasNoTrans
        let m = blasint(matrixRows)
        let n = blasint(matrixColumns)
        cblas_sgemv(order, transA, m, n, multiplier, matrix, n, vector, 1, .zero, resultVector, 1)
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
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Double>, _ matrix: UnsafePointer<Complex<Double>>, _ vector: UnsafePointer<Complex<Double>>, _ resultMultiplier: Complex<Double>, _ resultVector: UnsafeMutablePointer<Complex<Double>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasNoTrans
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
        let transA = CblasNoTrans
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
public func matVecMul(_ matrixRows: Int, _ matrixColumns: Int, _ vectorComponents: Int, _ multiplier: Complex<Float>, _ matrix: UnsafePointer<Complex<Float>>, _ vector: UnsafePointer<Complex<Float>>, _ resultMultiplier: Complex<Float>, _ resultVector: UnsafeMutablePointer<Complex<Float>>) {
    precondition(matrixColumns == vectorComponents)
    if matrixRows == 2 && matrixColumns == 2 {
        resultVector[0] = Relaxed.multiplyAdd(resultMultiplier, resultVector[0], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[0]), Relaxed.product(vector[1], matrix[1]))))
        resultVector[1] = Relaxed.multiplyAdd(resultMultiplier, resultVector[1], Relaxed.product(multiplier, Relaxed.sum(Relaxed.product(vector[0], matrix[2]), Relaxed.product(vector[1], matrix[3]))))
        return
    }
    #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
    if matrixRows &* matrixColumns > 1000 {
        let order = CblasRowMajor
        let transA = CblasNoTrans
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
        let transA = CblasNoTrans
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
