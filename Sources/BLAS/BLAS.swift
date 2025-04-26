//
//  BLAS.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 24.4.2025.
//

import _SebbuScienceCommon

#if canImport(WinSDK)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#endif

#if os(Windows) || os(Linux)
import COpenBLAS
#elseif os(macOS)
import Accelerate
#else
#warning("Unsupported platform")
#endif

#if os(Windows) || os(Linux)
        public typealias cblas_int = blasint
#elseif os(macOS)
        public typealias cblas_int = __LAPACK_int
#else
        #error("Unsupported platform")
#endif

public enum BLAS {
    public enum Order {
        public typealias RawValue = CBLAS_ORDER.RawValue
        case rowMajor
        case columnMajor
        
        public var rawValue: RawValue {
            switch self {
            case .rowMajor: CblasRowMajor.rawValue
            case .columnMajor: CblasColMajor.rawValue
            }
        }
    }

    public enum Transpose {
        public typealias RawValue = CBLAS_TRANSPOSE.RawValue
        case noTranspose
        case transpose
        case conjugateTranspose
        case conjugateNoTranspose
        
        public var rawValue: RawValue {
            switch self {
            case .noTranspose: CblasNoTrans.rawValue
            case .transpose: CblasTrans.rawValue
            case .conjugateTranspose: CblasConjTrans.rawValue
            #if canImport(COpenBLAS)
            case .conjugateNoTranspose: CblasConjNoTrans.rawValue
                #else
            case .conjugateNoTranspose: 114
                #endif
            }
        }
    }

    public enum UpperLower {
        public typealias RawValue = CBLAS_UPLO.RawValue
        case upper
        case lower
        
        public var rawValue: RawValue {
            switch self {
            case .upper: CblasUpper.rawValue
            case .lower: CblasLower.rawValue
            }
        }
    }

    public enum Diagonal {
        public typealias RawValue = CBLAS_DIAG.RawValue
        
        case nonUnit
        case unit
        
        public var rawValue: RawValue {
            switch self {
            case .nonUnit: CblasNonUnit.rawValue
            case .unit: CblasUnit.rawValue
            }
        }
    }

    public enum Side {
        public typealias RawValue = CBLAS_SIDE.RawValue
        
        case left
        case right
        
        public var rawValue: RawValue {
            switch self {
            case .left: CblasLeft.rawValue
            case .right: CblasRight.rawValue
            }
        }
    }

    public typealias Layout = Order
    
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

#if os(Windows) || os(Linux)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        loadSymbol(name:name, handle: handle)
    }
#endif
}

