//
//  AccelerateBridging.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 25.4.2025.
//
#if os(macOS)
import Accelerate

//TODO: Make these inlinable once https://github.com/swiftlang/swift/issues/80991 is fixed
internal extension BLAS {
    static func _sdsdot(n: cblas_int, alpha: Float, x: UnsafePointer<Float>?, incx: cblas_int, y: UnsafePointer<Float>?, incy: cblas_int) -> Float {
        cblas_sdsdot(n, alpha, x, incx, y, incy)
    }
    
    static func _dsdot(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int, y: UnsafePointer<Float>?, incy: cblas_int) -> Double {
        cblas_dsdot(n, x, incx, y, incy)
    }
    
    static func _sdot(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int, y: UnsafePointer<Float>?, incy: cblas_int) -> Float {
        cblas_sdot(n, x, incx, y, incy)
    }
    
    static func _ddot(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int, y: UnsafePointer<Double>?, incy: cblas_int) -> Double {
        cblas_ddot(n, x, incx, y, incy)
    }
    
    static func _cdotu_sub(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeRawPointer?, incy: cblas_int, ret: UnsafeMutableRawPointer?) -> Void {
        cblas_cdotu_sub(n, .init(x), incx, .init(y), incy, .init(ret!))
    }
    
    static func _cdotc_sub(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeRawPointer?, incy: cblas_int, ret: UnsafeMutableRawPointer?) -> Void {
        cblas_cdotc_sub(n, .init(x), incx, .init(y), incy, .init(ret!))
    }
    
    static func _zdotu_sub(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeRawPointer?, incy: cblas_int, ret: UnsafeMutableRawPointer?) -> Void {
        cblas_zdotu_sub(n, .init(x), incx, .init(y), incy, .init(ret!))
    }
    
    static func _zdotc_sub(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeRawPointer?, incy: cblas_int, ret: UnsafeMutableRawPointer?) -> Void {
        cblas_zdotc_sub(n, .init(x), incx, .init(y), incy, .init(ret!))
    }
    
