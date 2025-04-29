//
//  LAPACKE.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 24.4.2025.
//

#if canImport(CLAPACK)
import CLAPACK
#elseif canImport(Accelerate)
import Accelerate
#endif

import _SebbuScienceCommon

#if canImport(WinSDK)
import WinSDK
#elseif canImport(Glibc)
import Glibc
#endif

#if os(Windows) || os(Linux)
public typealias lapack_int = Int32
public typealias LAPACK_S_SELECT2 = (UnsafePointer<Float>?, UnsafePointer<Float>?) -> lapack_int
public typealias LAPACK_S_SELECT3 = (UnsafePointer<Float>?, UnsafePointer<Float>?, UnsafePointer<Float>?) -> lapack_int
public typealias LAPACK_D_SELECT2 = (UnsafePointer<Double>?, UnsafePointer<Double>?) -> lapack_int
public typealias LAPACK_D_SELECT3 = (UnsafePointer<Double>?, UnsafePointer<Double>?, UnsafePointer<Double>?) -> lapack_int
public typealias LAPACK_C_SELECT1 = (UnsafeRawPointer?) -> lapack_int
public typealias LAPACK_C_SELECT2 = (UnsafeRawPointer?, UnsafeRawPointer?) -> lapack_int
public typealias LAPACK_Z_SELECT1 = (UnsafeRawPointer?) -> lapack_int
public typealias LAPACK_Z_SELECT2 = (UnsafeRawPointer?, UnsafeRawPointer?) -> lapack_int
#elseif os(macOS)
public typealias lapack_int = __LAPACK_int
public typealias LAPACK_S_SELECT2 = (UnsafePointer<Float>?, UnsafePointer<Float>?) -> lapack_int
public typealias LAPACK_S_SELECT3 = (UnsafePointer<Float>?, UnsafePointer<Float>?) -> lapack_int
public typealias LAPACK_D_SELECT2 = (UnsafePointer<Double>?, UnsafePointer<Double>?) -> lapack_int
public typealias LAPACK_D_SELECT3 = (UnsafePointer<Double>?, UnsafePointer<Double>?, UnsafePointer<Double>?) -> lapack_int
public typealias LAPACK_C_SELECT1 = (UnsafeRawPointer?) -> lapack_int
public typealias LAPACK_C_SELECT2 = (UnsafeRawPointer?, UnsafeRawPointer?) -> lapack_int
public typealias LAPACK_Z_SELECT1 = (UnsafeRawPointer?) -> lapack_int
public typealias LAPACK_Z_SELECT2 = (UnsafeRawPointer?, UnsafeRawPointer?) -> lapack_int
#endif

public extension LAPACKE {
    enum MatrixLayout {
        case rowMajor
        case columnMajor
        
        public var rawValue: CInt {
            switch self {
                #if os(Windows) || os(Linux)
            case .rowMajor: return LAPACK_ROW_MAJOR
            case .columnMajor: return LAPACK_COL_MAJOR
                #elseif os(macOS)
            case .rowMajor: return 101
            case .columnMajor: return 102
                #else
            default:
                fatalError("Unsupported platform")
                #endif
            }
            
            
        }
    }
}

public enum LAPACKE {
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
    internal nonisolated(unsafe) static let blasHandle: UnsafeMutableRawPointer? = {
        if let handle = loadLibrary(name: "libopenblas.so") {
            return handle
        }
        let dlErrorMessage = getDLErrorMessage()
        print("Failed to load libopenblas.so: \(dlErrorMessage)")
        return nil
    }()

    @usableFromInline
    internal nonisolated(unsafe) static let lapackeHandle: UnsafeMutableRawPointer? = {
        if let handle = loadLibrary(name: "liblapacke.so") {
            return handle
        }
        let dlErrorMessage = getDLErrorMessage()
        print("Failed to load liblapacke.so: \(dlErrorMessage)")
        return nil
    }()
#endif

#if os(Windows)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        loadSymbol(name: name, handle: handle)
    }
#elseif os(Linux)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        if let symbol = loadSymbol(name:name, handle: blasHandle, as: type) { return symbol }
        if let symbol = loadSymbol(name: name, handle: lapackeHandle, as: type) { return symbol }
        return nil
    }
#endif
}

public extension LAPACKE {
    #if os(Windows) || os(Linux)
    static let sbdsdc: FunctionTypes.LAPACKE_sbdsdc? = load(name: "LAPACKE_sbdsdc")
    #elseif os(macOS)
    static let sbdsdc: FunctionTypes.LAPACKE_sbdsdc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsdc: FunctionTypes.LAPACKE_dbdsdc? = load(name: "LAPACKE_dbdsdc")
    #elseif os(macOS)
    static let dbdsdc: FunctionTypes.LAPACKE_dbdsdc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsqr: FunctionTypes.LAPACKE_sbdsqr? = load(name: "LAPACKE_sbdsqr")
    #elseif os(macOS)
    static let sbdsqr: FunctionTypes.LAPACKE_sbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsqr: FunctionTypes.LAPACKE_dbdsqr? = load(name: "LAPACKE_dbdsqr")
    #elseif os(macOS)
    static let dbdsqr: FunctionTypes.LAPACKE_dbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbdsqr: FunctionTypes.LAPACKE_cbdsqr? = load(name: "LAPACKE_cbdsqr")
    #elseif os(macOS)
    static let cbdsqr: FunctionTypes.LAPACKE_cbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbdsqr: FunctionTypes.LAPACKE_zbdsqr? = load(name: "LAPACKE_zbdsqr")
    #elseif os(macOS)
    static let zbdsqr: FunctionTypes.LAPACKE_zbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsvdx: FunctionTypes.LAPACKE_sbdsvdx? = load(name: "LAPACKE_sbdsvdx")
    #elseif os(macOS)
    static let sbdsvdx: FunctionTypes.LAPACKE_sbdsvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsvdx: FunctionTypes.LAPACKE_dbdsvdx? = load(name: "LAPACKE_dbdsvdx")
    #elseif os(macOS)
    static let dbdsvdx: FunctionTypes.LAPACKE_dbdsvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sdisna: FunctionTypes.LAPACKE_sdisna? = load(name: "LAPACKE_sdisna")
    #elseif os(macOS)
    static let sdisna: FunctionTypes.LAPACKE_sdisna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ddisna: FunctionTypes.LAPACKE_ddisna? = load(name: "LAPACKE_ddisna")
    #elseif os(macOS)
    static let ddisna: FunctionTypes.LAPACKE_ddisna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbbrd: FunctionTypes.LAPACKE_sgbbrd? = load(name: "LAPACKE_sgbbrd")
    #elseif os(macOS)
    static let sgbbrd: FunctionTypes.LAPACKE_sgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbbrd: FunctionTypes.LAPACKE_dgbbrd? = load(name: "LAPACKE_dgbbrd")
    #elseif os(macOS)
    static let dgbbrd: FunctionTypes.LAPACKE_dgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbbrd: FunctionTypes.LAPACKE_cgbbrd? = load(name: "LAPACKE_cgbbrd")
    #elseif os(macOS)
    static let cgbbrd: FunctionTypes.LAPACKE_cgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbbrd: FunctionTypes.LAPACKE_zgbbrd? = load(name: "LAPACKE_zgbbrd")
    #elseif os(macOS)
    static let zgbbrd: FunctionTypes.LAPACKE_zgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbcon: FunctionTypes.LAPACKE_sgbcon? = load(name: "LAPACKE_sgbcon")
    #elseif os(macOS)
    static let sgbcon: FunctionTypes.LAPACKE_sgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbcon: FunctionTypes.LAPACKE_dgbcon? = load(name: "LAPACKE_dgbcon")
    #elseif os(macOS)
    static let dgbcon: FunctionTypes.LAPACKE_dgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbcon: FunctionTypes.LAPACKE_cgbcon? = load(name: "LAPACKE_cgbcon")
    #elseif os(macOS)
    static let cgbcon: FunctionTypes.LAPACKE_cgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbcon: FunctionTypes.LAPACKE_zgbcon? = load(name: "LAPACKE_zgbcon")
    #elseif os(macOS)
    static let zgbcon: FunctionTypes.LAPACKE_zgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequ: FunctionTypes.LAPACKE_sgbequ? = load(name: "LAPACKE_sgbequ")
    #elseif os(macOS)
    static let sgbequ: FunctionTypes.LAPACKE_sgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequ: FunctionTypes.LAPACKE_dgbequ? = load(name: "LAPACKE_dgbequ")
    #elseif os(macOS)
    static let dgbequ: FunctionTypes.LAPACKE_dgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequ: FunctionTypes.LAPACKE_cgbequ? = load(name: "LAPACKE_cgbequ")
    #elseif os(macOS)
    static let cgbequ: FunctionTypes.LAPACKE_cgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequ: FunctionTypes.LAPACKE_zgbequ? = load(name: "LAPACKE_zgbequ")
    #elseif os(macOS)
    static let zgbequ: FunctionTypes.LAPACKE_zgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequb: FunctionTypes.LAPACKE_sgbequb? = load(name: "LAPACKE_sgbequb")
    #elseif os(macOS)
    static let sgbequb: FunctionTypes.LAPACKE_sgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequb: FunctionTypes.LAPACKE_dgbequb? = load(name: "LAPACKE_dgbequb")
    #elseif os(macOS)
    static let dgbequb: FunctionTypes.LAPACKE_dgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequb: FunctionTypes.LAPACKE_cgbequb? = load(name: "LAPACKE_cgbequb")
    #elseif os(macOS)
    static let cgbequb: FunctionTypes.LAPACKE_cgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequb: FunctionTypes.LAPACKE_zgbequb? = load(name: "LAPACKE_zgbequb")
    #elseif os(macOS)
    static let zgbequb: FunctionTypes.LAPACKE_zgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfs: FunctionTypes.LAPACKE_sgbrfs? = load(name: "LAPACKE_sgbrfs")
    #elseif os(macOS)
    static let sgbrfs: FunctionTypes.LAPACKE_sgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfs: FunctionTypes.LAPACKE_dgbrfs? = load(name: "LAPACKE_dgbrfs")
    #elseif os(macOS)
    static let dgbrfs: FunctionTypes.LAPACKE_dgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfs: FunctionTypes.LAPACKE_cgbrfs? = load(name: "LAPACKE_cgbrfs")
    #elseif os(macOS)
    static let cgbrfs: FunctionTypes.LAPACKE_cgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfs: FunctionTypes.LAPACKE_zgbrfs? = load(name: "LAPACKE_zgbrfs")
    #elseif os(macOS)
    static let zgbrfs: FunctionTypes.LAPACKE_zgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfsx: FunctionTypes.LAPACKE_sgbrfsx? = load(name: "LAPACKE_sgbrfsx")
    #elseif os(macOS)
    static let sgbrfsx: FunctionTypes.LAPACKE_sgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfsx: FunctionTypes.LAPACKE_dgbrfsx? = load(name: "LAPACKE_dgbrfsx")
    #elseif os(macOS)
    static let dgbrfsx: FunctionTypes.LAPACKE_dgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfsx: FunctionTypes.LAPACKE_cgbrfsx? = load(name: "LAPACKE_cgbrfsx")
    #elseif os(macOS)
    static let cgbrfsx: FunctionTypes.LAPACKE_cgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfsx: FunctionTypes.LAPACKE_zgbrfsx? = load(name: "LAPACKE_zgbrfsx")
    #elseif os(macOS)
    static let zgbrfsx: FunctionTypes.LAPACKE_zgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsv: FunctionTypes.LAPACKE_sgbsv? = load(name: "LAPACKE_sgbsv")
    #elseif os(macOS)
    static let sgbsv: FunctionTypes.LAPACKE_sgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsv: FunctionTypes.LAPACKE_dgbsv? = load(name: "LAPACKE_dgbsv")
    #elseif os(macOS)
    static let dgbsv: FunctionTypes.LAPACKE_dgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsv: FunctionTypes.LAPACKE_cgbsv? = load(name: "LAPACKE_cgbsv")
    #elseif os(macOS)
    static let cgbsv: FunctionTypes.LAPACKE_cgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsv: FunctionTypes.LAPACKE_zgbsv? = load(name: "LAPACKE_zgbsv")
    #elseif os(macOS)
    static let zgbsv: FunctionTypes.LAPACKE_zgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvx: FunctionTypes.LAPACKE_sgbsvx? = load(name: "LAPACKE_sgbsvx")
    #elseif os(macOS)
    static let sgbsvx: FunctionTypes.LAPACKE_sgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvx: FunctionTypes.LAPACKE_dgbsvx? = load(name: "LAPACKE_dgbsvx")
    #elseif os(macOS)
    static let dgbsvx: FunctionTypes.LAPACKE_dgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvx: FunctionTypes.LAPACKE_cgbsvx? = load(name: "LAPACKE_cgbsvx")
    #elseif os(macOS)
    static let cgbsvx: FunctionTypes.LAPACKE_cgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvx: FunctionTypes.LAPACKE_zgbsvx? = load(name: "LAPACKE_zgbsvx")
    #elseif os(macOS)
    static let zgbsvx: FunctionTypes.LAPACKE_zgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvxx: FunctionTypes.LAPACKE_sgbsvxx? = load(name: "LAPACKE_sgbsvxx")
    #elseif os(macOS)
    static let sgbsvxx: FunctionTypes.LAPACKE_sgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvxx: FunctionTypes.LAPACKE_dgbsvxx? = load(name: "LAPACKE_dgbsvxx")
    #elseif os(macOS)
    static let dgbsvxx: FunctionTypes.LAPACKE_dgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvxx: FunctionTypes.LAPACKE_cgbsvxx? = load(name: "LAPACKE_cgbsvxx")
    #elseif os(macOS)
    static let cgbsvxx: FunctionTypes.LAPACKE_cgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvxx: FunctionTypes.LAPACKE_zgbsvxx? = load(name: "LAPACKE_zgbsvxx")
    #elseif os(macOS)
    static let zgbsvxx: FunctionTypes.LAPACKE_zgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrf: FunctionTypes.LAPACKE_sgbtrf? = load(name: "LAPACKE_sgbtrf")
    #elseif os(macOS)
    static let sgbtrf: FunctionTypes.LAPACKE_sgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrf: FunctionTypes.LAPACKE_dgbtrf? = load(name: "LAPACKE_dgbtrf")
    #elseif os(macOS)
    static let dgbtrf: FunctionTypes.LAPACKE_dgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrf: FunctionTypes.LAPACKE_cgbtrf? = load(name: "LAPACKE_cgbtrf")
    #elseif os(macOS)
    static let cgbtrf: FunctionTypes.LAPACKE_cgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrf: FunctionTypes.LAPACKE_zgbtrf? = load(name: "LAPACKE_zgbtrf")
    #elseif os(macOS)
    static let zgbtrf: FunctionTypes.LAPACKE_zgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrs: FunctionTypes.LAPACKE_sgbtrs? = load(name: "LAPACKE_sgbtrs")
    #elseif os(macOS)
    static let sgbtrs: FunctionTypes.LAPACKE_sgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrs: FunctionTypes.LAPACKE_dgbtrs? = load(name: "LAPACKE_dgbtrs")
    #elseif os(macOS)
    static let dgbtrs: FunctionTypes.LAPACKE_dgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrs: FunctionTypes.LAPACKE_cgbtrs? = load(name: "LAPACKE_cgbtrs")
    #elseif os(macOS)
    static let cgbtrs: FunctionTypes.LAPACKE_cgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrs: FunctionTypes.LAPACKE_zgbtrs? = load(name: "LAPACKE_zgbtrs")
    #elseif os(macOS)
    static let zgbtrs: FunctionTypes.LAPACKE_zgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebak: FunctionTypes.LAPACKE_sgebak? = load(name: "LAPACKE_sgebak")
    #elseif os(macOS)
    static let sgebak: FunctionTypes.LAPACKE_sgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebak: FunctionTypes.LAPACKE_dgebak? = load(name: "LAPACKE_dgebak")
    #elseif os(macOS)
    static let dgebak: FunctionTypes.LAPACKE_dgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebak: FunctionTypes.LAPACKE_cgebak? = load(name: "LAPACKE_cgebak")
    #elseif os(macOS)
    static let cgebak: FunctionTypes.LAPACKE_cgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebak: FunctionTypes.LAPACKE_zgebak? = load(name: "LAPACKE_zgebak")
    #elseif os(macOS)
    static let zgebak: FunctionTypes.LAPACKE_zgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebal: FunctionTypes.LAPACKE_sgebal? = load(name: "LAPACKE_sgebal")
    #elseif os(macOS)
    static let sgebal: FunctionTypes.LAPACKE_sgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebal: FunctionTypes.LAPACKE_dgebal? = load(name: "LAPACKE_dgebal")
    #elseif os(macOS)
    static let dgebal: FunctionTypes.LAPACKE_dgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebal: FunctionTypes.LAPACKE_cgebal? = load(name: "LAPACKE_cgebal")
    #elseif os(macOS)
    static let cgebal: FunctionTypes.LAPACKE_cgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebal: FunctionTypes.LAPACKE_zgebal? = load(name: "LAPACKE_zgebal")
    #elseif os(macOS)
    static let zgebal: FunctionTypes.LAPACKE_zgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebrd: FunctionTypes.LAPACKE_sgebrd? = load(name: "LAPACKE_sgebrd")
    #elseif os(macOS)
    static let sgebrd: FunctionTypes.LAPACKE_sgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebrd: FunctionTypes.LAPACKE_dgebrd? = load(name: "LAPACKE_dgebrd")
    #elseif os(macOS)
    static let dgebrd: FunctionTypes.LAPACKE_dgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebrd: FunctionTypes.LAPACKE_cgebrd? = load(name: "LAPACKE_cgebrd")
    #elseif os(macOS)
    static let cgebrd: FunctionTypes.LAPACKE_cgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebrd: FunctionTypes.LAPACKE_zgebrd? = load(name: "LAPACKE_zgebrd")
    #elseif os(macOS)
    static let zgebrd: FunctionTypes.LAPACKE_zgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgecon: FunctionTypes.LAPACKE_sgecon? = load(name: "LAPACKE_sgecon")
    #elseif os(macOS)
    static let sgecon: FunctionTypes.LAPACKE_sgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgecon: FunctionTypes.LAPACKE_dgecon? = load(name: "LAPACKE_dgecon")
    #elseif os(macOS)
    static let dgecon: FunctionTypes.LAPACKE_dgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgecon: FunctionTypes.LAPACKE_cgecon? = load(name: "LAPACKE_cgecon")
    #elseif os(macOS)
    static let cgecon: FunctionTypes.LAPACKE_cgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgecon: FunctionTypes.LAPACKE_zgecon? = load(name: "LAPACKE_zgecon")
    #elseif os(macOS)
    static let zgecon: FunctionTypes.LAPACKE_zgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequ: FunctionTypes.LAPACKE_sgeequ? = load(name: "LAPACKE_sgeequ")
    #elseif os(macOS)
    static let sgeequ: FunctionTypes.LAPACKE_sgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequ: FunctionTypes.LAPACKE_dgeequ? = load(name: "LAPACKE_dgeequ")
    #elseif os(macOS)
    static let dgeequ: FunctionTypes.LAPACKE_dgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequ: FunctionTypes.LAPACKE_cgeequ? = load(name: "LAPACKE_cgeequ")
    #elseif os(macOS)
    static let cgeequ: FunctionTypes.LAPACKE_cgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequ: FunctionTypes.LAPACKE_zgeequ? = load(name: "LAPACKE_zgeequ")
    #elseif os(macOS)
    static let zgeequ: FunctionTypes.LAPACKE_zgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequb: FunctionTypes.LAPACKE_sgeequb? = load(name: "LAPACKE_sgeequb")
    #elseif os(macOS)
    static let sgeequb: FunctionTypes.LAPACKE_sgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequb: FunctionTypes.LAPACKE_dgeequb? = load(name: "LAPACKE_dgeequb")
    #elseif os(macOS)
    static let dgeequb: FunctionTypes.LAPACKE_dgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequb: FunctionTypes.LAPACKE_cgeequb? = load(name: "LAPACKE_cgeequb")
    #elseif os(macOS)
    static let cgeequb: FunctionTypes.LAPACKE_cgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequb: FunctionTypes.LAPACKE_zgeequb? = load(name: "LAPACKE_zgeequb")
    #elseif os(macOS)
    static let zgeequb: FunctionTypes.LAPACKE_zgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgees: FunctionTypes.LAPACKE_sgees? = load(name: "LAPACKE_sgees")
    #elseif os(macOS)
    static let sgees: FunctionTypes.LAPACKE_sgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgees: FunctionTypes.LAPACKE_dgees? = load(name: "LAPACKE_dgees")
    #elseif os(macOS)
    static let dgees: FunctionTypes.LAPACKE_dgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgees: FunctionTypes.LAPACKE_cgees? = load(name: "LAPACKE_cgees")
    #elseif os(macOS)
    static let cgees: FunctionTypes.LAPACKE_cgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgees: FunctionTypes.LAPACKE_zgees? = load(name: "LAPACKE_zgees")
    #elseif os(macOS)
    static let zgees: FunctionTypes.LAPACKE_zgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeesx: FunctionTypes.LAPACKE_sgeesx? = load(name: "LAPACKE_sgeesx")
    #elseif os(macOS)
    static let sgeesx: FunctionTypes.LAPACKE_sgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeesx: FunctionTypes.LAPACKE_dgeesx? = load(name: "LAPACKE_dgeesx")
    #elseif os(macOS)
    static let dgeesx: FunctionTypes.LAPACKE_dgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeesx: FunctionTypes.LAPACKE_cgeesx? = load(name: "LAPACKE_cgeesx")
    #elseif os(macOS)
    static let cgeesx: FunctionTypes.LAPACKE_cgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeesx: FunctionTypes.LAPACKE_zgeesx? = load(name: "LAPACKE_zgeesx")
    #elseif os(macOS)
    static let zgeesx: FunctionTypes.LAPACKE_zgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeev: FunctionTypes.LAPACKE_sgeev? = load(name: "LAPACKE_sgeev")
    #elseif os(macOS)
    static let sgeev: FunctionTypes.LAPACKE_sgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeev: FunctionTypes.LAPACKE_dgeev? = load(name: "LAPACKE_dgeev")
    #elseif os(macOS)
    static let dgeev: FunctionTypes.LAPACKE_dgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeev: FunctionTypes.LAPACKE_cgeev? = load(name: "LAPACKE_cgeev")
    #elseif os(macOS)
    static let cgeev: FunctionTypes.LAPACKE_cgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeev: FunctionTypes.LAPACKE_zgeev? = load(name: "LAPACKE_zgeev")
    #elseif os(macOS)
    static let zgeev: FunctionTypes.LAPACKE_zgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeevx: FunctionTypes.LAPACKE_sgeevx? = load(name: "LAPACKE_sgeevx")
    #elseif os(macOS)
    static let sgeevx: FunctionTypes.LAPACKE_sgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeevx: FunctionTypes.LAPACKE_dgeevx? = load(name: "LAPACKE_dgeevx")
    #elseif os(macOS)
    static let dgeevx: FunctionTypes.LAPACKE_dgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeevx: FunctionTypes.LAPACKE_cgeevx? = load(name: "LAPACKE_cgeevx")
    #elseif os(macOS)
    static let cgeevx: FunctionTypes.LAPACKE_cgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeevx: FunctionTypes.LAPACKE_zgeevx? = load(name: "LAPACKE_zgeevx")
    #elseif os(macOS)
    static let zgeevx: FunctionTypes.LAPACKE_zgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgehrd: FunctionTypes.LAPACKE_sgehrd? = load(name: "LAPACKE_sgehrd")
    #elseif os(macOS)
    static let sgehrd: FunctionTypes.LAPACKE_sgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgehrd: FunctionTypes.LAPACKE_dgehrd? = load(name: "LAPACKE_dgehrd")
    #elseif os(macOS)
    static let dgehrd: FunctionTypes.LAPACKE_dgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgehrd: FunctionTypes.LAPACKE_cgehrd? = load(name: "LAPACKE_cgehrd")
    #elseif os(macOS)
    static let cgehrd: FunctionTypes.LAPACKE_cgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgehrd: FunctionTypes.LAPACKE_zgehrd? = load(name: "LAPACKE_zgehrd")
    #elseif os(macOS)
    static let zgehrd: FunctionTypes.LAPACKE_zgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgejsv: FunctionTypes.LAPACKE_sgejsv? = load(name: "LAPACKE_sgejsv")
    #elseif os(macOS)
    static let sgejsv: FunctionTypes.LAPACKE_sgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgejsv: FunctionTypes.LAPACKE_dgejsv? = load(name: "LAPACKE_dgejsv")
    #elseif os(macOS)
    static let dgejsv: FunctionTypes.LAPACKE_dgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgejsv: FunctionTypes.LAPACKE_cgejsv? = load(name: "LAPACKE_cgejsv")
    #elseif os(macOS)
    static let cgejsv: FunctionTypes.LAPACKE_cgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgejsv: FunctionTypes.LAPACKE_zgejsv? = load(name: "LAPACKE_zgejsv")
    #elseif os(macOS)
    static let zgejsv: FunctionTypes.LAPACKE_zgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq2: FunctionTypes.LAPACKE_sgelq2? = load(name: "LAPACKE_sgelq2")
    #elseif os(macOS)
    static let sgelq2: FunctionTypes.LAPACKE_sgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq2: FunctionTypes.LAPACKE_dgelq2? = load(name: "LAPACKE_dgelq2")
    #elseif os(macOS)
    static let dgelq2: FunctionTypes.LAPACKE_dgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq2: FunctionTypes.LAPACKE_cgelq2? = load(name: "LAPACKE_cgelq2")
    #elseif os(macOS)
    static let cgelq2: FunctionTypes.LAPACKE_cgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq2: FunctionTypes.LAPACKE_zgelq2? = load(name: "LAPACKE_zgelq2")
    #elseif os(macOS)
    static let zgelq2: FunctionTypes.LAPACKE_zgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelqf: FunctionTypes.LAPACKE_sgelqf? = load(name: "LAPACKE_sgelqf")
    #elseif os(macOS)
    static let sgelqf: FunctionTypes.LAPACKE_sgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelqf: FunctionTypes.LAPACKE_dgelqf? = load(name: "LAPACKE_dgelqf")
    #elseif os(macOS)
    static let dgelqf: FunctionTypes.LAPACKE_dgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelqf: FunctionTypes.LAPACKE_cgelqf? = load(name: "LAPACKE_cgelqf")
    #elseif os(macOS)
    static let cgelqf: FunctionTypes.LAPACKE_cgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelqf: FunctionTypes.LAPACKE_zgelqf? = load(name: "LAPACKE_zgelqf")
    #elseif os(macOS)
    static let zgelqf: FunctionTypes.LAPACKE_zgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgels: FunctionTypes.LAPACKE_sgels? = load(name: "LAPACKE_sgels")
    #elseif os(macOS)
    static let sgels: FunctionTypes.LAPACKE_sgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgels: FunctionTypes.LAPACKE_dgels? = load(name: "LAPACKE_dgels")
    #elseif os(macOS)
    static let dgels: FunctionTypes.LAPACKE_dgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgels: FunctionTypes.LAPACKE_cgels? = load(name: "LAPACKE_cgels")
    #elseif os(macOS)
    static let cgels: FunctionTypes.LAPACKE_cgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgels: FunctionTypes.LAPACKE_zgels? = load(name: "LAPACKE_zgels")
    #elseif os(macOS)
    static let zgels: FunctionTypes.LAPACKE_zgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsd: FunctionTypes.LAPACKE_sgelsd? = load(name: "LAPACKE_sgelsd")
    #elseif os(macOS)
    static let sgelsd: FunctionTypes.LAPACKE_sgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsd: FunctionTypes.LAPACKE_dgelsd? = load(name: "LAPACKE_dgelsd")
    #elseif os(macOS)
    static let dgelsd: FunctionTypes.LAPACKE_dgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsd: FunctionTypes.LAPACKE_cgelsd? = load(name: "LAPACKE_cgelsd")
    #elseif os(macOS)
    static let cgelsd: FunctionTypes.LAPACKE_cgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsd: FunctionTypes.LAPACKE_zgelsd? = load(name: "LAPACKE_zgelsd")
    #elseif os(macOS)
    static let zgelsd: FunctionTypes.LAPACKE_zgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelss: FunctionTypes.LAPACKE_sgelss? = load(name: "LAPACKE_sgelss")
    #elseif os(macOS)
    static let sgelss: FunctionTypes.LAPACKE_sgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelss: FunctionTypes.LAPACKE_dgelss? = load(name: "LAPACKE_dgelss")
    #elseif os(macOS)
    static let dgelss: FunctionTypes.LAPACKE_dgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelss: FunctionTypes.LAPACKE_cgelss? = load(name: "LAPACKE_cgelss")
    #elseif os(macOS)
    static let cgelss: FunctionTypes.LAPACKE_cgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelss: FunctionTypes.LAPACKE_zgelss? = load(name: "LAPACKE_zgelss")
    #elseif os(macOS)
    static let zgelss: FunctionTypes.LAPACKE_zgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsy: FunctionTypes.LAPACKE_sgelsy? = load(name: "LAPACKE_sgelsy")
    #elseif os(macOS)
    static let sgelsy: FunctionTypes.LAPACKE_sgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsy: FunctionTypes.LAPACKE_dgelsy? = load(name: "LAPACKE_dgelsy")
    #elseif os(macOS)
    static let dgelsy: FunctionTypes.LAPACKE_dgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsy: FunctionTypes.LAPACKE_cgelsy? = load(name: "LAPACKE_cgelsy")
    #elseif os(macOS)
    static let cgelsy: FunctionTypes.LAPACKE_cgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsy: FunctionTypes.LAPACKE_zgelsy? = load(name: "LAPACKE_zgelsy")
    #elseif os(macOS)
    static let zgelsy: FunctionTypes.LAPACKE_zgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqlf: FunctionTypes.LAPACKE_sgeqlf? = load(name: "LAPACKE_sgeqlf")
    #elseif os(macOS)
    static let sgeqlf: FunctionTypes.LAPACKE_sgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqlf: FunctionTypes.LAPACKE_dgeqlf? = load(name: "LAPACKE_dgeqlf")
    #elseif os(macOS)
    static let dgeqlf: FunctionTypes.LAPACKE_dgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqlf: FunctionTypes.LAPACKE_cgeqlf? = load(name: "LAPACKE_cgeqlf")
    #elseif os(macOS)
    static let cgeqlf: FunctionTypes.LAPACKE_cgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqlf: FunctionTypes.LAPACKE_zgeqlf? = load(name: "LAPACKE_zgeqlf")
    #elseif os(macOS)
    static let zgeqlf: FunctionTypes.LAPACKE_zgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqp3: FunctionTypes.LAPACKE_sgeqp3? = load(name: "LAPACKE_sgeqp3")
    #elseif os(macOS)
    static let sgeqp3: FunctionTypes.LAPACKE_sgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqp3: FunctionTypes.LAPACKE_dgeqp3? = load(name: "LAPACKE_dgeqp3")
    #elseif os(macOS)
    static let dgeqp3: FunctionTypes.LAPACKE_dgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqp3: FunctionTypes.LAPACKE_cgeqp3? = load(name: "LAPACKE_cgeqp3")
    #elseif os(macOS)
    static let cgeqp3: FunctionTypes.LAPACKE_cgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqp3: FunctionTypes.LAPACKE_zgeqp3? = load(name: "LAPACKE_zgeqp3")
    #elseif os(macOS)
    static let zgeqp3: FunctionTypes.LAPACKE_zgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqpf: FunctionTypes.LAPACKE_sgeqpf? = load(name: "LAPACKE_sgeqpf")
    #elseif os(macOS)
    static let sgeqpf: FunctionTypes.LAPACKE_sgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqpf: FunctionTypes.LAPACKE_dgeqpf? = load(name: "LAPACKE_dgeqpf")
    #elseif os(macOS)
    static let dgeqpf: FunctionTypes.LAPACKE_dgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqpf: FunctionTypes.LAPACKE_cgeqpf? = load(name: "LAPACKE_cgeqpf")
    #elseif os(macOS)
    static let cgeqpf: FunctionTypes.LAPACKE_cgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqpf: FunctionTypes.LAPACKE_zgeqpf? = load(name: "LAPACKE_zgeqpf")
    #elseif os(macOS)
    static let zgeqpf: FunctionTypes.LAPACKE_zgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr2: FunctionTypes.LAPACKE_sgeqr2? = load(name: "LAPACKE_sgeqr2")
    #elseif os(macOS)
    static let sgeqr2: FunctionTypes.LAPACKE_sgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr2: FunctionTypes.LAPACKE_dgeqr2? = load(name: "LAPACKE_dgeqr2")
    #elseif os(macOS)
    static let dgeqr2: FunctionTypes.LAPACKE_dgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr2: FunctionTypes.LAPACKE_cgeqr2? = load(name: "LAPACKE_cgeqr2")
    #elseif os(macOS)
    static let cgeqr2: FunctionTypes.LAPACKE_cgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr2: FunctionTypes.LAPACKE_zgeqr2? = load(name: "LAPACKE_zgeqr2")
    #elseif os(macOS)
    static let zgeqr2: FunctionTypes.LAPACKE_zgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrf: FunctionTypes.LAPACKE_sgeqrf? = load(name: "LAPACKE_sgeqrf")
    #elseif os(macOS)
    static let sgeqrf: FunctionTypes.LAPACKE_sgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrf: FunctionTypes.LAPACKE_dgeqrf? = load(name: "LAPACKE_dgeqrf")
    #elseif os(macOS)
    static let dgeqrf: FunctionTypes.LAPACKE_dgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrf: FunctionTypes.LAPACKE_cgeqrf? = load(name: "LAPACKE_cgeqrf")
    #elseif os(macOS)
    static let cgeqrf: FunctionTypes.LAPACKE_cgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrf: FunctionTypes.LAPACKE_zgeqrf? = load(name: "LAPACKE_zgeqrf")
    #elseif os(macOS)
    static let zgeqrf: FunctionTypes.LAPACKE_zgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrfp: FunctionTypes.LAPACKE_sgeqrfp? = load(name: "LAPACKE_sgeqrfp")
    #elseif os(macOS)
    static let sgeqrfp: FunctionTypes.LAPACKE_sgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrfp: FunctionTypes.LAPACKE_dgeqrfp? = load(name: "LAPACKE_dgeqrfp")
    #elseif os(macOS)
    static let dgeqrfp: FunctionTypes.LAPACKE_dgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrfp: FunctionTypes.LAPACKE_cgeqrfp? = load(name: "LAPACKE_cgeqrfp")
    #elseif os(macOS)
    static let cgeqrfp: FunctionTypes.LAPACKE_cgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrfp: FunctionTypes.LAPACKE_zgeqrfp? = load(name: "LAPACKE_zgeqrfp")
    #elseif os(macOS)
    static let zgeqrfp: FunctionTypes.LAPACKE_zgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfs: FunctionTypes.LAPACKE_sgerfs? = load(name: "LAPACKE_sgerfs")
    #elseif os(macOS)
    static let sgerfs: FunctionTypes.LAPACKE_sgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfs: FunctionTypes.LAPACKE_dgerfs? = load(name: "LAPACKE_dgerfs")
    #elseif os(macOS)
    static let dgerfs: FunctionTypes.LAPACKE_dgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfs: FunctionTypes.LAPACKE_cgerfs? = load(name: "LAPACKE_cgerfs")
    #elseif os(macOS)
    static let cgerfs: FunctionTypes.LAPACKE_cgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfs: FunctionTypes.LAPACKE_zgerfs? = load(name: "LAPACKE_zgerfs")
    #elseif os(macOS)
    static let zgerfs: FunctionTypes.LAPACKE_zgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfsx: FunctionTypes.LAPACKE_sgerfsx? = load(name: "LAPACKE_sgerfsx")
    #elseif os(macOS)
    static let sgerfsx: FunctionTypes.LAPACKE_sgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfsx: FunctionTypes.LAPACKE_dgerfsx? = load(name: "LAPACKE_dgerfsx")
    #elseif os(macOS)
    static let dgerfsx: FunctionTypes.LAPACKE_dgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfsx: FunctionTypes.LAPACKE_cgerfsx? = load(name: "LAPACKE_cgerfsx")
    #elseif os(macOS)
    static let cgerfsx: FunctionTypes.LAPACKE_cgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfsx: FunctionTypes.LAPACKE_zgerfsx? = load(name: "LAPACKE_zgerfsx")
    #elseif os(macOS)
    static let zgerfsx: FunctionTypes.LAPACKE_zgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerqf: FunctionTypes.LAPACKE_sgerqf? = load(name: "LAPACKE_sgerqf")
    #elseif os(macOS)
    static let sgerqf: FunctionTypes.LAPACKE_sgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerqf: FunctionTypes.LAPACKE_dgerqf? = load(name: "LAPACKE_dgerqf")
    #elseif os(macOS)
    static let dgerqf: FunctionTypes.LAPACKE_dgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerqf: FunctionTypes.LAPACKE_cgerqf? = load(name: "LAPACKE_cgerqf")
    #elseif os(macOS)
    static let cgerqf: FunctionTypes.LAPACKE_cgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerqf: FunctionTypes.LAPACKE_zgerqf? = load(name: "LAPACKE_zgerqf")
    #elseif os(macOS)
    static let zgerqf: FunctionTypes.LAPACKE_zgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesdd: FunctionTypes.LAPACKE_sgesdd? = load(name: "LAPACKE_sgesdd")
    #elseif os(macOS)
    static let sgesdd: FunctionTypes.LAPACKE_sgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesdd: FunctionTypes.LAPACKE_dgesdd? = load(name: "LAPACKE_dgesdd")
    #elseif os(macOS)
    static let dgesdd: FunctionTypes.LAPACKE_dgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesdd: FunctionTypes.LAPACKE_cgesdd? = load(name: "LAPACKE_cgesdd")
    #elseif os(macOS)
    static let cgesdd: FunctionTypes.LAPACKE_cgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesdd: FunctionTypes.LAPACKE_zgesdd? = load(name: "LAPACKE_zgesdd")
    #elseif os(macOS)
    static let zgesdd: FunctionTypes.LAPACKE_zgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesv: FunctionTypes.LAPACKE_sgesv? = load(name: "LAPACKE_sgesv")
    #elseif os(macOS)
    static let sgesv: FunctionTypes.LAPACKE_sgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesv: FunctionTypes.LAPACKE_dgesv? = load(name: "LAPACKE_dgesv")
    #elseif os(macOS)
    static let dgesv: FunctionTypes.LAPACKE_dgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesv: FunctionTypes.LAPACKE_cgesv? = load(name: "LAPACKE_cgesv")
    #elseif os(macOS)
    static let cgesv: FunctionTypes.LAPACKE_cgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesv: FunctionTypes.LAPACKE_zgesv? = load(name: "LAPACKE_zgesv")
    #elseif os(macOS)
    static let zgesv: FunctionTypes.LAPACKE_zgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsgesv: FunctionTypes.LAPACKE_dsgesv? = load(name: "LAPACKE_dsgesv")
    #elseif os(macOS)
    static let dsgesv: FunctionTypes.LAPACKE_dsgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcgesv: FunctionTypes.LAPACKE_zcgesv? = load(name: "LAPACKE_zcgesv")
    #elseif os(macOS)
    static let zcgesv: FunctionTypes.LAPACKE_zcgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvd: FunctionTypes.LAPACKE_sgesvd? = load(name: "LAPACKE_sgesvd")
    #elseif os(macOS)
    static let sgesvd: FunctionTypes.LAPACKE_sgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvd: FunctionTypes.LAPACKE_dgesvd? = load(name: "LAPACKE_dgesvd")
    #elseif os(macOS)
    static let dgesvd: FunctionTypes.LAPACKE_dgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvd: FunctionTypes.LAPACKE_cgesvd? = load(name: "LAPACKE_cgesvd")
    #elseif os(macOS)
    static let cgesvd: FunctionTypes.LAPACKE_cgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvd: FunctionTypes.LAPACKE_zgesvd? = load(name: "LAPACKE_zgesvd")
    #elseif os(macOS)
    static let zgesvd: FunctionTypes.LAPACKE_zgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdx: FunctionTypes.LAPACKE_sgesvdx? = load(name: "LAPACKE_sgesvdx")
    #elseif os(macOS)
    static let sgesvdx: FunctionTypes.LAPACKE_sgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdx: FunctionTypes.LAPACKE_dgesvdx? = load(name: "LAPACKE_dgesvdx")
    #elseif os(macOS)
    static let dgesvdx: FunctionTypes.LAPACKE_dgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdx: FunctionTypes.LAPACKE_cgesvdx? = load(name: "LAPACKE_cgesvdx")
    #elseif os(macOS)
    static let cgesvdx: FunctionTypes.LAPACKE_cgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdx: FunctionTypes.LAPACKE_zgesvdx? = load(name: "LAPACKE_zgesvdx")
    #elseif os(macOS)
    static let zgesvdx: FunctionTypes.LAPACKE_zgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdq: FunctionTypes.LAPACKE_sgesvdq? = load(name: "LAPACKE_sgesvdq")
    #elseif os(macOS)
    static let sgesvdq: FunctionTypes.LAPACKE_sgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdq: FunctionTypes.LAPACKE_dgesvdq? = load(name: "LAPACKE_dgesvdq")
    #elseif os(macOS)
    static let dgesvdq: FunctionTypes.LAPACKE_dgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdq: FunctionTypes.LAPACKE_cgesvdq? = load(name: "LAPACKE_cgesvdq")
    #elseif os(macOS)
    static let cgesvdq: FunctionTypes.LAPACKE_cgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdq: FunctionTypes.LAPACKE_zgesvdq? = load(name: "LAPACKE_zgesvdq")
    #elseif os(macOS)
    static let zgesvdq: FunctionTypes.LAPACKE_zgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvj: FunctionTypes.LAPACKE_sgesvj? = load(name: "LAPACKE_sgesvj")
    #elseif os(macOS)
    static let sgesvj: FunctionTypes.LAPACKE_sgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvj: FunctionTypes.LAPACKE_dgesvj? = load(name: "LAPACKE_dgesvj")
    #elseif os(macOS)
    static let dgesvj: FunctionTypes.LAPACKE_dgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvj: FunctionTypes.LAPACKE_cgesvj? = load(name: "LAPACKE_cgesvj")
    #elseif os(macOS)
    static let cgesvj: FunctionTypes.LAPACKE_cgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvj: FunctionTypes.LAPACKE_zgesvj? = load(name: "LAPACKE_zgesvj")
    #elseif os(macOS)
    static let zgesvj: FunctionTypes.LAPACKE_zgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvx: FunctionTypes.LAPACKE_sgesvx? = load(name: "LAPACKE_sgesvx")
    #elseif os(macOS)
    static let sgesvx: FunctionTypes.LAPACKE_sgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvx: FunctionTypes.LAPACKE_dgesvx? = load(name: "LAPACKE_dgesvx")
    #elseif os(macOS)
    static let dgesvx: FunctionTypes.LAPACKE_dgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvx: FunctionTypes.LAPACKE_cgesvx? = load(name: "LAPACKE_cgesvx")
    #elseif os(macOS)
    static let cgesvx: FunctionTypes.LAPACKE_cgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvx: FunctionTypes.LAPACKE_zgesvx? = load(name: "LAPACKE_zgesvx")
    #elseif os(macOS)
    static let zgesvx: FunctionTypes.LAPACKE_zgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvxx: FunctionTypes.LAPACKE_sgesvxx? = load(name: "LAPACKE_sgesvxx")
    #elseif os(macOS)
    static let sgesvxx: FunctionTypes.LAPACKE_sgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvxx: FunctionTypes.LAPACKE_dgesvxx? = load(name: "LAPACKE_dgesvxx")
    #elseif os(macOS)
    static let dgesvxx: FunctionTypes.LAPACKE_dgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvxx: FunctionTypes.LAPACKE_cgesvxx? = load(name: "LAPACKE_cgesvxx")
    #elseif os(macOS)
    static let cgesvxx: FunctionTypes.LAPACKE_cgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvxx: FunctionTypes.LAPACKE_zgesvxx? = load(name: "LAPACKE_zgesvxx")
    #elseif os(macOS)
    static let zgesvxx: FunctionTypes.LAPACKE_zgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetf2: FunctionTypes.LAPACKE_sgetf2? = load(name: "LAPACKE_sgetf2")
    #elseif os(macOS)
    static let sgetf2: FunctionTypes.LAPACKE_sgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetf2: FunctionTypes.LAPACKE_dgetf2? = load(name: "LAPACKE_dgetf2")
    #elseif os(macOS)
    static let dgetf2: FunctionTypes.LAPACKE_dgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetf2: FunctionTypes.LAPACKE_cgetf2? = load(name: "LAPACKE_cgetf2")
    #elseif os(macOS)
    static let cgetf2: FunctionTypes.LAPACKE_cgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetf2: FunctionTypes.LAPACKE_zgetf2? = load(name: "LAPACKE_zgetf2")
    #elseif os(macOS)
    static let zgetf2: FunctionTypes.LAPACKE_zgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf: FunctionTypes.LAPACKE_sgetrf? = load(name: "LAPACKE_sgetrf")
    #elseif os(macOS)
    static let sgetrf: FunctionTypes.LAPACKE_sgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf: FunctionTypes.LAPACKE_dgetrf? = load(name: "LAPACKE_dgetrf")
    #elseif os(macOS)
    static let dgetrf: FunctionTypes.LAPACKE_dgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf: FunctionTypes.LAPACKE_cgetrf? = load(name: "LAPACKE_cgetrf")
    #elseif os(macOS)
    static let cgetrf: FunctionTypes.LAPACKE_cgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf: FunctionTypes.LAPACKE_zgetrf? = load(name: "LAPACKE_zgetrf")
    #elseif os(macOS)
    static let zgetrf: FunctionTypes.LAPACKE_zgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf2: FunctionTypes.LAPACKE_sgetrf2? = load(name: "LAPACKE_sgetrf2")
    #elseif os(macOS)
    static let sgetrf2: FunctionTypes.LAPACKE_sgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf2: FunctionTypes.LAPACKE_dgetrf2? = load(name: "LAPACKE_dgetrf2")
    #elseif os(macOS)
    static let dgetrf2: FunctionTypes.LAPACKE_dgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf2: FunctionTypes.LAPACKE_cgetrf2? = load(name: "LAPACKE_cgetrf2")
    #elseif os(macOS)
    static let cgetrf2: FunctionTypes.LAPACKE_cgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf2: FunctionTypes.LAPACKE_zgetrf2? = load(name: "LAPACKE_zgetrf2")
    #elseif os(macOS)
    static let zgetrf2: FunctionTypes.LAPACKE_zgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetri: FunctionTypes.LAPACKE_sgetri? = load(name: "LAPACKE_sgetri")
    #elseif os(macOS)
    static let sgetri: FunctionTypes.LAPACKE_sgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetri: FunctionTypes.LAPACKE_dgetri? = load(name: "LAPACKE_dgetri")
    #elseif os(macOS)
    static let dgetri: FunctionTypes.LAPACKE_dgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetri: FunctionTypes.LAPACKE_cgetri? = load(name: "LAPACKE_cgetri")
    #elseif os(macOS)
    static let cgetri: FunctionTypes.LAPACKE_cgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetri: FunctionTypes.LAPACKE_zgetri? = load(name: "LAPACKE_zgetri")
    #elseif os(macOS)
    static let zgetri: FunctionTypes.LAPACKE_zgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrs: FunctionTypes.LAPACKE_sgetrs? = load(name: "LAPACKE_sgetrs")
    #elseif os(macOS)
    static let sgetrs: FunctionTypes.LAPACKE_sgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrs: FunctionTypes.LAPACKE_dgetrs? = load(name: "LAPACKE_dgetrs")
    #elseif os(macOS)
    static let dgetrs: FunctionTypes.LAPACKE_dgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrs: FunctionTypes.LAPACKE_cgetrs? = load(name: "LAPACKE_cgetrs")
    #elseif os(macOS)
    static let cgetrs: FunctionTypes.LAPACKE_cgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrs: FunctionTypes.LAPACKE_zgetrs? = load(name: "LAPACKE_zgetrs")
    #elseif os(macOS)
    static let zgetrs: FunctionTypes.LAPACKE_zgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbak: FunctionTypes.LAPACKE_sggbak? = load(name: "LAPACKE_sggbak")
    #elseif os(macOS)
    static let sggbak: FunctionTypes.LAPACKE_sggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbak: FunctionTypes.LAPACKE_dggbak? = load(name: "LAPACKE_dggbak")
    #elseif os(macOS)
    static let dggbak: FunctionTypes.LAPACKE_dggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbak: FunctionTypes.LAPACKE_cggbak? = load(name: "LAPACKE_cggbak")
    #elseif os(macOS)
    static let cggbak: FunctionTypes.LAPACKE_cggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbak: FunctionTypes.LAPACKE_zggbak? = load(name: "LAPACKE_zggbak")
    #elseif os(macOS)
    static let zggbak: FunctionTypes.LAPACKE_zggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbal: FunctionTypes.LAPACKE_sggbal? = load(name: "LAPACKE_sggbal")
    #elseif os(macOS)
    static let sggbal: FunctionTypes.LAPACKE_sggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbal: FunctionTypes.LAPACKE_dggbal? = load(name: "LAPACKE_dggbal")
    #elseif os(macOS)
    static let dggbal: FunctionTypes.LAPACKE_dggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbal: FunctionTypes.LAPACKE_cggbal? = load(name: "LAPACKE_cggbal")
    #elseif os(macOS)
    static let cggbal: FunctionTypes.LAPACKE_cggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbal: FunctionTypes.LAPACKE_zggbal? = load(name: "LAPACKE_zggbal")
    #elseif os(macOS)
    static let zggbal: FunctionTypes.LAPACKE_zggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges: FunctionTypes.LAPACKE_sgges? = load(name: "LAPACKE_sgges")
    #elseif os(macOS)
    static let sgges: FunctionTypes.LAPACKE_sgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges: FunctionTypes.LAPACKE_dgges? = load(name: "LAPACKE_dgges")
    #elseif os(macOS)
    static let dgges: FunctionTypes.LAPACKE_dgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges: FunctionTypes.LAPACKE_cgges? = load(name: "LAPACKE_cgges")
    #elseif os(macOS)
    static let cgges: FunctionTypes.LAPACKE_cgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges: FunctionTypes.LAPACKE_zgges? = load(name: "LAPACKE_zgges")
    #elseif os(macOS)
    static let zgges: FunctionTypes.LAPACKE_zgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges3: FunctionTypes.LAPACKE_sgges3? = load(name: "LAPACKE_sgges3")
    #elseif os(macOS)
    static let sgges3: FunctionTypes.LAPACKE_sgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges3: FunctionTypes.LAPACKE_dgges3? = load(name: "LAPACKE_dgges3")
    #elseif os(macOS)
    static let dgges3: FunctionTypes.LAPACKE_dgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges3: FunctionTypes.LAPACKE_cgges3? = load(name: "LAPACKE_cgges3")
    #elseif os(macOS)
    static let cgges3: FunctionTypes.LAPACKE_cgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges3: FunctionTypes.LAPACKE_zgges3? = load(name: "LAPACKE_zgges3")
    #elseif os(macOS)
    static let zgges3: FunctionTypes.LAPACKE_zgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggesx: FunctionTypes.LAPACKE_sggesx? = load(name: "LAPACKE_sggesx")
    #elseif os(macOS)
    static let sggesx: FunctionTypes.LAPACKE_sggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggesx: FunctionTypes.LAPACKE_dggesx? = load(name: "LAPACKE_dggesx")
    #elseif os(macOS)
    static let dggesx: FunctionTypes.LAPACKE_dggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggesx: FunctionTypes.LAPACKE_cggesx? = load(name: "LAPACKE_cggesx")
    #elseif os(macOS)
    static let cggesx: FunctionTypes.LAPACKE_cggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggesx: FunctionTypes.LAPACKE_zggesx? = load(name: "LAPACKE_zggesx")
    #elseif os(macOS)
    static let zggesx: FunctionTypes.LAPACKE_zggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev: FunctionTypes.LAPACKE_sggev? = load(name: "LAPACKE_sggev")
    #elseif os(macOS)
    static let sggev: FunctionTypes.LAPACKE_sggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev: FunctionTypes.LAPACKE_dggev? = load(name: "LAPACKE_dggev")
    #elseif os(macOS)
    static let dggev: FunctionTypes.LAPACKE_dggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev: FunctionTypes.LAPACKE_cggev? = load(name: "LAPACKE_cggev")
    #elseif os(macOS)
    static let cggev: FunctionTypes.LAPACKE_cggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev: FunctionTypes.LAPACKE_zggev? = load(name: "LAPACKE_zggev")
    #elseif os(macOS)
    static let zggev: FunctionTypes.LAPACKE_zggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev3: FunctionTypes.LAPACKE_sggev3? = load(name: "LAPACKE_sggev3")
    #elseif os(macOS)
    static let sggev3: FunctionTypes.LAPACKE_sggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev3: FunctionTypes.LAPACKE_dggev3? = load(name: "LAPACKE_dggev3")
    #elseif os(macOS)
    static let dggev3: FunctionTypes.LAPACKE_dggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev3: FunctionTypes.LAPACKE_cggev3? = load(name: "LAPACKE_cggev3")
    #elseif os(macOS)
    static let cggev3: FunctionTypes.LAPACKE_cggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev3: FunctionTypes.LAPACKE_zggev3? = load(name: "LAPACKE_zggev3")
    #elseif os(macOS)
    static let zggev3: FunctionTypes.LAPACKE_zggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggevx: FunctionTypes.LAPACKE_sggevx? = load(name: "LAPACKE_sggevx")
    #elseif os(macOS)
    static let sggevx: FunctionTypes.LAPACKE_sggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggevx: FunctionTypes.LAPACKE_dggevx? = load(name: "LAPACKE_dggevx")
    #elseif os(macOS)
    static let dggevx: FunctionTypes.LAPACKE_dggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggevx: FunctionTypes.LAPACKE_cggevx? = load(name: "LAPACKE_cggevx")
    #elseif os(macOS)
    static let cggevx: FunctionTypes.LAPACKE_cggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggevx: FunctionTypes.LAPACKE_zggevx? = load(name: "LAPACKE_zggevx")
    #elseif os(macOS)
    static let zggevx: FunctionTypes.LAPACKE_zggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggglm: FunctionTypes.LAPACKE_sggglm? = load(name: "LAPACKE_sggglm")
    #elseif os(macOS)
    static let sggglm: FunctionTypes.LAPACKE_sggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggglm: FunctionTypes.LAPACKE_dggglm? = load(name: "LAPACKE_dggglm")
    #elseif os(macOS)
    static let dggglm: FunctionTypes.LAPACKE_dggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggglm: FunctionTypes.LAPACKE_cggglm? = load(name: "LAPACKE_cggglm")
    #elseif os(macOS)
    static let cggglm: FunctionTypes.LAPACKE_cggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggglm: FunctionTypes.LAPACKE_zggglm? = load(name: "LAPACKE_zggglm")
    #elseif os(macOS)
    static let zggglm: FunctionTypes.LAPACKE_zggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghrd: FunctionTypes.LAPACKE_sgghrd? = load(name: "LAPACKE_sgghrd")
    #elseif os(macOS)
    static let sgghrd: FunctionTypes.LAPACKE_sgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghrd: FunctionTypes.LAPACKE_dgghrd? = load(name: "LAPACKE_dgghrd")
    #elseif os(macOS)
    static let dgghrd: FunctionTypes.LAPACKE_dgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghrd: FunctionTypes.LAPACKE_cgghrd? = load(name: "LAPACKE_cgghrd")
    #elseif os(macOS)
    static let cgghrd: FunctionTypes.LAPACKE_cgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghrd: FunctionTypes.LAPACKE_zgghrd? = load(name: "LAPACKE_zgghrd")
    #elseif os(macOS)
    static let zgghrd: FunctionTypes.LAPACKE_zgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghd3: FunctionTypes.LAPACKE_sgghd3? = load(name: "LAPACKE_sgghd3")
    #elseif os(macOS)
    static let sgghd3: FunctionTypes.LAPACKE_sgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghd3: FunctionTypes.LAPACKE_dgghd3? = load(name: "LAPACKE_dgghd3")
    #elseif os(macOS)
    static let dgghd3: FunctionTypes.LAPACKE_dgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghd3: FunctionTypes.LAPACKE_cgghd3? = load(name: "LAPACKE_cgghd3")
    #elseif os(macOS)
    static let cgghd3: FunctionTypes.LAPACKE_cgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghd3: FunctionTypes.LAPACKE_zgghd3? = load(name: "LAPACKE_zgghd3")
    #elseif os(macOS)
    static let zgghd3: FunctionTypes.LAPACKE_zgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgglse: FunctionTypes.LAPACKE_sgglse? = load(name: "LAPACKE_sgglse")
    #elseif os(macOS)
    static let sgglse: FunctionTypes.LAPACKE_sgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgglse: FunctionTypes.LAPACKE_dgglse? = load(name: "LAPACKE_dgglse")
    #elseif os(macOS)
    static let dgglse: FunctionTypes.LAPACKE_dgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgglse: FunctionTypes.LAPACKE_cgglse? = load(name: "LAPACKE_cgglse")
    #elseif os(macOS)
    static let cgglse: FunctionTypes.LAPACKE_cgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgglse: FunctionTypes.LAPACKE_zgglse? = load(name: "LAPACKE_zgglse")
    #elseif os(macOS)
    static let zgglse: FunctionTypes.LAPACKE_zgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggqrf: FunctionTypes.LAPACKE_sggqrf? = load(name: "LAPACKE_sggqrf")
    #elseif os(macOS)
    static let sggqrf: FunctionTypes.LAPACKE_sggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggqrf: FunctionTypes.LAPACKE_dggqrf? = load(name: "LAPACKE_dggqrf")
    #elseif os(macOS)
    static let dggqrf: FunctionTypes.LAPACKE_dggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggqrf: FunctionTypes.LAPACKE_cggqrf? = load(name: "LAPACKE_cggqrf")
    #elseif os(macOS)
    static let cggqrf: FunctionTypes.LAPACKE_cggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggqrf: FunctionTypes.LAPACKE_zggqrf? = load(name: "LAPACKE_zggqrf")
    #elseif os(macOS)
    static let zggqrf: FunctionTypes.LAPACKE_zggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggrqf: FunctionTypes.LAPACKE_sggrqf? = load(name: "LAPACKE_sggrqf")
    #elseif os(macOS)
    static let sggrqf: FunctionTypes.LAPACKE_sggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggrqf: FunctionTypes.LAPACKE_dggrqf? = load(name: "LAPACKE_dggrqf")
    #elseif os(macOS)
    static let dggrqf: FunctionTypes.LAPACKE_dggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggrqf: FunctionTypes.LAPACKE_cggrqf? = load(name: "LAPACKE_cggrqf")
    #elseif os(macOS)
    static let cggrqf: FunctionTypes.LAPACKE_cggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggrqf: FunctionTypes.LAPACKE_zggrqf? = load(name: "LAPACKE_zggrqf")
    #elseif os(macOS)
    static let zggrqf: FunctionTypes.LAPACKE_zggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd: FunctionTypes.LAPACKE_sggsvd? = load(name: "LAPACKE_sggsvd")
    #elseif os(macOS)
    static let sggsvd: FunctionTypes.LAPACKE_sggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd: FunctionTypes.LAPACKE_dggsvd? = load(name: "LAPACKE_dggsvd")
    #elseif os(macOS)
    static let dggsvd: FunctionTypes.LAPACKE_dggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd: FunctionTypes.LAPACKE_cggsvd? = load(name: "LAPACKE_cggsvd")
    #elseif os(macOS)
    static let cggsvd: FunctionTypes.LAPACKE_cggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd: FunctionTypes.LAPACKE_zggsvd? = load(name: "LAPACKE_zggsvd")
    #elseif os(macOS)
    static let zggsvd: FunctionTypes.LAPACKE_zggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd3: FunctionTypes.LAPACKE_sggsvd3? = load(name: "LAPACKE_sggsvd3")
    #elseif os(macOS)
    static let sggsvd3: FunctionTypes.LAPACKE_sggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd3: FunctionTypes.LAPACKE_dggsvd3? = load(name: "LAPACKE_dggsvd3")
    #elseif os(macOS)
    static let dggsvd3: FunctionTypes.LAPACKE_dggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd3: FunctionTypes.LAPACKE_cggsvd3? = load(name: "LAPACKE_cggsvd3")
    #elseif os(macOS)
    static let cggsvd3: FunctionTypes.LAPACKE_cggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd3: FunctionTypes.LAPACKE_zggsvd3? = load(name: "LAPACKE_zggsvd3")
    #elseif os(macOS)
    static let zggsvd3: FunctionTypes.LAPACKE_zggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp: FunctionTypes.LAPACKE_sggsvp? = load(name: "LAPACKE_sggsvp")
    #elseif os(macOS)
    static let sggsvp: FunctionTypes.LAPACKE_sggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp: FunctionTypes.LAPACKE_dggsvp? = load(name: "LAPACKE_dggsvp")
    #elseif os(macOS)
    static let dggsvp: FunctionTypes.LAPACKE_dggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp: FunctionTypes.LAPACKE_cggsvp? = load(name: "LAPACKE_cggsvp")
    #elseif os(macOS)
    static let cggsvp: FunctionTypes.LAPACKE_cggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp: FunctionTypes.LAPACKE_zggsvp? = load(name: "LAPACKE_zggsvp")
    #elseif os(macOS)
    static let zggsvp: FunctionTypes.LAPACKE_zggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp3: FunctionTypes.LAPACKE_sggsvp3? = load(name: "LAPACKE_sggsvp3")
    #elseif os(macOS)
    static let sggsvp3: FunctionTypes.LAPACKE_sggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp3: FunctionTypes.LAPACKE_dggsvp3? = load(name: "LAPACKE_dggsvp3")
    #elseif os(macOS)
    static let dggsvp3: FunctionTypes.LAPACKE_dggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp3: FunctionTypes.LAPACKE_cggsvp3? = load(name: "LAPACKE_cggsvp3")
    #elseif os(macOS)
    static let cggsvp3: FunctionTypes.LAPACKE_cggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp3: FunctionTypes.LAPACKE_zggsvp3? = load(name: "LAPACKE_zggsvp3")
    #elseif os(macOS)
    static let zggsvp3: FunctionTypes.LAPACKE_zggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtcon: FunctionTypes.LAPACKE_sgtcon? = load(name: "LAPACKE_sgtcon")
    #elseif os(macOS)
    static let sgtcon: FunctionTypes.LAPACKE_sgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtcon: FunctionTypes.LAPACKE_dgtcon? = load(name: "LAPACKE_dgtcon")
    #elseif os(macOS)
    static let dgtcon: FunctionTypes.LAPACKE_dgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtcon: FunctionTypes.LAPACKE_cgtcon? = load(name: "LAPACKE_cgtcon")
    #elseif os(macOS)
    static let cgtcon: FunctionTypes.LAPACKE_cgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtcon: FunctionTypes.LAPACKE_zgtcon? = load(name: "LAPACKE_zgtcon")
    #elseif os(macOS)
    static let zgtcon: FunctionTypes.LAPACKE_zgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtrfs: FunctionTypes.LAPACKE_sgtrfs? = load(name: "LAPACKE_sgtrfs")
    #elseif os(macOS)
    static let sgtrfs: FunctionTypes.LAPACKE_sgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtrfs: FunctionTypes.LAPACKE_dgtrfs? = load(name: "LAPACKE_dgtrfs")
    #elseif os(macOS)
    static let dgtrfs: FunctionTypes.LAPACKE_dgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtrfs: FunctionTypes.LAPACKE_cgtrfs? = load(name: "LAPACKE_cgtrfs")
    #elseif os(macOS)
    static let cgtrfs: FunctionTypes.LAPACKE_cgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtrfs: FunctionTypes.LAPACKE_zgtrfs? = load(name: "LAPACKE_zgtrfs")
    #elseif os(macOS)
    static let zgtrfs: FunctionTypes.LAPACKE_zgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsv: FunctionTypes.LAPACKE_sgtsv? = load(name: "LAPACKE_sgtsv")
    #elseif os(macOS)
    static let sgtsv: FunctionTypes.LAPACKE_sgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsv: FunctionTypes.LAPACKE_dgtsv? = load(name: "LAPACKE_dgtsv")
    #elseif os(macOS)
    static let dgtsv: FunctionTypes.LAPACKE_dgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsv: FunctionTypes.LAPACKE_cgtsv? = load(name: "LAPACKE_cgtsv")
    #elseif os(macOS)
    static let cgtsv: FunctionTypes.LAPACKE_cgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsv: FunctionTypes.LAPACKE_zgtsv? = load(name: "LAPACKE_zgtsv")
    #elseif os(macOS)
    static let zgtsv: FunctionTypes.LAPACKE_zgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsvx: FunctionTypes.LAPACKE_sgtsvx? = load(name: "LAPACKE_sgtsvx")
    #elseif os(macOS)
    static let sgtsvx: FunctionTypes.LAPACKE_sgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsvx: FunctionTypes.LAPACKE_dgtsvx? = load(name: "LAPACKE_dgtsvx")
    #elseif os(macOS)
    static let dgtsvx: FunctionTypes.LAPACKE_dgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsvx: FunctionTypes.LAPACKE_cgtsvx? = load(name: "LAPACKE_cgtsvx")
    #elseif os(macOS)
    static let cgtsvx: FunctionTypes.LAPACKE_cgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsvx: FunctionTypes.LAPACKE_zgtsvx? = load(name: "LAPACKE_zgtsvx")
    #elseif os(macOS)
    static let zgtsvx: FunctionTypes.LAPACKE_zgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrf: FunctionTypes.LAPACKE_sgttrf? = load(name: "LAPACKE_sgttrf")
    #elseif os(macOS)
    static let sgttrf: FunctionTypes.LAPACKE_sgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrf: FunctionTypes.LAPACKE_dgttrf? = load(name: "LAPACKE_dgttrf")
    #elseif os(macOS)
    static let dgttrf: FunctionTypes.LAPACKE_dgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrf: FunctionTypes.LAPACKE_cgttrf? = load(name: "LAPACKE_cgttrf")
    #elseif os(macOS)
    static let cgttrf: FunctionTypes.LAPACKE_cgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrf: FunctionTypes.LAPACKE_zgttrf? = load(name: "LAPACKE_zgttrf")
    #elseif os(macOS)
    static let zgttrf: FunctionTypes.LAPACKE_zgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrs: FunctionTypes.LAPACKE_sgttrs? = load(name: "LAPACKE_sgttrs")
    #elseif os(macOS)
    static let sgttrs: FunctionTypes.LAPACKE_sgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrs: FunctionTypes.LAPACKE_dgttrs? = load(name: "LAPACKE_dgttrs")
    #elseif os(macOS)
    static let dgttrs: FunctionTypes.LAPACKE_dgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrs: FunctionTypes.LAPACKE_cgttrs? = load(name: "LAPACKE_cgttrs")
    #elseif os(macOS)
    static let cgttrs: FunctionTypes.LAPACKE_cgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrs: FunctionTypes.LAPACKE_zgttrs? = load(name: "LAPACKE_zgttrs")
    #elseif os(macOS)
    static let zgttrs: FunctionTypes.LAPACKE_zgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev: FunctionTypes.LAPACKE_chbev? = load(name: "LAPACKE_chbev")
    #elseif os(macOS)
    static let chbev: FunctionTypes.LAPACKE_chbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev: FunctionTypes.LAPACKE_zhbev? = load(name: "LAPACKE_zhbev")
    #elseif os(macOS)
    static let zhbev: FunctionTypes.LAPACKE_zhbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd: FunctionTypes.LAPACKE_chbevd? = load(name: "LAPACKE_chbevd")
    #elseif os(macOS)
    static let chbevd: FunctionTypes.LAPACKE_chbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd: FunctionTypes.LAPACKE_zhbevd? = load(name: "LAPACKE_zhbevd")
    #elseif os(macOS)
    static let zhbevd: FunctionTypes.LAPACKE_zhbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx: FunctionTypes.LAPACKE_chbevx? = load(name: "LAPACKE_chbevx")
    #elseif os(macOS)
    static let chbevx: FunctionTypes.LAPACKE_chbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx: FunctionTypes.LAPACKE_zhbevx? = load(name: "LAPACKE_zhbevx")
    #elseif os(macOS)
    static let zhbevx: FunctionTypes.LAPACKE_zhbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgst: FunctionTypes.LAPACKE_chbgst? = load(name: "LAPACKE_chbgst")
    #elseif os(macOS)
    static let chbgst: FunctionTypes.LAPACKE_chbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgst: FunctionTypes.LAPACKE_zhbgst? = load(name: "LAPACKE_zhbgst")
    #elseif os(macOS)
    static let zhbgst: FunctionTypes.LAPACKE_zhbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgv: FunctionTypes.LAPACKE_chbgv? = load(name: "LAPACKE_chbgv")
    #elseif os(macOS)
    static let chbgv: FunctionTypes.LAPACKE_chbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgv: FunctionTypes.LAPACKE_zhbgv? = load(name: "LAPACKE_zhbgv")
    #elseif os(macOS)
    static let zhbgv: FunctionTypes.LAPACKE_zhbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvd: FunctionTypes.LAPACKE_chbgvd? = load(name: "LAPACKE_chbgvd")
    #elseif os(macOS)
    static let chbgvd: FunctionTypes.LAPACKE_chbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvd: FunctionTypes.LAPACKE_zhbgvd? = load(name: "LAPACKE_zhbgvd")
    #elseif os(macOS)
    static let zhbgvd: FunctionTypes.LAPACKE_zhbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvx: FunctionTypes.LAPACKE_chbgvx? = load(name: "LAPACKE_chbgvx")
    #elseif os(macOS)
    static let chbgvx: FunctionTypes.LAPACKE_chbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvx: FunctionTypes.LAPACKE_zhbgvx? = load(name: "LAPACKE_zhbgvx")
    #elseif os(macOS)
    static let zhbgvx: FunctionTypes.LAPACKE_zhbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbtrd: FunctionTypes.LAPACKE_chbtrd? = load(name: "LAPACKE_chbtrd")
    #elseif os(macOS)
    static let chbtrd: FunctionTypes.LAPACKE_chbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbtrd: FunctionTypes.LAPACKE_zhbtrd? = load(name: "LAPACKE_zhbtrd")
    #elseif os(macOS)
    static let zhbtrd: FunctionTypes.LAPACKE_zhbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon: FunctionTypes.LAPACKE_checon? = load(name: "LAPACKE_checon")
    #elseif os(macOS)
    static let checon: FunctionTypes.LAPACKE_checon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon: FunctionTypes.LAPACKE_zhecon? = load(name: "LAPACKE_zhecon")
    #elseif os(macOS)
    static let zhecon: FunctionTypes.LAPACKE_zhecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheequb: FunctionTypes.LAPACKE_cheequb? = load(name: "LAPACKE_cheequb")
    #elseif os(macOS)
    static let cheequb: FunctionTypes.LAPACKE_cheequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheequb: FunctionTypes.LAPACKE_zheequb? = load(name: "LAPACKE_zheequb")
    #elseif os(macOS)
    static let zheequb: FunctionTypes.LAPACKE_zheequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev: FunctionTypes.LAPACKE_cheev? = load(name: "LAPACKE_cheev")
    #elseif os(macOS)
    static let cheev: FunctionTypes.LAPACKE_cheev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev: FunctionTypes.LAPACKE_zheev? = load(name: "LAPACKE_zheev")
    #elseif os(macOS)
    static let zheev: FunctionTypes.LAPACKE_zheev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd: FunctionTypes.LAPACKE_cheevd? = load(name: "LAPACKE_cheevd")
    #elseif os(macOS)
    static let cheevd: FunctionTypes.LAPACKE_cheevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd: FunctionTypes.LAPACKE_zheevd? = load(name: "LAPACKE_zheevd")
    #elseif os(macOS)
    static let zheevd: FunctionTypes.LAPACKE_zheevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr: FunctionTypes.LAPACKE_cheevr? = load(name: "LAPACKE_cheevr")
    #elseif os(macOS)
    static let cheevr: FunctionTypes.LAPACKE_cheevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr: FunctionTypes.LAPACKE_zheevr? = load(name: "LAPACKE_zheevr")
    #elseif os(macOS)
    static let zheevr: FunctionTypes.LAPACKE_zheevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx: FunctionTypes.LAPACKE_cheevx? = load(name: "LAPACKE_cheevx")
    #elseif os(macOS)
    static let cheevx: FunctionTypes.LAPACKE_cheevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx: FunctionTypes.LAPACKE_zheevx? = load(name: "LAPACKE_zheevx")
    #elseif os(macOS)
    static let zheevx: FunctionTypes.LAPACKE_zheevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegst: FunctionTypes.LAPACKE_chegst? = load(name: "LAPACKE_chegst")
    #elseif os(macOS)
    static let chegst: FunctionTypes.LAPACKE_chegst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegst: FunctionTypes.LAPACKE_zhegst? = load(name: "LAPACKE_zhegst")
    #elseif os(macOS)
    static let zhegst: FunctionTypes.LAPACKE_zhegst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv: FunctionTypes.LAPACKE_chegv? = load(name: "LAPACKE_chegv")
    #elseif os(macOS)
    static let chegv: FunctionTypes.LAPACKE_chegv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv: FunctionTypes.LAPACKE_zhegv? = load(name: "LAPACKE_zhegv")
    #elseif os(macOS)
    static let zhegv: FunctionTypes.LAPACKE_zhegv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvd: FunctionTypes.LAPACKE_chegvd? = load(name: "LAPACKE_chegvd")
    #elseif os(macOS)
    static let chegvd: FunctionTypes.LAPACKE_chegvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvd: FunctionTypes.LAPACKE_zhegvd? = load(name: "LAPACKE_zhegvd")
    #elseif os(macOS)
    static let zhegvd: FunctionTypes.LAPACKE_zhegvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvx: FunctionTypes.LAPACKE_chegvx? = load(name: "LAPACKE_chegvx")
    #elseif os(macOS)
    static let chegvx: FunctionTypes.LAPACKE_chegvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvx: FunctionTypes.LAPACKE_zhegvx? = load(name: "LAPACKE_zhegvx")
    #elseif os(macOS)
    static let zhegvx: FunctionTypes.LAPACKE_zhegvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfs: FunctionTypes.LAPACKE_cherfs? = load(name: "LAPACKE_cherfs")
    #elseif os(macOS)
    static let cherfs: FunctionTypes.LAPACKE_cherfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfs: FunctionTypes.LAPACKE_zherfs? = load(name: "LAPACKE_zherfs")
    #elseif os(macOS)
    static let zherfs: FunctionTypes.LAPACKE_zherfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfsx: FunctionTypes.LAPACKE_cherfsx? = load(name: "LAPACKE_cherfsx")
    #elseif os(macOS)
    static let cherfsx: FunctionTypes.LAPACKE_cherfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfsx: FunctionTypes.LAPACKE_zherfsx? = load(name: "LAPACKE_zherfsx")
    #elseif os(macOS)
    static let zherfsx: FunctionTypes.LAPACKE_zherfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv: FunctionTypes.LAPACKE_chesv? = load(name: "LAPACKE_chesv")
    #elseif os(macOS)
    static let chesv: FunctionTypes.LAPACKE_chesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv: FunctionTypes.LAPACKE_zhesv? = load(name: "LAPACKE_zhesv")
    #elseif os(macOS)
    static let zhesv: FunctionTypes.LAPACKE_zhesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvx: FunctionTypes.LAPACKE_chesvx? = load(name: "LAPACKE_chesvx")
    #elseif os(macOS)
    static let chesvx: FunctionTypes.LAPACKE_chesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvx: FunctionTypes.LAPACKE_zhesvx? = load(name: "LAPACKE_zhesvx")
    #elseif os(macOS)
    static let zhesvx: FunctionTypes.LAPACKE_zhesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvxx: FunctionTypes.LAPACKE_chesvxx? = load(name: "LAPACKE_chesvxx")
    #elseif os(macOS)
    static let chesvxx: FunctionTypes.LAPACKE_chesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvxx: FunctionTypes.LAPACKE_zhesvxx? = load(name: "LAPACKE_zhesvxx")
    #elseif os(macOS)
    static let zhesvxx: FunctionTypes.LAPACKE_zhesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrd: FunctionTypes.LAPACKE_chetrd? = load(name: "LAPACKE_chetrd")
    #elseif os(macOS)
    static let chetrd: FunctionTypes.LAPACKE_chetrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrd: FunctionTypes.LAPACKE_zhetrd? = load(name: "LAPACKE_zhetrd")
    #elseif os(macOS)
    static let zhetrd: FunctionTypes.LAPACKE_zhetrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf: FunctionTypes.LAPACKE_chetrf? = load(name: "LAPACKE_chetrf")
    #elseif os(macOS)
    static let chetrf: FunctionTypes.LAPACKE_chetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf: FunctionTypes.LAPACKE_zhetrf? = load(name: "LAPACKE_zhetrf")
    #elseif os(macOS)
    static let zhetrf: FunctionTypes.LAPACKE_zhetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri: FunctionTypes.LAPACKE_chetri? = load(name: "LAPACKE_chetri")
    #elseif os(macOS)
    static let chetri: FunctionTypes.LAPACKE_chetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri: FunctionTypes.LAPACKE_zhetri? = load(name: "LAPACKE_zhetri")
    #elseif os(macOS)
    static let zhetri: FunctionTypes.LAPACKE_zhetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs: FunctionTypes.LAPACKE_chetrs? = load(name: "LAPACKE_chetrs")
    #elseif os(macOS)
    static let chetrs: FunctionTypes.LAPACKE_chetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs: FunctionTypes.LAPACKE_zhetrs? = load(name: "LAPACKE_zhetrs")
    #elseif os(macOS)
    static let zhetrs: FunctionTypes.LAPACKE_zhetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chfrk: FunctionTypes.LAPACKE_chfrk? = load(name: "LAPACKE_chfrk")
    #elseif os(macOS)
    static let chfrk: FunctionTypes.LAPACKE_chfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhfrk: FunctionTypes.LAPACKE_zhfrk? = load(name: "LAPACKE_zhfrk")
    #elseif os(macOS)
    static let zhfrk: FunctionTypes.LAPACKE_zhfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shgeqz: FunctionTypes.LAPACKE_shgeqz? = load(name: "LAPACKE_shgeqz")
    #elseif os(macOS)
    static let shgeqz: FunctionTypes.LAPACKE_shgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhgeqz: FunctionTypes.LAPACKE_dhgeqz? = load(name: "LAPACKE_dhgeqz")
    #elseif os(macOS)
    static let dhgeqz: FunctionTypes.LAPACKE_dhgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chgeqz: FunctionTypes.LAPACKE_chgeqz? = load(name: "LAPACKE_chgeqz")
    #elseif os(macOS)
    static let chgeqz: FunctionTypes.LAPACKE_chgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhgeqz: FunctionTypes.LAPACKE_zhgeqz? = load(name: "LAPACKE_zhgeqz")
    #elseif os(macOS)
    static let zhgeqz: FunctionTypes.LAPACKE_zhgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpcon: FunctionTypes.LAPACKE_chpcon? = load(name: "LAPACKE_chpcon")
    #elseif os(macOS)
    static let chpcon: FunctionTypes.LAPACKE_chpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpcon: FunctionTypes.LAPACKE_zhpcon? = load(name: "LAPACKE_zhpcon")
    #elseif os(macOS)
    static let zhpcon: FunctionTypes.LAPACKE_zhpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpev: FunctionTypes.LAPACKE_chpev? = load(name: "LAPACKE_chpev")
    #elseif os(macOS)
    static let chpev: FunctionTypes.LAPACKE_chpev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpev: FunctionTypes.LAPACKE_zhpev? = load(name: "LAPACKE_zhpev")
    #elseif os(macOS)
    static let zhpev: FunctionTypes.LAPACKE_zhpev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevd: FunctionTypes.LAPACKE_chpevd? = load(name: "LAPACKE_chpevd")
    #elseif os(macOS)
    static let chpevd: FunctionTypes.LAPACKE_chpevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevd: FunctionTypes.LAPACKE_zhpevd? = load(name: "LAPACKE_zhpevd")
    #elseif os(macOS)
    static let zhpevd: FunctionTypes.LAPACKE_zhpevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevx: FunctionTypes.LAPACKE_chpevx? = load(name: "LAPACKE_chpevx")
    #elseif os(macOS)
    static let chpevx: FunctionTypes.LAPACKE_chpevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevx: FunctionTypes.LAPACKE_zhpevx? = load(name: "LAPACKE_zhpevx")
    #elseif os(macOS)
    static let zhpevx: FunctionTypes.LAPACKE_zhpevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgst: FunctionTypes.LAPACKE_chpgst? = load(name: "LAPACKE_chpgst")
    #elseif os(macOS)
    static let chpgst: FunctionTypes.LAPACKE_chpgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgst: FunctionTypes.LAPACKE_zhpgst? = load(name: "LAPACKE_zhpgst")
    #elseif os(macOS)
    static let zhpgst: FunctionTypes.LAPACKE_zhpgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgv: FunctionTypes.LAPACKE_chpgv? = load(name: "LAPACKE_chpgv")
    #elseif os(macOS)
    static let chpgv: FunctionTypes.LAPACKE_chpgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgv: FunctionTypes.LAPACKE_zhpgv? = load(name: "LAPACKE_zhpgv")
    #elseif os(macOS)
    static let zhpgv: FunctionTypes.LAPACKE_zhpgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvd: FunctionTypes.LAPACKE_chpgvd? = load(name: "LAPACKE_chpgvd")
    #elseif os(macOS)
    static let chpgvd: FunctionTypes.LAPACKE_chpgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvd: FunctionTypes.LAPACKE_zhpgvd? = load(name: "LAPACKE_zhpgvd")
    #elseif os(macOS)
    static let zhpgvd: FunctionTypes.LAPACKE_zhpgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvx: FunctionTypes.LAPACKE_chpgvx? = load(name: "LAPACKE_chpgvx")
    #elseif os(macOS)
    static let chpgvx: FunctionTypes.LAPACKE_chpgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvx: FunctionTypes.LAPACKE_zhpgvx? = load(name: "LAPACKE_zhpgvx")
    #elseif os(macOS)
    static let zhpgvx: FunctionTypes.LAPACKE_zhpgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chprfs: FunctionTypes.LAPACKE_chprfs? = load(name: "LAPACKE_chprfs")
    #elseif os(macOS)
    static let chprfs: FunctionTypes.LAPACKE_chprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhprfs: FunctionTypes.LAPACKE_zhprfs? = load(name: "LAPACKE_zhprfs")
    #elseif os(macOS)
    static let zhprfs: FunctionTypes.LAPACKE_zhprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsv: FunctionTypes.LAPACKE_chpsv? = load(name: "LAPACKE_chpsv")
    #elseif os(macOS)
    static let chpsv: FunctionTypes.LAPACKE_chpsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsv: FunctionTypes.LAPACKE_zhpsv? = load(name: "LAPACKE_zhpsv")
    #elseif os(macOS)
    static let zhpsv: FunctionTypes.LAPACKE_zhpsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsvx: FunctionTypes.LAPACKE_chpsvx? = load(name: "LAPACKE_chpsvx")
    #elseif os(macOS)
    static let chpsvx: FunctionTypes.LAPACKE_chpsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsvx: FunctionTypes.LAPACKE_zhpsvx? = load(name: "LAPACKE_zhpsvx")
    #elseif os(macOS)
    static let zhpsvx: FunctionTypes.LAPACKE_zhpsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrd: FunctionTypes.LAPACKE_chptrd? = load(name: "LAPACKE_chptrd")
    #elseif os(macOS)
    static let chptrd: FunctionTypes.LAPACKE_chptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrd: FunctionTypes.LAPACKE_zhptrd? = load(name: "LAPACKE_zhptrd")
    #elseif os(macOS)
    static let zhptrd: FunctionTypes.LAPACKE_zhptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrf: FunctionTypes.LAPACKE_chptrf? = load(name: "LAPACKE_chptrf")
    #elseif os(macOS)
    static let chptrf: FunctionTypes.LAPACKE_chptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrf: FunctionTypes.LAPACKE_zhptrf? = load(name: "LAPACKE_zhptrf")
    #elseif os(macOS)
    static let zhptrf: FunctionTypes.LAPACKE_zhptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptri: FunctionTypes.LAPACKE_chptri? = load(name: "LAPACKE_chptri")
    #elseif os(macOS)
    static let chptri: FunctionTypes.LAPACKE_chptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptri: FunctionTypes.LAPACKE_zhptri? = load(name: "LAPACKE_zhptri")
    #elseif os(macOS)
    static let zhptri: FunctionTypes.LAPACKE_zhptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrs: FunctionTypes.LAPACKE_chptrs? = load(name: "LAPACKE_chptrs")
    #elseif os(macOS)
    static let chptrs: FunctionTypes.LAPACKE_chptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrs: FunctionTypes.LAPACKE_zhptrs? = load(name: "LAPACKE_zhptrs")
    #elseif os(macOS)
    static let zhptrs: FunctionTypes.LAPACKE_zhptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shsein: FunctionTypes.LAPACKE_shsein? = load(name: "LAPACKE_shsein")
    #elseif os(macOS)
    static let shsein: FunctionTypes.LAPACKE_shsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhsein: FunctionTypes.LAPACKE_dhsein? = load(name: "LAPACKE_dhsein")
    #elseif os(macOS)
    static let dhsein: FunctionTypes.LAPACKE_dhsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chsein: FunctionTypes.LAPACKE_chsein? = load(name: "LAPACKE_chsein")
    #elseif os(macOS)
    static let chsein: FunctionTypes.LAPACKE_chsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhsein: FunctionTypes.LAPACKE_zhsein? = load(name: "LAPACKE_zhsein")
    #elseif os(macOS)
    static let zhsein: FunctionTypes.LAPACKE_zhsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shseqr: FunctionTypes.LAPACKE_shseqr? = load(name: "LAPACKE_shseqr")
    #elseif os(macOS)
    static let shseqr: FunctionTypes.LAPACKE_shseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhseqr: FunctionTypes.LAPACKE_dhseqr? = load(name: "LAPACKE_dhseqr")
    #elseif os(macOS)
    static let dhseqr: FunctionTypes.LAPACKE_dhseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chseqr: FunctionTypes.LAPACKE_chseqr? = load(name: "LAPACKE_chseqr")
    #elseif os(macOS)
    static let chseqr: FunctionTypes.LAPACKE_chseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhseqr: FunctionTypes.LAPACKE_zhseqr? = load(name: "LAPACKE_zhseqr")
    #elseif os(macOS)
    static let zhseqr: FunctionTypes.LAPACKE_zhseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacgv: FunctionTypes.LAPACKE_clacgv? = load(name: "LAPACKE_clacgv")
    #elseif os(macOS)
    static let clacgv: FunctionTypes.LAPACKE_clacgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacgv: FunctionTypes.LAPACKE_zlacgv? = load(name: "LAPACKE_zlacgv")
    #elseif os(macOS)
    static let zlacgv: FunctionTypes.LAPACKE_zlacgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacn2: FunctionTypes.LAPACKE_slacn2? = load(name: "LAPACKE_slacn2")
    #elseif os(macOS)
    static let slacn2: FunctionTypes.LAPACKE_slacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacn2: FunctionTypes.LAPACKE_dlacn2? = load(name: "LAPACKE_dlacn2")
    #elseif os(macOS)
    static let dlacn2: FunctionTypes.LAPACKE_dlacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacn2: FunctionTypes.LAPACKE_clacn2? = load(name: "LAPACKE_clacn2")
    #elseif os(macOS)
    static let clacn2: FunctionTypes.LAPACKE_clacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacn2: FunctionTypes.LAPACKE_zlacn2? = load(name: "LAPACKE_zlacn2")
    #elseif os(macOS)
    static let zlacn2: FunctionTypes.LAPACKE_zlacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacpy: FunctionTypes.LAPACKE_slacpy? = load(name: "LAPACKE_slacpy")
    #elseif os(macOS)
    static let slacpy: FunctionTypes.LAPACKE_slacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacpy: FunctionTypes.LAPACKE_dlacpy? = load(name: "LAPACKE_dlacpy")
    #elseif os(macOS)
    static let dlacpy: FunctionTypes.LAPACKE_dlacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacpy: FunctionTypes.LAPACKE_clacpy? = load(name: "LAPACKE_clacpy")
    #elseif os(macOS)
    static let clacpy: FunctionTypes.LAPACKE_clacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacpy: FunctionTypes.LAPACKE_zlacpy? = load(name: "LAPACKE_zlacpy")
    #elseif os(macOS)
    static let zlacpy: FunctionTypes.LAPACKE_zlacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacp2: FunctionTypes.LAPACKE_clacp2? = load(name: "LAPACKE_clacp2")
    #elseif os(macOS)
    static let clacp2: FunctionTypes.LAPACKE_clacp2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacp2: FunctionTypes.LAPACKE_zlacp2? = load(name: "LAPACKE_zlacp2")
    #elseif os(macOS)
    static let zlacp2: FunctionTypes.LAPACKE_zlacp2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlag2c: FunctionTypes.LAPACKE_zlag2c? = load(name: "LAPACKE_zlag2c")
    #elseif os(macOS)
    static let zlag2c: FunctionTypes.LAPACKE_zlag2c? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slag2d: FunctionTypes.LAPACKE_slag2d? = load(name: "LAPACKE_slag2d")
    #elseif os(macOS)
    static let slag2d: FunctionTypes.LAPACKE_slag2d? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlag2s: FunctionTypes.LAPACKE_dlag2s? = load(name: "LAPACKE_dlag2s")
    #elseif os(macOS)
    static let dlag2s: FunctionTypes.LAPACKE_dlag2s? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clag2z: FunctionTypes.LAPACKE_clag2z? = load(name: "LAPACKE_clag2z")
    #elseif os(macOS)
    static let clag2z: FunctionTypes.LAPACKE_clag2z? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagge: FunctionTypes.LAPACKE_slagge? = load(name: "LAPACKE_slagge")
    #elseif os(macOS)
    static let slagge: FunctionTypes.LAPACKE_slagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagge: FunctionTypes.LAPACKE_dlagge? = load(name: "LAPACKE_dlagge")
    #elseif os(macOS)
    static let dlagge: FunctionTypes.LAPACKE_dlagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagge: FunctionTypes.LAPACKE_clagge? = load(name: "LAPACKE_clagge")
    #elseif os(macOS)
    static let clagge: FunctionTypes.LAPACKE_clagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagge: FunctionTypes.LAPACKE_zlagge? = load(name: "LAPACKE_zlagge")
    #elseif os(macOS)
    static let zlagge: FunctionTypes.LAPACKE_zlagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slamch: FunctionTypes.LAPACKE_slamch? = load(name: "LAPACKE_slamch")
    #elseif os(macOS)
    static let slamch: FunctionTypes.LAPACKE_slamch? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlamch: FunctionTypes.LAPACKE_dlamch? = load(name: "LAPACKE_dlamch")
    #elseif os(macOS)
    static let dlamch: FunctionTypes.LAPACKE_dlamch? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slangb: FunctionTypes.LAPACKE_slangb? = load(name: "LAPACKE_slangb")
    #elseif os(macOS)
    static let slangb: FunctionTypes.LAPACKE_slangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlangb: FunctionTypes.LAPACKE_dlangb? = load(name: "LAPACKE_dlangb")
    #elseif os(macOS)
    static let dlangb: FunctionTypes.LAPACKE_dlangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clangb: FunctionTypes.LAPACKE_clangb? = load(name: "LAPACKE_clangb")
    #elseif os(macOS)
    static let clangb: FunctionTypes.LAPACKE_clangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlangb: FunctionTypes.LAPACKE_zlangb? = load(name: "LAPACKE_zlangb")
    #elseif os(macOS)
    static let zlangb: FunctionTypes.LAPACKE_zlangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slange: FunctionTypes.LAPACKE_slange? = load(name: "LAPACKE_slange")
    #elseif os(macOS)
    static let slange: FunctionTypes.LAPACKE_slange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlange: FunctionTypes.LAPACKE_dlange? = load(name: "LAPACKE_dlange")
    #elseif os(macOS)
    static let dlange: FunctionTypes.LAPACKE_dlange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clange: FunctionTypes.LAPACKE_clange? = load(name: "LAPACKE_clange")
    #elseif os(macOS)
    static let clange: FunctionTypes.LAPACKE_clange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlange: FunctionTypes.LAPACKE_zlange? = load(name: "LAPACKE_zlange")
    #elseif os(macOS)
    static let zlange: FunctionTypes.LAPACKE_zlange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clanhe: FunctionTypes.LAPACKE_clanhe? = load(name: "LAPACKE_clanhe")
    #elseif os(macOS)
    static let clanhe: FunctionTypes.LAPACKE_clanhe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlanhe: FunctionTypes.LAPACKE_zlanhe? = load(name: "LAPACKE_zlanhe")
    #elseif os(macOS)
    static let zlanhe: FunctionTypes.LAPACKE_zlanhe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacrm: FunctionTypes.LAPACKE_clacrm? = load(name: "LAPACKE_clacrm")
    #elseif os(macOS)
    static let clacrm: FunctionTypes.LAPACKE_clacrm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacrm: FunctionTypes.LAPACKE_zlacrm? = load(name: "LAPACKE_zlacrm")
    #elseif os(macOS)
    static let zlacrm: FunctionTypes.LAPACKE_zlacrm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarcm: FunctionTypes.LAPACKE_clarcm? = load(name: "LAPACKE_clarcm")
    #elseif os(macOS)
    static let clarcm: FunctionTypes.LAPACKE_clarcm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarcm: FunctionTypes.LAPACKE_zlarcm? = load(name: "LAPACKE_zlarcm")
    #elseif os(macOS)
    static let zlarcm: FunctionTypes.LAPACKE_zlarcm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slansy: FunctionTypes.LAPACKE_slansy? = load(name: "LAPACKE_slansy")
    #elseif os(macOS)
    static let slansy: FunctionTypes.LAPACKE_slansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlansy: FunctionTypes.LAPACKE_dlansy? = load(name: "LAPACKE_dlansy")
    #elseif os(macOS)
    static let dlansy: FunctionTypes.LAPACKE_dlansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clansy: FunctionTypes.LAPACKE_clansy? = load(name: "LAPACKE_clansy")
    #elseif os(macOS)
    static let clansy: FunctionTypes.LAPACKE_clansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlansy: FunctionTypes.LAPACKE_zlansy? = load(name: "LAPACKE_zlansy")
    #elseif os(macOS)
    static let zlansy: FunctionTypes.LAPACKE_zlansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slantr: FunctionTypes.LAPACKE_slantr? = load(name: "LAPACKE_slantr")
    #elseif os(macOS)
    static let slantr: FunctionTypes.LAPACKE_slantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlantr: FunctionTypes.LAPACKE_dlantr? = load(name: "LAPACKE_dlantr")
    #elseif os(macOS)
    static let dlantr: FunctionTypes.LAPACKE_dlantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clantr: FunctionTypes.LAPACKE_clantr? = load(name: "LAPACKE_clantr")
    #elseif os(macOS)
    static let clantr: FunctionTypes.LAPACKE_clantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlantr: FunctionTypes.LAPACKE_zlantr? = load(name: "LAPACKE_zlantr")
    #elseif os(macOS)
    static let zlantr: FunctionTypes.LAPACKE_zlantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfb: FunctionTypes.LAPACKE_slarfb? = load(name: "LAPACKE_slarfb")
    #elseif os(macOS)
    static let slarfb: FunctionTypes.LAPACKE_slarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfb: FunctionTypes.LAPACKE_dlarfb? = load(name: "LAPACKE_dlarfb")
    #elseif os(macOS)
    static let dlarfb: FunctionTypes.LAPACKE_dlarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfb: FunctionTypes.LAPACKE_clarfb? = load(name: "LAPACKE_clarfb")
    #elseif os(macOS)
    static let clarfb: FunctionTypes.LAPACKE_clarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfb: FunctionTypes.LAPACKE_zlarfb? = load(name: "LAPACKE_zlarfb")
    #elseif os(macOS)
    static let zlarfb: FunctionTypes.LAPACKE_zlarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfg: FunctionTypes.LAPACKE_slarfg? = load(name: "LAPACKE_slarfg")
    #elseif os(macOS)
    static let slarfg: FunctionTypes.LAPACKE_slarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfg: FunctionTypes.LAPACKE_dlarfg? = load(name: "LAPACKE_dlarfg")
    #elseif os(macOS)
    static let dlarfg: FunctionTypes.LAPACKE_dlarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfg: FunctionTypes.LAPACKE_clarfg? = load(name: "LAPACKE_clarfg")
    #elseif os(macOS)
    static let clarfg: FunctionTypes.LAPACKE_clarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfg: FunctionTypes.LAPACKE_zlarfg? = load(name: "LAPACKE_zlarfg")
    #elseif os(macOS)
    static let zlarfg: FunctionTypes.LAPACKE_zlarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarft: FunctionTypes.LAPACKE_slarft? = load(name: "LAPACKE_slarft")
    #elseif os(macOS)
    static let slarft: FunctionTypes.LAPACKE_slarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarft: FunctionTypes.LAPACKE_dlarft? = load(name: "LAPACKE_dlarft")
    #elseif os(macOS)
    static let dlarft: FunctionTypes.LAPACKE_dlarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarft: FunctionTypes.LAPACKE_clarft? = load(name: "LAPACKE_clarft")
    #elseif os(macOS)
    static let clarft: FunctionTypes.LAPACKE_clarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarft: FunctionTypes.LAPACKE_zlarft? = load(name: "LAPACKE_zlarft")
    #elseif os(macOS)
    static let zlarft: FunctionTypes.LAPACKE_zlarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfx: FunctionTypes.LAPACKE_slarfx? = load(name: "LAPACKE_slarfx")
    #elseif os(macOS)
    static let slarfx: FunctionTypes.LAPACKE_slarfx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfx: FunctionTypes.LAPACKE_dlarfx? = load(name: "LAPACKE_dlarfx")
    #elseif os(macOS)
    static let dlarfx: FunctionTypes.LAPACKE_dlarfx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarnv: FunctionTypes.LAPACKE_slarnv? = load(name: "LAPACKE_slarnv")
    #elseif os(macOS)
    static let slarnv: FunctionTypes.LAPACKE_slarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarnv: FunctionTypes.LAPACKE_dlarnv? = load(name: "LAPACKE_dlarnv")
    #elseif os(macOS)
    static let dlarnv: FunctionTypes.LAPACKE_dlarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarnv: FunctionTypes.LAPACKE_clarnv? = load(name: "LAPACKE_clarnv")
    #elseif os(macOS)
    static let clarnv: FunctionTypes.LAPACKE_clarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarnv: FunctionTypes.LAPACKE_zlarnv? = load(name: "LAPACKE_zlarnv")
    #elseif os(macOS)
    static let zlarnv: FunctionTypes.LAPACKE_zlarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slascl: FunctionTypes.LAPACKE_slascl? = load(name: "LAPACKE_slascl")
    #elseif os(macOS)
    static let slascl: FunctionTypes.LAPACKE_slascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlascl: FunctionTypes.LAPACKE_dlascl? = load(name: "LAPACKE_dlascl")
    #elseif os(macOS)
    static let dlascl: FunctionTypes.LAPACKE_dlascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clascl: FunctionTypes.LAPACKE_clascl? = load(name: "LAPACKE_clascl")
    #elseif os(macOS)
    static let clascl: FunctionTypes.LAPACKE_clascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlascl: FunctionTypes.LAPACKE_zlascl? = load(name: "LAPACKE_zlascl")
    #elseif os(macOS)
    static let zlascl: FunctionTypes.LAPACKE_zlascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaset: FunctionTypes.LAPACKE_slaset? = load(name: "LAPACKE_slaset")
    #elseif os(macOS)
    static let slaset: FunctionTypes.LAPACKE_slaset? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaset: FunctionTypes.LAPACKE_dlaset? = load(name: "LAPACKE_dlaset")
    #elseif os(macOS)
    static let dlaset: FunctionTypes.LAPACKE_dlaset? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slasrt: FunctionTypes.LAPACKE_slasrt? = load(name: "LAPACKE_slasrt")
    #elseif os(macOS)
    static let slasrt: FunctionTypes.LAPACKE_slasrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlasrt: FunctionTypes.LAPACKE_dlasrt? = load(name: "LAPACKE_dlasrt")
    #elseif os(macOS)
    static let dlasrt: FunctionTypes.LAPACKE_dlasrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slassq: FunctionTypes.LAPACKE_slassq? = load(name: "LAPACKE_slassq")
    #elseif os(macOS)
    static let slassq: FunctionTypes.LAPACKE_slassq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlassq: FunctionTypes.LAPACKE_dlassq? = load(name: "LAPACKE_dlassq")
    #elseif os(macOS)
    static let dlassq: FunctionTypes.LAPACKE_dlassq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let classq: FunctionTypes.LAPACKE_classq? = load(name: "LAPACKE_classq")
    #elseif os(macOS)
    static let classq: FunctionTypes.LAPACKE_classq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlassq: FunctionTypes.LAPACKE_zlassq? = load(name: "LAPACKE_zlassq")
    #elseif os(macOS)
    static let zlassq: FunctionTypes.LAPACKE_zlassq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaswp: FunctionTypes.LAPACKE_slaswp? = load(name: "LAPACKE_slaswp")
    #elseif os(macOS)
    static let slaswp: FunctionTypes.LAPACKE_slaswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaswp: FunctionTypes.LAPACKE_dlaswp? = load(name: "LAPACKE_dlaswp")
    #elseif os(macOS)
    static let dlaswp: FunctionTypes.LAPACKE_dlaswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claswp: FunctionTypes.LAPACKE_claswp? = load(name: "LAPACKE_claswp")
    #elseif os(macOS)
    static let claswp: FunctionTypes.LAPACKE_claswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaswp: FunctionTypes.LAPACKE_zlaswp? = load(name: "LAPACKE_zlaswp")
    #elseif os(macOS)
    static let zlaswp: FunctionTypes.LAPACKE_zlaswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slatms: FunctionTypes.LAPACKE_slatms? = load(name: "LAPACKE_slatms")
    #elseif os(macOS)
    static let slatms: FunctionTypes.LAPACKE_slatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlatms: FunctionTypes.LAPACKE_dlatms? = load(name: "LAPACKE_dlatms")
    #elseif os(macOS)
    static let dlatms: FunctionTypes.LAPACKE_dlatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clatms: FunctionTypes.LAPACKE_clatms? = load(name: "LAPACKE_clatms")
    #elseif os(macOS)
    static let clatms: FunctionTypes.LAPACKE_clatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlatms: FunctionTypes.LAPACKE_zlatms? = load(name: "LAPACKE_zlatms")
    #elseif os(macOS)
    static let zlatms: FunctionTypes.LAPACKE_zlatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slauum: FunctionTypes.LAPACKE_slauum? = load(name: "LAPACKE_slauum")
    #elseif os(macOS)
    static let slauum: FunctionTypes.LAPACKE_slauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlauum: FunctionTypes.LAPACKE_dlauum? = load(name: "LAPACKE_dlauum")
    #elseif os(macOS)
    static let dlauum: FunctionTypes.LAPACKE_dlauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clauum: FunctionTypes.LAPACKE_clauum? = load(name: "LAPACKE_clauum")
    #elseif os(macOS)
    static let clauum: FunctionTypes.LAPACKE_clauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlauum: FunctionTypes.LAPACKE_zlauum? = load(name: "LAPACKE_zlauum")
    #elseif os(macOS)
    static let zlauum: FunctionTypes.LAPACKE_zlauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopgtr: FunctionTypes.LAPACKE_sopgtr? = load(name: "LAPACKE_sopgtr")
    #elseif os(macOS)
    static let sopgtr: FunctionTypes.LAPACKE_sopgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopgtr: FunctionTypes.LAPACKE_dopgtr? = load(name: "LAPACKE_dopgtr")
    #elseif os(macOS)
    static let dopgtr: FunctionTypes.LAPACKE_dopgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopmtr: FunctionTypes.LAPACKE_sopmtr? = load(name: "LAPACKE_sopmtr")
    #elseif os(macOS)
    static let sopmtr: FunctionTypes.LAPACKE_sopmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopmtr: FunctionTypes.LAPACKE_dopmtr? = load(name: "LAPACKE_dopmtr")
    #elseif os(macOS)
    static let dopmtr: FunctionTypes.LAPACKE_dopmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgbr: FunctionTypes.LAPACKE_sorgbr? = load(name: "LAPACKE_sorgbr")
    #elseif os(macOS)
    static let sorgbr: FunctionTypes.LAPACKE_sorgbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgbr: FunctionTypes.LAPACKE_dorgbr? = load(name: "LAPACKE_dorgbr")
    #elseif os(macOS)
    static let dorgbr: FunctionTypes.LAPACKE_dorgbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorghr: FunctionTypes.LAPACKE_sorghr? = load(name: "LAPACKE_sorghr")
    #elseif os(macOS)
    static let sorghr: FunctionTypes.LAPACKE_sorghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorghr: FunctionTypes.LAPACKE_dorghr? = load(name: "LAPACKE_dorghr")
    #elseif os(macOS)
    static let dorghr: FunctionTypes.LAPACKE_dorghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorglq: FunctionTypes.LAPACKE_sorglq? = load(name: "LAPACKE_sorglq")
    #elseif os(macOS)
    static let sorglq: FunctionTypes.LAPACKE_sorglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorglq: FunctionTypes.LAPACKE_dorglq? = load(name: "LAPACKE_dorglq")
    #elseif os(macOS)
    static let dorglq: FunctionTypes.LAPACKE_dorglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgql: FunctionTypes.LAPACKE_sorgql? = load(name: "LAPACKE_sorgql")
    #elseif os(macOS)
    static let sorgql: FunctionTypes.LAPACKE_sorgql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgql: FunctionTypes.LAPACKE_dorgql? = load(name: "LAPACKE_dorgql")
    #elseif os(macOS)
    static let dorgql: FunctionTypes.LAPACKE_dorgql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgqr: FunctionTypes.LAPACKE_sorgqr? = load(name: "LAPACKE_sorgqr")
    #elseif os(macOS)
    static let sorgqr: FunctionTypes.LAPACKE_sorgqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgqr: FunctionTypes.LAPACKE_dorgqr? = load(name: "LAPACKE_dorgqr")
    #elseif os(macOS)
    static let dorgqr: FunctionTypes.LAPACKE_dorgqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgrq: FunctionTypes.LAPACKE_sorgrq? = load(name: "LAPACKE_sorgrq")
    #elseif os(macOS)
    static let sorgrq: FunctionTypes.LAPACKE_sorgrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgrq: FunctionTypes.LAPACKE_dorgrq? = load(name: "LAPACKE_dorgrq")
    #elseif os(macOS)
    static let dorgrq: FunctionTypes.LAPACKE_dorgrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtr: FunctionTypes.LAPACKE_sorgtr? = load(name: "LAPACKE_sorgtr")
    #elseif os(macOS)
    static let sorgtr: FunctionTypes.LAPACKE_sorgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtr: FunctionTypes.LAPACKE_dorgtr? = load(name: "LAPACKE_dorgtr")
    #elseif os(macOS)
    static let dorgtr: FunctionTypes.LAPACKE_dorgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtsqr_row: FunctionTypes.LAPACKE_sorgtsqr_row? = load(name: "LAPACKE_sorgtsqr_row")
    #elseif os(macOS)
    static let sorgtsqr_row: FunctionTypes.LAPACKE_sorgtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtsqr_row: FunctionTypes.LAPACKE_dorgtsqr_row? = load(name: "LAPACKE_dorgtsqr_row")
    #elseif os(macOS)
    static let dorgtsqr_row: FunctionTypes.LAPACKE_dorgtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormbr: FunctionTypes.LAPACKE_sormbr? = load(name: "LAPACKE_sormbr")
    #elseif os(macOS)
    static let sormbr: FunctionTypes.LAPACKE_sormbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormbr: FunctionTypes.LAPACKE_dormbr? = load(name: "LAPACKE_dormbr")
    #elseif os(macOS)
    static let dormbr: FunctionTypes.LAPACKE_dormbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormhr: FunctionTypes.LAPACKE_sormhr? = load(name: "LAPACKE_sormhr")
    #elseif os(macOS)
    static let sormhr: FunctionTypes.LAPACKE_sormhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormhr: FunctionTypes.LAPACKE_dormhr? = load(name: "LAPACKE_dormhr")
    #elseif os(macOS)
    static let dormhr: FunctionTypes.LAPACKE_dormhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormlq: FunctionTypes.LAPACKE_sormlq? = load(name: "LAPACKE_sormlq")
    #elseif os(macOS)
    static let sormlq: FunctionTypes.LAPACKE_sormlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormlq: FunctionTypes.LAPACKE_dormlq? = load(name: "LAPACKE_dormlq")
    #elseif os(macOS)
    static let dormlq: FunctionTypes.LAPACKE_dormlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormql: FunctionTypes.LAPACKE_sormql? = load(name: "LAPACKE_sormql")
    #elseif os(macOS)
    static let sormql: FunctionTypes.LAPACKE_sormql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormql: FunctionTypes.LAPACKE_dormql? = load(name: "LAPACKE_dormql")
    #elseif os(macOS)
    static let dormql: FunctionTypes.LAPACKE_dormql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormqr: FunctionTypes.LAPACKE_sormqr? = load(name: "LAPACKE_sormqr")
    #elseif os(macOS)
    static let sormqr: FunctionTypes.LAPACKE_sormqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormqr: FunctionTypes.LAPACKE_dormqr? = load(name: "LAPACKE_dormqr")
    #elseif os(macOS)
    static let dormqr: FunctionTypes.LAPACKE_dormqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrq: FunctionTypes.LAPACKE_sormrq? = load(name: "LAPACKE_sormrq")
    #elseif os(macOS)
    static let sormrq: FunctionTypes.LAPACKE_sormrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrq: FunctionTypes.LAPACKE_dormrq? = load(name: "LAPACKE_dormrq")
    #elseif os(macOS)
    static let dormrq: FunctionTypes.LAPACKE_dormrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrz: FunctionTypes.LAPACKE_sormrz? = load(name: "LAPACKE_sormrz")
    #elseif os(macOS)
    static let sormrz: FunctionTypes.LAPACKE_sormrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrz: FunctionTypes.LAPACKE_dormrz? = load(name: "LAPACKE_dormrz")
    #elseif os(macOS)
    static let dormrz: FunctionTypes.LAPACKE_dormrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormtr: FunctionTypes.LAPACKE_sormtr? = load(name: "LAPACKE_sormtr")
    #elseif os(macOS)
    static let sormtr: FunctionTypes.LAPACKE_sormtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormtr: FunctionTypes.LAPACKE_dormtr? = load(name: "LAPACKE_dormtr")
    #elseif os(macOS)
    static let dormtr: FunctionTypes.LAPACKE_dormtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbcon: FunctionTypes.LAPACKE_spbcon? = load(name: "LAPACKE_spbcon")
    #elseif os(macOS)
    static let spbcon: FunctionTypes.LAPACKE_spbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbcon: FunctionTypes.LAPACKE_dpbcon? = load(name: "LAPACKE_dpbcon")
    #elseif os(macOS)
    static let dpbcon: FunctionTypes.LAPACKE_dpbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbcon: FunctionTypes.LAPACKE_cpbcon? = load(name: "LAPACKE_cpbcon")
    #elseif os(macOS)
    static let cpbcon: FunctionTypes.LAPACKE_cpbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbcon: FunctionTypes.LAPACKE_zpbcon? = load(name: "LAPACKE_zpbcon")
    #elseif os(macOS)
    static let zpbcon: FunctionTypes.LAPACKE_zpbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbequ: FunctionTypes.LAPACKE_spbequ? = load(name: "LAPACKE_spbequ")
    #elseif os(macOS)
    static let spbequ: FunctionTypes.LAPACKE_spbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbequ: FunctionTypes.LAPACKE_dpbequ? = load(name: "LAPACKE_dpbequ")
    #elseif os(macOS)
    static let dpbequ: FunctionTypes.LAPACKE_dpbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbequ: FunctionTypes.LAPACKE_cpbequ? = load(name: "LAPACKE_cpbequ")
    #elseif os(macOS)
    static let cpbequ: FunctionTypes.LAPACKE_cpbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbequ: FunctionTypes.LAPACKE_zpbequ? = load(name: "LAPACKE_zpbequ")
    #elseif os(macOS)
    static let zpbequ: FunctionTypes.LAPACKE_zpbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbrfs: FunctionTypes.LAPACKE_spbrfs? = load(name: "LAPACKE_spbrfs")
    #elseif os(macOS)
    static let spbrfs: FunctionTypes.LAPACKE_spbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbrfs: FunctionTypes.LAPACKE_dpbrfs? = load(name: "LAPACKE_dpbrfs")
    #elseif os(macOS)
    static let dpbrfs: FunctionTypes.LAPACKE_dpbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbrfs: FunctionTypes.LAPACKE_cpbrfs? = load(name: "LAPACKE_cpbrfs")
    #elseif os(macOS)
    static let cpbrfs: FunctionTypes.LAPACKE_cpbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbrfs: FunctionTypes.LAPACKE_zpbrfs? = load(name: "LAPACKE_zpbrfs")
    #elseif os(macOS)
    static let zpbrfs: FunctionTypes.LAPACKE_zpbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbstf: FunctionTypes.LAPACKE_spbstf? = load(name: "LAPACKE_spbstf")
    #elseif os(macOS)
    static let spbstf: FunctionTypes.LAPACKE_spbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbstf: FunctionTypes.LAPACKE_dpbstf? = load(name: "LAPACKE_dpbstf")
    #elseif os(macOS)
    static let dpbstf: FunctionTypes.LAPACKE_dpbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbstf: FunctionTypes.LAPACKE_cpbstf? = load(name: "LAPACKE_cpbstf")
    #elseif os(macOS)
    static let cpbstf: FunctionTypes.LAPACKE_cpbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbstf: FunctionTypes.LAPACKE_zpbstf? = load(name: "LAPACKE_zpbstf")
    #elseif os(macOS)
    static let zpbstf: FunctionTypes.LAPACKE_zpbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsv: FunctionTypes.LAPACKE_spbsv? = load(name: "LAPACKE_spbsv")
    #elseif os(macOS)
    static let spbsv: FunctionTypes.LAPACKE_spbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsv: FunctionTypes.LAPACKE_dpbsv? = load(name: "LAPACKE_dpbsv")
    #elseif os(macOS)
    static let dpbsv: FunctionTypes.LAPACKE_dpbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsv: FunctionTypes.LAPACKE_cpbsv? = load(name: "LAPACKE_cpbsv")
    #elseif os(macOS)
    static let cpbsv: FunctionTypes.LAPACKE_cpbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsv: FunctionTypes.LAPACKE_zpbsv? = load(name: "LAPACKE_zpbsv")
    #elseif os(macOS)
    static let zpbsv: FunctionTypes.LAPACKE_zpbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsvx: FunctionTypes.LAPACKE_spbsvx? = load(name: "LAPACKE_spbsvx")
    #elseif os(macOS)
    static let spbsvx: FunctionTypes.LAPACKE_spbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsvx: FunctionTypes.LAPACKE_dpbsvx? = load(name: "LAPACKE_dpbsvx")
    #elseif os(macOS)
    static let dpbsvx: FunctionTypes.LAPACKE_dpbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsvx: FunctionTypes.LAPACKE_cpbsvx? = load(name: "LAPACKE_cpbsvx")
    #elseif os(macOS)
    static let cpbsvx: FunctionTypes.LAPACKE_cpbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsvx: FunctionTypes.LAPACKE_zpbsvx? = load(name: "LAPACKE_zpbsvx")
    #elseif os(macOS)
    static let zpbsvx: FunctionTypes.LAPACKE_zpbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrf: FunctionTypes.LAPACKE_spbtrf? = load(name: "LAPACKE_spbtrf")
    #elseif os(macOS)
    static let spbtrf: FunctionTypes.LAPACKE_spbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrf: FunctionTypes.LAPACKE_dpbtrf? = load(name: "LAPACKE_dpbtrf")
    #elseif os(macOS)
    static let dpbtrf: FunctionTypes.LAPACKE_dpbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrf: FunctionTypes.LAPACKE_cpbtrf? = load(name: "LAPACKE_cpbtrf")
    #elseif os(macOS)
    static let cpbtrf: FunctionTypes.LAPACKE_cpbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrf: FunctionTypes.LAPACKE_zpbtrf? = load(name: "LAPACKE_zpbtrf")
    #elseif os(macOS)
    static let zpbtrf: FunctionTypes.LAPACKE_zpbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrs: FunctionTypes.LAPACKE_spbtrs? = load(name: "LAPACKE_spbtrs")
    #elseif os(macOS)
    static let spbtrs: FunctionTypes.LAPACKE_spbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrs: FunctionTypes.LAPACKE_dpbtrs? = load(name: "LAPACKE_dpbtrs")
    #elseif os(macOS)
    static let dpbtrs: FunctionTypes.LAPACKE_dpbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrs: FunctionTypes.LAPACKE_cpbtrs? = load(name: "LAPACKE_cpbtrs")
    #elseif os(macOS)
    static let cpbtrs: FunctionTypes.LAPACKE_cpbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrs: FunctionTypes.LAPACKE_zpbtrs? = load(name: "LAPACKE_zpbtrs")
    #elseif os(macOS)
    static let zpbtrs: FunctionTypes.LAPACKE_zpbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrf: FunctionTypes.LAPACKE_spftrf? = load(name: "LAPACKE_spftrf")
    #elseif os(macOS)
    static let spftrf: FunctionTypes.LAPACKE_spftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrf: FunctionTypes.LAPACKE_dpftrf? = load(name: "LAPACKE_dpftrf")
    #elseif os(macOS)
    static let dpftrf: FunctionTypes.LAPACKE_dpftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrf: FunctionTypes.LAPACKE_cpftrf? = load(name: "LAPACKE_cpftrf")
    #elseif os(macOS)
    static let cpftrf: FunctionTypes.LAPACKE_cpftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrf: FunctionTypes.LAPACKE_zpftrf? = load(name: "LAPACKE_zpftrf")
    #elseif os(macOS)
    static let zpftrf: FunctionTypes.LAPACKE_zpftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftri: FunctionTypes.LAPACKE_spftri? = load(name: "LAPACKE_spftri")
    #elseif os(macOS)
    static let spftri: FunctionTypes.LAPACKE_spftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftri: FunctionTypes.LAPACKE_dpftri? = load(name: "LAPACKE_dpftri")
    #elseif os(macOS)
    static let dpftri: FunctionTypes.LAPACKE_dpftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftri: FunctionTypes.LAPACKE_cpftri? = load(name: "LAPACKE_cpftri")
    #elseif os(macOS)
    static let cpftri: FunctionTypes.LAPACKE_cpftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftri: FunctionTypes.LAPACKE_zpftri? = load(name: "LAPACKE_zpftri")
    #elseif os(macOS)
    static let zpftri: FunctionTypes.LAPACKE_zpftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrs: FunctionTypes.LAPACKE_spftrs? = load(name: "LAPACKE_spftrs")
    #elseif os(macOS)
    static let spftrs: FunctionTypes.LAPACKE_spftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrs: FunctionTypes.LAPACKE_dpftrs? = load(name: "LAPACKE_dpftrs")
    #elseif os(macOS)
    static let dpftrs: FunctionTypes.LAPACKE_dpftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrs: FunctionTypes.LAPACKE_cpftrs? = load(name: "LAPACKE_cpftrs")
    #elseif os(macOS)
    static let cpftrs: FunctionTypes.LAPACKE_cpftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrs: FunctionTypes.LAPACKE_zpftrs? = load(name: "LAPACKE_zpftrs")
    #elseif os(macOS)
    static let zpftrs: FunctionTypes.LAPACKE_zpftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spocon: FunctionTypes.LAPACKE_spocon? = load(name: "LAPACKE_spocon")
    #elseif os(macOS)
    static let spocon: FunctionTypes.LAPACKE_spocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpocon: FunctionTypes.LAPACKE_dpocon? = load(name: "LAPACKE_dpocon")
    #elseif os(macOS)
    static let dpocon: FunctionTypes.LAPACKE_dpocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpocon: FunctionTypes.LAPACKE_cpocon? = load(name: "LAPACKE_cpocon")
    #elseif os(macOS)
    static let cpocon: FunctionTypes.LAPACKE_cpocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpocon: FunctionTypes.LAPACKE_zpocon? = load(name: "LAPACKE_zpocon")
    #elseif os(macOS)
    static let zpocon: FunctionTypes.LAPACKE_zpocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequ: FunctionTypes.LAPACKE_spoequ? = load(name: "LAPACKE_spoequ")
    #elseif os(macOS)
    static let spoequ: FunctionTypes.LAPACKE_spoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequ: FunctionTypes.LAPACKE_dpoequ? = load(name: "LAPACKE_dpoequ")
    #elseif os(macOS)
    static let dpoequ: FunctionTypes.LAPACKE_dpoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequ: FunctionTypes.LAPACKE_cpoequ? = load(name: "LAPACKE_cpoequ")
    #elseif os(macOS)
    static let cpoequ: FunctionTypes.LAPACKE_cpoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequ: FunctionTypes.LAPACKE_zpoequ? = load(name: "LAPACKE_zpoequ")
    #elseif os(macOS)
    static let zpoequ: FunctionTypes.LAPACKE_zpoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequb: FunctionTypes.LAPACKE_spoequb? = load(name: "LAPACKE_spoequb")
    #elseif os(macOS)
    static let spoequb: FunctionTypes.LAPACKE_spoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequb: FunctionTypes.LAPACKE_dpoequb? = load(name: "LAPACKE_dpoequb")
    #elseif os(macOS)
    static let dpoequb: FunctionTypes.LAPACKE_dpoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequb: FunctionTypes.LAPACKE_cpoequb? = load(name: "LAPACKE_cpoequb")
    #elseif os(macOS)
    static let cpoequb: FunctionTypes.LAPACKE_cpoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequb: FunctionTypes.LAPACKE_zpoequb? = load(name: "LAPACKE_zpoequb")
    #elseif os(macOS)
    static let zpoequb: FunctionTypes.LAPACKE_zpoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfs: FunctionTypes.LAPACKE_sporfs? = load(name: "LAPACKE_sporfs")
    #elseif os(macOS)
    static let sporfs: FunctionTypes.LAPACKE_sporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfs: FunctionTypes.LAPACKE_dporfs? = load(name: "LAPACKE_dporfs")
    #elseif os(macOS)
    static let dporfs: FunctionTypes.LAPACKE_dporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfs: FunctionTypes.LAPACKE_cporfs? = load(name: "LAPACKE_cporfs")
    #elseif os(macOS)
    static let cporfs: FunctionTypes.LAPACKE_cporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfs: FunctionTypes.LAPACKE_zporfs? = load(name: "LAPACKE_zporfs")
    #elseif os(macOS)
    static let zporfs: FunctionTypes.LAPACKE_zporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfsx: FunctionTypes.LAPACKE_sporfsx? = load(name: "LAPACKE_sporfsx")
    #elseif os(macOS)
    static let sporfsx: FunctionTypes.LAPACKE_sporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfsx: FunctionTypes.LAPACKE_dporfsx? = load(name: "LAPACKE_dporfsx")
    #elseif os(macOS)
    static let dporfsx: FunctionTypes.LAPACKE_dporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfsx: FunctionTypes.LAPACKE_cporfsx? = load(name: "LAPACKE_cporfsx")
    #elseif os(macOS)
    static let cporfsx: FunctionTypes.LAPACKE_cporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfsx: FunctionTypes.LAPACKE_zporfsx? = load(name: "LAPACKE_zporfsx")
    #elseif os(macOS)
    static let zporfsx: FunctionTypes.LAPACKE_zporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposv: FunctionTypes.LAPACKE_sposv? = load(name: "LAPACKE_sposv")
    #elseif os(macOS)
    static let sposv: FunctionTypes.LAPACKE_sposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposv: FunctionTypes.LAPACKE_dposv? = load(name: "LAPACKE_dposv")
    #elseif os(macOS)
    static let dposv: FunctionTypes.LAPACKE_dposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposv: FunctionTypes.LAPACKE_cposv? = load(name: "LAPACKE_cposv")
    #elseif os(macOS)
    static let cposv: FunctionTypes.LAPACKE_cposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposv: FunctionTypes.LAPACKE_zposv? = load(name: "LAPACKE_zposv")
    #elseif os(macOS)
    static let zposv: FunctionTypes.LAPACKE_zposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsposv: FunctionTypes.LAPACKE_dsposv? = load(name: "LAPACKE_dsposv")
    #elseif os(macOS)
    static let dsposv: FunctionTypes.LAPACKE_dsposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcposv: FunctionTypes.LAPACKE_zcposv? = load(name: "LAPACKE_zcposv")
    #elseif os(macOS)
    static let zcposv: FunctionTypes.LAPACKE_zcposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvx: FunctionTypes.LAPACKE_sposvx? = load(name: "LAPACKE_sposvx")
    #elseif os(macOS)
    static let sposvx: FunctionTypes.LAPACKE_sposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvx: FunctionTypes.LAPACKE_dposvx? = load(name: "LAPACKE_dposvx")
    #elseif os(macOS)
    static let dposvx: FunctionTypes.LAPACKE_dposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvx: FunctionTypes.LAPACKE_cposvx? = load(name: "LAPACKE_cposvx")
    #elseif os(macOS)
    static let cposvx: FunctionTypes.LAPACKE_cposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvx: FunctionTypes.LAPACKE_zposvx? = load(name: "LAPACKE_zposvx")
    #elseif os(macOS)
    static let zposvx: FunctionTypes.LAPACKE_zposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvxx: FunctionTypes.LAPACKE_sposvxx? = load(name: "LAPACKE_sposvxx")
    #elseif os(macOS)
    static let sposvxx: FunctionTypes.LAPACKE_sposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvxx: FunctionTypes.LAPACKE_dposvxx? = load(name: "LAPACKE_dposvxx")
    #elseif os(macOS)
    static let dposvxx: FunctionTypes.LAPACKE_dposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvxx: FunctionTypes.LAPACKE_cposvxx? = load(name: "LAPACKE_cposvxx")
    #elseif os(macOS)
    static let cposvxx: FunctionTypes.LAPACKE_cposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvxx: FunctionTypes.LAPACKE_zposvxx? = load(name: "LAPACKE_zposvxx")
    #elseif os(macOS)
    static let zposvxx: FunctionTypes.LAPACKE_zposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf2: FunctionTypes.LAPACKE_spotrf2? = load(name: "LAPACKE_spotrf2")
    #elseif os(macOS)
    static let spotrf2: FunctionTypes.LAPACKE_spotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf2: FunctionTypes.LAPACKE_dpotrf2? = load(name: "LAPACKE_dpotrf2")
    #elseif os(macOS)
    static let dpotrf2: FunctionTypes.LAPACKE_dpotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf2: FunctionTypes.LAPACKE_cpotrf2? = load(name: "LAPACKE_cpotrf2")
    #elseif os(macOS)
    static let cpotrf2: FunctionTypes.LAPACKE_cpotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf2: FunctionTypes.LAPACKE_zpotrf2? = load(name: "LAPACKE_zpotrf2")
    #elseif os(macOS)
    static let zpotrf2: FunctionTypes.LAPACKE_zpotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf: FunctionTypes.LAPACKE_spotrf? = load(name: "LAPACKE_spotrf")
    #elseif os(macOS)
    static let spotrf: FunctionTypes.LAPACKE_spotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf: FunctionTypes.LAPACKE_dpotrf? = load(name: "LAPACKE_dpotrf")
    #elseif os(macOS)
    static let dpotrf: FunctionTypes.LAPACKE_dpotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf: FunctionTypes.LAPACKE_cpotrf? = load(name: "LAPACKE_cpotrf")
    #elseif os(macOS)
    static let cpotrf: FunctionTypes.LAPACKE_cpotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf: FunctionTypes.LAPACKE_zpotrf? = load(name: "LAPACKE_zpotrf")
    #elseif os(macOS)
    static let zpotrf: FunctionTypes.LAPACKE_zpotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotri: FunctionTypes.LAPACKE_spotri? = load(name: "LAPACKE_spotri")
    #elseif os(macOS)
    static let spotri: FunctionTypes.LAPACKE_spotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotri: FunctionTypes.LAPACKE_dpotri? = load(name: "LAPACKE_dpotri")
    #elseif os(macOS)
    static let dpotri: FunctionTypes.LAPACKE_dpotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotri: FunctionTypes.LAPACKE_cpotri? = load(name: "LAPACKE_cpotri")
    #elseif os(macOS)
    static let cpotri: FunctionTypes.LAPACKE_cpotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotri: FunctionTypes.LAPACKE_zpotri? = load(name: "LAPACKE_zpotri")
    #elseif os(macOS)
    static let zpotri: FunctionTypes.LAPACKE_zpotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrs: FunctionTypes.LAPACKE_spotrs? = load(name: "LAPACKE_spotrs")
    #elseif os(macOS)
    static let spotrs: FunctionTypes.LAPACKE_spotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrs: FunctionTypes.LAPACKE_dpotrs? = load(name: "LAPACKE_dpotrs")
    #elseif os(macOS)
    static let dpotrs: FunctionTypes.LAPACKE_dpotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrs: FunctionTypes.LAPACKE_cpotrs? = load(name: "LAPACKE_cpotrs")
    #elseif os(macOS)
    static let cpotrs: FunctionTypes.LAPACKE_cpotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrs: FunctionTypes.LAPACKE_zpotrs? = load(name: "LAPACKE_zpotrs")
    #elseif os(macOS)
    static let zpotrs: FunctionTypes.LAPACKE_zpotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppcon: FunctionTypes.LAPACKE_sppcon? = load(name: "LAPACKE_sppcon")
    #elseif os(macOS)
    static let sppcon: FunctionTypes.LAPACKE_sppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppcon: FunctionTypes.LAPACKE_dppcon? = load(name: "LAPACKE_dppcon")
    #elseif os(macOS)
    static let dppcon: FunctionTypes.LAPACKE_dppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppcon: FunctionTypes.LAPACKE_cppcon? = load(name: "LAPACKE_cppcon")
    #elseif os(macOS)
    static let cppcon: FunctionTypes.LAPACKE_cppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppcon: FunctionTypes.LAPACKE_zppcon? = load(name: "LAPACKE_zppcon")
    #elseif os(macOS)
    static let zppcon: FunctionTypes.LAPACKE_zppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppequ: FunctionTypes.LAPACKE_sppequ? = load(name: "LAPACKE_sppequ")
    #elseif os(macOS)
    static let sppequ: FunctionTypes.LAPACKE_sppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppequ: FunctionTypes.LAPACKE_dppequ? = load(name: "LAPACKE_dppequ")
    #elseif os(macOS)
    static let dppequ: FunctionTypes.LAPACKE_dppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppequ: FunctionTypes.LAPACKE_cppequ? = load(name: "LAPACKE_cppequ")
    #elseif os(macOS)
    static let cppequ: FunctionTypes.LAPACKE_cppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppequ: FunctionTypes.LAPACKE_zppequ? = load(name: "LAPACKE_zppequ")
    #elseif os(macOS)
    static let zppequ: FunctionTypes.LAPACKE_zppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spprfs: FunctionTypes.LAPACKE_spprfs? = load(name: "LAPACKE_spprfs")
    #elseif os(macOS)
    static let spprfs: FunctionTypes.LAPACKE_spprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpprfs: FunctionTypes.LAPACKE_dpprfs? = load(name: "LAPACKE_dpprfs")
    #elseif os(macOS)
    static let dpprfs: FunctionTypes.LAPACKE_dpprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpprfs: FunctionTypes.LAPACKE_cpprfs? = load(name: "LAPACKE_cpprfs")
    #elseif os(macOS)
    static let cpprfs: FunctionTypes.LAPACKE_cpprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpprfs: FunctionTypes.LAPACKE_zpprfs? = load(name: "LAPACKE_zpprfs")
    #elseif os(macOS)
    static let zpprfs: FunctionTypes.LAPACKE_zpprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsv: FunctionTypes.LAPACKE_sppsv? = load(name: "LAPACKE_sppsv")
    #elseif os(macOS)
    static let sppsv: FunctionTypes.LAPACKE_sppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsv: FunctionTypes.LAPACKE_dppsv? = load(name: "LAPACKE_dppsv")
    #elseif os(macOS)
    static let dppsv: FunctionTypes.LAPACKE_dppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsv: FunctionTypes.LAPACKE_cppsv? = load(name: "LAPACKE_cppsv")
    #elseif os(macOS)
    static let cppsv: FunctionTypes.LAPACKE_cppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsv: FunctionTypes.LAPACKE_zppsv? = load(name: "LAPACKE_zppsv")
    #elseif os(macOS)
    static let zppsv: FunctionTypes.LAPACKE_zppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsvx: FunctionTypes.LAPACKE_sppsvx? = load(name: "LAPACKE_sppsvx")
    #elseif os(macOS)
    static let sppsvx: FunctionTypes.LAPACKE_sppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsvx: FunctionTypes.LAPACKE_dppsvx? = load(name: "LAPACKE_dppsvx")
    #elseif os(macOS)
    static let dppsvx: FunctionTypes.LAPACKE_dppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsvx: FunctionTypes.LAPACKE_cppsvx? = load(name: "LAPACKE_cppsvx")
    #elseif os(macOS)
    static let cppsvx: FunctionTypes.LAPACKE_cppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsvx: FunctionTypes.LAPACKE_zppsvx? = load(name: "LAPACKE_zppsvx")
    #elseif os(macOS)
    static let zppsvx: FunctionTypes.LAPACKE_zppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrf: FunctionTypes.LAPACKE_spptrf? = load(name: "LAPACKE_spptrf")
    #elseif os(macOS)
    static let spptrf: FunctionTypes.LAPACKE_spptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrf: FunctionTypes.LAPACKE_dpptrf? = load(name: "LAPACKE_dpptrf")
    #elseif os(macOS)
    static let dpptrf: FunctionTypes.LAPACKE_dpptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrf: FunctionTypes.LAPACKE_cpptrf? = load(name: "LAPACKE_cpptrf")
    #elseif os(macOS)
    static let cpptrf: FunctionTypes.LAPACKE_cpptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrf: FunctionTypes.LAPACKE_zpptrf? = load(name: "LAPACKE_zpptrf")
    #elseif os(macOS)
    static let zpptrf: FunctionTypes.LAPACKE_zpptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptri: FunctionTypes.LAPACKE_spptri? = load(name: "LAPACKE_spptri")
    #elseif os(macOS)
    static let spptri: FunctionTypes.LAPACKE_spptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptri: FunctionTypes.LAPACKE_dpptri? = load(name: "LAPACKE_dpptri")
    #elseif os(macOS)
    static let dpptri: FunctionTypes.LAPACKE_dpptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptri: FunctionTypes.LAPACKE_cpptri? = load(name: "LAPACKE_cpptri")
    #elseif os(macOS)
    static let cpptri: FunctionTypes.LAPACKE_cpptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptri: FunctionTypes.LAPACKE_zpptri? = load(name: "LAPACKE_zpptri")
    #elseif os(macOS)
    static let zpptri: FunctionTypes.LAPACKE_zpptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrs: FunctionTypes.LAPACKE_spptrs? = load(name: "LAPACKE_spptrs")
    #elseif os(macOS)
    static let spptrs: FunctionTypes.LAPACKE_spptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrs: FunctionTypes.LAPACKE_dpptrs? = load(name: "LAPACKE_dpptrs")
    #elseif os(macOS)
    static let dpptrs: FunctionTypes.LAPACKE_dpptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrs: FunctionTypes.LAPACKE_cpptrs? = load(name: "LAPACKE_cpptrs")
    #elseif os(macOS)
    static let cpptrs: FunctionTypes.LAPACKE_cpptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrs: FunctionTypes.LAPACKE_zpptrs? = load(name: "LAPACKE_zpptrs")
    #elseif os(macOS)
    static let zpptrs: FunctionTypes.LAPACKE_zpptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spstrf: FunctionTypes.LAPACKE_spstrf? = load(name: "LAPACKE_spstrf")
    #elseif os(macOS)
    static let spstrf: FunctionTypes.LAPACKE_spstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpstrf: FunctionTypes.LAPACKE_dpstrf? = load(name: "LAPACKE_dpstrf")
    #elseif os(macOS)
    static let dpstrf: FunctionTypes.LAPACKE_dpstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpstrf: FunctionTypes.LAPACKE_cpstrf? = load(name: "LAPACKE_cpstrf")
    #elseif os(macOS)
    static let cpstrf: FunctionTypes.LAPACKE_cpstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpstrf: FunctionTypes.LAPACKE_zpstrf? = load(name: "LAPACKE_zpstrf")
    #elseif os(macOS)
    static let zpstrf: FunctionTypes.LAPACKE_zpstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptcon: FunctionTypes.LAPACKE_sptcon? = load(name: "LAPACKE_sptcon")
    #elseif os(macOS)
    static let sptcon: FunctionTypes.LAPACKE_sptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptcon: FunctionTypes.LAPACKE_dptcon? = load(name: "LAPACKE_dptcon")
    #elseif os(macOS)
    static let dptcon: FunctionTypes.LAPACKE_dptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptcon: FunctionTypes.LAPACKE_cptcon? = load(name: "LAPACKE_cptcon")
    #elseif os(macOS)
    static let cptcon: FunctionTypes.LAPACKE_cptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptcon: FunctionTypes.LAPACKE_zptcon? = load(name: "LAPACKE_zptcon")
    #elseif os(macOS)
    static let zptcon: FunctionTypes.LAPACKE_zptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spteqr: FunctionTypes.LAPACKE_spteqr? = load(name: "LAPACKE_spteqr")
    #elseif os(macOS)
    static let spteqr: FunctionTypes.LAPACKE_spteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpteqr: FunctionTypes.LAPACKE_dpteqr? = load(name: "LAPACKE_dpteqr")
    #elseif os(macOS)
    static let dpteqr: FunctionTypes.LAPACKE_dpteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpteqr: FunctionTypes.LAPACKE_cpteqr? = load(name: "LAPACKE_cpteqr")
    #elseif os(macOS)
    static let cpteqr: FunctionTypes.LAPACKE_cpteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpteqr: FunctionTypes.LAPACKE_zpteqr? = load(name: "LAPACKE_zpteqr")
    #elseif os(macOS)
    static let zpteqr: FunctionTypes.LAPACKE_zpteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptrfs: FunctionTypes.LAPACKE_sptrfs? = load(name: "LAPACKE_sptrfs")
    #elseif os(macOS)
    static let sptrfs: FunctionTypes.LAPACKE_sptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptrfs: FunctionTypes.LAPACKE_dptrfs? = load(name: "LAPACKE_dptrfs")
    #elseif os(macOS)
    static let dptrfs: FunctionTypes.LAPACKE_dptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptrfs: FunctionTypes.LAPACKE_cptrfs? = load(name: "LAPACKE_cptrfs")
    #elseif os(macOS)
    static let cptrfs: FunctionTypes.LAPACKE_cptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptrfs: FunctionTypes.LAPACKE_zptrfs? = load(name: "LAPACKE_zptrfs")
    #elseif os(macOS)
    static let zptrfs: FunctionTypes.LAPACKE_zptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsv: FunctionTypes.LAPACKE_sptsv? = load(name: "LAPACKE_sptsv")
    #elseif os(macOS)
    static let sptsv: FunctionTypes.LAPACKE_sptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsv: FunctionTypes.LAPACKE_dptsv? = load(name: "LAPACKE_dptsv")
    #elseif os(macOS)
    static let dptsv: FunctionTypes.LAPACKE_dptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsv: FunctionTypes.LAPACKE_cptsv? = load(name: "LAPACKE_cptsv")
    #elseif os(macOS)
    static let cptsv: FunctionTypes.LAPACKE_cptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsv: FunctionTypes.LAPACKE_zptsv? = load(name: "LAPACKE_zptsv")
    #elseif os(macOS)
    static let zptsv: FunctionTypes.LAPACKE_zptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsvx: FunctionTypes.LAPACKE_sptsvx? = load(name: "LAPACKE_sptsvx")
    #elseif os(macOS)
    static let sptsvx: FunctionTypes.LAPACKE_sptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsvx: FunctionTypes.LAPACKE_dptsvx? = load(name: "LAPACKE_dptsvx")
    #elseif os(macOS)
    static let dptsvx: FunctionTypes.LAPACKE_dptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsvx: FunctionTypes.LAPACKE_cptsvx? = load(name: "LAPACKE_cptsvx")
    #elseif os(macOS)
    static let cptsvx: FunctionTypes.LAPACKE_cptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsvx: FunctionTypes.LAPACKE_zptsvx? = load(name: "LAPACKE_zptsvx")
    #elseif os(macOS)
    static let zptsvx: FunctionTypes.LAPACKE_zptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrf: FunctionTypes.LAPACKE_spttrf? = load(name: "LAPACKE_spttrf")
    #elseif os(macOS)
    static let spttrf: FunctionTypes.LAPACKE_spttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrf: FunctionTypes.LAPACKE_dpttrf? = load(name: "LAPACKE_dpttrf")
    #elseif os(macOS)
    static let dpttrf: FunctionTypes.LAPACKE_dpttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrf: FunctionTypes.LAPACKE_cpttrf? = load(name: "LAPACKE_cpttrf")
    #elseif os(macOS)
    static let cpttrf: FunctionTypes.LAPACKE_cpttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrf: FunctionTypes.LAPACKE_zpttrf? = load(name: "LAPACKE_zpttrf")
    #elseif os(macOS)
    static let zpttrf: FunctionTypes.LAPACKE_zpttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrs: FunctionTypes.LAPACKE_spttrs? = load(name: "LAPACKE_spttrs")
    #elseif os(macOS)
    static let spttrs: FunctionTypes.LAPACKE_spttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrs: FunctionTypes.LAPACKE_dpttrs? = load(name: "LAPACKE_dpttrs")
    #elseif os(macOS)
    static let dpttrs: FunctionTypes.LAPACKE_dpttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrs: FunctionTypes.LAPACKE_cpttrs? = load(name: "LAPACKE_cpttrs")
    #elseif os(macOS)
    static let cpttrs: FunctionTypes.LAPACKE_cpttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrs: FunctionTypes.LAPACKE_zpttrs? = load(name: "LAPACKE_zpttrs")
    #elseif os(macOS)
    static let zpttrs: FunctionTypes.LAPACKE_zpttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev: FunctionTypes.LAPACKE_ssbev? = load(name: "LAPACKE_ssbev")
    #elseif os(macOS)
    static let ssbev: FunctionTypes.LAPACKE_ssbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev: FunctionTypes.LAPACKE_dsbev? = load(name: "LAPACKE_dsbev")
    #elseif os(macOS)
    static let dsbev: FunctionTypes.LAPACKE_dsbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd: FunctionTypes.LAPACKE_ssbevd? = load(name: "LAPACKE_ssbevd")
    #elseif os(macOS)
    static let ssbevd: FunctionTypes.LAPACKE_ssbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd: FunctionTypes.LAPACKE_dsbevd? = load(name: "LAPACKE_dsbevd")
    #elseif os(macOS)
    static let dsbevd: FunctionTypes.LAPACKE_dsbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx: FunctionTypes.LAPACKE_ssbevx? = load(name: "LAPACKE_ssbevx")
    #elseif os(macOS)
    static let ssbevx: FunctionTypes.LAPACKE_ssbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx: FunctionTypes.LAPACKE_dsbevx? = load(name: "LAPACKE_dsbevx")
    #elseif os(macOS)
    static let dsbevx: FunctionTypes.LAPACKE_dsbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgst: FunctionTypes.LAPACKE_ssbgst? = load(name: "LAPACKE_ssbgst")
    #elseif os(macOS)
    static let ssbgst: FunctionTypes.LAPACKE_ssbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgst: FunctionTypes.LAPACKE_dsbgst? = load(name: "LAPACKE_dsbgst")
    #elseif os(macOS)
    static let dsbgst: FunctionTypes.LAPACKE_dsbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgv: FunctionTypes.LAPACKE_ssbgv? = load(name: "LAPACKE_ssbgv")
    #elseif os(macOS)
    static let ssbgv: FunctionTypes.LAPACKE_ssbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgv: FunctionTypes.LAPACKE_dsbgv? = load(name: "LAPACKE_dsbgv")
    #elseif os(macOS)
    static let dsbgv: FunctionTypes.LAPACKE_dsbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvd: FunctionTypes.LAPACKE_ssbgvd? = load(name: "LAPACKE_ssbgvd")
    #elseif os(macOS)
    static let ssbgvd: FunctionTypes.LAPACKE_ssbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvd: FunctionTypes.LAPACKE_dsbgvd? = load(name: "LAPACKE_dsbgvd")
    #elseif os(macOS)
    static let dsbgvd: FunctionTypes.LAPACKE_dsbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvx: FunctionTypes.LAPACKE_ssbgvx? = load(name: "LAPACKE_ssbgvx")
    #elseif os(macOS)
    static let ssbgvx: FunctionTypes.LAPACKE_ssbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvx: FunctionTypes.LAPACKE_dsbgvx? = load(name: "LAPACKE_dsbgvx")
    #elseif os(macOS)
    static let dsbgvx: FunctionTypes.LAPACKE_dsbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbtrd: FunctionTypes.LAPACKE_ssbtrd? = load(name: "LAPACKE_ssbtrd")
    #elseif os(macOS)
    static let ssbtrd: FunctionTypes.LAPACKE_ssbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbtrd: FunctionTypes.LAPACKE_dsbtrd? = load(name: "LAPACKE_dsbtrd")
    #elseif os(macOS)
    static let dsbtrd: FunctionTypes.LAPACKE_dsbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssfrk: FunctionTypes.LAPACKE_ssfrk? = load(name: "LAPACKE_ssfrk")
    #elseif os(macOS)
    static let ssfrk: FunctionTypes.LAPACKE_ssfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsfrk: FunctionTypes.LAPACKE_dsfrk? = load(name: "LAPACKE_dsfrk")
    #elseif os(macOS)
    static let dsfrk: FunctionTypes.LAPACKE_dsfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspcon: FunctionTypes.LAPACKE_sspcon? = load(name: "LAPACKE_sspcon")
    #elseif os(macOS)
    static let sspcon: FunctionTypes.LAPACKE_sspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspcon: FunctionTypes.LAPACKE_dspcon? = load(name: "LAPACKE_dspcon")
    #elseif os(macOS)
    static let dspcon: FunctionTypes.LAPACKE_dspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspcon: FunctionTypes.LAPACKE_cspcon? = load(name: "LAPACKE_cspcon")
    #elseif os(macOS)
    static let cspcon: FunctionTypes.LAPACKE_cspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspcon: FunctionTypes.LAPACKE_zspcon? = load(name: "LAPACKE_zspcon")
    #elseif os(macOS)
    static let zspcon: FunctionTypes.LAPACKE_zspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspev: FunctionTypes.LAPACKE_sspev? = load(name: "LAPACKE_sspev")
    #elseif os(macOS)
    static let sspev: FunctionTypes.LAPACKE_sspev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspev: FunctionTypes.LAPACKE_dspev? = load(name: "LAPACKE_dspev")
    #elseif os(macOS)
    static let dspev: FunctionTypes.LAPACKE_dspev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevd: FunctionTypes.LAPACKE_sspevd? = load(name: "LAPACKE_sspevd")
    #elseif os(macOS)
    static let sspevd: FunctionTypes.LAPACKE_sspevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevd: FunctionTypes.LAPACKE_dspevd? = load(name: "LAPACKE_dspevd")
    #elseif os(macOS)
    static let dspevd: FunctionTypes.LAPACKE_dspevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevx: FunctionTypes.LAPACKE_sspevx? = load(name: "LAPACKE_sspevx")
    #elseif os(macOS)
    static let sspevx: FunctionTypes.LAPACKE_sspevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevx: FunctionTypes.LAPACKE_dspevx? = load(name: "LAPACKE_dspevx")
    #elseif os(macOS)
    static let dspevx: FunctionTypes.LAPACKE_dspevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgst: FunctionTypes.LAPACKE_sspgst? = load(name: "LAPACKE_sspgst")
    #elseif os(macOS)
    static let sspgst: FunctionTypes.LAPACKE_sspgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgst: FunctionTypes.LAPACKE_dspgst? = load(name: "LAPACKE_dspgst")
    #elseif os(macOS)
    static let dspgst: FunctionTypes.LAPACKE_dspgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgv: FunctionTypes.LAPACKE_sspgv? = load(name: "LAPACKE_sspgv")
    #elseif os(macOS)
    static let sspgv: FunctionTypes.LAPACKE_sspgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgv: FunctionTypes.LAPACKE_dspgv? = load(name: "LAPACKE_dspgv")
    #elseif os(macOS)
    static let dspgv: FunctionTypes.LAPACKE_dspgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvd: FunctionTypes.LAPACKE_sspgvd? = load(name: "LAPACKE_sspgvd")
    #elseif os(macOS)
    static let sspgvd: FunctionTypes.LAPACKE_sspgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvd: FunctionTypes.LAPACKE_dspgvd? = load(name: "LAPACKE_dspgvd")
    #elseif os(macOS)
    static let dspgvd: FunctionTypes.LAPACKE_dspgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvx: FunctionTypes.LAPACKE_sspgvx? = load(name: "LAPACKE_sspgvx")
    #elseif os(macOS)
    static let sspgvx: FunctionTypes.LAPACKE_sspgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvx: FunctionTypes.LAPACKE_dspgvx? = load(name: "LAPACKE_dspgvx")
    #elseif os(macOS)
    static let dspgvx: FunctionTypes.LAPACKE_dspgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssprfs: FunctionTypes.LAPACKE_ssprfs? = load(name: "LAPACKE_ssprfs")
    #elseif os(macOS)
    static let ssprfs: FunctionTypes.LAPACKE_ssprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsprfs: FunctionTypes.LAPACKE_dsprfs? = load(name: "LAPACKE_dsprfs")
    #elseif os(macOS)
    static let dsprfs: FunctionTypes.LAPACKE_dsprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csprfs: FunctionTypes.LAPACKE_csprfs? = load(name: "LAPACKE_csprfs")
    #elseif os(macOS)
    static let csprfs: FunctionTypes.LAPACKE_csprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsprfs: FunctionTypes.LAPACKE_zsprfs? = load(name: "LAPACKE_zsprfs")
    #elseif os(macOS)
    static let zsprfs: FunctionTypes.LAPACKE_zsprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsv: FunctionTypes.LAPACKE_sspsv? = load(name: "LAPACKE_sspsv")
    #elseif os(macOS)
    static let sspsv: FunctionTypes.LAPACKE_sspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsv: FunctionTypes.LAPACKE_dspsv? = load(name: "LAPACKE_dspsv")
    #elseif os(macOS)
    static let dspsv: FunctionTypes.LAPACKE_dspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsv: FunctionTypes.LAPACKE_cspsv? = load(name: "LAPACKE_cspsv")
    #elseif os(macOS)
    static let cspsv: FunctionTypes.LAPACKE_cspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsv: FunctionTypes.LAPACKE_zspsv? = load(name: "LAPACKE_zspsv")
    #elseif os(macOS)
    static let zspsv: FunctionTypes.LAPACKE_zspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsvx: FunctionTypes.LAPACKE_sspsvx? = load(name: "LAPACKE_sspsvx")
    #elseif os(macOS)
    static let sspsvx: FunctionTypes.LAPACKE_sspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsvx: FunctionTypes.LAPACKE_dspsvx? = load(name: "LAPACKE_dspsvx")
    #elseif os(macOS)
    static let dspsvx: FunctionTypes.LAPACKE_dspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsvx: FunctionTypes.LAPACKE_cspsvx? = load(name: "LAPACKE_cspsvx")
    #elseif os(macOS)
    static let cspsvx: FunctionTypes.LAPACKE_cspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsvx: FunctionTypes.LAPACKE_zspsvx? = load(name: "LAPACKE_zspsvx")
    #elseif os(macOS)
    static let zspsvx: FunctionTypes.LAPACKE_zspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrd: FunctionTypes.LAPACKE_ssptrd? = load(name: "LAPACKE_ssptrd")
    #elseif os(macOS)
    static let ssptrd: FunctionTypes.LAPACKE_ssptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrd: FunctionTypes.LAPACKE_dsptrd? = load(name: "LAPACKE_dsptrd")
    #elseif os(macOS)
    static let dsptrd: FunctionTypes.LAPACKE_dsptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrf: FunctionTypes.LAPACKE_ssptrf? = load(name: "LAPACKE_ssptrf")
    #elseif os(macOS)
    static let ssptrf: FunctionTypes.LAPACKE_ssptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrf: FunctionTypes.LAPACKE_dsptrf? = load(name: "LAPACKE_dsptrf")
    #elseif os(macOS)
    static let dsptrf: FunctionTypes.LAPACKE_dsptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrf: FunctionTypes.LAPACKE_csptrf? = load(name: "LAPACKE_csptrf")
    #elseif os(macOS)
    static let csptrf: FunctionTypes.LAPACKE_csptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrf: FunctionTypes.LAPACKE_zsptrf? = load(name: "LAPACKE_zsptrf")
    #elseif os(macOS)
    static let zsptrf: FunctionTypes.LAPACKE_zsptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptri: FunctionTypes.LAPACKE_ssptri? = load(name: "LAPACKE_ssptri")
    #elseif os(macOS)
    static let ssptri: FunctionTypes.LAPACKE_ssptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptri: FunctionTypes.LAPACKE_dsptri? = load(name: "LAPACKE_dsptri")
    #elseif os(macOS)
    static let dsptri: FunctionTypes.LAPACKE_dsptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptri: FunctionTypes.LAPACKE_csptri? = load(name: "LAPACKE_csptri")
    #elseif os(macOS)
    static let csptri: FunctionTypes.LAPACKE_csptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptri: FunctionTypes.LAPACKE_zsptri? = load(name: "LAPACKE_zsptri")
    #elseif os(macOS)
    static let zsptri: FunctionTypes.LAPACKE_zsptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrs: FunctionTypes.LAPACKE_ssptrs? = load(name: "LAPACKE_ssptrs")
    #elseif os(macOS)
    static let ssptrs: FunctionTypes.LAPACKE_ssptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrs: FunctionTypes.LAPACKE_dsptrs? = load(name: "LAPACKE_dsptrs")
    #elseif os(macOS)
    static let dsptrs: FunctionTypes.LAPACKE_dsptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrs: FunctionTypes.LAPACKE_csptrs? = load(name: "LAPACKE_csptrs")
    #elseif os(macOS)
    static let csptrs: FunctionTypes.LAPACKE_csptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrs: FunctionTypes.LAPACKE_zsptrs? = load(name: "LAPACKE_zsptrs")
    #elseif os(macOS)
    static let zsptrs: FunctionTypes.LAPACKE_zsptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstebz: FunctionTypes.LAPACKE_sstebz? = load(name: "LAPACKE_sstebz")
    #elseif os(macOS)
    static let sstebz: FunctionTypes.LAPACKE_sstebz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstebz: FunctionTypes.LAPACKE_dstebz? = load(name: "LAPACKE_dstebz")
    #elseif os(macOS)
    static let dstebz: FunctionTypes.LAPACKE_dstebz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstedc: FunctionTypes.LAPACKE_sstedc? = load(name: "LAPACKE_sstedc")
    #elseif os(macOS)
    static let sstedc: FunctionTypes.LAPACKE_sstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstedc: FunctionTypes.LAPACKE_dstedc? = load(name: "LAPACKE_dstedc")
    #elseif os(macOS)
    static let dstedc: FunctionTypes.LAPACKE_dstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstedc: FunctionTypes.LAPACKE_cstedc? = load(name: "LAPACKE_cstedc")
    #elseif os(macOS)
    static let cstedc: FunctionTypes.LAPACKE_cstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstedc: FunctionTypes.LAPACKE_zstedc? = load(name: "LAPACKE_zstedc")
    #elseif os(macOS)
    static let zstedc: FunctionTypes.LAPACKE_zstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstegr: FunctionTypes.LAPACKE_sstegr? = load(name: "LAPACKE_sstegr")
    #elseif os(macOS)
    static let sstegr: FunctionTypes.LAPACKE_sstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstegr: FunctionTypes.LAPACKE_dstegr? = load(name: "LAPACKE_dstegr")
    #elseif os(macOS)
    static let dstegr: FunctionTypes.LAPACKE_dstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstegr: FunctionTypes.LAPACKE_cstegr? = load(name: "LAPACKE_cstegr")
    #elseif os(macOS)
    static let cstegr: FunctionTypes.LAPACKE_cstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstegr: FunctionTypes.LAPACKE_zstegr? = load(name: "LAPACKE_zstegr")
    #elseif os(macOS)
    static let zstegr: FunctionTypes.LAPACKE_zstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstein: FunctionTypes.LAPACKE_sstein? = load(name: "LAPACKE_sstein")
    #elseif os(macOS)
    static let sstein: FunctionTypes.LAPACKE_sstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstein: FunctionTypes.LAPACKE_dstein? = load(name: "LAPACKE_dstein")
    #elseif os(macOS)
    static let dstein: FunctionTypes.LAPACKE_dstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstein: FunctionTypes.LAPACKE_cstein? = load(name: "LAPACKE_cstein")
    #elseif os(macOS)
    static let cstein: FunctionTypes.LAPACKE_cstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstein: FunctionTypes.LAPACKE_zstein? = load(name: "LAPACKE_zstein")
    #elseif os(macOS)
    static let zstein: FunctionTypes.LAPACKE_zstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstemr: FunctionTypes.LAPACKE_sstemr? = load(name: "LAPACKE_sstemr")
    #elseif os(macOS)
    static let sstemr: FunctionTypes.LAPACKE_sstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstemr: FunctionTypes.LAPACKE_dstemr? = load(name: "LAPACKE_dstemr")
    #elseif os(macOS)
    static let dstemr: FunctionTypes.LAPACKE_dstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstemr: FunctionTypes.LAPACKE_cstemr? = load(name: "LAPACKE_cstemr")
    #elseif os(macOS)
    static let cstemr: FunctionTypes.LAPACKE_cstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstemr: FunctionTypes.LAPACKE_zstemr? = load(name: "LAPACKE_zstemr")
    #elseif os(macOS)
    static let zstemr: FunctionTypes.LAPACKE_zstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssteqr: FunctionTypes.LAPACKE_ssteqr? = load(name: "LAPACKE_ssteqr")
    #elseif os(macOS)
    static let ssteqr: FunctionTypes.LAPACKE_ssteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsteqr: FunctionTypes.LAPACKE_dsteqr? = load(name: "LAPACKE_dsteqr")
    #elseif os(macOS)
    static let dsteqr: FunctionTypes.LAPACKE_dsteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csteqr: FunctionTypes.LAPACKE_csteqr? = load(name: "LAPACKE_csteqr")
    #elseif os(macOS)
    static let csteqr: FunctionTypes.LAPACKE_csteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsteqr: FunctionTypes.LAPACKE_zsteqr? = load(name: "LAPACKE_zsteqr")
    #elseif os(macOS)
    static let zsteqr: FunctionTypes.LAPACKE_zsteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssterf: FunctionTypes.LAPACKE_ssterf? = load(name: "LAPACKE_ssterf")
    #elseif os(macOS)
    static let ssterf: FunctionTypes.LAPACKE_ssterf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsterf: FunctionTypes.LAPACKE_dsterf? = load(name: "LAPACKE_dsterf")
    #elseif os(macOS)
    static let dsterf: FunctionTypes.LAPACKE_dsterf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstev: FunctionTypes.LAPACKE_sstev? = load(name: "LAPACKE_sstev")
    #elseif os(macOS)
    static let sstev: FunctionTypes.LAPACKE_sstev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstev: FunctionTypes.LAPACKE_dstev? = load(name: "LAPACKE_dstev")
    #elseif os(macOS)
    static let dstev: FunctionTypes.LAPACKE_dstev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevd: FunctionTypes.LAPACKE_sstevd? = load(name: "LAPACKE_sstevd")
    #elseif os(macOS)
    static let sstevd: FunctionTypes.LAPACKE_sstevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevd: FunctionTypes.LAPACKE_dstevd? = load(name: "LAPACKE_dstevd")
    #elseif os(macOS)
    static let dstevd: FunctionTypes.LAPACKE_dstevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevr: FunctionTypes.LAPACKE_sstevr? = load(name: "LAPACKE_sstevr")
    #elseif os(macOS)
    static let sstevr: FunctionTypes.LAPACKE_sstevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevr: FunctionTypes.LAPACKE_dstevr? = load(name: "LAPACKE_dstevr")
    #elseif os(macOS)
    static let dstevr: FunctionTypes.LAPACKE_dstevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevx: FunctionTypes.LAPACKE_sstevx? = load(name: "LAPACKE_sstevx")
    #elseif os(macOS)
    static let sstevx: FunctionTypes.LAPACKE_sstevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevx: FunctionTypes.LAPACKE_dstevx? = load(name: "LAPACKE_dstevx")
    #elseif os(macOS)
    static let dstevx: FunctionTypes.LAPACKE_dstevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon: FunctionTypes.LAPACKE_ssycon? = load(name: "LAPACKE_ssycon")
    #elseif os(macOS)
    static let ssycon: FunctionTypes.LAPACKE_ssycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon: FunctionTypes.LAPACKE_dsycon? = load(name: "LAPACKE_dsycon")
    #elseif os(macOS)
    static let dsycon: FunctionTypes.LAPACKE_dsycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon: FunctionTypes.LAPACKE_csycon? = load(name: "LAPACKE_csycon")
    #elseif os(macOS)
    static let csycon: FunctionTypes.LAPACKE_csycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon: FunctionTypes.LAPACKE_zsycon? = load(name: "LAPACKE_zsycon")
    #elseif os(macOS)
    static let zsycon: FunctionTypes.LAPACKE_zsycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyequb: FunctionTypes.LAPACKE_ssyequb? = load(name: "LAPACKE_ssyequb")
    #elseif os(macOS)
    static let ssyequb: FunctionTypes.LAPACKE_ssyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyequb: FunctionTypes.LAPACKE_dsyequb? = load(name: "LAPACKE_dsyequb")
    #elseif os(macOS)
    static let dsyequb: FunctionTypes.LAPACKE_dsyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyequb: FunctionTypes.LAPACKE_csyequb? = load(name: "LAPACKE_csyequb")
    #elseif os(macOS)
    static let csyequb: FunctionTypes.LAPACKE_csyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyequb: FunctionTypes.LAPACKE_zsyequb? = load(name: "LAPACKE_zsyequb")
    #elseif os(macOS)
    static let zsyequb: FunctionTypes.LAPACKE_zsyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev: FunctionTypes.LAPACKE_ssyev? = load(name: "LAPACKE_ssyev")
    #elseif os(macOS)
    static let ssyev: FunctionTypes.LAPACKE_ssyev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev: FunctionTypes.LAPACKE_dsyev? = load(name: "LAPACKE_dsyev")
    #elseif os(macOS)
    static let dsyev: FunctionTypes.LAPACKE_dsyev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd: FunctionTypes.LAPACKE_ssyevd? = load(name: "LAPACKE_ssyevd")
    #elseif os(macOS)
    static let ssyevd: FunctionTypes.LAPACKE_ssyevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd: FunctionTypes.LAPACKE_dsyevd? = load(name: "LAPACKE_dsyevd")
    #elseif os(macOS)
    static let dsyevd: FunctionTypes.LAPACKE_dsyevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr: FunctionTypes.LAPACKE_ssyevr? = load(name: "LAPACKE_ssyevr")
    #elseif os(macOS)
    static let ssyevr: FunctionTypes.LAPACKE_ssyevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr: FunctionTypes.LAPACKE_dsyevr? = load(name: "LAPACKE_dsyevr")
    #elseif os(macOS)
    static let dsyevr: FunctionTypes.LAPACKE_dsyevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx: FunctionTypes.LAPACKE_ssyevx? = load(name: "LAPACKE_ssyevx")
    #elseif os(macOS)
    static let ssyevx: FunctionTypes.LAPACKE_ssyevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx: FunctionTypes.LAPACKE_dsyevx? = load(name: "LAPACKE_dsyevx")
    #elseif os(macOS)
    static let dsyevx: FunctionTypes.LAPACKE_dsyevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygst: FunctionTypes.LAPACKE_ssygst? = load(name: "LAPACKE_ssygst")
    #elseif os(macOS)
    static let ssygst: FunctionTypes.LAPACKE_ssygst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygst: FunctionTypes.LAPACKE_dsygst? = load(name: "LAPACKE_dsygst")
    #elseif os(macOS)
    static let dsygst: FunctionTypes.LAPACKE_dsygst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv: FunctionTypes.LAPACKE_ssygv? = load(name: "LAPACKE_ssygv")
    #elseif os(macOS)
    static let ssygv: FunctionTypes.LAPACKE_ssygv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv: FunctionTypes.LAPACKE_dsygv? = load(name: "LAPACKE_dsygv")
    #elseif os(macOS)
    static let dsygv: FunctionTypes.LAPACKE_dsygv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvd: FunctionTypes.LAPACKE_ssygvd? = load(name: "LAPACKE_ssygvd")
    #elseif os(macOS)
    static let ssygvd: FunctionTypes.LAPACKE_ssygvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvd: FunctionTypes.LAPACKE_dsygvd? = load(name: "LAPACKE_dsygvd")
    #elseif os(macOS)
    static let dsygvd: FunctionTypes.LAPACKE_dsygvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvx: FunctionTypes.LAPACKE_ssygvx? = load(name: "LAPACKE_ssygvx")
    #elseif os(macOS)
    static let ssygvx: FunctionTypes.LAPACKE_ssygvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvx: FunctionTypes.LAPACKE_dsygvx? = load(name: "LAPACKE_dsygvx")
    #elseif os(macOS)
    static let dsygvx: FunctionTypes.LAPACKE_dsygvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfs: FunctionTypes.LAPACKE_ssyrfs? = load(name: "LAPACKE_ssyrfs")
    #elseif os(macOS)
    static let ssyrfs: FunctionTypes.LAPACKE_ssyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfs: FunctionTypes.LAPACKE_dsyrfs? = load(name: "LAPACKE_dsyrfs")
    #elseif os(macOS)
    static let dsyrfs: FunctionTypes.LAPACKE_dsyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfs: FunctionTypes.LAPACKE_csyrfs? = load(name: "LAPACKE_csyrfs")
    #elseif os(macOS)
    static let csyrfs: FunctionTypes.LAPACKE_csyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfs: FunctionTypes.LAPACKE_zsyrfs? = load(name: "LAPACKE_zsyrfs")
    #elseif os(macOS)
    static let zsyrfs: FunctionTypes.LAPACKE_zsyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfsx: FunctionTypes.LAPACKE_ssyrfsx? = load(name: "LAPACKE_ssyrfsx")
    #elseif os(macOS)
    static let ssyrfsx: FunctionTypes.LAPACKE_ssyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfsx: FunctionTypes.LAPACKE_dsyrfsx? = load(name: "LAPACKE_dsyrfsx")
    #elseif os(macOS)
    static let dsyrfsx: FunctionTypes.LAPACKE_dsyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfsx: FunctionTypes.LAPACKE_csyrfsx? = load(name: "LAPACKE_csyrfsx")
    #elseif os(macOS)
    static let csyrfsx: FunctionTypes.LAPACKE_csyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfsx: FunctionTypes.LAPACKE_zsyrfsx? = load(name: "LAPACKE_zsyrfsx")
    #elseif os(macOS)
    static let zsyrfsx: FunctionTypes.LAPACKE_zsyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv: FunctionTypes.LAPACKE_ssysv? = load(name: "LAPACKE_ssysv")
    #elseif os(macOS)
    static let ssysv: FunctionTypes.LAPACKE_ssysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv: FunctionTypes.LAPACKE_dsysv? = load(name: "LAPACKE_dsysv")
    #elseif os(macOS)
    static let dsysv: FunctionTypes.LAPACKE_dsysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv: FunctionTypes.LAPACKE_csysv? = load(name: "LAPACKE_csysv")
    #elseif os(macOS)
    static let csysv: FunctionTypes.LAPACKE_csysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv: FunctionTypes.LAPACKE_zsysv? = load(name: "LAPACKE_zsysv")
    #elseif os(macOS)
    static let zsysv: FunctionTypes.LAPACKE_zsysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvx: FunctionTypes.LAPACKE_ssysvx? = load(name: "LAPACKE_ssysvx")
    #elseif os(macOS)
    static let ssysvx: FunctionTypes.LAPACKE_ssysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvx: FunctionTypes.LAPACKE_dsysvx? = load(name: "LAPACKE_dsysvx")
    #elseif os(macOS)
    static let dsysvx: FunctionTypes.LAPACKE_dsysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvx: FunctionTypes.LAPACKE_csysvx? = load(name: "LAPACKE_csysvx")
    #elseif os(macOS)
    static let csysvx: FunctionTypes.LAPACKE_csysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvx: FunctionTypes.LAPACKE_zsysvx? = load(name: "LAPACKE_zsysvx")
    #elseif os(macOS)
    static let zsysvx: FunctionTypes.LAPACKE_zsysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvxx: FunctionTypes.LAPACKE_ssysvxx? = load(name: "LAPACKE_ssysvxx")
    #elseif os(macOS)
    static let ssysvxx: FunctionTypes.LAPACKE_ssysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvxx: FunctionTypes.LAPACKE_dsysvxx? = load(name: "LAPACKE_dsysvxx")
    #elseif os(macOS)
    static let dsysvxx: FunctionTypes.LAPACKE_dsysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvxx: FunctionTypes.LAPACKE_csysvxx? = load(name: "LAPACKE_csysvxx")
    #elseif os(macOS)
    static let csysvxx: FunctionTypes.LAPACKE_csysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvxx: FunctionTypes.LAPACKE_zsysvxx? = load(name: "LAPACKE_zsysvxx")
    #elseif os(macOS)
    static let zsysvxx: FunctionTypes.LAPACKE_zsysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrd: FunctionTypes.LAPACKE_ssytrd? = load(name: "LAPACKE_ssytrd")
    #elseif os(macOS)
    static let ssytrd: FunctionTypes.LAPACKE_ssytrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrd: FunctionTypes.LAPACKE_dsytrd? = load(name: "LAPACKE_dsytrd")
    #elseif os(macOS)
    static let dsytrd: FunctionTypes.LAPACKE_dsytrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf: FunctionTypes.LAPACKE_ssytrf? = load(name: "LAPACKE_ssytrf")
    #elseif os(macOS)
    static let ssytrf: FunctionTypes.LAPACKE_ssytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf: FunctionTypes.LAPACKE_dsytrf? = load(name: "LAPACKE_dsytrf")
    #elseif os(macOS)
    static let dsytrf: FunctionTypes.LAPACKE_dsytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf: FunctionTypes.LAPACKE_csytrf? = load(name: "LAPACKE_csytrf")
    #elseif os(macOS)
    static let csytrf: FunctionTypes.LAPACKE_csytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf: FunctionTypes.LAPACKE_zsytrf? = load(name: "LAPACKE_zsytrf")
    #elseif os(macOS)
    static let zsytrf: FunctionTypes.LAPACKE_zsytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri: FunctionTypes.LAPACKE_ssytri? = load(name: "LAPACKE_ssytri")
    #elseif os(macOS)
    static let ssytri: FunctionTypes.LAPACKE_ssytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri: FunctionTypes.LAPACKE_dsytri? = load(name: "LAPACKE_dsytri")
    #elseif os(macOS)
    static let dsytri: FunctionTypes.LAPACKE_dsytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri: FunctionTypes.LAPACKE_csytri? = load(name: "LAPACKE_csytri")
    #elseif os(macOS)
    static let csytri: FunctionTypes.LAPACKE_csytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri: FunctionTypes.LAPACKE_zsytri? = load(name: "LAPACKE_zsytri")
    #elseif os(macOS)
    static let zsytri: FunctionTypes.LAPACKE_zsytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs: FunctionTypes.LAPACKE_ssytrs? = load(name: "LAPACKE_ssytrs")
    #elseif os(macOS)
    static let ssytrs: FunctionTypes.LAPACKE_ssytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs: FunctionTypes.LAPACKE_dsytrs? = load(name: "LAPACKE_dsytrs")
    #elseif os(macOS)
    static let dsytrs: FunctionTypes.LAPACKE_dsytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs: FunctionTypes.LAPACKE_csytrs? = load(name: "LAPACKE_csytrs")
    #elseif os(macOS)
    static let csytrs: FunctionTypes.LAPACKE_csytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs: FunctionTypes.LAPACKE_zsytrs? = load(name: "LAPACKE_zsytrs")
    #elseif os(macOS)
    static let zsytrs: FunctionTypes.LAPACKE_zsytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbcon: FunctionTypes.LAPACKE_stbcon? = load(name: "LAPACKE_stbcon")
    #elseif os(macOS)
    static let stbcon: FunctionTypes.LAPACKE_stbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbcon: FunctionTypes.LAPACKE_dtbcon? = load(name: "LAPACKE_dtbcon")
    #elseif os(macOS)
    static let dtbcon: FunctionTypes.LAPACKE_dtbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbcon: FunctionTypes.LAPACKE_ctbcon? = load(name: "LAPACKE_ctbcon")
    #elseif os(macOS)
    static let ctbcon: FunctionTypes.LAPACKE_ctbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbcon: FunctionTypes.LAPACKE_ztbcon? = load(name: "LAPACKE_ztbcon")
    #elseif os(macOS)
    static let ztbcon: FunctionTypes.LAPACKE_ztbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbrfs: FunctionTypes.LAPACKE_stbrfs? = load(name: "LAPACKE_stbrfs")
    #elseif os(macOS)
    static let stbrfs: FunctionTypes.LAPACKE_stbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbrfs: FunctionTypes.LAPACKE_dtbrfs? = load(name: "LAPACKE_dtbrfs")
    #elseif os(macOS)
    static let dtbrfs: FunctionTypes.LAPACKE_dtbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbrfs: FunctionTypes.LAPACKE_ctbrfs? = load(name: "LAPACKE_ctbrfs")
    #elseif os(macOS)
    static let ctbrfs: FunctionTypes.LAPACKE_ctbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbrfs: FunctionTypes.LAPACKE_ztbrfs? = load(name: "LAPACKE_ztbrfs")
    #elseif os(macOS)
    static let ztbrfs: FunctionTypes.LAPACKE_ztbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbtrs: FunctionTypes.LAPACKE_stbtrs? = load(name: "LAPACKE_stbtrs")
    #elseif os(macOS)
    static let stbtrs: FunctionTypes.LAPACKE_stbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbtrs: FunctionTypes.LAPACKE_dtbtrs? = load(name: "LAPACKE_dtbtrs")
    #elseif os(macOS)
    static let dtbtrs: FunctionTypes.LAPACKE_dtbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbtrs: FunctionTypes.LAPACKE_ctbtrs? = load(name: "LAPACKE_ctbtrs")
    #elseif os(macOS)
    static let ctbtrs: FunctionTypes.LAPACKE_ctbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbtrs: FunctionTypes.LAPACKE_ztbtrs? = load(name: "LAPACKE_ztbtrs")
    #elseif os(macOS)
    static let ztbtrs: FunctionTypes.LAPACKE_ztbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfsm: FunctionTypes.LAPACKE_stfsm? = load(name: "LAPACKE_stfsm")
    #elseif os(macOS)
    static let stfsm: FunctionTypes.LAPACKE_stfsm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfsm: FunctionTypes.LAPACKE_dtfsm? = load(name: "LAPACKE_dtfsm")
    #elseif os(macOS)
    static let dtfsm: FunctionTypes.LAPACKE_dtfsm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stftri: FunctionTypes.LAPACKE_stftri? = load(name: "LAPACKE_stftri")
    #elseif os(macOS)
    static let stftri: FunctionTypes.LAPACKE_stftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtftri: FunctionTypes.LAPACKE_dtftri? = load(name: "LAPACKE_dtftri")
    #elseif os(macOS)
    static let dtftri: FunctionTypes.LAPACKE_dtftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctftri: FunctionTypes.LAPACKE_ctftri? = load(name: "LAPACKE_ctftri")
    #elseif os(macOS)
    static let ctftri: FunctionTypes.LAPACKE_ctftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztftri: FunctionTypes.LAPACKE_ztftri? = load(name: "LAPACKE_ztftri")
    #elseif os(macOS)
    static let ztftri: FunctionTypes.LAPACKE_ztftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttp: FunctionTypes.LAPACKE_stfttp? = load(name: "LAPACKE_stfttp")
    #elseif os(macOS)
    static let stfttp: FunctionTypes.LAPACKE_stfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttp: FunctionTypes.LAPACKE_dtfttp? = load(name: "LAPACKE_dtfttp")
    #elseif os(macOS)
    static let dtfttp: FunctionTypes.LAPACKE_dtfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttp: FunctionTypes.LAPACKE_ctfttp? = load(name: "LAPACKE_ctfttp")
    #elseif os(macOS)
    static let ctfttp: FunctionTypes.LAPACKE_ctfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttp: FunctionTypes.LAPACKE_ztfttp? = load(name: "LAPACKE_ztfttp")
    #elseif os(macOS)
    static let ztfttp: FunctionTypes.LAPACKE_ztfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttr: FunctionTypes.LAPACKE_stfttr? = load(name: "LAPACKE_stfttr")
    #elseif os(macOS)
    static let stfttr: FunctionTypes.LAPACKE_stfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttr: FunctionTypes.LAPACKE_dtfttr? = load(name: "LAPACKE_dtfttr")
    #elseif os(macOS)
    static let dtfttr: FunctionTypes.LAPACKE_dtfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttr: FunctionTypes.LAPACKE_ctfttr? = load(name: "LAPACKE_ctfttr")
    #elseif os(macOS)
    static let ctfttr: FunctionTypes.LAPACKE_ctfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttr: FunctionTypes.LAPACKE_ztfttr? = load(name: "LAPACKE_ztfttr")
    #elseif os(macOS)
    static let ztfttr: FunctionTypes.LAPACKE_ztfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgevc: FunctionTypes.LAPACKE_stgevc? = load(name: "LAPACKE_stgevc")
    #elseif os(macOS)
    static let stgevc: FunctionTypes.LAPACKE_stgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgevc: FunctionTypes.LAPACKE_dtgevc? = load(name: "LAPACKE_dtgevc")
    #elseif os(macOS)
    static let dtgevc: FunctionTypes.LAPACKE_dtgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgevc: FunctionTypes.LAPACKE_ctgevc? = load(name: "LAPACKE_ctgevc")
    #elseif os(macOS)
    static let ctgevc: FunctionTypes.LAPACKE_ctgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgevc: FunctionTypes.LAPACKE_ztgevc? = load(name: "LAPACKE_ztgevc")
    #elseif os(macOS)
    static let ztgevc: FunctionTypes.LAPACKE_ztgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgexc: FunctionTypes.LAPACKE_stgexc? = load(name: "LAPACKE_stgexc")
    #elseif os(macOS)
    static let stgexc: FunctionTypes.LAPACKE_stgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgexc: FunctionTypes.LAPACKE_dtgexc? = load(name: "LAPACKE_dtgexc")
    #elseif os(macOS)
    static let dtgexc: FunctionTypes.LAPACKE_dtgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgexc: FunctionTypes.LAPACKE_ctgexc? = load(name: "LAPACKE_ctgexc")
    #elseif os(macOS)
    static let ctgexc: FunctionTypes.LAPACKE_ctgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgexc: FunctionTypes.LAPACKE_ztgexc? = load(name: "LAPACKE_ztgexc")
    #elseif os(macOS)
    static let ztgexc: FunctionTypes.LAPACKE_ztgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsen: FunctionTypes.LAPACKE_stgsen? = load(name: "LAPACKE_stgsen")
    #elseif os(macOS)
    static let stgsen: FunctionTypes.LAPACKE_stgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsen: FunctionTypes.LAPACKE_dtgsen? = load(name: "LAPACKE_dtgsen")
    #elseif os(macOS)
    static let dtgsen: FunctionTypes.LAPACKE_dtgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsen: FunctionTypes.LAPACKE_ctgsen? = load(name: "LAPACKE_ctgsen")
    #elseif os(macOS)
    static let ctgsen: FunctionTypes.LAPACKE_ctgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsen: FunctionTypes.LAPACKE_ztgsen? = load(name: "LAPACKE_ztgsen")
    #elseif os(macOS)
    static let ztgsen: FunctionTypes.LAPACKE_ztgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsja: FunctionTypes.LAPACKE_stgsja? = load(name: "LAPACKE_stgsja")
    #elseif os(macOS)
    static let stgsja: FunctionTypes.LAPACKE_stgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsja: FunctionTypes.LAPACKE_dtgsja? = load(name: "LAPACKE_dtgsja")
    #elseif os(macOS)
    static let dtgsja: FunctionTypes.LAPACKE_dtgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsja: FunctionTypes.LAPACKE_ctgsja? = load(name: "LAPACKE_ctgsja")
    #elseif os(macOS)
    static let ctgsja: FunctionTypes.LAPACKE_ctgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsja: FunctionTypes.LAPACKE_ztgsja? = load(name: "LAPACKE_ztgsja")
    #elseif os(macOS)
    static let ztgsja: FunctionTypes.LAPACKE_ztgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsna: FunctionTypes.LAPACKE_stgsna? = load(name: "LAPACKE_stgsna")
    #elseif os(macOS)
    static let stgsna: FunctionTypes.LAPACKE_stgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsna: FunctionTypes.LAPACKE_dtgsna? = load(name: "LAPACKE_dtgsna")
    #elseif os(macOS)
    static let dtgsna: FunctionTypes.LAPACKE_dtgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsna: FunctionTypes.LAPACKE_ctgsna? = load(name: "LAPACKE_ctgsna")
    #elseif os(macOS)
    static let ctgsna: FunctionTypes.LAPACKE_ctgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsna: FunctionTypes.LAPACKE_ztgsna? = load(name: "LAPACKE_ztgsna")
    #elseif os(macOS)
    static let ztgsna: FunctionTypes.LAPACKE_ztgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsyl: FunctionTypes.LAPACKE_stgsyl? = load(name: "LAPACKE_stgsyl")
    #elseif os(macOS)
    static let stgsyl: FunctionTypes.LAPACKE_stgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsyl: FunctionTypes.LAPACKE_dtgsyl? = load(name: "LAPACKE_dtgsyl")
    #elseif os(macOS)
    static let dtgsyl: FunctionTypes.LAPACKE_dtgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsyl: FunctionTypes.LAPACKE_ctgsyl? = load(name: "LAPACKE_ctgsyl")
    #elseif os(macOS)
    static let ctgsyl: FunctionTypes.LAPACKE_ctgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsyl: FunctionTypes.LAPACKE_ztgsyl? = load(name: "LAPACKE_ztgsyl")
    #elseif os(macOS)
    static let ztgsyl: FunctionTypes.LAPACKE_ztgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpcon: FunctionTypes.LAPACKE_stpcon? = load(name: "LAPACKE_stpcon")
    #elseif os(macOS)
    static let stpcon: FunctionTypes.LAPACKE_stpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpcon: FunctionTypes.LAPACKE_dtpcon? = load(name: "LAPACKE_dtpcon")
    #elseif os(macOS)
    static let dtpcon: FunctionTypes.LAPACKE_dtpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpcon: FunctionTypes.LAPACKE_ctpcon? = load(name: "LAPACKE_ctpcon")
    #elseif os(macOS)
    static let ctpcon: FunctionTypes.LAPACKE_ctpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpcon: FunctionTypes.LAPACKE_ztpcon? = load(name: "LAPACKE_ztpcon")
    #elseif os(macOS)
    static let ztpcon: FunctionTypes.LAPACKE_ztpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfs: FunctionTypes.LAPACKE_stprfs? = load(name: "LAPACKE_stprfs")
    #elseif os(macOS)
    static let stprfs: FunctionTypes.LAPACKE_stprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfs: FunctionTypes.LAPACKE_dtprfs? = load(name: "LAPACKE_dtprfs")
    #elseif os(macOS)
    static let dtprfs: FunctionTypes.LAPACKE_dtprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfs: FunctionTypes.LAPACKE_ctprfs? = load(name: "LAPACKE_ctprfs")
    #elseif os(macOS)
    static let ctprfs: FunctionTypes.LAPACKE_ctprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfs: FunctionTypes.LAPACKE_ztprfs? = load(name: "LAPACKE_ztprfs")
    #elseif os(macOS)
    static let ztprfs: FunctionTypes.LAPACKE_ztprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptri: FunctionTypes.LAPACKE_stptri? = load(name: "LAPACKE_stptri")
    #elseif os(macOS)
    static let stptri: FunctionTypes.LAPACKE_stptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptri: FunctionTypes.LAPACKE_dtptri? = load(name: "LAPACKE_dtptri")
    #elseif os(macOS)
    static let dtptri: FunctionTypes.LAPACKE_dtptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptri: FunctionTypes.LAPACKE_ctptri? = load(name: "LAPACKE_ctptri")
    #elseif os(macOS)
    static let ctptri: FunctionTypes.LAPACKE_ctptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptri: FunctionTypes.LAPACKE_ztptri? = load(name: "LAPACKE_ztptri")
    #elseif os(macOS)
    static let ztptri: FunctionTypes.LAPACKE_ztptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptrs: FunctionTypes.LAPACKE_stptrs? = load(name: "LAPACKE_stptrs")
    #elseif os(macOS)
    static let stptrs: FunctionTypes.LAPACKE_stptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptrs: FunctionTypes.LAPACKE_dtptrs? = load(name: "LAPACKE_dtptrs")
    #elseif os(macOS)
    static let dtptrs: FunctionTypes.LAPACKE_dtptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptrs: FunctionTypes.LAPACKE_ctptrs? = load(name: "LAPACKE_ctptrs")
    #elseif os(macOS)
    static let ctptrs: FunctionTypes.LAPACKE_ctptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptrs: FunctionTypes.LAPACKE_ztptrs? = load(name: "LAPACKE_ztptrs")
    #elseif os(macOS)
    static let ztptrs: FunctionTypes.LAPACKE_ztptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttf: FunctionTypes.LAPACKE_stpttf? = load(name: "LAPACKE_stpttf")
    #elseif os(macOS)
    static let stpttf: FunctionTypes.LAPACKE_stpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttf: FunctionTypes.LAPACKE_dtpttf? = load(name: "LAPACKE_dtpttf")
    #elseif os(macOS)
    static let dtpttf: FunctionTypes.LAPACKE_dtpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttf: FunctionTypes.LAPACKE_ctpttf? = load(name: "LAPACKE_ctpttf")
    #elseif os(macOS)
    static let ctpttf: FunctionTypes.LAPACKE_ctpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttf: FunctionTypes.LAPACKE_ztpttf? = load(name: "LAPACKE_ztpttf")
    #elseif os(macOS)
    static let ztpttf: FunctionTypes.LAPACKE_ztpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttr: FunctionTypes.LAPACKE_stpttr? = load(name: "LAPACKE_stpttr")
    #elseif os(macOS)
    static let stpttr: FunctionTypes.LAPACKE_stpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttr: FunctionTypes.LAPACKE_dtpttr? = load(name: "LAPACKE_dtpttr")
    #elseif os(macOS)
    static let dtpttr: FunctionTypes.LAPACKE_dtpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttr: FunctionTypes.LAPACKE_ctpttr? = load(name: "LAPACKE_ctpttr")
    #elseif os(macOS)
    static let ctpttr: FunctionTypes.LAPACKE_ctpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttr: FunctionTypes.LAPACKE_ztpttr? = load(name: "LAPACKE_ztpttr")
    #elseif os(macOS)
    static let ztpttr: FunctionTypes.LAPACKE_ztpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strcon: FunctionTypes.LAPACKE_strcon? = load(name: "LAPACKE_strcon")
    #elseif os(macOS)
    static let strcon: FunctionTypes.LAPACKE_strcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrcon: FunctionTypes.LAPACKE_dtrcon? = load(name: "LAPACKE_dtrcon")
    #elseif os(macOS)
    static let dtrcon: FunctionTypes.LAPACKE_dtrcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrcon: FunctionTypes.LAPACKE_ctrcon? = load(name: "LAPACKE_ctrcon")
    #elseif os(macOS)
    static let ctrcon: FunctionTypes.LAPACKE_ctrcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrcon: FunctionTypes.LAPACKE_ztrcon? = load(name: "LAPACKE_ztrcon")
    #elseif os(macOS)
    static let ztrcon: FunctionTypes.LAPACKE_ztrcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strevc: FunctionTypes.LAPACKE_strevc? = load(name: "LAPACKE_strevc")
    #elseif os(macOS)
    static let strevc: FunctionTypes.LAPACKE_strevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrevc: FunctionTypes.LAPACKE_dtrevc? = load(name: "LAPACKE_dtrevc")
    #elseif os(macOS)
    static let dtrevc: FunctionTypes.LAPACKE_dtrevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrevc: FunctionTypes.LAPACKE_ctrevc? = load(name: "LAPACKE_ctrevc")
    #elseif os(macOS)
    static let ctrevc: FunctionTypes.LAPACKE_ctrevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrevc: FunctionTypes.LAPACKE_ztrevc? = load(name: "LAPACKE_ztrevc")
    #elseif os(macOS)
    static let ztrevc: FunctionTypes.LAPACKE_ztrevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strexc: FunctionTypes.LAPACKE_strexc? = load(name: "LAPACKE_strexc")
    #elseif os(macOS)
    static let strexc: FunctionTypes.LAPACKE_strexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrexc: FunctionTypes.LAPACKE_dtrexc? = load(name: "LAPACKE_dtrexc")
    #elseif os(macOS)
    static let dtrexc: FunctionTypes.LAPACKE_dtrexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrexc: FunctionTypes.LAPACKE_ctrexc? = load(name: "LAPACKE_ctrexc")
    #elseif os(macOS)
    static let ctrexc: FunctionTypes.LAPACKE_ctrexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrexc: FunctionTypes.LAPACKE_ztrexc? = load(name: "LAPACKE_ztrexc")
    #elseif os(macOS)
    static let ztrexc: FunctionTypes.LAPACKE_ztrexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strrfs: FunctionTypes.LAPACKE_strrfs? = load(name: "LAPACKE_strrfs")
    #elseif os(macOS)
    static let strrfs: FunctionTypes.LAPACKE_strrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrrfs: FunctionTypes.LAPACKE_dtrrfs? = load(name: "LAPACKE_dtrrfs")
    #elseif os(macOS)
    static let dtrrfs: FunctionTypes.LAPACKE_dtrrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrrfs: FunctionTypes.LAPACKE_ctrrfs? = load(name: "LAPACKE_ctrrfs")
    #elseif os(macOS)
    static let ctrrfs: FunctionTypes.LAPACKE_ctrrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrrfs: FunctionTypes.LAPACKE_ztrrfs? = load(name: "LAPACKE_ztrrfs")
    #elseif os(macOS)
    static let ztrrfs: FunctionTypes.LAPACKE_ztrrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsen: FunctionTypes.LAPACKE_strsen? = load(name: "LAPACKE_strsen")
    #elseif os(macOS)
    static let strsen: FunctionTypes.LAPACKE_strsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsen: FunctionTypes.LAPACKE_dtrsen? = load(name: "LAPACKE_dtrsen")
    #elseif os(macOS)
    static let dtrsen: FunctionTypes.LAPACKE_dtrsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsen: FunctionTypes.LAPACKE_ctrsen? = load(name: "LAPACKE_ctrsen")
    #elseif os(macOS)
    static let ctrsen: FunctionTypes.LAPACKE_ctrsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsen: FunctionTypes.LAPACKE_ztrsen? = load(name: "LAPACKE_ztrsen")
    #elseif os(macOS)
    static let ztrsen: FunctionTypes.LAPACKE_ztrsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsna: FunctionTypes.LAPACKE_strsna? = load(name: "LAPACKE_strsna")
    #elseif os(macOS)
    static let strsna: FunctionTypes.LAPACKE_strsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsna: FunctionTypes.LAPACKE_dtrsna? = load(name: "LAPACKE_dtrsna")
    #elseif os(macOS)
    static let dtrsna: FunctionTypes.LAPACKE_dtrsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsna: FunctionTypes.LAPACKE_ctrsna? = load(name: "LAPACKE_ctrsna")
    #elseif os(macOS)
    static let ctrsna: FunctionTypes.LAPACKE_ctrsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsna: FunctionTypes.LAPACKE_ztrsna? = load(name: "LAPACKE_ztrsna")
    #elseif os(macOS)
    static let ztrsna: FunctionTypes.LAPACKE_ztrsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl: FunctionTypes.LAPACKE_strsyl? = load(name: "LAPACKE_strsyl")
    #elseif os(macOS)
    static let strsyl: FunctionTypes.LAPACKE_strsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl: FunctionTypes.LAPACKE_dtrsyl? = load(name: "LAPACKE_dtrsyl")
    #elseif os(macOS)
    static let dtrsyl: FunctionTypes.LAPACKE_dtrsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsyl: FunctionTypes.LAPACKE_ctrsyl? = load(name: "LAPACKE_ctrsyl")
    #elseif os(macOS)
    static let ctrsyl: FunctionTypes.LAPACKE_ctrsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl: FunctionTypes.LAPACKE_ztrsyl? = load(name: "LAPACKE_ztrsyl")
    #elseif os(macOS)
    static let ztrsyl: FunctionTypes.LAPACKE_ztrsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl3: FunctionTypes.LAPACKE_strsyl3? = load(name: "LAPACKE_strsyl3")
    #elseif os(macOS)
    static let strsyl3: FunctionTypes.LAPACKE_strsyl3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl3: FunctionTypes.LAPACKE_dtrsyl3? = load(name: "LAPACKE_dtrsyl3")
    #elseif os(macOS)
    static let dtrsyl3: FunctionTypes.LAPACKE_dtrsyl3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl3: FunctionTypes.LAPACKE_ztrsyl3? = load(name: "LAPACKE_ztrsyl3")
    #elseif os(macOS)
    static let ztrsyl3: FunctionTypes.LAPACKE_ztrsyl3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtri: FunctionTypes.LAPACKE_strtri? = load(name: "LAPACKE_strtri")
    #elseif os(macOS)
    static let strtri: FunctionTypes.LAPACKE_strtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtri: FunctionTypes.LAPACKE_dtrtri? = load(name: "LAPACKE_dtrtri")
    #elseif os(macOS)
    static let dtrtri: FunctionTypes.LAPACKE_dtrtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtri: FunctionTypes.LAPACKE_ctrtri? = load(name: "LAPACKE_ctrtri")
    #elseif os(macOS)
    static let ctrtri: FunctionTypes.LAPACKE_ctrtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtri: FunctionTypes.LAPACKE_ztrtri? = load(name: "LAPACKE_ztrtri")
    #elseif os(macOS)
    static let ztrtri: FunctionTypes.LAPACKE_ztrtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtrs: FunctionTypes.LAPACKE_strtrs? = load(name: "LAPACKE_strtrs")
    #elseif os(macOS)
    static let strtrs: FunctionTypes.LAPACKE_strtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtrs: FunctionTypes.LAPACKE_dtrtrs? = load(name: "LAPACKE_dtrtrs")
    #elseif os(macOS)
    static let dtrtrs: FunctionTypes.LAPACKE_dtrtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtrs: FunctionTypes.LAPACKE_ctrtrs? = load(name: "LAPACKE_ctrtrs")
    #elseif os(macOS)
    static let ctrtrs: FunctionTypes.LAPACKE_ctrtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtrs: FunctionTypes.LAPACKE_ztrtrs? = load(name: "LAPACKE_ztrtrs")
    #elseif os(macOS)
    static let ztrtrs: FunctionTypes.LAPACKE_ztrtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttf: FunctionTypes.LAPACKE_strttf? = load(name: "LAPACKE_strttf")
    #elseif os(macOS)
    static let strttf: FunctionTypes.LAPACKE_strttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttf: FunctionTypes.LAPACKE_dtrttf? = load(name: "LAPACKE_dtrttf")
    #elseif os(macOS)
    static let dtrttf: FunctionTypes.LAPACKE_dtrttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttf: FunctionTypes.LAPACKE_ctrttf? = load(name: "LAPACKE_ctrttf")
    #elseif os(macOS)
    static let ctrttf: FunctionTypes.LAPACKE_ctrttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttf: FunctionTypes.LAPACKE_ztrttf? = load(name: "LAPACKE_ztrttf")
    #elseif os(macOS)
    static let ztrttf: FunctionTypes.LAPACKE_ztrttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttp: FunctionTypes.LAPACKE_strttp? = load(name: "LAPACKE_strttp")
    #elseif os(macOS)
    static let strttp: FunctionTypes.LAPACKE_strttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttp: FunctionTypes.LAPACKE_dtrttp? = load(name: "LAPACKE_dtrttp")
    #elseif os(macOS)
    static let dtrttp: FunctionTypes.LAPACKE_dtrttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttp: FunctionTypes.LAPACKE_ctrttp? = load(name: "LAPACKE_ctrttp")
    #elseif os(macOS)
    static let ctrttp: FunctionTypes.LAPACKE_ctrttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttp: FunctionTypes.LAPACKE_ztrttp? = load(name: "LAPACKE_ztrttp")
    #elseif os(macOS)
    static let ztrttp: FunctionTypes.LAPACKE_ztrttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stzrzf: FunctionTypes.LAPACKE_stzrzf? = load(name: "LAPACKE_stzrzf")
    #elseif os(macOS)
    static let stzrzf: FunctionTypes.LAPACKE_stzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtzrzf: FunctionTypes.LAPACKE_dtzrzf? = load(name: "LAPACKE_dtzrzf")
    #elseif os(macOS)
    static let dtzrzf: FunctionTypes.LAPACKE_dtzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctzrzf: FunctionTypes.LAPACKE_ctzrzf? = load(name: "LAPACKE_ctzrzf")
    #elseif os(macOS)
    static let ctzrzf: FunctionTypes.LAPACKE_ctzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztzrzf: FunctionTypes.LAPACKE_ztzrzf? = load(name: "LAPACKE_ztzrzf")
    #elseif os(macOS)
    static let ztzrzf: FunctionTypes.LAPACKE_ztzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungbr: FunctionTypes.LAPACKE_cungbr? = load(name: "LAPACKE_cungbr")
    #elseif os(macOS)
    static let cungbr: FunctionTypes.LAPACKE_cungbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungbr: FunctionTypes.LAPACKE_zungbr? = load(name: "LAPACKE_zungbr")
    #elseif os(macOS)
    static let zungbr: FunctionTypes.LAPACKE_zungbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunghr: FunctionTypes.LAPACKE_cunghr? = load(name: "LAPACKE_cunghr")
    #elseif os(macOS)
    static let cunghr: FunctionTypes.LAPACKE_cunghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunghr: FunctionTypes.LAPACKE_zunghr? = load(name: "LAPACKE_zunghr")
    #elseif os(macOS)
    static let zunghr: FunctionTypes.LAPACKE_zunghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunglq: FunctionTypes.LAPACKE_cunglq? = load(name: "LAPACKE_cunglq")
    #elseif os(macOS)
    static let cunglq: FunctionTypes.LAPACKE_cunglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunglq: FunctionTypes.LAPACKE_zunglq? = load(name: "LAPACKE_zunglq")
    #elseif os(macOS)
    static let zunglq: FunctionTypes.LAPACKE_zunglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungql: FunctionTypes.LAPACKE_cungql? = load(name: "LAPACKE_cungql")
    #elseif os(macOS)
    static let cungql: FunctionTypes.LAPACKE_cungql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungql: FunctionTypes.LAPACKE_zungql? = load(name: "LAPACKE_zungql")
    #elseif os(macOS)
    static let zungql: FunctionTypes.LAPACKE_zungql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungqr: FunctionTypes.LAPACKE_cungqr? = load(name: "LAPACKE_cungqr")
    #elseif os(macOS)
    static let cungqr: FunctionTypes.LAPACKE_cungqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungqr: FunctionTypes.LAPACKE_zungqr? = load(name: "LAPACKE_zungqr")
    #elseif os(macOS)
    static let zungqr: FunctionTypes.LAPACKE_zungqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungrq: FunctionTypes.LAPACKE_cungrq? = load(name: "LAPACKE_cungrq")
    #elseif os(macOS)
    static let cungrq: FunctionTypes.LAPACKE_cungrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungrq: FunctionTypes.LAPACKE_zungrq? = load(name: "LAPACKE_zungrq")
    #elseif os(macOS)
    static let zungrq: FunctionTypes.LAPACKE_zungrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtr: FunctionTypes.LAPACKE_cungtr? = load(name: "LAPACKE_cungtr")
    #elseif os(macOS)
    static let cungtr: FunctionTypes.LAPACKE_cungtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtr: FunctionTypes.LAPACKE_zungtr? = load(name: "LAPACKE_zungtr")
    #elseif os(macOS)
    static let zungtr: FunctionTypes.LAPACKE_zungtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtsqr_row: FunctionTypes.LAPACKE_cungtsqr_row? = load(name: "LAPACKE_cungtsqr_row")
    #elseif os(macOS)
    static let cungtsqr_row: FunctionTypes.LAPACKE_cungtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtsqr_row: FunctionTypes.LAPACKE_zungtsqr_row? = load(name: "LAPACKE_zungtsqr_row")
    #elseif os(macOS)
    static let zungtsqr_row: FunctionTypes.LAPACKE_zungtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmbr: FunctionTypes.LAPACKE_cunmbr? = load(name: "LAPACKE_cunmbr")
    #elseif os(macOS)
    static let cunmbr: FunctionTypes.LAPACKE_cunmbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmbr: FunctionTypes.LAPACKE_zunmbr? = load(name: "LAPACKE_zunmbr")
    #elseif os(macOS)
    static let zunmbr: FunctionTypes.LAPACKE_zunmbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmhr: FunctionTypes.LAPACKE_cunmhr? = load(name: "LAPACKE_cunmhr")
    #elseif os(macOS)
    static let cunmhr: FunctionTypes.LAPACKE_cunmhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmhr: FunctionTypes.LAPACKE_zunmhr? = load(name: "LAPACKE_zunmhr")
    #elseif os(macOS)
    static let zunmhr: FunctionTypes.LAPACKE_zunmhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmlq: FunctionTypes.LAPACKE_cunmlq? = load(name: "LAPACKE_cunmlq")
    #elseif os(macOS)
    static let cunmlq: FunctionTypes.LAPACKE_cunmlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmlq: FunctionTypes.LAPACKE_zunmlq? = load(name: "LAPACKE_zunmlq")
    #elseif os(macOS)
    static let zunmlq: FunctionTypes.LAPACKE_zunmlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmql: FunctionTypes.LAPACKE_cunmql? = load(name: "LAPACKE_cunmql")
    #elseif os(macOS)
    static let cunmql: FunctionTypes.LAPACKE_cunmql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmql: FunctionTypes.LAPACKE_zunmql? = load(name: "LAPACKE_zunmql")
    #elseif os(macOS)
    static let zunmql: FunctionTypes.LAPACKE_zunmql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmqr: FunctionTypes.LAPACKE_cunmqr? = load(name: "LAPACKE_cunmqr")
    #elseif os(macOS)
    static let cunmqr: FunctionTypes.LAPACKE_cunmqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmqr: FunctionTypes.LAPACKE_zunmqr? = load(name: "LAPACKE_zunmqr")
    #elseif os(macOS)
    static let zunmqr: FunctionTypes.LAPACKE_zunmqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrq: FunctionTypes.LAPACKE_cunmrq? = load(name: "LAPACKE_cunmrq")
    #elseif os(macOS)
    static let cunmrq: FunctionTypes.LAPACKE_cunmrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrq: FunctionTypes.LAPACKE_zunmrq? = load(name: "LAPACKE_zunmrq")
    #elseif os(macOS)
    static let zunmrq: FunctionTypes.LAPACKE_zunmrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrz: FunctionTypes.LAPACKE_cunmrz? = load(name: "LAPACKE_cunmrz")
    #elseif os(macOS)
    static let cunmrz: FunctionTypes.LAPACKE_cunmrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrz: FunctionTypes.LAPACKE_zunmrz? = load(name: "LAPACKE_zunmrz")
    #elseif os(macOS)
    static let zunmrz: FunctionTypes.LAPACKE_zunmrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmtr: FunctionTypes.LAPACKE_cunmtr? = load(name: "LAPACKE_cunmtr")
    #elseif os(macOS)
    static let cunmtr: FunctionTypes.LAPACKE_cunmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmtr: FunctionTypes.LAPACKE_zunmtr? = load(name: "LAPACKE_zunmtr")
    #elseif os(macOS)
    static let zunmtr: FunctionTypes.LAPACKE_zunmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupgtr: FunctionTypes.LAPACKE_cupgtr? = load(name: "LAPACKE_cupgtr")
    #elseif os(macOS)
    static let cupgtr: FunctionTypes.LAPACKE_cupgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupgtr: FunctionTypes.LAPACKE_zupgtr? = load(name: "LAPACKE_zupgtr")
    #elseif os(macOS)
    static let zupgtr: FunctionTypes.LAPACKE_zupgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupmtr: FunctionTypes.LAPACKE_cupmtr? = load(name: "LAPACKE_cupmtr")
    #elseif os(macOS)
    static let cupmtr: FunctionTypes.LAPACKE_cupmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupmtr: FunctionTypes.LAPACKE_zupmtr? = load(name: "LAPACKE_zupmtr")
    #elseif os(macOS)
    static let zupmtr: FunctionTypes.LAPACKE_zupmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsdc_work: FunctionTypes.LAPACKE_sbdsdc_work? = load(name: "LAPACKE_sbdsdc_work")
    #elseif os(macOS)
    static let sbdsdc_work: FunctionTypes.LAPACKE_sbdsdc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsdc_work: FunctionTypes.LAPACKE_dbdsdc_work? = load(name: "LAPACKE_dbdsdc_work")
    #elseif os(macOS)
    static let dbdsdc_work: FunctionTypes.LAPACKE_dbdsdc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsvdx_work: FunctionTypes.LAPACKE_sbdsvdx_work? = load(name: "LAPACKE_sbdsvdx_work")
    #elseif os(macOS)
    static let sbdsvdx_work: FunctionTypes.LAPACKE_sbdsvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsvdx_work: FunctionTypes.LAPACKE_dbdsvdx_work? = load(name: "LAPACKE_dbdsvdx_work")
    #elseif os(macOS)
    static let dbdsvdx_work: FunctionTypes.LAPACKE_dbdsvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsqr_work: FunctionTypes.LAPACKE_sbdsqr_work? = load(name: "LAPACKE_sbdsqr_work")
    #elseif os(macOS)
    static let sbdsqr_work: FunctionTypes.LAPACKE_sbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsqr_work: FunctionTypes.LAPACKE_dbdsqr_work? = load(name: "LAPACKE_dbdsqr_work")
    #elseif os(macOS)
    static let dbdsqr_work: FunctionTypes.LAPACKE_dbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbdsqr_work: FunctionTypes.LAPACKE_cbdsqr_work? = load(name: "LAPACKE_cbdsqr_work")
    #elseif os(macOS)
    static let cbdsqr_work: FunctionTypes.LAPACKE_cbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbdsqr_work: FunctionTypes.LAPACKE_zbdsqr_work? = load(name: "LAPACKE_zbdsqr_work")
    #elseif os(macOS)
    static let zbdsqr_work: FunctionTypes.LAPACKE_zbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sdisna_work: FunctionTypes.LAPACKE_sdisna_work? = load(name: "LAPACKE_sdisna_work")
    #elseif os(macOS)
    static let sdisna_work: FunctionTypes.LAPACKE_sdisna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ddisna_work: FunctionTypes.LAPACKE_ddisna_work? = load(name: "LAPACKE_ddisna_work")
    #elseif os(macOS)
    static let ddisna_work: FunctionTypes.LAPACKE_ddisna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbbrd_work: FunctionTypes.LAPACKE_sgbbrd_work? = load(name: "LAPACKE_sgbbrd_work")
    #elseif os(macOS)
    static let sgbbrd_work: FunctionTypes.LAPACKE_sgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbbrd_work: FunctionTypes.LAPACKE_dgbbrd_work? = load(name: "LAPACKE_dgbbrd_work")
    #elseif os(macOS)
    static let dgbbrd_work: FunctionTypes.LAPACKE_dgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbbrd_work: FunctionTypes.LAPACKE_cgbbrd_work? = load(name: "LAPACKE_cgbbrd_work")
    #elseif os(macOS)
    static let cgbbrd_work: FunctionTypes.LAPACKE_cgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbbrd_work: FunctionTypes.LAPACKE_zgbbrd_work? = load(name: "LAPACKE_zgbbrd_work")
    #elseif os(macOS)
    static let zgbbrd_work: FunctionTypes.LAPACKE_zgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbcon_work: FunctionTypes.LAPACKE_sgbcon_work? = load(name: "LAPACKE_sgbcon_work")
    #elseif os(macOS)
    static let sgbcon_work: FunctionTypes.LAPACKE_sgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbcon_work: FunctionTypes.LAPACKE_dgbcon_work? = load(name: "LAPACKE_dgbcon_work")
    #elseif os(macOS)
    static let dgbcon_work: FunctionTypes.LAPACKE_dgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbcon_work: FunctionTypes.LAPACKE_cgbcon_work? = load(name: "LAPACKE_cgbcon_work")
    #elseif os(macOS)
    static let cgbcon_work: FunctionTypes.LAPACKE_cgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbcon_work: FunctionTypes.LAPACKE_zgbcon_work? = load(name: "LAPACKE_zgbcon_work")
    #elseif os(macOS)
    static let zgbcon_work: FunctionTypes.LAPACKE_zgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequ_work: FunctionTypes.LAPACKE_sgbequ_work? = load(name: "LAPACKE_sgbequ_work")
    #elseif os(macOS)
    static let sgbequ_work: FunctionTypes.LAPACKE_sgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequ_work: FunctionTypes.LAPACKE_dgbequ_work? = load(name: "LAPACKE_dgbequ_work")
    #elseif os(macOS)
    static let dgbequ_work: FunctionTypes.LAPACKE_dgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequ_work: FunctionTypes.LAPACKE_cgbequ_work? = load(name: "LAPACKE_cgbequ_work")
    #elseif os(macOS)
    static let cgbequ_work: FunctionTypes.LAPACKE_cgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequ_work: FunctionTypes.LAPACKE_zgbequ_work? = load(name: "LAPACKE_zgbequ_work")
    #elseif os(macOS)
    static let zgbequ_work: FunctionTypes.LAPACKE_zgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequb_work: FunctionTypes.LAPACKE_sgbequb_work? = load(name: "LAPACKE_sgbequb_work")
    #elseif os(macOS)
    static let sgbequb_work: FunctionTypes.LAPACKE_sgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequb_work: FunctionTypes.LAPACKE_dgbequb_work? = load(name: "LAPACKE_dgbequb_work")
    #elseif os(macOS)
    static let dgbequb_work: FunctionTypes.LAPACKE_dgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequb_work: FunctionTypes.LAPACKE_cgbequb_work? = load(name: "LAPACKE_cgbequb_work")
    #elseif os(macOS)
    static let cgbequb_work: FunctionTypes.LAPACKE_cgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequb_work: FunctionTypes.LAPACKE_zgbequb_work? = load(name: "LAPACKE_zgbequb_work")
    #elseif os(macOS)
    static let zgbequb_work: FunctionTypes.LAPACKE_zgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfs_work: FunctionTypes.LAPACKE_sgbrfs_work? = load(name: "LAPACKE_sgbrfs_work")
    #elseif os(macOS)
    static let sgbrfs_work: FunctionTypes.LAPACKE_sgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfs_work: FunctionTypes.LAPACKE_dgbrfs_work? = load(name: "LAPACKE_dgbrfs_work")
    #elseif os(macOS)
    static let dgbrfs_work: FunctionTypes.LAPACKE_dgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfs_work: FunctionTypes.LAPACKE_cgbrfs_work? = load(name: "LAPACKE_cgbrfs_work")
    #elseif os(macOS)
    static let cgbrfs_work: FunctionTypes.LAPACKE_cgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfs_work: FunctionTypes.LAPACKE_zgbrfs_work? = load(name: "LAPACKE_zgbrfs_work")
    #elseif os(macOS)
    static let zgbrfs_work: FunctionTypes.LAPACKE_zgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfsx_work: FunctionTypes.LAPACKE_sgbrfsx_work? = load(name: "LAPACKE_sgbrfsx_work")
    #elseif os(macOS)
    static let sgbrfsx_work: FunctionTypes.LAPACKE_sgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfsx_work: FunctionTypes.LAPACKE_dgbrfsx_work? = load(name: "LAPACKE_dgbrfsx_work")
    #elseif os(macOS)
    static let dgbrfsx_work: FunctionTypes.LAPACKE_dgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfsx_work: FunctionTypes.LAPACKE_cgbrfsx_work? = load(name: "LAPACKE_cgbrfsx_work")
    #elseif os(macOS)
    static let cgbrfsx_work: FunctionTypes.LAPACKE_cgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfsx_work: FunctionTypes.LAPACKE_zgbrfsx_work? = load(name: "LAPACKE_zgbrfsx_work")
    #elseif os(macOS)
    static let zgbrfsx_work: FunctionTypes.LAPACKE_zgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsv_work: FunctionTypes.LAPACKE_sgbsv_work? = load(name: "LAPACKE_sgbsv_work")
    #elseif os(macOS)
    static let sgbsv_work: FunctionTypes.LAPACKE_sgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsv_work: FunctionTypes.LAPACKE_dgbsv_work? = load(name: "LAPACKE_dgbsv_work")
    #elseif os(macOS)
    static let dgbsv_work: FunctionTypes.LAPACKE_dgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsv_work: FunctionTypes.LAPACKE_cgbsv_work? = load(name: "LAPACKE_cgbsv_work")
    #elseif os(macOS)
    static let cgbsv_work: FunctionTypes.LAPACKE_cgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsv_work: FunctionTypes.LAPACKE_zgbsv_work? = load(name: "LAPACKE_zgbsv_work")
    #elseif os(macOS)
    static let zgbsv_work: FunctionTypes.LAPACKE_zgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvx_work: FunctionTypes.LAPACKE_sgbsvx_work? = load(name: "LAPACKE_sgbsvx_work")
    #elseif os(macOS)
    static let sgbsvx_work: FunctionTypes.LAPACKE_sgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvx_work: FunctionTypes.LAPACKE_dgbsvx_work? = load(name: "LAPACKE_dgbsvx_work")
    #elseif os(macOS)
    static let dgbsvx_work: FunctionTypes.LAPACKE_dgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvx_work: FunctionTypes.LAPACKE_cgbsvx_work? = load(name: "LAPACKE_cgbsvx_work")
    #elseif os(macOS)
    static let cgbsvx_work: FunctionTypes.LAPACKE_cgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvx_work: FunctionTypes.LAPACKE_zgbsvx_work? = load(name: "LAPACKE_zgbsvx_work")
    #elseif os(macOS)
    static let zgbsvx_work: FunctionTypes.LAPACKE_zgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvxx_work: FunctionTypes.LAPACKE_sgbsvxx_work? = load(name: "LAPACKE_sgbsvxx_work")
    #elseif os(macOS)
    static let sgbsvxx_work: FunctionTypes.LAPACKE_sgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvxx_work: FunctionTypes.LAPACKE_dgbsvxx_work? = load(name: "LAPACKE_dgbsvxx_work")
    #elseif os(macOS)
    static let dgbsvxx_work: FunctionTypes.LAPACKE_dgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvxx_work: FunctionTypes.LAPACKE_cgbsvxx_work? = load(name: "LAPACKE_cgbsvxx_work")
    #elseif os(macOS)
    static let cgbsvxx_work: FunctionTypes.LAPACKE_cgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvxx_work: FunctionTypes.LAPACKE_zgbsvxx_work? = load(name: "LAPACKE_zgbsvxx_work")
    #elseif os(macOS)
    static let zgbsvxx_work: FunctionTypes.LAPACKE_zgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrf_work: FunctionTypes.LAPACKE_sgbtrf_work? = load(name: "LAPACKE_sgbtrf_work")
    #elseif os(macOS)
    static let sgbtrf_work: FunctionTypes.LAPACKE_sgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrf_work: FunctionTypes.LAPACKE_dgbtrf_work? = load(name: "LAPACKE_dgbtrf_work")
    #elseif os(macOS)
    static let dgbtrf_work: FunctionTypes.LAPACKE_dgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrf_work: FunctionTypes.LAPACKE_cgbtrf_work? = load(name: "LAPACKE_cgbtrf_work")
    #elseif os(macOS)
    static let cgbtrf_work: FunctionTypes.LAPACKE_cgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrf_work: FunctionTypes.LAPACKE_zgbtrf_work? = load(name: "LAPACKE_zgbtrf_work")
    #elseif os(macOS)
    static let zgbtrf_work: FunctionTypes.LAPACKE_zgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrs_work: FunctionTypes.LAPACKE_sgbtrs_work? = load(name: "LAPACKE_sgbtrs_work")
    #elseif os(macOS)
    static let sgbtrs_work: FunctionTypes.LAPACKE_sgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrs_work: FunctionTypes.LAPACKE_dgbtrs_work? = load(name: "LAPACKE_dgbtrs_work")
    #elseif os(macOS)
    static let dgbtrs_work: FunctionTypes.LAPACKE_dgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrs_work: FunctionTypes.LAPACKE_cgbtrs_work? = load(name: "LAPACKE_cgbtrs_work")
    #elseif os(macOS)
    static let cgbtrs_work: FunctionTypes.LAPACKE_cgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrs_work: FunctionTypes.LAPACKE_zgbtrs_work? = load(name: "LAPACKE_zgbtrs_work")
    #elseif os(macOS)
    static let zgbtrs_work: FunctionTypes.LAPACKE_zgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebak_work: FunctionTypes.LAPACKE_sgebak_work? = load(name: "LAPACKE_sgebak_work")
    #elseif os(macOS)
    static let sgebak_work: FunctionTypes.LAPACKE_sgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebak_work: FunctionTypes.LAPACKE_dgebak_work? = load(name: "LAPACKE_dgebak_work")
    #elseif os(macOS)
    static let dgebak_work: FunctionTypes.LAPACKE_dgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebak_work: FunctionTypes.LAPACKE_cgebak_work? = load(name: "LAPACKE_cgebak_work")
    #elseif os(macOS)
    static let cgebak_work: FunctionTypes.LAPACKE_cgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebak_work: FunctionTypes.LAPACKE_zgebak_work? = load(name: "LAPACKE_zgebak_work")
    #elseif os(macOS)
    static let zgebak_work: FunctionTypes.LAPACKE_zgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebal_work: FunctionTypes.LAPACKE_sgebal_work? = load(name: "LAPACKE_sgebal_work")
    #elseif os(macOS)
    static let sgebal_work: FunctionTypes.LAPACKE_sgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebal_work: FunctionTypes.LAPACKE_dgebal_work? = load(name: "LAPACKE_dgebal_work")
    #elseif os(macOS)
    static let dgebal_work: FunctionTypes.LAPACKE_dgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebal_work: FunctionTypes.LAPACKE_cgebal_work? = load(name: "LAPACKE_cgebal_work")
    #elseif os(macOS)
    static let cgebal_work: FunctionTypes.LAPACKE_cgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebal_work: FunctionTypes.LAPACKE_zgebal_work? = load(name: "LAPACKE_zgebal_work")
    #elseif os(macOS)
    static let zgebal_work: FunctionTypes.LAPACKE_zgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebrd_work: FunctionTypes.LAPACKE_sgebrd_work? = load(name: "LAPACKE_sgebrd_work")
    #elseif os(macOS)
    static let sgebrd_work: FunctionTypes.LAPACKE_sgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebrd_work: FunctionTypes.LAPACKE_dgebrd_work? = load(name: "LAPACKE_dgebrd_work")
    #elseif os(macOS)
    static let dgebrd_work: FunctionTypes.LAPACKE_dgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebrd_work: FunctionTypes.LAPACKE_cgebrd_work? = load(name: "LAPACKE_cgebrd_work")
    #elseif os(macOS)
    static let cgebrd_work: FunctionTypes.LAPACKE_cgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebrd_work: FunctionTypes.LAPACKE_zgebrd_work? = load(name: "LAPACKE_zgebrd_work")
    #elseif os(macOS)
    static let zgebrd_work: FunctionTypes.LAPACKE_zgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgecon_work: FunctionTypes.LAPACKE_sgecon_work? = load(name: "LAPACKE_sgecon_work")
    #elseif os(macOS)
    static let sgecon_work: FunctionTypes.LAPACKE_sgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgecon_work: FunctionTypes.LAPACKE_dgecon_work? = load(name: "LAPACKE_dgecon_work")
    #elseif os(macOS)
    static let dgecon_work: FunctionTypes.LAPACKE_dgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgecon_work: FunctionTypes.LAPACKE_cgecon_work? = load(name: "LAPACKE_cgecon_work")
    #elseif os(macOS)
    static let cgecon_work: FunctionTypes.LAPACKE_cgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgecon_work: FunctionTypes.LAPACKE_zgecon_work? = load(name: "LAPACKE_zgecon_work")
    #elseif os(macOS)
    static let zgecon_work: FunctionTypes.LAPACKE_zgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequ_work: FunctionTypes.LAPACKE_sgeequ_work? = load(name: "LAPACKE_sgeequ_work")
    #elseif os(macOS)
    static let sgeequ_work: FunctionTypes.LAPACKE_sgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequ_work: FunctionTypes.LAPACKE_dgeequ_work? = load(name: "LAPACKE_dgeequ_work")
    #elseif os(macOS)
    static let dgeequ_work: FunctionTypes.LAPACKE_dgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequ_work: FunctionTypes.LAPACKE_cgeequ_work? = load(name: "LAPACKE_cgeequ_work")
    #elseif os(macOS)
    static let cgeequ_work: FunctionTypes.LAPACKE_cgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequ_work: FunctionTypes.LAPACKE_zgeequ_work? = load(name: "LAPACKE_zgeequ_work")
    #elseif os(macOS)
    static let zgeequ_work: FunctionTypes.LAPACKE_zgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequb_work: FunctionTypes.LAPACKE_sgeequb_work? = load(name: "LAPACKE_sgeequb_work")
    #elseif os(macOS)
    static let sgeequb_work: FunctionTypes.LAPACKE_sgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequb_work: FunctionTypes.LAPACKE_dgeequb_work? = load(name: "LAPACKE_dgeequb_work")
    #elseif os(macOS)
    static let dgeequb_work: FunctionTypes.LAPACKE_dgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequb_work: FunctionTypes.LAPACKE_cgeequb_work? = load(name: "LAPACKE_cgeequb_work")
    #elseif os(macOS)
    static let cgeequb_work: FunctionTypes.LAPACKE_cgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequb_work: FunctionTypes.LAPACKE_zgeequb_work? = load(name: "LAPACKE_zgeequb_work")
    #elseif os(macOS)
    static let zgeequb_work: FunctionTypes.LAPACKE_zgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgees_work: FunctionTypes.LAPACKE_sgees_work? = load(name: "LAPACKE_sgees_work")
    #elseif os(macOS)
    static let sgees_work: FunctionTypes.LAPACKE_sgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgees_work: FunctionTypes.LAPACKE_dgees_work? = load(name: "LAPACKE_dgees_work")
    #elseif os(macOS)
    static let dgees_work: FunctionTypes.LAPACKE_dgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgees_work: FunctionTypes.LAPACKE_cgees_work? = load(name: "LAPACKE_cgees_work")
    #elseif os(macOS)
    static let cgees_work: FunctionTypes.LAPACKE_cgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgees_work: FunctionTypes.LAPACKE_zgees_work? = load(name: "LAPACKE_zgees_work")
    #elseif os(macOS)
    static let zgees_work: FunctionTypes.LAPACKE_zgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeesx_work: FunctionTypes.LAPACKE_sgeesx_work? = load(name: "LAPACKE_sgeesx_work")
    #elseif os(macOS)
    static let sgeesx_work: FunctionTypes.LAPACKE_sgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeesx_work: FunctionTypes.LAPACKE_dgeesx_work? = load(name: "LAPACKE_dgeesx_work")
    #elseif os(macOS)
    static let dgeesx_work: FunctionTypes.LAPACKE_dgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeesx_work: FunctionTypes.LAPACKE_cgeesx_work? = load(name: "LAPACKE_cgeesx_work")
    #elseif os(macOS)
    static let cgeesx_work: FunctionTypes.LAPACKE_cgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeesx_work: FunctionTypes.LAPACKE_zgeesx_work? = load(name: "LAPACKE_zgeesx_work")
    #elseif os(macOS)
    static let zgeesx_work: FunctionTypes.LAPACKE_zgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeev_work: FunctionTypes.LAPACKE_sgeev_work? = load(name: "LAPACKE_sgeev_work")
    #elseif os(macOS)
    static let sgeev_work: FunctionTypes.LAPACKE_sgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeev_work: FunctionTypes.LAPACKE_dgeev_work? = load(name: "LAPACKE_dgeev_work")
    #elseif os(macOS)
    static let dgeev_work: FunctionTypes.LAPACKE_dgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeev_work: FunctionTypes.LAPACKE_cgeev_work? = load(name: "LAPACKE_cgeev_work")
    #elseif os(macOS)
    static let cgeev_work: FunctionTypes.LAPACKE_cgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeev_work: FunctionTypes.LAPACKE_zgeev_work? = load(name: "LAPACKE_zgeev_work")
    #elseif os(macOS)
    static let zgeev_work: FunctionTypes.LAPACKE_zgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeevx_work: FunctionTypes.LAPACKE_sgeevx_work? = load(name: "LAPACKE_sgeevx_work")
    #elseif os(macOS)
    static let sgeevx_work: FunctionTypes.LAPACKE_sgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeevx_work: FunctionTypes.LAPACKE_dgeevx_work? = load(name: "LAPACKE_dgeevx_work")
    #elseif os(macOS)
    static let dgeevx_work: FunctionTypes.LAPACKE_dgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeevx_work: FunctionTypes.LAPACKE_cgeevx_work? = load(name: "LAPACKE_cgeevx_work")
    #elseif os(macOS)
    static let cgeevx_work: FunctionTypes.LAPACKE_cgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeevx_work: FunctionTypes.LAPACKE_zgeevx_work? = load(name: "LAPACKE_zgeevx_work")
    #elseif os(macOS)
    static let zgeevx_work: FunctionTypes.LAPACKE_zgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgehrd_work: FunctionTypes.LAPACKE_sgehrd_work? = load(name: "LAPACKE_sgehrd_work")
    #elseif os(macOS)
    static let sgehrd_work: FunctionTypes.LAPACKE_sgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgehrd_work: FunctionTypes.LAPACKE_dgehrd_work? = load(name: "LAPACKE_dgehrd_work")
    #elseif os(macOS)
    static let dgehrd_work: FunctionTypes.LAPACKE_dgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgehrd_work: FunctionTypes.LAPACKE_cgehrd_work? = load(name: "LAPACKE_cgehrd_work")
    #elseif os(macOS)
    static let cgehrd_work: FunctionTypes.LAPACKE_cgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgehrd_work: FunctionTypes.LAPACKE_zgehrd_work? = load(name: "LAPACKE_zgehrd_work")
    #elseif os(macOS)
    static let zgehrd_work: FunctionTypes.LAPACKE_zgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgejsv_work: FunctionTypes.LAPACKE_sgejsv_work? = load(name: "LAPACKE_sgejsv_work")
    #elseif os(macOS)
    static let sgejsv_work: FunctionTypes.LAPACKE_sgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgejsv_work: FunctionTypes.LAPACKE_dgejsv_work? = load(name: "LAPACKE_dgejsv_work")
    #elseif os(macOS)
    static let dgejsv_work: FunctionTypes.LAPACKE_dgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgejsv_work: FunctionTypes.LAPACKE_cgejsv_work? = load(name: "LAPACKE_cgejsv_work")
    #elseif os(macOS)
    static let cgejsv_work: FunctionTypes.LAPACKE_cgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgejsv_work: FunctionTypes.LAPACKE_zgejsv_work? = load(name: "LAPACKE_zgejsv_work")
    #elseif os(macOS)
    static let zgejsv_work: FunctionTypes.LAPACKE_zgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq2_work: FunctionTypes.LAPACKE_sgelq2_work? = load(name: "LAPACKE_sgelq2_work")
    #elseif os(macOS)
    static let sgelq2_work: FunctionTypes.LAPACKE_sgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq2_work: FunctionTypes.LAPACKE_dgelq2_work? = load(name: "LAPACKE_dgelq2_work")
    #elseif os(macOS)
    static let dgelq2_work: FunctionTypes.LAPACKE_dgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq2_work: FunctionTypes.LAPACKE_cgelq2_work? = load(name: "LAPACKE_cgelq2_work")
    #elseif os(macOS)
    static let cgelq2_work: FunctionTypes.LAPACKE_cgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq2_work: FunctionTypes.LAPACKE_zgelq2_work? = load(name: "LAPACKE_zgelq2_work")
    #elseif os(macOS)
    static let zgelq2_work: FunctionTypes.LAPACKE_zgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelqf_work: FunctionTypes.LAPACKE_sgelqf_work? = load(name: "LAPACKE_sgelqf_work")
    #elseif os(macOS)
    static let sgelqf_work: FunctionTypes.LAPACKE_sgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelqf_work: FunctionTypes.LAPACKE_dgelqf_work? = load(name: "LAPACKE_dgelqf_work")
    #elseif os(macOS)
    static let dgelqf_work: FunctionTypes.LAPACKE_dgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelqf_work: FunctionTypes.LAPACKE_cgelqf_work? = load(name: "LAPACKE_cgelqf_work")
    #elseif os(macOS)
    static let cgelqf_work: FunctionTypes.LAPACKE_cgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelqf_work: FunctionTypes.LAPACKE_zgelqf_work? = load(name: "LAPACKE_zgelqf_work")
    #elseif os(macOS)
    static let zgelqf_work: FunctionTypes.LAPACKE_zgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgels_work: FunctionTypes.LAPACKE_sgels_work? = load(name: "LAPACKE_sgels_work")
    #elseif os(macOS)
    static let sgels_work: FunctionTypes.LAPACKE_sgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgels_work: FunctionTypes.LAPACKE_dgels_work? = load(name: "LAPACKE_dgels_work")
    #elseif os(macOS)
    static let dgels_work: FunctionTypes.LAPACKE_dgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgels_work: FunctionTypes.LAPACKE_cgels_work? = load(name: "LAPACKE_cgels_work")
    #elseif os(macOS)
    static let cgels_work: FunctionTypes.LAPACKE_cgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgels_work: FunctionTypes.LAPACKE_zgels_work? = load(name: "LAPACKE_zgels_work")
    #elseif os(macOS)
    static let zgels_work: FunctionTypes.LAPACKE_zgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsd_work: FunctionTypes.LAPACKE_sgelsd_work? = load(name: "LAPACKE_sgelsd_work")
    #elseif os(macOS)
    static let sgelsd_work: FunctionTypes.LAPACKE_sgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsd_work: FunctionTypes.LAPACKE_dgelsd_work? = load(name: "LAPACKE_dgelsd_work")
    #elseif os(macOS)
    static let dgelsd_work: FunctionTypes.LAPACKE_dgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsd_work: FunctionTypes.LAPACKE_cgelsd_work? = load(name: "LAPACKE_cgelsd_work")
    #elseif os(macOS)
    static let cgelsd_work: FunctionTypes.LAPACKE_cgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsd_work: FunctionTypes.LAPACKE_zgelsd_work? = load(name: "LAPACKE_zgelsd_work")
    #elseif os(macOS)
    static let zgelsd_work: FunctionTypes.LAPACKE_zgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelss_work: FunctionTypes.LAPACKE_sgelss_work? = load(name: "LAPACKE_sgelss_work")
    #elseif os(macOS)
    static let sgelss_work: FunctionTypes.LAPACKE_sgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelss_work: FunctionTypes.LAPACKE_dgelss_work? = load(name: "LAPACKE_dgelss_work")
    #elseif os(macOS)
    static let dgelss_work: FunctionTypes.LAPACKE_dgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelss_work: FunctionTypes.LAPACKE_cgelss_work? = load(name: "LAPACKE_cgelss_work")
    #elseif os(macOS)
    static let cgelss_work: FunctionTypes.LAPACKE_cgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelss_work: FunctionTypes.LAPACKE_zgelss_work? = load(name: "LAPACKE_zgelss_work")
    #elseif os(macOS)
    static let zgelss_work: FunctionTypes.LAPACKE_zgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsy_work: FunctionTypes.LAPACKE_sgelsy_work? = load(name: "LAPACKE_sgelsy_work")
    #elseif os(macOS)
    static let sgelsy_work: FunctionTypes.LAPACKE_sgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsy_work: FunctionTypes.LAPACKE_dgelsy_work? = load(name: "LAPACKE_dgelsy_work")
    #elseif os(macOS)
    static let dgelsy_work: FunctionTypes.LAPACKE_dgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsy_work: FunctionTypes.LAPACKE_cgelsy_work? = load(name: "LAPACKE_cgelsy_work")
    #elseif os(macOS)
    static let cgelsy_work: FunctionTypes.LAPACKE_cgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsy_work: FunctionTypes.LAPACKE_zgelsy_work? = load(name: "LAPACKE_zgelsy_work")
    #elseif os(macOS)
    static let zgelsy_work: FunctionTypes.LAPACKE_zgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqlf_work: FunctionTypes.LAPACKE_sgeqlf_work? = load(name: "LAPACKE_sgeqlf_work")
    #elseif os(macOS)
    static let sgeqlf_work: FunctionTypes.LAPACKE_sgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqlf_work: FunctionTypes.LAPACKE_dgeqlf_work? = load(name: "LAPACKE_dgeqlf_work")
    #elseif os(macOS)
    static let dgeqlf_work: FunctionTypes.LAPACKE_dgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqlf_work: FunctionTypes.LAPACKE_cgeqlf_work? = load(name: "LAPACKE_cgeqlf_work")
    #elseif os(macOS)
    static let cgeqlf_work: FunctionTypes.LAPACKE_cgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqlf_work: FunctionTypes.LAPACKE_zgeqlf_work? = load(name: "LAPACKE_zgeqlf_work")
    #elseif os(macOS)
    static let zgeqlf_work: FunctionTypes.LAPACKE_zgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqp3_work: FunctionTypes.LAPACKE_sgeqp3_work? = load(name: "LAPACKE_sgeqp3_work")
    #elseif os(macOS)
    static let sgeqp3_work: FunctionTypes.LAPACKE_sgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqp3_work: FunctionTypes.LAPACKE_dgeqp3_work? = load(name: "LAPACKE_dgeqp3_work")
    #elseif os(macOS)
    static let dgeqp3_work: FunctionTypes.LAPACKE_dgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqp3_work: FunctionTypes.LAPACKE_cgeqp3_work? = load(name: "LAPACKE_cgeqp3_work")
    #elseif os(macOS)
    static let cgeqp3_work: FunctionTypes.LAPACKE_cgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqp3_work: FunctionTypes.LAPACKE_zgeqp3_work? = load(name: "LAPACKE_zgeqp3_work")
    #elseif os(macOS)
    static let zgeqp3_work: FunctionTypes.LAPACKE_zgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqpf_work: FunctionTypes.LAPACKE_sgeqpf_work? = load(name: "LAPACKE_sgeqpf_work")
    #elseif os(macOS)
    static let sgeqpf_work: FunctionTypes.LAPACKE_sgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqpf_work: FunctionTypes.LAPACKE_dgeqpf_work? = load(name: "LAPACKE_dgeqpf_work")
    #elseif os(macOS)
    static let dgeqpf_work: FunctionTypes.LAPACKE_dgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqpf_work: FunctionTypes.LAPACKE_cgeqpf_work? = load(name: "LAPACKE_cgeqpf_work")
    #elseif os(macOS)
    static let cgeqpf_work: FunctionTypes.LAPACKE_cgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqpf_work: FunctionTypes.LAPACKE_zgeqpf_work? = load(name: "LAPACKE_zgeqpf_work")
    #elseif os(macOS)
    static let zgeqpf_work: FunctionTypes.LAPACKE_zgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr2_work: FunctionTypes.LAPACKE_sgeqr2_work? = load(name: "LAPACKE_sgeqr2_work")
    #elseif os(macOS)
    static let sgeqr2_work: FunctionTypes.LAPACKE_sgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr2_work: FunctionTypes.LAPACKE_dgeqr2_work? = load(name: "LAPACKE_dgeqr2_work")
    #elseif os(macOS)
    static let dgeqr2_work: FunctionTypes.LAPACKE_dgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr2_work: FunctionTypes.LAPACKE_cgeqr2_work? = load(name: "LAPACKE_cgeqr2_work")
    #elseif os(macOS)
    static let cgeqr2_work: FunctionTypes.LAPACKE_cgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr2_work: FunctionTypes.LAPACKE_zgeqr2_work? = load(name: "LAPACKE_zgeqr2_work")
    #elseif os(macOS)
    static let zgeqr2_work: FunctionTypes.LAPACKE_zgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrf_work: FunctionTypes.LAPACKE_sgeqrf_work? = load(name: "LAPACKE_sgeqrf_work")
    #elseif os(macOS)
    static let sgeqrf_work: FunctionTypes.LAPACKE_sgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrf_work: FunctionTypes.LAPACKE_dgeqrf_work? = load(name: "LAPACKE_dgeqrf_work")
    #elseif os(macOS)
    static let dgeqrf_work: FunctionTypes.LAPACKE_dgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrf_work: FunctionTypes.LAPACKE_cgeqrf_work? = load(name: "LAPACKE_cgeqrf_work")
    #elseif os(macOS)
    static let cgeqrf_work: FunctionTypes.LAPACKE_cgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrf_work: FunctionTypes.LAPACKE_zgeqrf_work? = load(name: "LAPACKE_zgeqrf_work")
    #elseif os(macOS)
    static let zgeqrf_work: FunctionTypes.LAPACKE_zgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrfp_work: FunctionTypes.LAPACKE_sgeqrfp_work? = load(name: "LAPACKE_sgeqrfp_work")
    #elseif os(macOS)
    static let sgeqrfp_work: FunctionTypes.LAPACKE_sgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrfp_work: FunctionTypes.LAPACKE_dgeqrfp_work? = load(name: "LAPACKE_dgeqrfp_work")
    #elseif os(macOS)
    static let dgeqrfp_work: FunctionTypes.LAPACKE_dgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrfp_work: FunctionTypes.LAPACKE_cgeqrfp_work? = load(name: "LAPACKE_cgeqrfp_work")
    #elseif os(macOS)
    static let cgeqrfp_work: FunctionTypes.LAPACKE_cgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrfp_work: FunctionTypes.LAPACKE_zgeqrfp_work? = load(name: "LAPACKE_zgeqrfp_work")
    #elseif os(macOS)
    static let zgeqrfp_work: FunctionTypes.LAPACKE_zgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfs_work: FunctionTypes.LAPACKE_sgerfs_work? = load(name: "LAPACKE_sgerfs_work")
    #elseif os(macOS)
    static let sgerfs_work: FunctionTypes.LAPACKE_sgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfs_work: FunctionTypes.LAPACKE_dgerfs_work? = load(name: "LAPACKE_dgerfs_work")
    #elseif os(macOS)
    static let dgerfs_work: FunctionTypes.LAPACKE_dgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfs_work: FunctionTypes.LAPACKE_cgerfs_work? = load(name: "LAPACKE_cgerfs_work")
    #elseif os(macOS)
    static let cgerfs_work: FunctionTypes.LAPACKE_cgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfs_work: FunctionTypes.LAPACKE_zgerfs_work? = load(name: "LAPACKE_zgerfs_work")
    #elseif os(macOS)
    static let zgerfs_work: FunctionTypes.LAPACKE_zgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfsx_work: FunctionTypes.LAPACKE_sgerfsx_work? = load(name: "LAPACKE_sgerfsx_work")
    #elseif os(macOS)
    static let sgerfsx_work: FunctionTypes.LAPACKE_sgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfsx_work: FunctionTypes.LAPACKE_dgerfsx_work? = load(name: "LAPACKE_dgerfsx_work")
    #elseif os(macOS)
    static let dgerfsx_work: FunctionTypes.LAPACKE_dgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfsx_work: FunctionTypes.LAPACKE_cgerfsx_work? = load(name: "LAPACKE_cgerfsx_work")
    #elseif os(macOS)
    static let cgerfsx_work: FunctionTypes.LAPACKE_cgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfsx_work: FunctionTypes.LAPACKE_zgerfsx_work? = load(name: "LAPACKE_zgerfsx_work")
    #elseif os(macOS)
    static let zgerfsx_work: FunctionTypes.LAPACKE_zgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerqf_work: FunctionTypes.LAPACKE_sgerqf_work? = load(name: "LAPACKE_sgerqf_work")
    #elseif os(macOS)
    static let sgerqf_work: FunctionTypes.LAPACKE_sgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerqf_work: FunctionTypes.LAPACKE_dgerqf_work? = load(name: "LAPACKE_dgerqf_work")
    #elseif os(macOS)
    static let dgerqf_work: FunctionTypes.LAPACKE_dgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerqf_work: FunctionTypes.LAPACKE_cgerqf_work? = load(name: "LAPACKE_cgerqf_work")
    #elseif os(macOS)
    static let cgerqf_work: FunctionTypes.LAPACKE_cgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerqf_work: FunctionTypes.LAPACKE_zgerqf_work? = load(name: "LAPACKE_zgerqf_work")
    #elseif os(macOS)
    static let zgerqf_work: FunctionTypes.LAPACKE_zgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesdd_work: FunctionTypes.LAPACKE_sgesdd_work? = load(name: "LAPACKE_sgesdd_work")
    #elseif os(macOS)
    static let sgesdd_work: FunctionTypes.LAPACKE_sgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesdd_work: FunctionTypes.LAPACKE_dgesdd_work? = load(name: "LAPACKE_dgesdd_work")
    #elseif os(macOS)
    static let dgesdd_work: FunctionTypes.LAPACKE_dgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesdd_work: FunctionTypes.LAPACKE_cgesdd_work? = load(name: "LAPACKE_cgesdd_work")
    #elseif os(macOS)
    static let cgesdd_work: FunctionTypes.LAPACKE_cgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesdd_work: FunctionTypes.LAPACKE_zgesdd_work? = load(name: "LAPACKE_zgesdd_work")
    #elseif os(macOS)
    static let zgesdd_work: FunctionTypes.LAPACKE_zgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgedmd_work: FunctionTypes.LAPACKE_sgedmd_work? = load(name: "LAPACKE_sgedmd_work")
    #elseif os(macOS)
    static let sgedmd_work: FunctionTypes.LAPACKE_sgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgedmd_work: FunctionTypes.LAPACKE_dgedmd_work? = load(name: "LAPACKE_dgedmd_work")
    #elseif os(macOS)
    static let dgedmd_work: FunctionTypes.LAPACKE_dgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgedmd_work: FunctionTypes.LAPACKE_cgedmd_work? = load(name: "LAPACKE_cgedmd_work")
    #elseif os(macOS)
    static let cgedmd_work: FunctionTypes.LAPACKE_cgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgedmd_work: FunctionTypes.LAPACKE_zgedmd_work? = load(name: "LAPACKE_zgedmd_work")
    #elseif os(macOS)
    static let zgedmd_work: FunctionTypes.LAPACKE_zgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgedmdq_work: FunctionTypes.LAPACKE_sgedmdq_work? = load(name: "LAPACKE_sgedmdq_work")
    #elseif os(macOS)
    static let sgedmdq_work: FunctionTypes.LAPACKE_sgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgedmdq_work: FunctionTypes.LAPACKE_dgedmdq_work? = load(name: "LAPACKE_dgedmdq_work")
    #elseif os(macOS)
    static let dgedmdq_work: FunctionTypes.LAPACKE_dgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgedmdq_work: FunctionTypes.LAPACKE_cgedmdq_work? = load(name: "LAPACKE_cgedmdq_work")
    #elseif os(macOS)
    static let cgedmdq_work: FunctionTypes.LAPACKE_cgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgedmdq_work: FunctionTypes.LAPACKE_zgedmdq_work? = load(name: "LAPACKE_zgedmdq_work")
    #elseif os(macOS)
    static let zgedmdq_work: FunctionTypes.LAPACKE_zgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesv_work: FunctionTypes.LAPACKE_sgesv_work? = load(name: "LAPACKE_sgesv_work")
    #elseif os(macOS)
    static let sgesv_work: FunctionTypes.LAPACKE_sgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesv_work: FunctionTypes.LAPACKE_dgesv_work? = load(name: "LAPACKE_dgesv_work")
    #elseif os(macOS)
    static let dgesv_work: FunctionTypes.LAPACKE_dgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesv_work: FunctionTypes.LAPACKE_cgesv_work? = load(name: "LAPACKE_cgesv_work")
    #elseif os(macOS)
    static let cgesv_work: FunctionTypes.LAPACKE_cgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesv_work: FunctionTypes.LAPACKE_zgesv_work? = load(name: "LAPACKE_zgesv_work")
    #elseif os(macOS)
    static let zgesv_work: FunctionTypes.LAPACKE_zgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsgesv_work: FunctionTypes.LAPACKE_dsgesv_work? = load(name: "LAPACKE_dsgesv_work")
    #elseif os(macOS)
    static let dsgesv_work: FunctionTypes.LAPACKE_dsgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcgesv_work: FunctionTypes.LAPACKE_zcgesv_work? = load(name: "LAPACKE_zcgesv_work")
    #elseif os(macOS)
    static let zcgesv_work: FunctionTypes.LAPACKE_zcgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvd_work: FunctionTypes.LAPACKE_sgesvd_work? = load(name: "LAPACKE_sgesvd_work")
    #elseif os(macOS)
    static let sgesvd_work: FunctionTypes.LAPACKE_sgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvd_work: FunctionTypes.LAPACKE_dgesvd_work? = load(name: "LAPACKE_dgesvd_work")
    #elseif os(macOS)
    static let dgesvd_work: FunctionTypes.LAPACKE_dgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvd_work: FunctionTypes.LAPACKE_cgesvd_work? = load(name: "LAPACKE_cgesvd_work")
    #elseif os(macOS)
    static let cgesvd_work: FunctionTypes.LAPACKE_cgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvd_work: FunctionTypes.LAPACKE_zgesvd_work? = load(name: "LAPACKE_zgesvd_work")
    #elseif os(macOS)
    static let zgesvd_work: FunctionTypes.LAPACKE_zgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdx_work: FunctionTypes.LAPACKE_sgesvdx_work? = load(name: "LAPACKE_sgesvdx_work")
    #elseif os(macOS)
    static let sgesvdx_work: FunctionTypes.LAPACKE_sgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdx_work: FunctionTypes.LAPACKE_dgesvdx_work? = load(name: "LAPACKE_dgesvdx_work")
    #elseif os(macOS)
    static let dgesvdx_work: FunctionTypes.LAPACKE_dgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdx_work: FunctionTypes.LAPACKE_cgesvdx_work? = load(name: "LAPACKE_cgesvdx_work")
    #elseif os(macOS)
    static let cgesvdx_work: FunctionTypes.LAPACKE_cgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdx_work: FunctionTypes.LAPACKE_zgesvdx_work? = load(name: "LAPACKE_zgesvdx_work")
    #elseif os(macOS)
    static let zgesvdx_work: FunctionTypes.LAPACKE_zgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdq_work: FunctionTypes.LAPACKE_sgesvdq_work? = load(name: "LAPACKE_sgesvdq_work")
    #elseif os(macOS)
    static let sgesvdq_work: FunctionTypes.LAPACKE_sgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdq_work: FunctionTypes.LAPACKE_dgesvdq_work? = load(name: "LAPACKE_dgesvdq_work")
    #elseif os(macOS)
    static let dgesvdq_work: FunctionTypes.LAPACKE_dgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdq_work: FunctionTypes.LAPACKE_cgesvdq_work? = load(name: "LAPACKE_cgesvdq_work")
    #elseif os(macOS)
    static let cgesvdq_work: FunctionTypes.LAPACKE_cgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdq_work: FunctionTypes.LAPACKE_zgesvdq_work? = load(name: "LAPACKE_zgesvdq_work")
    #elseif os(macOS)
    static let zgesvdq_work: FunctionTypes.LAPACKE_zgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvj_work: FunctionTypes.LAPACKE_sgesvj_work? = load(name: "LAPACKE_sgesvj_work")
    #elseif os(macOS)
    static let sgesvj_work: FunctionTypes.LAPACKE_sgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvj_work: FunctionTypes.LAPACKE_dgesvj_work? = load(name: "LAPACKE_dgesvj_work")
    #elseif os(macOS)
    static let dgesvj_work: FunctionTypes.LAPACKE_dgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvj_work: FunctionTypes.LAPACKE_cgesvj_work? = load(name: "LAPACKE_cgesvj_work")
    #elseif os(macOS)
    static let cgesvj_work: FunctionTypes.LAPACKE_cgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvj_work: FunctionTypes.LAPACKE_zgesvj_work? = load(name: "LAPACKE_zgesvj_work")
    #elseif os(macOS)
    static let zgesvj_work: FunctionTypes.LAPACKE_zgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvx_work: FunctionTypes.LAPACKE_sgesvx_work? = load(name: "LAPACKE_sgesvx_work")
    #elseif os(macOS)
    static let sgesvx_work: FunctionTypes.LAPACKE_sgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvx_work: FunctionTypes.LAPACKE_dgesvx_work? = load(name: "LAPACKE_dgesvx_work")
    #elseif os(macOS)
    static let dgesvx_work: FunctionTypes.LAPACKE_dgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvx_work: FunctionTypes.LAPACKE_cgesvx_work? = load(name: "LAPACKE_cgesvx_work")
    #elseif os(macOS)
    static let cgesvx_work: FunctionTypes.LAPACKE_cgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvx_work: FunctionTypes.LAPACKE_zgesvx_work? = load(name: "LAPACKE_zgesvx_work")
    #elseif os(macOS)
    static let zgesvx_work: FunctionTypes.LAPACKE_zgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvxx_work: FunctionTypes.LAPACKE_sgesvxx_work? = load(name: "LAPACKE_sgesvxx_work")
    #elseif os(macOS)
    static let sgesvxx_work: FunctionTypes.LAPACKE_sgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvxx_work: FunctionTypes.LAPACKE_dgesvxx_work? = load(name: "LAPACKE_dgesvxx_work")
    #elseif os(macOS)
    static let dgesvxx_work: FunctionTypes.LAPACKE_dgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvxx_work: FunctionTypes.LAPACKE_cgesvxx_work? = load(name: "LAPACKE_cgesvxx_work")
    #elseif os(macOS)
    static let cgesvxx_work: FunctionTypes.LAPACKE_cgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvxx_work: FunctionTypes.LAPACKE_zgesvxx_work? = load(name: "LAPACKE_zgesvxx_work")
    #elseif os(macOS)
    static let zgesvxx_work: FunctionTypes.LAPACKE_zgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetf2_work: FunctionTypes.LAPACKE_sgetf2_work? = load(name: "LAPACKE_sgetf2_work")
    #elseif os(macOS)
    static let sgetf2_work: FunctionTypes.LAPACKE_sgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetf2_work: FunctionTypes.LAPACKE_dgetf2_work? = load(name: "LAPACKE_dgetf2_work")
    #elseif os(macOS)
    static let dgetf2_work: FunctionTypes.LAPACKE_dgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetf2_work: FunctionTypes.LAPACKE_cgetf2_work? = load(name: "LAPACKE_cgetf2_work")
    #elseif os(macOS)
    static let cgetf2_work: FunctionTypes.LAPACKE_cgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetf2_work: FunctionTypes.LAPACKE_zgetf2_work? = load(name: "LAPACKE_zgetf2_work")
    #elseif os(macOS)
    static let zgetf2_work: FunctionTypes.LAPACKE_zgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf_work: FunctionTypes.LAPACKE_sgetrf_work? = load(name: "LAPACKE_sgetrf_work")
    #elseif os(macOS)
    static let sgetrf_work: FunctionTypes.LAPACKE_sgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf_work: FunctionTypes.LAPACKE_dgetrf_work? = load(name: "LAPACKE_dgetrf_work")
    #elseif os(macOS)
    static let dgetrf_work: FunctionTypes.LAPACKE_dgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf_work: FunctionTypes.LAPACKE_cgetrf_work? = load(name: "LAPACKE_cgetrf_work")
    #elseif os(macOS)
    static let cgetrf_work: FunctionTypes.LAPACKE_cgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf_work: FunctionTypes.LAPACKE_zgetrf_work? = load(name: "LAPACKE_zgetrf_work")
    #elseif os(macOS)
    static let zgetrf_work: FunctionTypes.LAPACKE_zgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf2_work: FunctionTypes.LAPACKE_sgetrf2_work? = load(name: "LAPACKE_sgetrf2_work")
    #elseif os(macOS)
    static let sgetrf2_work: FunctionTypes.LAPACKE_sgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf2_work: FunctionTypes.LAPACKE_dgetrf2_work? = load(name: "LAPACKE_dgetrf2_work")
    #elseif os(macOS)
    static let dgetrf2_work: FunctionTypes.LAPACKE_dgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf2_work: FunctionTypes.LAPACKE_cgetrf2_work? = load(name: "LAPACKE_cgetrf2_work")
    #elseif os(macOS)
    static let cgetrf2_work: FunctionTypes.LAPACKE_cgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf2_work: FunctionTypes.LAPACKE_zgetrf2_work? = load(name: "LAPACKE_zgetrf2_work")
    #elseif os(macOS)
    static let zgetrf2_work: FunctionTypes.LAPACKE_zgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetri_work: FunctionTypes.LAPACKE_sgetri_work? = load(name: "LAPACKE_sgetri_work")
    #elseif os(macOS)
    static let sgetri_work: FunctionTypes.LAPACKE_sgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetri_work: FunctionTypes.LAPACKE_dgetri_work? = load(name: "LAPACKE_dgetri_work")
    #elseif os(macOS)
    static let dgetri_work: FunctionTypes.LAPACKE_dgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetri_work: FunctionTypes.LAPACKE_cgetri_work? = load(name: "LAPACKE_cgetri_work")
    #elseif os(macOS)
    static let cgetri_work: FunctionTypes.LAPACKE_cgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetri_work: FunctionTypes.LAPACKE_zgetri_work? = load(name: "LAPACKE_zgetri_work")
    #elseif os(macOS)
    static let zgetri_work: FunctionTypes.LAPACKE_zgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrs_work: FunctionTypes.LAPACKE_sgetrs_work? = load(name: "LAPACKE_sgetrs_work")
    #elseif os(macOS)
    static let sgetrs_work: FunctionTypes.LAPACKE_sgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrs_work: FunctionTypes.LAPACKE_dgetrs_work? = load(name: "LAPACKE_dgetrs_work")
    #elseif os(macOS)
    static let dgetrs_work: FunctionTypes.LAPACKE_dgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrs_work: FunctionTypes.LAPACKE_cgetrs_work? = load(name: "LAPACKE_cgetrs_work")
    #elseif os(macOS)
    static let cgetrs_work: FunctionTypes.LAPACKE_cgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrs_work: FunctionTypes.LAPACKE_zgetrs_work? = load(name: "LAPACKE_zgetrs_work")
    #elseif os(macOS)
    static let zgetrs_work: FunctionTypes.LAPACKE_zgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbak_work: FunctionTypes.LAPACKE_sggbak_work? = load(name: "LAPACKE_sggbak_work")
    #elseif os(macOS)
    static let sggbak_work: FunctionTypes.LAPACKE_sggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbak_work: FunctionTypes.LAPACKE_dggbak_work? = load(name: "LAPACKE_dggbak_work")
    #elseif os(macOS)
    static let dggbak_work: FunctionTypes.LAPACKE_dggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbak_work: FunctionTypes.LAPACKE_cggbak_work? = load(name: "LAPACKE_cggbak_work")
    #elseif os(macOS)
    static let cggbak_work: FunctionTypes.LAPACKE_cggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbak_work: FunctionTypes.LAPACKE_zggbak_work? = load(name: "LAPACKE_zggbak_work")
    #elseif os(macOS)
    static let zggbak_work: FunctionTypes.LAPACKE_zggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbal_work: FunctionTypes.LAPACKE_sggbal_work? = load(name: "LAPACKE_sggbal_work")
    #elseif os(macOS)
    static let sggbal_work: FunctionTypes.LAPACKE_sggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbal_work: FunctionTypes.LAPACKE_dggbal_work? = load(name: "LAPACKE_dggbal_work")
    #elseif os(macOS)
    static let dggbal_work: FunctionTypes.LAPACKE_dggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbal_work: FunctionTypes.LAPACKE_cggbal_work? = load(name: "LAPACKE_cggbal_work")
    #elseif os(macOS)
    static let cggbal_work: FunctionTypes.LAPACKE_cggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbal_work: FunctionTypes.LAPACKE_zggbal_work? = load(name: "LAPACKE_zggbal_work")
    #elseif os(macOS)
    static let zggbal_work: FunctionTypes.LAPACKE_zggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges_work: FunctionTypes.LAPACKE_sgges_work? = load(name: "LAPACKE_sgges_work")
    #elseif os(macOS)
    static let sgges_work: FunctionTypes.LAPACKE_sgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges_work: FunctionTypes.LAPACKE_dgges_work? = load(name: "LAPACKE_dgges_work")
    #elseif os(macOS)
    static let dgges_work: FunctionTypes.LAPACKE_dgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges_work: FunctionTypes.LAPACKE_cgges_work? = load(name: "LAPACKE_cgges_work")
    #elseif os(macOS)
    static let cgges_work: FunctionTypes.LAPACKE_cgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges_work: FunctionTypes.LAPACKE_zgges_work? = load(name: "LAPACKE_zgges_work")
    #elseif os(macOS)
    static let zgges_work: FunctionTypes.LAPACKE_zgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges3_work: FunctionTypes.LAPACKE_sgges3_work? = load(name: "LAPACKE_sgges3_work")
    #elseif os(macOS)
    static let sgges3_work: FunctionTypes.LAPACKE_sgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges3_work: FunctionTypes.LAPACKE_dgges3_work? = load(name: "LAPACKE_dgges3_work")
    #elseif os(macOS)
    static let dgges3_work: FunctionTypes.LAPACKE_dgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges3_work: FunctionTypes.LAPACKE_cgges3_work? = load(name: "LAPACKE_cgges3_work")
    #elseif os(macOS)
    static let cgges3_work: FunctionTypes.LAPACKE_cgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges3_work: FunctionTypes.LAPACKE_zgges3_work? = load(name: "LAPACKE_zgges3_work")
    #elseif os(macOS)
    static let zgges3_work: FunctionTypes.LAPACKE_zgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggesx_work: FunctionTypes.LAPACKE_sggesx_work? = load(name: "LAPACKE_sggesx_work")
    #elseif os(macOS)
    static let sggesx_work: FunctionTypes.LAPACKE_sggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggesx_work: FunctionTypes.LAPACKE_dggesx_work? = load(name: "LAPACKE_dggesx_work")
    #elseif os(macOS)
    static let dggesx_work: FunctionTypes.LAPACKE_dggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggesx_work: FunctionTypes.LAPACKE_cggesx_work? = load(name: "LAPACKE_cggesx_work")
    #elseif os(macOS)
    static let cggesx_work: FunctionTypes.LAPACKE_cggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggesx_work: FunctionTypes.LAPACKE_zggesx_work? = load(name: "LAPACKE_zggesx_work")
    #elseif os(macOS)
    static let zggesx_work: FunctionTypes.LAPACKE_zggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev_work: FunctionTypes.LAPACKE_sggev_work? = load(name: "LAPACKE_sggev_work")
    #elseif os(macOS)
    static let sggev_work: FunctionTypes.LAPACKE_sggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev_work: FunctionTypes.LAPACKE_dggev_work? = load(name: "LAPACKE_dggev_work")
    #elseif os(macOS)
    static let dggev_work: FunctionTypes.LAPACKE_dggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev_work: FunctionTypes.LAPACKE_cggev_work? = load(name: "LAPACKE_cggev_work")
    #elseif os(macOS)
    static let cggev_work: FunctionTypes.LAPACKE_cggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev_work: FunctionTypes.LAPACKE_zggev_work? = load(name: "LAPACKE_zggev_work")
    #elseif os(macOS)
    static let zggev_work: FunctionTypes.LAPACKE_zggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev3_work: FunctionTypes.LAPACKE_sggev3_work? = load(name: "LAPACKE_sggev3_work")
    #elseif os(macOS)
    static let sggev3_work: FunctionTypes.LAPACKE_sggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev3_work: FunctionTypes.LAPACKE_dggev3_work? = load(name: "LAPACKE_dggev3_work")
    #elseif os(macOS)
    static let dggev3_work: FunctionTypes.LAPACKE_dggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev3_work: FunctionTypes.LAPACKE_cggev3_work? = load(name: "LAPACKE_cggev3_work")
    #elseif os(macOS)
    static let cggev3_work: FunctionTypes.LAPACKE_cggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev3_work: FunctionTypes.LAPACKE_zggev3_work? = load(name: "LAPACKE_zggev3_work")
    #elseif os(macOS)
    static let zggev3_work: FunctionTypes.LAPACKE_zggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggevx_work: FunctionTypes.LAPACKE_sggevx_work? = load(name: "LAPACKE_sggevx_work")
    #elseif os(macOS)
    static let sggevx_work: FunctionTypes.LAPACKE_sggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggevx_work: FunctionTypes.LAPACKE_dggevx_work? = load(name: "LAPACKE_dggevx_work")
    #elseif os(macOS)
    static let dggevx_work: FunctionTypes.LAPACKE_dggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggevx_work: FunctionTypes.LAPACKE_cggevx_work? = load(name: "LAPACKE_cggevx_work")
    #elseif os(macOS)
    static let cggevx_work: FunctionTypes.LAPACKE_cggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggevx_work: FunctionTypes.LAPACKE_zggevx_work? = load(name: "LAPACKE_zggevx_work")
    #elseif os(macOS)
    static let zggevx_work: FunctionTypes.LAPACKE_zggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggglm_work: FunctionTypes.LAPACKE_sggglm_work? = load(name: "LAPACKE_sggglm_work")
    #elseif os(macOS)
    static let sggglm_work: FunctionTypes.LAPACKE_sggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggglm_work: FunctionTypes.LAPACKE_dggglm_work? = load(name: "LAPACKE_dggglm_work")
    #elseif os(macOS)
    static let dggglm_work: FunctionTypes.LAPACKE_dggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggglm_work: FunctionTypes.LAPACKE_cggglm_work? = load(name: "LAPACKE_cggglm_work")
    #elseif os(macOS)
    static let cggglm_work: FunctionTypes.LAPACKE_cggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggglm_work: FunctionTypes.LAPACKE_zggglm_work? = load(name: "LAPACKE_zggglm_work")
    #elseif os(macOS)
    static let zggglm_work: FunctionTypes.LAPACKE_zggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghrd_work: FunctionTypes.LAPACKE_sgghrd_work? = load(name: "LAPACKE_sgghrd_work")
    #elseif os(macOS)
    static let sgghrd_work: FunctionTypes.LAPACKE_sgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghrd_work: FunctionTypes.LAPACKE_dgghrd_work? = load(name: "LAPACKE_dgghrd_work")
    #elseif os(macOS)
    static let dgghrd_work: FunctionTypes.LAPACKE_dgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghrd_work: FunctionTypes.LAPACKE_cgghrd_work? = load(name: "LAPACKE_cgghrd_work")
    #elseif os(macOS)
    static let cgghrd_work: FunctionTypes.LAPACKE_cgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghrd_work: FunctionTypes.LAPACKE_zgghrd_work? = load(name: "LAPACKE_zgghrd_work")
    #elseif os(macOS)
    static let zgghrd_work: FunctionTypes.LAPACKE_zgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghd3_work: FunctionTypes.LAPACKE_sgghd3_work? = load(name: "LAPACKE_sgghd3_work")
    #elseif os(macOS)
    static let sgghd3_work: FunctionTypes.LAPACKE_sgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghd3_work: FunctionTypes.LAPACKE_dgghd3_work? = load(name: "LAPACKE_dgghd3_work")
    #elseif os(macOS)
    static let dgghd3_work: FunctionTypes.LAPACKE_dgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghd3_work: FunctionTypes.LAPACKE_cgghd3_work? = load(name: "LAPACKE_cgghd3_work")
    #elseif os(macOS)
    static let cgghd3_work: FunctionTypes.LAPACKE_cgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghd3_work: FunctionTypes.LAPACKE_zgghd3_work? = load(name: "LAPACKE_zgghd3_work")
    #elseif os(macOS)
    static let zgghd3_work: FunctionTypes.LAPACKE_zgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgglse_work: FunctionTypes.LAPACKE_sgglse_work? = load(name: "LAPACKE_sgglse_work")
    #elseif os(macOS)
    static let sgglse_work: FunctionTypes.LAPACKE_sgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgglse_work: FunctionTypes.LAPACKE_dgglse_work? = load(name: "LAPACKE_dgglse_work")
    #elseif os(macOS)
    static let dgglse_work: FunctionTypes.LAPACKE_dgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgglse_work: FunctionTypes.LAPACKE_cgglse_work? = load(name: "LAPACKE_cgglse_work")
    #elseif os(macOS)
    static let cgglse_work: FunctionTypes.LAPACKE_cgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgglse_work: FunctionTypes.LAPACKE_zgglse_work? = load(name: "LAPACKE_zgglse_work")
    #elseif os(macOS)
    static let zgglse_work: FunctionTypes.LAPACKE_zgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggqrf_work: FunctionTypes.LAPACKE_sggqrf_work? = load(name: "LAPACKE_sggqrf_work")
    #elseif os(macOS)
    static let sggqrf_work: FunctionTypes.LAPACKE_sggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggqrf_work: FunctionTypes.LAPACKE_dggqrf_work? = load(name: "LAPACKE_dggqrf_work")
    #elseif os(macOS)
    static let dggqrf_work: FunctionTypes.LAPACKE_dggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggqrf_work: FunctionTypes.LAPACKE_cggqrf_work? = load(name: "LAPACKE_cggqrf_work")
    #elseif os(macOS)
    static let cggqrf_work: FunctionTypes.LAPACKE_cggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggqrf_work: FunctionTypes.LAPACKE_zggqrf_work? = load(name: "LAPACKE_zggqrf_work")
    #elseif os(macOS)
    static let zggqrf_work: FunctionTypes.LAPACKE_zggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggrqf_work: FunctionTypes.LAPACKE_sggrqf_work? = load(name: "LAPACKE_sggrqf_work")
    #elseif os(macOS)
    static let sggrqf_work: FunctionTypes.LAPACKE_sggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggrqf_work: FunctionTypes.LAPACKE_dggrqf_work? = load(name: "LAPACKE_dggrqf_work")
    #elseif os(macOS)
    static let dggrqf_work: FunctionTypes.LAPACKE_dggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggrqf_work: FunctionTypes.LAPACKE_cggrqf_work? = load(name: "LAPACKE_cggrqf_work")
    #elseif os(macOS)
    static let cggrqf_work: FunctionTypes.LAPACKE_cggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggrqf_work: FunctionTypes.LAPACKE_zggrqf_work? = load(name: "LAPACKE_zggrqf_work")
    #elseif os(macOS)
    static let zggrqf_work: FunctionTypes.LAPACKE_zggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd_work: FunctionTypes.LAPACKE_sggsvd_work? = load(name: "LAPACKE_sggsvd_work")
    #elseif os(macOS)
    static let sggsvd_work: FunctionTypes.LAPACKE_sggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd_work: FunctionTypes.LAPACKE_dggsvd_work? = load(name: "LAPACKE_dggsvd_work")
    #elseif os(macOS)
    static let dggsvd_work: FunctionTypes.LAPACKE_dggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd_work: FunctionTypes.LAPACKE_cggsvd_work? = load(name: "LAPACKE_cggsvd_work")
    #elseif os(macOS)
    static let cggsvd_work: FunctionTypes.LAPACKE_cggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd_work: FunctionTypes.LAPACKE_zggsvd_work? = load(name: "LAPACKE_zggsvd_work")
    #elseif os(macOS)
    static let zggsvd_work: FunctionTypes.LAPACKE_zggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd3_work: FunctionTypes.LAPACKE_sggsvd3_work? = load(name: "LAPACKE_sggsvd3_work")
    #elseif os(macOS)
    static let sggsvd3_work: FunctionTypes.LAPACKE_sggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd3_work: FunctionTypes.LAPACKE_dggsvd3_work? = load(name: "LAPACKE_dggsvd3_work")
    #elseif os(macOS)
    static let dggsvd3_work: FunctionTypes.LAPACKE_dggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd3_work: FunctionTypes.LAPACKE_cggsvd3_work? = load(name: "LAPACKE_cggsvd3_work")
    #elseif os(macOS)
    static let cggsvd3_work: FunctionTypes.LAPACKE_cggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd3_work: FunctionTypes.LAPACKE_zggsvd3_work? = load(name: "LAPACKE_zggsvd3_work")
    #elseif os(macOS)
    static let zggsvd3_work: FunctionTypes.LAPACKE_zggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp_work: FunctionTypes.LAPACKE_sggsvp_work? = load(name: "LAPACKE_sggsvp_work")
    #elseif os(macOS)
    static let sggsvp_work: FunctionTypes.LAPACKE_sggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp_work: FunctionTypes.LAPACKE_dggsvp_work? = load(name: "LAPACKE_dggsvp_work")
    #elseif os(macOS)
    static let dggsvp_work: FunctionTypes.LAPACKE_dggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp_work: FunctionTypes.LAPACKE_cggsvp_work? = load(name: "LAPACKE_cggsvp_work")
    #elseif os(macOS)
    static let cggsvp_work: FunctionTypes.LAPACKE_cggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp_work: FunctionTypes.LAPACKE_zggsvp_work? = load(name: "LAPACKE_zggsvp_work")
    #elseif os(macOS)
    static let zggsvp_work: FunctionTypes.LAPACKE_zggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp3_work: FunctionTypes.LAPACKE_sggsvp3_work? = load(name: "LAPACKE_sggsvp3_work")
    #elseif os(macOS)
    static let sggsvp3_work: FunctionTypes.LAPACKE_sggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp3_work: FunctionTypes.LAPACKE_dggsvp3_work? = load(name: "LAPACKE_dggsvp3_work")
    #elseif os(macOS)
    static let dggsvp3_work: FunctionTypes.LAPACKE_dggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp3_work: FunctionTypes.LAPACKE_cggsvp3_work? = load(name: "LAPACKE_cggsvp3_work")
    #elseif os(macOS)
    static let cggsvp3_work: FunctionTypes.LAPACKE_cggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp3_work: FunctionTypes.LAPACKE_zggsvp3_work? = load(name: "LAPACKE_zggsvp3_work")
    #elseif os(macOS)
    static let zggsvp3_work: FunctionTypes.LAPACKE_zggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtcon_work: FunctionTypes.LAPACKE_sgtcon_work? = load(name: "LAPACKE_sgtcon_work")
    #elseif os(macOS)
    static let sgtcon_work: FunctionTypes.LAPACKE_sgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtcon_work: FunctionTypes.LAPACKE_dgtcon_work? = load(name: "LAPACKE_dgtcon_work")
    #elseif os(macOS)
    static let dgtcon_work: FunctionTypes.LAPACKE_dgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtcon_work: FunctionTypes.LAPACKE_cgtcon_work? = load(name: "LAPACKE_cgtcon_work")
    #elseif os(macOS)
    static let cgtcon_work: FunctionTypes.LAPACKE_cgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtcon_work: FunctionTypes.LAPACKE_zgtcon_work? = load(name: "LAPACKE_zgtcon_work")
    #elseif os(macOS)
    static let zgtcon_work: FunctionTypes.LAPACKE_zgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtrfs_work: FunctionTypes.LAPACKE_sgtrfs_work? = load(name: "LAPACKE_sgtrfs_work")
    #elseif os(macOS)
    static let sgtrfs_work: FunctionTypes.LAPACKE_sgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtrfs_work: FunctionTypes.LAPACKE_dgtrfs_work? = load(name: "LAPACKE_dgtrfs_work")
    #elseif os(macOS)
    static let dgtrfs_work: FunctionTypes.LAPACKE_dgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtrfs_work: FunctionTypes.LAPACKE_cgtrfs_work? = load(name: "LAPACKE_cgtrfs_work")
    #elseif os(macOS)
    static let cgtrfs_work: FunctionTypes.LAPACKE_cgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtrfs_work: FunctionTypes.LAPACKE_zgtrfs_work? = load(name: "LAPACKE_zgtrfs_work")
    #elseif os(macOS)
    static let zgtrfs_work: FunctionTypes.LAPACKE_zgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsv_work: FunctionTypes.LAPACKE_sgtsv_work? = load(name: "LAPACKE_sgtsv_work")
    #elseif os(macOS)
    static let sgtsv_work: FunctionTypes.LAPACKE_sgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsv_work: FunctionTypes.LAPACKE_dgtsv_work? = load(name: "LAPACKE_dgtsv_work")
    #elseif os(macOS)
    static let dgtsv_work: FunctionTypes.LAPACKE_dgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsv_work: FunctionTypes.LAPACKE_cgtsv_work? = load(name: "LAPACKE_cgtsv_work")
    #elseif os(macOS)
    static let cgtsv_work: FunctionTypes.LAPACKE_cgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsv_work: FunctionTypes.LAPACKE_zgtsv_work? = load(name: "LAPACKE_zgtsv_work")
    #elseif os(macOS)
    static let zgtsv_work: FunctionTypes.LAPACKE_zgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsvx_work: FunctionTypes.LAPACKE_sgtsvx_work? = load(name: "LAPACKE_sgtsvx_work")
    #elseif os(macOS)
    static let sgtsvx_work: FunctionTypes.LAPACKE_sgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsvx_work: FunctionTypes.LAPACKE_dgtsvx_work? = load(name: "LAPACKE_dgtsvx_work")
    #elseif os(macOS)
    static let dgtsvx_work: FunctionTypes.LAPACKE_dgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsvx_work: FunctionTypes.LAPACKE_cgtsvx_work? = load(name: "LAPACKE_cgtsvx_work")
    #elseif os(macOS)
    static let cgtsvx_work: FunctionTypes.LAPACKE_cgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsvx_work: FunctionTypes.LAPACKE_zgtsvx_work? = load(name: "LAPACKE_zgtsvx_work")
    #elseif os(macOS)
    static let zgtsvx_work: FunctionTypes.LAPACKE_zgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrf_work: FunctionTypes.LAPACKE_sgttrf_work? = load(name: "LAPACKE_sgttrf_work")
    #elseif os(macOS)
    static let sgttrf_work: FunctionTypes.LAPACKE_sgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrf_work: FunctionTypes.LAPACKE_dgttrf_work? = load(name: "LAPACKE_dgttrf_work")
    #elseif os(macOS)
    static let dgttrf_work: FunctionTypes.LAPACKE_dgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrf_work: FunctionTypes.LAPACKE_cgttrf_work? = load(name: "LAPACKE_cgttrf_work")
    #elseif os(macOS)
    static let cgttrf_work: FunctionTypes.LAPACKE_cgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrf_work: FunctionTypes.LAPACKE_zgttrf_work? = load(name: "LAPACKE_zgttrf_work")
    #elseif os(macOS)
    static let zgttrf_work: FunctionTypes.LAPACKE_zgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrs_work: FunctionTypes.LAPACKE_sgttrs_work? = load(name: "LAPACKE_sgttrs_work")
    #elseif os(macOS)
    static let sgttrs_work: FunctionTypes.LAPACKE_sgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrs_work: FunctionTypes.LAPACKE_dgttrs_work? = load(name: "LAPACKE_dgttrs_work")
    #elseif os(macOS)
    static let dgttrs_work: FunctionTypes.LAPACKE_dgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrs_work: FunctionTypes.LAPACKE_cgttrs_work? = load(name: "LAPACKE_cgttrs_work")
    #elseif os(macOS)
    static let cgttrs_work: FunctionTypes.LAPACKE_cgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrs_work: FunctionTypes.LAPACKE_zgttrs_work? = load(name: "LAPACKE_zgttrs_work")
    #elseif os(macOS)
    static let zgttrs_work: FunctionTypes.LAPACKE_zgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev_work: FunctionTypes.LAPACKE_chbev_work? = load(name: "LAPACKE_chbev_work")
    #elseif os(macOS)
    static let chbev_work: FunctionTypes.LAPACKE_chbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev_work: FunctionTypes.LAPACKE_zhbev_work? = load(name: "LAPACKE_zhbev_work")
    #elseif os(macOS)
    static let zhbev_work: FunctionTypes.LAPACKE_zhbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd_work: FunctionTypes.LAPACKE_chbevd_work? = load(name: "LAPACKE_chbevd_work")
    #elseif os(macOS)
    static let chbevd_work: FunctionTypes.LAPACKE_chbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd_work: FunctionTypes.LAPACKE_zhbevd_work? = load(name: "LAPACKE_zhbevd_work")
    #elseif os(macOS)
    static let zhbevd_work: FunctionTypes.LAPACKE_zhbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx_work: FunctionTypes.LAPACKE_chbevx_work? = load(name: "LAPACKE_chbevx_work")
    #elseif os(macOS)
    static let chbevx_work: FunctionTypes.LAPACKE_chbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx_work: FunctionTypes.LAPACKE_zhbevx_work? = load(name: "LAPACKE_zhbevx_work")
    #elseif os(macOS)
    static let zhbevx_work: FunctionTypes.LAPACKE_zhbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgst_work: FunctionTypes.LAPACKE_chbgst_work? = load(name: "LAPACKE_chbgst_work")
    #elseif os(macOS)
    static let chbgst_work: FunctionTypes.LAPACKE_chbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgst_work: FunctionTypes.LAPACKE_zhbgst_work? = load(name: "LAPACKE_zhbgst_work")
    #elseif os(macOS)
    static let zhbgst_work: FunctionTypes.LAPACKE_zhbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgv_work: FunctionTypes.LAPACKE_chbgv_work? = load(name: "LAPACKE_chbgv_work")
    #elseif os(macOS)
    static let chbgv_work: FunctionTypes.LAPACKE_chbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgv_work: FunctionTypes.LAPACKE_zhbgv_work? = load(name: "LAPACKE_zhbgv_work")
    #elseif os(macOS)
    static let zhbgv_work: FunctionTypes.LAPACKE_zhbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvd_work: FunctionTypes.LAPACKE_chbgvd_work? = load(name: "LAPACKE_chbgvd_work")
    #elseif os(macOS)
    static let chbgvd_work: FunctionTypes.LAPACKE_chbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvd_work: FunctionTypes.LAPACKE_zhbgvd_work? = load(name: "LAPACKE_zhbgvd_work")
    #elseif os(macOS)
    static let zhbgvd_work: FunctionTypes.LAPACKE_zhbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvx_work: FunctionTypes.LAPACKE_chbgvx_work? = load(name: "LAPACKE_chbgvx_work")
    #elseif os(macOS)
    static let chbgvx_work: FunctionTypes.LAPACKE_chbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvx_work: FunctionTypes.LAPACKE_zhbgvx_work? = load(name: "LAPACKE_zhbgvx_work")
    #elseif os(macOS)
    static let zhbgvx_work: FunctionTypes.LAPACKE_zhbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbtrd_work: FunctionTypes.LAPACKE_chbtrd_work? = load(name: "LAPACKE_chbtrd_work")
    #elseif os(macOS)
    static let chbtrd_work: FunctionTypes.LAPACKE_chbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbtrd_work: FunctionTypes.LAPACKE_zhbtrd_work? = load(name: "LAPACKE_zhbtrd_work")
    #elseif os(macOS)
    static let zhbtrd_work: FunctionTypes.LAPACKE_zhbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon_work: FunctionTypes.LAPACKE_checon_work? = load(name: "LAPACKE_checon_work")
    #elseif os(macOS)
    static let checon_work: FunctionTypes.LAPACKE_checon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon_work: FunctionTypes.LAPACKE_zhecon_work? = load(name: "LAPACKE_zhecon_work")
    #elseif os(macOS)
    static let zhecon_work: FunctionTypes.LAPACKE_zhecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheequb_work: FunctionTypes.LAPACKE_cheequb_work? = load(name: "LAPACKE_cheequb_work")
    #elseif os(macOS)
    static let cheequb_work: FunctionTypes.LAPACKE_cheequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheequb_work: FunctionTypes.LAPACKE_zheequb_work? = load(name: "LAPACKE_zheequb_work")
    #elseif os(macOS)
    static let zheequb_work: FunctionTypes.LAPACKE_zheequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev_work: FunctionTypes.LAPACKE_cheev_work? = load(name: "LAPACKE_cheev_work")
    #elseif os(macOS)
    static let cheev_work: FunctionTypes.LAPACKE_cheev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev_work: FunctionTypes.LAPACKE_zheev_work? = load(name: "LAPACKE_zheev_work")
    #elseif os(macOS)
    static let zheev_work: FunctionTypes.LAPACKE_zheev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd_work: FunctionTypes.LAPACKE_cheevd_work? = load(name: "LAPACKE_cheevd_work")
    #elseif os(macOS)
    static let cheevd_work: FunctionTypes.LAPACKE_cheevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd_work: FunctionTypes.LAPACKE_zheevd_work? = load(name: "LAPACKE_zheevd_work")
    #elseif os(macOS)
    static let zheevd_work: FunctionTypes.LAPACKE_zheevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr_work: FunctionTypes.LAPACKE_cheevr_work? = load(name: "LAPACKE_cheevr_work")
    #elseif os(macOS)
    static let cheevr_work: FunctionTypes.LAPACKE_cheevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr_work: FunctionTypes.LAPACKE_zheevr_work? = load(name: "LAPACKE_zheevr_work")
    #elseif os(macOS)
    static let zheevr_work: FunctionTypes.LAPACKE_zheevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx_work: FunctionTypes.LAPACKE_cheevx_work? = load(name: "LAPACKE_cheevx_work")
    #elseif os(macOS)
    static let cheevx_work: FunctionTypes.LAPACKE_cheevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx_work: FunctionTypes.LAPACKE_zheevx_work? = load(name: "LAPACKE_zheevx_work")
    #elseif os(macOS)
    static let zheevx_work: FunctionTypes.LAPACKE_zheevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegst_work: FunctionTypes.LAPACKE_chegst_work? = load(name: "LAPACKE_chegst_work")
    #elseif os(macOS)
    static let chegst_work: FunctionTypes.LAPACKE_chegst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegst_work: FunctionTypes.LAPACKE_zhegst_work? = load(name: "LAPACKE_zhegst_work")
    #elseif os(macOS)
    static let zhegst_work: FunctionTypes.LAPACKE_zhegst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv_work: FunctionTypes.LAPACKE_chegv_work? = load(name: "LAPACKE_chegv_work")
    #elseif os(macOS)
    static let chegv_work: FunctionTypes.LAPACKE_chegv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv_work: FunctionTypes.LAPACKE_zhegv_work? = load(name: "LAPACKE_zhegv_work")
    #elseif os(macOS)
    static let zhegv_work: FunctionTypes.LAPACKE_zhegv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvd_work: FunctionTypes.LAPACKE_chegvd_work? = load(name: "LAPACKE_chegvd_work")
    #elseif os(macOS)
    static let chegvd_work: FunctionTypes.LAPACKE_chegvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvd_work: FunctionTypes.LAPACKE_zhegvd_work? = load(name: "LAPACKE_zhegvd_work")
    #elseif os(macOS)
    static let zhegvd_work: FunctionTypes.LAPACKE_zhegvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvx_work: FunctionTypes.LAPACKE_chegvx_work? = load(name: "LAPACKE_chegvx_work")
    #elseif os(macOS)
    static let chegvx_work: FunctionTypes.LAPACKE_chegvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvx_work: FunctionTypes.LAPACKE_zhegvx_work? = load(name: "LAPACKE_zhegvx_work")
    #elseif os(macOS)
    static let zhegvx_work: FunctionTypes.LAPACKE_zhegvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfs_work: FunctionTypes.LAPACKE_cherfs_work? = load(name: "LAPACKE_cherfs_work")
    #elseif os(macOS)
    static let cherfs_work: FunctionTypes.LAPACKE_cherfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfs_work: FunctionTypes.LAPACKE_zherfs_work? = load(name: "LAPACKE_zherfs_work")
    #elseif os(macOS)
    static let zherfs_work: FunctionTypes.LAPACKE_zherfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfsx_work: FunctionTypes.LAPACKE_cherfsx_work? = load(name: "LAPACKE_cherfsx_work")
    #elseif os(macOS)
    static let cherfsx_work: FunctionTypes.LAPACKE_cherfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfsx_work: FunctionTypes.LAPACKE_zherfsx_work? = load(name: "LAPACKE_zherfsx_work")
    #elseif os(macOS)
    static let zherfsx_work: FunctionTypes.LAPACKE_zherfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_work: FunctionTypes.LAPACKE_chesv_work? = load(name: "LAPACKE_chesv_work")
    #elseif os(macOS)
    static let chesv_work: FunctionTypes.LAPACKE_chesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_work: FunctionTypes.LAPACKE_zhesv_work? = load(name: "LAPACKE_zhesv_work")
    #elseif os(macOS)
    static let zhesv_work: FunctionTypes.LAPACKE_zhesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvx_work: FunctionTypes.LAPACKE_chesvx_work? = load(name: "LAPACKE_chesvx_work")
    #elseif os(macOS)
    static let chesvx_work: FunctionTypes.LAPACKE_chesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvx_work: FunctionTypes.LAPACKE_zhesvx_work? = load(name: "LAPACKE_zhesvx_work")
    #elseif os(macOS)
    static let zhesvx_work: FunctionTypes.LAPACKE_zhesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvxx_work: FunctionTypes.LAPACKE_chesvxx_work? = load(name: "LAPACKE_chesvxx_work")
    #elseif os(macOS)
    static let chesvxx_work: FunctionTypes.LAPACKE_chesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvxx_work: FunctionTypes.LAPACKE_zhesvxx_work? = load(name: "LAPACKE_zhesvxx_work")
    #elseif os(macOS)
    static let zhesvxx_work: FunctionTypes.LAPACKE_zhesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrd_work: FunctionTypes.LAPACKE_chetrd_work? = load(name: "LAPACKE_chetrd_work")
    #elseif os(macOS)
    static let chetrd_work: FunctionTypes.LAPACKE_chetrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrd_work: FunctionTypes.LAPACKE_zhetrd_work? = load(name: "LAPACKE_zhetrd_work")
    #elseif os(macOS)
    static let zhetrd_work: FunctionTypes.LAPACKE_zhetrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_work: FunctionTypes.LAPACKE_chetrf_work? = load(name: "LAPACKE_chetrf_work")
    #elseif os(macOS)
    static let chetrf_work: FunctionTypes.LAPACKE_chetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_work: FunctionTypes.LAPACKE_zhetrf_work? = load(name: "LAPACKE_zhetrf_work")
    #elseif os(macOS)
    static let zhetrf_work: FunctionTypes.LAPACKE_zhetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri_work: FunctionTypes.LAPACKE_chetri_work? = load(name: "LAPACKE_chetri_work")
    #elseif os(macOS)
    static let chetri_work: FunctionTypes.LAPACKE_chetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri_work: FunctionTypes.LAPACKE_zhetri_work? = load(name: "LAPACKE_zhetri_work")
    #elseif os(macOS)
    static let zhetri_work: FunctionTypes.LAPACKE_zhetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_work: FunctionTypes.LAPACKE_chetrs_work? = load(name: "LAPACKE_chetrs_work")
    #elseif os(macOS)
    static let chetrs_work: FunctionTypes.LAPACKE_chetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_work: FunctionTypes.LAPACKE_zhetrs_work? = load(name: "LAPACKE_zhetrs_work")
    #elseif os(macOS)
    static let zhetrs_work: FunctionTypes.LAPACKE_zhetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chfrk_work: FunctionTypes.LAPACKE_chfrk_work? = load(name: "LAPACKE_chfrk_work")
    #elseif os(macOS)
    static let chfrk_work: FunctionTypes.LAPACKE_chfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhfrk_work: FunctionTypes.LAPACKE_zhfrk_work? = load(name: "LAPACKE_zhfrk_work")
    #elseif os(macOS)
    static let zhfrk_work: FunctionTypes.LAPACKE_zhfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shgeqz_work: FunctionTypes.LAPACKE_shgeqz_work? = load(name: "LAPACKE_shgeqz_work")
    #elseif os(macOS)
    static let shgeqz_work: FunctionTypes.LAPACKE_shgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhgeqz_work: FunctionTypes.LAPACKE_dhgeqz_work? = load(name: "LAPACKE_dhgeqz_work")
    #elseif os(macOS)
    static let dhgeqz_work: FunctionTypes.LAPACKE_dhgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chgeqz_work: FunctionTypes.LAPACKE_chgeqz_work? = load(name: "LAPACKE_chgeqz_work")
    #elseif os(macOS)
    static let chgeqz_work: FunctionTypes.LAPACKE_chgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhgeqz_work: FunctionTypes.LAPACKE_zhgeqz_work? = load(name: "LAPACKE_zhgeqz_work")
    #elseif os(macOS)
    static let zhgeqz_work: FunctionTypes.LAPACKE_zhgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpcon_work: FunctionTypes.LAPACKE_chpcon_work? = load(name: "LAPACKE_chpcon_work")
    #elseif os(macOS)
    static let chpcon_work: FunctionTypes.LAPACKE_chpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpcon_work: FunctionTypes.LAPACKE_zhpcon_work? = load(name: "LAPACKE_zhpcon_work")
    #elseif os(macOS)
    static let zhpcon_work: FunctionTypes.LAPACKE_zhpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpev_work: FunctionTypes.LAPACKE_chpev_work? = load(name: "LAPACKE_chpev_work")
    #elseif os(macOS)
    static let chpev_work: FunctionTypes.LAPACKE_chpev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpev_work: FunctionTypes.LAPACKE_zhpev_work? = load(name: "LAPACKE_zhpev_work")
    #elseif os(macOS)
    static let zhpev_work: FunctionTypes.LAPACKE_zhpev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevd_work: FunctionTypes.LAPACKE_chpevd_work? = load(name: "LAPACKE_chpevd_work")
    #elseif os(macOS)
    static let chpevd_work: FunctionTypes.LAPACKE_chpevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevd_work: FunctionTypes.LAPACKE_zhpevd_work? = load(name: "LAPACKE_zhpevd_work")
    #elseif os(macOS)
    static let zhpevd_work: FunctionTypes.LAPACKE_zhpevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevx_work: FunctionTypes.LAPACKE_chpevx_work? = load(name: "LAPACKE_chpevx_work")
    #elseif os(macOS)
    static let chpevx_work: FunctionTypes.LAPACKE_chpevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevx_work: FunctionTypes.LAPACKE_zhpevx_work? = load(name: "LAPACKE_zhpevx_work")
    #elseif os(macOS)
    static let zhpevx_work: FunctionTypes.LAPACKE_zhpevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgst_work: FunctionTypes.LAPACKE_chpgst_work? = load(name: "LAPACKE_chpgst_work")
    #elseif os(macOS)
    static let chpgst_work: FunctionTypes.LAPACKE_chpgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgst_work: FunctionTypes.LAPACKE_zhpgst_work? = load(name: "LAPACKE_zhpgst_work")
    #elseif os(macOS)
    static let zhpgst_work: FunctionTypes.LAPACKE_zhpgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgv_work: FunctionTypes.LAPACKE_chpgv_work? = load(name: "LAPACKE_chpgv_work")
    #elseif os(macOS)
    static let chpgv_work: FunctionTypes.LAPACKE_chpgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgv_work: FunctionTypes.LAPACKE_zhpgv_work? = load(name: "LAPACKE_zhpgv_work")
    #elseif os(macOS)
    static let zhpgv_work: FunctionTypes.LAPACKE_zhpgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvd_work: FunctionTypes.LAPACKE_chpgvd_work? = load(name: "LAPACKE_chpgvd_work")
    #elseif os(macOS)
    static let chpgvd_work: FunctionTypes.LAPACKE_chpgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvd_work: FunctionTypes.LAPACKE_zhpgvd_work? = load(name: "LAPACKE_zhpgvd_work")
    #elseif os(macOS)
    static let zhpgvd_work: FunctionTypes.LAPACKE_zhpgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvx_work: FunctionTypes.LAPACKE_chpgvx_work? = load(name: "LAPACKE_chpgvx_work")
    #elseif os(macOS)
    static let chpgvx_work: FunctionTypes.LAPACKE_chpgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvx_work: FunctionTypes.LAPACKE_zhpgvx_work? = load(name: "LAPACKE_zhpgvx_work")
    #elseif os(macOS)
    static let zhpgvx_work: FunctionTypes.LAPACKE_zhpgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chprfs_work: FunctionTypes.LAPACKE_chprfs_work? = load(name: "LAPACKE_chprfs_work")
    #elseif os(macOS)
    static let chprfs_work: FunctionTypes.LAPACKE_chprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhprfs_work: FunctionTypes.LAPACKE_zhprfs_work? = load(name: "LAPACKE_zhprfs_work")
    #elseif os(macOS)
    static let zhprfs_work: FunctionTypes.LAPACKE_zhprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsv_work: FunctionTypes.LAPACKE_chpsv_work? = load(name: "LAPACKE_chpsv_work")
    #elseif os(macOS)
    static let chpsv_work: FunctionTypes.LAPACKE_chpsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsv_work: FunctionTypes.LAPACKE_zhpsv_work? = load(name: "LAPACKE_zhpsv_work")
    #elseif os(macOS)
    static let zhpsv_work: FunctionTypes.LAPACKE_zhpsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsvx_work: FunctionTypes.LAPACKE_chpsvx_work? = load(name: "LAPACKE_chpsvx_work")
    #elseif os(macOS)
    static let chpsvx_work: FunctionTypes.LAPACKE_chpsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsvx_work: FunctionTypes.LAPACKE_zhpsvx_work? = load(name: "LAPACKE_zhpsvx_work")
    #elseif os(macOS)
    static let zhpsvx_work: FunctionTypes.LAPACKE_zhpsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrd_work: FunctionTypes.LAPACKE_chptrd_work? = load(name: "LAPACKE_chptrd_work")
    #elseif os(macOS)
    static let chptrd_work: FunctionTypes.LAPACKE_chptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrd_work: FunctionTypes.LAPACKE_zhptrd_work? = load(name: "LAPACKE_zhptrd_work")
    #elseif os(macOS)
    static let zhptrd_work: FunctionTypes.LAPACKE_zhptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrf_work: FunctionTypes.LAPACKE_chptrf_work? = load(name: "LAPACKE_chptrf_work")
    #elseif os(macOS)
    static let chptrf_work: FunctionTypes.LAPACKE_chptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrf_work: FunctionTypes.LAPACKE_zhptrf_work? = load(name: "LAPACKE_zhptrf_work")
    #elseif os(macOS)
    static let zhptrf_work: FunctionTypes.LAPACKE_zhptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptri_work: FunctionTypes.LAPACKE_chptri_work? = load(name: "LAPACKE_chptri_work")
    #elseif os(macOS)
    static let chptri_work: FunctionTypes.LAPACKE_chptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptri_work: FunctionTypes.LAPACKE_zhptri_work? = load(name: "LAPACKE_zhptri_work")
    #elseif os(macOS)
    static let zhptri_work: FunctionTypes.LAPACKE_zhptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrs_work: FunctionTypes.LAPACKE_chptrs_work? = load(name: "LAPACKE_chptrs_work")
    #elseif os(macOS)
    static let chptrs_work: FunctionTypes.LAPACKE_chptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrs_work: FunctionTypes.LAPACKE_zhptrs_work? = load(name: "LAPACKE_zhptrs_work")
    #elseif os(macOS)
    static let zhptrs_work: FunctionTypes.LAPACKE_zhptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shsein_work: FunctionTypes.LAPACKE_shsein_work? = load(name: "LAPACKE_shsein_work")
    #elseif os(macOS)
    static let shsein_work: FunctionTypes.LAPACKE_shsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhsein_work: FunctionTypes.LAPACKE_dhsein_work? = load(name: "LAPACKE_dhsein_work")
    #elseif os(macOS)
    static let dhsein_work: FunctionTypes.LAPACKE_dhsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chsein_work: FunctionTypes.LAPACKE_chsein_work? = load(name: "LAPACKE_chsein_work")
    #elseif os(macOS)
    static let chsein_work: FunctionTypes.LAPACKE_chsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhsein_work: FunctionTypes.LAPACKE_zhsein_work? = load(name: "LAPACKE_zhsein_work")
    #elseif os(macOS)
    static let zhsein_work: FunctionTypes.LAPACKE_zhsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shseqr_work: FunctionTypes.LAPACKE_shseqr_work? = load(name: "LAPACKE_shseqr_work")
    #elseif os(macOS)
    static let shseqr_work: FunctionTypes.LAPACKE_shseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhseqr_work: FunctionTypes.LAPACKE_dhseqr_work? = load(name: "LAPACKE_dhseqr_work")
    #elseif os(macOS)
    static let dhseqr_work: FunctionTypes.LAPACKE_dhseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chseqr_work: FunctionTypes.LAPACKE_chseqr_work? = load(name: "LAPACKE_chseqr_work")
    #elseif os(macOS)
    static let chseqr_work: FunctionTypes.LAPACKE_chseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhseqr_work: FunctionTypes.LAPACKE_zhseqr_work? = load(name: "LAPACKE_zhseqr_work")
    #elseif os(macOS)
    static let zhseqr_work: FunctionTypes.LAPACKE_zhseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacgv_work: FunctionTypes.LAPACKE_clacgv_work? = load(name: "LAPACKE_clacgv_work")
    #elseif os(macOS)
    static let clacgv_work: FunctionTypes.LAPACKE_clacgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacgv_work: FunctionTypes.LAPACKE_zlacgv_work? = load(name: "LAPACKE_zlacgv_work")
    #elseif os(macOS)
    static let zlacgv_work: FunctionTypes.LAPACKE_zlacgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacn2_work: FunctionTypes.LAPACKE_slacn2_work? = load(name: "LAPACKE_slacn2_work")
    #elseif os(macOS)
    static let slacn2_work: FunctionTypes.LAPACKE_slacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacn2_work: FunctionTypes.LAPACKE_dlacn2_work? = load(name: "LAPACKE_dlacn2_work")
    #elseif os(macOS)
    static let dlacn2_work: FunctionTypes.LAPACKE_dlacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacn2_work: FunctionTypes.LAPACKE_clacn2_work? = load(name: "LAPACKE_clacn2_work")
    #elseif os(macOS)
    static let clacn2_work: FunctionTypes.LAPACKE_clacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacn2_work: FunctionTypes.LAPACKE_zlacn2_work? = load(name: "LAPACKE_zlacn2_work")
    #elseif os(macOS)
    static let zlacn2_work: FunctionTypes.LAPACKE_zlacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacpy_work: FunctionTypes.LAPACKE_slacpy_work? = load(name: "LAPACKE_slacpy_work")
    #elseif os(macOS)
    static let slacpy_work: FunctionTypes.LAPACKE_slacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacpy_work: FunctionTypes.LAPACKE_dlacpy_work? = load(name: "LAPACKE_dlacpy_work")
    #elseif os(macOS)
    static let dlacpy_work: FunctionTypes.LAPACKE_dlacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacpy_work: FunctionTypes.LAPACKE_clacpy_work? = load(name: "LAPACKE_clacpy_work")
    #elseif os(macOS)
    static let clacpy_work: FunctionTypes.LAPACKE_clacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacpy_work: FunctionTypes.LAPACKE_zlacpy_work? = load(name: "LAPACKE_zlacpy_work")
    #elseif os(macOS)
    static let zlacpy_work: FunctionTypes.LAPACKE_zlacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacp2_work: FunctionTypes.LAPACKE_clacp2_work? = load(name: "LAPACKE_clacp2_work")
    #elseif os(macOS)
    static let clacp2_work: FunctionTypes.LAPACKE_clacp2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacp2_work: FunctionTypes.LAPACKE_zlacp2_work? = load(name: "LAPACKE_zlacp2_work")
    #elseif os(macOS)
    static let zlacp2_work: FunctionTypes.LAPACKE_zlacp2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlag2c_work: FunctionTypes.LAPACKE_zlag2c_work? = load(name: "LAPACKE_zlag2c_work")
    #elseif os(macOS)
    static let zlag2c_work: FunctionTypes.LAPACKE_zlag2c_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slag2d_work: FunctionTypes.LAPACKE_slag2d_work? = load(name: "LAPACKE_slag2d_work")
    #elseif os(macOS)
    static let slag2d_work: FunctionTypes.LAPACKE_slag2d_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlag2s_work: FunctionTypes.LAPACKE_dlag2s_work? = load(name: "LAPACKE_dlag2s_work")
    #elseif os(macOS)
    static let dlag2s_work: FunctionTypes.LAPACKE_dlag2s_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clag2z_work: FunctionTypes.LAPACKE_clag2z_work? = load(name: "LAPACKE_clag2z_work")
    #elseif os(macOS)
    static let clag2z_work: FunctionTypes.LAPACKE_clag2z_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagge_work: FunctionTypes.LAPACKE_slagge_work? = load(name: "LAPACKE_slagge_work")
    #elseif os(macOS)
    static let slagge_work: FunctionTypes.LAPACKE_slagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagge_work: FunctionTypes.LAPACKE_dlagge_work? = load(name: "LAPACKE_dlagge_work")
    #elseif os(macOS)
    static let dlagge_work: FunctionTypes.LAPACKE_dlagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagge_work: FunctionTypes.LAPACKE_clagge_work? = load(name: "LAPACKE_clagge_work")
    #elseif os(macOS)
    static let clagge_work: FunctionTypes.LAPACKE_clagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagge_work: FunctionTypes.LAPACKE_zlagge_work? = load(name: "LAPACKE_zlagge_work")
    #elseif os(macOS)
    static let zlagge_work: FunctionTypes.LAPACKE_zlagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claghe_work: FunctionTypes.LAPACKE_claghe_work? = load(name: "LAPACKE_claghe_work")
    #elseif os(macOS)
    static let claghe_work: FunctionTypes.LAPACKE_claghe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaghe_work: FunctionTypes.LAPACKE_zlaghe_work? = load(name: "LAPACKE_zlaghe_work")
    #elseif os(macOS)
    static let zlaghe_work: FunctionTypes.LAPACKE_zlaghe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagsy_work: FunctionTypes.LAPACKE_slagsy_work? = load(name: "LAPACKE_slagsy_work")
    #elseif os(macOS)
    static let slagsy_work: FunctionTypes.LAPACKE_slagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagsy_work: FunctionTypes.LAPACKE_dlagsy_work? = load(name: "LAPACKE_dlagsy_work")
    #elseif os(macOS)
    static let dlagsy_work: FunctionTypes.LAPACKE_dlagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagsy_work: FunctionTypes.LAPACKE_clagsy_work? = load(name: "LAPACKE_clagsy_work")
    #elseif os(macOS)
    static let clagsy_work: FunctionTypes.LAPACKE_clagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagsy_work: FunctionTypes.LAPACKE_zlagsy_work? = load(name: "LAPACKE_zlagsy_work")
    #elseif os(macOS)
    static let zlagsy_work: FunctionTypes.LAPACKE_zlagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmr_work: FunctionTypes.LAPACKE_slapmr_work? = load(name: "LAPACKE_slapmr_work")
    #elseif os(macOS)
    static let slapmr_work: FunctionTypes.LAPACKE_slapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmr_work: FunctionTypes.LAPACKE_dlapmr_work? = load(name: "LAPACKE_dlapmr_work")
    #elseif os(macOS)
    static let dlapmr_work: FunctionTypes.LAPACKE_dlapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmr_work: FunctionTypes.LAPACKE_clapmr_work? = load(name: "LAPACKE_clapmr_work")
    #elseif os(macOS)
    static let clapmr_work: FunctionTypes.LAPACKE_clapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmr_work: FunctionTypes.LAPACKE_zlapmr_work? = load(name: "LAPACKE_zlapmr_work")
    #elseif os(macOS)
    static let zlapmr_work: FunctionTypes.LAPACKE_zlapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmt_work: FunctionTypes.LAPACKE_slapmt_work? = load(name: "LAPACKE_slapmt_work")
    #elseif os(macOS)
    static let slapmt_work: FunctionTypes.LAPACKE_slapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmt_work: FunctionTypes.LAPACKE_dlapmt_work? = load(name: "LAPACKE_dlapmt_work")
    #elseif os(macOS)
    static let dlapmt_work: FunctionTypes.LAPACKE_dlapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmt_work: FunctionTypes.LAPACKE_clapmt_work? = load(name: "LAPACKE_clapmt_work")
    #elseif os(macOS)
    static let clapmt_work: FunctionTypes.LAPACKE_clapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmt_work: FunctionTypes.LAPACKE_zlapmt_work? = load(name: "LAPACKE_zlapmt_work")
    #elseif os(macOS)
    static let zlapmt_work: FunctionTypes.LAPACKE_zlapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgp_work: FunctionTypes.LAPACKE_slartgp_work? = load(name: "LAPACKE_slartgp_work")
    #elseif os(macOS)
    static let slartgp_work: FunctionTypes.LAPACKE_slartgp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgp_work: FunctionTypes.LAPACKE_dlartgp_work? = load(name: "LAPACKE_dlartgp_work")
    #elseif os(macOS)
    static let dlartgp_work: FunctionTypes.LAPACKE_dlartgp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgs_work: FunctionTypes.LAPACKE_slartgs_work? = load(name: "LAPACKE_slartgs_work")
    #elseif os(macOS)
    static let slartgs_work: FunctionTypes.LAPACKE_slartgs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgs_work: FunctionTypes.LAPACKE_dlartgs_work? = load(name: "LAPACKE_dlartgs_work")
    #elseif os(macOS)
    static let dlartgs_work: FunctionTypes.LAPACKE_dlartgs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy2_work: FunctionTypes.LAPACKE_slapy2_work? = load(name: "LAPACKE_slapy2_work")
    #elseif os(macOS)
    static let slapy2_work: FunctionTypes.LAPACKE_slapy2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy2_work: FunctionTypes.LAPACKE_dlapy2_work? = load(name: "LAPACKE_dlapy2_work")
    #elseif os(macOS)
    static let dlapy2_work: FunctionTypes.LAPACKE_dlapy2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy3_work: FunctionTypes.LAPACKE_slapy3_work? = load(name: "LAPACKE_slapy3_work")
    #elseif os(macOS)
    static let slapy3_work: FunctionTypes.LAPACKE_slapy3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy3_work: FunctionTypes.LAPACKE_dlapy3_work? = load(name: "LAPACKE_dlapy3_work")
    #elseif os(macOS)
    static let dlapy3_work: FunctionTypes.LAPACKE_dlapy3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slamch_work: FunctionTypes.LAPACKE_slamch_work? = load(name: "LAPACKE_slamch_work")
    #elseif os(macOS)
    static let slamch_work: FunctionTypes.LAPACKE_slamch_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlamch_work: FunctionTypes.LAPACKE_dlamch_work? = load(name: "LAPACKE_dlamch_work")
    #elseif os(macOS)
    static let dlamch_work: FunctionTypes.LAPACKE_dlamch_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slangb_work: FunctionTypes.LAPACKE_slangb_work? = load(name: "LAPACKE_slangb_work")
    #elseif os(macOS)
    static let slangb_work: FunctionTypes.LAPACKE_slangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlangb_work: FunctionTypes.LAPACKE_dlangb_work? = load(name: "LAPACKE_dlangb_work")
    #elseif os(macOS)
    static let dlangb_work: FunctionTypes.LAPACKE_dlangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clangb_work: FunctionTypes.LAPACKE_clangb_work? = load(name: "LAPACKE_clangb_work")
    #elseif os(macOS)
    static let clangb_work: FunctionTypes.LAPACKE_clangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlangb_work: FunctionTypes.LAPACKE_zlangb_work? = load(name: "LAPACKE_zlangb_work")
    #elseif os(macOS)
    static let zlangb_work: FunctionTypes.LAPACKE_zlangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slange_work: FunctionTypes.LAPACKE_slange_work? = load(name: "LAPACKE_slange_work")
    #elseif os(macOS)
    static let slange_work: FunctionTypes.LAPACKE_slange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlange_work: FunctionTypes.LAPACKE_dlange_work? = load(name: "LAPACKE_dlange_work")
    #elseif os(macOS)
    static let dlange_work: FunctionTypes.LAPACKE_dlange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clange_work: FunctionTypes.LAPACKE_clange_work? = load(name: "LAPACKE_clange_work")
    #elseif os(macOS)
    static let clange_work: FunctionTypes.LAPACKE_clange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlange_work: FunctionTypes.LAPACKE_zlange_work? = load(name: "LAPACKE_zlange_work")
    #elseif os(macOS)
    static let zlange_work: FunctionTypes.LAPACKE_zlange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clanhe_work: FunctionTypes.LAPACKE_clanhe_work? = load(name: "LAPACKE_clanhe_work")
    #elseif os(macOS)
    static let clanhe_work: FunctionTypes.LAPACKE_clanhe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlanhe_work: FunctionTypes.LAPACKE_zlanhe_work? = load(name: "LAPACKE_zlanhe_work")
    #elseif os(macOS)
    static let zlanhe_work: FunctionTypes.LAPACKE_zlanhe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacrm_work: FunctionTypes.LAPACKE_clacrm_work? = load(name: "LAPACKE_clacrm_work")
    #elseif os(macOS)
    static let clacrm_work: FunctionTypes.LAPACKE_clacrm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacrm_work: FunctionTypes.LAPACKE_zlacrm_work? = load(name: "LAPACKE_zlacrm_work")
    #elseif os(macOS)
    static let zlacrm_work: FunctionTypes.LAPACKE_zlacrm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarcm_work: FunctionTypes.LAPACKE_clarcm_work? = load(name: "LAPACKE_clarcm_work")
    #elseif os(macOS)
    static let clarcm_work: FunctionTypes.LAPACKE_clarcm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarcm_work: FunctionTypes.LAPACKE_zlarcm_work? = load(name: "LAPACKE_zlarcm_work")
    #elseif os(macOS)
    static let zlarcm_work: FunctionTypes.LAPACKE_zlarcm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slansy_work: FunctionTypes.LAPACKE_slansy_work? = load(name: "LAPACKE_slansy_work")
    #elseif os(macOS)
    static let slansy_work: FunctionTypes.LAPACKE_slansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlansy_work: FunctionTypes.LAPACKE_dlansy_work? = load(name: "LAPACKE_dlansy_work")
    #elseif os(macOS)
    static let dlansy_work: FunctionTypes.LAPACKE_dlansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clansy_work: FunctionTypes.LAPACKE_clansy_work? = load(name: "LAPACKE_clansy_work")
    #elseif os(macOS)
    static let clansy_work: FunctionTypes.LAPACKE_clansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlansy_work: FunctionTypes.LAPACKE_zlansy_work? = load(name: "LAPACKE_zlansy_work")
    #elseif os(macOS)
    static let zlansy_work: FunctionTypes.LAPACKE_zlansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slantr_work: FunctionTypes.LAPACKE_slantr_work? = load(name: "LAPACKE_slantr_work")
    #elseif os(macOS)
    static let slantr_work: FunctionTypes.LAPACKE_slantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlantr_work: FunctionTypes.LAPACKE_dlantr_work? = load(name: "LAPACKE_dlantr_work")
    #elseif os(macOS)
    static let dlantr_work: FunctionTypes.LAPACKE_dlantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clantr_work: FunctionTypes.LAPACKE_clantr_work? = load(name: "LAPACKE_clantr_work")
    #elseif os(macOS)
    static let clantr_work: FunctionTypes.LAPACKE_clantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlantr_work: FunctionTypes.LAPACKE_zlantr_work? = load(name: "LAPACKE_zlantr_work")
    #elseif os(macOS)
    static let zlantr_work: FunctionTypes.LAPACKE_zlantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfb_work: FunctionTypes.LAPACKE_slarfb_work? = load(name: "LAPACKE_slarfb_work")
    #elseif os(macOS)
    static let slarfb_work: FunctionTypes.LAPACKE_slarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfb_work: FunctionTypes.LAPACKE_dlarfb_work? = load(name: "LAPACKE_dlarfb_work")
    #elseif os(macOS)
    static let dlarfb_work: FunctionTypes.LAPACKE_dlarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfb_work: FunctionTypes.LAPACKE_clarfb_work? = load(name: "LAPACKE_clarfb_work")
    #elseif os(macOS)
    static let clarfb_work: FunctionTypes.LAPACKE_clarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfb_work: FunctionTypes.LAPACKE_zlarfb_work? = load(name: "LAPACKE_zlarfb_work")
    #elseif os(macOS)
    static let zlarfb_work: FunctionTypes.LAPACKE_zlarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfg_work: FunctionTypes.LAPACKE_slarfg_work? = load(name: "LAPACKE_slarfg_work")
    #elseif os(macOS)
    static let slarfg_work: FunctionTypes.LAPACKE_slarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfg_work: FunctionTypes.LAPACKE_dlarfg_work? = load(name: "LAPACKE_dlarfg_work")
    #elseif os(macOS)
    static let dlarfg_work: FunctionTypes.LAPACKE_dlarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfg_work: FunctionTypes.LAPACKE_clarfg_work? = load(name: "LAPACKE_clarfg_work")
    #elseif os(macOS)
    static let clarfg_work: FunctionTypes.LAPACKE_clarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfg_work: FunctionTypes.LAPACKE_zlarfg_work? = load(name: "LAPACKE_zlarfg_work")
    #elseif os(macOS)
    static let zlarfg_work: FunctionTypes.LAPACKE_zlarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarft_work: FunctionTypes.LAPACKE_slarft_work? = load(name: "LAPACKE_slarft_work")
    #elseif os(macOS)
    static let slarft_work: FunctionTypes.LAPACKE_slarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarft_work: FunctionTypes.LAPACKE_dlarft_work? = load(name: "LAPACKE_dlarft_work")
    #elseif os(macOS)
    static let dlarft_work: FunctionTypes.LAPACKE_dlarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarft_work: FunctionTypes.LAPACKE_clarft_work? = load(name: "LAPACKE_clarft_work")
    #elseif os(macOS)
    static let clarft_work: FunctionTypes.LAPACKE_clarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarft_work: FunctionTypes.LAPACKE_zlarft_work? = load(name: "LAPACKE_zlarft_work")
    #elseif os(macOS)
    static let zlarft_work: FunctionTypes.LAPACKE_zlarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfx_work: FunctionTypes.LAPACKE_slarfx_work? = load(name: "LAPACKE_slarfx_work")
    #elseif os(macOS)
    static let slarfx_work: FunctionTypes.LAPACKE_slarfx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfx_work: FunctionTypes.LAPACKE_dlarfx_work? = load(name: "LAPACKE_dlarfx_work")
    #elseif os(macOS)
    static let dlarfx_work: FunctionTypes.LAPACKE_dlarfx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarnv_work: FunctionTypes.LAPACKE_slarnv_work? = load(name: "LAPACKE_slarnv_work")
    #elseif os(macOS)
    static let slarnv_work: FunctionTypes.LAPACKE_slarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarnv_work: FunctionTypes.LAPACKE_dlarnv_work? = load(name: "LAPACKE_dlarnv_work")
    #elseif os(macOS)
    static let dlarnv_work: FunctionTypes.LAPACKE_dlarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarnv_work: FunctionTypes.LAPACKE_clarnv_work? = load(name: "LAPACKE_clarnv_work")
    #elseif os(macOS)
    static let clarnv_work: FunctionTypes.LAPACKE_clarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarnv_work: FunctionTypes.LAPACKE_zlarnv_work? = load(name: "LAPACKE_zlarnv_work")
    #elseif os(macOS)
    static let zlarnv_work: FunctionTypes.LAPACKE_zlarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slascl_work: FunctionTypes.LAPACKE_slascl_work? = load(name: "LAPACKE_slascl_work")
    #elseif os(macOS)
    static let slascl_work: FunctionTypes.LAPACKE_slascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlascl_work: FunctionTypes.LAPACKE_dlascl_work? = load(name: "LAPACKE_dlascl_work")
    #elseif os(macOS)
    static let dlascl_work: FunctionTypes.LAPACKE_dlascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clascl_work: FunctionTypes.LAPACKE_clascl_work? = load(name: "LAPACKE_clascl_work")
    #elseif os(macOS)
    static let clascl_work: FunctionTypes.LAPACKE_clascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlascl_work: FunctionTypes.LAPACKE_zlascl_work? = load(name: "LAPACKE_zlascl_work")
    #elseif os(macOS)
    static let zlascl_work: FunctionTypes.LAPACKE_zlascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaset_work: FunctionTypes.LAPACKE_slaset_work? = load(name: "LAPACKE_slaset_work")
    #elseif os(macOS)
    static let slaset_work: FunctionTypes.LAPACKE_slaset_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaset_work: FunctionTypes.LAPACKE_dlaset_work? = load(name: "LAPACKE_dlaset_work")
    #elseif os(macOS)
    static let dlaset_work: FunctionTypes.LAPACKE_dlaset_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slasrt_work: FunctionTypes.LAPACKE_slasrt_work? = load(name: "LAPACKE_slasrt_work")
    #elseif os(macOS)
    static let slasrt_work: FunctionTypes.LAPACKE_slasrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlasrt_work: FunctionTypes.LAPACKE_dlasrt_work? = load(name: "LAPACKE_dlasrt_work")
    #elseif os(macOS)
    static let dlasrt_work: FunctionTypes.LAPACKE_dlasrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slassq_work: FunctionTypes.LAPACKE_slassq_work? = load(name: "LAPACKE_slassq_work")
    #elseif os(macOS)
    static let slassq_work: FunctionTypes.LAPACKE_slassq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlassq_work: FunctionTypes.LAPACKE_dlassq_work? = load(name: "LAPACKE_dlassq_work")
    #elseif os(macOS)
    static let dlassq_work: FunctionTypes.LAPACKE_dlassq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let classq_work: FunctionTypes.LAPACKE_classq_work? = load(name: "LAPACKE_classq_work")
    #elseif os(macOS)
    static let classq_work: FunctionTypes.LAPACKE_classq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlassq_work: FunctionTypes.LAPACKE_zlassq_work? = load(name: "LAPACKE_zlassq_work")
    #elseif os(macOS)
    static let zlassq_work: FunctionTypes.LAPACKE_zlassq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaswp_work: FunctionTypes.LAPACKE_slaswp_work? = load(name: "LAPACKE_slaswp_work")
    #elseif os(macOS)
    static let slaswp_work: FunctionTypes.LAPACKE_slaswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaswp_work: FunctionTypes.LAPACKE_dlaswp_work? = load(name: "LAPACKE_dlaswp_work")
    #elseif os(macOS)
    static let dlaswp_work: FunctionTypes.LAPACKE_dlaswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claswp_work: FunctionTypes.LAPACKE_claswp_work? = load(name: "LAPACKE_claswp_work")
    #elseif os(macOS)
    static let claswp_work: FunctionTypes.LAPACKE_claswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaswp_work: FunctionTypes.LAPACKE_zlaswp_work? = load(name: "LAPACKE_zlaswp_work")
    #elseif os(macOS)
    static let zlaswp_work: FunctionTypes.LAPACKE_zlaswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slatms_work: FunctionTypes.LAPACKE_slatms_work? = load(name: "LAPACKE_slatms_work")
    #elseif os(macOS)
    static let slatms_work: FunctionTypes.LAPACKE_slatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlatms_work: FunctionTypes.LAPACKE_dlatms_work? = load(name: "LAPACKE_dlatms_work")
    #elseif os(macOS)
    static let dlatms_work: FunctionTypes.LAPACKE_dlatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clatms_work: FunctionTypes.LAPACKE_clatms_work? = load(name: "LAPACKE_clatms_work")
    #elseif os(macOS)
    static let clatms_work: FunctionTypes.LAPACKE_clatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlatms_work: FunctionTypes.LAPACKE_zlatms_work? = load(name: "LAPACKE_zlatms_work")
    #elseif os(macOS)
    static let zlatms_work: FunctionTypes.LAPACKE_zlatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slauum_work: FunctionTypes.LAPACKE_slauum_work? = load(name: "LAPACKE_slauum_work")
    #elseif os(macOS)
    static let slauum_work: FunctionTypes.LAPACKE_slauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlauum_work: FunctionTypes.LAPACKE_dlauum_work? = load(name: "LAPACKE_dlauum_work")
    #elseif os(macOS)
    static let dlauum_work: FunctionTypes.LAPACKE_dlauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clauum_work: FunctionTypes.LAPACKE_clauum_work? = load(name: "LAPACKE_clauum_work")
    #elseif os(macOS)
    static let clauum_work: FunctionTypes.LAPACKE_clauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlauum_work: FunctionTypes.LAPACKE_zlauum_work? = load(name: "LAPACKE_zlauum_work")
    #elseif os(macOS)
    static let zlauum_work: FunctionTypes.LAPACKE_zlauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopgtr_work: FunctionTypes.LAPACKE_sopgtr_work? = load(name: "LAPACKE_sopgtr_work")
    #elseif os(macOS)
    static let sopgtr_work: FunctionTypes.LAPACKE_sopgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopgtr_work: FunctionTypes.LAPACKE_dopgtr_work? = load(name: "LAPACKE_dopgtr_work")
    #elseif os(macOS)
    static let dopgtr_work: FunctionTypes.LAPACKE_dopgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopmtr_work: FunctionTypes.LAPACKE_sopmtr_work? = load(name: "LAPACKE_sopmtr_work")
    #elseif os(macOS)
    static let sopmtr_work: FunctionTypes.LAPACKE_sopmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopmtr_work: FunctionTypes.LAPACKE_dopmtr_work? = load(name: "LAPACKE_dopmtr_work")
    #elseif os(macOS)
    static let dopmtr_work: FunctionTypes.LAPACKE_dopmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgbr_work: FunctionTypes.LAPACKE_sorgbr_work? = load(name: "LAPACKE_sorgbr_work")
    #elseif os(macOS)
    static let sorgbr_work: FunctionTypes.LAPACKE_sorgbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgbr_work: FunctionTypes.LAPACKE_dorgbr_work? = load(name: "LAPACKE_dorgbr_work")
    #elseif os(macOS)
    static let dorgbr_work: FunctionTypes.LAPACKE_dorgbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorghr_work: FunctionTypes.LAPACKE_sorghr_work? = load(name: "LAPACKE_sorghr_work")
    #elseif os(macOS)
    static let sorghr_work: FunctionTypes.LAPACKE_sorghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorghr_work: FunctionTypes.LAPACKE_dorghr_work? = load(name: "LAPACKE_dorghr_work")
    #elseif os(macOS)
    static let dorghr_work: FunctionTypes.LAPACKE_dorghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorglq_work: FunctionTypes.LAPACKE_sorglq_work? = load(name: "LAPACKE_sorglq_work")
    #elseif os(macOS)
    static let sorglq_work: FunctionTypes.LAPACKE_sorglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorglq_work: FunctionTypes.LAPACKE_dorglq_work? = load(name: "LAPACKE_dorglq_work")
    #elseif os(macOS)
    static let dorglq_work: FunctionTypes.LAPACKE_dorglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgql_work: FunctionTypes.LAPACKE_sorgql_work? = load(name: "LAPACKE_sorgql_work")
    #elseif os(macOS)
    static let sorgql_work: FunctionTypes.LAPACKE_sorgql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgql_work: FunctionTypes.LAPACKE_dorgql_work? = load(name: "LAPACKE_dorgql_work")
    #elseif os(macOS)
    static let dorgql_work: FunctionTypes.LAPACKE_dorgql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgqr_work: FunctionTypes.LAPACKE_sorgqr_work? = load(name: "LAPACKE_sorgqr_work")
    #elseif os(macOS)
    static let sorgqr_work: FunctionTypes.LAPACKE_sorgqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgqr_work: FunctionTypes.LAPACKE_dorgqr_work? = load(name: "LAPACKE_dorgqr_work")
    #elseif os(macOS)
    static let dorgqr_work: FunctionTypes.LAPACKE_dorgqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgrq_work: FunctionTypes.LAPACKE_sorgrq_work? = load(name: "LAPACKE_sorgrq_work")
    #elseif os(macOS)
    static let sorgrq_work: FunctionTypes.LAPACKE_sorgrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgrq_work: FunctionTypes.LAPACKE_dorgrq_work? = load(name: "LAPACKE_dorgrq_work")
    #elseif os(macOS)
    static let dorgrq_work: FunctionTypes.LAPACKE_dorgrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtr_work: FunctionTypes.LAPACKE_sorgtr_work? = load(name: "LAPACKE_sorgtr_work")
    #elseif os(macOS)
    static let sorgtr_work: FunctionTypes.LAPACKE_sorgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtr_work: FunctionTypes.LAPACKE_dorgtr_work? = load(name: "LAPACKE_dorgtr_work")
    #elseif os(macOS)
    static let dorgtr_work: FunctionTypes.LAPACKE_dorgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtsqr_row_work: FunctionTypes.LAPACKE_sorgtsqr_row_work? = load(name: "LAPACKE_sorgtsqr_row_work")
    #elseif os(macOS)
    static let sorgtsqr_row_work: FunctionTypes.LAPACKE_sorgtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtsqr_row_work: FunctionTypes.LAPACKE_dorgtsqr_row_work? = load(name: "LAPACKE_dorgtsqr_row_work")
    #elseif os(macOS)
    static let dorgtsqr_row_work: FunctionTypes.LAPACKE_dorgtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormbr_work: FunctionTypes.LAPACKE_sormbr_work? = load(name: "LAPACKE_sormbr_work")
    #elseif os(macOS)
    static let sormbr_work: FunctionTypes.LAPACKE_sormbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormbr_work: FunctionTypes.LAPACKE_dormbr_work? = load(name: "LAPACKE_dormbr_work")
    #elseif os(macOS)
    static let dormbr_work: FunctionTypes.LAPACKE_dormbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormhr_work: FunctionTypes.LAPACKE_sormhr_work? = load(name: "LAPACKE_sormhr_work")
    #elseif os(macOS)
    static let sormhr_work: FunctionTypes.LAPACKE_sormhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormhr_work: FunctionTypes.LAPACKE_dormhr_work? = load(name: "LAPACKE_dormhr_work")
    #elseif os(macOS)
    static let dormhr_work: FunctionTypes.LAPACKE_dormhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormlq_work: FunctionTypes.LAPACKE_sormlq_work? = load(name: "LAPACKE_sormlq_work")
    #elseif os(macOS)
    static let sormlq_work: FunctionTypes.LAPACKE_sormlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormlq_work: FunctionTypes.LAPACKE_dormlq_work? = load(name: "LAPACKE_dormlq_work")
    #elseif os(macOS)
    static let dormlq_work: FunctionTypes.LAPACKE_dormlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormql_work: FunctionTypes.LAPACKE_sormql_work? = load(name: "LAPACKE_sormql_work")
    #elseif os(macOS)
    static let sormql_work: FunctionTypes.LAPACKE_sormql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormql_work: FunctionTypes.LAPACKE_dormql_work? = load(name: "LAPACKE_dormql_work")
    #elseif os(macOS)
    static let dormql_work: FunctionTypes.LAPACKE_dormql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormqr_work: FunctionTypes.LAPACKE_sormqr_work? = load(name: "LAPACKE_sormqr_work")
    #elseif os(macOS)
    static let sormqr_work: FunctionTypes.LAPACKE_sormqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormqr_work: FunctionTypes.LAPACKE_dormqr_work? = load(name: "LAPACKE_dormqr_work")
    #elseif os(macOS)
    static let dormqr_work: FunctionTypes.LAPACKE_dormqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrq_work: FunctionTypes.LAPACKE_sormrq_work? = load(name: "LAPACKE_sormrq_work")
    #elseif os(macOS)
    static let sormrq_work: FunctionTypes.LAPACKE_sormrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrq_work: FunctionTypes.LAPACKE_dormrq_work? = load(name: "LAPACKE_dormrq_work")
    #elseif os(macOS)
    static let dormrq_work: FunctionTypes.LAPACKE_dormrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrz_work: FunctionTypes.LAPACKE_sormrz_work? = load(name: "LAPACKE_sormrz_work")
    #elseif os(macOS)
    static let sormrz_work: FunctionTypes.LAPACKE_sormrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrz_work: FunctionTypes.LAPACKE_dormrz_work? = load(name: "LAPACKE_dormrz_work")
    #elseif os(macOS)
    static let dormrz_work: FunctionTypes.LAPACKE_dormrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormtr_work: FunctionTypes.LAPACKE_sormtr_work? = load(name: "LAPACKE_sormtr_work")
    #elseif os(macOS)
    static let sormtr_work: FunctionTypes.LAPACKE_sormtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormtr_work: FunctionTypes.LAPACKE_dormtr_work? = load(name: "LAPACKE_dormtr_work")
    #elseif os(macOS)
    static let dormtr_work: FunctionTypes.LAPACKE_dormtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbcon_work: FunctionTypes.LAPACKE_spbcon_work? = load(name: "LAPACKE_spbcon_work")
    #elseif os(macOS)
    static let spbcon_work: FunctionTypes.LAPACKE_spbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbcon_work: FunctionTypes.LAPACKE_dpbcon_work? = load(name: "LAPACKE_dpbcon_work")
    #elseif os(macOS)
    static let dpbcon_work: FunctionTypes.LAPACKE_dpbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbcon_work: FunctionTypes.LAPACKE_cpbcon_work? = load(name: "LAPACKE_cpbcon_work")
    #elseif os(macOS)
    static let cpbcon_work: FunctionTypes.LAPACKE_cpbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbcon_work: FunctionTypes.LAPACKE_zpbcon_work? = load(name: "LAPACKE_zpbcon_work")
    #elseif os(macOS)
    static let zpbcon_work: FunctionTypes.LAPACKE_zpbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbequ_work: FunctionTypes.LAPACKE_spbequ_work? = load(name: "LAPACKE_spbequ_work")
    #elseif os(macOS)
    static let spbequ_work: FunctionTypes.LAPACKE_spbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbequ_work: FunctionTypes.LAPACKE_dpbequ_work? = load(name: "LAPACKE_dpbequ_work")
    #elseif os(macOS)
    static let dpbequ_work: FunctionTypes.LAPACKE_dpbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbequ_work: FunctionTypes.LAPACKE_cpbequ_work? = load(name: "LAPACKE_cpbequ_work")
    #elseif os(macOS)
    static let cpbequ_work: FunctionTypes.LAPACKE_cpbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbequ_work: FunctionTypes.LAPACKE_zpbequ_work? = load(name: "LAPACKE_zpbequ_work")
    #elseif os(macOS)
    static let zpbequ_work: FunctionTypes.LAPACKE_zpbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbrfs_work: FunctionTypes.LAPACKE_spbrfs_work? = load(name: "LAPACKE_spbrfs_work")
    #elseif os(macOS)
    static let spbrfs_work: FunctionTypes.LAPACKE_spbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbrfs_work: FunctionTypes.LAPACKE_dpbrfs_work? = load(name: "LAPACKE_dpbrfs_work")
    #elseif os(macOS)
    static let dpbrfs_work: FunctionTypes.LAPACKE_dpbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbrfs_work: FunctionTypes.LAPACKE_cpbrfs_work? = load(name: "LAPACKE_cpbrfs_work")
    #elseif os(macOS)
    static let cpbrfs_work: FunctionTypes.LAPACKE_cpbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbrfs_work: FunctionTypes.LAPACKE_zpbrfs_work? = load(name: "LAPACKE_zpbrfs_work")
    #elseif os(macOS)
    static let zpbrfs_work: FunctionTypes.LAPACKE_zpbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbstf_work: FunctionTypes.LAPACKE_spbstf_work? = load(name: "LAPACKE_spbstf_work")
    #elseif os(macOS)
    static let spbstf_work: FunctionTypes.LAPACKE_spbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbstf_work: FunctionTypes.LAPACKE_dpbstf_work? = load(name: "LAPACKE_dpbstf_work")
    #elseif os(macOS)
    static let dpbstf_work: FunctionTypes.LAPACKE_dpbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbstf_work: FunctionTypes.LAPACKE_cpbstf_work? = load(name: "LAPACKE_cpbstf_work")
    #elseif os(macOS)
    static let cpbstf_work: FunctionTypes.LAPACKE_cpbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbstf_work: FunctionTypes.LAPACKE_zpbstf_work? = load(name: "LAPACKE_zpbstf_work")
    #elseif os(macOS)
    static let zpbstf_work: FunctionTypes.LAPACKE_zpbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsv_work: FunctionTypes.LAPACKE_spbsv_work? = load(name: "LAPACKE_spbsv_work")
    #elseif os(macOS)
    static let spbsv_work: FunctionTypes.LAPACKE_spbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsv_work: FunctionTypes.LAPACKE_dpbsv_work? = load(name: "LAPACKE_dpbsv_work")
    #elseif os(macOS)
    static let dpbsv_work: FunctionTypes.LAPACKE_dpbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsv_work: FunctionTypes.LAPACKE_cpbsv_work? = load(name: "LAPACKE_cpbsv_work")
    #elseif os(macOS)
    static let cpbsv_work: FunctionTypes.LAPACKE_cpbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsv_work: FunctionTypes.LAPACKE_zpbsv_work? = load(name: "LAPACKE_zpbsv_work")
    #elseif os(macOS)
    static let zpbsv_work: FunctionTypes.LAPACKE_zpbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsvx_work: FunctionTypes.LAPACKE_spbsvx_work? = load(name: "LAPACKE_spbsvx_work")
    #elseif os(macOS)
    static let spbsvx_work: FunctionTypes.LAPACKE_spbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsvx_work: FunctionTypes.LAPACKE_dpbsvx_work? = load(name: "LAPACKE_dpbsvx_work")
    #elseif os(macOS)
    static let dpbsvx_work: FunctionTypes.LAPACKE_dpbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsvx_work: FunctionTypes.LAPACKE_cpbsvx_work? = load(name: "LAPACKE_cpbsvx_work")
    #elseif os(macOS)
    static let cpbsvx_work: FunctionTypes.LAPACKE_cpbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsvx_work: FunctionTypes.LAPACKE_zpbsvx_work? = load(name: "LAPACKE_zpbsvx_work")
    #elseif os(macOS)
    static let zpbsvx_work: FunctionTypes.LAPACKE_zpbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrf_work: FunctionTypes.LAPACKE_spbtrf_work? = load(name: "LAPACKE_spbtrf_work")
    #elseif os(macOS)
    static let spbtrf_work: FunctionTypes.LAPACKE_spbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrf_work: FunctionTypes.LAPACKE_dpbtrf_work? = load(name: "LAPACKE_dpbtrf_work")
    #elseif os(macOS)
    static let dpbtrf_work: FunctionTypes.LAPACKE_dpbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrf_work: FunctionTypes.LAPACKE_cpbtrf_work? = load(name: "LAPACKE_cpbtrf_work")
    #elseif os(macOS)
    static let cpbtrf_work: FunctionTypes.LAPACKE_cpbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrf_work: FunctionTypes.LAPACKE_zpbtrf_work? = load(name: "LAPACKE_zpbtrf_work")
    #elseif os(macOS)
    static let zpbtrf_work: FunctionTypes.LAPACKE_zpbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrs_work: FunctionTypes.LAPACKE_spbtrs_work? = load(name: "LAPACKE_spbtrs_work")
    #elseif os(macOS)
    static let spbtrs_work: FunctionTypes.LAPACKE_spbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrs_work: FunctionTypes.LAPACKE_dpbtrs_work? = load(name: "LAPACKE_dpbtrs_work")
    #elseif os(macOS)
    static let dpbtrs_work: FunctionTypes.LAPACKE_dpbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrs_work: FunctionTypes.LAPACKE_cpbtrs_work? = load(name: "LAPACKE_cpbtrs_work")
    #elseif os(macOS)
    static let cpbtrs_work: FunctionTypes.LAPACKE_cpbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrs_work: FunctionTypes.LAPACKE_zpbtrs_work? = load(name: "LAPACKE_zpbtrs_work")
    #elseif os(macOS)
    static let zpbtrs_work: FunctionTypes.LAPACKE_zpbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrf_work: FunctionTypes.LAPACKE_spftrf_work? = load(name: "LAPACKE_spftrf_work")
    #elseif os(macOS)
    static let spftrf_work: FunctionTypes.LAPACKE_spftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrf_work: FunctionTypes.LAPACKE_dpftrf_work? = load(name: "LAPACKE_dpftrf_work")
    #elseif os(macOS)
    static let dpftrf_work: FunctionTypes.LAPACKE_dpftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrf_work: FunctionTypes.LAPACKE_cpftrf_work? = load(name: "LAPACKE_cpftrf_work")
    #elseif os(macOS)
    static let cpftrf_work: FunctionTypes.LAPACKE_cpftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrf_work: FunctionTypes.LAPACKE_zpftrf_work? = load(name: "LAPACKE_zpftrf_work")
    #elseif os(macOS)
    static let zpftrf_work: FunctionTypes.LAPACKE_zpftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftri_work: FunctionTypes.LAPACKE_spftri_work? = load(name: "LAPACKE_spftri_work")
    #elseif os(macOS)
    static let spftri_work: FunctionTypes.LAPACKE_spftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftri_work: FunctionTypes.LAPACKE_dpftri_work? = load(name: "LAPACKE_dpftri_work")
    #elseif os(macOS)
    static let dpftri_work: FunctionTypes.LAPACKE_dpftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftri_work: FunctionTypes.LAPACKE_cpftri_work? = load(name: "LAPACKE_cpftri_work")
    #elseif os(macOS)
    static let cpftri_work: FunctionTypes.LAPACKE_cpftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftri_work: FunctionTypes.LAPACKE_zpftri_work? = load(name: "LAPACKE_zpftri_work")
    #elseif os(macOS)
    static let zpftri_work: FunctionTypes.LAPACKE_zpftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrs_work: FunctionTypes.LAPACKE_spftrs_work? = load(name: "LAPACKE_spftrs_work")
    #elseif os(macOS)
    static let spftrs_work: FunctionTypes.LAPACKE_spftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrs_work: FunctionTypes.LAPACKE_dpftrs_work? = load(name: "LAPACKE_dpftrs_work")
    #elseif os(macOS)
    static let dpftrs_work: FunctionTypes.LAPACKE_dpftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrs_work: FunctionTypes.LAPACKE_cpftrs_work? = load(name: "LAPACKE_cpftrs_work")
    #elseif os(macOS)
    static let cpftrs_work: FunctionTypes.LAPACKE_cpftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrs_work: FunctionTypes.LAPACKE_zpftrs_work? = load(name: "LAPACKE_zpftrs_work")
    #elseif os(macOS)
    static let zpftrs_work: FunctionTypes.LAPACKE_zpftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spocon_work: FunctionTypes.LAPACKE_spocon_work? = load(name: "LAPACKE_spocon_work")
    #elseif os(macOS)
    static let spocon_work: FunctionTypes.LAPACKE_spocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpocon_work: FunctionTypes.LAPACKE_dpocon_work? = load(name: "LAPACKE_dpocon_work")
    #elseif os(macOS)
    static let dpocon_work: FunctionTypes.LAPACKE_dpocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpocon_work: FunctionTypes.LAPACKE_cpocon_work? = load(name: "LAPACKE_cpocon_work")
    #elseif os(macOS)
    static let cpocon_work: FunctionTypes.LAPACKE_cpocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpocon_work: FunctionTypes.LAPACKE_zpocon_work? = load(name: "LAPACKE_zpocon_work")
    #elseif os(macOS)
    static let zpocon_work: FunctionTypes.LAPACKE_zpocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequ_work: FunctionTypes.LAPACKE_spoequ_work? = load(name: "LAPACKE_spoequ_work")
    #elseif os(macOS)
    static let spoequ_work: FunctionTypes.LAPACKE_spoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequ_work: FunctionTypes.LAPACKE_dpoequ_work? = load(name: "LAPACKE_dpoequ_work")
    #elseif os(macOS)
    static let dpoequ_work: FunctionTypes.LAPACKE_dpoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequ_work: FunctionTypes.LAPACKE_cpoequ_work? = load(name: "LAPACKE_cpoequ_work")
    #elseif os(macOS)
    static let cpoequ_work: FunctionTypes.LAPACKE_cpoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequ_work: FunctionTypes.LAPACKE_zpoequ_work? = load(name: "LAPACKE_zpoequ_work")
    #elseif os(macOS)
    static let zpoequ_work: FunctionTypes.LAPACKE_zpoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequb_work: FunctionTypes.LAPACKE_spoequb_work? = load(name: "LAPACKE_spoequb_work")
    #elseif os(macOS)
    static let spoequb_work: FunctionTypes.LAPACKE_spoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequb_work: FunctionTypes.LAPACKE_dpoequb_work? = load(name: "LAPACKE_dpoequb_work")
    #elseif os(macOS)
    static let dpoequb_work: FunctionTypes.LAPACKE_dpoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequb_work: FunctionTypes.LAPACKE_cpoequb_work? = load(name: "LAPACKE_cpoequb_work")
    #elseif os(macOS)
    static let cpoequb_work: FunctionTypes.LAPACKE_cpoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequb_work: FunctionTypes.LAPACKE_zpoequb_work? = load(name: "LAPACKE_zpoequb_work")
    #elseif os(macOS)
    static let zpoequb_work: FunctionTypes.LAPACKE_zpoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfs_work: FunctionTypes.LAPACKE_sporfs_work? = load(name: "LAPACKE_sporfs_work")
    #elseif os(macOS)
    static let sporfs_work: FunctionTypes.LAPACKE_sporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfs_work: FunctionTypes.LAPACKE_dporfs_work? = load(name: "LAPACKE_dporfs_work")
    #elseif os(macOS)
    static let dporfs_work: FunctionTypes.LAPACKE_dporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfs_work: FunctionTypes.LAPACKE_cporfs_work? = load(name: "LAPACKE_cporfs_work")
    #elseif os(macOS)
    static let cporfs_work: FunctionTypes.LAPACKE_cporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfs_work: FunctionTypes.LAPACKE_zporfs_work? = load(name: "LAPACKE_zporfs_work")
    #elseif os(macOS)
    static let zporfs_work: FunctionTypes.LAPACKE_zporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfsx_work: FunctionTypes.LAPACKE_sporfsx_work? = load(name: "LAPACKE_sporfsx_work")
    #elseif os(macOS)
    static let sporfsx_work: FunctionTypes.LAPACKE_sporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfsx_work: FunctionTypes.LAPACKE_dporfsx_work? = load(name: "LAPACKE_dporfsx_work")
    #elseif os(macOS)
    static let dporfsx_work: FunctionTypes.LAPACKE_dporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfsx_work: FunctionTypes.LAPACKE_cporfsx_work? = load(name: "LAPACKE_cporfsx_work")
    #elseif os(macOS)
    static let cporfsx_work: FunctionTypes.LAPACKE_cporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfsx_work: FunctionTypes.LAPACKE_zporfsx_work? = load(name: "LAPACKE_zporfsx_work")
    #elseif os(macOS)
    static let zporfsx_work: FunctionTypes.LAPACKE_zporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposv_work: FunctionTypes.LAPACKE_sposv_work? = load(name: "LAPACKE_sposv_work")
    #elseif os(macOS)
    static let sposv_work: FunctionTypes.LAPACKE_sposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposv_work: FunctionTypes.LAPACKE_dposv_work? = load(name: "LAPACKE_dposv_work")
    #elseif os(macOS)
    static let dposv_work: FunctionTypes.LAPACKE_dposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposv_work: FunctionTypes.LAPACKE_cposv_work? = load(name: "LAPACKE_cposv_work")
    #elseif os(macOS)
    static let cposv_work: FunctionTypes.LAPACKE_cposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposv_work: FunctionTypes.LAPACKE_zposv_work? = load(name: "LAPACKE_zposv_work")
    #elseif os(macOS)
    static let zposv_work: FunctionTypes.LAPACKE_zposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsposv_work: FunctionTypes.LAPACKE_dsposv_work? = load(name: "LAPACKE_dsposv_work")
    #elseif os(macOS)
    static let dsposv_work: FunctionTypes.LAPACKE_dsposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcposv_work: FunctionTypes.LAPACKE_zcposv_work? = load(name: "LAPACKE_zcposv_work")
    #elseif os(macOS)
    static let zcposv_work: FunctionTypes.LAPACKE_zcposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvx_work: FunctionTypes.LAPACKE_sposvx_work? = load(name: "LAPACKE_sposvx_work")
    #elseif os(macOS)
    static let sposvx_work: FunctionTypes.LAPACKE_sposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvx_work: FunctionTypes.LAPACKE_dposvx_work? = load(name: "LAPACKE_dposvx_work")
    #elseif os(macOS)
    static let dposvx_work: FunctionTypes.LAPACKE_dposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvx_work: FunctionTypes.LAPACKE_cposvx_work? = load(name: "LAPACKE_cposvx_work")
    #elseif os(macOS)
    static let cposvx_work: FunctionTypes.LAPACKE_cposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvx_work: FunctionTypes.LAPACKE_zposvx_work? = load(name: "LAPACKE_zposvx_work")
    #elseif os(macOS)
    static let zposvx_work: FunctionTypes.LAPACKE_zposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvxx_work: FunctionTypes.LAPACKE_sposvxx_work? = load(name: "LAPACKE_sposvxx_work")
    #elseif os(macOS)
    static let sposvxx_work: FunctionTypes.LAPACKE_sposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvxx_work: FunctionTypes.LAPACKE_dposvxx_work? = load(name: "LAPACKE_dposvxx_work")
    #elseif os(macOS)
    static let dposvxx_work: FunctionTypes.LAPACKE_dposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvxx_work: FunctionTypes.LAPACKE_cposvxx_work? = load(name: "LAPACKE_cposvxx_work")
    #elseif os(macOS)
    static let cposvxx_work: FunctionTypes.LAPACKE_cposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvxx_work: FunctionTypes.LAPACKE_zposvxx_work? = load(name: "LAPACKE_zposvxx_work")
    #elseif os(macOS)
    static let zposvxx_work: FunctionTypes.LAPACKE_zposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf2_work: FunctionTypes.LAPACKE_spotrf2_work? = load(name: "LAPACKE_spotrf2_work")
    #elseif os(macOS)
    static let spotrf2_work: FunctionTypes.LAPACKE_spotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf2_work: FunctionTypes.LAPACKE_dpotrf2_work? = load(name: "LAPACKE_dpotrf2_work")
    #elseif os(macOS)
    static let dpotrf2_work: FunctionTypes.LAPACKE_dpotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf2_work: FunctionTypes.LAPACKE_cpotrf2_work? = load(name: "LAPACKE_cpotrf2_work")
    #elseif os(macOS)
    static let cpotrf2_work: FunctionTypes.LAPACKE_cpotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf2_work: FunctionTypes.LAPACKE_zpotrf2_work? = load(name: "LAPACKE_zpotrf2_work")
    #elseif os(macOS)
    static let zpotrf2_work: FunctionTypes.LAPACKE_zpotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf_work: FunctionTypes.LAPACKE_spotrf_work? = load(name: "LAPACKE_spotrf_work")
    #elseif os(macOS)
    static let spotrf_work: FunctionTypes.LAPACKE_spotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf_work: FunctionTypes.LAPACKE_dpotrf_work? = load(name: "LAPACKE_dpotrf_work")
    #elseif os(macOS)
    static let dpotrf_work: FunctionTypes.LAPACKE_dpotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf_work: FunctionTypes.LAPACKE_cpotrf_work? = load(name: "LAPACKE_cpotrf_work")
    #elseif os(macOS)
    static let cpotrf_work: FunctionTypes.LAPACKE_cpotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf_work: FunctionTypes.LAPACKE_zpotrf_work? = load(name: "LAPACKE_zpotrf_work")
    #elseif os(macOS)
    static let zpotrf_work: FunctionTypes.LAPACKE_zpotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotri_work: FunctionTypes.LAPACKE_spotri_work? = load(name: "LAPACKE_spotri_work")
    #elseif os(macOS)
    static let spotri_work: FunctionTypes.LAPACKE_spotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotri_work: FunctionTypes.LAPACKE_dpotri_work? = load(name: "LAPACKE_dpotri_work")
    #elseif os(macOS)
    static let dpotri_work: FunctionTypes.LAPACKE_dpotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotri_work: FunctionTypes.LAPACKE_cpotri_work? = load(name: "LAPACKE_cpotri_work")
    #elseif os(macOS)
    static let cpotri_work: FunctionTypes.LAPACKE_cpotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotri_work: FunctionTypes.LAPACKE_zpotri_work? = load(name: "LAPACKE_zpotri_work")
    #elseif os(macOS)
    static let zpotri_work: FunctionTypes.LAPACKE_zpotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrs_work: FunctionTypes.LAPACKE_spotrs_work? = load(name: "LAPACKE_spotrs_work")
    #elseif os(macOS)
    static let spotrs_work: FunctionTypes.LAPACKE_spotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrs_work: FunctionTypes.LAPACKE_dpotrs_work? = load(name: "LAPACKE_dpotrs_work")
    #elseif os(macOS)
    static let dpotrs_work: FunctionTypes.LAPACKE_dpotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrs_work: FunctionTypes.LAPACKE_cpotrs_work? = load(name: "LAPACKE_cpotrs_work")
    #elseif os(macOS)
    static let cpotrs_work: FunctionTypes.LAPACKE_cpotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrs_work: FunctionTypes.LAPACKE_zpotrs_work? = load(name: "LAPACKE_zpotrs_work")
    #elseif os(macOS)
    static let zpotrs_work: FunctionTypes.LAPACKE_zpotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppcon_work: FunctionTypes.LAPACKE_sppcon_work? = load(name: "LAPACKE_sppcon_work")
    #elseif os(macOS)
    static let sppcon_work: FunctionTypes.LAPACKE_sppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppcon_work: FunctionTypes.LAPACKE_dppcon_work? = load(name: "LAPACKE_dppcon_work")
    #elseif os(macOS)
    static let dppcon_work: FunctionTypes.LAPACKE_dppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppcon_work: FunctionTypes.LAPACKE_cppcon_work? = load(name: "LAPACKE_cppcon_work")
    #elseif os(macOS)
    static let cppcon_work: FunctionTypes.LAPACKE_cppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppcon_work: FunctionTypes.LAPACKE_zppcon_work? = load(name: "LAPACKE_zppcon_work")
    #elseif os(macOS)
    static let zppcon_work: FunctionTypes.LAPACKE_zppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppequ_work: FunctionTypes.LAPACKE_sppequ_work? = load(name: "LAPACKE_sppequ_work")
    #elseif os(macOS)
    static let sppequ_work: FunctionTypes.LAPACKE_sppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppequ_work: FunctionTypes.LAPACKE_dppequ_work? = load(name: "LAPACKE_dppequ_work")
    #elseif os(macOS)
    static let dppequ_work: FunctionTypes.LAPACKE_dppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppequ_work: FunctionTypes.LAPACKE_cppequ_work? = load(name: "LAPACKE_cppequ_work")
    #elseif os(macOS)
    static let cppequ_work: FunctionTypes.LAPACKE_cppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppequ_work: FunctionTypes.LAPACKE_zppequ_work? = load(name: "LAPACKE_zppequ_work")
    #elseif os(macOS)
    static let zppequ_work: FunctionTypes.LAPACKE_zppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spprfs_work: FunctionTypes.LAPACKE_spprfs_work? = load(name: "LAPACKE_spprfs_work")
    #elseif os(macOS)
    static let spprfs_work: FunctionTypes.LAPACKE_spprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpprfs_work: FunctionTypes.LAPACKE_dpprfs_work? = load(name: "LAPACKE_dpprfs_work")
    #elseif os(macOS)
    static let dpprfs_work: FunctionTypes.LAPACKE_dpprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpprfs_work: FunctionTypes.LAPACKE_cpprfs_work? = load(name: "LAPACKE_cpprfs_work")
    #elseif os(macOS)
    static let cpprfs_work: FunctionTypes.LAPACKE_cpprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpprfs_work: FunctionTypes.LAPACKE_zpprfs_work? = load(name: "LAPACKE_zpprfs_work")
    #elseif os(macOS)
    static let zpprfs_work: FunctionTypes.LAPACKE_zpprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsv_work: FunctionTypes.LAPACKE_sppsv_work? = load(name: "LAPACKE_sppsv_work")
    #elseif os(macOS)
    static let sppsv_work: FunctionTypes.LAPACKE_sppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsv_work: FunctionTypes.LAPACKE_dppsv_work? = load(name: "LAPACKE_dppsv_work")
    #elseif os(macOS)
    static let dppsv_work: FunctionTypes.LAPACKE_dppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsv_work: FunctionTypes.LAPACKE_cppsv_work? = load(name: "LAPACKE_cppsv_work")
    #elseif os(macOS)
    static let cppsv_work: FunctionTypes.LAPACKE_cppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsv_work: FunctionTypes.LAPACKE_zppsv_work? = load(name: "LAPACKE_zppsv_work")
    #elseif os(macOS)
    static let zppsv_work: FunctionTypes.LAPACKE_zppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsvx_work: FunctionTypes.LAPACKE_sppsvx_work? = load(name: "LAPACKE_sppsvx_work")
    #elseif os(macOS)
    static let sppsvx_work: FunctionTypes.LAPACKE_sppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsvx_work: FunctionTypes.LAPACKE_dppsvx_work? = load(name: "LAPACKE_dppsvx_work")
    #elseif os(macOS)
    static let dppsvx_work: FunctionTypes.LAPACKE_dppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsvx_work: FunctionTypes.LAPACKE_cppsvx_work? = load(name: "LAPACKE_cppsvx_work")
    #elseif os(macOS)
    static let cppsvx_work: FunctionTypes.LAPACKE_cppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsvx_work: FunctionTypes.LAPACKE_zppsvx_work? = load(name: "LAPACKE_zppsvx_work")
    #elseif os(macOS)
    static let zppsvx_work: FunctionTypes.LAPACKE_zppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrf_work: FunctionTypes.LAPACKE_spptrf_work? = load(name: "LAPACKE_spptrf_work")
    #elseif os(macOS)
    static let spptrf_work: FunctionTypes.LAPACKE_spptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrf_work: FunctionTypes.LAPACKE_dpptrf_work? = load(name: "LAPACKE_dpptrf_work")
    #elseif os(macOS)
    static let dpptrf_work: FunctionTypes.LAPACKE_dpptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrf_work: FunctionTypes.LAPACKE_cpptrf_work? = load(name: "LAPACKE_cpptrf_work")
    #elseif os(macOS)
    static let cpptrf_work: FunctionTypes.LAPACKE_cpptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrf_work: FunctionTypes.LAPACKE_zpptrf_work? = load(name: "LAPACKE_zpptrf_work")
    #elseif os(macOS)
    static let zpptrf_work: FunctionTypes.LAPACKE_zpptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptri_work: FunctionTypes.LAPACKE_spptri_work? = load(name: "LAPACKE_spptri_work")
    #elseif os(macOS)
    static let spptri_work: FunctionTypes.LAPACKE_spptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptri_work: FunctionTypes.LAPACKE_dpptri_work? = load(name: "LAPACKE_dpptri_work")
    #elseif os(macOS)
    static let dpptri_work: FunctionTypes.LAPACKE_dpptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptri_work: FunctionTypes.LAPACKE_cpptri_work? = load(name: "LAPACKE_cpptri_work")
    #elseif os(macOS)
    static let cpptri_work: FunctionTypes.LAPACKE_cpptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptri_work: FunctionTypes.LAPACKE_zpptri_work? = load(name: "LAPACKE_zpptri_work")
    #elseif os(macOS)
    static let zpptri_work: FunctionTypes.LAPACKE_zpptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrs_work: FunctionTypes.LAPACKE_spptrs_work? = load(name: "LAPACKE_spptrs_work")
    #elseif os(macOS)
    static let spptrs_work: FunctionTypes.LAPACKE_spptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrs_work: FunctionTypes.LAPACKE_dpptrs_work? = load(name: "LAPACKE_dpptrs_work")
    #elseif os(macOS)
    static let dpptrs_work: FunctionTypes.LAPACKE_dpptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrs_work: FunctionTypes.LAPACKE_cpptrs_work? = load(name: "LAPACKE_cpptrs_work")
    #elseif os(macOS)
    static let cpptrs_work: FunctionTypes.LAPACKE_cpptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrs_work: FunctionTypes.LAPACKE_zpptrs_work? = load(name: "LAPACKE_zpptrs_work")
    #elseif os(macOS)
    static let zpptrs_work: FunctionTypes.LAPACKE_zpptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spstrf_work: FunctionTypes.LAPACKE_spstrf_work? = load(name: "LAPACKE_spstrf_work")
    #elseif os(macOS)
    static let spstrf_work: FunctionTypes.LAPACKE_spstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpstrf_work: FunctionTypes.LAPACKE_dpstrf_work? = load(name: "LAPACKE_dpstrf_work")
    #elseif os(macOS)
    static let dpstrf_work: FunctionTypes.LAPACKE_dpstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpstrf_work: FunctionTypes.LAPACKE_cpstrf_work? = load(name: "LAPACKE_cpstrf_work")
    #elseif os(macOS)
    static let cpstrf_work: FunctionTypes.LAPACKE_cpstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpstrf_work: FunctionTypes.LAPACKE_zpstrf_work? = load(name: "LAPACKE_zpstrf_work")
    #elseif os(macOS)
    static let zpstrf_work: FunctionTypes.LAPACKE_zpstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptcon_work: FunctionTypes.LAPACKE_sptcon_work? = load(name: "LAPACKE_sptcon_work")
    #elseif os(macOS)
    static let sptcon_work: FunctionTypes.LAPACKE_sptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptcon_work: FunctionTypes.LAPACKE_dptcon_work? = load(name: "LAPACKE_dptcon_work")
    #elseif os(macOS)
    static let dptcon_work: FunctionTypes.LAPACKE_dptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptcon_work: FunctionTypes.LAPACKE_cptcon_work? = load(name: "LAPACKE_cptcon_work")
    #elseif os(macOS)
    static let cptcon_work: FunctionTypes.LAPACKE_cptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptcon_work: FunctionTypes.LAPACKE_zptcon_work? = load(name: "LAPACKE_zptcon_work")
    #elseif os(macOS)
    static let zptcon_work: FunctionTypes.LAPACKE_zptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spteqr_work: FunctionTypes.LAPACKE_spteqr_work? = load(name: "LAPACKE_spteqr_work")
    #elseif os(macOS)
    static let spteqr_work: FunctionTypes.LAPACKE_spteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpteqr_work: FunctionTypes.LAPACKE_dpteqr_work? = load(name: "LAPACKE_dpteqr_work")
    #elseif os(macOS)
    static let dpteqr_work: FunctionTypes.LAPACKE_dpteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpteqr_work: FunctionTypes.LAPACKE_cpteqr_work? = load(name: "LAPACKE_cpteqr_work")
    #elseif os(macOS)
    static let cpteqr_work: FunctionTypes.LAPACKE_cpteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpteqr_work: FunctionTypes.LAPACKE_zpteqr_work? = load(name: "LAPACKE_zpteqr_work")
    #elseif os(macOS)
    static let zpteqr_work: FunctionTypes.LAPACKE_zpteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptrfs_work: FunctionTypes.LAPACKE_sptrfs_work? = load(name: "LAPACKE_sptrfs_work")
    #elseif os(macOS)
    static let sptrfs_work: FunctionTypes.LAPACKE_sptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptrfs_work: FunctionTypes.LAPACKE_dptrfs_work? = load(name: "LAPACKE_dptrfs_work")
    #elseif os(macOS)
    static let dptrfs_work: FunctionTypes.LAPACKE_dptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptrfs_work: FunctionTypes.LAPACKE_cptrfs_work? = load(name: "LAPACKE_cptrfs_work")
    #elseif os(macOS)
    static let cptrfs_work: FunctionTypes.LAPACKE_cptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptrfs_work: FunctionTypes.LAPACKE_zptrfs_work? = load(name: "LAPACKE_zptrfs_work")
    #elseif os(macOS)
    static let zptrfs_work: FunctionTypes.LAPACKE_zptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsv_work: FunctionTypes.LAPACKE_sptsv_work? = load(name: "LAPACKE_sptsv_work")
    #elseif os(macOS)
    static let sptsv_work: FunctionTypes.LAPACKE_sptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsv_work: FunctionTypes.LAPACKE_dptsv_work? = load(name: "LAPACKE_dptsv_work")
    #elseif os(macOS)
    static let dptsv_work: FunctionTypes.LAPACKE_dptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsv_work: FunctionTypes.LAPACKE_cptsv_work? = load(name: "LAPACKE_cptsv_work")
    #elseif os(macOS)
    static let cptsv_work: FunctionTypes.LAPACKE_cptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsv_work: FunctionTypes.LAPACKE_zptsv_work? = load(name: "LAPACKE_zptsv_work")
    #elseif os(macOS)
    static let zptsv_work: FunctionTypes.LAPACKE_zptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsvx_work: FunctionTypes.LAPACKE_sptsvx_work? = load(name: "LAPACKE_sptsvx_work")
    #elseif os(macOS)
    static let sptsvx_work: FunctionTypes.LAPACKE_sptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsvx_work: FunctionTypes.LAPACKE_dptsvx_work? = load(name: "LAPACKE_dptsvx_work")
    #elseif os(macOS)
    static let dptsvx_work: FunctionTypes.LAPACKE_dptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsvx_work: FunctionTypes.LAPACKE_cptsvx_work? = load(name: "LAPACKE_cptsvx_work")
    #elseif os(macOS)
    static let cptsvx_work: FunctionTypes.LAPACKE_cptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsvx_work: FunctionTypes.LAPACKE_zptsvx_work? = load(name: "LAPACKE_zptsvx_work")
    #elseif os(macOS)
    static let zptsvx_work: FunctionTypes.LAPACKE_zptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrf_work: FunctionTypes.LAPACKE_spttrf_work? = load(name: "LAPACKE_spttrf_work")
    #elseif os(macOS)
    static let spttrf_work: FunctionTypes.LAPACKE_spttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrf_work: FunctionTypes.LAPACKE_dpttrf_work? = load(name: "LAPACKE_dpttrf_work")
    #elseif os(macOS)
    static let dpttrf_work: FunctionTypes.LAPACKE_dpttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrf_work: FunctionTypes.LAPACKE_cpttrf_work? = load(name: "LAPACKE_cpttrf_work")
    #elseif os(macOS)
    static let cpttrf_work: FunctionTypes.LAPACKE_cpttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrf_work: FunctionTypes.LAPACKE_zpttrf_work? = load(name: "LAPACKE_zpttrf_work")
    #elseif os(macOS)
    static let zpttrf_work: FunctionTypes.LAPACKE_zpttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrs_work: FunctionTypes.LAPACKE_spttrs_work? = load(name: "LAPACKE_spttrs_work")
    #elseif os(macOS)
    static let spttrs_work: FunctionTypes.LAPACKE_spttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrs_work: FunctionTypes.LAPACKE_dpttrs_work? = load(name: "LAPACKE_dpttrs_work")
    #elseif os(macOS)
    static let dpttrs_work: FunctionTypes.LAPACKE_dpttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrs_work: FunctionTypes.LAPACKE_cpttrs_work? = load(name: "LAPACKE_cpttrs_work")
    #elseif os(macOS)
    static let cpttrs_work: FunctionTypes.LAPACKE_cpttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrs_work: FunctionTypes.LAPACKE_zpttrs_work? = load(name: "LAPACKE_zpttrs_work")
    #elseif os(macOS)
    static let zpttrs_work: FunctionTypes.LAPACKE_zpttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev_work: FunctionTypes.LAPACKE_ssbev_work? = load(name: "LAPACKE_ssbev_work")
    #elseif os(macOS)
    static let ssbev_work: FunctionTypes.LAPACKE_ssbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev_work: FunctionTypes.LAPACKE_dsbev_work? = load(name: "LAPACKE_dsbev_work")
    #elseif os(macOS)
    static let dsbev_work: FunctionTypes.LAPACKE_dsbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd_work: FunctionTypes.LAPACKE_ssbevd_work? = load(name: "LAPACKE_ssbevd_work")
    #elseif os(macOS)
    static let ssbevd_work: FunctionTypes.LAPACKE_ssbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd_work: FunctionTypes.LAPACKE_dsbevd_work? = load(name: "LAPACKE_dsbevd_work")
    #elseif os(macOS)
    static let dsbevd_work: FunctionTypes.LAPACKE_dsbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx_work: FunctionTypes.LAPACKE_ssbevx_work? = load(name: "LAPACKE_ssbevx_work")
    #elseif os(macOS)
    static let ssbevx_work: FunctionTypes.LAPACKE_ssbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx_work: FunctionTypes.LAPACKE_dsbevx_work? = load(name: "LAPACKE_dsbevx_work")
    #elseif os(macOS)
    static let dsbevx_work: FunctionTypes.LAPACKE_dsbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgst_work: FunctionTypes.LAPACKE_ssbgst_work? = load(name: "LAPACKE_ssbgst_work")
    #elseif os(macOS)
    static let ssbgst_work: FunctionTypes.LAPACKE_ssbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgst_work: FunctionTypes.LAPACKE_dsbgst_work? = load(name: "LAPACKE_dsbgst_work")
    #elseif os(macOS)
    static let dsbgst_work: FunctionTypes.LAPACKE_dsbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgv_work: FunctionTypes.LAPACKE_ssbgv_work? = load(name: "LAPACKE_ssbgv_work")
    #elseif os(macOS)
    static let ssbgv_work: FunctionTypes.LAPACKE_ssbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgv_work: FunctionTypes.LAPACKE_dsbgv_work? = load(name: "LAPACKE_dsbgv_work")
    #elseif os(macOS)
    static let dsbgv_work: FunctionTypes.LAPACKE_dsbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvd_work: FunctionTypes.LAPACKE_ssbgvd_work? = load(name: "LAPACKE_ssbgvd_work")
    #elseif os(macOS)
    static let ssbgvd_work: FunctionTypes.LAPACKE_ssbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvd_work: FunctionTypes.LAPACKE_dsbgvd_work? = load(name: "LAPACKE_dsbgvd_work")
    #elseif os(macOS)
    static let dsbgvd_work: FunctionTypes.LAPACKE_dsbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvx_work: FunctionTypes.LAPACKE_ssbgvx_work? = load(name: "LAPACKE_ssbgvx_work")
    #elseif os(macOS)
    static let ssbgvx_work: FunctionTypes.LAPACKE_ssbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvx_work: FunctionTypes.LAPACKE_dsbgvx_work? = load(name: "LAPACKE_dsbgvx_work")
    #elseif os(macOS)
    static let dsbgvx_work: FunctionTypes.LAPACKE_dsbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbtrd_work: FunctionTypes.LAPACKE_ssbtrd_work? = load(name: "LAPACKE_ssbtrd_work")
    #elseif os(macOS)
    static let ssbtrd_work: FunctionTypes.LAPACKE_ssbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbtrd_work: FunctionTypes.LAPACKE_dsbtrd_work? = load(name: "LAPACKE_dsbtrd_work")
    #elseif os(macOS)
    static let dsbtrd_work: FunctionTypes.LAPACKE_dsbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssfrk_work: FunctionTypes.LAPACKE_ssfrk_work? = load(name: "LAPACKE_ssfrk_work")
    #elseif os(macOS)
    static let ssfrk_work: FunctionTypes.LAPACKE_ssfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsfrk_work: FunctionTypes.LAPACKE_dsfrk_work? = load(name: "LAPACKE_dsfrk_work")
    #elseif os(macOS)
    static let dsfrk_work: FunctionTypes.LAPACKE_dsfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspcon_work: FunctionTypes.LAPACKE_sspcon_work? = load(name: "LAPACKE_sspcon_work")
    #elseif os(macOS)
    static let sspcon_work: FunctionTypes.LAPACKE_sspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspcon_work: FunctionTypes.LAPACKE_dspcon_work? = load(name: "LAPACKE_dspcon_work")
    #elseif os(macOS)
    static let dspcon_work: FunctionTypes.LAPACKE_dspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspcon_work: FunctionTypes.LAPACKE_cspcon_work? = load(name: "LAPACKE_cspcon_work")
    #elseif os(macOS)
    static let cspcon_work: FunctionTypes.LAPACKE_cspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspcon_work: FunctionTypes.LAPACKE_zspcon_work? = load(name: "LAPACKE_zspcon_work")
    #elseif os(macOS)
    static let zspcon_work: FunctionTypes.LAPACKE_zspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspev_work: FunctionTypes.LAPACKE_sspev_work? = load(name: "LAPACKE_sspev_work")
    #elseif os(macOS)
    static let sspev_work: FunctionTypes.LAPACKE_sspev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspev_work: FunctionTypes.LAPACKE_dspev_work? = load(name: "LAPACKE_dspev_work")
    #elseif os(macOS)
    static let dspev_work: FunctionTypes.LAPACKE_dspev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevd_work: FunctionTypes.LAPACKE_sspevd_work? = load(name: "LAPACKE_sspevd_work")
    #elseif os(macOS)
    static let sspevd_work: FunctionTypes.LAPACKE_sspevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevd_work: FunctionTypes.LAPACKE_dspevd_work? = load(name: "LAPACKE_dspevd_work")
    #elseif os(macOS)
    static let dspevd_work: FunctionTypes.LAPACKE_dspevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevx_work: FunctionTypes.LAPACKE_sspevx_work? = load(name: "LAPACKE_sspevx_work")
    #elseif os(macOS)
    static let sspevx_work: FunctionTypes.LAPACKE_sspevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevx_work: FunctionTypes.LAPACKE_dspevx_work? = load(name: "LAPACKE_dspevx_work")
    #elseif os(macOS)
    static let dspevx_work: FunctionTypes.LAPACKE_dspevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgst_work: FunctionTypes.LAPACKE_sspgst_work? = load(name: "LAPACKE_sspgst_work")
    #elseif os(macOS)
    static let sspgst_work: FunctionTypes.LAPACKE_sspgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgst_work: FunctionTypes.LAPACKE_dspgst_work? = load(name: "LAPACKE_dspgst_work")
    #elseif os(macOS)
    static let dspgst_work: FunctionTypes.LAPACKE_dspgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgv_work: FunctionTypes.LAPACKE_sspgv_work? = load(name: "LAPACKE_sspgv_work")
    #elseif os(macOS)
    static let sspgv_work: FunctionTypes.LAPACKE_sspgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgv_work: FunctionTypes.LAPACKE_dspgv_work? = load(name: "LAPACKE_dspgv_work")
    #elseif os(macOS)
    static let dspgv_work: FunctionTypes.LAPACKE_dspgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvd_work: FunctionTypes.LAPACKE_sspgvd_work? = load(name: "LAPACKE_sspgvd_work")
    #elseif os(macOS)
    static let sspgvd_work: FunctionTypes.LAPACKE_sspgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvd_work: FunctionTypes.LAPACKE_dspgvd_work? = load(name: "LAPACKE_dspgvd_work")
    #elseif os(macOS)
    static let dspgvd_work: FunctionTypes.LAPACKE_dspgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvx_work: FunctionTypes.LAPACKE_sspgvx_work? = load(name: "LAPACKE_sspgvx_work")
    #elseif os(macOS)
    static let sspgvx_work: FunctionTypes.LAPACKE_sspgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvx_work: FunctionTypes.LAPACKE_dspgvx_work? = load(name: "LAPACKE_dspgvx_work")
    #elseif os(macOS)
    static let dspgvx_work: FunctionTypes.LAPACKE_dspgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssprfs_work: FunctionTypes.LAPACKE_ssprfs_work? = load(name: "LAPACKE_ssprfs_work")
    #elseif os(macOS)
    static let ssprfs_work: FunctionTypes.LAPACKE_ssprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsprfs_work: FunctionTypes.LAPACKE_dsprfs_work? = load(name: "LAPACKE_dsprfs_work")
    #elseif os(macOS)
    static let dsprfs_work: FunctionTypes.LAPACKE_dsprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csprfs_work: FunctionTypes.LAPACKE_csprfs_work? = load(name: "LAPACKE_csprfs_work")
    #elseif os(macOS)
    static let csprfs_work: FunctionTypes.LAPACKE_csprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsprfs_work: FunctionTypes.LAPACKE_zsprfs_work? = load(name: "LAPACKE_zsprfs_work")
    #elseif os(macOS)
    static let zsprfs_work: FunctionTypes.LAPACKE_zsprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsv_work: FunctionTypes.LAPACKE_sspsv_work? = load(name: "LAPACKE_sspsv_work")
    #elseif os(macOS)
    static let sspsv_work: FunctionTypes.LAPACKE_sspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsv_work: FunctionTypes.LAPACKE_dspsv_work? = load(name: "LAPACKE_dspsv_work")
    #elseif os(macOS)
    static let dspsv_work: FunctionTypes.LAPACKE_dspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsv_work: FunctionTypes.LAPACKE_cspsv_work? = load(name: "LAPACKE_cspsv_work")
    #elseif os(macOS)
    static let cspsv_work: FunctionTypes.LAPACKE_cspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsv_work: FunctionTypes.LAPACKE_zspsv_work? = load(name: "LAPACKE_zspsv_work")
    #elseif os(macOS)
    static let zspsv_work: FunctionTypes.LAPACKE_zspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsvx_work: FunctionTypes.LAPACKE_sspsvx_work? = load(name: "LAPACKE_sspsvx_work")
    #elseif os(macOS)
    static let sspsvx_work: FunctionTypes.LAPACKE_sspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsvx_work: FunctionTypes.LAPACKE_dspsvx_work? = load(name: "LAPACKE_dspsvx_work")
    #elseif os(macOS)
    static let dspsvx_work: FunctionTypes.LAPACKE_dspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsvx_work: FunctionTypes.LAPACKE_cspsvx_work? = load(name: "LAPACKE_cspsvx_work")
    #elseif os(macOS)
    static let cspsvx_work: FunctionTypes.LAPACKE_cspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsvx_work: FunctionTypes.LAPACKE_zspsvx_work? = load(name: "LAPACKE_zspsvx_work")
    #elseif os(macOS)
    static let zspsvx_work: FunctionTypes.LAPACKE_zspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrd_work: FunctionTypes.LAPACKE_ssptrd_work? = load(name: "LAPACKE_ssptrd_work")
    #elseif os(macOS)
    static let ssptrd_work: FunctionTypes.LAPACKE_ssptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrd_work: FunctionTypes.LAPACKE_dsptrd_work? = load(name: "LAPACKE_dsptrd_work")
    #elseif os(macOS)
    static let dsptrd_work: FunctionTypes.LAPACKE_dsptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrf_work: FunctionTypes.LAPACKE_ssptrf_work? = load(name: "LAPACKE_ssptrf_work")
    #elseif os(macOS)
    static let ssptrf_work: FunctionTypes.LAPACKE_ssptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrf_work: FunctionTypes.LAPACKE_dsptrf_work? = load(name: "LAPACKE_dsptrf_work")
    #elseif os(macOS)
    static let dsptrf_work: FunctionTypes.LAPACKE_dsptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrf_work: FunctionTypes.LAPACKE_csptrf_work? = load(name: "LAPACKE_csptrf_work")
    #elseif os(macOS)
    static let csptrf_work: FunctionTypes.LAPACKE_csptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrf_work: FunctionTypes.LAPACKE_zsptrf_work? = load(name: "LAPACKE_zsptrf_work")
    #elseif os(macOS)
    static let zsptrf_work: FunctionTypes.LAPACKE_zsptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptri_work: FunctionTypes.LAPACKE_ssptri_work? = load(name: "LAPACKE_ssptri_work")
    #elseif os(macOS)
    static let ssptri_work: FunctionTypes.LAPACKE_ssptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptri_work: FunctionTypes.LAPACKE_dsptri_work? = load(name: "LAPACKE_dsptri_work")
    #elseif os(macOS)
    static let dsptri_work: FunctionTypes.LAPACKE_dsptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptri_work: FunctionTypes.LAPACKE_csptri_work? = load(name: "LAPACKE_csptri_work")
    #elseif os(macOS)
    static let csptri_work: FunctionTypes.LAPACKE_csptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptri_work: FunctionTypes.LAPACKE_zsptri_work? = load(name: "LAPACKE_zsptri_work")
    #elseif os(macOS)
    static let zsptri_work: FunctionTypes.LAPACKE_zsptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrs_work: FunctionTypes.LAPACKE_ssptrs_work? = load(name: "LAPACKE_ssptrs_work")
    #elseif os(macOS)
    static let ssptrs_work: FunctionTypes.LAPACKE_ssptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrs_work: FunctionTypes.LAPACKE_dsptrs_work? = load(name: "LAPACKE_dsptrs_work")
    #elseif os(macOS)
    static let dsptrs_work: FunctionTypes.LAPACKE_dsptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrs_work: FunctionTypes.LAPACKE_csptrs_work? = load(name: "LAPACKE_csptrs_work")
    #elseif os(macOS)
    static let csptrs_work: FunctionTypes.LAPACKE_csptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrs_work: FunctionTypes.LAPACKE_zsptrs_work? = load(name: "LAPACKE_zsptrs_work")
    #elseif os(macOS)
    static let zsptrs_work: FunctionTypes.LAPACKE_zsptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstebz_work: FunctionTypes.LAPACKE_sstebz_work? = load(name: "LAPACKE_sstebz_work")
    #elseif os(macOS)
    static let sstebz_work: FunctionTypes.LAPACKE_sstebz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstebz_work: FunctionTypes.LAPACKE_dstebz_work? = load(name: "LAPACKE_dstebz_work")
    #elseif os(macOS)
    static let dstebz_work: FunctionTypes.LAPACKE_dstebz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstedc_work: FunctionTypes.LAPACKE_sstedc_work? = load(name: "LAPACKE_sstedc_work")
    #elseif os(macOS)
    static let sstedc_work: FunctionTypes.LAPACKE_sstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstedc_work: FunctionTypes.LAPACKE_dstedc_work? = load(name: "LAPACKE_dstedc_work")
    #elseif os(macOS)
    static let dstedc_work: FunctionTypes.LAPACKE_dstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstedc_work: FunctionTypes.LAPACKE_cstedc_work? = load(name: "LAPACKE_cstedc_work")
    #elseif os(macOS)
    static let cstedc_work: FunctionTypes.LAPACKE_cstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstedc_work: FunctionTypes.LAPACKE_zstedc_work? = load(name: "LAPACKE_zstedc_work")
    #elseif os(macOS)
    static let zstedc_work: FunctionTypes.LAPACKE_zstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstegr_work: FunctionTypes.LAPACKE_sstegr_work? = load(name: "LAPACKE_sstegr_work")
    #elseif os(macOS)
    static let sstegr_work: FunctionTypes.LAPACKE_sstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstegr_work: FunctionTypes.LAPACKE_dstegr_work? = load(name: "LAPACKE_dstegr_work")
    #elseif os(macOS)
    static let dstegr_work: FunctionTypes.LAPACKE_dstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstegr_work: FunctionTypes.LAPACKE_cstegr_work? = load(name: "LAPACKE_cstegr_work")
    #elseif os(macOS)
    static let cstegr_work: FunctionTypes.LAPACKE_cstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstegr_work: FunctionTypes.LAPACKE_zstegr_work? = load(name: "LAPACKE_zstegr_work")
    #elseif os(macOS)
    static let zstegr_work: FunctionTypes.LAPACKE_zstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstein_work: FunctionTypes.LAPACKE_sstein_work? = load(name: "LAPACKE_sstein_work")
    #elseif os(macOS)
    static let sstein_work: FunctionTypes.LAPACKE_sstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstein_work: FunctionTypes.LAPACKE_dstein_work? = load(name: "LAPACKE_dstein_work")
    #elseif os(macOS)
    static let dstein_work: FunctionTypes.LAPACKE_dstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstein_work: FunctionTypes.LAPACKE_cstein_work? = load(name: "LAPACKE_cstein_work")
    #elseif os(macOS)
    static let cstein_work: FunctionTypes.LAPACKE_cstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstein_work: FunctionTypes.LAPACKE_zstein_work? = load(name: "LAPACKE_zstein_work")
    #elseif os(macOS)
    static let zstein_work: FunctionTypes.LAPACKE_zstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstemr_work: FunctionTypes.LAPACKE_sstemr_work? = load(name: "LAPACKE_sstemr_work")
    #elseif os(macOS)
    static let sstemr_work: FunctionTypes.LAPACKE_sstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstemr_work: FunctionTypes.LAPACKE_dstemr_work? = load(name: "LAPACKE_dstemr_work")
    #elseif os(macOS)
    static let dstemr_work: FunctionTypes.LAPACKE_dstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstemr_work: FunctionTypes.LAPACKE_cstemr_work? = load(name: "LAPACKE_cstemr_work")
    #elseif os(macOS)
    static let cstemr_work: FunctionTypes.LAPACKE_cstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstemr_work: FunctionTypes.LAPACKE_zstemr_work? = load(name: "LAPACKE_zstemr_work")
    #elseif os(macOS)
    static let zstemr_work: FunctionTypes.LAPACKE_zstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssteqr_work: FunctionTypes.LAPACKE_ssteqr_work? = load(name: "LAPACKE_ssteqr_work")
    #elseif os(macOS)
    static let ssteqr_work: FunctionTypes.LAPACKE_ssteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsteqr_work: FunctionTypes.LAPACKE_dsteqr_work? = load(name: "LAPACKE_dsteqr_work")
    #elseif os(macOS)
    static let dsteqr_work: FunctionTypes.LAPACKE_dsteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csteqr_work: FunctionTypes.LAPACKE_csteqr_work? = load(name: "LAPACKE_csteqr_work")
    #elseif os(macOS)
    static let csteqr_work: FunctionTypes.LAPACKE_csteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsteqr_work: FunctionTypes.LAPACKE_zsteqr_work? = load(name: "LAPACKE_zsteqr_work")
    #elseif os(macOS)
    static let zsteqr_work: FunctionTypes.LAPACKE_zsteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssterf_work: FunctionTypes.LAPACKE_ssterf_work? = load(name: "LAPACKE_ssterf_work")
    #elseif os(macOS)
    static let ssterf_work: FunctionTypes.LAPACKE_ssterf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsterf_work: FunctionTypes.LAPACKE_dsterf_work? = load(name: "LAPACKE_dsterf_work")
    #elseif os(macOS)
    static let dsterf_work: FunctionTypes.LAPACKE_dsterf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstev_work: FunctionTypes.LAPACKE_sstev_work? = load(name: "LAPACKE_sstev_work")
    #elseif os(macOS)
    static let sstev_work: FunctionTypes.LAPACKE_sstev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstev_work: FunctionTypes.LAPACKE_dstev_work? = load(name: "LAPACKE_dstev_work")
    #elseif os(macOS)
    static let dstev_work: FunctionTypes.LAPACKE_dstev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevd_work: FunctionTypes.LAPACKE_sstevd_work? = load(name: "LAPACKE_sstevd_work")
    #elseif os(macOS)
    static let sstevd_work: FunctionTypes.LAPACKE_sstevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevd_work: FunctionTypes.LAPACKE_dstevd_work? = load(name: "LAPACKE_dstevd_work")
    #elseif os(macOS)
    static let dstevd_work: FunctionTypes.LAPACKE_dstevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevr_work: FunctionTypes.LAPACKE_sstevr_work? = load(name: "LAPACKE_sstevr_work")
    #elseif os(macOS)
    static let sstevr_work: FunctionTypes.LAPACKE_sstevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevr_work: FunctionTypes.LAPACKE_dstevr_work? = load(name: "LAPACKE_dstevr_work")
    #elseif os(macOS)
    static let dstevr_work: FunctionTypes.LAPACKE_dstevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevx_work: FunctionTypes.LAPACKE_sstevx_work? = load(name: "LAPACKE_sstevx_work")
    #elseif os(macOS)
    static let sstevx_work: FunctionTypes.LAPACKE_sstevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevx_work: FunctionTypes.LAPACKE_dstevx_work? = load(name: "LAPACKE_dstevx_work")
    #elseif os(macOS)
    static let dstevx_work: FunctionTypes.LAPACKE_dstevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon_work: FunctionTypes.LAPACKE_ssycon_work? = load(name: "LAPACKE_ssycon_work")
    #elseif os(macOS)
    static let ssycon_work: FunctionTypes.LAPACKE_ssycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon_work: FunctionTypes.LAPACKE_dsycon_work? = load(name: "LAPACKE_dsycon_work")
    #elseif os(macOS)
    static let dsycon_work: FunctionTypes.LAPACKE_dsycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon_work: FunctionTypes.LAPACKE_csycon_work? = load(name: "LAPACKE_csycon_work")
    #elseif os(macOS)
    static let csycon_work: FunctionTypes.LAPACKE_csycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon_work: FunctionTypes.LAPACKE_zsycon_work? = load(name: "LAPACKE_zsycon_work")
    #elseif os(macOS)
    static let zsycon_work: FunctionTypes.LAPACKE_zsycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyequb_work: FunctionTypes.LAPACKE_ssyequb_work? = load(name: "LAPACKE_ssyequb_work")
    #elseif os(macOS)
    static let ssyequb_work: FunctionTypes.LAPACKE_ssyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyequb_work: FunctionTypes.LAPACKE_dsyequb_work? = load(name: "LAPACKE_dsyequb_work")
    #elseif os(macOS)
    static let dsyequb_work: FunctionTypes.LAPACKE_dsyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyequb_work: FunctionTypes.LAPACKE_csyequb_work? = load(name: "LAPACKE_csyequb_work")
    #elseif os(macOS)
    static let csyequb_work: FunctionTypes.LAPACKE_csyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyequb_work: FunctionTypes.LAPACKE_zsyequb_work? = load(name: "LAPACKE_zsyequb_work")
    #elseif os(macOS)
    static let zsyequb_work: FunctionTypes.LAPACKE_zsyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev_work: FunctionTypes.LAPACKE_ssyev_work? = load(name: "LAPACKE_ssyev_work")
    #elseif os(macOS)
    static let ssyev_work: FunctionTypes.LAPACKE_ssyev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev_work: FunctionTypes.LAPACKE_dsyev_work? = load(name: "LAPACKE_dsyev_work")
    #elseif os(macOS)
    static let dsyev_work: FunctionTypes.LAPACKE_dsyev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd_work: FunctionTypes.LAPACKE_ssyevd_work? = load(name: "LAPACKE_ssyevd_work")
    #elseif os(macOS)
    static let ssyevd_work: FunctionTypes.LAPACKE_ssyevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd_work: FunctionTypes.LAPACKE_dsyevd_work? = load(name: "LAPACKE_dsyevd_work")
    #elseif os(macOS)
    static let dsyevd_work: FunctionTypes.LAPACKE_dsyevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr_work: FunctionTypes.LAPACKE_ssyevr_work? = load(name: "LAPACKE_ssyevr_work")
    #elseif os(macOS)
    static let ssyevr_work: FunctionTypes.LAPACKE_ssyevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr_work: FunctionTypes.LAPACKE_dsyevr_work? = load(name: "LAPACKE_dsyevr_work")
    #elseif os(macOS)
    static let dsyevr_work: FunctionTypes.LAPACKE_dsyevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx_work: FunctionTypes.LAPACKE_ssyevx_work? = load(name: "LAPACKE_ssyevx_work")
    #elseif os(macOS)
    static let ssyevx_work: FunctionTypes.LAPACKE_ssyevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx_work: FunctionTypes.LAPACKE_dsyevx_work? = load(name: "LAPACKE_dsyevx_work")
    #elseif os(macOS)
    static let dsyevx_work: FunctionTypes.LAPACKE_dsyevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygst_work: FunctionTypes.LAPACKE_ssygst_work? = load(name: "LAPACKE_ssygst_work")
    #elseif os(macOS)
    static let ssygst_work: FunctionTypes.LAPACKE_ssygst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygst_work: FunctionTypes.LAPACKE_dsygst_work? = load(name: "LAPACKE_dsygst_work")
    #elseif os(macOS)
    static let dsygst_work: FunctionTypes.LAPACKE_dsygst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv_work: FunctionTypes.LAPACKE_ssygv_work? = load(name: "LAPACKE_ssygv_work")
    #elseif os(macOS)
    static let ssygv_work: FunctionTypes.LAPACKE_ssygv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv_work: FunctionTypes.LAPACKE_dsygv_work? = load(name: "LAPACKE_dsygv_work")
    #elseif os(macOS)
    static let dsygv_work: FunctionTypes.LAPACKE_dsygv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvd_work: FunctionTypes.LAPACKE_ssygvd_work? = load(name: "LAPACKE_ssygvd_work")
    #elseif os(macOS)
    static let ssygvd_work: FunctionTypes.LAPACKE_ssygvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvd_work: FunctionTypes.LAPACKE_dsygvd_work? = load(name: "LAPACKE_dsygvd_work")
    #elseif os(macOS)
    static let dsygvd_work: FunctionTypes.LAPACKE_dsygvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvx_work: FunctionTypes.LAPACKE_ssygvx_work? = load(name: "LAPACKE_ssygvx_work")
    #elseif os(macOS)
    static let ssygvx_work: FunctionTypes.LAPACKE_ssygvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvx_work: FunctionTypes.LAPACKE_dsygvx_work? = load(name: "LAPACKE_dsygvx_work")
    #elseif os(macOS)
    static let dsygvx_work: FunctionTypes.LAPACKE_dsygvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfs_work: FunctionTypes.LAPACKE_ssyrfs_work? = load(name: "LAPACKE_ssyrfs_work")
    #elseif os(macOS)
    static let ssyrfs_work: FunctionTypes.LAPACKE_ssyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfs_work: FunctionTypes.LAPACKE_dsyrfs_work? = load(name: "LAPACKE_dsyrfs_work")
    #elseif os(macOS)
    static let dsyrfs_work: FunctionTypes.LAPACKE_dsyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfs_work: FunctionTypes.LAPACKE_csyrfs_work? = load(name: "LAPACKE_csyrfs_work")
    #elseif os(macOS)
    static let csyrfs_work: FunctionTypes.LAPACKE_csyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfs_work: FunctionTypes.LAPACKE_zsyrfs_work? = load(name: "LAPACKE_zsyrfs_work")
    #elseif os(macOS)
    static let zsyrfs_work: FunctionTypes.LAPACKE_zsyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfsx_work: FunctionTypes.LAPACKE_ssyrfsx_work? = load(name: "LAPACKE_ssyrfsx_work")
    #elseif os(macOS)
    static let ssyrfsx_work: FunctionTypes.LAPACKE_ssyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfsx_work: FunctionTypes.LAPACKE_dsyrfsx_work? = load(name: "LAPACKE_dsyrfsx_work")
    #elseif os(macOS)
    static let dsyrfsx_work: FunctionTypes.LAPACKE_dsyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfsx_work: FunctionTypes.LAPACKE_csyrfsx_work? = load(name: "LAPACKE_csyrfsx_work")
    #elseif os(macOS)
    static let csyrfsx_work: FunctionTypes.LAPACKE_csyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfsx_work: FunctionTypes.LAPACKE_zsyrfsx_work? = load(name: "LAPACKE_zsyrfsx_work")
    #elseif os(macOS)
    static let zsyrfsx_work: FunctionTypes.LAPACKE_zsyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_work: FunctionTypes.LAPACKE_ssysv_work? = load(name: "LAPACKE_ssysv_work")
    #elseif os(macOS)
    static let ssysv_work: FunctionTypes.LAPACKE_ssysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_work: FunctionTypes.LAPACKE_dsysv_work? = load(name: "LAPACKE_dsysv_work")
    #elseif os(macOS)
    static let dsysv_work: FunctionTypes.LAPACKE_dsysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_work: FunctionTypes.LAPACKE_csysv_work? = load(name: "LAPACKE_csysv_work")
    #elseif os(macOS)
    static let csysv_work: FunctionTypes.LAPACKE_csysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_work: FunctionTypes.LAPACKE_zsysv_work? = load(name: "LAPACKE_zsysv_work")
    #elseif os(macOS)
    static let zsysv_work: FunctionTypes.LAPACKE_zsysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvx_work: FunctionTypes.LAPACKE_ssysvx_work? = load(name: "LAPACKE_ssysvx_work")
    #elseif os(macOS)
    static let ssysvx_work: FunctionTypes.LAPACKE_ssysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvx_work: FunctionTypes.LAPACKE_dsysvx_work? = load(name: "LAPACKE_dsysvx_work")
    #elseif os(macOS)
    static let dsysvx_work: FunctionTypes.LAPACKE_dsysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvx_work: FunctionTypes.LAPACKE_csysvx_work? = load(name: "LAPACKE_csysvx_work")
    #elseif os(macOS)
    static let csysvx_work: FunctionTypes.LAPACKE_csysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvx_work: FunctionTypes.LAPACKE_zsysvx_work? = load(name: "LAPACKE_zsysvx_work")
    #elseif os(macOS)
    static let zsysvx_work: FunctionTypes.LAPACKE_zsysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvxx_work: FunctionTypes.LAPACKE_ssysvxx_work? = load(name: "LAPACKE_ssysvxx_work")
    #elseif os(macOS)
    static let ssysvxx_work: FunctionTypes.LAPACKE_ssysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvxx_work: FunctionTypes.LAPACKE_dsysvxx_work? = load(name: "LAPACKE_dsysvxx_work")
    #elseif os(macOS)
    static let dsysvxx_work: FunctionTypes.LAPACKE_dsysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvxx_work: FunctionTypes.LAPACKE_csysvxx_work? = load(name: "LAPACKE_csysvxx_work")
    #elseif os(macOS)
    static let csysvxx_work: FunctionTypes.LAPACKE_csysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvxx_work: FunctionTypes.LAPACKE_zsysvxx_work? = load(name: "LAPACKE_zsysvxx_work")
    #elseif os(macOS)
    static let zsysvxx_work: FunctionTypes.LAPACKE_zsysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrd_work: FunctionTypes.LAPACKE_ssytrd_work? = load(name: "LAPACKE_ssytrd_work")
    #elseif os(macOS)
    static let ssytrd_work: FunctionTypes.LAPACKE_ssytrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrd_work: FunctionTypes.LAPACKE_dsytrd_work? = load(name: "LAPACKE_dsytrd_work")
    #elseif os(macOS)
    static let dsytrd_work: FunctionTypes.LAPACKE_dsytrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_work: FunctionTypes.LAPACKE_ssytrf_work? = load(name: "LAPACKE_ssytrf_work")
    #elseif os(macOS)
    static let ssytrf_work: FunctionTypes.LAPACKE_ssytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_work: FunctionTypes.LAPACKE_dsytrf_work? = load(name: "LAPACKE_dsytrf_work")
    #elseif os(macOS)
    static let dsytrf_work: FunctionTypes.LAPACKE_dsytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_work: FunctionTypes.LAPACKE_csytrf_work? = load(name: "LAPACKE_csytrf_work")
    #elseif os(macOS)
    static let csytrf_work: FunctionTypes.LAPACKE_csytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_work: FunctionTypes.LAPACKE_zsytrf_work? = load(name: "LAPACKE_zsytrf_work")
    #elseif os(macOS)
    static let zsytrf_work: FunctionTypes.LAPACKE_zsytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri_work: FunctionTypes.LAPACKE_ssytri_work? = load(name: "LAPACKE_ssytri_work")
    #elseif os(macOS)
    static let ssytri_work: FunctionTypes.LAPACKE_ssytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri_work: FunctionTypes.LAPACKE_dsytri_work? = load(name: "LAPACKE_dsytri_work")
    #elseif os(macOS)
    static let dsytri_work: FunctionTypes.LAPACKE_dsytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri_work: FunctionTypes.LAPACKE_csytri_work? = load(name: "LAPACKE_csytri_work")
    #elseif os(macOS)
    static let csytri_work: FunctionTypes.LAPACKE_csytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri_work: FunctionTypes.LAPACKE_zsytri_work? = load(name: "LAPACKE_zsytri_work")
    #elseif os(macOS)
    static let zsytri_work: FunctionTypes.LAPACKE_zsytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_work: FunctionTypes.LAPACKE_ssytrs_work? = load(name: "LAPACKE_ssytrs_work")
    #elseif os(macOS)
    static let ssytrs_work: FunctionTypes.LAPACKE_ssytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_work: FunctionTypes.LAPACKE_dsytrs_work? = load(name: "LAPACKE_dsytrs_work")
    #elseif os(macOS)
    static let dsytrs_work: FunctionTypes.LAPACKE_dsytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_work: FunctionTypes.LAPACKE_csytrs_work? = load(name: "LAPACKE_csytrs_work")
    #elseif os(macOS)
    static let csytrs_work: FunctionTypes.LAPACKE_csytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_work: FunctionTypes.LAPACKE_zsytrs_work? = load(name: "LAPACKE_zsytrs_work")
    #elseif os(macOS)
    static let zsytrs_work: FunctionTypes.LAPACKE_zsytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbcon_work: FunctionTypes.LAPACKE_stbcon_work? = load(name: "LAPACKE_stbcon_work")
    #elseif os(macOS)
    static let stbcon_work: FunctionTypes.LAPACKE_stbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbcon_work: FunctionTypes.LAPACKE_dtbcon_work? = load(name: "LAPACKE_dtbcon_work")
    #elseif os(macOS)
    static let dtbcon_work: FunctionTypes.LAPACKE_dtbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbcon_work: FunctionTypes.LAPACKE_ctbcon_work? = load(name: "LAPACKE_ctbcon_work")
    #elseif os(macOS)
    static let ctbcon_work: FunctionTypes.LAPACKE_ctbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbcon_work: FunctionTypes.LAPACKE_ztbcon_work? = load(name: "LAPACKE_ztbcon_work")
    #elseif os(macOS)
    static let ztbcon_work: FunctionTypes.LAPACKE_ztbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbrfs_work: FunctionTypes.LAPACKE_stbrfs_work? = load(name: "LAPACKE_stbrfs_work")
    #elseif os(macOS)
    static let stbrfs_work: FunctionTypes.LAPACKE_stbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbrfs_work: FunctionTypes.LAPACKE_dtbrfs_work? = load(name: "LAPACKE_dtbrfs_work")
    #elseif os(macOS)
    static let dtbrfs_work: FunctionTypes.LAPACKE_dtbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbrfs_work: FunctionTypes.LAPACKE_ctbrfs_work? = load(name: "LAPACKE_ctbrfs_work")
    #elseif os(macOS)
    static let ctbrfs_work: FunctionTypes.LAPACKE_ctbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbrfs_work: FunctionTypes.LAPACKE_ztbrfs_work? = load(name: "LAPACKE_ztbrfs_work")
    #elseif os(macOS)
    static let ztbrfs_work: FunctionTypes.LAPACKE_ztbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbtrs_work: FunctionTypes.LAPACKE_stbtrs_work? = load(name: "LAPACKE_stbtrs_work")
    #elseif os(macOS)
    static let stbtrs_work: FunctionTypes.LAPACKE_stbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbtrs_work: FunctionTypes.LAPACKE_dtbtrs_work? = load(name: "LAPACKE_dtbtrs_work")
    #elseif os(macOS)
    static let dtbtrs_work: FunctionTypes.LAPACKE_dtbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbtrs_work: FunctionTypes.LAPACKE_ctbtrs_work? = load(name: "LAPACKE_ctbtrs_work")
    #elseif os(macOS)
    static let ctbtrs_work: FunctionTypes.LAPACKE_ctbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbtrs_work: FunctionTypes.LAPACKE_ztbtrs_work? = load(name: "LAPACKE_ztbtrs_work")
    #elseif os(macOS)
    static let ztbtrs_work: FunctionTypes.LAPACKE_ztbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfsm_work: FunctionTypes.LAPACKE_stfsm_work? = load(name: "LAPACKE_stfsm_work")
    #elseif os(macOS)
    static let stfsm_work: FunctionTypes.LAPACKE_stfsm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfsm_work: FunctionTypes.LAPACKE_dtfsm_work? = load(name: "LAPACKE_dtfsm_work")
    #elseif os(macOS)
    static let dtfsm_work: FunctionTypes.LAPACKE_dtfsm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stftri_work: FunctionTypes.LAPACKE_stftri_work? = load(name: "LAPACKE_stftri_work")
    #elseif os(macOS)
    static let stftri_work: FunctionTypes.LAPACKE_stftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtftri_work: FunctionTypes.LAPACKE_dtftri_work? = load(name: "LAPACKE_dtftri_work")
    #elseif os(macOS)
    static let dtftri_work: FunctionTypes.LAPACKE_dtftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctftri_work: FunctionTypes.LAPACKE_ctftri_work? = load(name: "LAPACKE_ctftri_work")
    #elseif os(macOS)
    static let ctftri_work: FunctionTypes.LAPACKE_ctftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztftri_work: FunctionTypes.LAPACKE_ztftri_work? = load(name: "LAPACKE_ztftri_work")
    #elseif os(macOS)
    static let ztftri_work: FunctionTypes.LAPACKE_ztftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttp_work: FunctionTypes.LAPACKE_stfttp_work? = load(name: "LAPACKE_stfttp_work")
    #elseif os(macOS)
    static let stfttp_work: FunctionTypes.LAPACKE_stfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttp_work: FunctionTypes.LAPACKE_dtfttp_work? = load(name: "LAPACKE_dtfttp_work")
    #elseif os(macOS)
    static let dtfttp_work: FunctionTypes.LAPACKE_dtfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttp_work: FunctionTypes.LAPACKE_ctfttp_work? = load(name: "LAPACKE_ctfttp_work")
    #elseif os(macOS)
    static let ctfttp_work: FunctionTypes.LAPACKE_ctfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttp_work: FunctionTypes.LAPACKE_ztfttp_work? = load(name: "LAPACKE_ztfttp_work")
    #elseif os(macOS)
    static let ztfttp_work: FunctionTypes.LAPACKE_ztfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttr_work: FunctionTypes.LAPACKE_stfttr_work? = load(name: "LAPACKE_stfttr_work")
    #elseif os(macOS)
    static let stfttr_work: FunctionTypes.LAPACKE_stfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttr_work: FunctionTypes.LAPACKE_dtfttr_work? = load(name: "LAPACKE_dtfttr_work")
    #elseif os(macOS)
    static let dtfttr_work: FunctionTypes.LAPACKE_dtfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttr_work: FunctionTypes.LAPACKE_ctfttr_work? = load(name: "LAPACKE_ctfttr_work")
    #elseif os(macOS)
    static let ctfttr_work: FunctionTypes.LAPACKE_ctfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttr_work: FunctionTypes.LAPACKE_ztfttr_work? = load(name: "LAPACKE_ztfttr_work")
    #elseif os(macOS)
    static let ztfttr_work: FunctionTypes.LAPACKE_ztfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgevc_work: FunctionTypes.LAPACKE_stgevc_work? = load(name: "LAPACKE_stgevc_work")
    #elseif os(macOS)
    static let stgevc_work: FunctionTypes.LAPACKE_stgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgevc_work: FunctionTypes.LAPACKE_dtgevc_work? = load(name: "LAPACKE_dtgevc_work")
    #elseif os(macOS)
    static let dtgevc_work: FunctionTypes.LAPACKE_dtgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgevc_work: FunctionTypes.LAPACKE_ctgevc_work? = load(name: "LAPACKE_ctgevc_work")
    #elseif os(macOS)
    static let ctgevc_work: FunctionTypes.LAPACKE_ctgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgevc_work: FunctionTypes.LAPACKE_ztgevc_work? = load(name: "LAPACKE_ztgevc_work")
    #elseif os(macOS)
    static let ztgevc_work: FunctionTypes.LAPACKE_ztgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgexc_work: FunctionTypes.LAPACKE_stgexc_work? = load(name: "LAPACKE_stgexc_work")
    #elseif os(macOS)
    static let stgexc_work: FunctionTypes.LAPACKE_stgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgexc_work: FunctionTypes.LAPACKE_dtgexc_work? = load(name: "LAPACKE_dtgexc_work")
    #elseif os(macOS)
    static let dtgexc_work: FunctionTypes.LAPACKE_dtgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgexc_work: FunctionTypes.LAPACKE_ctgexc_work? = load(name: "LAPACKE_ctgexc_work")
    #elseif os(macOS)
    static let ctgexc_work: FunctionTypes.LAPACKE_ctgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgexc_work: FunctionTypes.LAPACKE_ztgexc_work? = load(name: "LAPACKE_ztgexc_work")
    #elseif os(macOS)
    static let ztgexc_work: FunctionTypes.LAPACKE_ztgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsen_work: FunctionTypes.LAPACKE_stgsen_work? = load(name: "LAPACKE_stgsen_work")
    #elseif os(macOS)
    static let stgsen_work: FunctionTypes.LAPACKE_stgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsen_work: FunctionTypes.LAPACKE_dtgsen_work? = load(name: "LAPACKE_dtgsen_work")
    #elseif os(macOS)
    static let dtgsen_work: FunctionTypes.LAPACKE_dtgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsen_work: FunctionTypes.LAPACKE_ctgsen_work? = load(name: "LAPACKE_ctgsen_work")
    #elseif os(macOS)
    static let ctgsen_work: FunctionTypes.LAPACKE_ctgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsen_work: FunctionTypes.LAPACKE_ztgsen_work? = load(name: "LAPACKE_ztgsen_work")
    #elseif os(macOS)
    static let ztgsen_work: FunctionTypes.LAPACKE_ztgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsja_work: FunctionTypes.LAPACKE_stgsja_work? = load(name: "LAPACKE_stgsja_work")
    #elseif os(macOS)
    static let stgsja_work: FunctionTypes.LAPACKE_stgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsja_work: FunctionTypes.LAPACKE_dtgsja_work? = load(name: "LAPACKE_dtgsja_work")
    #elseif os(macOS)
    static let dtgsja_work: FunctionTypes.LAPACKE_dtgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsja_work: FunctionTypes.LAPACKE_ctgsja_work? = load(name: "LAPACKE_ctgsja_work")
    #elseif os(macOS)
    static let ctgsja_work: FunctionTypes.LAPACKE_ctgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsja_work: FunctionTypes.LAPACKE_ztgsja_work? = load(name: "LAPACKE_ztgsja_work")
    #elseif os(macOS)
    static let ztgsja_work: FunctionTypes.LAPACKE_ztgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsna_work: FunctionTypes.LAPACKE_stgsna_work? = load(name: "LAPACKE_stgsna_work")
    #elseif os(macOS)
    static let stgsna_work: FunctionTypes.LAPACKE_stgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsna_work: FunctionTypes.LAPACKE_dtgsna_work? = load(name: "LAPACKE_dtgsna_work")
    #elseif os(macOS)
    static let dtgsna_work: FunctionTypes.LAPACKE_dtgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsna_work: FunctionTypes.LAPACKE_ctgsna_work? = load(name: "LAPACKE_ctgsna_work")
    #elseif os(macOS)
    static let ctgsna_work: FunctionTypes.LAPACKE_ctgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsna_work: FunctionTypes.LAPACKE_ztgsna_work? = load(name: "LAPACKE_ztgsna_work")
    #elseif os(macOS)
    static let ztgsna_work: FunctionTypes.LAPACKE_ztgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsyl_work: FunctionTypes.LAPACKE_stgsyl_work? = load(name: "LAPACKE_stgsyl_work")
    #elseif os(macOS)
    static let stgsyl_work: FunctionTypes.LAPACKE_stgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsyl_work: FunctionTypes.LAPACKE_dtgsyl_work? = load(name: "LAPACKE_dtgsyl_work")
    #elseif os(macOS)
    static let dtgsyl_work: FunctionTypes.LAPACKE_dtgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsyl_work: FunctionTypes.LAPACKE_ctgsyl_work? = load(name: "LAPACKE_ctgsyl_work")
    #elseif os(macOS)
    static let ctgsyl_work: FunctionTypes.LAPACKE_ctgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsyl_work: FunctionTypes.LAPACKE_ztgsyl_work? = load(name: "LAPACKE_ztgsyl_work")
    #elseif os(macOS)
    static let ztgsyl_work: FunctionTypes.LAPACKE_ztgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpcon_work: FunctionTypes.LAPACKE_stpcon_work? = load(name: "LAPACKE_stpcon_work")
    #elseif os(macOS)
    static let stpcon_work: FunctionTypes.LAPACKE_stpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpcon_work: FunctionTypes.LAPACKE_dtpcon_work? = load(name: "LAPACKE_dtpcon_work")
    #elseif os(macOS)
    static let dtpcon_work: FunctionTypes.LAPACKE_dtpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpcon_work: FunctionTypes.LAPACKE_ctpcon_work? = load(name: "LAPACKE_ctpcon_work")
    #elseif os(macOS)
    static let ctpcon_work: FunctionTypes.LAPACKE_ctpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpcon_work: FunctionTypes.LAPACKE_ztpcon_work? = load(name: "LAPACKE_ztpcon_work")
    #elseif os(macOS)
    static let ztpcon_work: FunctionTypes.LAPACKE_ztpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfs_work: FunctionTypes.LAPACKE_stprfs_work? = load(name: "LAPACKE_stprfs_work")
    #elseif os(macOS)
    static let stprfs_work: FunctionTypes.LAPACKE_stprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfs_work: FunctionTypes.LAPACKE_dtprfs_work? = load(name: "LAPACKE_dtprfs_work")
    #elseif os(macOS)
    static let dtprfs_work: FunctionTypes.LAPACKE_dtprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfs_work: FunctionTypes.LAPACKE_ctprfs_work? = load(name: "LAPACKE_ctprfs_work")
    #elseif os(macOS)
    static let ctprfs_work: FunctionTypes.LAPACKE_ctprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfs_work: FunctionTypes.LAPACKE_ztprfs_work? = load(name: "LAPACKE_ztprfs_work")
    #elseif os(macOS)
    static let ztprfs_work: FunctionTypes.LAPACKE_ztprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptri_work: FunctionTypes.LAPACKE_stptri_work? = load(name: "LAPACKE_stptri_work")
    #elseif os(macOS)
    static let stptri_work: FunctionTypes.LAPACKE_stptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptri_work: FunctionTypes.LAPACKE_dtptri_work? = load(name: "LAPACKE_dtptri_work")
    #elseif os(macOS)
    static let dtptri_work: FunctionTypes.LAPACKE_dtptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptri_work: FunctionTypes.LAPACKE_ctptri_work? = load(name: "LAPACKE_ctptri_work")
    #elseif os(macOS)
    static let ctptri_work: FunctionTypes.LAPACKE_ctptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptri_work: FunctionTypes.LAPACKE_ztptri_work? = load(name: "LAPACKE_ztptri_work")
    #elseif os(macOS)
    static let ztptri_work: FunctionTypes.LAPACKE_ztptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptrs_work: FunctionTypes.LAPACKE_stptrs_work? = load(name: "LAPACKE_stptrs_work")
    #elseif os(macOS)
    static let stptrs_work: FunctionTypes.LAPACKE_stptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptrs_work: FunctionTypes.LAPACKE_dtptrs_work? = load(name: "LAPACKE_dtptrs_work")
    #elseif os(macOS)
    static let dtptrs_work: FunctionTypes.LAPACKE_dtptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptrs_work: FunctionTypes.LAPACKE_ctptrs_work? = load(name: "LAPACKE_ctptrs_work")
    #elseif os(macOS)
    static let ctptrs_work: FunctionTypes.LAPACKE_ctptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptrs_work: FunctionTypes.LAPACKE_ztptrs_work? = load(name: "LAPACKE_ztptrs_work")
    #elseif os(macOS)
    static let ztptrs_work: FunctionTypes.LAPACKE_ztptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttf_work: FunctionTypes.LAPACKE_stpttf_work? = load(name: "LAPACKE_stpttf_work")
    #elseif os(macOS)
    static let stpttf_work: FunctionTypes.LAPACKE_stpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttf_work: FunctionTypes.LAPACKE_dtpttf_work? = load(name: "LAPACKE_dtpttf_work")
    #elseif os(macOS)
    static let dtpttf_work: FunctionTypes.LAPACKE_dtpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttf_work: FunctionTypes.LAPACKE_ctpttf_work? = load(name: "LAPACKE_ctpttf_work")
    #elseif os(macOS)
    static let ctpttf_work: FunctionTypes.LAPACKE_ctpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttf_work: FunctionTypes.LAPACKE_ztpttf_work? = load(name: "LAPACKE_ztpttf_work")
    #elseif os(macOS)
    static let ztpttf_work: FunctionTypes.LAPACKE_ztpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttr_work: FunctionTypes.LAPACKE_stpttr_work? = load(name: "LAPACKE_stpttr_work")
    #elseif os(macOS)
    static let stpttr_work: FunctionTypes.LAPACKE_stpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttr_work: FunctionTypes.LAPACKE_dtpttr_work? = load(name: "LAPACKE_dtpttr_work")
    #elseif os(macOS)
    static let dtpttr_work: FunctionTypes.LAPACKE_dtpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttr_work: FunctionTypes.LAPACKE_ctpttr_work? = load(name: "LAPACKE_ctpttr_work")
    #elseif os(macOS)
    static let ctpttr_work: FunctionTypes.LAPACKE_ctpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttr_work: FunctionTypes.LAPACKE_ztpttr_work? = load(name: "LAPACKE_ztpttr_work")
    #elseif os(macOS)
    static let ztpttr_work: FunctionTypes.LAPACKE_ztpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strcon_work: FunctionTypes.LAPACKE_strcon_work? = load(name: "LAPACKE_strcon_work")
    #elseif os(macOS)
    static let strcon_work: FunctionTypes.LAPACKE_strcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrcon_work: FunctionTypes.LAPACKE_dtrcon_work? = load(name: "LAPACKE_dtrcon_work")
    #elseif os(macOS)
    static let dtrcon_work: FunctionTypes.LAPACKE_dtrcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrcon_work: FunctionTypes.LAPACKE_ctrcon_work? = load(name: "LAPACKE_ctrcon_work")
    #elseif os(macOS)
    static let ctrcon_work: FunctionTypes.LAPACKE_ctrcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrcon_work: FunctionTypes.LAPACKE_ztrcon_work? = load(name: "LAPACKE_ztrcon_work")
    #elseif os(macOS)
    static let ztrcon_work: FunctionTypes.LAPACKE_ztrcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strevc_work: FunctionTypes.LAPACKE_strevc_work? = load(name: "LAPACKE_strevc_work")
    #elseif os(macOS)
    static let strevc_work: FunctionTypes.LAPACKE_strevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrevc_work: FunctionTypes.LAPACKE_dtrevc_work? = load(name: "LAPACKE_dtrevc_work")
    #elseif os(macOS)
    static let dtrevc_work: FunctionTypes.LAPACKE_dtrevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrevc_work: FunctionTypes.LAPACKE_ctrevc_work? = load(name: "LAPACKE_ctrevc_work")
    #elseif os(macOS)
    static let ctrevc_work: FunctionTypes.LAPACKE_ctrevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrevc_work: FunctionTypes.LAPACKE_ztrevc_work? = load(name: "LAPACKE_ztrevc_work")
    #elseif os(macOS)
    static let ztrevc_work: FunctionTypes.LAPACKE_ztrevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strexc_work: FunctionTypes.LAPACKE_strexc_work? = load(name: "LAPACKE_strexc_work")
    #elseif os(macOS)
    static let strexc_work: FunctionTypes.LAPACKE_strexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrexc_work: FunctionTypes.LAPACKE_dtrexc_work? = load(name: "LAPACKE_dtrexc_work")
    #elseif os(macOS)
    static let dtrexc_work: FunctionTypes.LAPACKE_dtrexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrexc_work: FunctionTypes.LAPACKE_ctrexc_work? = load(name: "LAPACKE_ctrexc_work")
    #elseif os(macOS)
    static let ctrexc_work: FunctionTypes.LAPACKE_ctrexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrexc_work: FunctionTypes.LAPACKE_ztrexc_work? = load(name: "LAPACKE_ztrexc_work")
    #elseif os(macOS)
    static let ztrexc_work: FunctionTypes.LAPACKE_ztrexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strrfs_work: FunctionTypes.LAPACKE_strrfs_work? = load(name: "LAPACKE_strrfs_work")
    #elseif os(macOS)
    static let strrfs_work: FunctionTypes.LAPACKE_strrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrrfs_work: FunctionTypes.LAPACKE_dtrrfs_work? = load(name: "LAPACKE_dtrrfs_work")
    #elseif os(macOS)
    static let dtrrfs_work: FunctionTypes.LAPACKE_dtrrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrrfs_work: FunctionTypes.LAPACKE_ctrrfs_work? = load(name: "LAPACKE_ctrrfs_work")
    #elseif os(macOS)
    static let ctrrfs_work: FunctionTypes.LAPACKE_ctrrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrrfs_work: FunctionTypes.LAPACKE_ztrrfs_work? = load(name: "LAPACKE_ztrrfs_work")
    #elseif os(macOS)
    static let ztrrfs_work: FunctionTypes.LAPACKE_ztrrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsen_work: FunctionTypes.LAPACKE_strsen_work? = load(name: "LAPACKE_strsen_work")
    #elseif os(macOS)
    static let strsen_work: FunctionTypes.LAPACKE_strsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsen_work: FunctionTypes.LAPACKE_dtrsen_work? = load(name: "LAPACKE_dtrsen_work")
    #elseif os(macOS)
    static let dtrsen_work: FunctionTypes.LAPACKE_dtrsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsen_work: FunctionTypes.LAPACKE_ctrsen_work? = load(name: "LAPACKE_ctrsen_work")
    #elseif os(macOS)
    static let ctrsen_work: FunctionTypes.LAPACKE_ctrsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsen_work: FunctionTypes.LAPACKE_ztrsen_work? = load(name: "LAPACKE_ztrsen_work")
    #elseif os(macOS)
    static let ztrsen_work: FunctionTypes.LAPACKE_ztrsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsna_work: FunctionTypes.LAPACKE_strsna_work? = load(name: "LAPACKE_strsna_work")
    #elseif os(macOS)
    static let strsna_work: FunctionTypes.LAPACKE_strsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsna_work: FunctionTypes.LAPACKE_dtrsna_work? = load(name: "LAPACKE_dtrsna_work")
    #elseif os(macOS)
    static let dtrsna_work: FunctionTypes.LAPACKE_dtrsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsna_work: FunctionTypes.LAPACKE_ctrsna_work? = load(name: "LAPACKE_ctrsna_work")
    #elseif os(macOS)
    static let ctrsna_work: FunctionTypes.LAPACKE_ctrsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsna_work: FunctionTypes.LAPACKE_ztrsna_work? = load(name: "LAPACKE_ztrsna_work")
    #elseif os(macOS)
    static let ztrsna_work: FunctionTypes.LAPACKE_ztrsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl_work: FunctionTypes.LAPACKE_strsyl_work? = load(name: "LAPACKE_strsyl_work")
    #elseif os(macOS)
    static let strsyl_work: FunctionTypes.LAPACKE_strsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl_work: FunctionTypes.LAPACKE_dtrsyl_work? = load(name: "LAPACKE_dtrsyl_work")
    #elseif os(macOS)
    static let dtrsyl_work: FunctionTypes.LAPACKE_dtrsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsyl_work: FunctionTypes.LAPACKE_ctrsyl_work? = load(name: "LAPACKE_ctrsyl_work")
    #elseif os(macOS)
    static let ctrsyl_work: FunctionTypes.LAPACKE_ctrsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl_work: FunctionTypes.LAPACKE_ztrsyl_work? = load(name: "LAPACKE_ztrsyl_work")
    #elseif os(macOS)
    static let ztrsyl_work: FunctionTypes.LAPACKE_ztrsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl3_work: FunctionTypes.LAPACKE_strsyl3_work? = load(name: "LAPACKE_strsyl3_work")
    #elseif os(macOS)
    static let strsyl3_work: FunctionTypes.LAPACKE_strsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl3_work: FunctionTypes.LAPACKE_dtrsyl3_work? = load(name: "LAPACKE_dtrsyl3_work")
    #elseif os(macOS)
    static let dtrsyl3_work: FunctionTypes.LAPACKE_dtrsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsyl3_work: FunctionTypes.LAPACKE_ctrsyl3_work? = load(name: "LAPACKE_ctrsyl3_work")
    #elseif os(macOS)
    static let ctrsyl3_work: FunctionTypes.LAPACKE_ctrsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl3_work: FunctionTypes.LAPACKE_ztrsyl3_work? = load(name: "LAPACKE_ztrsyl3_work")
    #elseif os(macOS)
    static let ztrsyl3_work: FunctionTypes.LAPACKE_ztrsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtri_work: FunctionTypes.LAPACKE_strtri_work? = load(name: "LAPACKE_strtri_work")
    #elseif os(macOS)
    static let strtri_work: FunctionTypes.LAPACKE_strtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtri_work: FunctionTypes.LAPACKE_dtrtri_work? = load(name: "LAPACKE_dtrtri_work")
    #elseif os(macOS)
    static let dtrtri_work: FunctionTypes.LAPACKE_dtrtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtri_work: FunctionTypes.LAPACKE_ctrtri_work? = load(name: "LAPACKE_ctrtri_work")
    #elseif os(macOS)
    static let ctrtri_work: FunctionTypes.LAPACKE_ctrtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtri_work: FunctionTypes.LAPACKE_ztrtri_work? = load(name: "LAPACKE_ztrtri_work")
    #elseif os(macOS)
    static let ztrtri_work: FunctionTypes.LAPACKE_ztrtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtrs_work: FunctionTypes.LAPACKE_strtrs_work? = load(name: "LAPACKE_strtrs_work")
    #elseif os(macOS)
    static let strtrs_work: FunctionTypes.LAPACKE_strtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtrs_work: FunctionTypes.LAPACKE_dtrtrs_work? = load(name: "LAPACKE_dtrtrs_work")
    #elseif os(macOS)
    static let dtrtrs_work: FunctionTypes.LAPACKE_dtrtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtrs_work: FunctionTypes.LAPACKE_ctrtrs_work? = load(name: "LAPACKE_ctrtrs_work")
    #elseif os(macOS)
    static let ctrtrs_work: FunctionTypes.LAPACKE_ctrtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtrs_work: FunctionTypes.LAPACKE_ztrtrs_work? = load(name: "LAPACKE_ztrtrs_work")
    #elseif os(macOS)
    static let ztrtrs_work: FunctionTypes.LAPACKE_ztrtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttf_work: FunctionTypes.LAPACKE_strttf_work? = load(name: "LAPACKE_strttf_work")
    #elseif os(macOS)
    static let strttf_work: FunctionTypes.LAPACKE_strttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttf_work: FunctionTypes.LAPACKE_dtrttf_work? = load(name: "LAPACKE_dtrttf_work")
    #elseif os(macOS)
    static let dtrttf_work: FunctionTypes.LAPACKE_dtrttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttf_work: FunctionTypes.LAPACKE_ctrttf_work? = load(name: "LAPACKE_ctrttf_work")
    #elseif os(macOS)
    static let ctrttf_work: FunctionTypes.LAPACKE_ctrttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttf_work: FunctionTypes.LAPACKE_ztrttf_work? = load(name: "LAPACKE_ztrttf_work")
    #elseif os(macOS)
    static let ztrttf_work: FunctionTypes.LAPACKE_ztrttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttp_work: FunctionTypes.LAPACKE_strttp_work? = load(name: "LAPACKE_strttp_work")
    #elseif os(macOS)
    static let strttp_work: FunctionTypes.LAPACKE_strttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttp_work: FunctionTypes.LAPACKE_dtrttp_work? = load(name: "LAPACKE_dtrttp_work")
    #elseif os(macOS)
    static let dtrttp_work: FunctionTypes.LAPACKE_dtrttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttp_work: FunctionTypes.LAPACKE_ctrttp_work? = load(name: "LAPACKE_ctrttp_work")
    #elseif os(macOS)
    static let ctrttp_work: FunctionTypes.LAPACKE_ctrttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttp_work: FunctionTypes.LAPACKE_ztrttp_work? = load(name: "LAPACKE_ztrttp_work")
    #elseif os(macOS)
    static let ztrttp_work: FunctionTypes.LAPACKE_ztrttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stzrzf_work: FunctionTypes.LAPACKE_stzrzf_work? = load(name: "LAPACKE_stzrzf_work")
    #elseif os(macOS)
    static let stzrzf_work: FunctionTypes.LAPACKE_stzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtzrzf_work: FunctionTypes.LAPACKE_dtzrzf_work? = load(name: "LAPACKE_dtzrzf_work")
    #elseif os(macOS)
    static let dtzrzf_work: FunctionTypes.LAPACKE_dtzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctzrzf_work: FunctionTypes.LAPACKE_ctzrzf_work? = load(name: "LAPACKE_ctzrzf_work")
    #elseif os(macOS)
    static let ctzrzf_work: FunctionTypes.LAPACKE_ctzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztzrzf_work: FunctionTypes.LAPACKE_ztzrzf_work? = load(name: "LAPACKE_ztzrzf_work")
    #elseif os(macOS)
    static let ztzrzf_work: FunctionTypes.LAPACKE_ztzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungbr_work: FunctionTypes.LAPACKE_cungbr_work? = load(name: "LAPACKE_cungbr_work")
    #elseif os(macOS)
    static let cungbr_work: FunctionTypes.LAPACKE_cungbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungbr_work: FunctionTypes.LAPACKE_zungbr_work? = load(name: "LAPACKE_zungbr_work")
    #elseif os(macOS)
    static let zungbr_work: FunctionTypes.LAPACKE_zungbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunghr_work: FunctionTypes.LAPACKE_cunghr_work? = load(name: "LAPACKE_cunghr_work")
    #elseif os(macOS)
    static let cunghr_work: FunctionTypes.LAPACKE_cunghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunghr_work: FunctionTypes.LAPACKE_zunghr_work? = load(name: "LAPACKE_zunghr_work")
    #elseif os(macOS)
    static let zunghr_work: FunctionTypes.LAPACKE_zunghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunglq_work: FunctionTypes.LAPACKE_cunglq_work? = load(name: "LAPACKE_cunglq_work")
    #elseif os(macOS)
    static let cunglq_work: FunctionTypes.LAPACKE_cunglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunglq_work: FunctionTypes.LAPACKE_zunglq_work? = load(name: "LAPACKE_zunglq_work")
    #elseif os(macOS)
    static let zunglq_work: FunctionTypes.LAPACKE_zunglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungql_work: FunctionTypes.LAPACKE_cungql_work? = load(name: "LAPACKE_cungql_work")
    #elseif os(macOS)
    static let cungql_work: FunctionTypes.LAPACKE_cungql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungql_work: FunctionTypes.LAPACKE_zungql_work? = load(name: "LAPACKE_zungql_work")
    #elseif os(macOS)
    static let zungql_work: FunctionTypes.LAPACKE_zungql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungqr_work: FunctionTypes.LAPACKE_cungqr_work? = load(name: "LAPACKE_cungqr_work")
    #elseif os(macOS)
    static let cungqr_work: FunctionTypes.LAPACKE_cungqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungqr_work: FunctionTypes.LAPACKE_zungqr_work? = load(name: "LAPACKE_zungqr_work")
    #elseif os(macOS)
    static let zungqr_work: FunctionTypes.LAPACKE_zungqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungrq_work: FunctionTypes.LAPACKE_cungrq_work? = load(name: "LAPACKE_cungrq_work")
    #elseif os(macOS)
    static let cungrq_work: FunctionTypes.LAPACKE_cungrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungrq_work: FunctionTypes.LAPACKE_zungrq_work? = load(name: "LAPACKE_zungrq_work")
    #elseif os(macOS)
    static let zungrq_work: FunctionTypes.LAPACKE_zungrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtr_work: FunctionTypes.LAPACKE_cungtr_work? = load(name: "LAPACKE_cungtr_work")
    #elseif os(macOS)
    static let cungtr_work: FunctionTypes.LAPACKE_cungtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtr_work: FunctionTypes.LAPACKE_zungtr_work? = load(name: "LAPACKE_zungtr_work")
    #elseif os(macOS)
    static let zungtr_work: FunctionTypes.LAPACKE_zungtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtsqr_row_work: FunctionTypes.LAPACKE_cungtsqr_row_work? = load(name: "LAPACKE_cungtsqr_row_work")
    #elseif os(macOS)
    static let cungtsqr_row_work: FunctionTypes.LAPACKE_cungtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtsqr_row_work: FunctionTypes.LAPACKE_zungtsqr_row_work? = load(name: "LAPACKE_zungtsqr_row_work")
    #elseif os(macOS)
    static let zungtsqr_row_work: FunctionTypes.LAPACKE_zungtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmbr_work: FunctionTypes.LAPACKE_cunmbr_work? = load(name: "LAPACKE_cunmbr_work")
    #elseif os(macOS)
    static let cunmbr_work: FunctionTypes.LAPACKE_cunmbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmbr_work: FunctionTypes.LAPACKE_zunmbr_work? = load(name: "LAPACKE_zunmbr_work")
    #elseif os(macOS)
    static let zunmbr_work: FunctionTypes.LAPACKE_zunmbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmhr_work: FunctionTypes.LAPACKE_cunmhr_work? = load(name: "LAPACKE_cunmhr_work")
    #elseif os(macOS)
    static let cunmhr_work: FunctionTypes.LAPACKE_cunmhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmhr_work: FunctionTypes.LAPACKE_zunmhr_work? = load(name: "LAPACKE_zunmhr_work")
    #elseif os(macOS)
    static let zunmhr_work: FunctionTypes.LAPACKE_zunmhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmlq_work: FunctionTypes.LAPACKE_cunmlq_work? = load(name: "LAPACKE_cunmlq_work")
    #elseif os(macOS)
    static let cunmlq_work: FunctionTypes.LAPACKE_cunmlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmlq_work: FunctionTypes.LAPACKE_zunmlq_work? = load(name: "LAPACKE_zunmlq_work")
    #elseif os(macOS)
    static let zunmlq_work: FunctionTypes.LAPACKE_zunmlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmql_work: FunctionTypes.LAPACKE_cunmql_work? = load(name: "LAPACKE_cunmql_work")
    #elseif os(macOS)
    static let cunmql_work: FunctionTypes.LAPACKE_cunmql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmql_work: FunctionTypes.LAPACKE_zunmql_work? = load(name: "LAPACKE_zunmql_work")
    #elseif os(macOS)
    static let zunmql_work: FunctionTypes.LAPACKE_zunmql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmqr_work: FunctionTypes.LAPACKE_cunmqr_work? = load(name: "LAPACKE_cunmqr_work")
    #elseif os(macOS)
    static let cunmqr_work: FunctionTypes.LAPACKE_cunmqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmqr_work: FunctionTypes.LAPACKE_zunmqr_work? = load(name: "LAPACKE_zunmqr_work")
    #elseif os(macOS)
    static let zunmqr_work: FunctionTypes.LAPACKE_zunmqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrq_work: FunctionTypes.LAPACKE_cunmrq_work? = load(name: "LAPACKE_cunmrq_work")
    #elseif os(macOS)
    static let cunmrq_work: FunctionTypes.LAPACKE_cunmrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrq_work: FunctionTypes.LAPACKE_zunmrq_work? = load(name: "LAPACKE_zunmrq_work")
    #elseif os(macOS)
    static let zunmrq_work: FunctionTypes.LAPACKE_zunmrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrz_work: FunctionTypes.LAPACKE_cunmrz_work? = load(name: "LAPACKE_cunmrz_work")
    #elseif os(macOS)
    static let cunmrz_work: FunctionTypes.LAPACKE_cunmrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrz_work: FunctionTypes.LAPACKE_zunmrz_work? = load(name: "LAPACKE_zunmrz_work")
    #elseif os(macOS)
    static let zunmrz_work: FunctionTypes.LAPACKE_zunmrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmtr_work: FunctionTypes.LAPACKE_cunmtr_work? = load(name: "LAPACKE_cunmtr_work")
    #elseif os(macOS)
    static let cunmtr_work: FunctionTypes.LAPACKE_cunmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmtr_work: FunctionTypes.LAPACKE_zunmtr_work? = load(name: "LAPACKE_zunmtr_work")
    #elseif os(macOS)
    static let zunmtr_work: FunctionTypes.LAPACKE_zunmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupgtr_work: FunctionTypes.LAPACKE_cupgtr_work? = load(name: "LAPACKE_cupgtr_work")
    #elseif os(macOS)
    static let cupgtr_work: FunctionTypes.LAPACKE_cupgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupgtr_work: FunctionTypes.LAPACKE_zupgtr_work? = load(name: "LAPACKE_zupgtr_work")
    #elseif os(macOS)
    static let zupgtr_work: FunctionTypes.LAPACKE_zupgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupmtr_work: FunctionTypes.LAPACKE_cupmtr_work? = load(name: "LAPACKE_cupmtr_work")
    #elseif os(macOS)
    static let cupmtr_work: FunctionTypes.LAPACKE_cupmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupmtr_work: FunctionTypes.LAPACKE_zupmtr_work? = load(name: "LAPACKE_zupmtr_work")
    #elseif os(macOS)
    static let zupmtr_work: FunctionTypes.LAPACKE_zupmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claghe: FunctionTypes.LAPACKE_claghe? = load(name: "LAPACKE_claghe")
    #elseif os(macOS)
    static let claghe: FunctionTypes.LAPACKE_claghe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaghe: FunctionTypes.LAPACKE_zlaghe? = load(name: "LAPACKE_zlaghe")
    #elseif os(macOS)
    static let zlaghe: FunctionTypes.LAPACKE_zlaghe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagsy: FunctionTypes.LAPACKE_slagsy? = load(name: "LAPACKE_slagsy")
    #elseif os(macOS)
    static let slagsy: FunctionTypes.LAPACKE_slagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagsy: FunctionTypes.LAPACKE_dlagsy? = load(name: "LAPACKE_dlagsy")
    #elseif os(macOS)
    static let dlagsy: FunctionTypes.LAPACKE_dlagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagsy: FunctionTypes.LAPACKE_clagsy? = load(name: "LAPACKE_clagsy")
    #elseif os(macOS)
    static let clagsy: FunctionTypes.LAPACKE_clagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagsy: FunctionTypes.LAPACKE_zlagsy? = load(name: "LAPACKE_zlagsy")
    #elseif os(macOS)
    static let zlagsy: FunctionTypes.LAPACKE_zlagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmr: FunctionTypes.LAPACKE_slapmr? = load(name: "LAPACKE_slapmr")
    #elseif os(macOS)
    static let slapmr: FunctionTypes.LAPACKE_slapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmr: FunctionTypes.LAPACKE_dlapmr? = load(name: "LAPACKE_dlapmr")
    #elseif os(macOS)
    static let dlapmr: FunctionTypes.LAPACKE_dlapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmr: FunctionTypes.LAPACKE_clapmr? = load(name: "LAPACKE_clapmr")
    #elseif os(macOS)
    static let clapmr: FunctionTypes.LAPACKE_clapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmr: FunctionTypes.LAPACKE_zlapmr? = load(name: "LAPACKE_zlapmr")
    #elseif os(macOS)
    static let zlapmr: FunctionTypes.LAPACKE_zlapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmt: FunctionTypes.LAPACKE_slapmt? = load(name: "LAPACKE_slapmt")
    #elseif os(macOS)
    static let slapmt: FunctionTypes.LAPACKE_slapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmt: FunctionTypes.LAPACKE_dlapmt? = load(name: "LAPACKE_dlapmt")
    #elseif os(macOS)
    static let dlapmt: FunctionTypes.LAPACKE_dlapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmt: FunctionTypes.LAPACKE_clapmt? = load(name: "LAPACKE_clapmt")
    #elseif os(macOS)
    static let clapmt: FunctionTypes.LAPACKE_clapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmt: FunctionTypes.LAPACKE_zlapmt? = load(name: "LAPACKE_zlapmt")
    #elseif os(macOS)
    static let zlapmt: FunctionTypes.LAPACKE_zlapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy2: FunctionTypes.LAPACKE_slapy2? = load(name: "LAPACKE_slapy2")
    #elseif os(macOS)
    static let slapy2: FunctionTypes.LAPACKE_slapy2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy2: FunctionTypes.LAPACKE_dlapy2? = load(name: "LAPACKE_dlapy2")
    #elseif os(macOS)
    static let dlapy2: FunctionTypes.LAPACKE_dlapy2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy3: FunctionTypes.LAPACKE_slapy3? = load(name: "LAPACKE_slapy3")
    #elseif os(macOS)
    static let slapy3: FunctionTypes.LAPACKE_slapy3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy3: FunctionTypes.LAPACKE_dlapy3? = load(name: "LAPACKE_dlapy3")
    #elseif os(macOS)
    static let dlapy3: FunctionTypes.LAPACKE_dlapy3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgp: FunctionTypes.LAPACKE_slartgp? = load(name: "LAPACKE_slartgp")
    #elseif os(macOS)
    static let slartgp: FunctionTypes.LAPACKE_slartgp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgp: FunctionTypes.LAPACKE_dlartgp? = load(name: "LAPACKE_dlartgp")
    #elseif os(macOS)
    static let dlartgp: FunctionTypes.LAPACKE_dlartgp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgs: FunctionTypes.LAPACKE_slartgs? = load(name: "LAPACKE_slartgs")
    #elseif os(macOS)
    static let slartgs: FunctionTypes.LAPACKE_slartgs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgs: FunctionTypes.LAPACKE_dlartgs? = load(name: "LAPACKE_dlartgs")
    #elseif os(macOS)
    static let dlartgs: FunctionTypes.LAPACKE_dlartgs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbbcsd: FunctionTypes.LAPACKE_cbbcsd? = load(name: "LAPACKE_cbbcsd")
    #elseif os(macOS)
    static let cbbcsd: FunctionTypes.LAPACKE_cbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbbcsd_work: FunctionTypes.LAPACKE_cbbcsd_work? = load(name: "LAPACKE_cbbcsd_work")
    #elseif os(macOS)
    static let cbbcsd_work: FunctionTypes.LAPACKE_cbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheswapr: FunctionTypes.LAPACKE_cheswapr? = load(name: "LAPACKE_cheswapr")
    #elseif os(macOS)
    static let cheswapr: FunctionTypes.LAPACKE_cheswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheswapr_work: FunctionTypes.LAPACKE_cheswapr_work? = load(name: "LAPACKE_cheswapr_work")
    #elseif os(macOS)
    static let cheswapr_work: FunctionTypes.LAPACKE_cheswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2: FunctionTypes.LAPACKE_chetri2? = load(name: "LAPACKE_chetri2")
    #elseif os(macOS)
    static let chetri2: FunctionTypes.LAPACKE_chetri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2_work: FunctionTypes.LAPACKE_chetri2_work? = load(name: "LAPACKE_chetri2_work")
    #elseif os(macOS)
    static let chetri2_work: FunctionTypes.LAPACKE_chetri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2x: FunctionTypes.LAPACKE_chetri2x? = load(name: "LAPACKE_chetri2x")
    #elseif os(macOS)
    static let chetri2x: FunctionTypes.LAPACKE_chetri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2x_work: FunctionTypes.LAPACKE_chetri2x_work? = load(name: "LAPACKE_chetri2x_work")
    #elseif os(macOS)
    static let chetri2x_work: FunctionTypes.LAPACKE_chetri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs2: FunctionTypes.LAPACKE_chetrs2? = load(name: "LAPACKE_chetrs2")
    #elseif os(macOS)
    static let chetrs2: FunctionTypes.LAPACKE_chetrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs2_work: FunctionTypes.LAPACKE_chetrs2_work? = load(name: "LAPACKE_chetrs2_work")
    #elseif os(macOS)
    static let chetrs2_work: FunctionTypes.LAPACKE_chetrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyconv: FunctionTypes.LAPACKE_csyconv? = load(name: "LAPACKE_csyconv")
    #elseif os(macOS)
    static let csyconv: FunctionTypes.LAPACKE_csyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyconv_work: FunctionTypes.LAPACKE_csyconv_work? = load(name: "LAPACKE_csyconv_work")
    #elseif os(macOS)
    static let csyconv_work: FunctionTypes.LAPACKE_csyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyswapr: FunctionTypes.LAPACKE_csyswapr? = load(name: "LAPACKE_csyswapr")
    #elseif os(macOS)
    static let csyswapr: FunctionTypes.LAPACKE_csyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyswapr_work: FunctionTypes.LAPACKE_csyswapr_work? = load(name: "LAPACKE_csyswapr_work")
    #elseif os(macOS)
    static let csyswapr_work: FunctionTypes.LAPACKE_csyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2: FunctionTypes.LAPACKE_csytri2? = load(name: "LAPACKE_csytri2")
    #elseif os(macOS)
    static let csytri2: FunctionTypes.LAPACKE_csytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2_work: FunctionTypes.LAPACKE_csytri2_work? = load(name: "LAPACKE_csytri2_work")
    #elseif os(macOS)
    static let csytri2_work: FunctionTypes.LAPACKE_csytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2x: FunctionTypes.LAPACKE_csytri2x? = load(name: "LAPACKE_csytri2x")
    #elseif os(macOS)
    static let csytri2x: FunctionTypes.LAPACKE_csytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2x_work: FunctionTypes.LAPACKE_csytri2x_work? = load(name: "LAPACKE_csytri2x_work")
    #elseif os(macOS)
    static let csytri2x_work: FunctionTypes.LAPACKE_csytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs2: FunctionTypes.LAPACKE_csytrs2? = load(name: "LAPACKE_csytrs2")
    #elseif os(macOS)
    static let csytrs2: FunctionTypes.LAPACKE_csytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs2_work: FunctionTypes.LAPACKE_csytrs2_work? = load(name: "LAPACKE_csytrs2_work")
    #elseif os(macOS)
    static let csytrs2_work: FunctionTypes.LAPACKE_csytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunbdb: FunctionTypes.LAPACKE_cunbdb? = load(name: "LAPACKE_cunbdb")
    #elseif os(macOS)
    static let cunbdb: FunctionTypes.LAPACKE_cunbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunbdb_work: FunctionTypes.LAPACKE_cunbdb_work? = load(name: "LAPACKE_cunbdb_work")
    #elseif os(macOS)
    static let cunbdb_work: FunctionTypes.LAPACKE_cunbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd: FunctionTypes.LAPACKE_cuncsd? = load(name: "LAPACKE_cuncsd")
    #elseif os(macOS)
    static let cuncsd: FunctionTypes.LAPACKE_cuncsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd_work: FunctionTypes.LAPACKE_cuncsd_work? = load(name: "LAPACKE_cuncsd_work")
    #elseif os(macOS)
    static let cuncsd_work: FunctionTypes.LAPACKE_cuncsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd2by1: FunctionTypes.LAPACKE_cuncsd2by1? = load(name: "LAPACKE_cuncsd2by1")
    #elseif os(macOS)
    static let cuncsd2by1: FunctionTypes.LAPACKE_cuncsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd2by1_work: FunctionTypes.LAPACKE_cuncsd2by1_work? = load(name: "LAPACKE_cuncsd2by1_work")
    #elseif os(macOS)
    static let cuncsd2by1_work: FunctionTypes.LAPACKE_cuncsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbbcsd: FunctionTypes.LAPACKE_dbbcsd? = load(name: "LAPACKE_dbbcsd")
    #elseif os(macOS)
    static let dbbcsd: FunctionTypes.LAPACKE_dbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbbcsd_work: FunctionTypes.LAPACKE_dbbcsd_work? = load(name: "LAPACKE_dbbcsd_work")
    #elseif os(macOS)
    static let dbbcsd_work: FunctionTypes.LAPACKE_dbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorbdb: FunctionTypes.LAPACKE_dorbdb? = load(name: "LAPACKE_dorbdb")
    #elseif os(macOS)
    static let dorbdb: FunctionTypes.LAPACKE_dorbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorbdb_work: FunctionTypes.LAPACKE_dorbdb_work? = load(name: "LAPACKE_dorbdb_work")
    #elseif os(macOS)
    static let dorbdb_work: FunctionTypes.LAPACKE_dorbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd: FunctionTypes.LAPACKE_dorcsd? = load(name: "LAPACKE_dorcsd")
    #elseif os(macOS)
    static let dorcsd: FunctionTypes.LAPACKE_dorcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd_work: FunctionTypes.LAPACKE_dorcsd_work? = load(name: "LAPACKE_dorcsd_work")
    #elseif os(macOS)
    static let dorcsd_work: FunctionTypes.LAPACKE_dorcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd2by1: FunctionTypes.LAPACKE_dorcsd2by1? = load(name: "LAPACKE_dorcsd2by1")
    #elseif os(macOS)
    static let dorcsd2by1: FunctionTypes.LAPACKE_dorcsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd2by1_work: FunctionTypes.LAPACKE_dorcsd2by1_work? = load(name: "LAPACKE_dorcsd2by1_work")
    #elseif os(macOS)
    static let dorcsd2by1_work: FunctionTypes.LAPACKE_dorcsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyconv: FunctionTypes.LAPACKE_dsyconv? = load(name: "LAPACKE_dsyconv")
    #elseif os(macOS)
    static let dsyconv: FunctionTypes.LAPACKE_dsyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyconv_work: FunctionTypes.LAPACKE_dsyconv_work? = load(name: "LAPACKE_dsyconv_work")
    #elseif os(macOS)
    static let dsyconv_work: FunctionTypes.LAPACKE_dsyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyswapr: FunctionTypes.LAPACKE_dsyswapr? = load(name: "LAPACKE_dsyswapr")
    #elseif os(macOS)
    static let dsyswapr: FunctionTypes.LAPACKE_dsyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyswapr_work: FunctionTypes.LAPACKE_dsyswapr_work? = load(name: "LAPACKE_dsyswapr_work")
    #elseif os(macOS)
    static let dsyswapr_work: FunctionTypes.LAPACKE_dsyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2: FunctionTypes.LAPACKE_dsytri2? = load(name: "LAPACKE_dsytri2")
    #elseif os(macOS)
    static let dsytri2: FunctionTypes.LAPACKE_dsytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2_work: FunctionTypes.LAPACKE_dsytri2_work? = load(name: "LAPACKE_dsytri2_work")
    #elseif os(macOS)
    static let dsytri2_work: FunctionTypes.LAPACKE_dsytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2x: FunctionTypes.LAPACKE_dsytri2x? = load(name: "LAPACKE_dsytri2x")
    #elseif os(macOS)
    static let dsytri2x: FunctionTypes.LAPACKE_dsytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2x_work: FunctionTypes.LAPACKE_dsytri2x_work? = load(name: "LAPACKE_dsytri2x_work")
    #elseif os(macOS)
    static let dsytri2x_work: FunctionTypes.LAPACKE_dsytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs2: FunctionTypes.LAPACKE_dsytrs2? = load(name: "LAPACKE_dsytrs2")
    #elseif os(macOS)
    static let dsytrs2: FunctionTypes.LAPACKE_dsytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs2_work: FunctionTypes.LAPACKE_dsytrs2_work? = load(name: "LAPACKE_dsytrs2_work")
    #elseif os(macOS)
    static let dsytrs2_work: FunctionTypes.LAPACKE_dsytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbbcsd: FunctionTypes.LAPACKE_sbbcsd? = load(name: "LAPACKE_sbbcsd")
    #elseif os(macOS)
    static let sbbcsd: FunctionTypes.LAPACKE_sbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbbcsd_work: FunctionTypes.LAPACKE_sbbcsd_work? = load(name: "LAPACKE_sbbcsd_work")
    #elseif os(macOS)
    static let sbbcsd_work: FunctionTypes.LAPACKE_sbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorbdb: FunctionTypes.LAPACKE_sorbdb? = load(name: "LAPACKE_sorbdb")
    #elseif os(macOS)
    static let sorbdb: FunctionTypes.LAPACKE_sorbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorbdb_work: FunctionTypes.LAPACKE_sorbdb_work? = load(name: "LAPACKE_sorbdb_work")
    #elseif os(macOS)
    static let sorbdb_work: FunctionTypes.LAPACKE_sorbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd: FunctionTypes.LAPACKE_sorcsd? = load(name: "LAPACKE_sorcsd")
    #elseif os(macOS)
    static let sorcsd: FunctionTypes.LAPACKE_sorcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd_work: FunctionTypes.LAPACKE_sorcsd_work? = load(name: "LAPACKE_sorcsd_work")
    #elseif os(macOS)
    static let sorcsd_work: FunctionTypes.LAPACKE_sorcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd2by1: FunctionTypes.LAPACKE_sorcsd2by1? = load(name: "LAPACKE_sorcsd2by1")
    #elseif os(macOS)
    static let sorcsd2by1: FunctionTypes.LAPACKE_sorcsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd2by1_work: FunctionTypes.LAPACKE_sorcsd2by1_work? = load(name: "LAPACKE_sorcsd2by1_work")
    #elseif os(macOS)
    static let sorcsd2by1_work: FunctionTypes.LAPACKE_sorcsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyconv: FunctionTypes.LAPACKE_ssyconv? = load(name: "LAPACKE_ssyconv")
    #elseif os(macOS)
    static let ssyconv: FunctionTypes.LAPACKE_ssyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyconv_work: FunctionTypes.LAPACKE_ssyconv_work? = load(name: "LAPACKE_ssyconv_work")
    #elseif os(macOS)
    static let ssyconv_work: FunctionTypes.LAPACKE_ssyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyswapr: FunctionTypes.LAPACKE_ssyswapr? = load(name: "LAPACKE_ssyswapr")
    #elseif os(macOS)
    static let ssyswapr: FunctionTypes.LAPACKE_ssyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyswapr_work: FunctionTypes.LAPACKE_ssyswapr_work? = load(name: "LAPACKE_ssyswapr_work")
    #elseif os(macOS)
    static let ssyswapr_work: FunctionTypes.LAPACKE_ssyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2: FunctionTypes.LAPACKE_ssytri2? = load(name: "LAPACKE_ssytri2")
    #elseif os(macOS)
    static let ssytri2: FunctionTypes.LAPACKE_ssytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2_work: FunctionTypes.LAPACKE_ssytri2_work? = load(name: "LAPACKE_ssytri2_work")
    #elseif os(macOS)
    static let ssytri2_work: FunctionTypes.LAPACKE_ssytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2x: FunctionTypes.LAPACKE_ssytri2x? = load(name: "LAPACKE_ssytri2x")
    #elseif os(macOS)
    static let ssytri2x: FunctionTypes.LAPACKE_ssytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2x_work: FunctionTypes.LAPACKE_ssytri2x_work? = load(name: "LAPACKE_ssytri2x_work")
    #elseif os(macOS)
    static let ssytri2x_work: FunctionTypes.LAPACKE_ssytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs2: FunctionTypes.LAPACKE_ssytrs2? = load(name: "LAPACKE_ssytrs2")
    #elseif os(macOS)
    static let ssytrs2: FunctionTypes.LAPACKE_ssytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs2_work: FunctionTypes.LAPACKE_ssytrs2_work? = load(name: "LAPACKE_ssytrs2_work")
    #elseif os(macOS)
    static let ssytrs2_work: FunctionTypes.LAPACKE_ssytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbbcsd: FunctionTypes.LAPACKE_zbbcsd? = load(name: "LAPACKE_zbbcsd")
    #elseif os(macOS)
    static let zbbcsd: FunctionTypes.LAPACKE_zbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbbcsd_work: FunctionTypes.LAPACKE_zbbcsd_work? = load(name: "LAPACKE_zbbcsd_work")
    #elseif os(macOS)
    static let zbbcsd_work: FunctionTypes.LAPACKE_zbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheswapr: FunctionTypes.LAPACKE_zheswapr? = load(name: "LAPACKE_zheswapr")
    #elseif os(macOS)
    static let zheswapr: FunctionTypes.LAPACKE_zheswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheswapr_work: FunctionTypes.LAPACKE_zheswapr_work? = load(name: "LAPACKE_zheswapr_work")
    #elseif os(macOS)
    static let zheswapr_work: FunctionTypes.LAPACKE_zheswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2: FunctionTypes.LAPACKE_zhetri2? = load(name: "LAPACKE_zhetri2")
    #elseif os(macOS)
    static let zhetri2: FunctionTypes.LAPACKE_zhetri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2_work: FunctionTypes.LAPACKE_zhetri2_work? = load(name: "LAPACKE_zhetri2_work")
    #elseif os(macOS)
    static let zhetri2_work: FunctionTypes.LAPACKE_zhetri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2x: FunctionTypes.LAPACKE_zhetri2x? = load(name: "LAPACKE_zhetri2x")
    #elseif os(macOS)
    static let zhetri2x: FunctionTypes.LAPACKE_zhetri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2x_work: FunctionTypes.LAPACKE_zhetri2x_work? = load(name: "LAPACKE_zhetri2x_work")
    #elseif os(macOS)
    static let zhetri2x_work: FunctionTypes.LAPACKE_zhetri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs2: FunctionTypes.LAPACKE_zhetrs2? = load(name: "LAPACKE_zhetrs2")
    #elseif os(macOS)
    static let zhetrs2: FunctionTypes.LAPACKE_zhetrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs2_work: FunctionTypes.LAPACKE_zhetrs2_work? = load(name: "LAPACKE_zhetrs2_work")
    #elseif os(macOS)
    static let zhetrs2_work: FunctionTypes.LAPACKE_zhetrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyconv: FunctionTypes.LAPACKE_zsyconv? = load(name: "LAPACKE_zsyconv")
    #elseif os(macOS)
    static let zsyconv: FunctionTypes.LAPACKE_zsyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyconv_work: FunctionTypes.LAPACKE_zsyconv_work? = load(name: "LAPACKE_zsyconv_work")
    #elseif os(macOS)
    static let zsyconv_work: FunctionTypes.LAPACKE_zsyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyswapr: FunctionTypes.LAPACKE_zsyswapr? = load(name: "LAPACKE_zsyswapr")
    #elseif os(macOS)
    static let zsyswapr: FunctionTypes.LAPACKE_zsyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyswapr_work: FunctionTypes.LAPACKE_zsyswapr_work? = load(name: "LAPACKE_zsyswapr_work")
    #elseif os(macOS)
    static let zsyswapr_work: FunctionTypes.LAPACKE_zsyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2: FunctionTypes.LAPACKE_zsytri2? = load(name: "LAPACKE_zsytri2")
    #elseif os(macOS)
    static let zsytri2: FunctionTypes.LAPACKE_zsytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2_work: FunctionTypes.LAPACKE_zsytri2_work? = load(name: "LAPACKE_zsytri2_work")
    #elseif os(macOS)
    static let zsytri2_work: FunctionTypes.LAPACKE_zsytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2x: FunctionTypes.LAPACKE_zsytri2x? = load(name: "LAPACKE_zsytri2x")
    #elseif os(macOS)
    static let zsytri2x: FunctionTypes.LAPACKE_zsytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2x_work: FunctionTypes.LAPACKE_zsytri2x_work? = load(name: "LAPACKE_zsytri2x_work")
    #elseif os(macOS)
    static let zsytri2x_work: FunctionTypes.LAPACKE_zsytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs2: FunctionTypes.LAPACKE_zsytrs2? = load(name: "LAPACKE_zsytrs2")
    #elseif os(macOS)
    static let zsytrs2: FunctionTypes.LAPACKE_zsytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs2_work: FunctionTypes.LAPACKE_zsytrs2_work? = load(name: "LAPACKE_zsytrs2_work")
    #elseif os(macOS)
    static let zsytrs2_work: FunctionTypes.LAPACKE_zsytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunbdb: FunctionTypes.LAPACKE_zunbdb? = load(name: "LAPACKE_zunbdb")
    #elseif os(macOS)
    static let zunbdb: FunctionTypes.LAPACKE_zunbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunbdb_work: FunctionTypes.LAPACKE_zunbdb_work? = load(name: "LAPACKE_zunbdb_work")
    #elseif os(macOS)
    static let zunbdb_work: FunctionTypes.LAPACKE_zunbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd: FunctionTypes.LAPACKE_zuncsd? = load(name: "LAPACKE_zuncsd")
    #elseif os(macOS)
    static let zuncsd: FunctionTypes.LAPACKE_zuncsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd_work: FunctionTypes.LAPACKE_zuncsd_work? = load(name: "LAPACKE_zuncsd_work")
    #elseif os(macOS)
    static let zuncsd_work: FunctionTypes.LAPACKE_zuncsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd2by1: FunctionTypes.LAPACKE_zuncsd2by1? = load(name: "LAPACKE_zuncsd2by1")
    #elseif os(macOS)
    static let zuncsd2by1: FunctionTypes.LAPACKE_zuncsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd2by1_work: FunctionTypes.LAPACKE_zuncsd2by1_work? = load(name: "LAPACKE_zuncsd2by1_work")
    #elseif os(macOS)
    static let zuncsd2by1_work: FunctionTypes.LAPACKE_zuncsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqrt: FunctionTypes.LAPACKE_sgemqrt? = load(name: "LAPACKE_sgemqrt")
    #elseif os(macOS)
    static let sgemqrt: FunctionTypes.LAPACKE_sgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqrt: FunctionTypes.LAPACKE_dgemqrt? = load(name: "LAPACKE_dgemqrt")
    #elseif os(macOS)
    static let dgemqrt: FunctionTypes.LAPACKE_dgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqrt: FunctionTypes.LAPACKE_cgemqrt? = load(name: "LAPACKE_cgemqrt")
    #elseif os(macOS)
    static let cgemqrt: FunctionTypes.LAPACKE_cgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqrt: FunctionTypes.LAPACKE_zgemqrt? = load(name: "LAPACKE_zgemqrt")
    #elseif os(macOS)
    static let zgemqrt: FunctionTypes.LAPACKE_zgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt: FunctionTypes.LAPACKE_sgeqrt? = load(name: "LAPACKE_sgeqrt")
    #elseif os(macOS)
    static let sgeqrt: FunctionTypes.LAPACKE_sgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt: FunctionTypes.LAPACKE_dgeqrt? = load(name: "LAPACKE_dgeqrt")
    #elseif os(macOS)
    static let dgeqrt: FunctionTypes.LAPACKE_dgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt: FunctionTypes.LAPACKE_cgeqrt? = load(name: "LAPACKE_cgeqrt")
    #elseif os(macOS)
    static let cgeqrt: FunctionTypes.LAPACKE_cgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt: FunctionTypes.LAPACKE_zgeqrt? = load(name: "LAPACKE_zgeqrt")
    #elseif os(macOS)
    static let zgeqrt: FunctionTypes.LAPACKE_zgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt2: FunctionTypes.LAPACKE_sgeqrt2? = load(name: "LAPACKE_sgeqrt2")
    #elseif os(macOS)
    static let sgeqrt2: FunctionTypes.LAPACKE_sgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt2: FunctionTypes.LAPACKE_dgeqrt2? = load(name: "LAPACKE_dgeqrt2")
    #elseif os(macOS)
    static let dgeqrt2: FunctionTypes.LAPACKE_dgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt2: FunctionTypes.LAPACKE_cgeqrt2? = load(name: "LAPACKE_cgeqrt2")
    #elseif os(macOS)
    static let cgeqrt2: FunctionTypes.LAPACKE_cgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt2: FunctionTypes.LAPACKE_zgeqrt2? = load(name: "LAPACKE_zgeqrt2")
    #elseif os(macOS)
    static let zgeqrt2: FunctionTypes.LAPACKE_zgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt3: FunctionTypes.LAPACKE_sgeqrt3? = load(name: "LAPACKE_sgeqrt3")
    #elseif os(macOS)
    static let sgeqrt3: FunctionTypes.LAPACKE_sgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt3: FunctionTypes.LAPACKE_dgeqrt3? = load(name: "LAPACKE_dgeqrt3")
    #elseif os(macOS)
    static let dgeqrt3: FunctionTypes.LAPACKE_dgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt3: FunctionTypes.LAPACKE_cgeqrt3? = load(name: "LAPACKE_cgeqrt3")
    #elseif os(macOS)
    static let cgeqrt3: FunctionTypes.LAPACKE_cgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt3: FunctionTypes.LAPACKE_zgeqrt3? = load(name: "LAPACKE_zgeqrt3")
    #elseif os(macOS)
    static let zgeqrt3: FunctionTypes.LAPACKE_zgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpmqrt: FunctionTypes.LAPACKE_stpmqrt? = load(name: "LAPACKE_stpmqrt")
    #elseif os(macOS)
    static let stpmqrt: FunctionTypes.LAPACKE_stpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpmqrt: FunctionTypes.LAPACKE_dtpmqrt? = load(name: "LAPACKE_dtpmqrt")
    #elseif os(macOS)
    static let dtpmqrt: FunctionTypes.LAPACKE_dtpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpmqrt: FunctionTypes.LAPACKE_ctpmqrt? = load(name: "LAPACKE_ctpmqrt")
    #elseif os(macOS)
    static let ctpmqrt: FunctionTypes.LAPACKE_ctpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpmqrt: FunctionTypes.LAPACKE_ztpmqrt? = load(name: "LAPACKE_ztpmqrt")
    #elseif os(macOS)
    static let ztpmqrt: FunctionTypes.LAPACKE_ztpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt: FunctionTypes.LAPACKE_stpqrt? = load(name: "LAPACKE_stpqrt")
    #elseif os(macOS)
    static let stpqrt: FunctionTypes.LAPACKE_stpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt: FunctionTypes.LAPACKE_dtpqrt? = load(name: "LAPACKE_dtpqrt")
    #elseif os(macOS)
    static let dtpqrt: FunctionTypes.LAPACKE_dtpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt: FunctionTypes.LAPACKE_ctpqrt? = load(name: "LAPACKE_ctpqrt")
    #elseif os(macOS)
    static let ctpqrt: FunctionTypes.LAPACKE_ctpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt: FunctionTypes.LAPACKE_ztpqrt? = load(name: "LAPACKE_ztpqrt")
    #elseif os(macOS)
    static let ztpqrt: FunctionTypes.LAPACKE_ztpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt2: FunctionTypes.LAPACKE_stpqrt2? = load(name: "LAPACKE_stpqrt2")
    #elseif os(macOS)
    static let stpqrt2: FunctionTypes.LAPACKE_stpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt2: FunctionTypes.LAPACKE_dtpqrt2? = load(name: "LAPACKE_dtpqrt2")
    #elseif os(macOS)
    static let dtpqrt2: FunctionTypes.LAPACKE_dtpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt2: FunctionTypes.LAPACKE_ctpqrt2? = load(name: "LAPACKE_ctpqrt2")
    #elseif os(macOS)
    static let ctpqrt2: FunctionTypes.LAPACKE_ctpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt2: FunctionTypes.LAPACKE_ztpqrt2? = load(name: "LAPACKE_ztpqrt2")
    #elseif os(macOS)
    static let ztpqrt2: FunctionTypes.LAPACKE_ztpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfb: FunctionTypes.LAPACKE_stprfb? = load(name: "LAPACKE_stprfb")
    #elseif os(macOS)
    static let stprfb: FunctionTypes.LAPACKE_stprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfb: FunctionTypes.LAPACKE_dtprfb? = load(name: "LAPACKE_dtprfb")
    #elseif os(macOS)
    static let dtprfb: FunctionTypes.LAPACKE_dtprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfb: FunctionTypes.LAPACKE_ctprfb? = load(name: "LAPACKE_ctprfb")
    #elseif os(macOS)
    static let ctprfb: FunctionTypes.LAPACKE_ctprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfb: FunctionTypes.LAPACKE_ztprfb? = load(name: "LAPACKE_ztprfb")
    #elseif os(macOS)
    static let ztprfb: FunctionTypes.LAPACKE_ztprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqrt_work: FunctionTypes.LAPACKE_sgemqrt_work? = load(name: "LAPACKE_sgemqrt_work")
    #elseif os(macOS)
    static let sgemqrt_work: FunctionTypes.LAPACKE_sgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqrt_work: FunctionTypes.LAPACKE_dgemqrt_work? = load(name: "LAPACKE_dgemqrt_work")
    #elseif os(macOS)
    static let dgemqrt_work: FunctionTypes.LAPACKE_dgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqrt_work: FunctionTypes.LAPACKE_cgemqrt_work? = load(name: "LAPACKE_cgemqrt_work")
    #elseif os(macOS)
    static let cgemqrt_work: FunctionTypes.LAPACKE_cgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqrt_work: FunctionTypes.LAPACKE_zgemqrt_work? = load(name: "LAPACKE_zgemqrt_work")
    #elseif os(macOS)
    static let zgemqrt_work: FunctionTypes.LAPACKE_zgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt_work: FunctionTypes.LAPACKE_sgeqrt_work? = load(name: "LAPACKE_sgeqrt_work")
    #elseif os(macOS)
    static let sgeqrt_work: FunctionTypes.LAPACKE_sgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt_work: FunctionTypes.LAPACKE_dgeqrt_work? = load(name: "LAPACKE_dgeqrt_work")
    #elseif os(macOS)
    static let dgeqrt_work: FunctionTypes.LAPACKE_dgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt_work: FunctionTypes.LAPACKE_cgeqrt_work? = load(name: "LAPACKE_cgeqrt_work")
    #elseif os(macOS)
    static let cgeqrt_work: FunctionTypes.LAPACKE_cgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt_work: FunctionTypes.LAPACKE_zgeqrt_work? = load(name: "LAPACKE_zgeqrt_work")
    #elseif os(macOS)
    static let zgeqrt_work: FunctionTypes.LAPACKE_zgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt2_work: FunctionTypes.LAPACKE_sgeqrt2_work? = load(name: "LAPACKE_sgeqrt2_work")
    #elseif os(macOS)
    static let sgeqrt2_work: FunctionTypes.LAPACKE_sgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt2_work: FunctionTypes.LAPACKE_dgeqrt2_work? = load(name: "LAPACKE_dgeqrt2_work")
    #elseif os(macOS)
    static let dgeqrt2_work: FunctionTypes.LAPACKE_dgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt2_work: FunctionTypes.LAPACKE_cgeqrt2_work? = load(name: "LAPACKE_cgeqrt2_work")
    #elseif os(macOS)
    static let cgeqrt2_work: FunctionTypes.LAPACKE_cgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt2_work: FunctionTypes.LAPACKE_zgeqrt2_work? = load(name: "LAPACKE_zgeqrt2_work")
    #elseif os(macOS)
    static let zgeqrt2_work: FunctionTypes.LAPACKE_zgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt3_work: FunctionTypes.LAPACKE_sgeqrt3_work? = load(name: "LAPACKE_sgeqrt3_work")
    #elseif os(macOS)
    static let sgeqrt3_work: FunctionTypes.LAPACKE_sgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt3_work: FunctionTypes.LAPACKE_dgeqrt3_work? = load(name: "LAPACKE_dgeqrt3_work")
    #elseif os(macOS)
    static let dgeqrt3_work: FunctionTypes.LAPACKE_dgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt3_work: FunctionTypes.LAPACKE_cgeqrt3_work? = load(name: "LAPACKE_cgeqrt3_work")
    #elseif os(macOS)
    static let cgeqrt3_work: FunctionTypes.LAPACKE_cgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt3_work: FunctionTypes.LAPACKE_zgeqrt3_work? = load(name: "LAPACKE_zgeqrt3_work")
    #elseif os(macOS)
    static let zgeqrt3_work: FunctionTypes.LAPACKE_zgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpmqrt_work: FunctionTypes.LAPACKE_stpmqrt_work? = load(name: "LAPACKE_stpmqrt_work")
    #elseif os(macOS)
    static let stpmqrt_work: FunctionTypes.LAPACKE_stpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpmqrt_work: FunctionTypes.LAPACKE_dtpmqrt_work? = load(name: "LAPACKE_dtpmqrt_work")
    #elseif os(macOS)
    static let dtpmqrt_work: FunctionTypes.LAPACKE_dtpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpmqrt_work: FunctionTypes.LAPACKE_ctpmqrt_work? = load(name: "LAPACKE_ctpmqrt_work")
    #elseif os(macOS)
    static let ctpmqrt_work: FunctionTypes.LAPACKE_ctpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpmqrt_work: FunctionTypes.LAPACKE_ztpmqrt_work? = load(name: "LAPACKE_ztpmqrt_work")
    #elseif os(macOS)
    static let ztpmqrt_work: FunctionTypes.LAPACKE_ztpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt_work: FunctionTypes.LAPACKE_stpqrt_work? = load(name: "LAPACKE_stpqrt_work")
    #elseif os(macOS)
    static let stpqrt_work: FunctionTypes.LAPACKE_stpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt_work: FunctionTypes.LAPACKE_dtpqrt_work? = load(name: "LAPACKE_dtpqrt_work")
    #elseif os(macOS)
    static let dtpqrt_work: FunctionTypes.LAPACKE_dtpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt_work: FunctionTypes.LAPACKE_ctpqrt_work? = load(name: "LAPACKE_ctpqrt_work")
    #elseif os(macOS)
    static let ctpqrt_work: FunctionTypes.LAPACKE_ctpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt_work: FunctionTypes.LAPACKE_ztpqrt_work? = load(name: "LAPACKE_ztpqrt_work")
    #elseif os(macOS)
    static let ztpqrt_work: FunctionTypes.LAPACKE_ztpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt2_work: FunctionTypes.LAPACKE_stpqrt2_work? = load(name: "LAPACKE_stpqrt2_work")
    #elseif os(macOS)
    static let stpqrt2_work: FunctionTypes.LAPACKE_stpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt2_work: FunctionTypes.LAPACKE_dtpqrt2_work? = load(name: "LAPACKE_dtpqrt2_work")
    #elseif os(macOS)
    static let dtpqrt2_work: FunctionTypes.LAPACKE_dtpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt2_work: FunctionTypes.LAPACKE_ctpqrt2_work? = load(name: "LAPACKE_ctpqrt2_work")
    #elseif os(macOS)
    static let ctpqrt2_work: FunctionTypes.LAPACKE_ctpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt2_work: FunctionTypes.LAPACKE_ztpqrt2_work? = load(name: "LAPACKE_ztpqrt2_work")
    #elseif os(macOS)
    static let ztpqrt2_work: FunctionTypes.LAPACKE_ztpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfb_work: FunctionTypes.LAPACKE_stprfb_work? = load(name: "LAPACKE_stprfb_work")
    #elseif os(macOS)
    static let stprfb_work: FunctionTypes.LAPACKE_stprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfb_work: FunctionTypes.LAPACKE_dtprfb_work? = load(name: "LAPACKE_dtprfb_work")
    #elseif os(macOS)
    static let dtprfb_work: FunctionTypes.LAPACKE_dtprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfb_work: FunctionTypes.LAPACKE_ctprfb_work? = load(name: "LAPACKE_ctprfb_work")
    #elseif os(macOS)
    static let ctprfb_work: FunctionTypes.LAPACKE_ctprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfb_work: FunctionTypes.LAPACKE_ztprfb_work? = load(name: "LAPACKE_ztprfb_work")
    #elseif os(macOS)
    static let ztprfb_work: FunctionTypes.LAPACKE_ztprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rook: FunctionTypes.LAPACKE_ssysv_rook? = load(name: "LAPACKE_ssysv_rook")
    #elseif os(macOS)
    static let ssysv_rook: FunctionTypes.LAPACKE_ssysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rook: FunctionTypes.LAPACKE_dsysv_rook? = load(name: "LAPACKE_dsysv_rook")
    #elseif os(macOS)
    static let dsysv_rook: FunctionTypes.LAPACKE_dsysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rook: FunctionTypes.LAPACKE_csysv_rook? = load(name: "LAPACKE_csysv_rook")
    #elseif os(macOS)
    static let csysv_rook: FunctionTypes.LAPACKE_csysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rook: FunctionTypes.LAPACKE_zsysv_rook? = load(name: "LAPACKE_zsysv_rook")
    #elseif os(macOS)
    static let zsysv_rook: FunctionTypes.LAPACKE_zsysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rook: FunctionTypes.LAPACKE_ssytrf_rook? = load(name: "LAPACKE_ssytrf_rook")
    #elseif os(macOS)
    static let ssytrf_rook: FunctionTypes.LAPACKE_ssytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rook: FunctionTypes.LAPACKE_dsytrf_rook? = load(name: "LAPACKE_dsytrf_rook")
    #elseif os(macOS)
    static let dsytrf_rook: FunctionTypes.LAPACKE_dsytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rook: FunctionTypes.LAPACKE_csytrf_rook? = load(name: "LAPACKE_csytrf_rook")
    #elseif os(macOS)
    static let csytrf_rook: FunctionTypes.LAPACKE_csytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rook: FunctionTypes.LAPACKE_zsytrf_rook? = load(name: "LAPACKE_zsytrf_rook")
    #elseif os(macOS)
    static let zsytrf_rook: FunctionTypes.LAPACKE_zsytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_rook: FunctionTypes.LAPACKE_ssytrs_rook? = load(name: "LAPACKE_ssytrs_rook")
    #elseif os(macOS)
    static let ssytrs_rook: FunctionTypes.LAPACKE_ssytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_rook: FunctionTypes.LAPACKE_dsytrs_rook? = load(name: "LAPACKE_dsytrs_rook")
    #elseif os(macOS)
    static let dsytrs_rook: FunctionTypes.LAPACKE_dsytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_rook: FunctionTypes.LAPACKE_csytrs_rook? = load(name: "LAPACKE_csytrs_rook")
    #elseif os(macOS)
    static let csytrs_rook: FunctionTypes.LAPACKE_csytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_rook: FunctionTypes.LAPACKE_zsytrs_rook? = load(name: "LAPACKE_zsytrs_rook")
    #elseif os(macOS)
    static let zsytrs_rook: FunctionTypes.LAPACKE_zsytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rook: FunctionTypes.LAPACKE_chetrf_rook? = load(name: "LAPACKE_chetrf_rook")
    #elseif os(macOS)
    static let chetrf_rook: FunctionTypes.LAPACKE_chetrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rook: FunctionTypes.LAPACKE_zhetrf_rook? = load(name: "LAPACKE_zhetrf_rook")
    #elseif os(macOS)
    static let zhetrf_rook: FunctionTypes.LAPACKE_zhetrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_rook: FunctionTypes.LAPACKE_chetrs_rook? = load(name: "LAPACKE_chetrs_rook")
    #elseif os(macOS)
    static let chetrs_rook: FunctionTypes.LAPACKE_chetrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_rook: FunctionTypes.LAPACKE_zhetrs_rook? = load(name: "LAPACKE_zhetrs_rook")
    #elseif os(macOS)
    static let zhetrs_rook: FunctionTypes.LAPACKE_zhetrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rook_work: FunctionTypes.LAPACKE_ssysv_rook_work? = load(name: "LAPACKE_ssysv_rook_work")
    #elseif os(macOS)
    static let ssysv_rook_work: FunctionTypes.LAPACKE_ssysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rook_work: FunctionTypes.LAPACKE_dsysv_rook_work? = load(name: "LAPACKE_dsysv_rook_work")
    #elseif os(macOS)
    static let dsysv_rook_work: FunctionTypes.LAPACKE_dsysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rook_work: FunctionTypes.LAPACKE_csysv_rook_work? = load(name: "LAPACKE_csysv_rook_work")
    #elseif os(macOS)
    static let csysv_rook_work: FunctionTypes.LAPACKE_csysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rook_work: FunctionTypes.LAPACKE_zsysv_rook_work? = load(name: "LAPACKE_zsysv_rook_work")
    #elseif os(macOS)
    static let zsysv_rook_work: FunctionTypes.LAPACKE_zsysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rook_work: FunctionTypes.LAPACKE_ssytrf_rook_work? = load(name: "LAPACKE_ssytrf_rook_work")
    #elseif os(macOS)
    static let ssytrf_rook_work: FunctionTypes.LAPACKE_ssytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rook_work: FunctionTypes.LAPACKE_dsytrf_rook_work? = load(name: "LAPACKE_dsytrf_rook_work")
    #elseif os(macOS)
    static let dsytrf_rook_work: FunctionTypes.LAPACKE_dsytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rook_work: FunctionTypes.LAPACKE_csytrf_rook_work? = load(name: "LAPACKE_csytrf_rook_work")
    #elseif os(macOS)
    static let csytrf_rook_work: FunctionTypes.LAPACKE_csytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rook_work: FunctionTypes.LAPACKE_zsytrf_rook_work? = load(name: "LAPACKE_zsytrf_rook_work")
    #elseif os(macOS)
    static let zsytrf_rook_work: FunctionTypes.LAPACKE_zsytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_rook_work: FunctionTypes.LAPACKE_ssytrs_rook_work? = load(name: "LAPACKE_ssytrs_rook_work")
    #elseif os(macOS)
    static let ssytrs_rook_work: FunctionTypes.LAPACKE_ssytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_rook_work: FunctionTypes.LAPACKE_dsytrs_rook_work? = load(name: "LAPACKE_dsytrs_rook_work")
    #elseif os(macOS)
    static let dsytrs_rook_work: FunctionTypes.LAPACKE_dsytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_rook_work: FunctionTypes.LAPACKE_csytrs_rook_work? = load(name: "LAPACKE_csytrs_rook_work")
    #elseif os(macOS)
    static let csytrs_rook_work: FunctionTypes.LAPACKE_csytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_rook_work: FunctionTypes.LAPACKE_zsytrs_rook_work? = load(name: "LAPACKE_zsytrs_rook_work")
    #elseif os(macOS)
    static let zsytrs_rook_work: FunctionTypes.LAPACKE_zsytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rook_work: FunctionTypes.LAPACKE_chetrf_rook_work? = load(name: "LAPACKE_chetrf_rook_work")
    #elseif os(macOS)
    static let chetrf_rook_work: FunctionTypes.LAPACKE_chetrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rook_work: FunctionTypes.LAPACKE_zhetrf_rook_work? = load(name: "LAPACKE_zhetrf_rook_work")
    #elseif os(macOS)
    static let zhetrf_rook_work: FunctionTypes.LAPACKE_zhetrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_rook_work: FunctionTypes.LAPACKE_chetrs_rook_work? = load(name: "LAPACKE_chetrs_rook_work")
    #elseif os(macOS)
    static let chetrs_rook_work: FunctionTypes.LAPACKE_chetrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_rook_work: FunctionTypes.LAPACKE_zhetrs_rook_work? = load(name: "LAPACKE_zhetrs_rook_work")
    #elseif os(macOS)
    static let zhetrs_rook_work: FunctionTypes.LAPACKE_zhetrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ilaver: FunctionTypes.LAPACKE_ilaver? = load(name: "LAPACKE_ilaver")
    #elseif os(macOS)
    static let ilaver: FunctionTypes.LAPACKE_ilaver? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa: FunctionTypes.LAPACKE_ssysv_aa? = load(name: "LAPACKE_ssysv_aa")
    #elseif os(macOS)
    static let ssysv_aa: FunctionTypes.LAPACKE_ssysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa_work: FunctionTypes.LAPACKE_ssysv_aa_work? = load(name: "LAPACKE_ssysv_aa_work")
    #elseif os(macOS)
    static let ssysv_aa_work: FunctionTypes.LAPACKE_ssysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa: FunctionTypes.LAPACKE_dsysv_aa? = load(name: "LAPACKE_dsysv_aa")
    #elseif os(macOS)
    static let dsysv_aa: FunctionTypes.LAPACKE_dsysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa_work: FunctionTypes.LAPACKE_dsysv_aa_work? = load(name: "LAPACKE_dsysv_aa_work")
    #elseif os(macOS)
    static let dsysv_aa_work: FunctionTypes.LAPACKE_dsysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa: FunctionTypes.LAPACKE_csysv_aa? = load(name: "LAPACKE_csysv_aa")
    #elseif os(macOS)
    static let csysv_aa: FunctionTypes.LAPACKE_csysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa_work: FunctionTypes.LAPACKE_csysv_aa_work? = load(name: "LAPACKE_csysv_aa_work")
    #elseif os(macOS)
    static let csysv_aa_work: FunctionTypes.LAPACKE_csysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa: FunctionTypes.LAPACKE_zsysv_aa? = load(name: "LAPACKE_zsysv_aa")
    #elseif os(macOS)
    static let zsysv_aa: FunctionTypes.LAPACKE_zsysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa_work: FunctionTypes.LAPACKE_zsysv_aa_work? = load(name: "LAPACKE_zsysv_aa_work")
    #elseif os(macOS)
    static let zsysv_aa_work: FunctionTypes.LAPACKE_zsysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa: FunctionTypes.LAPACKE_chesv_aa? = load(name: "LAPACKE_chesv_aa")
    #elseif os(macOS)
    static let chesv_aa: FunctionTypes.LAPACKE_chesv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa_work: FunctionTypes.LAPACKE_chesv_aa_work? = load(name: "LAPACKE_chesv_aa_work")
    #elseif os(macOS)
    static let chesv_aa_work: FunctionTypes.LAPACKE_chesv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa: FunctionTypes.LAPACKE_zhesv_aa? = load(name: "LAPACKE_zhesv_aa")
    #elseif os(macOS)
    static let zhesv_aa: FunctionTypes.LAPACKE_zhesv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa_work: FunctionTypes.LAPACKE_zhesv_aa_work? = load(name: "LAPACKE_zhesv_aa_work")
    #elseif os(macOS)
    static let zhesv_aa_work: FunctionTypes.LAPACKE_zhesv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa: FunctionTypes.LAPACKE_ssytrf_aa? = load(name: "LAPACKE_ssytrf_aa")
    #elseif os(macOS)
    static let ssytrf_aa: FunctionTypes.LAPACKE_ssytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa: FunctionTypes.LAPACKE_dsytrf_aa? = load(name: "LAPACKE_dsytrf_aa")
    #elseif os(macOS)
    static let dsytrf_aa: FunctionTypes.LAPACKE_dsytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa: FunctionTypes.LAPACKE_csytrf_aa? = load(name: "LAPACKE_csytrf_aa")
    #elseif os(macOS)
    static let csytrf_aa: FunctionTypes.LAPACKE_csytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa: FunctionTypes.LAPACKE_zsytrf_aa? = load(name: "LAPACKE_zsytrf_aa")
    #elseif os(macOS)
    static let zsytrf_aa: FunctionTypes.LAPACKE_zsytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa: FunctionTypes.LAPACKE_chetrf_aa? = load(name: "LAPACKE_chetrf_aa")
    #elseif os(macOS)
    static let chetrf_aa: FunctionTypes.LAPACKE_chetrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa: FunctionTypes.LAPACKE_zhetrf_aa? = load(name: "LAPACKE_zhetrf_aa")
    #elseif os(macOS)
    static let zhetrf_aa: FunctionTypes.LAPACKE_zhetrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa_work: FunctionTypes.LAPACKE_ssytrf_aa_work? = load(name: "LAPACKE_ssytrf_aa_work")
    #elseif os(macOS)
    static let ssytrf_aa_work: FunctionTypes.LAPACKE_ssytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa_work: FunctionTypes.LAPACKE_dsytrf_aa_work? = load(name: "LAPACKE_dsytrf_aa_work")
    #elseif os(macOS)
    static let dsytrf_aa_work: FunctionTypes.LAPACKE_dsytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa_work: FunctionTypes.LAPACKE_csytrf_aa_work? = load(name: "LAPACKE_csytrf_aa_work")
    #elseif os(macOS)
    static let csytrf_aa_work: FunctionTypes.LAPACKE_csytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa_work: FunctionTypes.LAPACKE_zsytrf_aa_work? = load(name: "LAPACKE_zsytrf_aa_work")
    #elseif os(macOS)
    static let zsytrf_aa_work: FunctionTypes.LAPACKE_zsytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa_work: FunctionTypes.LAPACKE_chetrf_aa_work? = load(name: "LAPACKE_chetrf_aa_work")
    #elseif os(macOS)
    static let chetrf_aa_work: FunctionTypes.LAPACKE_chetrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa_work: FunctionTypes.LAPACKE_zhetrf_aa_work? = load(name: "LAPACKE_zhetrf_aa_work")
    #elseif os(macOS)
    static let zhetrf_aa_work: FunctionTypes.LAPACKE_zhetrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa: FunctionTypes.LAPACKE_csytrs_aa? = load(name: "LAPACKE_csytrs_aa")
    #elseif os(macOS)
    static let csytrs_aa: FunctionTypes.LAPACKE_csytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa_work: FunctionTypes.LAPACKE_csytrs_aa_work? = load(name: "LAPACKE_csytrs_aa_work")
    #elseif os(macOS)
    static let csytrs_aa_work: FunctionTypes.LAPACKE_csytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa: FunctionTypes.LAPACKE_chetrs_aa? = load(name: "LAPACKE_chetrs_aa")
    #elseif os(macOS)
    static let chetrs_aa: FunctionTypes.LAPACKE_chetrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa_work: FunctionTypes.LAPACKE_chetrs_aa_work? = load(name: "LAPACKE_chetrs_aa_work")
    #elseif os(macOS)
    static let chetrs_aa_work: FunctionTypes.LAPACKE_chetrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa: FunctionTypes.LAPACKE_dsytrs_aa? = load(name: "LAPACKE_dsytrs_aa")
    #elseif os(macOS)
    static let dsytrs_aa: FunctionTypes.LAPACKE_dsytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa_work: FunctionTypes.LAPACKE_dsytrs_aa_work? = load(name: "LAPACKE_dsytrs_aa_work")
    #elseif os(macOS)
    static let dsytrs_aa_work: FunctionTypes.LAPACKE_dsytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa: FunctionTypes.LAPACKE_ssytrs_aa? = load(name: "LAPACKE_ssytrs_aa")
    #elseif os(macOS)
    static let ssytrs_aa: FunctionTypes.LAPACKE_ssytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa_work: FunctionTypes.LAPACKE_ssytrs_aa_work? = load(name: "LAPACKE_ssytrs_aa_work")
    #elseif os(macOS)
    static let ssytrs_aa_work: FunctionTypes.LAPACKE_ssytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa: FunctionTypes.LAPACKE_zsytrs_aa? = load(name: "LAPACKE_zsytrs_aa")
    #elseif os(macOS)
    static let zsytrs_aa: FunctionTypes.LAPACKE_zsytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa_work: FunctionTypes.LAPACKE_zsytrs_aa_work? = load(name: "LAPACKE_zsytrs_aa_work")
    #elseif os(macOS)
    static let zsytrs_aa_work: FunctionTypes.LAPACKE_zsytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa: FunctionTypes.LAPACKE_zhetrs_aa? = load(name: "LAPACKE_zhetrs_aa")
    #elseif os(macOS)
    static let zhetrs_aa: FunctionTypes.LAPACKE_zhetrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa_work: FunctionTypes.LAPACKE_zhetrs_aa_work? = load(name: "LAPACKE_zhetrs_aa_work")
    #elseif os(macOS)
    static let zhetrs_aa_work: FunctionTypes.LAPACKE_zhetrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rk: FunctionTypes.LAPACKE_ssysv_rk? = load(name: "LAPACKE_ssysv_rk")
    #elseif os(macOS)
    static let ssysv_rk: FunctionTypes.LAPACKE_ssysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rk_work: FunctionTypes.LAPACKE_ssysv_rk_work? = load(name: "LAPACKE_ssysv_rk_work")
    #elseif os(macOS)
    static let ssysv_rk_work: FunctionTypes.LAPACKE_ssysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rk: FunctionTypes.LAPACKE_dsysv_rk? = load(name: "LAPACKE_dsysv_rk")
    #elseif os(macOS)
    static let dsysv_rk: FunctionTypes.LAPACKE_dsysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rk_work: FunctionTypes.LAPACKE_dsysv_rk_work? = load(name: "LAPACKE_dsysv_rk_work")
    #elseif os(macOS)
    static let dsysv_rk_work: FunctionTypes.LAPACKE_dsysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rk: FunctionTypes.LAPACKE_csysv_rk? = load(name: "LAPACKE_csysv_rk")
    #elseif os(macOS)
    static let csysv_rk: FunctionTypes.LAPACKE_csysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rk_work: FunctionTypes.LAPACKE_csysv_rk_work? = load(name: "LAPACKE_csysv_rk_work")
    #elseif os(macOS)
    static let csysv_rk_work: FunctionTypes.LAPACKE_csysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rk: FunctionTypes.LAPACKE_zsysv_rk? = load(name: "LAPACKE_zsysv_rk")
    #elseif os(macOS)
    static let zsysv_rk: FunctionTypes.LAPACKE_zsysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rk_work: FunctionTypes.LAPACKE_zsysv_rk_work? = load(name: "LAPACKE_zsysv_rk_work")
    #elseif os(macOS)
    static let zsysv_rk_work: FunctionTypes.LAPACKE_zsysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_rk: FunctionTypes.LAPACKE_chesv_rk? = load(name: "LAPACKE_chesv_rk")
    #elseif os(macOS)
    static let chesv_rk: FunctionTypes.LAPACKE_chesv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_rk_work: FunctionTypes.LAPACKE_chesv_rk_work? = load(name: "LAPACKE_chesv_rk_work")
    #elseif os(macOS)
    static let chesv_rk_work: FunctionTypes.LAPACKE_chesv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_rk: FunctionTypes.LAPACKE_zhesv_rk? = load(name: "LAPACKE_zhesv_rk")
    #elseif os(macOS)
    static let zhesv_rk: FunctionTypes.LAPACKE_zhesv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_rk_work: FunctionTypes.LAPACKE_zhesv_rk_work? = load(name: "LAPACKE_zhesv_rk_work")
    #elseif os(macOS)
    static let zhesv_rk_work: FunctionTypes.LAPACKE_zhesv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rk: FunctionTypes.LAPACKE_ssytrf_rk? = load(name: "LAPACKE_ssytrf_rk")
    #elseif os(macOS)
    static let ssytrf_rk: FunctionTypes.LAPACKE_ssytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rk: FunctionTypes.LAPACKE_dsytrf_rk? = load(name: "LAPACKE_dsytrf_rk")
    #elseif os(macOS)
    static let dsytrf_rk: FunctionTypes.LAPACKE_dsytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rk: FunctionTypes.LAPACKE_csytrf_rk? = load(name: "LAPACKE_csytrf_rk")
    #elseif os(macOS)
    static let csytrf_rk: FunctionTypes.LAPACKE_csytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rk: FunctionTypes.LAPACKE_zsytrf_rk? = load(name: "LAPACKE_zsytrf_rk")
    #elseif os(macOS)
    static let zsytrf_rk: FunctionTypes.LAPACKE_zsytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rk: FunctionTypes.LAPACKE_chetrf_rk? = load(name: "LAPACKE_chetrf_rk")
    #elseif os(macOS)
    static let chetrf_rk: FunctionTypes.LAPACKE_chetrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rk: FunctionTypes.LAPACKE_zhetrf_rk? = load(name: "LAPACKE_zhetrf_rk")
    #elseif os(macOS)
    static let zhetrf_rk: FunctionTypes.LAPACKE_zhetrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rk_work: FunctionTypes.LAPACKE_ssytrf_rk_work? = load(name: "LAPACKE_ssytrf_rk_work")
    #elseif os(macOS)
    static let ssytrf_rk_work: FunctionTypes.LAPACKE_ssytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rk_work: FunctionTypes.LAPACKE_dsytrf_rk_work? = load(name: "LAPACKE_dsytrf_rk_work")
    #elseif os(macOS)
    static let dsytrf_rk_work: FunctionTypes.LAPACKE_dsytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rk_work: FunctionTypes.LAPACKE_csytrf_rk_work? = load(name: "LAPACKE_csytrf_rk_work")
    #elseif os(macOS)
    static let csytrf_rk_work: FunctionTypes.LAPACKE_csytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rk_work: FunctionTypes.LAPACKE_zsytrf_rk_work? = load(name: "LAPACKE_zsytrf_rk_work")
    #elseif os(macOS)
    static let zsytrf_rk_work: FunctionTypes.LAPACKE_zsytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rk_work: FunctionTypes.LAPACKE_chetrf_rk_work? = load(name: "LAPACKE_chetrf_rk_work")
    #elseif os(macOS)
    static let chetrf_rk_work: FunctionTypes.LAPACKE_chetrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rk_work: FunctionTypes.LAPACKE_zhetrf_rk_work? = load(name: "LAPACKE_zhetrf_rk_work")
    #elseif os(macOS)
    static let zhetrf_rk_work: FunctionTypes.LAPACKE_zhetrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_3: FunctionTypes.LAPACKE_csytrs_3? = load(name: "LAPACKE_csytrs_3")
    #elseif os(macOS)
    static let csytrs_3: FunctionTypes.LAPACKE_csytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_3_work: FunctionTypes.LAPACKE_csytrs_3_work? = load(name: "LAPACKE_csytrs_3_work")
    #elseif os(macOS)
    static let csytrs_3_work: FunctionTypes.LAPACKE_csytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_3: FunctionTypes.LAPACKE_chetrs_3? = load(name: "LAPACKE_chetrs_3")
    #elseif os(macOS)
    static let chetrs_3: FunctionTypes.LAPACKE_chetrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_3_work: FunctionTypes.LAPACKE_chetrs_3_work? = load(name: "LAPACKE_chetrs_3_work")
    #elseif os(macOS)
    static let chetrs_3_work: FunctionTypes.LAPACKE_chetrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_3: FunctionTypes.LAPACKE_dsytrs_3? = load(name: "LAPACKE_dsytrs_3")
    #elseif os(macOS)
    static let dsytrs_3: FunctionTypes.LAPACKE_dsytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_3_work: FunctionTypes.LAPACKE_dsytrs_3_work? = load(name: "LAPACKE_dsytrs_3_work")
    #elseif os(macOS)
    static let dsytrs_3_work: FunctionTypes.LAPACKE_dsytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_3: FunctionTypes.LAPACKE_ssytrs_3? = load(name: "LAPACKE_ssytrs_3")
    #elseif os(macOS)
    static let ssytrs_3: FunctionTypes.LAPACKE_ssytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_3_work: FunctionTypes.LAPACKE_ssytrs_3_work? = load(name: "LAPACKE_ssytrs_3_work")
    #elseif os(macOS)
    static let ssytrs_3_work: FunctionTypes.LAPACKE_ssytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_3: FunctionTypes.LAPACKE_zsytrs_3? = load(name: "LAPACKE_zsytrs_3")
    #elseif os(macOS)
    static let zsytrs_3: FunctionTypes.LAPACKE_zsytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_3_work: FunctionTypes.LAPACKE_zsytrs_3_work? = load(name: "LAPACKE_zsytrs_3_work")
    #elseif os(macOS)
    static let zsytrs_3_work: FunctionTypes.LAPACKE_zsytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_3: FunctionTypes.LAPACKE_zhetrs_3? = load(name: "LAPACKE_zhetrs_3")
    #elseif os(macOS)
    static let zhetrs_3: FunctionTypes.LAPACKE_zhetrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_3_work: FunctionTypes.LAPACKE_zhetrs_3_work? = load(name: "LAPACKE_zhetrs_3_work")
    #elseif os(macOS)
    static let zhetrs_3_work: FunctionTypes.LAPACKE_zhetrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri_3: FunctionTypes.LAPACKE_ssytri_3? = load(name: "LAPACKE_ssytri_3")
    #elseif os(macOS)
    static let ssytri_3: FunctionTypes.LAPACKE_ssytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri_3: FunctionTypes.LAPACKE_dsytri_3? = load(name: "LAPACKE_dsytri_3")
    #elseif os(macOS)
    static let dsytri_3: FunctionTypes.LAPACKE_dsytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri_3: FunctionTypes.LAPACKE_csytri_3? = load(name: "LAPACKE_csytri_3")
    #elseif os(macOS)
    static let csytri_3: FunctionTypes.LAPACKE_csytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri_3: FunctionTypes.LAPACKE_zsytri_3? = load(name: "LAPACKE_zsytri_3")
    #elseif os(macOS)
    static let zsytri_3: FunctionTypes.LAPACKE_zsytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri_3: FunctionTypes.LAPACKE_chetri_3? = load(name: "LAPACKE_chetri_3")
    #elseif os(macOS)
    static let chetri_3: FunctionTypes.LAPACKE_chetri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri_3: FunctionTypes.LAPACKE_zhetri_3? = load(name: "LAPACKE_zhetri_3")
    #elseif os(macOS)
    static let zhetri_3: FunctionTypes.LAPACKE_zhetri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri_3_work: FunctionTypes.LAPACKE_ssytri_3_work? = load(name: "LAPACKE_ssytri_3_work")
    #elseif os(macOS)
    static let ssytri_3_work: FunctionTypes.LAPACKE_ssytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri_3_work: FunctionTypes.LAPACKE_dsytri_3_work? = load(name: "LAPACKE_dsytri_3_work")
    #elseif os(macOS)
    static let dsytri_3_work: FunctionTypes.LAPACKE_dsytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri_3_work: FunctionTypes.LAPACKE_csytri_3_work? = load(name: "LAPACKE_csytri_3_work")
    #elseif os(macOS)
    static let csytri_3_work: FunctionTypes.LAPACKE_csytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri_3_work: FunctionTypes.LAPACKE_zsytri_3_work? = load(name: "LAPACKE_zsytri_3_work")
    #elseif os(macOS)
    static let zsytri_3_work: FunctionTypes.LAPACKE_zsytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri_3_work: FunctionTypes.LAPACKE_chetri_3_work? = load(name: "LAPACKE_chetri_3_work")
    #elseif os(macOS)
    static let chetri_3_work: FunctionTypes.LAPACKE_chetri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri_3_work: FunctionTypes.LAPACKE_zhetri_3_work? = load(name: "LAPACKE_zhetri_3_work")
    #elseif os(macOS)
    static let zhetri_3_work: FunctionTypes.LAPACKE_zhetri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon_3: FunctionTypes.LAPACKE_ssycon_3? = load(name: "LAPACKE_ssycon_3")
    #elseif os(macOS)
    static let ssycon_3: FunctionTypes.LAPACKE_ssycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon_3: FunctionTypes.LAPACKE_dsycon_3? = load(name: "LAPACKE_dsycon_3")
    #elseif os(macOS)
    static let dsycon_3: FunctionTypes.LAPACKE_dsycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon_3: FunctionTypes.LAPACKE_csycon_3? = load(name: "LAPACKE_csycon_3")
    #elseif os(macOS)
    static let csycon_3: FunctionTypes.LAPACKE_csycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon_3: FunctionTypes.LAPACKE_zsycon_3? = load(name: "LAPACKE_zsycon_3")
    #elseif os(macOS)
    static let zsycon_3: FunctionTypes.LAPACKE_zsycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon_3: FunctionTypes.LAPACKE_checon_3? = load(name: "LAPACKE_checon_3")
    #elseif os(macOS)
    static let checon_3: FunctionTypes.LAPACKE_checon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon_3: FunctionTypes.LAPACKE_zhecon_3? = load(name: "LAPACKE_zhecon_3")
    #elseif os(macOS)
    static let zhecon_3: FunctionTypes.LAPACKE_zhecon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon_3_work: FunctionTypes.LAPACKE_ssycon_3_work? = load(name: "LAPACKE_ssycon_3_work")
    #elseif os(macOS)
    static let ssycon_3_work: FunctionTypes.LAPACKE_ssycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon_3_work: FunctionTypes.LAPACKE_dsycon_3_work? = load(name: "LAPACKE_dsycon_3_work")
    #elseif os(macOS)
    static let dsycon_3_work: FunctionTypes.LAPACKE_dsycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon_3_work: FunctionTypes.LAPACKE_csycon_3_work? = load(name: "LAPACKE_csycon_3_work")
    #elseif os(macOS)
    static let csycon_3_work: FunctionTypes.LAPACKE_csycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon_3_work: FunctionTypes.LAPACKE_zsycon_3_work? = load(name: "LAPACKE_zsycon_3_work")
    #elseif os(macOS)
    static let zsycon_3_work: FunctionTypes.LAPACKE_zsycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon_3_work: FunctionTypes.LAPACKE_checon_3_work? = load(name: "LAPACKE_checon_3_work")
    #elseif os(macOS)
    static let checon_3_work: FunctionTypes.LAPACKE_checon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon_3_work: FunctionTypes.LAPACKE_zhecon_3_work? = load(name: "LAPACKE_zhecon_3_work")
    #elseif os(macOS)
    static let zhecon_3_work: FunctionTypes.LAPACKE_zhecon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq: FunctionTypes.LAPACKE_sgelq? = load(name: "LAPACKE_sgelq")
    #elseif os(macOS)
    static let sgelq: FunctionTypes.LAPACKE_sgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq: FunctionTypes.LAPACKE_dgelq? = load(name: "LAPACKE_dgelq")
    #elseif os(macOS)
    static let dgelq: FunctionTypes.LAPACKE_dgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq: FunctionTypes.LAPACKE_cgelq? = load(name: "LAPACKE_cgelq")
    #elseif os(macOS)
    static let cgelq: FunctionTypes.LAPACKE_cgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq: FunctionTypes.LAPACKE_zgelq? = load(name: "LAPACKE_zgelq")
    #elseif os(macOS)
    static let zgelq: FunctionTypes.LAPACKE_zgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq_work: FunctionTypes.LAPACKE_sgelq_work? = load(name: "LAPACKE_sgelq_work")
    #elseif os(macOS)
    static let sgelq_work: FunctionTypes.LAPACKE_sgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq_work: FunctionTypes.LAPACKE_dgelq_work? = load(name: "LAPACKE_dgelq_work")
    #elseif os(macOS)
    static let dgelq_work: FunctionTypes.LAPACKE_dgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq_work: FunctionTypes.LAPACKE_cgelq_work? = load(name: "LAPACKE_cgelq_work")
    #elseif os(macOS)
    static let cgelq_work: FunctionTypes.LAPACKE_cgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq_work: FunctionTypes.LAPACKE_zgelq_work? = load(name: "LAPACKE_zgelq_work")
    #elseif os(macOS)
    static let zgelq_work: FunctionTypes.LAPACKE_zgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemlq: FunctionTypes.LAPACKE_sgemlq? = load(name: "LAPACKE_sgemlq")
    #elseif os(macOS)
    static let sgemlq: FunctionTypes.LAPACKE_sgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemlq: FunctionTypes.LAPACKE_dgemlq? = load(name: "LAPACKE_dgemlq")
    #elseif os(macOS)
    static let dgemlq: FunctionTypes.LAPACKE_dgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemlq: FunctionTypes.LAPACKE_cgemlq? = load(name: "LAPACKE_cgemlq")
    #elseif os(macOS)
    static let cgemlq: FunctionTypes.LAPACKE_cgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemlq: FunctionTypes.LAPACKE_zgemlq? = load(name: "LAPACKE_zgemlq")
    #elseif os(macOS)
    static let zgemlq: FunctionTypes.LAPACKE_zgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemlq_work: FunctionTypes.LAPACKE_sgemlq_work? = load(name: "LAPACKE_sgemlq_work")
    #elseif os(macOS)
    static let sgemlq_work: FunctionTypes.LAPACKE_sgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemlq_work: FunctionTypes.LAPACKE_dgemlq_work? = load(name: "LAPACKE_dgemlq_work")
    #elseif os(macOS)
    static let dgemlq_work: FunctionTypes.LAPACKE_dgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemlq_work: FunctionTypes.LAPACKE_cgemlq_work? = load(name: "LAPACKE_cgemlq_work")
    #elseif os(macOS)
    static let cgemlq_work: FunctionTypes.LAPACKE_cgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemlq_work: FunctionTypes.LAPACKE_zgemlq_work? = load(name: "LAPACKE_zgemlq_work")
    #elseif os(macOS)
    static let zgemlq_work: FunctionTypes.LAPACKE_zgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr: FunctionTypes.LAPACKE_sgeqr? = load(name: "LAPACKE_sgeqr")
    #elseif os(macOS)
    static let sgeqr: FunctionTypes.LAPACKE_sgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr: FunctionTypes.LAPACKE_dgeqr? = load(name: "LAPACKE_dgeqr")
    #elseif os(macOS)
    static let dgeqr: FunctionTypes.LAPACKE_dgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr: FunctionTypes.LAPACKE_cgeqr? = load(name: "LAPACKE_cgeqr")
    #elseif os(macOS)
    static let cgeqr: FunctionTypes.LAPACKE_cgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr: FunctionTypes.LAPACKE_zgeqr? = load(name: "LAPACKE_zgeqr")
    #elseif os(macOS)
    static let zgeqr: FunctionTypes.LAPACKE_zgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr_work: FunctionTypes.LAPACKE_sgeqr_work? = load(name: "LAPACKE_sgeqr_work")
    #elseif os(macOS)
    static let sgeqr_work: FunctionTypes.LAPACKE_sgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr_work: FunctionTypes.LAPACKE_dgeqr_work? = load(name: "LAPACKE_dgeqr_work")
    #elseif os(macOS)
    static let dgeqr_work: FunctionTypes.LAPACKE_dgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr_work: FunctionTypes.LAPACKE_cgeqr_work? = load(name: "LAPACKE_cgeqr_work")
    #elseif os(macOS)
    static let cgeqr_work: FunctionTypes.LAPACKE_cgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr_work: FunctionTypes.LAPACKE_zgeqr_work? = load(name: "LAPACKE_zgeqr_work")
    #elseif os(macOS)
    static let zgeqr_work: FunctionTypes.LAPACKE_zgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqr: FunctionTypes.LAPACKE_sgemqr? = load(name: "LAPACKE_sgemqr")
    #elseif os(macOS)
    static let sgemqr: FunctionTypes.LAPACKE_sgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqr: FunctionTypes.LAPACKE_dgemqr? = load(name: "LAPACKE_dgemqr")
    #elseif os(macOS)
    static let dgemqr: FunctionTypes.LAPACKE_dgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqr: FunctionTypes.LAPACKE_cgemqr? = load(name: "LAPACKE_cgemqr")
    #elseif os(macOS)
    static let cgemqr: FunctionTypes.LAPACKE_cgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqr: FunctionTypes.LAPACKE_zgemqr? = load(name: "LAPACKE_zgemqr")
    #elseif os(macOS)
    static let zgemqr: FunctionTypes.LAPACKE_zgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqr_work: FunctionTypes.LAPACKE_sgemqr_work? = load(name: "LAPACKE_sgemqr_work")
    #elseif os(macOS)
    static let sgemqr_work: FunctionTypes.LAPACKE_sgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqr_work: FunctionTypes.LAPACKE_dgemqr_work? = load(name: "LAPACKE_dgemqr_work")
    #elseif os(macOS)
    static let dgemqr_work: FunctionTypes.LAPACKE_dgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqr_work: FunctionTypes.LAPACKE_cgemqr_work? = load(name: "LAPACKE_cgemqr_work")
    #elseif os(macOS)
    static let cgemqr_work: FunctionTypes.LAPACKE_cgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqr_work: FunctionTypes.LAPACKE_zgemqr_work? = load(name: "LAPACKE_zgemqr_work")
    #elseif os(macOS)
    static let zgemqr_work: FunctionTypes.LAPACKE_zgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsls: FunctionTypes.LAPACKE_sgetsls? = load(name: "LAPACKE_sgetsls")
    #elseif os(macOS)
    static let sgetsls: FunctionTypes.LAPACKE_sgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsls: FunctionTypes.LAPACKE_dgetsls? = load(name: "LAPACKE_dgetsls")
    #elseif os(macOS)
    static let dgetsls: FunctionTypes.LAPACKE_dgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsls: FunctionTypes.LAPACKE_cgetsls? = load(name: "LAPACKE_cgetsls")
    #elseif os(macOS)
    static let cgetsls: FunctionTypes.LAPACKE_cgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsls: FunctionTypes.LAPACKE_zgetsls? = load(name: "LAPACKE_zgetsls")
    #elseif os(macOS)
    static let zgetsls: FunctionTypes.LAPACKE_zgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsls_work: FunctionTypes.LAPACKE_sgetsls_work? = load(name: "LAPACKE_sgetsls_work")
    #elseif os(macOS)
    static let sgetsls_work: FunctionTypes.LAPACKE_sgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsls_work: FunctionTypes.LAPACKE_dgetsls_work? = load(name: "LAPACKE_dgetsls_work")
    #elseif os(macOS)
    static let dgetsls_work: FunctionTypes.LAPACKE_dgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsls_work: FunctionTypes.LAPACKE_cgetsls_work? = load(name: "LAPACKE_cgetsls_work")
    #elseif os(macOS)
    static let cgetsls_work: FunctionTypes.LAPACKE_cgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsls_work: FunctionTypes.LAPACKE_zgetsls_work? = load(name: "LAPACKE_zgetsls_work")
    #elseif os(macOS)
    static let zgetsls_work: FunctionTypes.LAPACKE_zgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsqrhrt: FunctionTypes.LAPACKE_sgetsqrhrt? = load(name: "LAPACKE_sgetsqrhrt")
    #elseif os(macOS)
    static let sgetsqrhrt: FunctionTypes.LAPACKE_sgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsqrhrt: FunctionTypes.LAPACKE_dgetsqrhrt? = load(name: "LAPACKE_dgetsqrhrt")
    #elseif os(macOS)
    static let dgetsqrhrt: FunctionTypes.LAPACKE_dgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsqrhrt: FunctionTypes.LAPACKE_cgetsqrhrt? = load(name: "LAPACKE_cgetsqrhrt")
    #elseif os(macOS)
    static let cgetsqrhrt: FunctionTypes.LAPACKE_cgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsqrhrt: FunctionTypes.LAPACKE_zgetsqrhrt? = load(name: "LAPACKE_zgetsqrhrt")
    #elseif os(macOS)
    static let zgetsqrhrt: FunctionTypes.LAPACKE_zgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsqrhrt_work: FunctionTypes.LAPACKE_sgetsqrhrt_work? = load(name: "LAPACKE_sgetsqrhrt_work")
    #elseif os(macOS)
    static let sgetsqrhrt_work: FunctionTypes.LAPACKE_sgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsqrhrt_work: FunctionTypes.LAPACKE_dgetsqrhrt_work? = load(name: "LAPACKE_dgetsqrhrt_work")
    #elseif os(macOS)
    static let dgetsqrhrt_work: FunctionTypes.LAPACKE_dgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsqrhrt_work: FunctionTypes.LAPACKE_cgetsqrhrt_work? = load(name: "LAPACKE_cgetsqrhrt_work")
    #elseif os(macOS)
    static let cgetsqrhrt_work: FunctionTypes.LAPACKE_cgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsqrhrt_work: FunctionTypes.LAPACKE_zgetsqrhrt_work? = load(name: "LAPACKE_zgetsqrhrt_work")
    #elseif os(macOS)
    static let zgetsqrhrt_work: FunctionTypes.LAPACKE_zgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev_2stage: FunctionTypes.LAPACKE_ssyev_2stage? = load(name: "LAPACKE_ssyev_2stage")
    #elseif os(macOS)
    static let ssyev_2stage: FunctionTypes.LAPACKE_ssyev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev_2stage: FunctionTypes.LAPACKE_dsyev_2stage? = load(name: "LAPACKE_dsyev_2stage")
    #elseif os(macOS)
    static let dsyev_2stage: FunctionTypes.LAPACKE_dsyev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd_2stage: FunctionTypes.LAPACKE_ssyevd_2stage? = load(name: "LAPACKE_ssyevd_2stage")
    #elseif os(macOS)
    static let ssyevd_2stage: FunctionTypes.LAPACKE_ssyevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd_2stage: FunctionTypes.LAPACKE_dsyevd_2stage? = load(name: "LAPACKE_dsyevd_2stage")
    #elseif os(macOS)
    static let dsyevd_2stage: FunctionTypes.LAPACKE_dsyevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr_2stage: FunctionTypes.LAPACKE_ssyevr_2stage? = load(name: "LAPACKE_ssyevr_2stage")
    #elseif os(macOS)
    static let ssyevr_2stage: FunctionTypes.LAPACKE_ssyevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr_2stage: FunctionTypes.LAPACKE_dsyevr_2stage? = load(name: "LAPACKE_dsyevr_2stage")
    #elseif os(macOS)
    static let dsyevr_2stage: FunctionTypes.LAPACKE_dsyevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx_2stage: FunctionTypes.LAPACKE_ssyevx_2stage? = load(name: "LAPACKE_ssyevx_2stage")
    #elseif os(macOS)
    static let ssyevx_2stage: FunctionTypes.LAPACKE_ssyevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx_2stage: FunctionTypes.LAPACKE_dsyevx_2stage? = load(name: "LAPACKE_dsyevx_2stage")
    #elseif os(macOS)
    static let dsyevx_2stage: FunctionTypes.LAPACKE_dsyevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev_2stage_work: FunctionTypes.LAPACKE_ssyev_2stage_work? = load(name: "LAPACKE_ssyev_2stage_work")
    #elseif os(macOS)
    static let ssyev_2stage_work: FunctionTypes.LAPACKE_ssyev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev_2stage_work: FunctionTypes.LAPACKE_dsyev_2stage_work? = load(name: "LAPACKE_dsyev_2stage_work")
    #elseif os(macOS)
    static let dsyev_2stage_work: FunctionTypes.LAPACKE_dsyev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd_2stage_work: FunctionTypes.LAPACKE_ssyevd_2stage_work? = load(name: "LAPACKE_ssyevd_2stage_work")
    #elseif os(macOS)
    static let ssyevd_2stage_work: FunctionTypes.LAPACKE_ssyevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd_2stage_work: FunctionTypes.LAPACKE_dsyevd_2stage_work? = load(name: "LAPACKE_dsyevd_2stage_work")
    #elseif os(macOS)
    static let dsyevd_2stage_work: FunctionTypes.LAPACKE_dsyevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr_2stage_work: FunctionTypes.LAPACKE_ssyevr_2stage_work? = load(name: "LAPACKE_ssyevr_2stage_work")
    #elseif os(macOS)
    static let ssyevr_2stage_work: FunctionTypes.LAPACKE_ssyevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr_2stage_work: FunctionTypes.LAPACKE_dsyevr_2stage_work? = load(name: "LAPACKE_dsyevr_2stage_work")
    #elseif os(macOS)
    static let dsyevr_2stage_work: FunctionTypes.LAPACKE_dsyevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx_2stage_work: FunctionTypes.LAPACKE_ssyevx_2stage_work? = load(name: "LAPACKE_ssyevx_2stage_work")
    #elseif os(macOS)
    static let ssyevx_2stage_work: FunctionTypes.LAPACKE_ssyevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx_2stage_work: FunctionTypes.LAPACKE_dsyevx_2stage_work? = load(name: "LAPACKE_dsyevx_2stage_work")
    #elseif os(macOS)
    static let dsyevx_2stage_work: FunctionTypes.LAPACKE_dsyevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev_2stage: FunctionTypes.LAPACKE_cheev_2stage? = load(name: "LAPACKE_cheev_2stage")
    #elseif os(macOS)
    static let cheev_2stage: FunctionTypes.LAPACKE_cheev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev_2stage: FunctionTypes.LAPACKE_zheev_2stage? = load(name: "LAPACKE_zheev_2stage")
    #elseif os(macOS)
    static let zheev_2stage: FunctionTypes.LAPACKE_zheev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd_2stage: FunctionTypes.LAPACKE_cheevd_2stage? = load(name: "LAPACKE_cheevd_2stage")
    #elseif os(macOS)
    static let cheevd_2stage: FunctionTypes.LAPACKE_cheevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd_2stage: FunctionTypes.LAPACKE_zheevd_2stage? = load(name: "LAPACKE_zheevd_2stage")
    #elseif os(macOS)
    static let zheevd_2stage: FunctionTypes.LAPACKE_zheevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr_2stage: FunctionTypes.LAPACKE_cheevr_2stage? = load(name: "LAPACKE_cheevr_2stage")
    #elseif os(macOS)
    static let cheevr_2stage: FunctionTypes.LAPACKE_cheevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr_2stage: FunctionTypes.LAPACKE_zheevr_2stage? = load(name: "LAPACKE_zheevr_2stage")
    #elseif os(macOS)
    static let zheevr_2stage: FunctionTypes.LAPACKE_zheevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx_2stage: FunctionTypes.LAPACKE_cheevx_2stage? = load(name: "LAPACKE_cheevx_2stage")
    #elseif os(macOS)
    static let cheevx_2stage: FunctionTypes.LAPACKE_cheevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx_2stage: FunctionTypes.LAPACKE_zheevx_2stage? = load(name: "LAPACKE_zheevx_2stage")
    #elseif os(macOS)
    static let zheevx_2stage: FunctionTypes.LAPACKE_zheevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev_2stage_work: FunctionTypes.LAPACKE_cheev_2stage_work? = load(name: "LAPACKE_cheev_2stage_work")
    #elseif os(macOS)
    static let cheev_2stage_work: FunctionTypes.LAPACKE_cheev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev_2stage_work: FunctionTypes.LAPACKE_zheev_2stage_work? = load(name: "LAPACKE_zheev_2stage_work")
    #elseif os(macOS)
    static let zheev_2stage_work: FunctionTypes.LAPACKE_zheev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd_2stage_work: FunctionTypes.LAPACKE_cheevd_2stage_work? = load(name: "LAPACKE_cheevd_2stage_work")
    #elseif os(macOS)
    static let cheevd_2stage_work: FunctionTypes.LAPACKE_cheevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd_2stage_work: FunctionTypes.LAPACKE_zheevd_2stage_work? = load(name: "LAPACKE_zheevd_2stage_work")
    #elseif os(macOS)
    static let zheevd_2stage_work: FunctionTypes.LAPACKE_zheevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr_2stage_work: FunctionTypes.LAPACKE_cheevr_2stage_work? = load(name: "LAPACKE_cheevr_2stage_work")
    #elseif os(macOS)
    static let cheevr_2stage_work: FunctionTypes.LAPACKE_cheevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr_2stage_work: FunctionTypes.LAPACKE_zheevr_2stage_work? = load(name: "LAPACKE_zheevr_2stage_work")
    #elseif os(macOS)
    static let zheevr_2stage_work: FunctionTypes.LAPACKE_zheevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx_2stage_work: FunctionTypes.LAPACKE_cheevx_2stage_work? = load(name: "LAPACKE_cheevx_2stage_work")
    #elseif os(macOS)
    static let cheevx_2stage_work: FunctionTypes.LAPACKE_cheevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx_2stage_work: FunctionTypes.LAPACKE_zheevx_2stage_work? = load(name: "LAPACKE_zheevx_2stage_work")
    #elseif os(macOS)
    static let zheevx_2stage_work: FunctionTypes.LAPACKE_zheevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev_2stage: FunctionTypes.LAPACKE_ssbev_2stage? = load(name: "LAPACKE_ssbev_2stage")
    #elseif os(macOS)
    static let ssbev_2stage: FunctionTypes.LAPACKE_ssbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev_2stage: FunctionTypes.LAPACKE_dsbev_2stage? = load(name: "LAPACKE_dsbev_2stage")
    #elseif os(macOS)
    static let dsbev_2stage: FunctionTypes.LAPACKE_dsbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd_2stage: FunctionTypes.LAPACKE_ssbevd_2stage? = load(name: "LAPACKE_ssbevd_2stage")
    #elseif os(macOS)
    static let ssbevd_2stage: FunctionTypes.LAPACKE_ssbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd_2stage: FunctionTypes.LAPACKE_dsbevd_2stage? = load(name: "LAPACKE_dsbevd_2stage")
    #elseif os(macOS)
    static let dsbevd_2stage: FunctionTypes.LAPACKE_dsbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx_2stage: FunctionTypes.LAPACKE_ssbevx_2stage? = load(name: "LAPACKE_ssbevx_2stage")
    #elseif os(macOS)
    static let ssbevx_2stage: FunctionTypes.LAPACKE_ssbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx_2stage: FunctionTypes.LAPACKE_dsbevx_2stage? = load(name: "LAPACKE_dsbevx_2stage")
    #elseif os(macOS)
    static let dsbevx_2stage: FunctionTypes.LAPACKE_dsbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev_2stage_work: FunctionTypes.LAPACKE_ssbev_2stage_work? = load(name: "LAPACKE_ssbev_2stage_work")
    #elseif os(macOS)
    static let ssbev_2stage_work: FunctionTypes.LAPACKE_ssbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev_2stage_work: FunctionTypes.LAPACKE_dsbev_2stage_work? = load(name: "LAPACKE_dsbev_2stage_work")
    #elseif os(macOS)
    static let dsbev_2stage_work: FunctionTypes.LAPACKE_dsbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd_2stage_work: FunctionTypes.LAPACKE_ssbevd_2stage_work? = load(name: "LAPACKE_ssbevd_2stage_work")
    #elseif os(macOS)
    static let ssbevd_2stage_work: FunctionTypes.LAPACKE_ssbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd_2stage_work: FunctionTypes.LAPACKE_dsbevd_2stage_work? = load(name: "LAPACKE_dsbevd_2stage_work")
    #elseif os(macOS)
    static let dsbevd_2stage_work: FunctionTypes.LAPACKE_dsbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx_2stage_work: FunctionTypes.LAPACKE_ssbevx_2stage_work? = load(name: "LAPACKE_ssbevx_2stage_work")
    #elseif os(macOS)
    static let ssbevx_2stage_work: FunctionTypes.LAPACKE_ssbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx_2stage_work: FunctionTypes.LAPACKE_dsbevx_2stage_work? = load(name: "LAPACKE_dsbevx_2stage_work")
    #elseif os(macOS)
    static let dsbevx_2stage_work: FunctionTypes.LAPACKE_dsbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev_2stage: FunctionTypes.LAPACKE_chbev_2stage? = load(name: "LAPACKE_chbev_2stage")
    #elseif os(macOS)
    static let chbev_2stage: FunctionTypes.LAPACKE_chbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev_2stage: FunctionTypes.LAPACKE_zhbev_2stage? = load(name: "LAPACKE_zhbev_2stage")
    #elseif os(macOS)
    static let zhbev_2stage: FunctionTypes.LAPACKE_zhbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd_2stage: FunctionTypes.LAPACKE_chbevd_2stage? = load(name: "LAPACKE_chbevd_2stage")
    #elseif os(macOS)
    static let chbevd_2stage: FunctionTypes.LAPACKE_chbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd_2stage: FunctionTypes.LAPACKE_zhbevd_2stage? = load(name: "LAPACKE_zhbevd_2stage")
    #elseif os(macOS)
    static let zhbevd_2stage: FunctionTypes.LAPACKE_zhbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx_2stage: FunctionTypes.LAPACKE_chbevx_2stage? = load(name: "LAPACKE_chbevx_2stage")
    #elseif os(macOS)
    static let chbevx_2stage: FunctionTypes.LAPACKE_chbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx_2stage: FunctionTypes.LAPACKE_zhbevx_2stage? = load(name: "LAPACKE_zhbevx_2stage")
    #elseif os(macOS)
    static let zhbevx_2stage: FunctionTypes.LAPACKE_zhbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev_2stage_work: FunctionTypes.LAPACKE_chbev_2stage_work? = load(name: "LAPACKE_chbev_2stage_work")
    #elseif os(macOS)
    static let chbev_2stage_work: FunctionTypes.LAPACKE_chbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev_2stage_work: FunctionTypes.LAPACKE_zhbev_2stage_work? = load(name: "LAPACKE_zhbev_2stage_work")
    #elseif os(macOS)
    static let zhbev_2stage_work: FunctionTypes.LAPACKE_zhbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd_2stage_work: FunctionTypes.LAPACKE_chbevd_2stage_work? = load(name: "LAPACKE_chbevd_2stage_work")
    #elseif os(macOS)
    static let chbevd_2stage_work: FunctionTypes.LAPACKE_chbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd_2stage_work: FunctionTypes.LAPACKE_zhbevd_2stage_work? = load(name: "LAPACKE_zhbevd_2stage_work")
    #elseif os(macOS)
    static let zhbevd_2stage_work: FunctionTypes.LAPACKE_zhbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx_2stage_work: FunctionTypes.LAPACKE_chbevx_2stage_work? = load(name: "LAPACKE_chbevx_2stage_work")
    #elseif os(macOS)
    static let chbevx_2stage_work: FunctionTypes.LAPACKE_chbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx_2stage_work: FunctionTypes.LAPACKE_zhbevx_2stage_work? = load(name: "LAPACKE_zhbevx_2stage_work")
    #elseif os(macOS)
    static let zhbevx_2stage_work: FunctionTypes.LAPACKE_zhbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv_2stage: FunctionTypes.LAPACKE_ssygv_2stage? = load(name: "LAPACKE_ssygv_2stage")
    #elseif os(macOS)
    static let ssygv_2stage: FunctionTypes.LAPACKE_ssygv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv_2stage: FunctionTypes.LAPACKE_dsygv_2stage? = load(name: "LAPACKE_dsygv_2stage")
    #elseif os(macOS)
    static let dsygv_2stage: FunctionTypes.LAPACKE_dsygv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv_2stage_work: FunctionTypes.LAPACKE_ssygv_2stage_work? = load(name: "LAPACKE_ssygv_2stage_work")
    #elseif os(macOS)
    static let ssygv_2stage_work: FunctionTypes.LAPACKE_ssygv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv_2stage_work: FunctionTypes.LAPACKE_dsygv_2stage_work? = load(name: "LAPACKE_dsygv_2stage_work")
    #elseif os(macOS)
    static let dsygv_2stage_work: FunctionTypes.LAPACKE_dsygv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv_2stage: FunctionTypes.LAPACKE_chegv_2stage? = load(name: "LAPACKE_chegv_2stage")
    #elseif os(macOS)
    static let chegv_2stage: FunctionTypes.LAPACKE_chegv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv_2stage: FunctionTypes.LAPACKE_zhegv_2stage? = load(name: "LAPACKE_zhegv_2stage")
    #elseif os(macOS)
    static let zhegv_2stage: FunctionTypes.LAPACKE_zhegv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv_2stage_work: FunctionTypes.LAPACKE_chegv_2stage_work? = load(name: "LAPACKE_chegv_2stage_work")
    #elseif os(macOS)
    static let chegv_2stage_work: FunctionTypes.LAPACKE_chegv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv_2stage_work: FunctionTypes.LAPACKE_zhegv_2stage_work? = load(name: "LAPACKE_zhegv_2stage_work")
    #elseif os(macOS)
    static let zhegv_2stage_work: FunctionTypes.LAPACKE_zhegv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa_2stage: FunctionTypes.LAPACKE_ssysv_aa_2stage? = load(name: "LAPACKE_ssysv_aa_2stage")
    #elseif os(macOS)
    static let ssysv_aa_2stage: FunctionTypes.LAPACKE_ssysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa_2stage_work: FunctionTypes.LAPACKE_ssysv_aa_2stage_work? = load(name: "LAPACKE_ssysv_aa_2stage_work")
    #elseif os(macOS)
    static let ssysv_aa_2stage_work: FunctionTypes.LAPACKE_ssysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa_2stage: FunctionTypes.LAPACKE_dsysv_aa_2stage? = load(name: "LAPACKE_dsysv_aa_2stage")
    #elseif os(macOS)
    static let dsysv_aa_2stage: FunctionTypes.LAPACKE_dsysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa_2stage_work: FunctionTypes.LAPACKE_dsysv_aa_2stage_work? = load(name: "LAPACKE_dsysv_aa_2stage_work")
    #elseif os(macOS)
    static let dsysv_aa_2stage_work: FunctionTypes.LAPACKE_dsysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa_2stage: FunctionTypes.LAPACKE_csysv_aa_2stage? = load(name: "LAPACKE_csysv_aa_2stage")
    #elseif os(macOS)
    static let csysv_aa_2stage: FunctionTypes.LAPACKE_csysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa_2stage_work: FunctionTypes.LAPACKE_csysv_aa_2stage_work? = load(name: "LAPACKE_csysv_aa_2stage_work")
    #elseif os(macOS)
    static let csysv_aa_2stage_work: FunctionTypes.LAPACKE_csysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa_2stage: FunctionTypes.LAPACKE_zsysv_aa_2stage? = load(name: "LAPACKE_zsysv_aa_2stage")
    #elseif os(macOS)
    static let zsysv_aa_2stage: FunctionTypes.LAPACKE_zsysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa_2stage_work: FunctionTypes.LAPACKE_zsysv_aa_2stage_work? = load(name: "LAPACKE_zsysv_aa_2stage_work")
    #elseif os(macOS)
    static let zsysv_aa_2stage_work: FunctionTypes.LAPACKE_zsysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa_2stage: FunctionTypes.LAPACKE_chesv_aa_2stage? = load(name: "LAPACKE_chesv_aa_2stage")
    #elseif os(macOS)
    static let chesv_aa_2stage: FunctionTypes.LAPACKE_chesv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa_2stage_work: FunctionTypes.LAPACKE_chesv_aa_2stage_work? = load(name: "LAPACKE_chesv_aa_2stage_work")
    #elseif os(macOS)
    static let chesv_aa_2stage_work: FunctionTypes.LAPACKE_chesv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa_2stage: FunctionTypes.LAPACKE_zhesv_aa_2stage? = load(name: "LAPACKE_zhesv_aa_2stage")
    #elseif os(macOS)
    static let zhesv_aa_2stage: FunctionTypes.LAPACKE_zhesv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa_2stage_work: FunctionTypes.LAPACKE_zhesv_aa_2stage_work? = load(name: "LAPACKE_zhesv_aa_2stage_work")
    #elseif os(macOS)
    static let zhesv_aa_2stage_work: FunctionTypes.LAPACKE_zhesv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa_2stage: FunctionTypes.LAPACKE_ssytrf_aa_2stage? = load(name: "LAPACKE_ssytrf_aa_2stage")
    #elseif os(macOS)
    static let ssytrf_aa_2stage: FunctionTypes.LAPACKE_ssytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa_2stage_work: FunctionTypes.LAPACKE_ssytrf_aa_2stage_work? = load(name: "LAPACKE_ssytrf_aa_2stage_work")
    #elseif os(macOS)
    static let ssytrf_aa_2stage_work: FunctionTypes.LAPACKE_ssytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa_2stage: FunctionTypes.LAPACKE_dsytrf_aa_2stage? = load(name: "LAPACKE_dsytrf_aa_2stage")
    #elseif os(macOS)
    static let dsytrf_aa_2stage: FunctionTypes.LAPACKE_dsytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa_2stage_work: FunctionTypes.LAPACKE_dsytrf_aa_2stage_work? = load(name: "LAPACKE_dsytrf_aa_2stage_work")
    #elseif os(macOS)
    static let dsytrf_aa_2stage_work: FunctionTypes.LAPACKE_dsytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa_2stage: FunctionTypes.LAPACKE_csytrf_aa_2stage? = load(name: "LAPACKE_csytrf_aa_2stage")
    #elseif os(macOS)
    static let csytrf_aa_2stage: FunctionTypes.LAPACKE_csytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa_2stage_work: FunctionTypes.LAPACKE_csytrf_aa_2stage_work? = load(name: "LAPACKE_csytrf_aa_2stage_work")
    #elseif os(macOS)
    static let csytrf_aa_2stage_work: FunctionTypes.LAPACKE_csytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa_2stage: FunctionTypes.LAPACKE_zsytrf_aa_2stage? = load(name: "LAPACKE_zsytrf_aa_2stage")
    #elseif os(macOS)
    static let zsytrf_aa_2stage: FunctionTypes.LAPACKE_zsytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa_2stage_work: FunctionTypes.LAPACKE_zsytrf_aa_2stage_work? = load(name: "LAPACKE_zsytrf_aa_2stage_work")
    #elseif os(macOS)
    static let zsytrf_aa_2stage_work: FunctionTypes.LAPACKE_zsytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa_2stage: FunctionTypes.LAPACKE_chetrf_aa_2stage? = load(name: "LAPACKE_chetrf_aa_2stage")
    #elseif os(macOS)
    static let chetrf_aa_2stage: FunctionTypes.LAPACKE_chetrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa_2stage_work: FunctionTypes.LAPACKE_chetrf_aa_2stage_work? = load(name: "LAPACKE_chetrf_aa_2stage_work")
    #elseif os(macOS)
    static let chetrf_aa_2stage_work: FunctionTypes.LAPACKE_chetrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa_2stage: FunctionTypes.LAPACKE_zhetrf_aa_2stage? = load(name: "LAPACKE_zhetrf_aa_2stage")
    #elseif os(macOS)
    static let zhetrf_aa_2stage: FunctionTypes.LAPACKE_zhetrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa_2stage_work: FunctionTypes.LAPACKE_zhetrf_aa_2stage_work? = load(name: "LAPACKE_zhetrf_aa_2stage_work")
    #elseif os(macOS)
    static let zhetrf_aa_2stage_work: FunctionTypes.LAPACKE_zhetrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa_2stage: FunctionTypes.LAPACKE_ssytrs_aa_2stage? = load(name: "LAPACKE_ssytrs_aa_2stage")
    #elseif os(macOS)
    static let ssytrs_aa_2stage: FunctionTypes.LAPACKE_ssytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa_2stage_work: FunctionTypes.LAPACKE_ssytrs_aa_2stage_work? = load(name: "LAPACKE_ssytrs_aa_2stage_work")
    #elseif os(macOS)
    static let ssytrs_aa_2stage_work: FunctionTypes.LAPACKE_ssytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa_2stage: FunctionTypes.LAPACKE_dsytrs_aa_2stage? = load(name: "LAPACKE_dsytrs_aa_2stage")
    #elseif os(macOS)
    static let dsytrs_aa_2stage: FunctionTypes.LAPACKE_dsytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa_2stage_work: FunctionTypes.LAPACKE_dsytrs_aa_2stage_work? = load(name: "LAPACKE_dsytrs_aa_2stage_work")
    #elseif os(macOS)
    static let dsytrs_aa_2stage_work: FunctionTypes.LAPACKE_dsytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa_2stage: FunctionTypes.LAPACKE_csytrs_aa_2stage? = load(name: "LAPACKE_csytrs_aa_2stage")
    #elseif os(macOS)
    static let csytrs_aa_2stage: FunctionTypes.LAPACKE_csytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa_2stage_work: FunctionTypes.LAPACKE_csytrs_aa_2stage_work? = load(name: "LAPACKE_csytrs_aa_2stage_work")
    #elseif os(macOS)
    static let csytrs_aa_2stage_work: FunctionTypes.LAPACKE_csytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa_2stage: FunctionTypes.LAPACKE_zsytrs_aa_2stage? = load(name: "LAPACKE_zsytrs_aa_2stage")
    #elseif os(macOS)
    static let zsytrs_aa_2stage: FunctionTypes.LAPACKE_zsytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa_2stage_work: FunctionTypes.LAPACKE_zsytrs_aa_2stage_work? = load(name: "LAPACKE_zsytrs_aa_2stage_work")
    #elseif os(macOS)
    static let zsytrs_aa_2stage_work: FunctionTypes.LAPACKE_zsytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa_2stage: FunctionTypes.LAPACKE_chetrs_aa_2stage? = load(name: "LAPACKE_chetrs_aa_2stage")
    #elseif os(macOS)
    static let chetrs_aa_2stage: FunctionTypes.LAPACKE_chetrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa_2stage_work: FunctionTypes.LAPACKE_chetrs_aa_2stage_work? = load(name: "LAPACKE_chetrs_aa_2stage_work")
    #elseif os(macOS)
    static let chetrs_aa_2stage_work: FunctionTypes.LAPACKE_chetrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa_2stage: FunctionTypes.LAPACKE_zhetrs_aa_2stage? = load(name: "LAPACKE_zhetrs_aa_2stage")
    #elseif os(macOS)
    static let zhetrs_aa_2stage: FunctionTypes.LAPACKE_zhetrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa_2stage_work: FunctionTypes.LAPACKE_zhetrs_aa_2stage_work? = load(name: "LAPACKE_zhetrs_aa_2stage_work")
    #elseif os(macOS)
    static let zhetrs_aa_2stage_work: FunctionTypes.LAPACKE_zhetrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorhr_col: FunctionTypes.LAPACKE_sorhr_col? = load(name: "LAPACKE_sorhr_col")
    #elseif os(macOS)
    static let sorhr_col: FunctionTypes.LAPACKE_sorhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorhr_col_work: FunctionTypes.LAPACKE_sorhr_col_work? = load(name: "LAPACKE_sorhr_col_work")
    #elseif os(macOS)
    static let sorhr_col_work: FunctionTypes.LAPACKE_sorhr_col_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorhr_col: FunctionTypes.LAPACKE_dorhr_col? = load(name: "LAPACKE_dorhr_col")
    #elseif os(macOS)
    static let dorhr_col: FunctionTypes.LAPACKE_dorhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorhr_col_work: FunctionTypes.LAPACKE_dorhr_col_work? = load(name: "LAPACKE_dorhr_col_work")
    #elseif os(macOS)
    static let dorhr_col_work: FunctionTypes.LAPACKE_dorhr_col_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunhr_col: FunctionTypes.LAPACKE_cunhr_col? = load(name: "LAPACKE_cunhr_col")
    #elseif os(macOS)
    static let cunhr_col: FunctionTypes.LAPACKE_cunhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunhr_col_work: FunctionTypes.LAPACKE_cunhr_col_work? = load(name: "LAPACKE_cunhr_col_work")
    #elseif os(macOS)
    static let cunhr_col_work: FunctionTypes.LAPACKE_cunhr_col_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunhr_col: FunctionTypes.LAPACKE_zunhr_col? = load(name: "LAPACKE_zunhr_col")
    #elseif os(macOS)
    static let zunhr_col: FunctionTypes.LAPACKE_zunhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunhr_col_work: FunctionTypes.LAPACKE_zunhr_col_work? = load(name: "LAPACKE_zunhr_col_work")
    #elseif os(macOS)
    static let zunhr_col_work: FunctionTypes.LAPACKE_zunhr_col_work? = nil
    #endif
}
