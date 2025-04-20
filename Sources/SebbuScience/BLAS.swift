#if canImport(COpenBLAS)
@_exported import COpenBLAS
#elseif canImport(Accelerate)
import Accelerate
#endif

#if canImport(WinSDK)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#endif

@usableFromInline
internal enum BLAS {
    #if os(Windows)
    @usableFromInline
    internal nonisolated(unsafe) static let handle: HMODULE? = {
        if let handle = loadLibrary(name: "libopenblas.dll") {
            return handle
        }
        print("Failed to load libopenblas.dll")
        return nil
    }()
    #elseif os(Linux)
    @usableFromInline
    internal nonisolated(unsafe) static let handle: UnsafeMutableRawPointer? = {
        if let handle = loadLibrary(name: "libopenblas.so") {
            return handle
        }
        let dlErrorMessage = getDLErrorMessage()
        print("Failed to load libopenblas.so: \(dlErrorMessage)")
        return nil
    }()
    #endif

    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        loadSymbol(name:name, handle: handle)
    }
    
    // Float functions
    @usableFromInline
    internal static let sgemm: CBLAS_SGEMM? = load(name: "cblas_sgemm")
    @usableFromInline
    internal static let saxpy: CBLAS_SAXPY? = load(name: "cblas_saxpy")
    @usableFromInline
    internal static let sscal: CBLAS_SSCAL? = load(name: "cblas_sscal")
    @usableFromInline
    internal static let sgemv: CBLAS_SGEMV? = load(name: "cblas_sgemv")
    @usableFromInline
    internal static let sdot: CBLAS_SDOT? = load(name: "cblas_sdot")

    // Double functions
    @usableFromInline
    internal static let dgemm: CBLAS_DGEMM? = load(name: "cblas_dgemm")
    @usableFromInline
    internal static let daxpy: CBLAS_DAXPY? = load(name: "cblas_daxpy")
    @usableFromInline
    internal static let dscal: CBLAS_DSCAL? = load(name: "cblas_dscal")
    @usableFromInline
    internal static let dgemv: CBLAS_DGEMV? = load(name: "cblas_dgemv")
    @usableFromInline
    internal static let ddot: CBLAS_DDOT? = load(name: "cblas_ddot")

    // Single precision complex functions
    @usableFromInline
    internal static let cgemm: CBLAS_CGEMM? = load(name: "cblas_cgemm")
    @usableFromInline
    internal static let caxpy: CBLAS_CAXPY? = load(name: "cblas_caxpy")
    @usableFromInline
    internal static let cscal: CBLAS_CSCAL? = load(name: "cblas_cscal")
    @usableFromInline
    internal static let csscal: CBLAS_CSSCAL? = load(name: "cblas_csscal")
    @usableFromInline
    internal static let cgemv: CBLAS_CGEMV? = load(name: "cblas_cgemv")
    @usableFromInline
    internal static let cdotu_sub: CBLAS_CDOTU_SUB? = load(name: "cblas_cdotu_sub")
    @usableFromInline
    internal static let cdotc_sub: CBLAS_CDOTC_SUB? = load(name: "cblas_cdotc_sub")

    // Double precision complex functions
    @usableFromInline
    internal static let zgemm: CBLAS_ZGEMM? = load(name: "cblas_zgemm")
    @usableFromInline
    internal static let zaxpy: CBLAS_ZAXPY? = load(name: "cblas_zaxpy")
    @usableFromInline
    internal static let zscal: CBLAS_ZSCAL? = load(name: "cblas_zscal")
    @usableFromInline
    internal static let zdscal: CBLAS_ZDSCAL? = load(name: "cblas_zdscal")
    @usableFromInline
    internal static let zgemv: CBLAS_ZGEMV? = load(name: "cblas_zgemv")
    @usableFromInline
    internal static let zdotu_sub: CBLAS_ZDOTU_SUB? = load(name: "cblas_zdotu_sub")
    @usableFromInline
    internal static let zdotc_sub: CBLAS_ZDOTC_SUB? = load(name: "cblas_zdotc_sub")
}

