#if canImport(COpenBLAS) 
import COpenBLAS
public typealias blasint = Int32
public typealias lapack_int = Int32
#elseif canImport(_COpenBLASWindows)
import _COpenBLASWindows
public typealias blasint = Int32
public typealias lapack_int = Int32
#elseif canImport(Accelerate)
import Accelerate
public typealias blasint = __LAPACK_int
public typealias lapack_int = __LAPACK_int
#endif

public enum BLAS {
    @inlinable
    public static var isAvailable: Bool {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        true
        #else
        false
        #endif
    }
}

public extension BLAS {
    enum Order: RawRepresentable {
        case rowMajor
        case columnMajor

        public var rawValue: CBLAS_ORDER {
            switch self {
                case .rowMajor: CblasRowMajor
                case .columnMajor: CblasColMajor
            }
        }

        public init?(rawValue: CBLAS_ORDER) {
            switch rawValue {
                case CblasRowMajor: self = .rowMajor
                case CblasColMajor: self = .columnMajor
                default: fatalError("Unreachable")
            }
        }   
    }

    enum Transpose: RawRepresentable {
        case noTranspose
        case transpose
        case conjugateTranspose
        case conjugateNoTranspose

        public var rawValue: CBLAS_TRANSPOSE {
            switch self {
                case .noTranspose: CblasNoTrans
                case .transpose: CblasTrans
                case .conjugateTranspose: CblasConjTrans
                case .conjugateNoTranspose: 
                #if canImport(Accelerate)
                    AtlasConj
                #else
                    CblasConjNoTrans
                #endif
            }
        }

        public init?(rawValue: CBLAS_TRANSPOSE) {
            switch rawValue {
                case CblasNoTrans: self = .noTranspose
                case CblasTrans: self = .transpose
                case CblasConjTrans: self = .conjugateTranspose
                #if canImport(Accelerate)
                case AtlasConj: self = .conjugateNoTranspose
                #else
                case CblasConjNoTrans: self = .conjugateNoTranspose
                #endif
                default: fatalError("Unreachable")
            }
        }
    }

    enum UpLo: RawRepresentable {
        case upper
        case lower

        public var rawValue: CBLAS_UPLO {
            switch self {
                case .upper: CblasUpper
                case .lower: CblasLower
            }
        }

        public init?(rawValue: CBLAS_UPLO) {
            switch rawValue {
                case CblasUpper: self = .upper
                case CblasLower: self = .lower
                default: fatalError("Unreachable")
            }
        }
    }

    enum Diag: RawRepresentable {
        case nonUnit
        case unit

        public var rawValue: CBLAS_DIAG {
            switch self {
                case .nonUnit: CblasNonUnit
                case .unit: CblasUnit
            }
        }

        public init?(rawValue: CBLAS_DIAG) {
            switch rawValue {
                case CblasNonUnit: self = .nonUnit
                case CblasUnit: self = .unit
                default: fatalError("Unreachable")
            }
        }
    }

    enum Side: RawRepresentable {
        case left
        case right

        public var rawValue: CBLAS_SIDE {
            switch self {
                case .left: CblasLeft
                case .right: CblasRight
            }
        }

        public init?(rawValue: CBLAS_SIDE) {
            switch rawValue {
                case CblasLeft: self = .left
                case CblasRight: self = .right
                default: fatalError("Unreachable")
            }
        }
    }
    typealias Layout = Order
}

