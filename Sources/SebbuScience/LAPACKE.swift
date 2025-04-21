#if canImport(CLAPACK)
import CLAPACK
#endif

#if canImport(WinSDK)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#endif

@usableFromInline
internal enum LAPACKE {
    #if os(Linux)
    @usableFromInline
    internal nonisolated(unsafe) static let handle: UnsafeMutableRawPointer? = {
        if let handle = loadLibrary(name: "liblapacke.so") {
            return handle
        }
        let firstErrorMessage = getDLErrorMessage()
        if let handle = BLAS.handle {
            return handle
        }
        let secondErrorMessage = getDLErrorMessage()
        print("Failed to load liblapacke.so: \(firstErrorMessage)")
        print("Failed to load libopenblas.so: \(secondErrorMessage)")
        return nil
    }()
    #endif

    #if os(Windows)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        BLAS.load(name: name)
    }
    #elseif os(Linux)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        if let lapackeSymbol = loadSymbol(name: name, handle: handle, as: type) {
            return lapackeSymbol
        }
        if let openBlasSymbol = BLAS.load(name: name, as: type) {
            return openBlasSymbol
        }
        return nil
    }
    #endif
    
    #if os(Windows) || os(Linux)
    // Float functions
    @usableFromInline
    static let ssyevd: LAPACKE_SSYEVD? = load(name: "LAPACKE_ssyevd")
    @usableFromInline
    static let sgeev: LAPACKE_SGEEV? = load(name: "LAPACKE_sgeev")
    @usableFromInline
    static let sgesv: LAPACKE_SGESV? = load(name: "LAPACKE_sgesv")

    // Double functions
    @usableFromInline
    static let dsyevd: LAPACKE_DSYEVD? = load(name: "LAPACKE_dsyevd")
    @usableFromInline
    static let dgeev: LAPACKE_DGEEV? = load(name: "LAPACKE_dgeev")
    @usableFromInline
    static let dgesv: LAPACKE_DGESV? = load(name: "LAPACKE_dgesv")

    // Single precision complex functions
    @usableFromInline
    static let cheevd: LAPACKE_CHEEVD? = load(name: "LAPACKE_cheevd")
    @usableFromInline
    static let cgeev: LAPACKE_CGEEV? = load(name: "LAPACKE_cgeev")
    @usableFromInline
    static let cgesv: LAPACKE_CGESV? = load(name: "LAPACKE_cgesv")

    // Double precision complex functions
    @usableFromInline
    static let zheevd: LAPACKE_ZHEEVD? = load(name: "LAPACKE_zheevd")
    @usableFromInline
    static let zgeev: LAPACKE_ZGEEV? = load(name: "LAPACKE_zgeev")
    @usableFromInline
    static let zgesv: LAPACKE_ZGESV? = load(name: "LAPACKE_zgesv")
    #endif
}

///MARK: Typealiases
extension LAPACKE {
    //TODO: sgetri, sgetrf
    //TODO: dgetri, dgetrf
    //TODO: cgetri, cgetrf
    //TODO: zgetri, zgetrf
    #if os(Windows) || os(Linux)
    // Float functions
    @usableFromInline
    typealias LAPACKE_SSYEVD = @convention(c) (_ matrix_layout: Int32, _ jobz: CChar, _ uplo: CChar,
                                               _ n: Int32, _ a: UnsafeMutablePointer<Float>?, 
                                               _ lda: Int32, _ w: UnsafeMutablePointer<Float>?) -> Int32

    @usableFromInline
    typealias LAPACKE_SGEEV = @convention(c) (_ matrix_layout: Int32, _ jobvl: CChar, _ jobvr: CChar, 
                                              _ n: Int32, _ a: UnsafeMutablePointer<Float>?, _ lda: Int32, 
                                              _ wr: UnsafeMutablePointer<Float>?, _ wi: UnsafeMutablePointer<Float>?, 
                                              _ vl: UnsafeMutablePointer<Float>?, _ ldvl: Int32, 
                                              _ vr: UnsafeMutablePointer<Float>?, _ ldvr: Int32) -> Int32

    @usableFromInline
    typealias LAPACKE_SGESV = @convention(c) (_ matrix_layout: Int32, _ n: Int32, _ nrhs: Int32, 
                                              _ a: UnsafeMutablePointer<Float>?, _ lda: Int32, _ ipiv: UnsafeMutablePointer<Int32>?, 
                                              _ b: UnsafeMutablePointer<Float>?, _ ldb: Int32) -> Int32

    // Double functions
    @usableFromInline
    typealias LAPACKE_DSYEVD = @convention(c) (_ matrix_layout: Int32, _ jobz: CChar, _ uplo: CChar,
                                               _ n: Int32, _ a: UnsafeMutablePointer<Double>?, 
                                               _ lda: Int32, _ w: UnsafeMutablePointer<Double>?) -> Int32

    @usableFromInline
    typealias LAPACKE_DGEEV = @convention(c) (_ matrix_layout: Int32, _ jobvl: CChar, _ jobvr: CChar, 
                                              _ n: Int32, _ a: UnsafeMutablePointer<Double>?, _ lda: Int32, 
                                              _ wr: UnsafeMutablePointer<Double>?, _ wi: UnsafeMutablePointer<Double>?, 
                                              _ vl: UnsafeMutablePointer<Double>?, _ ldvl: Int32, 
                                              _ vr: UnsafeMutablePointer<Double>?, _ ldvr: Int32) -> Int32

    @usableFromInline
    typealias LAPACKE_DGESV = @convention(c) (_ matrix_layout: Int32, _ n: Int32, _ nrhs: Int32, 
                                              _ a: UnsafeMutablePointer<Double>?, _ lda: Int32, _ ipiv: UnsafeMutablePointer<Int32>?, 
                                              _ b: UnsafeMutablePointer<Double>?, _ ldb: Int32) -> Int32