///MARK: Typealiases
extension BLAS {
    // Flot functions
    @usableFromInline
    typealias CBLAS_SAXPY = @convention(c) (_ n: blasint, _ alpha: Float, _ x: UnsafePointer<Float>?, _ incx: blasint, _ y: UnsafeMutablePointer<Float>?, _ incy: blasint) -> Void
    @usableFromInline
    typealias CBLAS_SSCAL = @convention(c) (_ N: blasint, _ alpha: Float, _ X: UnsafeMutablePointer<Float>?, _ incX: blasint) -> Void
    @usableFromInline
    typealias CBLAS_SGEMM = @convention(c) (_ Order: CBLAS_ORDER, _ TransA: CBLAS_TRANSPOSE, _ TransB: CBLAS_TRANSPOSE, 
                                            _ M: blasint, _ N: blasint, _ K: blasint, 
                                            _ alpha: Float, _ A: UnsafePointer<Float>?, 
                                            _ lda: blasint, _ B: UnsafePointer<Float>?, 
                                            _ ldb: blasint, _ beta: Float, 
                                            _ C: UnsafeMutablePointer<Float>?, _ ldc: blasint) -> Void
    @usableFromInline
    typealias CBLAS_SGEMV = @convention(c) (_ order: CBLAS_ORDER, _ trans: CBLAS_TRANSPOSE, 
                                            _ m: blasint, _ n: blasint, 
                                            _ alpha: Float, _ a: UnsafePointer<Float>?, 
                                            _ lda: blasint, _ x: UnsafePointer<Float>?, _ incx: blasint, 
                                            _ beta: Float, _ y: UnsafeMutablePointer<Float>?, _ incy: blasint) -> Void

    @usableFromInline
    typealias CBLAS_SDOT = @convention(c) (_ n: blasint, _ x: UnsafePointer<Float>?, _ incx: blasint, 
                                           _ y: UnsafePointer<Float>?, _ incy: blasint) -> Float

    // Double functions
    @usableFromInline
    typealias CBLAS_DAXPY = @convention(c) (_ n: blasint, _ alpha: Double, _ x: UnsafePointer<Double>?, _ incx: blasint, _ y: UnsafeMutablePointer<Double>?, _ incy: blasint) -> Void
    @usableFromInline
    typealias CBLAS_DSCAL = @convention(c) (_ N: blasint, _ alpha: Double, _ X: UnsafeMutablePointer<Double>?, _ incX: blasint) -> Void
    @usableFromInline
    typealias CBLAS_DGEMM = @convention(c) (_ Order: CBLAS_ORDER, _ TransA: CBLAS_TRANSPOSE, _ TransB: CBLAS_TRANSPOSE, 
                                            _ M: blasint, _ N: blasint, _ K: blasint, 
                                            _ alpha: Double, _ A: UnsafePointer<Double>?, 
                                            _ lda: blasint, _ B: UnsafePointer<Double>?, 
                                            _ ldb: blasint, _ beta: Double, 
                                            _ C: UnsafeMutablePointer<Double>?, _ ldc: blasint) -> Void
    @usableFromInline
    typealias CBLAS_DGEMV = @convention(c) (_ order: CBLAS_ORDER, _ trans: CBLAS_TRANSPOSE, 
                                            _ m: blasint, _ n: blasint, 
                                            _ alpha: Double, _ a: UnsafePointer<Double>?, 
                                            _ lda: blasint, _ x: UnsafePointer<Double>?, _ incx: blasint, 
                                            _ beta: Double, _ y: UnsafeMutablePointer<Double>?, _ incy: blasint) -> Void

    @usableFromInline
    typealias CBLAS_DDOT = @convention(c) (_ n: blasint, _ x: UnsafePointer<Double>?, _ incx: blasint, 
                                           _ y: UnsafePointer<Double>?, _ incy: blasint) -> Double

    // Single precision complex functions
    @usableFromInline
    typealias CBLAS_CAXPY = @convention(c) (_ n: blasint, _ alpha: UnsafeRawPointer?, _ x: UnsafeRawPointer?, _ incx: blasint, _ y: UnsafeMutableRawPointer?, _ incy: blasint) -> Void
    @usableFromInline
    typealias CBLAS_CSCAL = @convention(c) (_ N: blasint, _ alpha: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: blasint) -> Void
    @usableFromInline
    typealias CBLAS_CSSCAL = @convention(c) (_ N: blasint, _ alpha: Float, _ X: UnsafeMutableRawPointer?, _ incX: blasint) -> Void
    @usableFromInline
    typealias CBLAS_CGEMM = @convention(c) (_ Order: CBLAS_ORDER, _ TransA: CBLAS_TRANSPOSE, _ TransB: CBLAS_TRANSPOSE, 
                                            _ M: blasint, _ N: blasint, _ K: blasint, 
                                            _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, 
                                            _ lda: blasint, _ B: UnsafeRawPointer?, 
                                            _ ldb: blasint, _ beta: UnsafeRawPointer?, 
                                            _ C: UnsafeMutableRawPointer?, _ ldc: blasint) -> Void