public extension BLAS {
    #if os(Windows) || os(Linux)
    static let sdsdot: FunctionTypes.cblas_sdsdot? = load(name: "cblas_sdsdot")
    #elseif os(macOS)
    static let sdsdot: Optional<_> = _sdsdot
    #endif
    #if os(Windows) || os(Linux)
    static let dsdot: FunctionTypes.cblas_dsdot? = load(name: "cblas_dsdot")
    #elseif os(macOS)
    static let dsdot: Optional<_> = _dsdot
    #endif
    #if os(Windows) || os(Linux)
    static let sdot: FunctionTypes.cblas_sdot? = load(name: "cblas_sdot")
    #elseif os(macOS)
    static let sdot: Optional<_> = _sdot
    #endif
    #if os(Windows) || os(Linux)
    static let ddot: FunctionTypes.cblas_ddot? = load(name: "cblas_ddot")
    #elseif os(macOS)
    static let ddot: Optional<_> = _ddot
    #endif
    #if os(Windows) || os(Linux)
    static let cdotu_sub: FunctionTypes.cblas_cdotu_sub? = load(name: "cblas_cdotu_sub")
    #elseif os(macOS)
    static let cdotu_sub: Optional<_> = _cdotu_sub
    #endif
    #if os(Windows) || os(Linux)
    static let cdotc_sub: FunctionTypes.cblas_cdotc_sub? = load(name: "cblas_cdotc_sub")
    #elseif os(macOS)
    static let cdotc_sub: Optional<_> = _cdotc_sub
    #endif
    #if os(Windows) || os(Linux)
    static let zdotu_sub: FunctionTypes.cblas_zdotu_sub? = load(name: "cblas_zdotu_sub")
    #elseif os(macOS)
    static let zdotu_sub: Optional<_> = _zdotu_sub
    #endif
    #if os(Windows) || os(Linux)
    static let zdotc_sub: FunctionTypes.cblas_zdotc_sub? = load(name: "cblas_zdotc_sub")
    #elseif os(macOS)
    static let zdotc_sub: Optional<_> = _zdotc_sub
    #endif
    #if os(Windows) || os(Linux)
    static let sasum: FunctionTypes.cblas_sasum? = load(name: "cblas_sasum")
    #elseif os(macOS)
    static let sasum: Optional<_> = _sasum
    #endif
    #if os(Windows) || os(Linux)
    static let dasum: FunctionTypes.cblas_dasum? = load(name: "cblas_dasum")
    #elseif os(macOS)
    static let dasum: Optional<_> = _dasum
    #endif
    #if os(Windows) || os(Linux)
    static let scasum: FunctionTypes.cblas_scasum? = load(name: "cblas_scasum")
    #elseif os(macOS)
    static let scasum: Optional<_> = _scasum
    #endif
    #if os(Windows) || os(Linux)
    static let dzasum: FunctionTypes.cblas_dzasum? = load(name: "cblas_dzasum")
    #elseif os(macOS)
    static let dzasum: Optional<_> = _dzasum
    #endif
    #if os(Windows) || os(Linux)
    static let ssum: FunctionTypes.cblas_ssum? = load(name: "cblas_ssum")
    #elseif os(macOS)
    static let ssum: Optional<_> = _ssum
    #endif
    #if os(Windows) || os(Linux)
    static let dsum: FunctionTypes.cblas_dsum? = load(name: "cblas_dsum")
    #elseif os(macOS)
    static let dsum: Optional<_> = _dsum
    #endif
    #if os(Windows) || os(Linux)
    static let scsum: FunctionTypes.cblas_scsum? = load(name: "cblas_scsum")
    #elseif os(macOS)
    static let scsum: Optional<_> = _scsum
    #endif
    #if os(Windows) || os(Linux)
    static let dzsum: FunctionTypes.cblas_dzsum? = load(name: "cblas_dzsum")
    #elseif os(macOS)
    static let dzsum: Optional<_> = _dzsum
    #endif
    #if os(Windows) || os(Linux)
    static let snrm2: FunctionTypes.cblas_snrm2? = load(name: "cblas_snrm2")
    #elseif os(macOS)
    static let snrm2: Optional<_> = _snrm2
    #endif
    #if os(Windows) || os(Linux)
    static let dnrm2: FunctionTypes.cblas_dnrm2? = load(name: "cblas_dnrm2")
    #elseif os(macOS)
    static let dnrm2: Optional<_> = _dnrm2
    #endif
    #if os(Windows) || os(Linux)
    static let scnrm2: FunctionTypes.cblas_scnrm2? = load(name: "cblas_scnrm2")
    #elseif os(macOS)
    static let scnrm2: Optional<_> = _scnrm2
    #endif
    #if os(Windows) || os(Linux)
    static let dznrm2: FunctionTypes.cblas_dznrm2? = load(name: "cblas_dznrm2")
    #elseif os(macOS)
    static let dznrm2: Optional<_> = _dznrm2
    #endif
    #if os(Windows) || os(Linux)
    static let isamax: FunctionTypes.cblas_isamax? = load(name: "cblas_isamax")
    #elseif os(macOS)
    static let isamax: Optional<_> = _isamax
    #endif
    #if os(Windows) || os(Linux)
    static let idamax: FunctionTypes.cblas_idamax? = load(name: "cblas_idamax")
    #elseif os(macOS)
    static let idamax: Optional<_> = _idamax
    #endif
    #if os(Windows) || os(Linux)
    static let icamax: FunctionTypes.cblas_icamax? = load(name: "cblas_icamax")
    #elseif os(macOS)
    static let icamax: Optional<_> = _icamax
    #endif
    #if os(Windows) || os(Linux)
    static let izamax: FunctionTypes.cblas_izamax? = load(name: "cblas_izamax")
    #elseif os(macOS)
    static let izamax: Optional<_> = _izamax
    #endif
    #if os(Windows) || os(Linux)
    static let isamin: FunctionTypes.cblas_isamin? = load(name: "cblas_isamin")
    #elseif os(macOS)
    static let isamin: Optional<_> = _isamin
    #endif
    #if os(Windows) || os(Linux)
    static let idamin: FunctionTypes.cblas_idamin? = load(name: "cblas_idamin")
    #elseif os(macOS)
    static let idamin: Optional<_> = _idamin
    #endif
    #if os(Windows) || os(Linux)
    static let icamin: FunctionTypes.cblas_icamin? = load(name: "cblas_icamin")
    #elseif os(macOS)
    static let icamin: Optional<_> = _icamin
    #endif
    #if os(Windows) || os(Linux)
    static let izamin: FunctionTypes.cblas_izamin? = load(name: "cblas_izamin")
    #elseif os(macOS)
    static let izamin: Optional<_> = _izamin
    #endif
    #if os(Windows) || os(Linux)
    static let samax: FunctionTypes.cblas_samax? = load(name: "cblas_samax")
    #elseif os(macOS)
    static let samax: Optional<_> = _samax
    #endif
    #if os(Windows) || os(Linux)
    static let damax: FunctionTypes.cblas_damax? = load(name: "cblas_damax")
    #elseif os(macOS)
    static let damax: Optional<_> = _damax
    #endif
    #if os(Windows) || os(Linux)
    static let scamax: FunctionTypes.cblas_scamax? = load(name: "cblas_scamax")
    #elseif os(macOS)
    static let scamax: Optional<_> = _scamax
    #endif
    #if os(Windows) || os(Linux)
    static let dzamax: FunctionTypes.cblas_dzamax? = load(name: "cblas_dzamax")
    #elseif os(macOS)
    static let dzamax: Optional<_> = _dzamax
    #endif
    #if os(Windows) || os(Linux)
    static let samin: FunctionTypes.cblas_samin? = load(name: "cblas_samin")
    #elseif os(macOS)
    static let samin: Optional<_> = _samin
    #endif
    #if os(Windows) || os(Linux)
    static let damin: FunctionTypes.cblas_damin? = load(name: "cblas_damin")
    #elseif os(macOS)
    static let damin: Optional<_> = _damin
    #endif
    #if os(Windows) || os(Linux)
    static let scamin: FunctionTypes.cblas_scamin? = load(name: "cblas_scamin")
    #elseif os(macOS)
    static let scamin: Optional<_> = _scamin
    #endif
    #if os(Windows) || os(Linux)
    static let dzamin: FunctionTypes.cblas_dzamin? = load(name: "cblas_dzamin")
    #elseif os(macOS)
    static let dzamin: Optional<_> = _dzamin
    #endif
    #if os(Windows) || os(Linux)
    static let ismax: FunctionTypes.cblas_ismax? = load(name: "cblas_ismax")
    #elseif os(macOS)
    static let ismax: Optional<_> = _ismax
    #endif
    #if os(Windows) || os(Linux)
    static let idmax: FunctionTypes.cblas_idmax? = load(name: "cblas_idmax")
    #elseif os(macOS)
    static let idmax: Optional<_> = _idmax
    #endif
    #if os(Windows) || os(Linux)
    static let icmax: FunctionTypes.cblas_icmax? = load(name: "cblas_icmax")
    #elseif os(macOS)
    static let icmax: Optional<_> = _icmax
    #endif
    #if os(Windows) || os(Linux)
    static let izmax: FunctionTypes.cblas_izmax? = load(name: "cblas_izmax")
    #elseif os(macOS)
    static let izmax: Optional<_> = _izmax
    #endif
    #if os(Windows) || os(Linux)
    static let ismin: FunctionTypes.cblas_ismin? = load(name: "cblas_ismin")
    #elseif os(macOS)
    static let ismin: Optional<_> = _ismin
    #endif
    #if os(Windows) || os(Linux)
    static let idmin: FunctionTypes.cblas_idmin? = load(name: "cblas_idmin")
    #elseif os(macOS)
    static let idmin: Optional<_> = _idmin
    #endif
    #if os(Windows) || os(Linux)
    static let icmin: FunctionTypes.cblas_icmin? = load(name: "cblas_icmin")
    #elseif os(macOS)
    static let icmin: Optional<_> = _icmin
    #endif
    #if os(Windows) || os(Linux)
    static let izmin: FunctionTypes.cblas_izmin? = load(name: "cblas_izmin")
    #elseif os(macOS)
    static let izmin: Optional<_> = _izmin
    #endif
    #if os(Windows) || os(Linux)
    static let saxpy: FunctionTypes.cblas_saxpy? = load(name: "cblas_saxpy")
    #elseif os(macOS)
    static let saxpy: Optional<_> = _saxpy
    #endif
    #if os(Windows) || os(Linux)
    static let daxpy: FunctionTypes.cblas_daxpy? = load(name: "cblas_daxpy")
    #elseif os(macOS)
    static let daxpy: Optional<_> = _daxpy
    #endif
    #if os(Windows) || os(Linux)
    static let caxpy: FunctionTypes.cblas_caxpy? = load(name: "cblas_caxpy")
    #elseif os(macOS)
    static let caxpy: Optional<_> = _caxpy
    #endif
    #if os(Windows) || os(Linux)
    static let zaxpy: FunctionTypes.cblas_zaxpy? = load(name: "cblas_zaxpy")
    #elseif os(macOS)
    static let zaxpy: Optional<_> = _zaxpy
    #endif
    #if os(Windows) || os(Linux)
    static let caxpyc: FunctionTypes.cblas_caxpyc? = load(name: "cblas_caxpyc")
    #elseif os(macOS)
    static let caxpyc: Optional<_> = _caxpyc
    #endif
    #if os(Windows) || os(Linux)
    static let zaxpyc: FunctionTypes.cblas_zaxpyc? = load(name: "cblas_zaxpyc")
    #elseif os(macOS)
    static let zaxpyc: Optional<_> = _zaxpyc
    #endif
    #if os(Windows) || os(Linux)
    static let scopy: FunctionTypes.cblas_scopy? = load(name: "cblas_scopy")
    #elseif os(macOS)
    static let scopy: Optional<_> = _scopy
    #endif
    #if os(Windows) || os(Linux)
    static let dcopy: FunctionTypes.cblas_dcopy? = load(name: "cblas_dcopy")
    #elseif os(macOS)
    static let dcopy: Optional<_> = _dcopy
    #endif
    #if os(Windows) || os(Linux)
    static let ccopy: FunctionTypes.cblas_ccopy? = load(name: "cblas_ccopy")
    #elseif os(macOS)
    static let ccopy: Optional<_> = _ccopy
    #endif
    #if os(Windows) || os(Linux)
    static let zcopy: FunctionTypes.cblas_zcopy? = load(name: "cblas_zcopy")
    #elseif os(macOS)
    static let zcopy: Optional<_> = _zcopy
    #endif
    #if os(Windows) || os(Linux)
    static let sswap: FunctionTypes.cblas_sswap? = load(name: "cblas_sswap")
    #elseif os(macOS)
    static let sswap: Optional<_> = _sswap
    #endif
    #if os(Windows) || os(Linux)
    static let dswap: FunctionTypes.cblas_dswap? = load(name: "cblas_dswap")
    #elseif os(macOS)
    static let dswap: Optional<_> = _dswap
    #endif
    #if os(Windows) || os(Linux)
    static let cswap: FunctionTypes.cblas_cswap? = load(name: "cblas_cswap")
    #elseif os(macOS)
    static let cswap: Optional<_> = _cswap
    #endif
    #if os(Windows) || os(Linux)
    static let zswap: FunctionTypes.cblas_zswap? = load(name: "cblas_zswap")
    #elseif os(macOS)
    static let zswap: Optional<_> = _zswap
    #endif
    #if os(Windows) || os(Linux)
    static let srot: FunctionTypes.cblas_srot? = load(name: "cblas_srot")
    #elseif os(macOS)
    static let srot: Optional<_> = _srot
    #endif
    #if os(Windows) || os(Linux)
    static let drot: FunctionTypes.cblas_drot? = load(name: "cblas_drot")
    #elseif os(macOS)
    static let drot: Optional<_> = _drot
    #endif
    #if os(Windows) || os(Linux)
    static let csrot: FunctionTypes.cblas_csrot? = load(name: "cblas_csrot")
    #elseif os(macOS)
    static let csrot: Optional<_> = _csrot
    #endif
    #if os(Windows) || os(Linux)
    static let zdrot: FunctionTypes.cblas_zdrot? = load(name: "cblas_zdrot")
    #elseif os(macOS)
    static let zdrot: Optional<_> = _zdrot
    #endif
    #if os(Windows) || os(Linux)
    static let srotg: FunctionTypes.cblas_srotg? = load(name: "cblas_srotg")
    #elseif os(macOS)
    static let srotg: Optional<_> = _srotg
    #endif
    #if os(Windows) || os(Linux)
    static let drotg: FunctionTypes.cblas_drotg? = load(name: "cblas_drotg")
    #elseif os(macOS)
    static let drotg: Optional<_> = _drotg
    #endif
    #if os(Windows) || os(Linux)
    static let crotg: FunctionTypes.cblas_crotg? = load(name: "cblas_crotg")
    #elseif os(macOS)
    static let crotg: Optional<_> = _crotg
    #endif
    #if os(Windows) || os(Linux)
    static let zrotg: FunctionTypes.cblas_zrotg? = load(name: "cblas_zrotg")
    #elseif os(macOS)
    static let zrotg: Optional<_> = _zrotg
    #endif
    #if os(Windows) || os(Linux)
    static let srotm: FunctionTypes.cblas_srotm? = load(name: "cblas_srotm")
    #elseif os(macOS)
    static let srotm: Optional<_> = _srotm
    #endif
    #if os(Windows) || os(Linux)
    static let drotm: FunctionTypes.cblas_drotm? = load(name: "cblas_drotm")
    #elseif os(macOS)
    static let drotm: Optional<_> = _drotm
    #endif
    #if os(Windows) || os(Linux)
    static let srotmg: FunctionTypes.cblas_srotmg? = load(name: "cblas_srotmg")
    #elseif os(macOS)
    static let srotmg: Optional<_> = _srotmg
    #endif
    #if os(Windows) || os(Linux)
    static let drotmg: FunctionTypes.cblas_drotmg? = load(name: "cblas_drotmg")
    #elseif os(macOS)
    static let drotmg: Optional<_> = _drotmg
    #endif
    #if os(Windows) || os(Linux)
    static let sscal: FunctionTypes.cblas_sscal? = load(name: "cblas_sscal")
    #elseif os(macOS)
    static let sscal: Optional<_> = _sscal
    #endif
    #if os(Windows) || os(Linux)
    static let dscal: FunctionTypes.cblas_dscal? = load(name: "cblas_dscal")
    #elseif os(macOS)
    static let dscal: Optional<_> = _dscal
    #endif
    #if os(Windows) || os(Linux)
    static let cscal: FunctionTypes.cblas_cscal? = load(name: "cblas_cscal")
    #elseif os(macOS)
    static let cscal: Optional<_> = _cscal
    #endif
    #if os(Windows) || os(Linux)
    static let zscal: FunctionTypes.cblas_zscal? = load(name: "cblas_zscal")
    #elseif os(macOS)
    static let zscal: Optional<_> = _zscal
    #endif
    #if os(Windows) || os(Linux)
    static let csscal: FunctionTypes.cblas_csscal? = load(name: "cblas_csscal")
    #elseif os(macOS)
    static let csscal: Optional<_> = _csscal
    #endif
    #if os(Windows) || os(Linux)
    static let zdscal: FunctionTypes.cblas_zdscal? = load(name: "cblas_zdscal")
    #elseif os(macOS)
    static let zdscal: Optional<_> = _zdscal
    #endif
    #if os(Windows) || os(Linux)
    static let sgemv: FunctionTypes.cblas_sgemv? = load(name: "cblas_sgemv")
    #elseif os(macOS)
    static let sgemv: Optional<_> = _sgemv
    #endif
    #if os(Windows) || os(Linux)
    static let dgemv: FunctionTypes.cblas_dgemv? = load(name: "cblas_dgemv")
    #elseif os(macOS)
    static let dgemv: Optional<_> = _dgemv
    #endif
    #if os(Windows) || os(Linux)
    static let cgemv: FunctionTypes.cblas_cgemv? = load(name: "cblas_cgemv")
    #elseif os(macOS)
    static let cgemv: Optional<_> = _cgemv
    #endif
    #if os(Windows) || os(Linux)
    static let zgemv: FunctionTypes.cblas_zgemv? = load(name: "cblas_zgemv")
    #elseif os(macOS)
    static let zgemv: Optional<_> = _zgemv
    #endif
    #if os(Windows) || os(Linux)
    static let sger: FunctionTypes.cblas_sger? = load(name: "cblas_sger")
    #elseif os(macOS)
    static let sger: Optional<_> = _sger
    #endif
    #if os(Windows) || os(Linux)
    static let dger: FunctionTypes.cblas_dger? = load(name: "cblas_dger")
    #elseif os(macOS)
    static let dger: Optional<_> = _dger
    #endif
    #if os(Windows) || os(Linux)
    static let cgeru: FunctionTypes.cblas_cgeru? = load(name: "cblas_cgeru")
    #elseif os(macOS)
    static let cgeru: Optional<_> = _cgeru
    #endif
    #if os(Windows) || os(Linux)
    static let cgerc: FunctionTypes.cblas_cgerc? = load(name: "cblas_cgerc")
    #elseif os(macOS)
    static let cgerc: Optional<_> = _cgerc
    #endif
    #if os(Windows) || os(Linux)
    static let zgeru: FunctionTypes.cblas_zgeru? = load(name: "cblas_zgeru")
    #elseif os(macOS)
    static let zgeru: Optional<_> = _zgeru
    #endif
    #if os(Windows) || os(Linux)
    static let zgerc: FunctionTypes.cblas_zgerc? = load(name: "cblas_zgerc")
    #elseif os(macOS)
    static let zgerc: Optional<_> = _zgerc
    #endif
    #if os(Windows) || os(Linux)
    static let strsv: FunctionTypes.cblas_strsv? = load(name: "cblas_strsv")
    #elseif os(macOS)
    static let strsv: Optional<_> = _strsv
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsv: FunctionTypes.cblas_dtrsv? = load(name: "cblas_dtrsv")
    #elseif os(macOS)
    static let dtrsv: Optional<_> = _dtrsv
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsv: FunctionTypes.cblas_ctrsv? = load(name: "cblas_ctrsv")
    #elseif os(macOS)
    static let ctrsv: Optional<_> = _ctrsv
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsv: FunctionTypes.cblas_ztrsv? = load(name: "cblas_ztrsv")
    #elseif os(macOS)
    static let ztrsv: Optional<_> = _ztrsv
    #endif
    #if os(Windows) || os(Linux)
    static let strmv: FunctionTypes.cblas_strmv? = load(name: "cblas_strmv")
    #elseif os(macOS)
    static let strmv: Optional<_> = _strmv
    #endif
    #if os(Windows) || os(Linux)
    static let dtrmv: FunctionTypes.cblas_dtrmv? = load(name: "cblas_dtrmv")
    #elseif os(macOS)
    static let dtrmv: Optional<_> = _dtrmv
    #endif
    #if os(Windows) || os(Linux)
    static let ctrmv: FunctionTypes.cblas_ctrmv? = load(name: "cblas_ctrmv")
    #elseif os(macOS)
    static let ctrmv: Optional<_> = _ctrmv
    #endif
    #if os(Windows) || os(Linux)
    static let ztrmv: FunctionTypes.cblas_ztrmv? = load(name: "cblas_ztrmv")
    #elseif os(macOS)
    static let ztrmv: Optional<_> = _ztrmv
    #endif
    #if os(Windows) || os(Linux)
    static let ssyr: FunctionTypes.cblas_ssyr? = load(name: "cblas_ssyr")
    #elseif os(macOS)
    static let ssyr: Optional<_> = _ssyr
    #endif
    #if os(Windows) || os(Linux)
    static let dsyr: FunctionTypes.cblas_dsyr? = load(name: "cblas_dsyr")
    #elseif os(macOS)
    static let dsyr: Optional<_> = _dsyr
    #endif
    #if os(Windows) || os(Linux)
    static let cher: FunctionTypes.cblas_cher? = load(name: "cblas_cher")
    #elseif os(macOS)
    static let cher: Optional<_> = _cher
    #endif
    #if os(Windows) || os(Linux)
    static let zher: FunctionTypes.cblas_zher? = load(name: "cblas_zher")
    #elseif os(macOS)
    static let zher: Optional<_> = _zher
    #endif
    #if os(Windows) || os(Linux)
    static let ssyr2: FunctionTypes.cblas_ssyr2? = load(name: "cblas_ssyr2")
    #elseif os(macOS)
    static let ssyr2: Optional<_> = _ssyr2
    #endif
    #if os(Windows) || os(Linux)
    static let dsyr2: FunctionTypes.cblas_dsyr2? = load(name: "cblas_dsyr2")
    #elseif os(macOS)
    static let dsyr2: Optional<_> = _dsyr2
    #endif
    #if os(Windows) || os(Linux)
    static let cher2: FunctionTypes.cblas_cher2? = load(name: "cblas_cher2")
    #elseif os(macOS)
    static let cher2: Optional<_> = _cher2
    #endif
    #if os(Windows) || os(Linux)
    static let zher2: FunctionTypes.cblas_zher2? = load(name: "cblas_zher2")
    #elseif os(macOS)
    static let zher2: Optional<_> = _zher2
    #endif
    #if os(Windows) || os(Linux)
    static let sgbmv: FunctionTypes.cblas_sgbmv? = load(name: "cblas_sgbmv")
    #elseif os(macOS)
    static let sgbmv: Optional<_> = _sgbmv
    #endif
    #if os(Windows) || os(Linux)
    static let dgbmv: FunctionTypes.cblas_dgbmv? = load(name: "cblas_dgbmv")
    #elseif os(macOS)
    static let dgbmv: Optional<_> = _dgbmv
    #endif
    #if os(Windows) || os(Linux)
    static let cgbmv: FunctionTypes.cblas_cgbmv? = load(name: "cblas_cgbmv")
    #elseif os(macOS)
    static let cgbmv: Optional<_> = _cgbmv
    #endif
    #if os(Windows) || os(Linux)
    static let zgbmv: FunctionTypes.cblas_zgbmv? = load(name: "cblas_zgbmv")
    #elseif os(macOS)
    static let zgbmv: Optional<_> = _zgbmv
    #endif
    #if os(Windows) || os(Linux)
    static let ssbmv: FunctionTypes.cblas_ssbmv? = load(name: "cblas_ssbmv")
    #elseif os(macOS)
    static let ssbmv: Optional<_> = _ssbmv
    #endif
    #if os(Windows) || os(Linux)
    static let dsbmv: FunctionTypes.cblas_dsbmv? = load(name: "cblas_dsbmv")
    #elseif os(macOS)
    static let dsbmv: Optional<_> = _dsbmv
    #endif
    #if os(Windows) || os(Linux)
    static let stbmv: FunctionTypes.cblas_stbmv? = load(name: "cblas_stbmv")
    #elseif os(macOS)
    static let stbmv: Optional<_> = _stbmv
    #endif
    #if os(Windows) || os(Linux)
    static let dtbmv: FunctionTypes.cblas_dtbmv? = load(name: "cblas_dtbmv")
    #elseif os(macOS)
    static let dtbmv: Optional<_> = _dtbmv
    #endif
    #if os(Windows) || os(Linux)
    static let ctbmv: FunctionTypes.cblas_ctbmv? = load(name: "cblas_ctbmv")
    #elseif os(macOS)
    static let ctbmv: Optional<_> = _ctbmv
    #endif
    #if os(Windows) || os(Linux)
    static let ztbmv: FunctionTypes.cblas_ztbmv? = load(name: "cblas_ztbmv")
    #elseif os(macOS)
    static let ztbmv: Optional<_> = _ztbmv
    #endif
    #if os(Windows) || os(Linux)
    static let stbsv: FunctionTypes.cblas_stbsv? = load(name: "cblas_stbsv")
    #elseif os(macOS)
    static let stbsv: Optional<_> = _stbsv
    #endif
    #if os(Windows) || os(Linux)
    static let dtbsv: FunctionTypes.cblas_dtbsv? = load(name: "cblas_dtbsv")
    #elseif os(macOS)
    static let dtbsv: Optional<_> = _dtbsv
    #endif
    #if os(Windows) || os(Linux)
    static let ctbsv: FunctionTypes.cblas_ctbsv? = load(name: "cblas_ctbsv")
    #elseif os(macOS)
    static let ctbsv: Optional<_> = _ctbsv
    #endif
    #if os(Windows) || os(Linux)
    static let ztbsv: FunctionTypes.cblas_ztbsv? = load(name: "cblas_ztbsv")
    #elseif os(macOS)
    static let ztbsv: Optional<_> = _ztbsv
    #endif
    #if os(Windows) || os(Linux)
    static let stpmv: FunctionTypes.cblas_stpmv? = load(name: "cblas_stpmv")
    #elseif os(macOS)
    static let stpmv: Optional<_> = _stpmv
    #endif
    #if os(Windows) || os(Linux)
    static let dtpmv: FunctionTypes.cblas_dtpmv? = load(name: "cblas_dtpmv")
    #elseif os(macOS)
    static let dtpmv: Optional<_> = _dtpmv
    #endif
    #if os(Windows) || os(Linux)
    static let ctpmv: FunctionTypes.cblas_ctpmv? = load(name: "cblas_ctpmv")
    #elseif os(macOS)
    static let ctpmv: Optional<_> = _ctpmv
    #endif
    #if os(Windows) || os(Linux)
    static let ztpmv: FunctionTypes.cblas_ztpmv? = load(name: "cblas_ztpmv")
    #elseif os(macOS)
    static let ztpmv: Optional<_> = _ztpmv
    #endif
    #if os(Windows) || os(Linux)
    static let stpsv: FunctionTypes.cblas_stpsv? = load(name: "cblas_stpsv")
    #elseif os(macOS)
    static let stpsv: Optional<_> = _stpsv
    #endif
    #if os(Windows) || os(Linux)
    static let dtpsv: FunctionTypes.cblas_dtpsv? = load(name: "cblas_dtpsv")
    #elseif os(macOS)
    static let dtpsv: Optional<_> = _dtpsv
    #endif
    #if os(Windows) || os(Linux)
    static let ctpsv: FunctionTypes.cblas_ctpsv? = load(name: "cblas_ctpsv")
    #elseif os(macOS)
    static let ctpsv: Optional<_> = _ctpsv
    #endif
    #if os(Windows) || os(Linux)
    static let ztpsv: FunctionTypes.cblas_ztpsv? = load(name: "cblas_ztpsv")
    #elseif os(macOS)
    static let ztpsv: Optional<_> = _ztpsv
    #endif
    #if os(Windows) || os(Linux)
    static let ssymv: FunctionTypes.cblas_ssymv? = load(name: "cblas_ssymv")
    #elseif os(macOS)
    static let ssymv: Optional<_> = _ssymv
    #endif
    #if os(Windows) || os(Linux)
    static let dsymv: FunctionTypes.cblas_dsymv? = load(name: "cblas_dsymv")
    #elseif os(macOS)
    static let dsymv: Optional<_> = _dsymv
    #endif
    #if os(Windows) || os(Linux)
    static let chemv: FunctionTypes.cblas_chemv? = load(name: "cblas_chemv")
    #elseif os(macOS)
    static let chemv: Optional<_> = _chemv
    #endif
    #if os(Windows) || os(Linux)
    static let zhemv: FunctionTypes.cblas_zhemv? = load(name: "cblas_zhemv")
    #elseif os(macOS)
    static let zhemv: Optional<_> = _zhemv
    #endif
    #if os(Windows) || os(Linux)
    static let sspmv: FunctionTypes.cblas_sspmv? = load(name: "cblas_sspmv")
    #elseif os(macOS)
    static let sspmv: Optional<_> = _sspmv
    #endif
    #if os(Windows) || os(Linux)
    static let dspmv: FunctionTypes.cblas_dspmv? = load(name: "cblas_dspmv")
    #elseif os(macOS)
    static let dspmv: Optional<_> = _dspmv
    #endif
    #if os(Windows) || os(Linux)
    static let sspr: FunctionTypes.cblas_sspr? = load(name: "cblas_sspr")
    #elseif os(macOS)
    static let sspr: Optional<_> = _sspr
    #endif
    #if os(Windows) || os(Linux)
    static let dspr: FunctionTypes.cblas_dspr? = load(name: "cblas_dspr")
    #elseif os(macOS)
    static let dspr: Optional<_> = _dspr
    #endif
    #if os(Windows) || os(Linux)
    static let chpr: FunctionTypes.cblas_chpr? = load(name: "cblas_chpr")
    #elseif os(macOS)
    static let chpr: Optional<_> = _chpr
    #endif
    #if os(Windows) || os(Linux)
    static let zhpr: FunctionTypes.cblas_zhpr? = load(name: "cblas_zhpr")
    #elseif os(macOS)
    static let zhpr: Optional<_> = _zhpr
    #endif
    #if os(Windows) || os(Linux)
    static let sspr2: FunctionTypes.cblas_sspr2? = load(name: "cblas_sspr2")
    #elseif os(macOS)
    static let sspr2: Optional<_> = _sspr2
    #endif
    #if os(Windows) || os(Linux)
    static let dspr2: FunctionTypes.cblas_dspr2? = load(name: "cblas_dspr2")
    #elseif os(macOS)
    static let dspr2: Optional<_> = _dspr2
    #endif
    #if os(Windows) || os(Linux)
    static let chpr2: FunctionTypes.cblas_chpr2? = load(name: "cblas_chpr2")
    #elseif os(macOS)
    static let chpr2: Optional<_> = _chpr2
    #endif
    #if os(Windows) || os(Linux)
    static let zhpr2: FunctionTypes.cblas_zhpr2? = load(name: "cblas_zhpr2")
    #elseif os(macOS)
    static let zhpr2: Optional<_> = _zhpr2
    #endif
    #if os(Windows) || os(Linux)
    static let chbmv: FunctionTypes.cblas_chbmv? = load(name: "cblas_chbmv")
    #elseif os(macOS)
    static let chbmv: Optional<_> = _chbmv
    #endif
    #if os(Windows) || os(Linux)
    static let zhbmv: FunctionTypes.cblas_zhbmv? = load(name: "cblas_zhbmv")
    #elseif os(macOS)
    static let zhbmv: Optional<_> = _zhbmv
    #endif
    #if os(Windows) || os(Linux)
    static let chpmv: FunctionTypes.cblas_chpmv? = load(name: "cblas_chpmv")
    #elseif os(macOS)
    static let chpmv: Optional<_> = _chpmv
    #endif
    #if os(Windows) || os(Linux)
    static let zhpmv: FunctionTypes.cblas_zhpmv? = load(name: "cblas_zhpmv")
    #elseif os(macOS)
    static let zhpmv: Optional<_> = _zhpmv
    #endif
    #if os(Windows) || os(Linux)
    static let sgemm: FunctionTypes.cblas_sgemm? = load(name: "cblas_sgemm")
    #elseif os(macOS)
    static let sgemm: Optional<_> = _sgemm
    #endif
    #if os(Windows) || os(Linux)
    static let dgemm: FunctionTypes.cblas_dgemm? = load(name: "cblas_dgemm")
    #elseif os(macOS)
    static let dgemm: Optional<_> = _dgemm
    #endif
    #if os(Windows) || os(Linux)
    static let cgemm: FunctionTypes.cblas_cgemm? = load(name: "cblas_cgemm")
    #elseif os(macOS)
    static let cgemm: Optional<_> = _cgemm
    #endif
    #if os(Windows) || os(Linux)
    static let cgemm3m: FunctionTypes.cblas_cgemm3m? = load(name: "cblas_cgemm3m")
    #elseif os(macOS)
    static let cgemm3m: Optional<_> = _cgemm3m
    #endif
    #if os(Windows) || os(Linux)
    static let zgemm: FunctionTypes.cblas_zgemm? = load(name: "cblas_zgemm")
    #elseif os(macOS)
    static let zgemm: Optional<_> = _zgemm
    #endif
    #if os(Windows) || os(Linux)
    static let zgemm3m: FunctionTypes.cblas_zgemm3m? = load(name: "cblas_zgemm3m")
    #elseif os(macOS)
    static let zgemm3m: Optional<_> = _zgemm3m
    #endif
    #if os(Windows) || os(Linux)
    static let sgemmt: FunctionTypes.cblas_sgemmt? = load(name: "cblas_sgemmt")
    #elseif os(macOS)
    static let sgemmt: Optional<_> = _sgemmt
    #endif
    #if os(Windows) || os(Linux)
    static let dgemmt: FunctionTypes.cblas_dgemmt? = load(name: "cblas_dgemmt")
    #elseif os(macOS)
    static let dgemmt: Optional<_> = _dgemmt
    #endif
    #if os(Windows) || os(Linux)
    static let cgemmt: FunctionTypes.cblas_cgemmt? = load(name: "cblas_cgemmt")
    #elseif os(macOS)
    static let cgemmt: Optional<_> = _cgemmt
    #endif
    #if os(Windows) || os(Linux)
    static let zgemmt: FunctionTypes.cblas_zgemmt? = load(name: "cblas_zgemmt")
    #elseif os(macOS)
    static let zgemmt: Optional<_> = _zgemmt
    #endif
    #if os(Windows) || os(Linux)
    static let ssymm: FunctionTypes.cblas_ssymm? = load(name: "cblas_ssymm")
    #elseif os(macOS)
    static let ssymm: Optional<_> = _ssymm
    #endif
    #if os(Windows) || os(Linux)
    static let dsymm: FunctionTypes.cblas_dsymm? = load(name: "cblas_dsymm")
    #elseif os(macOS)
    static let dsymm: Optional<_> = _dsymm
    #endif
    #if os(Windows) || os(Linux)
    static let csymm: FunctionTypes.cblas_csymm? = load(name: "cblas_csymm")
    #elseif os(macOS)
    static let csymm: Optional<_> = _csymm
    #endif
    #if os(Windows) || os(Linux)
    static let zsymm: FunctionTypes.cblas_zsymm? = load(name: "cblas_zsymm")
    #elseif os(macOS)
    static let zsymm: Optional<_> = _zsymm
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrk: FunctionTypes.cblas_ssyrk? = load(name: "cblas_ssyrk")
    #elseif os(macOS)
    static let ssyrk: Optional<_> = _ssyrk
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrk: FunctionTypes.cblas_dsyrk? = load(name: "cblas_dsyrk")
    #elseif os(macOS)
    static let dsyrk: Optional<_> = _dsyrk
    #endif
    #if os(Windows) || os(Linux)
    static let csyrk: FunctionTypes.cblas_csyrk? = load(name: "cblas_csyrk")
    #elseif os(macOS)
    static let csyrk: Optional<_> = _csyrk
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrk: FunctionTypes.cblas_zsyrk? = load(name: "cblas_zsyrk")
    #elseif os(macOS)
    static let zsyrk: Optional<_> = _zsyrk
    #endif
    #if os(Windows) || os(Linux)
    static let ssyr2k: FunctionTypes.cblas_ssyr2k? = load(name: "cblas_ssyr2k")
    #elseif os(macOS)
    static let ssyr2k: Optional<_> = _ssyr2k
    #endif
    #if os(Windows) || os(Linux)
    static let dsyr2k: FunctionTypes.cblas_dsyr2k? = load(name: "cblas_dsyr2k")
    #elseif os(macOS)
    static let dsyr2k: Optional<_> = _dsyr2k
    #endif
    #if os(Windows) || os(Linux)
    static let csyr2k: FunctionTypes.cblas_csyr2k? = load(name: "cblas_csyr2k")
    #elseif os(macOS)
    static let csyr2k: Optional<_> = _csyr2k
    #endif
    #if os(Windows) || os(Linux)
    static let zsyr2k: FunctionTypes.cblas_zsyr2k? = load(name: "cblas_zsyr2k")
    #elseif os(macOS)
    static let zsyr2k: Optional<_> = _zsyr2k
    #endif
    #if os(Windows) || os(Linux)
    static let strmm: FunctionTypes.cblas_strmm? = load(name: "cblas_strmm")
    #elseif os(macOS)
    static let strmm: Optional<_> = _strmm
    #endif
    #if os(Windows) || os(Linux)
    static let dtrmm: FunctionTypes.cblas_dtrmm? = load(name: "cblas_dtrmm")
    #elseif os(macOS)
    static let dtrmm: Optional<_> = _dtrmm
    #endif
    #if os(Windows) || os(Linux)
    static let ctrmm: FunctionTypes.cblas_ctrmm? = load(name: "cblas_ctrmm")
    #elseif os(macOS)
    static let ctrmm: Optional<_> = _ctrmm
    #endif
    #if os(Windows) || os(Linux)
    static let ztrmm: FunctionTypes.cblas_ztrmm? = load(name: "cblas_ztrmm")
    #elseif os(macOS)
    static let ztrmm: Optional<_> = _ztrmm
    #endif
    #if os(Windows) || os(Linux)
    static let strsm: FunctionTypes.cblas_strsm? = load(name: "cblas_strsm")
    #elseif os(macOS)
    static let strsm: Optional<_> = _strsm
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsm: FunctionTypes.cblas_dtrsm? = load(name: "cblas_dtrsm")
    #elseif os(macOS)
    static let dtrsm: Optional<_> = _dtrsm
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsm: FunctionTypes.cblas_ctrsm? = load(name: "cblas_ctrsm")
    #elseif os(macOS)
    static let ctrsm: Optional<_> = _ctrsm
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsm: FunctionTypes.cblas_ztrsm? = load(name: "cblas_ztrsm")
    #elseif os(macOS)
    static let ztrsm: Optional<_> = _ztrsm
    #endif
    #if os(Windows) || os(Linux)
    static let chemm: FunctionTypes.cblas_chemm? = load(name: "cblas_chemm")
    #elseif os(macOS)
    static let chemm: Optional<_> = _chemm
    #endif
    #if os(Windows) || os(Linux)
    static let zhemm: FunctionTypes.cblas_zhemm? = load(name: "cblas_zhemm")
    #elseif os(macOS)
    static let zhemm: Optional<_> = _zhemm
    #endif
    #if os(Windows) || os(Linux)
    static let cherk: FunctionTypes.cblas_cherk? = load(name: "cblas_cherk")
    #elseif os(macOS)
    static let cherk: Optional<_> = _cherk
    #endif
    #if os(Windows) || os(Linux)
    static let zherk: FunctionTypes.cblas_zherk? = load(name: "cblas_zherk")
    #elseif os(macOS)
    static let zherk: Optional<_> = _zherk
    #endif
    #if os(Windows) || os(Linux)
    static let cher2k: FunctionTypes.cblas_cher2k? = load(name: "cblas_cher2k")
    #elseif os(macOS)
    static let cher2k: Optional<_> = _cher2k
    #endif
    #if os(Windows) || os(Linux)
    static let zher2k: FunctionTypes.cblas_zher2k? = load(name: "cblas_zher2k")
    #elseif os(macOS)
    static let zher2k: Optional<_> = _zher2k
    #endif
}
