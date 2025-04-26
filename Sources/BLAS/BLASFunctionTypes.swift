//
//  BLASFunctionTypes.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 24.4.2025.
//

public extension BLAS {
    enum FunctionTypes {
        public typealias cblas_sdsdot = @convention(c) (_ n: cblas_int, _ alpha: Float, _ x: UnsafePointer<Float>?, _ incx: cblas_int, _ y: UnsafePointer<Float>?, _ incy: cblas_int) -> Float
        public typealias cblas_dsdot = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int, _ y: UnsafePointer<Float>?, _ incy: cblas_int) -> Double
        public typealias cblas_sdot = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int, _ y: UnsafePointer<Float>?, _ incy: cblas_int) -> Float
        public typealias cblas_ddot = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int, _ y: UnsafePointer<Double>?, _ incy: cblas_int) -> Double

        public typealias cblas_cdotu_sub = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeRawPointer?, _ incy: cblas_int, _ ret: UnsafeMutableRawPointer?) -> Void
        public typealias cblas_cdotc_sub = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeRawPointer?, _ incy: cblas_int, _ ret: UnsafeMutableRawPointer?) -> Void
        public typealias cblas_zdotu_sub = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeRawPointer?, _ incy: cblas_int, _ ret: UnsafeMutableRawPointer?) -> Void
        public typealias cblas_zdotc_sub = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeRawPointer?, _ incy: cblas_int, _ ret: UnsafeMutableRawPointer?) -> Void

        public typealias cblas_sasum = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Float
        public typealias cblas_dasum = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Double
        public typealias cblas_scasum = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Float
        public typealias cblas_dzasum = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Double
        public typealias cblas_ssum = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Float
        public typealias cblas_dsum = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Double
        public typealias cblas_scsum = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Float
        public typealias cblas_dzsum = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Double
        public typealias cblas_snrm2 = @convention(c) (_ N: cblas_int, _ X: UnsafePointer<Float>?, _ incX: cblas_int) -> Float
        public typealias cblas_dnrm2 = @convention(c) (_ N: cblas_int, _ X: UnsafePointer<Double>?, _ incX: cblas_int) -> Double
        public typealias cblas_scnrm2 = @convention(c) (_ N: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int) -> Float
        public typealias cblas_dznrm2 = @convention(c) (_ N: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int) -> Double
        public typealias cblas_isamax = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Int
        public typealias cblas_idamax = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Int
        public typealias cblas_icamax = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_izamax = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_isamin = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Int
        public typealias cblas_idamin = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Int
        public typealias cblas_icamin = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_izamin = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_samax = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Float
        public typealias cblas_damax = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Double
        public typealias cblas_scamax = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Float
        public typealias cblas_dzamax = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Double
        public typealias cblas_samin = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Float
        public typealias cblas_damin = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Double
        public typealias cblas_scamin = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Float
        public typealias cblas_dzamin = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Double
        public typealias cblas_ismax = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Int
        public typealias cblas_idmax = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Int
        public typealias cblas_icmax = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_izmax = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_ismin = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int) -> Int
        public typealias cblas_idmin = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int) -> Int
        public typealias cblas_icmin = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int
        public typealias cblas_izmin = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int) -> Int

        public typealias cblas_saxpy = @convention(c) (_ n: cblas_int, _ alpha: Float, _ x: UnsafePointer<Float>?, _ incx: cblas_int, _ y: UnsafeMutablePointer<Float>?, _ incy: cblas_int) -> Void
        public typealias cblas_daxpy = @convention(c) (_ n: cblas_int, _ alpha: Double, _ x: UnsafePointer<Double>?, _ incx: cblas_int, _ y: UnsafeMutablePointer<Double>?, _ incy: cblas_int) -> Void
        public typealias cblas_caxpy = @convention(c) (_ n: cblas_int, _ alpha: UnsafeRawPointer?, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void
        public typealias cblas_zaxpy = @convention(c) (_ n: cblas_int, _ alpha: UnsafeRawPointer?, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void

        public typealias cblas_caxpyc = @convention(c) (_ n: cblas_int, _ alpha: UnsafeRawPointer?, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void
        public typealias cblas_zaxpyc = @convention(c) (_ n: cblas_int, _ alpha: UnsafeRawPointer?, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void

        public typealias cblas_scopy = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int, _ y: UnsafeMutablePointer<Float>?, _ incy: cblas_int) -> Void
        public typealias cblas_dcopy = @convention(c) (_ n: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int, _ y: UnsafeMutablePointer<Double>?, _ incy: cblas_int) -> Void
        public typealias cblas_ccopy = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void
        public typealias cblas_zcopy = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void

        public typealias cblas_sswap = @convention(c) (_ n: cblas_int, _ x: UnsafeMutablePointer<Float>?, _ incx: cblas_int, _ y: UnsafeMutablePointer<Float>?, _ incy: cblas_int) -> Void
        public typealias cblas_dswap = @convention(c) (_ n: cblas_int, _ x: UnsafeMutablePointer<Double>?, _ incx: cblas_int, _ y: UnsafeMutablePointer<Double>?, _ incy: cblas_int) -> Void
        public typealias cblas_cswap = @convention(c) (_ n: cblas_int, _ x: UnsafeMutableRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void
        public typealias cblas_zswap = @convention(c) (_ n: cblas_int, _ x: UnsafeMutableRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void

        public typealias cblas_srot = @convention(c) (_ N: cblas_int, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int, _ Y: UnsafeMutablePointer<Float>?, _ incY: cblas_int, _ c: Float, _ s: Float) -> Void
        public typealias cblas_drot = @convention(c) (_ N: cblas_int, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int, _ Y: UnsafeMutablePointer<Double>?, _ incY: cblas_int, _ c: Double, _ s: Double) -> Void
        public typealias cblas_csrot = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incY: cblas_int, _ c: Float, _ s: Float) -> Void
        public typealias cblas_zdrot = @convention(c) (_ n: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ y: UnsafeMutableRawPointer?, _ incY: cblas_int, _ c: Double, _ s: Double) -> Void

        public typealias cblas_srotg = @convention(c) (_ a: UnsafeMutablePointer<Float>?, _ b: UnsafeMutablePointer<Float>?, _ c: UnsafeMutablePointer<Float>?, _ s: UnsafeMutablePointer<Float>?) -> Void
        public typealias cblas_drotg = @convention(c) (_ a: UnsafeMutablePointer<Double>?, _ b: UnsafeMutablePointer<Double>?, _ c: UnsafeMutablePointer<Double>?, _ s: UnsafeMutablePointer<Double>?) -> Void
        public typealias cblas_crotg = @convention(c) (_ a: UnsafeMutableRawPointer?, _ b: UnsafeMutableRawPointer?, _ c: UnsafeMutablePointer<Float>?, _ s: UnsafeMutableRawPointer?) -> Void
        public typealias cblas_zrotg = @convention(c) (_ a: UnsafeMutableRawPointer?, _ b: UnsafeMutableRawPointer?, _ c: UnsafeMutablePointer<Double>?, _ s: UnsafeMutableRawPointer?) -> Void


        public typealias cblas_srotm = @convention(c) (_ N: cblas_int, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int, _ Y: UnsafeMutablePointer<Float>?, _ incY: cblas_int, _ P: UnsafePointer<Float>?) -> Void
        public typealias cblas_drotm = @convention(c) (_ N: cblas_int, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int, _ Y: UnsafeMutablePointer<Double>?, _ incY: cblas_int, _ P: UnsafePointer<Double>?) -> Void

        public typealias cblas_srotmg = @convention(c) (_ d1: UnsafeMutablePointer<Float>?, _ d2: UnsafeMutablePointer<Float>?, _ b1: UnsafeMutablePointer<Float>?, _ b2: Float, _ P: UnsafeMutablePointer<Float>?) -> Void
        public typealias cblas_drotmg = @convention(c) (_ d1: UnsafeMutablePointer<Double>?, _ d2: UnsafeMutablePointer<Double>?, _ b1: UnsafeMutablePointer<Double>?, _ b2: Double, _ P: UnsafeMutablePointer<Double>?) -> Void

        public typealias cblas_sscal = @convention(c) (_ N: cblas_int, _ alpha: Float, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dscal = @convention(c) (_ N: cblas_int, _ alpha: Double, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_cscal = @convention(c) (_ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_zscal = @convention(c) (_ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_csscal = @convention(c) (_ N: cblas_int, _ alpha: Float, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_zdscal = @convention(c) (_ N: cblas_int, _ alpha: Double, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_sgemv = @convention(c) (_ order: BLAS.Order.RawValue, _ trans: BLAS.Transpose.RawValue, _ m: cblas_int, _ n: cblas_int,          _ alpha: Float, _ a: UnsafePointer<Float>?, _ lda: cblas_int, _ x: UnsafePointer<Float>?, _ incx: cblas_int, _ beta: Float, _ y: UnsafeMutablePointer<Float>?, _ incy: cblas_int) -> Void
        public typealias cblas_dgemv = @convention(c) (_ order: BLAS.Order.RawValue, _ trans: BLAS.Transpose.RawValue, _ m: cblas_int, _ n: cblas_int,          _ alpha: Double, _ a: UnsafePointer<Double>?, _ lda: cblas_int, _ x: UnsafePointer<Double>?, _ incx: cblas_int, _ beta: Double, _ y: UnsafeMutablePointer<Double>?, _ incy: cblas_int) -> Void
        public typealias cblas_cgemv = @convention(c) (_ order: BLAS.Order.RawValue, _ trans: BLAS.Transpose.RawValue, _ m: cblas_int, _ n: cblas_int,          _ alpha: UnsafeRawPointer?, _ a: UnsafeRawPointer?, _ lda: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ beta: UnsafeRawPointer?, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void
        public typealias cblas_zgemv = @convention(c) (_ order: BLAS.Order.RawValue, _ trans: BLAS.Transpose.RawValue, _ m: cblas_int, _ n: cblas_int,          _ alpha: UnsafeRawPointer?, _ a: UnsafeRawPointer?, _ lda: cblas_int, _ x: UnsafeRawPointer?, _ incx: cblas_int, _ beta: UnsafeRawPointer?, _ y: UnsafeMutableRawPointer?, _ incy: cblas_int) -> Void

        public typealias cblas_sger = @convention(c) (_ order: BLAS.Order.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Float, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ Y: UnsafePointer<Float>?, _ incY: cblas_int, _ A: UnsafeMutablePointer<Float>?, _ lda: cblas_int) -> Void
        public typealias cblas_dger = @convention(c) (_ order: BLAS.Order.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Double, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ Y: UnsafePointer<Double>?, _ incY: cblas_int, _ A: UnsafeMutablePointer<Double>?, _ lda: cblas_int) -> Void
        public typealias cblas_cgeru = @convention(c) (_ order: BLAS.Order.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void
        public typealias cblas_cgerc = @convention(c) (_ order: BLAS.Order.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void
        public typealias cblas_zgeru = @convention(c) (_ order: BLAS.Order.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void
        public typealias cblas_zgerc = @convention(c) (_ order: BLAS.Order.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void

        public typealias cblas_strsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dtrsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_ctrsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_ztrsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_strmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dtrmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_ctrmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_ztrmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_ssyr = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ A: UnsafeMutablePointer<Float>?, _ lda: cblas_int) -> Void
        public typealias cblas_dsyr = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ A: UnsafeMutablePointer<Double>?, _ lda: cblas_int) -> Void
        public typealias cblas_cher = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void
        public typealias cblas_zher = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void

        public typealias cblas_ssyr2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ Y: UnsafePointer<Float>?, _ incY: cblas_int, _ A: UnsafeMutablePointer<Float>?, _ lda: cblas_int) -> Void
        public typealias cblas_dsyr2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ Y: UnsafePointer<Double>?, _ incY: cblas_int, _ A: UnsafeMutablePointer<Double>?, _ lda: cblas_int) -> Void
        public typealias cblas_cher2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void
        public typealias cblas_zher2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ A: UnsafeMutableRawPointer?, _ lda: cblas_int) -> Void

        public typealias cblas_sgbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ KL: cblas_int, _ KU: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ beta: Float, _ Y: UnsafeMutablePointer<Float>?, _ incY: cblas_int) -> Void
        public typealias cblas_dgbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ KL: cblas_int, _ KU: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ beta: Double, _ Y: UnsafeMutablePointer<Double>?, _ incY: cblas_int) -> Void
        public typealias cblas_cgbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ KL: cblas_int, _ KU: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void
        public typealias cblas_zgbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ KL: cblas_int, _ KU: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void

        public typealias cblas_ssbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ K: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ beta: Float, _ Y: UnsafeMutablePointer<Float>?, _ incY: cblas_int) -> Void
        public typealias cblas_dsbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ K: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ beta: Double, _ Y: UnsafeMutablePointer<Double>?, _ incY: cblas_int) -> Void


        public typealias cblas_stbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dtbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_ctbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_ztbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_stbsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dtbsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_ctbsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_ztbsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ K: cblas_int, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_stpmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafePointer<Float>?, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dtpmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafePointer<Double>?, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_ctpmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_ztpmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_stpsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafePointer<Float>?, _ X: UnsafeMutablePointer<Float>?, _ incX: cblas_int) -> Void
        public typealias cblas_dtpsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafePointer<Double>?, _ X: UnsafeMutablePointer<Double>?, _ incX: cblas_int) -> Void
        public typealias cblas_ctpsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void
        public typealias cblas_ztpsv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ N: cblas_int, _ Ap: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: cblas_int) -> Void

        public typealias cblas_ssymv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ beta: Float, _ Y: UnsafeMutablePointer<Float>?, _ incY: cblas_int) -> Void
        public typealias cblas_dsymv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ beta: Double, _ Y: UnsafeMutablePointer<Double>?, _ incY: cblas_int) -> Void
        public typealias cblas_chemv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void
        public typealias cblas_zhemv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void


        public typealias cblas_sspmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ Ap: UnsafePointer<Float>?, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ beta: Float, _ Y: UnsafeMutablePointer<Float>?, _ incY: cblas_int) -> Void
        public typealias cblas_dspmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ Ap: UnsafePointer<Double>?, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ beta: Double, _ Y: UnsafeMutablePointer<Double>?, _ incY: cblas_int) -> Void

        public typealias cblas_sspr = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ Ap: UnsafeMutablePointer<Float>?) -> Void
        public typealias cblas_dspr = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ Ap: UnsafeMutablePointer<Double>?) -> Void

        public typealias cblas_chpr = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ A: UnsafeMutableRawPointer?) -> Void
        public typealias cblas_zhpr = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ A: UnsafeMutableRawPointer?) -> Void

        public typealias cblas_sspr2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Float, _ X: UnsafePointer<Float>?, _ incX: cblas_int, _ Y: UnsafePointer<Float>?, _ incY: cblas_int, _ A: UnsafeMutablePointer<Float>?) -> Void
        public typealias cblas_dspr2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: Double, _ X: UnsafePointer<Double>?, _ incX: cblas_int, _ Y: UnsafePointer<Double>?, _ incY: cblas_int, _ A: UnsafeMutablePointer<Double>?) -> Void
        public typealias cblas_chpr2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ Ap: UnsafeMutableRawPointer?) -> Void
        public typealias cblas_zhpr2 = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ Y: UnsafeRawPointer?, _ incY: cblas_int, _ Ap: UnsafeMutableRawPointer?) -> Void

        public typealias cblas_chbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void
        public typealias cblas_zhbmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void

        public typealias cblas_chpmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int,          _ alpha: UnsafeRawPointer?, _ Ap: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void
        public typealias cblas_zhpmv = @convention(c) (_ order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ N: cblas_int,          _ alpha: UnsafeRawPointer?, _ Ap: UnsafeRawPointer?, _ X: UnsafeRawPointer?, _ incX: cblas_int, _ beta: UnsafeRawPointer?, _ Y: UnsafeMutableRawPointer?, _ incY: cblas_int) -> Void

        public typealias cblas_sgemm = @convention(c) (_ Order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ K: cblas_int,          _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ B: UnsafePointer<Float>?, _ ldb: cblas_int, _ beta: Float, _ C: UnsafeMutablePointer<Float>?, _ ldc: cblas_int) -> Void
        public typealias cblas_dgemm = @convention(c) (_ Order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ K: cblas_int,          _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ B: UnsafePointer<Double>?, _ ldb: cblas_int, _ beta: Double, _ C: UnsafeMutablePointer<Double>?, _ ldc: cblas_int) -> Void
        public typealias cblas_cgemm = @convention(c) (_ Order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_cgemm3m = @convention(c) (_ Order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zgemm = @convention(c) (_ Order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zgemm3m = @convention(c) (_ Order: BLAS.Order.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ N: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_sgemmt = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ K: cblas_int,          _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ B: UnsafePointer<Float>?, _ ldb: cblas_int, _ beta: Float, _ C: UnsafeMutablePointer<Float>?, _ ldc: cblas_int) -> Void
        public typealias cblas_dgemmt = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ K: cblas_int,          _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ B: UnsafePointer<Double>?, _ ldb: cblas_int, _ beta: Double, _ C: UnsafeMutablePointer<Double>?, _ ldc: cblas_int) -> Void
        public typealias cblas_cgemmt = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zgemmt = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ TransB: BLAS.Transpose.RawValue, _ M: cblas_int, _ K: cblas_int,          _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_ssymm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ B: UnsafePointer<Float>?, _ ldb: cblas_int, _ beta: Float, _ C: UnsafeMutablePointer<Float>?, _ ldc: cblas_int) -> Void
        public typealias cblas_dsymm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ B: UnsafePointer<Double>?, _ ldb: cblas_int, _ beta: Double, _ C: UnsafeMutablePointer<Double>?, _ ldc: cblas_int) -> Void
        public typealias cblas_csymm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zsymm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_ssyrk = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,          _ N: cblas_int, _ K: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ beta: Float, _ C: UnsafeMutablePointer<Float>?, _ ldc: cblas_int) -> Void
        public typealias cblas_dsyrk = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,          _ N: cblas_int, _ K: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ beta: Double, _ C: UnsafeMutablePointer<Double>?, _ ldc: cblas_int) -> Void
        public typealias cblas_csyrk = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,          _ N: cblas_int, _ K: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zsyrk = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,          _ N: cblas_int, _ K: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_ssyr2k = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,           _ N: cblas_int, _ K: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ B: UnsafePointer<Float>?, _ ldb: cblas_int, _ beta: Float, _ C: UnsafeMutablePointer<Float>?, _ ldc: cblas_int) -> Void
        public typealias cblas_dsyr2k = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,           _ N: cblas_int, _ K: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ B: UnsafePointer<Double>?, _ ldb: cblas_int, _ beta: Double, _ C: UnsafeMutablePointer<Double>?, _ ldc: cblas_int) -> Void
        public typealias cblas_csyr2k = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,           _ N: cblas_int, _ K: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zsyr2k = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue,           _ N: cblas_int, _ K: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_strmm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ B: UnsafeMutablePointer<Float>?, _ ldb: cblas_int) -> Void
        public typealias cblas_dtrmm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ B: UnsafeMutablePointer<Double>?, _ ldb: cblas_int) -> Void
        public typealias cblas_ctrmm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeMutableRawPointer?, _ ldb: cblas_int) -> Void
        public typealias cblas_ztrmm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeMutableRawPointer?, _ ldb: cblas_int) -> Void

        public typealias cblas_strsm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Float, _ A: UnsafePointer<Float>?, _ lda: cblas_int, _ B: UnsafeMutablePointer<Float>?, _ ldb: cblas_int) -> Void
        public typealias cblas_dtrsm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: Double, _ A: UnsafePointer<Double>?, _ lda: cblas_int, _ B: UnsafeMutablePointer<Double>?, _ ldb: cblas_int) -> Void
        public typealias cblas_ctrsm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeMutableRawPointer?, _ ldb: cblas_int) -> Void
        public typealias cblas_ztrsm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ TransA: BLAS.Transpose.RawValue, _ Diag: BLAS.Diagonal.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeMutableRawPointer?, _ ldb: cblas_int) -> Void

        public typealias cblas_chemm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zhemm = @convention(c) (_ Order: BLAS.Order.RawValue, _ Side: BLAS.Side.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ M: cblas_int, _ N: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: UnsafeRawPointer?, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_cherk = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue, _ N: cblas_int, _ K: cblas_int, _ alpha: Float, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ beta: Float, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zherk = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue, _ N: cblas_int, _ K: cblas_int, _ alpha: Double, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ beta: Double, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

        public typealias cblas_cher2k = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue, _ N: cblas_int, _ K: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: Float, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void
        public typealias cblas_zher2k = @convention(c) (_ Order: BLAS.Order.RawValue, _ Uplo: BLAS.UpperLower.RawValue, _ Trans: BLAS.Transpose.RawValue, _ N: cblas_int, _ K: cblas_int, _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, _ lda: cblas_int, _ B: UnsafeRawPointer?, _ ldb: cblas_int, _ beta: Double, _ C: UnsafeMutableRawPointer?, _ ldc: cblas_int) -> Void

    }
}