public extension BLAS {
    @inlinable
    @_transparent
    static func daxpy(_ N: Int, _ alpha: Double, _ x: UnsafePointer<Double>, _ incx: Int, _ y: UnsafeMutablePointer<Double>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_daxpy(blasint(N), alpha, x, blasint(incx), y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func saxpy(_ N: Int, _ alpha: Float, _ x: UnsafePointer<Float>, _ incx: Int, _ y: UnsafeMutablePointer<Float>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_saxpy(blasint(N), alpha, x, blasint(incx), y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zaxpy(_ N: Int, _ alpha: Complex<Double>, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ y: UnsafeMutablePointer<Complex<Double>>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            cblas_zaxpy(blasint(N), .init(alpha), .init(x), blasint(incx), .init(y), blasint(incy))
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zaxpy(_ N: Int, _ alpha: Double, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ y: UnsafeMutablePointer<Complex<Double>>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        assert(incx == 1 && incy == 1, "Currently this is implemented for single increments")
        let count = 2 * N
        x.withMemoryRebound(to: Double.self, capacity: count) { x in
            y.withMemoryRebound(to: Double.self, capacity: count) { y in 
                cblas_daxpy(blasint(count), alpha, x, 1, y, 1)
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func caxpy(_ N: Int, _ alpha: Complex<Float>, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ y: UnsafeMutablePointer<Complex<Float>>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            cblas_caxpy(blasint(N), .init(alpha), .init(x), blasint(incx), .init(y), blasint(incy))
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func caxpy(_ N: Int, _ alpha: Float, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ y: UnsafeMutablePointer<Complex<Float>>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        assert(incx == 1 && incy == 1, "Currently this is implemented for single increments")
        let count = 2 * N
        x.withMemoryRebound(to: Float.self, capacity: count) { x in
            y.withMemoryRebound(to: Float.self, capacity: count) { y in 
                cblas_saxpy(blasint(count), alpha, x, 1, y, 1)
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func dscal(_ N: Int, _ alpha: Double, _ x: UnsafeMutablePointer<Double>, _ incx: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_dscal(blasint(N), alpha, x, blasint(incx))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func sscal(_ N: Int, _ alpha: Float, _ x: UnsafeMutablePointer<Float>, _ incx: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_sscal(blasint(N), alpha, x, blasint(incx))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zscal(_ N: Int, _ alpha: Complex<Double>, _ x: UnsafeMutablePointer<Complex<Double>>, _ incx: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in
            cblas_zscal(blasint(N), .init(alpha), .init(x), blasint(incx))
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zdscal(_ N: Int, _ alpha: Double, _ x: UnsafeMutablePointer<Complex<Double>>, _ incx: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        assert(incx == 1, "Currently this is implemented for single increments")
        let count = 2 * N
        x.withMemoryRebound(to: Double.self, capacity: count) { x in 
            cblas_dscal(blasint(count), alpha, x, 1)
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func cscal(_ N: Int, _ alpha: Complex<Float>, _ x: UnsafeMutablePointer<Complex<Float>>, _ incx: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in
            cblas_cscal(blasint(N), .init(alpha), .init(x), blasint(incx))
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func csscal(_ N: Int, _ alpha: Float, _ x: UnsafeMutablePointer<Complex<Float>>, _ incx: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        assert(incx == 1, "Currently this is implemented for single increments")
        let count = 2 * N
        x.withMemoryRebound(to: Float.self, capacity: count) { x in 
            cblas_sscal(blasint(count), alpha, x, 1)
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func ddot(_ N: Int, _ x: UnsafePointer<Double>, _ incx: Int, _ y: UnsafePointer<Double>, _ incy: Int) -> Double {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_ddot(blasint(N), x, blasint(incx), y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func sdot(_ N: Int, _ x: UnsafePointer<Float>, _ incx: Int, _ y: UnsafePointer<Float>, _ incy: Int) -> Float {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_sdot(blasint(N), x, blasint(incx), y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zdotu(_ N: Int, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ y: UnsafePointer<Complex<Double>>, _ incy: Int) -> Complex<Double> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        var result: Complex<Double> = .zero
        withUnsafeMutablePointer(to: &result) { ret in 
            cblas_zdotu_sub(blasint(N), .init(x), blasint(incx), .init(y), blasint(incy), .init(ret))
        }
        return result
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zdotc(_ N: Int, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ y: UnsafePointer<Complex<Double>>, _ incy: Int) -> Complex<Double> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        var result: Complex<Double> = .zero
        withUnsafeMutablePointer(to: &result) { ret in 
            cblas_zdotc_sub(blasint(N), .init(x), blasint(incx), .init(y), blasint(incy), .init(ret))
        }
        return result
        #else
        fatalError("Not available on this platform")
        #endif
    }


    @inlinable
    @_transparent
    static func cdotu(_ N: Int, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ y: UnsafePointer<Complex<Float>>, _ incy: Int) -> Complex<Float> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        var result: Complex<Float> = .zero
        withUnsafeMutablePointer(to: &result) { ret in 
            cblas_cdotu_sub(blasint(N), .init(x), blasint(incx), .init(y), blasint(incy), .init(ret))
        }
        return result
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func cdotc(_ N: Int, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ y: UnsafePointer<Complex<Float>>, _ incy: Int) -> Complex<Float> {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        var result: Complex<Float> = .zero
        withUnsafeMutablePointer(to: &result) { ret in 
            cblas_cdotc_sub(blasint(N), .init(x), blasint(incx), .init(y), blasint(incy), .init(ret))
        }
        return result
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func dgemv(_ order: Order, _ trans: Transpose, _ m: Int, _ n: Int, _ alpha: Double, _ A: UnsafePointer<Double>, _ lda: Int, _ x: UnsafePointer<Double>, _ incx: Int, _ beta: Double, _ y: UnsafeMutablePointer<Double>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_dgemv(order.rawValue, trans.rawValue, blasint(m), blasint(n), alpha, A, blasint(lda), x, blasint(incx), beta, y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func sgemv(_ order: Order, _ trans: Transpose, _ m: Int, _ n: Int, _ alpha: Float, _ A: UnsafePointer<Float>, _ lda: Int, _ x: UnsafePointer<Float>, _ incx: Int, _ beta: Float, _ y: UnsafeMutablePointer<Float>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_sgemv(order.rawValue, trans.rawValue, blasint(m), blasint(n), alpha, A, blasint(lda), x, blasint(incx), beta, y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zgemv(_ order: Order, _ trans: Transpose, _ m: Int, _ n: Int, _ alpha: Complex<Double>, _ A: UnsafePointer<Complex<Double>>, _ lda: Int, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ beta: Complex<Double>, _ y: UnsafeMutablePointer<Complex<Double>>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in
            withUnsafePointer(to: beta) { beta in 
                cblas_zgemv(order.rawValue, trans.rawValue, blasint(m), blasint(n), .init(alpha), .init(A), blasint(lda), .init(x), blasint(incx), .init(beta), .init(y), blasint(incy))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func cgemv(_ order: Order, _ trans: Transpose, _ m: Int, _ n: Int, _ alpha: Complex<Float>, _ A: UnsafePointer<Complex<Float>>, _ lda: Int, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ beta: Complex<Float>, _ y: UnsafeMutablePointer<Complex<Float>>, _ incy: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in
            withUnsafePointer(to: beta) { beta in 
                cblas_cgemv(order.rawValue, trans.rawValue, blasint(m), blasint(n), .init(alpha), .init(A), blasint(lda), .init(x), blasint(incx), .init(beta), .init(y), blasint(incy))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func dgemm(_ order: Order, _ transA: Transpose, _ transB: Transpose, _ m: Int, _ n: Int, _ k: Int, _ alpha: Double, _ A: UnsafePointer<Double>, _ lda: Int, _ B: UnsafePointer<Double>, _ ldb: Int, _ beta: Double, _ C: UnsafeMutablePointer<Double>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_dgemm(order.rawValue, transA.rawValue, transB.rawValue, blasint(m), blasint(n), blasint(k), alpha, A, blasint(lda), B, blasint(ldb), beta, C, blasint(ldc))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func sgemm(_ order: Order, _ transA: Transpose, _ transB: Transpose, _ m: Int, _ n: Int, _ k: Int, _ alpha: Float, _ A: UnsafePointer<Float>, _ lda: Int, _ B: UnsafePointer<Float>, _ ldb: Int, _ beta: Float, _ C: UnsafeMutablePointer<Float>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_sgemm(order.rawValue, transA.rawValue, transB.rawValue, blasint(m), blasint(n), blasint(k), alpha, A, blasint(lda), B, blasint(ldb), beta, C, blasint(ldc))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zgemm(_ order: Order, _ transA: Transpose, _ transB: Transpose, _ m: Int, _ n: Int, _ k: Int, _ alpha: Complex<Double>, _ A: UnsafePointer<Complex<Double>>, _ lda: Int, _ B: UnsafePointer<Complex<Double>>, _ ldb: Int, _ beta: Complex<Double>, _ C: UnsafeMutablePointer<Complex<Double>>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_zgemm(order.rawValue, transA.rawValue, transB.rawValue, blasint(m), blasint(n), blasint(k), .init(alpha), .init(A), blasint(lda), .init(B), blasint(ldb), .init(beta), .init(C), blasint(ldc))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func cgemm(_ order: Order, _ transA: Transpose, _ transB: Transpose, _ m: Int, _ n: Int, _ k: Int, _ alpha: Complex<Float>, _ A: UnsafePointer<Complex<Float>>, _ lda: Int, _ B: UnsafePointer<Complex<Float>>, _ ldb: Int, _ beta: Complex<Float>, _ C: UnsafeMutablePointer<Complex<Float>>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_cgemm(order.rawValue, transA.rawValue, transB.rawValue, blasint(m), blasint(n), blasint(k), .init(alpha), .init(A), blasint(lda), .init(B), blasint(ldb), .init(beta), .init(C), blasint(ldc))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func dsymv(_ order: Order, _ uplo: UpLo, _ n: Int, _ alpha: Double, _ A: UnsafePointer<Double>, _ lda: Int, _ x: UnsafePointer<Double>, _ incx: Int, _ beta: Double, _ y: UnsafeMutablePointer<Double>, _ incy: Int) {
       #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_dsymv(order.rawValue, uplo.rawValue, blasint(n), alpha, A, blasint(lda), x, blasint(incx), beta, y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func ssymv(_ order: Order, _ uplo: UpLo, _ n: Int, _ alpha: Float, _ A: UnsafePointer<Float>, _ lda: Int, _ x: UnsafePointer<Float>, _ incx: Int, _ beta: Float, _ y: UnsafeMutablePointer<Float>, _ incy: Int) {
       #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_ssymv(order.rawValue, uplo.rawValue, blasint(n), alpha, A, blasint(lda), x, blasint(incx), beta, y, blasint(incy))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zhemv(_ order: Order, _ uplo: UpLo, _ n: Int, _ alpha: Complex<Double>, _ A: UnsafePointer<Complex<Double>>, _ lda: Int, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ beta: Complex<Double>, _ y: UnsafeMutablePointer<Complex<Double>>, _ incy: Int) {
       #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_zhemv(order.rawValue, uplo.rawValue, blasint(n), .init(alpha), .init(A), blasint(lda), .init(x), blasint(incx), .init(beta), .init(y), blasint(incy))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func chemv(_ order: Order, _ uplo: UpLo, _ n: Int, _ alpha: Complex<Float>, _ A: UnsafePointer<Complex<Float>>, _ lda: Int, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ beta: Complex<Float>, _ y: UnsafeMutablePointer<Complex<Float>>, _ incy: Int) {
       #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_chemv(order.rawValue, uplo.rawValue, blasint(n), .init(alpha), .init(A), blasint(lda), .init(x), blasint(incx), .init(beta), .init(y), blasint(incy))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func dsymm(_ order: Order, _ side: Side, _ uplo: UpLo, _ m: Int, _ n: Int, _ alpha: Double, _ A: UnsafePointer<Double>, _ lda: Int, _ B: UnsafePointer<Double>, _ ldb: Int, _ beta: Double, _ C: UnsafeMutablePointer<Double>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_dsymm(order.rawValue, side.rawValue, uplo.rawValue, blasint(m), blasint(n), alpha, A, blasint(lda), B, blasint(ldb), beta, C, blasint(ldc))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func ssymm(_ order: Order, _ side: Side, _ uplo: UpLo, _ m: Int, _ n: Int, _ alpha: Float, _ A: UnsafePointer<Float>, _ lda: Int, _ B: UnsafePointer<Float>, _ ldb: Int, _ beta: Float, _ C: UnsafeMutablePointer<Float>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        cblas_ssymm(order.rawValue, side.rawValue, uplo.rawValue, blasint(m), blasint(n), alpha, A, blasint(lda), B, blasint(ldb), beta, C, blasint(ldc))
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zsymm(_ order: Order, _ side: Side, _ uplo: UpLo, _ m: Int, _ n: Int, _ alpha: Complex<Double>, _ A: UnsafePointer<Complex<Double>>, _ lda: Int, _ B: UnsafePointer<Complex<Double>>, _ ldb: Int, _ beta: Complex<Double>, _ C: UnsafeMutablePointer<Complex<Double>>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_zsymm(order.rawValue, side.rawValue, uplo.rawValue, blasint(m), blasint(n), .init(alpha), .init(A), blasint(lda), .init(B), blasint(ldb), .init(beta), .init(C), blasint(ldc))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func csymm(_ order: Order, _ side: Side, _ uplo: UpLo, _ m: Int, _ n: Int, _ alpha: Complex<Float>, _ A: UnsafePointer<Complex<Float>>, _ lda: Int, _ B: UnsafePointer<Complex<Float>>, _ ldb: Int, _ beta: Complex<Float>, _ C: UnsafeMutablePointer<Complex<Float>>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_csymm(order.rawValue, side.rawValue, uplo.rawValue, blasint(m), blasint(n), .init(alpha), .init(A), blasint(lda), .init(B), blasint(ldb), .init(beta), .init(C), blasint(ldc))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func zhemm(_ order: Order, _ side: Side, _ uplo: UpLo, _ m: Int, _ n: Int, _ alpha: Complex<Double>, _ A: UnsafePointer<Complex<Double>>, _ lda: Int, _ B: UnsafePointer<Complex<Double>>, _ ldb: Int, _ beta: Complex<Double>, _ C: UnsafeMutablePointer<Complex<Double>>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_zhemm(order.rawValue, side.rawValue, uplo.rawValue, blasint(m), blasint(n), .init(alpha), .init(A), blasint(lda), .init(B), blasint(ldb), .init(beta), .init(C), blasint(ldc))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func chemm(_ order: Order, _ side: Side, _ uplo: UpLo, _ m: Int, _ n: Int, _ alpha: Complex<Float>, _ A: UnsafePointer<Complex<Float>>, _ lda: Int, _ B: UnsafePointer<Complex<Float>>, _ ldb: Int, _ beta: Complex<Float>, _ C: UnsafeMutablePointer<Complex<Float>>, _ ldc: Int) {
        #if canImport(COpenBLAS) || canImport(_COpenBLASWindows) || canImport(Accelerate)
        withUnsafePointer(to: alpha) { alpha in 
            withUnsafePointer(to: beta) { beta in 
                cblas_chemm(order.rawValue, side.rawValue, uplo.rawValue, blasint(m), blasint(n), .init(alpha), .init(A), blasint(lda), .init(B), blasint(ldb), .init(beta), .init(C), blasint(ldc))
            }
        }
        #else
        fatalError("Not available on this platform")
        #endif
    }

    @inlinable
    @_transparent
    static func dcopy(_ n: Int, _ x: UnsafePointer<Double>, _ incx: Int, _ y: UnsafeMutablePointer<Double>, _ incy: Int) {
        cblas_dcopy(blasint(n), x, blasint(incx), y, blasint(incy))
    }

    @inlinable
    @_transparent
    static func scopy(_ n: Int, _ x: UnsafePointer<Float>, _ incx: Int, _ y: UnsafeMutablePointer<Float>, _ incy: Int) {
        cblas_scopy(blasint(n), x, blasint(incx), y, blasint(incy))
    }

    @inlinable
    @_transparent
    static func zcopy(_ n: Int, _ x: UnsafePointer<Complex<Double>>, _ incx: Int, _ y: UnsafeMutablePointer<Complex<Double>>, _ incy: Int) {
        cblas_zcopy(blasint(n), .init(x), blasint(incx), .init(y), blasint(incy))
    }

    @inlinable
    @_transparent
    static func ccopy(_ n: Int, _ x: UnsafePointer<Complex<Float>>, _ incx: Int, _ y: UnsafeMutablePointer<Complex<Float>>, _ incy: Int) {
        cblas_ccopy(blasint(n), .init(x), blasint(incx), .init(y), blasint(incy))
    }
}