    static func _sasum(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Float {
        cblas_sasum(n, x, incx)
    }
    
    static func _dasum(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Double {
        cblas_dasum(n, x, incx)
    }
    
    static func _scasum(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Float {
        cblas_scasum(n, .init(x), incx)
    }
    
    static func _dzasum(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Double {
        cblas_dzasum(n, .init(x), incx)
    }
    
    static func _ssum(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Float {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _dsum(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Double {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _scsum(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Float {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _dzsum(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Double {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _snrm2(N: cblas_int, X: UnsafePointer<Float>?, incX: cblas_int) -> Float {
        cblas_snrm2(N, X, incX)
    }
    
    static func _dnrm2(N: cblas_int, X: UnsafePointer<Double>?, incX: cblas_int) -> Double {
        cblas_dnrm2(N, X, incX)
    }
    
    static func _scnrm2(N: cblas_int, X: UnsafeRawPointer?, incX: cblas_int) -> Float {
        cblas_scnrm2(N, .init(X), incX)
    }
    
    static func _dznrm2(N: cblas_int, X: UnsafeRawPointer?, incX: cblas_int) -> Double {
        cblas_dznrm2(N, .init(X), incX)
    }
    
    static func _isamax(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Int {
        cblas_isamax(n, x, incx)
    }
    
    static func _idamax(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Int {
        cblas_idamax(n, x, incx)
    }
    
    static func _icamax(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        cblas_icamax(n, .init(x), incx)
    }
    
    static func _izamax(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        cblas_izamax(n, .init(x), incx)
    }
    
    static func _isamin(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _idamin(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _icamin(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _izamin(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _samax(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Float {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _damax(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Double {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _scamax(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Float {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _dzamax(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Double {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _samin(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Float {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _damin(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Double {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _scamin(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Float {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _dzamin(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Double {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _ismax(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _idmax(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _icmax(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _izmax(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _ismin(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _idmin(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _icmin(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _izmin(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int) -> Int {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _saxpy(n: cblas_int, alpha: Float, x: UnsafePointer<Float>?, incx: cblas_int, y: UnsafeMutablePointer<Float>?, incy: cblas_int) -> Void {
        cblas_saxpy(n, alpha, x, incx, y, incy)
    }
    
    static func _daxpy(n: cblas_int, alpha: Double, x: UnsafePointer<Double>?, incx: cblas_int, y: UnsafeMutablePointer<Double>?, incy: cblas_int) -> Void {
        cblas_daxpy(n, alpha, x, incx, y, incy)
    }
    
    static func _caxpy(n: cblas_int, alpha: UnsafeRawPointer?, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_caxpy(n, .init(alpha!), .init(x), incx, .init(y), incy)
    }
    
    static func _zaxpy(n: cblas_int, alpha: UnsafeRawPointer?, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_zaxpy(n, .init(alpha!), .init(x), incx, .init(y), incy)
    }
    
    static func _caxpyc(n: cblas_int, alpha: UnsafeRawPointer?, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _zaxpyc(n: cblas_int, alpha: UnsafeRawPointer?, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _scopy(n: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int, y: UnsafeMutablePointer<Float>?, incy: cblas_int) -> Void {
        cblas_scopy(n, x, incx, y, incy)
    }
    
    static func _dcopy(n: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int, y: UnsafeMutablePointer<Double>?, incy: cblas_int) -> Void {
        cblas_dcopy(n, x, incx, y, incy)
    }
    
    static func _ccopy(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_ccopy(n, .init(x), incx, .init(y), incy)
    }
    
    static func _zcopy(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_zcopy(n, .init(x), incx, .init(y), incy)
    }
    
    static func _sswap(n: cblas_int, x: UnsafeMutablePointer<Float>?, incx: cblas_int, y: UnsafeMutablePointer<Float>?, incy: cblas_int) -> Void {
        cblas_sswap(n, x, incx, y, incy)
    }
    
    static func _dswap(n: cblas_int, x: UnsafeMutablePointer<Double>?, incx: cblas_int, y: UnsafeMutablePointer<Double>?, incy: cblas_int) -> Void {
        cblas_dswap(n, x, incx, y, incy)
    }
    
    static func _cswap(n: cblas_int, x: UnsafeMutableRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_cswap(n, .init(x), incx, .init(y), incy)
    }
    
    static func _zswap(n: cblas_int, x: UnsafeMutableRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_zswap(n, .init(x), incx, .init(y), incy)
    }
    
    static func _srot(N: cblas_int, X: UnsafeMutablePointer<Float>?, incX: cblas_int, Y: UnsafeMutablePointer<Float>?, incY: cblas_int, c: Float, s: Float) -> Void {
        cblas_srot(N, X, incX, Y, incY, c, s)
    }
    
    static func _drot(N: cblas_int, X: UnsafeMutablePointer<Double>?, incX: cblas_int, Y: UnsafeMutablePointer<Double>?, incY: cblas_int, c: Double, s: Double) -> Void {
        cblas_drot(N, X, incX, Y, incY, c, s)
    }
    
    static func _csrot(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incY: cblas_int, c: Float, s: Float) -> Void {
        cblas_csrot(n, .init(x), incx, .init(y), incY, c, s)
    }
    
    static func _zdrot(n: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, y: UnsafeMutableRawPointer?, incY: cblas_int, c: Double, s: Double) -> Void {
        cblas_zdrot(n, .init(x), incx, .init(y), incY, c, s)
    }
    
    static func _srotg(a: UnsafeMutablePointer<Float>?, b: UnsafeMutablePointer<Float>?, c: UnsafeMutablePointer<Float>?, s: UnsafeMutablePointer<Float>?) -> Void {
        cblas_srotg(a!, b!, c!, s!)
    }
    
    static func _drotg(a: UnsafeMutablePointer<Double>?, b: UnsafeMutablePointer<Double>?, c: UnsafeMutablePointer<Double>?, s: UnsafeMutablePointer<Double>?) -> Void {
        cblas_drotg(a!, b!, c!, s!)
    }
    
    static func _crotg(a: UnsafeMutableRawPointer?, b: UnsafeMutableRawPointer?, c: UnsafeMutablePointer<Float>?, s: UnsafeMutableRawPointer?) -> Void {
        cblas_crotg(.init(a!), .init(b!), c!, .init(s!))
    }
    
    static func _zrotg(a: UnsafeMutableRawPointer?, b: UnsafeMutableRawPointer?, c: UnsafeMutablePointer<Double>?, s: UnsafeMutableRawPointer?) -> Void {
        cblas_zrotg(.init(a!), .init(b!), c!, .init(s!))
    }
    
    static func _srotm(N: cblas_int, X: UnsafeMutablePointer<Float>?, incX: cblas_int, Y: UnsafeMutablePointer<Float>?, incY: cblas_int, P: UnsafePointer<Float>?) -> Void {
        cblas_srotm(N, X, incX, Y, incY, P!)
    }
    
    static func _drotm(N: cblas_int, X: UnsafeMutablePointer<Double>?, incX: cblas_int, Y: UnsafeMutablePointer<Double>?, incY: cblas_int, P: UnsafePointer<Double>?) -> Void {
        cblas_drotm(N, X, incX, Y, incY, P!)
    }
    
    static func _srotmg(d1: UnsafeMutablePointer<Float>?, d2: UnsafeMutablePointer<Float>?, b1: UnsafeMutablePointer<Float>?, b2: Float, P: UnsafeMutablePointer<Float>?) -> Void {
        cblas_srotmg(d1!, d2!, b1!, b2, P!)
    }
    
    static func _drotmg(d1: UnsafeMutablePointer<Double>?, d2: UnsafeMutablePointer<Double>?, b1: UnsafeMutablePointer<Double>?, b2: Double, P: UnsafeMutablePointer<Double>?) -> Void {
        cblas_drotmg(d1!, d2!, b1!, b2, P!)
    }
    
    static func _sscal(N: cblas_int, alpha: Float, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_sscal(N, alpha, X, incX)
    }
    
    static func _dscal(N: cblas_int, alpha: Double, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dscal(N, alpha, X, incX)
    }
    
    static func _cscal(N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_cscal(N, .init(alpha!), .init(X), incX)
    }
    
    static func _zscal(N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_zscal(N, .init(alpha!), .init(X), incX)
    }
    
    static func _csscal(N: cblas_int, alpha: Float, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_csscal(N, alpha, .init(X), incX)
    }
    
    static func _zdscal(N: cblas_int, alpha: Double, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_zdscal(N, alpha, .init(X), incX)
    }
    
    static func _sgemv(order: BLAS.Order.RawValue, trans: BLAS.Transpose.RawValue, m: cblas_int, n: cblas_int,          alpha: Float, a: UnsafePointer<Float>?, lda: cblas_int, x: UnsafePointer<Float>?, incx: cblas_int, beta: Float, y: UnsafeMutablePointer<Float>?, incy: cblas_int) -> Void {
        cblas_sgemv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(trans), m, n, alpha, a, lda, x, incx, beta, y, incy)
    }
    
    static func _dgemv(order: BLAS.Order.RawValue, trans: BLAS.Transpose.RawValue, m: cblas_int, n: cblas_int,          alpha: Double, a: UnsafePointer<Double>?, lda: cblas_int, x: UnsafePointer<Double>?, incx: cblas_int, beta: Double, y: UnsafeMutablePointer<Double>?, incy: cblas_int) -> Void {
        cblas_dgemv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(trans), m, n, alpha, a, lda, x, incx, beta, y, incy)
    }
    
    static func _cgemv(order: BLAS.Order.RawValue, trans: BLAS.Transpose.RawValue, m: cblas_int, n: cblas_int,          alpha: UnsafeRawPointer?, a: UnsafeRawPointer?, lda: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, beta: UnsafeRawPointer?, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_cgemv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(trans), m, n, .init(alpha!), .init(a), lda, .init(x), incx, .init(beta!), .init(y), incy)
    }
    
    static func _zgemv(order: BLAS.Order.RawValue, trans: BLAS.Transpose.RawValue, m: cblas_int, n: cblas_int,          alpha: UnsafeRawPointer?, a: UnsafeRawPointer?, lda: cblas_int, x: UnsafeRawPointer?, incx: cblas_int, beta: UnsafeRawPointer?, y: UnsafeMutableRawPointer?, incy: cblas_int) -> Void {
        cblas_zgemv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(trans), m, n, .init(alpha!), .init(a), lda, .init(x), incx, .init(beta!), .init(y), incy)
    }
    
    static func _sger(order: BLAS.Order.RawValue, M: cblas_int, N: cblas_int, alpha: Float, X: UnsafePointer<Float>?, incX: cblas_int, Y: UnsafePointer<Float>?, incY: cblas_int, A: UnsafeMutablePointer<Float>?, lda: cblas_int) -> Void {
        cblas_sger(CBLAS_ORDER(order), M, N, alpha, X, incX, Y, incY, A, lda)
    }
    
    static func _dger(order: BLAS.Order.RawValue, M: cblas_int, N: cblas_int, alpha: Double, X: UnsafePointer<Double>?, incX: cblas_int, Y: UnsafePointer<Double>?, incY: cblas_int, A: UnsafeMutablePointer<Double>?, lda: cblas_int) -> Void {
        cblas_dger(CBLAS_ORDER(order), M, N, alpha, X, incX, Y, incY, A, lda)
    }
    
    static func _cgeru(order: BLAS.Order.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_cgeru(CBLAS_ORDER(order), M, N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(A), lda)
    }
    
    static func _cgerc(order: BLAS.Order.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_cgerc(CBLAS_ORDER(order), M, N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(A), lda)
    }
    
    static func _zgeru(order: BLAS.Order.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_zgeru(CBLAS_ORDER(order), M, N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(A), lda)
    }
    
    static func _zgerc(order: BLAS.Order.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_zgerc(CBLAS_ORDER(order), M, N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(A), lda)
    }
    
    static func _strsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_strsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, A, lda, X, incX)
    }
    
    static func _dtrsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dtrsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, A, lda, X, incX)
    }
    
    static func _ctrsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ctrsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(A), lda, .init(X), incX)
    }
    
    static func _ztrsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ztrsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(A), lda, .init(X), incX)
    }
    
    static func _strmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_strmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, A, lda, X, incX)
    }
    
    static func _dtrmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dtrmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, A, lda, X, incX)
    }
    
    static func _ctrmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ctrmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(A), lda, .init(X), incX)
    }
    
    static func _ztrmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ztrmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(A), lda, .init(X), incX)
    }
    
    static func _ssyr(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, X: UnsafePointer<Float>?, incX: cblas_int, A: UnsafeMutablePointer<Float>?, lda: cblas_int) -> Void {
        cblas_ssyr(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, X, incX, A, lda)
    }
    
    static func _dsyr(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, X: UnsafePointer<Double>?, incX: cblas_int, A: UnsafeMutablePointer<Double>?, lda: cblas_int) -> Void {
        cblas_dsyr(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, X, incX, A, lda)
    }
    
    static func _cher(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, X: UnsafeRawPointer?, incX: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_cher(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(A), lda)
    }
    
    static func _zher(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, X: UnsafeRawPointer?, incX: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_zher(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(A), lda)
    }
    
    static func _ssyr2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, X: UnsafePointer<Float>?, incX: cblas_int, Y: UnsafePointer<Float>?, incY: cblas_int, A: UnsafeMutablePointer<Float>?, lda: cblas_int) -> Void {
        cblas_ssyr2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, X, incX, Y, incY, A, lda)
    }
    
    static func _dsyr2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, X: UnsafePointer<Double>?, incX: cblas_int, Y: UnsafePointer<Double>?, incY: cblas_int, A: UnsafeMutablePointer<Double>?, lda: cblas_int) -> Void {
        cblas_dsyr2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, X, incX, Y, incY, A, lda)
    }
    
    static func _cher2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_cher2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(A), lda)
    }
    
    static func _zher2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, A: UnsafeMutableRawPointer?, lda: cblas_int) -> Void {
        cblas_zher2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(A), lda)
    }
    
    static func _sgbmv(order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, KL: cblas_int, KU: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafePointer<Float>?, incX: cblas_int, beta: Float, Y: UnsafeMutablePointer<Float>?, incY: cblas_int) -> Void {
        cblas_sgbmv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(TransA), M, N, KL, KU, alpha, A, lda, X, incX, beta, Y, incY)
    }
    
    static func _dgbmv(order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, KL: cblas_int, KU: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafePointer<Double>?, incX: cblas_int, beta: Double, Y: UnsafeMutablePointer<Double>?, incY: cblas_int) -> Void {
        cblas_dgbmv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(TransA), M, N, KL, KU, alpha, A, lda, X, incX, beta, Y, incY)
    }
    
    static func _cgbmv(order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, KL: cblas_int, KU: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_cgbmv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(TransA), M, N, KL, KU, .init(alpha!), .init(A), lda, .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _zgbmv(order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, KL: cblas_int, KU: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_zgbmv(CBLAS_ORDER(order), CBLAS_TRANSPOSE(TransA), M, N, KL, KU, .init(alpha!), .init(A), lda, .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _ssbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, K: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafePointer<Float>?, incX: cblas_int, beta: Float, Y: UnsafeMutablePointer<Float>?, incY: cblas_int) -> Void {
        cblas_ssbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, K, alpha, A, lda, X, incX, beta, Y, incY)
    }
    
    static func _dsbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, K: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafePointer<Double>?, incX: cblas_int, beta: Double, Y: UnsafeMutablePointer<Double>?, incY: cblas_int) -> Void {
        cblas_dsbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, K, alpha, A, lda, X, incX, beta, Y, incY)
    }
    
    static func _stbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_stbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, A, lda, X, incX)
    }
    
    static func _dtbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dtbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, A, lda, X, incX)
    }
    
    static func _ctbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ctbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, .init(A), lda, .init(X), incX)
    }
    
    static func _ztbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ztbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, .init(A), lda, .init(X), incX)
    }
    
    static func _stbsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_stbsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, A, lda, X, incX)
    }
    
    static func _dtbsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dtbsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, A, lda, X, incX)
    }
    
    static func _ctbsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ctbsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, .init(A), lda, .init(X), incX)
    }
    
    static func _ztbsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, K: cblas_int, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ztbsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, K, .init(A), lda, .init(X), incX)
    }
    
    static func _stpmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafePointer<Float>?, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_stpmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, Ap, X, incX)
    }
    
    static func _dtpmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafePointer<Double>?, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dtpmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, Ap, X, incX)
    }
    
    static func _ctpmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafeRawPointer?, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ctpmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(Ap), .init(X), incX)
    }
    
    static func _ztpmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafeRawPointer?, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ztpmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(Ap), .init(X), incX)
    }
    
    static func _stpsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafePointer<Float>?, X: UnsafeMutablePointer<Float>?, incX: cblas_int) -> Void {
        cblas_stpsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, Ap, X, incX)
    }
    
    static func _dtpsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafePointer<Double>?, X: UnsafeMutablePointer<Double>?, incX: cblas_int) -> Void {
        cblas_dtpsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, Ap, X, incX)
    }
    
    static func _ctpsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafeRawPointer?, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ctpsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(Ap), .init(X), incX)
    }
    
    static func _ztpsv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, N: cblas_int, Ap: UnsafeRawPointer?, X: UnsafeMutableRawPointer?, incX: cblas_int) -> Void {
        cblas_ztpsv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), N, .init(Ap), .init(X), incX)
    }
    
    static func _ssymv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, X: UnsafePointer<Float>?, incX: cblas_int, beta: Float, Y: UnsafeMutablePointer<Float>?, incY: cblas_int) -> Void {
        cblas_ssymv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, A, lda, X, incX, beta, Y, incY)
    }
    
    static func _dsymv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, X: UnsafePointer<Double>?, incX: cblas_int, beta: Double, Y: UnsafeMutablePointer<Double>?, incY: cblas_int) -> Void {
        cblas_dsymv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, A, lda, X, incX, beta, Y, incY)
    }
    
    static func _chemv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_chemv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(A), lda, .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _zhemv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_zhemv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(A), lda, .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _sspmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, Ap: UnsafePointer<Float>?, X: UnsafePointer<Float>?, incX: cblas_int, beta: Float, Y: UnsafeMutablePointer<Float>?, incY: cblas_int) -> Void {
        cblas_sspmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(Ap), .init(X), incX, beta, .init(Y), incY)
    }
    
    static func _dspmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, Ap: UnsafePointer<Double>?, X: UnsafePointer<Double>?, incX: cblas_int, beta: Double, Y: UnsafeMutablePointer<Double>?, incY: cblas_int) -> Void {
        cblas_dspmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(Ap), .init(X), incX, beta, .init(Y), incY)
    }
    
    static func _sspr(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, X: UnsafePointer<Float>?, incX: cblas_int, Ap: UnsafeMutablePointer<Float>?) -> Void {
        cblas_sspr(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(Ap))
    }
    
    static func _dspr(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, X: UnsafePointer<Double>?, incX: cblas_int, Ap: UnsafeMutablePointer<Double>?) -> Void {
        cblas_dspr(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(Ap))
    }
    
    static func _chpr(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, X: UnsafeRawPointer?, incX: cblas_int, A: UnsafeMutableRawPointer?) -> Void {
        cblas_chpr(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(A))
    }
    
    static func _zhpr(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, X: UnsafeRawPointer?, incX: cblas_int, A: UnsafeMutableRawPointer?) -> Void {
        cblas_zhpr(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(A))
    }
    
    static func _sspr2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Float, X: UnsafePointer<Float>?, incX: cblas_int, Y: UnsafePointer<Float>?, incY: cblas_int, A: UnsafeMutablePointer<Float>?) -> Void {
        cblas_sspr2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(Y), incY, .init(A))
    }
    
    static func _dspr2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: Double, X: UnsafePointer<Double>?, incX: cblas_int, Y: UnsafePointer<Double>?, incY: cblas_int, A: UnsafeMutablePointer<Double>?) -> Void {
        cblas_dspr2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, alpha, .init(X), incX, .init(Y), incY, .init(A))
    }
    
    static func _chpr2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, Ap: UnsafeMutableRawPointer?) -> Void {
        cblas_chpr2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(Ap))
    }
    
    static func _zhpr2(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, alpha: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, Y: UnsafeRawPointer?, incY: cblas_int, Ap: UnsafeMutableRawPointer?) -> Void {
        cblas_zhpr2(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(X), incX, .init(Y), incY, .init(Ap))
    }
    
    static func _chbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_chbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, K, .init(alpha!), .init(A), lda, .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _zhbmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_zhbmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, K, .init(alpha!), .init(A), lda, .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _chpmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int,          alpha: UnsafeRawPointer?, Ap: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_chpmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(Ap), .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _zhpmv(order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, N: cblas_int,          alpha: UnsafeRawPointer?, Ap: UnsafeRawPointer?, X: UnsafeRawPointer?, incX: cblas_int, beta: UnsafeRawPointer?, Y: UnsafeMutableRawPointer?, incY: cblas_int) -> Void {
        cblas_zhpmv(CBLAS_ORDER(order), CBLAS_UPLO(Uplo), N, .init(alpha!), .init(Ap), .init(X), incX, .init(beta!), .init(Y), incY)
    }
    
    static func _sgemm(Order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, K: cblas_int,          alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, B: UnsafePointer<Float>?, ldb: cblas_int, beta: Float, C: UnsafeMutablePointer<Float>?, ldc: cblas_int) -> Void {
        cblas_sgemm(CBLAS_ORDER(Order), CBLAS_TRANSPOSE(TransA), CBLAS_TRANSPOSE(TransB), M, N, K, alpha, A, lda, B, ldb, beta, C, ldc)
    }
    
    static func _dgemm(Order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, K: cblas_int,          alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, B: UnsafePointer<Double>?, ldb: cblas_int, beta: Double, C: UnsafeMutablePointer<Double>?, ldc: cblas_int) -> Void {
        cblas_dgemm(CBLAS_ORDER(Order), CBLAS_TRANSPOSE(TransA), CBLAS_TRANSPOSE(TransB), M, N, K, alpha, A, lda, B, ldb, beta, C, ldc)
    }
    
    static func _cgemm(Order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_cgemm(CBLAS_ORDER(Order), CBLAS_TRANSPOSE(TransA), CBLAS_TRANSPOSE(TransB), M, N, K, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _cgemm3m(Order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _zgemm(Order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zgemm(CBLAS_ORDER(Order), CBLAS_TRANSPOSE(TransA), CBLAS_TRANSPOSE(TransB), M, N, K, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _zgemm3m(Order: BLAS.Order.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, N: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _sgemmt(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, K: cblas_int,          alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, B: UnsafePointer<Float>?, ldb: cblas_int, beta: Float, C: UnsafeMutablePointer<Float>?, ldc: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _dgemmt(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, K: cblas_int,          alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, B: UnsafePointer<Double>?, ldb: cblas_int, beta: Double, C: UnsafeMutablePointer<Double>?, ldc: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _cgemmt(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _zgemmt(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, TransB: BLAS.Transpose.RawValue, M: cblas_int, K: cblas_int,          alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        fatalError("Not implemented in Accelerate")
    }
    
    static func _ssymm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, M: cblas_int, N: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, B: UnsafePointer<Float>?, ldb: cblas_int, beta: Float, C: UnsafeMutablePointer<Float>?, ldc: cblas_int) -> Void {
        cblas_ssymm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), M, N, alpha, A, lda, B, ldb, beta, C, ldc)
    }
    
    static func _dsymm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, M: cblas_int, N: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, B: UnsafePointer<Double>?, ldb: cblas_int, beta: Double, C: UnsafeMutablePointer<Double>?, ldc: cblas_int) -> Void {
        cblas_dsymm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), M, N, alpha, A, lda, B, ldb, beta, C, ldc)
    }
    
    static func _csymm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_csymm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), M, N, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _zsymm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zsymm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), M, N, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _ssyrk(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,          N: cblas_int, K: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, beta: Float, C: UnsafeMutablePointer<Float>?, ldc: cblas_int) -> Void {
        cblas_ssyrk(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, alpha, A, lda, beta, C, ldc)
    }
    
    static func _dsyrk(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,          N: cblas_int, K: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, beta: Double, C: UnsafeMutablePointer<Double>?, ldc: cblas_int) -> Void {
        cblas_dsyrk(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, alpha, A, lda, beta, C, ldc)
    }
    
    static func _csyrk(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,          N: cblas_int, K: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_csyrk(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, .init(alpha!), .init(A), lda, .init(beta!), .init(C), ldc)
    }
    
    static func _zsyrk(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,          N: cblas_int, K: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zsyrk(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, .init(alpha!), .init(A), lda, .init(beta!), .init(C), ldc)
    }
    
    static func _ssyr2k(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,           N: cblas_int, K: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, B: UnsafePointer<Float>?, ldb: cblas_int, beta: Float, C: UnsafeMutablePointer<Float>?, ldc: cblas_int) -> Void {
        cblas_ssyr2k(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, alpha, A, lda, B, ldb, beta, C, ldc)
    }
    
    static func _dsyr2k(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,           N: cblas_int, K: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, B: UnsafePointer<Double>?, ldb: cblas_int, beta: Double, C: UnsafeMutablePointer<Double>?, ldc: cblas_int) -> Void {
        cblas_dsyr2k(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, alpha, A, lda, B, ldb, beta, C, ldc)
    }
    
    static func _csyr2k(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,           N: cblas_int, K: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_csyr2k(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _zsyr2k(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue,           N: cblas_int, K: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zsyr2k(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _strmm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, B: UnsafeMutablePointer<Float>?, ldb: cblas_int) -> Void {
        cblas_strmm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, alpha, A, lda, B, ldb)
    }
    
    static func _dtrmm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, B: UnsafeMutablePointer<Double>?, ldb: cblas_int) -> Void {
        cblas_dtrmm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, alpha, A, lda, B, ldb)
    }
    
    static func _ctrmm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeMutableRawPointer?, ldb: cblas_int) -> Void {
        cblas_ctrmm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, .init(alpha!), .init(A), lda, .init(B), ldb)
    }
    
    static func _ztrmm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeMutableRawPointer?, ldb: cblas_int) -> Void {
        cblas_ztrmm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, .init(alpha!), .init(A), lda, .init(B), ldb)
    }
    
    static func _strsm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: Float, A: UnsafePointer<Float>?, lda: cblas_int, B: UnsafeMutablePointer<Float>?, ldb: cblas_int) -> Void {
        cblas_strsm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, alpha, A, lda, B, ldb)
    }
    
    static func _dtrsm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: Double, A: UnsafePointer<Double>?, lda: cblas_int, B: UnsafeMutablePointer<Double>?, ldb: cblas_int) -> Void {
        cblas_dtrsm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, alpha, A, lda, B, ldb)
    }
    
    static func _ctrsm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeMutableRawPointer?, ldb: cblas_int) -> Void {
        cblas_ctrsm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, .init(alpha!), .init(A), lda, .init(B), ldb)
    }
    
    static func _ztrsm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, TransA: BLAS.Transpose.RawValue, Diag: BLAS.Diagonal.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeMutableRawPointer?, ldb: cblas_int) -> Void {
        cblas_ztrsm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(TransA), CBLAS_DIAG(Diag), M, N, .init(alpha!), .init(A), lda, .init(B), ldb)
    }
    
    static func _chemm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_chemm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), M, N, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _zhemm(Order: BLAS.Order.RawValue, Side: BLAS.Side.RawValue, Uplo: BLAS.UpperLower.RawValue, M: cblas_int, N: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: UnsafeRawPointer?, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zhemm(CBLAS_ORDER(Order), CBLAS_SIDE(Side), CBLAS_UPLO(Uplo), M, N, .init(alpha!), .init(A), lda, .init(B), ldb, .init(beta!), .init(C), ldc)
    }
    
    static func _cherk(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue, N: cblas_int, K: cblas_int, alpha: Float, A: UnsafeRawPointer?, lda: cblas_int, beta: Float, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_cherk(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, alpha, .init(A), lda, beta, .init(C), ldc)
    }
    
    static func _zherk(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue, N: cblas_int, K: cblas_int, alpha: Double, A: UnsafeRawPointer?, lda: cblas_int, beta: Double, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zherk(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, alpha, .init(A), lda, beta, .init(C), ldc)
    }
    
    static func _cher2k(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue, N: cblas_int, K: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: Float, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_cher2k(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, .init(alpha!), .init(A), lda, .init(B), ldb, beta, .init(C), ldc)
    }
    
    static func _zher2k(Order: BLAS.Order.RawValue, Uplo: BLAS.UpperLower.RawValue, Trans: BLAS.Transpose.RawValue, N: cblas_int, K: cblas_int, alpha: UnsafeRawPointer?, A: UnsafeRawPointer?, lda: cblas_int, B: UnsafeRawPointer?, ldb: cblas_int, beta: Double, C: UnsafeMutableRawPointer?, ldc: cblas_int) -> Void {
        cblas_zher2k(CBLAS_ORDER(Order), CBLAS_UPLO(Uplo), CBLAS_TRANSPOSE(Trans), N, K, .init(alpha!), .init(A), lda, .init(B), ldb, beta, .init(C), ldc)
    }
}
#endif
