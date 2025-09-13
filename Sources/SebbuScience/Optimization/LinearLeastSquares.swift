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
    static func linearLeastSquares(A: Matrix<Double>, _ b: Vector<Double>) throws -> Vector<Double> {
        let x = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return Vector(x.elements)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Double>, _ B: Matrix<Double>) throws -> Matrix<Double> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)
        let lda = n
        let ldb = nrhs
        var _A = Array(A.elements)
        var _B = Array(B.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_dgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        return .init(elements: _B, rows: B.rows, columns: B.columns)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Float>, _ b: Vector<Float>) throws -> Vector<Float> {
        let x = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return Vector(x.elements)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Float>, _ B: Matrix<Float>) throws -> Matrix<Float> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)
        let lda = n
        let ldb = nrhs
        var _A = Array(A.elements)
        var _B = Array(B.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_sgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        return .init(elements: _B, rows: B.rows, columns: B.columns)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Float>>, _ b: Vector<Complex<Float>>) throws -> Vector<Complex<Float>> {
        let x = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return Vector(x.elements)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Float>>, _ B: Matrix<Complex<Float>>) throws -> Matrix<Complex<Float>> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)
        let lda = n
        let ldb = nrhs
        var _A = Array(A.elements)
        var _B = Array(B.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_cgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        return .init(elements: _B, rows: B.rows, columns: B.columns)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Double>>, _ b: Vector<Complex<Double>>) throws -> Vector<Complex<Double>> {
        let x = try linearLeastSquares(A: A, Matrix.init(elements: b.components, rows: A.rows, columns: 1))
        return Vector(x.elements)
    }

    @inlinable
    static func linearLeastSquares(A: Matrix<Complex<Double>>, _ B: Matrix<Complex<Double>>) throws -> Matrix<Complex<Double>> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
        let m = lapack_int(A.rows)
        let n = lapack_int(A.columns)
        let nrhs = lapack_int(B.columns)
        let lda = n
        let ldb = nrhs
        var _A = Array(A.elements)
        var _B = Array(B.elements)
        let _N = Int8(bitPattern: UInt8(ascii: "N"))
        let info = _A.withUnsafeMutableBufferPointer { A in
            _B.withUnsafeMutableBufferPointer { B in 
                LAPACKE_zgels(LAPACK_ROW_MAJOR, _N, m, n, nrhs, .init(A.baseAddress), lda, .init(B.baseAddress), ldb)
            }     
        }
        if info != 0 { throw MatrixOperations.MatrixOperationError.info(Int(info)) }
        return .init(elements: _B, rows: B.rows, columns: B.columns)
        #elseif canImport(Accelerate)
        fatalError("TODO: Implement")
        #else
        fatalError("TODO: Not implemented yet")
        #endif
    }
}