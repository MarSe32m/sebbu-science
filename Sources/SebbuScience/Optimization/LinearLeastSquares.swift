//
//  LinearLeastSquares.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 13.9.2025.
//
#if canImport(COpenBLAS)
import COpenBLAS
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
#elseif canImport(Accelerate)
import Accelerate
#endif

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
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)

        let lda = n
        let ldb = nrhs

        var _A = Array(A.elements)
        var _B = Array(B.elements)
        // Pad with zeros
        while _B.count < Int(m * nrhs) { _B.append(.zero) }
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_dgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        let result: Matrix<Double> = .init(elements: Array(_B[0..<Int(nrhs * n)]), rows: Int(n), columns: Int(nrhs))

        var residuals: Matrix<Double>?
        if m > n {
            let residualElements = _B[Int(n * nrhs)..<Int(m * nrhs)]
            residuals = residualElements.isEmpty ? nil : .init(elements: Array(residualElements), rows: Int(m - n), columns: Int(nrhs))
        }

        return (result, residuals)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Float>, _ b: Vector<Float>) throws -> (result: Vector<Float>, residuals: Vector<Float>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Float>, _ B: Matrix<Float>) throws -> (result: Matrix<Float>, residuals: Matrix<Float>?) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)

        let lda = n
        let ldb = nrhs

        var _A = Array(A.elements)
        var _B = Array(B.elements)
        // Pad with zeros
        while _B.count < Int(m * nrhs) { _B.append(.zero) }
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_sgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        let result: Matrix<Float> = .init(elements: Array(_B[0..<Int(nrhs * n)]), rows: Int(n), columns: Int(nrhs))

        var residuals: Matrix<Float>?
        if m > n {
            let residualElements = _B[Int(n * nrhs)..<Int(m * nrhs)]
            residuals = residualElements.isEmpty ? nil : .init(elements: Array(residualElements), rows: Int(m - n), columns: Int(nrhs))
        }

        return (result, residuals)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Float>>, _ b: Vector<Complex<Float>>) throws -> (result: Vector<Complex<Float>>, residuals: Vector<Complex<Float>>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Float>>, _ B: Matrix<Complex<Float>>) throws -> (result: Matrix<Complex<Float>>, residuals: Matrix<Complex<Float>>?) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)

        let lda = n
        let ldb = nrhs

        var _A = Array(A.elements)
        var _B = Array(B.elements)
        // Pad with zeros
        while _B.count < Int(m * nrhs) { _B.append(.zero) }
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_cgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        let result: Matrix<Complex<Float>> = .init(elements: Array(_B[0..<Int(nrhs * n)]), rows: Int(n), columns: Int(nrhs))

        var residuals: Matrix<Complex<Float>>?
        if m > n {
            let residualElements = _B[Int(n * nrhs)..<Int(m * nrhs)]
            residuals = residualElements.isEmpty ? nil : .init(elements: Array(residualElements), rows: Int(m - n), columns: Int(nrhs))
        }

        return (result, residuals)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Double>>, _ b: Vector<Complex<Double>>) throws -> (result: Vector<Complex<Double>>, residuals: Vector<Complex<Double>>?) {
        let (x, residuals) = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return (Vector(x.elements), residuals == nil ? nil : Vector(residuals!.elements))
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Double>>, _ B: Matrix<Complex<Double>>) throws -> (result: Matrix<Complex<Double>>, residuals: Matrix<Complex<Double>>?) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)

        let lda = n
        let ldb = nrhs

        var _A = Array(A.elements)
        var _B = Array(B.elements)
        // Pad with zeros
        while _B.count < Int(m * nrhs) { _B.append(.zero) }
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_zgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        let result: Matrix<Complex<Double>> = .init(elements: Array(_B[0..<Int(nrhs * n)]), rows: Int(n), columns: Int(nrhs))

        var residuals: Matrix<Complex<Double>>?
        if m > n {
            let residualElements = _B[Int(n * nrhs)..<Int(m * nrhs)]
            residuals = residualElements.isEmpty ? nil : .init(elements: Array(residualElements), rows: Int(m - n), columns: Int(nrhs))
        }

        return (result, residuals)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }
}