    @usableFromInline
    typealias CBLAS_CGEMV = @convention(c) (_ order: CBLAS_ORDER, _ trans: CBLAS_TRANSPOSE, 
                                            _ m: blasint, _ n: blasint, 
                                            _ alpha: UnsafeRawPointer?, _ a: UnsafeRawPointer?, 
                                            _ lda: blasint, _ x: UnsafeRawPointer?, _ incx: blasint, 
                                            _ beta: UnsafeRawPointer?, _ y: UnsafeMutableRawPointer?, _ incy: blasint) -> Void

    @usableFromInline
    typealias CBLAS_CDOTU_SUB = @convention(c) (_ n: blasint, _ x: UnsafeRawPointer?, _ incx: blasint, 
                                                _ y: UnsafeRawPointer?, _ incy: blasint, _ ret: UnsafeMutableRawPointer?) -> Void

    @usableFromInline
    typealias CBLAS_CDOTC_SUB = @convention(c) (_ n: blasint, _ x: UnsafeRawPointer?, _ incx: blasint, 
                                                _ y: UnsafeRawPointer?, _ incy: blasint, _ ret: UnsafeMutableRawPointer?) -> Void

    // Double precision complex functions
    @usableFromInline
    typealias CBLAS_ZAXPY = @convention(c) (_ n: blasint, _ alpha: UnsafeRawPointer?, _ x: UnsafeRawPointer?, _ incx: blasint, _ y: UnsafeMutableRawPointer?, _ incy: blasint) -> Void
    @usableFromInline
    typealias CBLAS_ZSCAL = @convention(c) (_ N: blasint, _ alpha: UnsafeRawPointer?, _ X: UnsafeMutableRawPointer?, _ incX: blasint) -> Void
    @usableFromInline
    typealias CBLAS_ZDSCAL = @convention(c) (_ N: blasint, _ alpha: Double, _ X: UnsafeMutableRawPointer?, _ incX: blasint) -> Void
    @usableFromInline
    typealias CBLAS_ZGEMM = @convention(c) (_ Order: CBLAS_ORDER, _ TransA: CBLAS_TRANSPOSE, _ TransB: CBLAS_TRANSPOSE, 
                                            _ M: blasint, _ N: blasint, _ K: blasint, 
                                            _ alpha: UnsafeRawPointer?, _ A: UnsafeRawPointer?, 
                                            _ lda: blasint, _ B: UnsafeRawPointer?, 
                                            _ ldb: blasint, _ beta: UnsafeRawPointer?, 
                                            _ C: UnsafeMutableRawPointer?, _ ldc: blasint) -> Void

    @usableFromInline
    typealias CBLAS_ZGEMV = @convention(c) (_ order: CBLAS_ORDER, _ trans: CBLAS_TRANSPOSE, 
                                            _ m: blasint, _ n: blasint, 
                                            _ alpha: UnsafeRawPointer?, _ a: UnsafeRawPointer?, 
                                            _ lda: blasint, _ x: UnsafeRawPointer?, _ incx: blasint, 
                                            _ beta: UnsafeRawPointer?, _ y: UnsafeMutableRawPointer?, _ incy: blasint) -> Void

    @usableFromInline
    typealias CBLAS_ZDOTU_SUB = @convention(c) (_ n: blasint, _ x: UnsafeRawPointer?, _ incx: blasint, 
                                                _ y: UnsafeRawPointer?, _ incy: blasint, _ ret: UnsafeMutableRawPointer?) -> Void

    @usableFromInline
    typealias CBLAS_ZDOTC_SUB = @convention(c) (_ n: blasint, _ x: UnsafeRawPointer?, _ incx: blasint, 
                                                _ y: UnsafeRawPointer?, _ incy: blasint, _ ret: UnsafeMutableRawPointer?) -> Void
}