    // Single precision complex functions
    @usableFromInline
    typealias LAPACKE_CHEEVD = @convention(c) (_ matrix_layout: Int32, _ jobz: CChar, _ uplo: CChar, 
                                               _ n: Int32, _ a: UnsafeMutableRawPointer?, 
                                               _ lda: Int32, _ w: UnsafeMutablePointer<Float>?) -> Int32

    @usableFromInline
    typealias LAPACKE_CGEEV = @convention(c) (_ matrix_layout: Int32, _ jobvl: CChar, _ jobvr: CChar, 
                                              _ n: Int32, _ a: UnsafeMutableRawPointer?, _ lda: Int32, 
                                              _ w: UnsafeMutableRawPointer?, _ vl: UnsafeMutableRawPointer?, 
                                              _ ldvl: Int32, _ vr: UnsafeMutableRawPointer?, _ ldvr: Int32) -> Int32

    @usableFromInline
    typealias LAPACKE_CGESV = @convention(c) (_ matrix_layout: Int32, _ n: Int32, _ nrhs: Int32, 
                                              _ a: UnsafeMutableRawPointer?, _ lda: Int32, _ ipiv: UnsafeMutablePointer<Int32>?,
                                               _ b: UnsafeMutableRawPointer?, _ ldb: Int32) -> Int32

    // Double precision complex functions
    @usableFromInline
    typealias LAPACKE_ZHEEVD = @convention(c) (_ matrix_layout: Int32, _ jobz: CChar, _ uplo: CChar, 
                                               _ n: Int32, _ a: UnsafeMutableRawPointer?, 
                                               _ lda: Int32, _ w: UnsafeMutablePointer<Double>?) -> Int32

    @usableFromInline
    typealias LAPACKE_ZGEEV = @convention(c) (_ matrix_layout: Int32, _ jobvl: CChar, _ jobvr: CChar, 
                                              _ n: Int32, _ a: UnsafeMutableRawPointer?, _ lda: Int32, 
                                              _ w: UnsafeMutableRawPointer?, _ vl: UnsafeMutableRawPointer?, 
                                              _ ldvl: Int32, _ vr: UnsafeMutableRawPointer?, _ ldvr: Int32) -> Int32

    @usableFromInline
    typealias LAPACKE_ZGESV = @convention(c) (_ matrix_layout: Int32, _ n: Int32, _ nrhs: Int32, 
                                              _ a: UnsafeMutableRawPointer?, _ lda: Int32, _ ipiv: UnsafeMutablePointer<Int32>?,
                                               _ b: UnsafeMutableRawPointer?, _ ldb: Int32) -> Int32

// WITH COMPLEX<> DEFINITIONS
//    // Single precision complex functions
//    @usableFromInline
//    typealias LAPACKE_CHEEVD = @convention(c) (_ matrix_layout: Int32, _ jobz: CChar, _ uplo: CChar, 
//                                               _ n: Int32, _ a: UnsafeMutablePointer<Complex<Float>>?, 
//                                               _ lda: Int32, _ w: UnsafeMutablePointer<Float>?) -> Int32
//
//    @usableFromInline
//    typealias LAPACKE_CGEEV = @convention(c) (_ matrix_layout: Int32, _ jobvl: CChar, _ jobvr: CChar, 
//                                              _ n: Int32, _ a: UnsafeMutablePointer<Complex<Float>>?, _ lda: Int32, 
//                                              _ w: UnsafeMutablePointer<Complex<Float>>?, _ vl: UnsafeMutablePointer<Complex<Float>>?, 
//                                              _ ldvl: Int32, _ vr: UnsafeMutablePointer<Complex<Float>>?, _ ldvr: Int32) -> Int32
//
//    @usableFromInline
//    typealias LAPACKE_CGESV = @convention(c) (_ matrix_layout: Int32, _ n: Int32, _ nrhs: Int32, 
//                                              _ a: UnsafeMutablePointer<Complex<Float>>?, _ lda: Int32, _ ipiv: UnsafeMutablePointer<Int32>?,
//                                               _ b: UnsafeMutablePointer<Complex<Float>>?, _ ldb: Int32) -> Int32
//
//    // Double precision complex functions
//    @usableFromInline
//    typealias LAPACKE_ZHEEVD = @convention(c) (_ matrix_layout: Int32, _ jobz: CChar, _ uplo: CChar, 
//                                               _ n: Int32, _ a: UnsafeMutablePointer<Complex<Double>>?, 
//                                               _ lda: Int32, _ w: UnsafeMutablePointer<Double>?) -> Int32
//
//    @usableFromInline
//    typealias LAPACKE_ZGEEV = @convention(c) (_ matrix_layout: Int32, _ jobvl: CChar, _ jobvr: CChar, 
//                                              _ n: Int32, _ a: UnsafeMutablePointer<Complex<Double>>?, _ lda: Int32, 
//                                              _ w: UnsafeMutablePointer<Complex<Double>>?, _ vl: UnsafeMutablePointer<Complex<Double>>?, 
//                                              _ ldvl: Int32, _ vr: UnsafeMutablePointer<Complex<Double>>?, _ ldvr: Int32) -> Int32
//
//    @usableFromInline
//    typealias LAPACKE_ZGESV = @convention(c) (_ matrix_layout: Int32, _ n: Int32, _ nrhs: Int32, 
//                                              _ a: UnsafeMutablePointer<Complex<Double>>?, _ lda: Int32, _ ipiv: UnsafeMutablePointer<Int32>?,
//                                               _ b: UnsafeMutablePointer<Complex<Double>>?, _ ldb: Int32) -> Int32
    #endif
}
