// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import SebbuLAPACK
import SebbuBLAS

import RealModule
import ComplexModule
import NumericsExtensions

public extension Optimize {
    @inlinable
    static func linearLeastSquares(A: Matrix<Double>, _ b: Vector<Double>) throws -> (result: Vector<Double>, residuals: Vector<Double>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Double>, _ B: Matrix<Double>) throws -> (result: Matrix<Double>, residuals: Matrix<Double>?) {
        let m = A.rows
        let n = A.columns
        let nrhs = B.columns
        
        var a = A.elements
        var b = B.elements
        // Pad with zeros
        while b.count < max(m, n) * nrhs { b.append(.zero) }
        let info = LAPACK.dgels(layout: .rowMajor, transpose: .noTranspose, m: m, n: n, nrhs: nrhs, a: &a, lda: n, b: &b, ldb: nrhs)
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(info) }
        let result: Matrix<Double> = .init(elements: Array(b[0..<nrhs*n]), rows: n, columns: nrhs)
        var residuals: Matrix<Double>? = nil
        if m > n {
            let residualElements = b[n*nrhs..<m*nrhs]
            if !residualElements.isEmpty {
                residuals = .init(elements: Array(residualElements), rows: m - n, columns: nrhs)
            }
        }
        return (result, residuals)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Float>, _ b: Vector<Float>) throws -> (result: Vector<Float>, residuals: Vector<Float>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Float>, _ B: Matrix<Float>) throws -> (result: Matrix<Float>, residuals: Matrix<Float>?) {
        let m = A.rows
        let n = A.columns
        let nrhs = B.columns
        
        var a = A.elements
        var b = B.elements
        // Pad with zeros
        while b.count < max(m, n) * nrhs { b.append(.zero) }
        let info = LAPACK.sgels(layout: .rowMajor, transpose: .noTranspose, m: m, n: n, nrhs: nrhs, a: &a, lda: n, b: &b, ldb: nrhs)
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(info) }
        let result: Matrix<Float> = .init(elements: Array(b[0..<nrhs*n]), rows: n, columns: nrhs)
        var residuals: Matrix<Float>? = nil
        if m > n {
            let residualElements = b[n*nrhs..<m*nrhs]
            if !residualElements.isEmpty {
                residuals = .init(elements: Array(residualElements), rows: m - n, columns: nrhs)
            }
        }
        return (result, residuals)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Float>>, _ b: Vector<Complex<Float>>) throws -> (result: Vector<Complex<Float>>, residuals: Vector<Complex<Float>>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Float>>, _ B: Matrix<Complex<Float>>) throws -> (result: Matrix<Complex<Float>>, residuals: Matrix<Complex<Float>>?) {
        let m = A.rows
        let n = A.columns
        let nrhs = B.columns
        
        var a = A.elements
        var b = B.elements
        // Pad with zeros
        while b.count < max(m, n) * nrhs { b.append(.zero) }
        let info = LAPACK.cgels(layout: .rowMajor, transpose: .noTranspose, m: m, n: n, nrhs: nrhs, a: &a, lda: n, b: &b, ldb: nrhs)
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(info) }
        let result: Matrix<Complex<Float>> = .init(elements: Array(b[0..<nrhs*n]), rows: n, columns: nrhs)
        var residuals: Matrix<Complex<Float>>? = nil
        if m > n {
            let residualElements = b[n*nrhs..<m*nrhs]
            if !residualElements.isEmpty {
                residuals = .init(elements: Array(residualElements), rows: m - n, columns: nrhs)
            }
        }
        return (result, residuals)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Double>>, _ b: Vector<Complex<Double>>) throws -> (result: Vector<Complex<Double>>, residuals: Vector<Complex<Double>>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Double>>, _ B: Matrix<Complex<Double>>) throws -> (result: Matrix<Complex<Double>>, residuals: Matrix<Complex<Double>>?) {
        let m = A.rows
        let n = A.columns
        let nrhs = B.columns
        
        var a = A.elements
        var b = B.elements
        // Pad with zeros
        while b.count < max(m, n) * nrhs { b.append(.zero) }
        let info = LAPACK.zgels(layout: .rowMajor, transpose: .noTranspose, m: m, n: n, nrhs: nrhs, a: &a, lda: n, b: &b, ldb: nrhs)
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(info) }
        let result: Matrix<Complex<Double>> = .init(elements: Array(b[0..<nrhs*n]), rows: n, columns: nrhs)
        var residuals: Matrix<Complex<Double>>? = nil
        if m > n {
            let residualElements = b[n*nrhs..<m*nrhs]
            if !residualElements.isEmpty {
                residuals = .init(elements: Array(residualElements), rows: m - n, columns: nrhs)
            }
        }
        return (result, residuals)
    }
}
