//
//  LAPACKE.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 24.4.2025.
//

#if canImport(DynamicCLAPACK)
import DynamicCLAPACK
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
    internal static func load<T>(name: String, as type: T.Type) -> T? {
        loadSymbol(name: name, handle: handle)
    }
#elseif os(Linux)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type) -> T? {
        if let symbol = loadSymbol(name:name, handle: blasHandle, as: type) { return symbol }
        if let symbol = loadSymbol(name: name, handle: lapackeHandle, as: type) { return symbol }
        return nil
    }
#endif
}

public extension LAPACKE {
    #if os(Windows) || os(Linux)
    static let sbdsdc: FunctionType.LAPACKE_sbdsdc? = load(name: "LAPACKE_sbdsdc", as: FunctionType.LAPACKE_sbdsdc.self)
    #elseif os(macOS)
    static let sbdsdc: FunctionType.LAPACKE_sbdsdc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsdc: FunctionType.LAPACKE_dbdsdc? = load(name: "LAPACKE_dbdsdc", as: FunctionType.LAPACKE_dbdsdc.self)
    #elseif os(macOS)
    static let dbdsdc: FunctionType.LAPACKE_dbdsdc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsqr: FunctionType.LAPACKE_sbdsqr? = load(name: "LAPACKE_sbdsqr", as: FunctionType.LAPACKE_sbdsqr.self)
    #elseif os(macOS)
    static let sbdsqr: FunctionType.LAPACKE_sbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsqr: FunctionType.LAPACKE_dbdsqr? = load(name: "LAPACKE_dbdsqr", as: FunctionType.LAPACKE_dbdsqr.self)
    #elseif os(macOS)
    static let dbdsqr: FunctionType.LAPACKE_dbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbdsqr: FunctionType.LAPACKE_cbdsqr? = load(name: "LAPACKE_cbdsqr", as: FunctionType.LAPACKE_cbdsqr.self)
    #elseif os(macOS)
    static let cbdsqr: FunctionType.LAPACKE_cbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbdsqr: FunctionType.LAPACKE_zbdsqr? = load(name: "LAPACKE_zbdsqr", as: FunctionType.LAPACKE_zbdsqr.self)
    #elseif os(macOS)
    static let zbdsqr: FunctionType.LAPACKE_zbdsqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsvdx: FunctionType.LAPACKE_sbdsvdx? = load(name: "LAPACKE_sbdsvdx", as: FunctionType.LAPACKE_sbdsvdx.self)
    #elseif os(macOS)
    static let sbdsvdx: FunctionType.LAPACKE_sbdsvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsvdx: FunctionType.LAPACKE_dbdsvdx? = load(name: "LAPACKE_dbdsvdx", as: FunctionType.LAPACKE_dbdsvdx.self)
    #elseif os(macOS)
    static let dbdsvdx: FunctionType.LAPACKE_dbdsvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sdisna: FunctionType.LAPACKE_sdisna? = load(name: "LAPACKE_sdisna", as: FunctionType.LAPACKE_sdisna.self)
    #elseif os(macOS)
    static let sdisna: FunctionType.LAPACKE_sdisna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ddisna: FunctionType.LAPACKE_ddisna? = load(name: "LAPACKE_ddisna", as: FunctionType.LAPACKE_ddisna.self)
    #elseif os(macOS)
    static let ddisna: FunctionType.LAPACKE_ddisna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbbrd: FunctionType.LAPACKE_sgbbrd? = load(name: "LAPACKE_sgbbrd", as: FunctionType.LAPACKE_sgbbrd.self)
    #elseif os(macOS)
    static let sgbbrd: FunctionType.LAPACKE_sgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbbrd: FunctionType.LAPACKE_dgbbrd? = load(name: "LAPACKE_dgbbrd", as: FunctionType.LAPACKE_dgbbrd.self)
    #elseif os(macOS)
    static let dgbbrd: FunctionType.LAPACKE_dgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbbrd: FunctionType.LAPACKE_cgbbrd? = load(name: "LAPACKE_cgbbrd", as: FunctionType.LAPACKE_cgbbrd.self)
    #elseif os(macOS)
    static let cgbbrd: FunctionType.LAPACKE_cgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbbrd: FunctionType.LAPACKE_zgbbrd? = load(name: "LAPACKE_zgbbrd", as: FunctionType.LAPACKE_zgbbrd.self)
    #elseif os(macOS)
    static let zgbbrd: FunctionType.LAPACKE_zgbbrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbcon: FunctionType.LAPACKE_sgbcon? = load(name: "LAPACKE_sgbcon", as: FunctionType.LAPACKE_sgbcon.self)
    #elseif os(macOS)
    static let sgbcon: FunctionType.LAPACKE_sgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbcon: FunctionType.LAPACKE_dgbcon? = load(name: "LAPACKE_dgbcon", as: FunctionType.LAPACKE_dgbcon.self)
    #elseif os(macOS)
    static let dgbcon: FunctionType.LAPACKE_dgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbcon: FunctionType.LAPACKE_cgbcon? = load(name: "LAPACKE_cgbcon", as: FunctionType.LAPACKE_cgbcon.self)
    #elseif os(macOS)
    static let cgbcon: FunctionType.LAPACKE_cgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbcon: FunctionType.LAPACKE_zgbcon? = load(name: "LAPACKE_zgbcon", as: FunctionType.LAPACKE_zgbcon.self)
    #elseif os(macOS)
    static let zgbcon: FunctionType.LAPACKE_zgbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequ: FunctionType.LAPACKE_sgbequ? = load(name: "LAPACKE_sgbequ", as: FunctionType.LAPACKE_sgbequ.self)
    #elseif os(macOS)
    static let sgbequ: FunctionType.LAPACKE_sgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequ: FunctionType.LAPACKE_dgbequ? = load(name: "LAPACKE_dgbequ", as: FunctionType.LAPACKE_dgbequ.self)
    #elseif os(macOS)
    static let dgbequ: FunctionType.LAPACKE_dgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequ: FunctionType.LAPACKE_cgbequ? = load(name: "LAPACKE_cgbequ", as: FunctionType.LAPACKE_cgbequ.self)
    #elseif os(macOS)
    static let cgbequ: FunctionType.LAPACKE_cgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequ: FunctionType.LAPACKE_zgbequ? = load(name: "LAPACKE_zgbequ", as: FunctionType.LAPACKE_zgbequ.self)
    #elseif os(macOS)
    static let zgbequ: FunctionType.LAPACKE_zgbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequb: FunctionType.LAPACKE_sgbequb? = load(name: "LAPACKE_sgbequb", as: FunctionType.LAPACKE_sgbequb.self)
    #elseif os(macOS)
    static let sgbequb: FunctionType.LAPACKE_sgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequb: FunctionType.LAPACKE_dgbequb? = load(name: "LAPACKE_dgbequb", as: FunctionType.LAPACKE_dgbequb.self)
    #elseif os(macOS)
    static let dgbequb: FunctionType.LAPACKE_dgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequb: FunctionType.LAPACKE_cgbequb? = load(name: "LAPACKE_cgbequb", as: FunctionType.LAPACKE_cgbequb.self)
    #elseif os(macOS)
    static let cgbequb: FunctionType.LAPACKE_cgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequb: FunctionType.LAPACKE_zgbequb? = load(name: "LAPACKE_zgbequb", as: FunctionType.LAPACKE_zgbequb.self)
    #elseif os(macOS)
    static let zgbequb: FunctionType.LAPACKE_zgbequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfs: FunctionType.LAPACKE_sgbrfs? = load(name: "LAPACKE_sgbrfs", as: FunctionType.LAPACKE_sgbrfs.self)
    #elseif os(macOS)
    static let sgbrfs: FunctionType.LAPACKE_sgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfs: FunctionType.LAPACKE_dgbrfs? = load(name: "LAPACKE_dgbrfs", as: FunctionType.LAPACKE_dgbrfs.self)
    #elseif os(macOS)
    static let dgbrfs: FunctionType.LAPACKE_dgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfs: FunctionType.LAPACKE_cgbrfs? = load(name: "LAPACKE_cgbrfs", as: FunctionType.LAPACKE_cgbrfs.self)
    #elseif os(macOS)
    static let cgbrfs: FunctionType.LAPACKE_cgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfs: FunctionType.LAPACKE_zgbrfs? = load(name: "LAPACKE_zgbrfs", as: FunctionType.LAPACKE_zgbrfs.self)
    #elseif os(macOS)
    static let zgbrfs: FunctionType.LAPACKE_zgbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfsx: FunctionType.LAPACKE_sgbrfsx? = load(name: "LAPACKE_sgbrfsx", as: FunctionType.LAPACKE_sgbrfsx.self)
    #elseif os(macOS)
    static let sgbrfsx: FunctionType.LAPACKE_sgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfsx: FunctionType.LAPACKE_dgbrfsx? = load(name: "LAPACKE_dgbrfsx", as: FunctionType.LAPACKE_dgbrfsx.self)
    #elseif os(macOS)
    static let dgbrfsx: FunctionType.LAPACKE_dgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfsx: FunctionType.LAPACKE_cgbrfsx? = load(name: "LAPACKE_cgbrfsx", as: FunctionType.LAPACKE_cgbrfsx.self)
    #elseif os(macOS)
    static let cgbrfsx: FunctionType.LAPACKE_cgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfsx: FunctionType.LAPACKE_zgbrfsx? = load(name: "LAPACKE_zgbrfsx", as: FunctionType.LAPACKE_zgbrfsx.self)
    #elseif os(macOS)
    static let zgbrfsx: FunctionType.LAPACKE_zgbrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsv: FunctionType.LAPACKE_sgbsv? = load(name: "LAPACKE_sgbsv", as: FunctionType.LAPACKE_sgbsv.self)
    #elseif os(macOS)
    static let sgbsv: FunctionType.LAPACKE_sgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsv: FunctionType.LAPACKE_dgbsv? = load(name: "LAPACKE_dgbsv", as: FunctionType.LAPACKE_dgbsv.self)
    #elseif os(macOS)
    static let dgbsv: FunctionType.LAPACKE_dgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsv: FunctionType.LAPACKE_cgbsv? = load(name: "LAPACKE_cgbsv", as: FunctionType.LAPACKE_cgbsv.self)
    #elseif os(macOS)
    static let cgbsv: FunctionType.LAPACKE_cgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsv: FunctionType.LAPACKE_zgbsv? = load(name: "LAPACKE_zgbsv", as: FunctionType.LAPACKE_zgbsv.self)
    #elseif os(macOS)
    static let zgbsv: FunctionType.LAPACKE_zgbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvx: FunctionType.LAPACKE_sgbsvx? = load(name: "LAPACKE_sgbsvx", as: FunctionType.LAPACKE_sgbsvx.self)
    #elseif os(macOS)
    static let sgbsvx: FunctionType.LAPACKE_sgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvx: FunctionType.LAPACKE_dgbsvx? = load(name: "LAPACKE_dgbsvx", as: FunctionType.LAPACKE_dgbsvx.self)
    #elseif os(macOS)
    static let dgbsvx: FunctionType.LAPACKE_dgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvx: FunctionType.LAPACKE_cgbsvx? = load(name: "LAPACKE_cgbsvx", as: FunctionType.LAPACKE_cgbsvx.self)
    #elseif os(macOS)
    static let cgbsvx: FunctionType.LAPACKE_cgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvx: FunctionType.LAPACKE_zgbsvx? = load(name: "LAPACKE_zgbsvx", as: FunctionType.LAPACKE_zgbsvx.self)
    #elseif os(macOS)
    static let zgbsvx: FunctionType.LAPACKE_zgbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvxx: FunctionType.LAPACKE_sgbsvxx? = load(name: "LAPACKE_sgbsvxx", as: FunctionType.LAPACKE_sgbsvxx.self)
    #elseif os(macOS)
    static let sgbsvxx: FunctionType.LAPACKE_sgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvxx: FunctionType.LAPACKE_dgbsvxx? = load(name: "LAPACKE_dgbsvxx", as: FunctionType.LAPACKE_dgbsvxx.self)
    #elseif os(macOS)
    static let dgbsvxx: FunctionType.LAPACKE_dgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvxx: FunctionType.LAPACKE_cgbsvxx? = load(name: "LAPACKE_cgbsvxx", as: FunctionType.LAPACKE_cgbsvxx.self)
    #elseif os(macOS)
    static let cgbsvxx: FunctionType.LAPACKE_cgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvxx: FunctionType.LAPACKE_zgbsvxx? = load(name: "LAPACKE_zgbsvxx", as: FunctionType.LAPACKE_zgbsvxx.self)
    #elseif os(macOS)
    static let zgbsvxx: FunctionType.LAPACKE_zgbsvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrf: FunctionType.LAPACKE_sgbtrf? = load(name: "LAPACKE_sgbtrf", as: FunctionType.LAPACKE_sgbtrf.self)
    #elseif os(macOS)
    static let sgbtrf: FunctionType.LAPACKE_sgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrf: FunctionType.LAPACKE_dgbtrf? = load(name: "LAPACKE_dgbtrf", as: FunctionType.LAPACKE_dgbtrf.self)
    #elseif os(macOS)
    static let dgbtrf: FunctionType.LAPACKE_dgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrf: FunctionType.LAPACKE_cgbtrf? = load(name: "LAPACKE_cgbtrf", as: FunctionType.LAPACKE_cgbtrf.self)
    #elseif os(macOS)
    static let cgbtrf: FunctionType.LAPACKE_cgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrf: FunctionType.LAPACKE_zgbtrf? = load(name: "LAPACKE_zgbtrf", as: FunctionType.LAPACKE_zgbtrf.self)
    #elseif os(macOS)
    static let zgbtrf: FunctionType.LAPACKE_zgbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrs: FunctionType.LAPACKE_sgbtrs? = load(name: "LAPACKE_sgbtrs", as: FunctionType.LAPACKE_sgbtrs.self)
    #elseif os(macOS)
    static let sgbtrs: FunctionType.LAPACKE_sgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrs: FunctionType.LAPACKE_dgbtrs? = load(name: "LAPACKE_dgbtrs", as: FunctionType.LAPACKE_dgbtrs.self)
    #elseif os(macOS)
    static let dgbtrs: FunctionType.LAPACKE_dgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrs: FunctionType.LAPACKE_cgbtrs? = load(name: "LAPACKE_cgbtrs", as: FunctionType.LAPACKE_cgbtrs.self)
    #elseif os(macOS)
    static let cgbtrs: FunctionType.LAPACKE_cgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrs: FunctionType.LAPACKE_zgbtrs? = load(name: "LAPACKE_zgbtrs", as: FunctionType.LAPACKE_zgbtrs.self)
    #elseif os(macOS)
    static let zgbtrs: FunctionType.LAPACKE_zgbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebak: FunctionType.LAPACKE_sgebak? = load(name: "LAPACKE_sgebak", as: FunctionType.LAPACKE_sgebak.self)
    #elseif os(macOS)
    static let sgebak: FunctionType.LAPACKE_sgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebak: FunctionType.LAPACKE_dgebak? = load(name: "LAPACKE_dgebak", as: FunctionType.LAPACKE_dgebak.self)
    #elseif os(macOS)
    static let dgebak: FunctionType.LAPACKE_dgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebak: FunctionType.LAPACKE_cgebak? = load(name: "LAPACKE_cgebak", as: FunctionType.LAPACKE_cgebak.self)
    #elseif os(macOS)
    static let cgebak: FunctionType.LAPACKE_cgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebak: FunctionType.LAPACKE_zgebak? = load(name: "LAPACKE_zgebak", as: FunctionType.LAPACKE_zgebak.self)
    #elseif os(macOS)
    static let zgebak: FunctionType.LAPACKE_zgebak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebal: FunctionType.LAPACKE_sgebal? = load(name: "LAPACKE_sgebal", as: FunctionType.LAPACKE_sgebal.self)
    #elseif os(macOS)
    static let sgebal: FunctionType.LAPACKE_sgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebal: FunctionType.LAPACKE_dgebal? = load(name: "LAPACKE_dgebal", as: FunctionType.LAPACKE_dgebal.self)
    #elseif os(macOS)
    static let dgebal: FunctionType.LAPACKE_dgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebal: FunctionType.LAPACKE_cgebal? = load(name: "LAPACKE_cgebal", as: FunctionType.LAPACKE_cgebal.self)
    #elseif os(macOS)
    static let cgebal: FunctionType.LAPACKE_cgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebal: FunctionType.LAPACKE_zgebal? = load(name: "LAPACKE_zgebal", as: FunctionType.LAPACKE_zgebal.self)
    #elseif os(macOS)
    static let zgebal: FunctionType.LAPACKE_zgebal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebrd: FunctionType.LAPACKE_sgebrd? = load(name: "LAPACKE_sgebrd", as: FunctionType.LAPACKE_sgebrd.self)
    #elseif os(macOS)
    static let sgebrd: FunctionType.LAPACKE_sgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebrd: FunctionType.LAPACKE_dgebrd? = load(name: "LAPACKE_dgebrd", as: FunctionType.LAPACKE_dgebrd.self)
    #elseif os(macOS)
    static let dgebrd: FunctionType.LAPACKE_dgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebrd: FunctionType.LAPACKE_cgebrd? = load(name: "LAPACKE_cgebrd", as: FunctionType.LAPACKE_cgebrd.self)
    #elseif os(macOS)
    static let cgebrd: FunctionType.LAPACKE_cgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebrd: FunctionType.LAPACKE_zgebrd? = load(name: "LAPACKE_zgebrd", as: FunctionType.LAPACKE_zgebrd.self)
    #elseif os(macOS)
    static let zgebrd: FunctionType.LAPACKE_zgebrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgecon: FunctionType.LAPACKE_sgecon? = load(name: "LAPACKE_sgecon", as: FunctionType.LAPACKE_sgecon.self)
    #elseif os(macOS)
    static let sgecon: FunctionType.LAPACKE_sgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgecon: FunctionType.LAPACKE_dgecon? = load(name: "LAPACKE_dgecon", as: FunctionType.LAPACKE_dgecon.self)
    #elseif os(macOS)
    static let dgecon: FunctionType.LAPACKE_dgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgecon: FunctionType.LAPACKE_cgecon? = load(name: "LAPACKE_cgecon", as: FunctionType.LAPACKE_cgecon.self)
    #elseif os(macOS)
    static let cgecon: FunctionType.LAPACKE_cgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgecon: FunctionType.LAPACKE_zgecon? = load(name: "LAPACKE_zgecon", as: FunctionType.LAPACKE_zgecon.self)
    #elseif os(macOS)
    static let zgecon: FunctionType.LAPACKE_zgecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequ: FunctionType.LAPACKE_sgeequ? = load(name: "LAPACKE_sgeequ", as: FunctionType.LAPACKE_sgeequ.self)
    #elseif os(macOS)
    static let sgeequ: FunctionType.LAPACKE_sgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequ: FunctionType.LAPACKE_dgeequ? = load(name: "LAPACKE_dgeequ", as: FunctionType.LAPACKE_dgeequ.self)
    #elseif os(macOS)
    static let dgeequ: FunctionType.LAPACKE_dgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequ: FunctionType.LAPACKE_cgeequ? = load(name: "LAPACKE_cgeequ", as: FunctionType.LAPACKE_cgeequ.self)
    #elseif os(macOS)
    static let cgeequ: FunctionType.LAPACKE_cgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequ: FunctionType.LAPACKE_zgeequ? = load(name: "LAPACKE_zgeequ", as: FunctionType.LAPACKE_zgeequ.self)
    #elseif os(macOS)
    static let zgeequ: FunctionType.LAPACKE_zgeequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequb: FunctionType.LAPACKE_sgeequb? = load(name: "LAPACKE_sgeequb", as: FunctionType.LAPACKE_sgeequb.self)
    #elseif os(macOS)
    static let sgeequb: FunctionType.LAPACKE_sgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequb: FunctionType.LAPACKE_dgeequb? = load(name: "LAPACKE_dgeequb", as: FunctionType.LAPACKE_dgeequb.self)
    #elseif os(macOS)
    static let dgeequb: FunctionType.LAPACKE_dgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequb: FunctionType.LAPACKE_cgeequb? = load(name: "LAPACKE_cgeequb", as: FunctionType.LAPACKE_cgeequb.self)
    #elseif os(macOS)
    static let cgeequb: FunctionType.LAPACKE_cgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequb: FunctionType.LAPACKE_zgeequb? = load(name: "LAPACKE_zgeequb", as: FunctionType.LAPACKE_zgeequb.self)
    #elseif os(macOS)
    static let zgeequb: FunctionType.LAPACKE_zgeequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgees: FunctionType.LAPACKE_sgees? = load(name: "LAPACKE_sgees", as: FunctionType.LAPACKE_sgees.self)
    #elseif os(macOS)
    static let sgees: FunctionType.LAPACKE_sgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgees: FunctionType.LAPACKE_dgees? = load(name: "LAPACKE_dgees", as: FunctionType.LAPACKE_dgees.self)
    #elseif os(macOS)
    static let dgees: FunctionType.LAPACKE_dgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgees: FunctionType.LAPACKE_cgees? = load(name: "LAPACKE_cgees", as: FunctionType.LAPACKE_cgees.self)
    #elseif os(macOS)
    static let cgees: FunctionType.LAPACKE_cgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgees: FunctionType.LAPACKE_zgees? = load(name: "LAPACKE_zgees", as: FunctionType.LAPACKE_zgees.self)
    #elseif os(macOS)
    static let zgees: FunctionType.LAPACKE_zgees? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeesx: FunctionType.LAPACKE_sgeesx? = load(name: "LAPACKE_sgeesx", as: FunctionType.LAPACKE_sgeesx.self)
    #elseif os(macOS)
    static let sgeesx: FunctionType.LAPACKE_sgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeesx: FunctionType.LAPACKE_dgeesx? = load(name: "LAPACKE_dgeesx", as: FunctionType.LAPACKE_dgeesx.self)
    #elseif os(macOS)
    static let dgeesx: FunctionType.LAPACKE_dgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeesx: FunctionType.LAPACKE_cgeesx? = load(name: "LAPACKE_cgeesx", as: FunctionType.LAPACKE_cgeesx.self)
    #elseif os(macOS)
    static let cgeesx: FunctionType.LAPACKE_cgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeesx: FunctionType.LAPACKE_zgeesx? = load(name: "LAPACKE_zgeesx", as: FunctionType.LAPACKE_zgeesx.self)
    #elseif os(macOS)
    static let zgeesx: FunctionType.LAPACKE_zgeesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeev: FunctionType.LAPACKE_sgeev? = load(name: "LAPACKE_sgeev", as: FunctionType.LAPACKE_sgeev.self)
    #elseif os(macOS)
    static let sgeev: FunctionType.LAPACKE_sgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeev: FunctionType.LAPACKE_dgeev? = load(name: "LAPACKE_dgeev", as: FunctionType.LAPACKE_dgeev.self)
    #elseif os(macOS)
    static let dgeev: FunctionType.LAPACKE_dgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeev: FunctionType.LAPACKE_cgeev? = load(name: "LAPACKE_cgeev", as: FunctionType.LAPACKE_cgeev.self)
    #elseif os(macOS)
    static let cgeev: FunctionType.LAPACKE_cgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeev: FunctionType.LAPACKE_zgeev? = load(name: "LAPACKE_zgeev", as: FunctionType.LAPACKE_zgeev.self)
    #elseif os(macOS)
    static let zgeev: FunctionType.LAPACKE_zgeev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeevx: FunctionType.LAPACKE_sgeevx? = load(name: "LAPACKE_sgeevx", as: FunctionType.LAPACKE_sgeevx.self)
    #elseif os(macOS)
    static let sgeevx: FunctionType.LAPACKE_sgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeevx: FunctionType.LAPACKE_dgeevx? = load(name: "LAPACKE_dgeevx", as: FunctionType.LAPACKE_dgeevx.self)
    #elseif os(macOS)
    static let dgeevx: FunctionType.LAPACKE_dgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeevx: FunctionType.LAPACKE_cgeevx? = load(name: "LAPACKE_cgeevx", as: FunctionType.LAPACKE_cgeevx.self)
    #elseif os(macOS)
    static let cgeevx: FunctionType.LAPACKE_cgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeevx: FunctionType.LAPACKE_zgeevx? = load(name: "LAPACKE_zgeevx", as: FunctionType.LAPACKE_zgeevx.self)
    #elseif os(macOS)
    static let zgeevx: FunctionType.LAPACKE_zgeevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgehrd: FunctionType.LAPACKE_sgehrd? = load(name: "LAPACKE_sgehrd", as: FunctionType.LAPACKE_sgehrd.self)
    #elseif os(macOS)
    static let sgehrd: FunctionType.LAPACKE_sgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgehrd: FunctionType.LAPACKE_dgehrd? = load(name: "LAPACKE_dgehrd", as: FunctionType.LAPACKE_dgehrd.self)
    #elseif os(macOS)
    static let dgehrd: FunctionType.LAPACKE_dgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgehrd: FunctionType.LAPACKE_cgehrd? = load(name: "LAPACKE_cgehrd", as: FunctionType.LAPACKE_cgehrd.self)
    #elseif os(macOS)
    static let cgehrd: FunctionType.LAPACKE_cgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgehrd: FunctionType.LAPACKE_zgehrd? = load(name: "LAPACKE_zgehrd", as: FunctionType.LAPACKE_zgehrd.self)
    #elseif os(macOS)
    static let zgehrd: FunctionType.LAPACKE_zgehrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgejsv: FunctionType.LAPACKE_sgejsv? = load(name: "LAPACKE_sgejsv", as: FunctionType.LAPACKE_sgejsv.self)
    #elseif os(macOS)
    static let sgejsv: FunctionType.LAPACKE_sgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgejsv: FunctionType.LAPACKE_dgejsv? = load(name: "LAPACKE_dgejsv", as: FunctionType.LAPACKE_dgejsv.self)
    #elseif os(macOS)
    static let dgejsv: FunctionType.LAPACKE_dgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgejsv: FunctionType.LAPACKE_cgejsv? = load(name: "LAPACKE_cgejsv", as: FunctionType.LAPACKE_cgejsv.self)
    #elseif os(macOS)
    static let cgejsv: FunctionType.LAPACKE_cgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgejsv: FunctionType.LAPACKE_zgejsv? = load(name: "LAPACKE_zgejsv", as: FunctionType.LAPACKE_zgejsv.self)
    #elseif os(macOS)
    static let zgejsv: FunctionType.LAPACKE_zgejsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq2: FunctionType.LAPACKE_sgelq2? = load(name: "LAPACKE_sgelq2", as: FunctionType.LAPACKE_sgelq2.self)
    #elseif os(macOS)
    static let sgelq2: FunctionType.LAPACKE_sgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq2: FunctionType.LAPACKE_dgelq2? = load(name: "LAPACKE_dgelq2", as: FunctionType.LAPACKE_dgelq2.self)
    #elseif os(macOS)
    static let dgelq2: FunctionType.LAPACKE_dgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq2: FunctionType.LAPACKE_cgelq2? = load(name: "LAPACKE_cgelq2", as: FunctionType.LAPACKE_cgelq2.self)
    #elseif os(macOS)
    static let cgelq2: FunctionType.LAPACKE_cgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq2: FunctionType.LAPACKE_zgelq2? = load(name: "LAPACKE_zgelq2", as: FunctionType.LAPACKE_zgelq2.self)
    #elseif os(macOS)
    static let zgelq2: FunctionType.LAPACKE_zgelq2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelqf: FunctionType.LAPACKE_sgelqf? = load(name: "LAPACKE_sgelqf", as: FunctionType.LAPACKE_sgelqf.self)
    #elseif os(macOS)
    static let sgelqf: FunctionType.LAPACKE_sgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelqf: FunctionType.LAPACKE_dgelqf? = load(name: "LAPACKE_dgelqf", as: FunctionType.LAPACKE_dgelqf.self)
    #elseif os(macOS)
    static let dgelqf: FunctionType.LAPACKE_dgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelqf: FunctionType.LAPACKE_cgelqf? = load(name: "LAPACKE_cgelqf", as: FunctionType.LAPACKE_cgelqf.self)
    #elseif os(macOS)
    static let cgelqf: FunctionType.LAPACKE_cgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelqf: FunctionType.LAPACKE_zgelqf? = load(name: "LAPACKE_zgelqf", as: FunctionType.LAPACKE_zgelqf.self)
    #elseif os(macOS)
    static let zgelqf: FunctionType.LAPACKE_zgelqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgels: FunctionType.LAPACKE_sgels? = load(name: "LAPACKE_sgels", as: FunctionType.LAPACKE_sgels.self)
    #elseif os(macOS)
    static let sgels: FunctionType.LAPACKE_sgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgels: FunctionType.LAPACKE_dgels? = load(name: "LAPACKE_dgels", as: FunctionType.LAPACKE_dgels.self)
    #elseif os(macOS)
    static let dgels: FunctionType.LAPACKE_dgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgels: FunctionType.LAPACKE_cgels? = load(name: "LAPACKE_cgels", as: FunctionType.LAPACKE_cgels.self)
    #elseif os(macOS)
    static let cgels: FunctionType.LAPACKE_cgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgels: FunctionType.LAPACKE_zgels? = load(name: "LAPACKE_zgels", as: FunctionType.LAPACKE_zgels.self)
    #elseif os(macOS)
    static let zgels: FunctionType.LAPACKE_zgels? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsd: FunctionType.LAPACKE_sgelsd? = load(name: "LAPACKE_sgelsd", as: FunctionType.LAPACKE_sgelsd.self)
    #elseif os(macOS)
    static let sgelsd: FunctionType.LAPACKE_sgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsd: FunctionType.LAPACKE_dgelsd? = load(name: "LAPACKE_dgelsd", as: FunctionType.LAPACKE_dgelsd.self)
    #elseif os(macOS)
    static let dgelsd: FunctionType.LAPACKE_dgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsd: FunctionType.LAPACKE_cgelsd? = load(name: "LAPACKE_cgelsd", as: FunctionType.LAPACKE_cgelsd.self)
    #elseif os(macOS)
    static let cgelsd: FunctionType.LAPACKE_cgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsd: FunctionType.LAPACKE_zgelsd? = load(name: "LAPACKE_zgelsd", as: FunctionType.LAPACKE_zgelsd.self)
    #elseif os(macOS)
    static let zgelsd: FunctionType.LAPACKE_zgelsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelss: FunctionType.LAPACKE_sgelss? = load(name: "LAPACKE_sgelss", as: FunctionType.LAPACKE_sgelss.self)
    #elseif os(macOS)
    static let sgelss: FunctionType.LAPACKE_sgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelss: FunctionType.LAPACKE_dgelss? = load(name: "LAPACKE_dgelss", as: FunctionType.LAPACKE_dgelss.self)
    #elseif os(macOS)
    static let dgelss: FunctionType.LAPACKE_dgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelss: FunctionType.LAPACKE_cgelss? = load(name: "LAPACKE_cgelss", as: FunctionType.LAPACKE_cgelss.self)
    #elseif os(macOS)
    static let cgelss: FunctionType.LAPACKE_cgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelss: FunctionType.LAPACKE_zgelss? = load(name: "LAPACKE_zgelss", as: FunctionType.LAPACKE_zgelss.self)
    #elseif os(macOS)
    static let zgelss: FunctionType.LAPACKE_zgelss? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsy: FunctionType.LAPACKE_sgelsy? = load(name: "LAPACKE_sgelsy", as: FunctionType.LAPACKE_sgelsy.self)
    #elseif os(macOS)
    static let sgelsy: FunctionType.LAPACKE_sgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsy: FunctionType.LAPACKE_dgelsy? = load(name: "LAPACKE_dgelsy", as: FunctionType.LAPACKE_dgelsy.self)
    #elseif os(macOS)
    static let dgelsy: FunctionType.LAPACKE_dgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsy: FunctionType.LAPACKE_cgelsy? = load(name: "LAPACKE_cgelsy", as: FunctionType.LAPACKE_cgelsy.self)
    #elseif os(macOS)
    static let cgelsy: FunctionType.LAPACKE_cgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsy: FunctionType.LAPACKE_zgelsy? = load(name: "LAPACKE_zgelsy", as: FunctionType.LAPACKE_zgelsy.self)
    #elseif os(macOS)
    static let zgelsy: FunctionType.LAPACKE_zgelsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqlf: FunctionType.LAPACKE_sgeqlf? = load(name: "LAPACKE_sgeqlf", as: FunctionType.LAPACKE_sgeqlf.self)
    #elseif os(macOS)
    static let sgeqlf: FunctionType.LAPACKE_sgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqlf: FunctionType.LAPACKE_dgeqlf? = load(name: "LAPACKE_dgeqlf", as: FunctionType.LAPACKE_dgeqlf.self)
    #elseif os(macOS)
    static let dgeqlf: FunctionType.LAPACKE_dgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqlf: FunctionType.LAPACKE_cgeqlf? = load(name: "LAPACKE_cgeqlf", as: FunctionType.LAPACKE_cgeqlf.self)
    #elseif os(macOS)
    static let cgeqlf: FunctionType.LAPACKE_cgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqlf: FunctionType.LAPACKE_zgeqlf? = load(name: "LAPACKE_zgeqlf", as: FunctionType.LAPACKE_zgeqlf.self)
    #elseif os(macOS)
    static let zgeqlf: FunctionType.LAPACKE_zgeqlf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqp3: FunctionType.LAPACKE_sgeqp3? = load(name: "LAPACKE_sgeqp3", as: FunctionType.LAPACKE_sgeqp3.self)
    #elseif os(macOS)
    static let sgeqp3: FunctionType.LAPACKE_sgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqp3: FunctionType.LAPACKE_dgeqp3? = load(name: "LAPACKE_dgeqp3", as: FunctionType.LAPACKE_dgeqp3.self)
    #elseif os(macOS)
    static let dgeqp3: FunctionType.LAPACKE_dgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqp3: FunctionType.LAPACKE_cgeqp3? = load(name: "LAPACKE_cgeqp3", as: FunctionType.LAPACKE_cgeqp3.self)
    #elseif os(macOS)
    static let cgeqp3: FunctionType.LAPACKE_cgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqp3: FunctionType.LAPACKE_zgeqp3? = load(name: "LAPACKE_zgeqp3", as: FunctionType.LAPACKE_zgeqp3.self)
    #elseif os(macOS)
    static let zgeqp3: FunctionType.LAPACKE_zgeqp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqpf: FunctionType.LAPACKE_sgeqpf? = load(name: "LAPACKE_sgeqpf", as: FunctionType.LAPACKE_sgeqpf.self)
    #elseif os(macOS)
    static let sgeqpf: FunctionType.LAPACKE_sgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqpf: FunctionType.LAPACKE_dgeqpf? = load(name: "LAPACKE_dgeqpf", as: FunctionType.LAPACKE_dgeqpf.self)
    #elseif os(macOS)
    static let dgeqpf: FunctionType.LAPACKE_dgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqpf: FunctionType.LAPACKE_cgeqpf? = load(name: "LAPACKE_cgeqpf", as: FunctionType.LAPACKE_cgeqpf.self)
    #elseif os(macOS)
    static let cgeqpf: FunctionType.LAPACKE_cgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqpf: FunctionType.LAPACKE_zgeqpf? = load(name: "LAPACKE_zgeqpf", as: FunctionType.LAPACKE_zgeqpf.self)
    #elseif os(macOS)
    static let zgeqpf: FunctionType.LAPACKE_zgeqpf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr2: FunctionType.LAPACKE_sgeqr2? = load(name: "LAPACKE_sgeqr2", as: FunctionType.LAPACKE_sgeqr2.self)
    #elseif os(macOS)
    static let sgeqr2: FunctionType.LAPACKE_sgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr2: FunctionType.LAPACKE_dgeqr2? = load(name: "LAPACKE_dgeqr2", as: FunctionType.LAPACKE_dgeqr2.self)
    #elseif os(macOS)
    static let dgeqr2: FunctionType.LAPACKE_dgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr2: FunctionType.LAPACKE_cgeqr2? = load(name: "LAPACKE_cgeqr2", as: FunctionType.LAPACKE_cgeqr2.self)
    #elseif os(macOS)
    static let cgeqr2: FunctionType.LAPACKE_cgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr2: FunctionType.LAPACKE_zgeqr2? = load(name: "LAPACKE_zgeqr2", as: FunctionType.LAPACKE_zgeqr2.self)
    #elseif os(macOS)
    static let zgeqr2: FunctionType.LAPACKE_zgeqr2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrf: FunctionType.LAPACKE_sgeqrf? = load(name: "LAPACKE_sgeqrf", as: FunctionType.LAPACKE_sgeqrf.self)
    #elseif os(macOS)
    static let sgeqrf: FunctionType.LAPACKE_sgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrf: FunctionType.LAPACKE_dgeqrf? = load(name: "LAPACKE_dgeqrf", as: FunctionType.LAPACKE_dgeqrf.self)
    #elseif os(macOS)
    static let dgeqrf: FunctionType.LAPACKE_dgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrf: FunctionType.LAPACKE_cgeqrf? = load(name: "LAPACKE_cgeqrf", as: FunctionType.LAPACKE_cgeqrf.self)
    #elseif os(macOS)
    static let cgeqrf: FunctionType.LAPACKE_cgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrf: FunctionType.LAPACKE_zgeqrf? = load(name: "LAPACKE_zgeqrf", as: FunctionType.LAPACKE_zgeqrf.self)
    #elseif os(macOS)
    static let zgeqrf: FunctionType.LAPACKE_zgeqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrfp: FunctionType.LAPACKE_sgeqrfp? = load(name: "LAPACKE_sgeqrfp", as: FunctionType.LAPACKE_sgeqrfp.self)
    #elseif os(macOS)
    static let sgeqrfp: FunctionType.LAPACKE_sgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrfp: FunctionType.LAPACKE_dgeqrfp? = load(name: "LAPACKE_dgeqrfp", as: FunctionType.LAPACKE_dgeqrfp.self)
    #elseif os(macOS)
    static let dgeqrfp: FunctionType.LAPACKE_dgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrfp: FunctionType.LAPACKE_cgeqrfp? = load(name: "LAPACKE_cgeqrfp", as: FunctionType.LAPACKE_cgeqrfp.self)
    #elseif os(macOS)
    static let cgeqrfp: FunctionType.LAPACKE_cgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrfp: FunctionType.LAPACKE_zgeqrfp? = load(name: "LAPACKE_zgeqrfp", as: FunctionType.LAPACKE_zgeqrfp.self)
    #elseif os(macOS)
    static let zgeqrfp: FunctionType.LAPACKE_zgeqrfp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfs: FunctionType.LAPACKE_sgerfs? = load(name: "LAPACKE_sgerfs", as: FunctionType.LAPACKE_sgerfs.self)
    #elseif os(macOS)
    static let sgerfs: FunctionType.LAPACKE_sgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfs: FunctionType.LAPACKE_dgerfs? = load(name: "LAPACKE_dgerfs", as: FunctionType.LAPACKE_dgerfs.self)
    #elseif os(macOS)
    static let dgerfs: FunctionType.LAPACKE_dgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfs: FunctionType.LAPACKE_cgerfs? = load(name: "LAPACKE_cgerfs", as: FunctionType.LAPACKE_cgerfs.self)
    #elseif os(macOS)
    static let cgerfs: FunctionType.LAPACKE_cgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfs: FunctionType.LAPACKE_zgerfs? = load(name: "LAPACKE_zgerfs", as: FunctionType.LAPACKE_zgerfs.self)
    #elseif os(macOS)
    static let zgerfs: FunctionType.LAPACKE_zgerfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfsx: FunctionType.LAPACKE_sgerfsx? = load(name: "LAPACKE_sgerfsx", as: FunctionType.LAPACKE_sgerfsx.self)
    #elseif os(macOS)
    static let sgerfsx: FunctionType.LAPACKE_sgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfsx: FunctionType.LAPACKE_dgerfsx? = load(name: "LAPACKE_dgerfsx", as: FunctionType.LAPACKE_dgerfsx.self)
    #elseif os(macOS)
    static let dgerfsx: FunctionType.LAPACKE_dgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfsx: FunctionType.LAPACKE_cgerfsx? = load(name: "LAPACKE_cgerfsx", as: FunctionType.LAPACKE_cgerfsx.self)
    #elseif os(macOS)
    static let cgerfsx: FunctionType.LAPACKE_cgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfsx: FunctionType.LAPACKE_zgerfsx? = load(name: "LAPACKE_zgerfsx", as: FunctionType.LAPACKE_zgerfsx.self)
    #elseif os(macOS)
    static let zgerfsx: FunctionType.LAPACKE_zgerfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerqf: FunctionType.LAPACKE_sgerqf? = load(name: "LAPACKE_sgerqf", as: FunctionType.LAPACKE_sgerqf.self)
    #elseif os(macOS)
    static let sgerqf: FunctionType.LAPACKE_sgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerqf: FunctionType.LAPACKE_dgerqf? = load(name: "LAPACKE_dgerqf", as: FunctionType.LAPACKE_dgerqf.self)
    #elseif os(macOS)
    static let dgerqf: FunctionType.LAPACKE_dgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerqf: FunctionType.LAPACKE_cgerqf? = load(name: "LAPACKE_cgerqf", as: FunctionType.LAPACKE_cgerqf.self)
    #elseif os(macOS)
    static let cgerqf: FunctionType.LAPACKE_cgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerqf: FunctionType.LAPACKE_zgerqf? = load(name: "LAPACKE_zgerqf", as: FunctionType.LAPACKE_zgerqf.self)
    #elseif os(macOS)
    static let zgerqf: FunctionType.LAPACKE_zgerqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesdd: FunctionType.LAPACKE_sgesdd? = load(name: "LAPACKE_sgesdd", as: FunctionType.LAPACKE_sgesdd.self)
    #elseif os(macOS)
    static let sgesdd: FunctionType.LAPACKE_sgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesdd: FunctionType.LAPACKE_dgesdd? = load(name: "LAPACKE_dgesdd", as: FunctionType.LAPACKE_dgesdd.self)
    #elseif os(macOS)
    static let dgesdd: FunctionType.LAPACKE_dgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesdd: FunctionType.LAPACKE_cgesdd? = load(name: "LAPACKE_cgesdd", as: FunctionType.LAPACKE_cgesdd.self)
    #elseif os(macOS)
    static let cgesdd: FunctionType.LAPACKE_cgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesdd: FunctionType.LAPACKE_zgesdd? = load(name: "LAPACKE_zgesdd", as: FunctionType.LAPACKE_zgesdd.self)
    #elseif os(macOS)
    static let zgesdd: FunctionType.LAPACKE_zgesdd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesv: FunctionType.LAPACKE_sgesv? = load(name: "LAPACKE_sgesv", as: FunctionType.LAPACKE_sgesv.self)
    #elseif os(macOS)
    static let sgesv: FunctionType.LAPACKE_sgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesv: FunctionType.LAPACKE_dgesv? = load(name: "LAPACKE_dgesv", as: FunctionType.LAPACKE_dgesv.self)
    #elseif os(macOS)
    static let dgesv: FunctionType.LAPACKE_dgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesv: FunctionType.LAPACKE_cgesv? = load(name: "LAPACKE_cgesv", as: FunctionType.LAPACKE_cgesv.self)
    #elseif os(macOS)
    static let cgesv: FunctionType.LAPACKE_cgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesv: FunctionType.LAPACKE_zgesv? = load(name: "LAPACKE_zgesv", as: FunctionType.LAPACKE_zgesv.self)
    #elseif os(macOS)
    static let zgesv: FunctionType.LAPACKE_zgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsgesv: FunctionType.LAPACKE_dsgesv? = load(name: "LAPACKE_dsgesv", as: FunctionType.LAPACKE_dsgesv.self)
    #elseif os(macOS)
    static let dsgesv: FunctionType.LAPACKE_dsgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcgesv: FunctionType.LAPACKE_zcgesv? = load(name: "LAPACKE_zcgesv", as: FunctionType.LAPACKE_zcgesv.self)
    #elseif os(macOS)
    static let zcgesv: FunctionType.LAPACKE_zcgesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvd: FunctionType.LAPACKE_sgesvd? = load(name: "LAPACKE_sgesvd", as: FunctionType.LAPACKE_sgesvd.self)
    #elseif os(macOS)
    static let sgesvd: FunctionType.LAPACKE_sgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvd: FunctionType.LAPACKE_dgesvd? = load(name: "LAPACKE_dgesvd", as: FunctionType.LAPACKE_dgesvd.self)
    #elseif os(macOS)
    static let dgesvd: FunctionType.LAPACKE_dgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvd: FunctionType.LAPACKE_cgesvd? = load(name: "LAPACKE_cgesvd", as: FunctionType.LAPACKE_cgesvd.self)
    #elseif os(macOS)
    static let cgesvd: FunctionType.LAPACKE_cgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvd: FunctionType.LAPACKE_zgesvd? = load(name: "LAPACKE_zgesvd", as: FunctionType.LAPACKE_zgesvd.self)
    #elseif os(macOS)
    static let zgesvd: FunctionType.LAPACKE_zgesvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdx: FunctionType.LAPACKE_sgesvdx? = load(name: "LAPACKE_sgesvdx", as: FunctionType.LAPACKE_sgesvdx.self)
    #elseif os(macOS)
    static let sgesvdx: FunctionType.LAPACKE_sgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdx: FunctionType.LAPACKE_dgesvdx? = load(name: "LAPACKE_dgesvdx", as: FunctionType.LAPACKE_dgesvdx.self)
    #elseif os(macOS)
    static let dgesvdx: FunctionType.LAPACKE_dgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdx: FunctionType.LAPACKE_cgesvdx? = load(name: "LAPACKE_cgesvdx", as: FunctionType.LAPACKE_cgesvdx.self)
    #elseif os(macOS)
    static let cgesvdx: FunctionType.LAPACKE_cgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdx: FunctionType.LAPACKE_zgesvdx? = load(name: "LAPACKE_zgesvdx", as: FunctionType.LAPACKE_zgesvdx.self)
    #elseif os(macOS)
    static let zgesvdx: FunctionType.LAPACKE_zgesvdx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdq: FunctionType.LAPACKE_sgesvdq? = load(name: "LAPACKE_sgesvdq", as: FunctionType.LAPACKE_sgesvdq.self)
    #elseif os(macOS)
    static let sgesvdq: FunctionType.LAPACKE_sgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdq: FunctionType.LAPACKE_dgesvdq? = load(name: "LAPACKE_dgesvdq", as: FunctionType.LAPACKE_dgesvdq.self)
    #elseif os(macOS)
    static let dgesvdq: FunctionType.LAPACKE_dgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdq: FunctionType.LAPACKE_cgesvdq? = load(name: "LAPACKE_cgesvdq", as: FunctionType.LAPACKE_cgesvdq.self)
    #elseif os(macOS)
    static let cgesvdq: FunctionType.LAPACKE_cgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdq: FunctionType.LAPACKE_zgesvdq? = load(name: "LAPACKE_zgesvdq", as: FunctionType.LAPACKE_zgesvdq.self)
    #elseif os(macOS)
    static let zgesvdq: FunctionType.LAPACKE_zgesvdq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvj: FunctionType.LAPACKE_sgesvj? = load(name: "LAPACKE_sgesvj", as: FunctionType.LAPACKE_sgesvj.self)
    #elseif os(macOS)
    static let sgesvj: FunctionType.LAPACKE_sgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvj: FunctionType.LAPACKE_dgesvj? = load(name: "LAPACKE_dgesvj", as: FunctionType.LAPACKE_dgesvj.self)
    #elseif os(macOS)
    static let dgesvj: FunctionType.LAPACKE_dgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvj: FunctionType.LAPACKE_cgesvj? = load(name: "LAPACKE_cgesvj", as: FunctionType.LAPACKE_cgesvj.self)
    #elseif os(macOS)
    static let cgesvj: FunctionType.LAPACKE_cgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvj: FunctionType.LAPACKE_zgesvj? = load(name: "LAPACKE_zgesvj", as: FunctionType.LAPACKE_zgesvj.self)
    #elseif os(macOS)
    static let zgesvj: FunctionType.LAPACKE_zgesvj? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvx: FunctionType.LAPACKE_sgesvx? = load(name: "LAPACKE_sgesvx", as: FunctionType.LAPACKE_sgesvx.self)
    #elseif os(macOS)
    static let sgesvx: FunctionType.LAPACKE_sgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvx: FunctionType.LAPACKE_dgesvx? = load(name: "LAPACKE_dgesvx", as: FunctionType.LAPACKE_dgesvx.self)
    #elseif os(macOS)
    static let dgesvx: FunctionType.LAPACKE_dgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvx: FunctionType.LAPACKE_cgesvx? = load(name: "LAPACKE_cgesvx", as: FunctionType.LAPACKE_cgesvx.self)
    #elseif os(macOS)
    static let cgesvx: FunctionType.LAPACKE_cgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvx: FunctionType.LAPACKE_zgesvx? = load(name: "LAPACKE_zgesvx", as: FunctionType.LAPACKE_zgesvx.self)
    #elseif os(macOS)
    static let zgesvx: FunctionType.LAPACKE_zgesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvxx: FunctionType.LAPACKE_sgesvxx? = load(name: "LAPACKE_sgesvxx", as: FunctionType.LAPACKE_sgesvxx.self)
    #elseif os(macOS)
    static let sgesvxx: FunctionType.LAPACKE_sgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvxx: FunctionType.LAPACKE_dgesvxx? = load(name: "LAPACKE_dgesvxx", as: FunctionType.LAPACKE_dgesvxx.self)
    #elseif os(macOS)
    static let dgesvxx: FunctionType.LAPACKE_dgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvxx: FunctionType.LAPACKE_cgesvxx? = load(name: "LAPACKE_cgesvxx", as: FunctionType.LAPACKE_cgesvxx.self)
    #elseif os(macOS)
    static let cgesvxx: FunctionType.LAPACKE_cgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvxx: FunctionType.LAPACKE_zgesvxx? = load(name: "LAPACKE_zgesvxx", as: FunctionType.LAPACKE_zgesvxx.self)
    #elseif os(macOS)
    static let zgesvxx: FunctionType.LAPACKE_zgesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetf2: FunctionType.LAPACKE_sgetf2? = load(name: "LAPACKE_sgetf2", as: FunctionType.LAPACKE_sgetf2.self)
    #elseif os(macOS)
    static let sgetf2: FunctionType.LAPACKE_sgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetf2: FunctionType.LAPACKE_dgetf2? = load(name: "LAPACKE_dgetf2", as: FunctionType.LAPACKE_dgetf2.self)
    #elseif os(macOS)
    static let dgetf2: FunctionType.LAPACKE_dgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetf2: FunctionType.LAPACKE_cgetf2? = load(name: "LAPACKE_cgetf2", as: FunctionType.LAPACKE_cgetf2.self)
    #elseif os(macOS)
    static let cgetf2: FunctionType.LAPACKE_cgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetf2: FunctionType.LAPACKE_zgetf2? = load(name: "LAPACKE_zgetf2", as: FunctionType.LAPACKE_zgetf2.self)
    #elseif os(macOS)
    static let zgetf2: FunctionType.LAPACKE_zgetf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf: FunctionType.LAPACKE_sgetrf? = load(name: "LAPACKE_sgetrf", as: FunctionType.LAPACKE_sgetrf.self)
    #elseif os(macOS)
    static let sgetrf: FunctionType.LAPACKE_sgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf: FunctionType.LAPACKE_dgetrf? = load(name: "LAPACKE_dgetrf", as: FunctionType.LAPACKE_dgetrf.self)
    #elseif os(macOS)
    static let dgetrf: FunctionType.LAPACKE_dgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf: FunctionType.LAPACKE_cgetrf? = load(name: "LAPACKE_cgetrf", as: FunctionType.LAPACKE_cgetrf.self)
    #elseif os(macOS)
    static let cgetrf: FunctionType.LAPACKE_cgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf: FunctionType.LAPACKE_zgetrf? = load(name: "LAPACKE_zgetrf", as: FunctionType.LAPACKE_zgetrf.self)
    #elseif os(macOS)
    static let zgetrf: FunctionType.LAPACKE_zgetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf2: FunctionType.LAPACKE_sgetrf2? = load(name: "LAPACKE_sgetrf2", as: FunctionType.LAPACKE_sgetrf2.self)
    #elseif os(macOS)
    static let sgetrf2: FunctionType.LAPACKE_sgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf2: FunctionType.LAPACKE_dgetrf2? = load(name: "LAPACKE_dgetrf2", as: FunctionType.LAPACKE_dgetrf2.self)
    #elseif os(macOS)
    static let dgetrf2: FunctionType.LAPACKE_dgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf2: FunctionType.LAPACKE_cgetrf2? = load(name: "LAPACKE_cgetrf2", as: FunctionType.LAPACKE_cgetrf2.self)
    #elseif os(macOS)
    static let cgetrf2: FunctionType.LAPACKE_cgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf2: FunctionType.LAPACKE_zgetrf2? = load(name: "LAPACKE_zgetrf2", as: FunctionType.LAPACKE_zgetrf2.self)
    #elseif os(macOS)
    static let zgetrf2: FunctionType.LAPACKE_zgetrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetri: FunctionType.LAPACKE_sgetri? = load(name: "LAPACKE_sgetri", as: FunctionType.LAPACKE_sgetri.self)
    #elseif os(macOS)
    static let sgetri: FunctionType.LAPACKE_sgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetri: FunctionType.LAPACKE_dgetri? = load(name: "LAPACKE_dgetri", as: FunctionType.LAPACKE_dgetri.self)
    #elseif os(macOS)
    static let dgetri: FunctionType.LAPACKE_dgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetri: FunctionType.LAPACKE_cgetri? = load(name: "LAPACKE_cgetri", as: FunctionType.LAPACKE_cgetri.self)
    #elseif os(macOS)
    static let cgetri: FunctionType.LAPACKE_cgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetri: FunctionType.LAPACKE_zgetri? = load(name: "LAPACKE_zgetri", as: FunctionType.LAPACKE_zgetri.self)
    #elseif os(macOS)
    static let zgetri: FunctionType.LAPACKE_zgetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrs: FunctionType.LAPACKE_sgetrs? = load(name: "LAPACKE_sgetrs", as: FunctionType.LAPACKE_sgetrs.self)
    #elseif os(macOS)
    static let sgetrs: FunctionType.LAPACKE_sgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrs: FunctionType.LAPACKE_dgetrs? = load(name: "LAPACKE_dgetrs", as: FunctionType.LAPACKE_dgetrs.self)
    #elseif os(macOS)
    static let dgetrs: FunctionType.LAPACKE_dgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrs: FunctionType.LAPACKE_cgetrs? = load(name: "LAPACKE_cgetrs", as: FunctionType.LAPACKE_cgetrs.self)
    #elseif os(macOS)
    static let cgetrs: FunctionType.LAPACKE_cgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrs: FunctionType.LAPACKE_zgetrs? = load(name: "LAPACKE_zgetrs", as: FunctionType.LAPACKE_zgetrs.self)
    #elseif os(macOS)
    static let zgetrs: FunctionType.LAPACKE_zgetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbak: FunctionType.LAPACKE_sggbak? = load(name: "LAPACKE_sggbak", as: FunctionType.LAPACKE_sggbak.self)
    #elseif os(macOS)
    static let sggbak: FunctionType.LAPACKE_sggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbak: FunctionType.LAPACKE_dggbak? = load(name: "LAPACKE_dggbak", as: FunctionType.LAPACKE_dggbak.self)
    #elseif os(macOS)
    static let dggbak: FunctionType.LAPACKE_dggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbak: FunctionType.LAPACKE_cggbak? = load(name: "LAPACKE_cggbak", as: FunctionType.LAPACKE_cggbak.self)
    #elseif os(macOS)
    static let cggbak: FunctionType.LAPACKE_cggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbak: FunctionType.LAPACKE_zggbak? = load(name: "LAPACKE_zggbak", as: FunctionType.LAPACKE_zggbak.self)
    #elseif os(macOS)
    static let zggbak: FunctionType.LAPACKE_zggbak? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbal: FunctionType.LAPACKE_sggbal? = load(name: "LAPACKE_sggbal", as: FunctionType.LAPACKE_sggbal.self)
    #elseif os(macOS)
    static let sggbal: FunctionType.LAPACKE_sggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbal: FunctionType.LAPACKE_dggbal? = load(name: "LAPACKE_dggbal", as: FunctionType.LAPACKE_dggbal.self)
    #elseif os(macOS)
    static let dggbal: FunctionType.LAPACKE_dggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbal: FunctionType.LAPACKE_cggbal? = load(name: "LAPACKE_cggbal", as: FunctionType.LAPACKE_cggbal.self)
    #elseif os(macOS)
    static let cggbal: FunctionType.LAPACKE_cggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbal: FunctionType.LAPACKE_zggbal? = load(name: "LAPACKE_zggbal", as: FunctionType.LAPACKE_zggbal.self)
    #elseif os(macOS)
    static let zggbal: FunctionType.LAPACKE_zggbal? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges: FunctionType.LAPACKE_sgges? = load(name: "LAPACKE_sgges", as: FunctionType.LAPACKE_sgges.self)
    #elseif os(macOS)
    static let sgges: FunctionType.LAPACKE_sgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges: FunctionType.LAPACKE_dgges? = load(name: "LAPACKE_dgges", as: FunctionType.LAPACKE_dgges.self)
    #elseif os(macOS)
    static let dgges: FunctionType.LAPACKE_dgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges: FunctionType.LAPACKE_cgges? = load(name: "LAPACKE_cgges", as: FunctionType.LAPACKE_cgges.self)
    #elseif os(macOS)
    static let cgges: FunctionType.LAPACKE_cgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges: FunctionType.LAPACKE_zgges? = load(name: "LAPACKE_zgges", as: FunctionType.LAPACKE_zgges.self)
    #elseif os(macOS)
    static let zgges: FunctionType.LAPACKE_zgges? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges3: FunctionType.LAPACKE_sgges3? = load(name: "LAPACKE_sgges3", as: FunctionType.LAPACKE_sgges3.self)
    #elseif os(macOS)
    static let sgges3: FunctionType.LAPACKE_sgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges3: FunctionType.LAPACKE_dgges3? = load(name: "LAPACKE_dgges3", as: FunctionType.LAPACKE_dgges3.self)
    #elseif os(macOS)
    static let dgges3: FunctionType.LAPACKE_dgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges3: FunctionType.LAPACKE_cgges3? = load(name: "LAPACKE_cgges3", as: FunctionType.LAPACKE_cgges3.self)
    #elseif os(macOS)
    static let cgges3: FunctionType.LAPACKE_cgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges3: FunctionType.LAPACKE_zgges3? = load(name: "LAPACKE_zgges3", as: FunctionType.LAPACKE_zgges3.self)
    #elseif os(macOS)
    static let zgges3: FunctionType.LAPACKE_zgges3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggesx: FunctionType.LAPACKE_sggesx? = load(name: "LAPACKE_sggesx", as: FunctionType.LAPACKE_sggesx.self)
    #elseif os(macOS)
    static let sggesx: FunctionType.LAPACKE_sggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggesx: FunctionType.LAPACKE_dggesx? = load(name: "LAPACKE_dggesx", as: FunctionType.LAPACKE_dggesx.self)
    #elseif os(macOS)
    static let dggesx: FunctionType.LAPACKE_dggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggesx: FunctionType.LAPACKE_cggesx? = load(name: "LAPACKE_cggesx", as: FunctionType.LAPACKE_cggesx.self)
    #elseif os(macOS)
    static let cggesx: FunctionType.LAPACKE_cggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggesx: FunctionType.LAPACKE_zggesx? = load(name: "LAPACKE_zggesx", as: FunctionType.LAPACKE_zggesx.self)
    #elseif os(macOS)
    static let zggesx: FunctionType.LAPACKE_zggesx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev: FunctionType.LAPACKE_sggev? = load(name: "LAPACKE_sggev", as: FunctionType.LAPACKE_sggev.self)
    #elseif os(macOS)
    static let sggev: FunctionType.LAPACKE_sggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev: FunctionType.LAPACKE_dggev? = load(name: "LAPACKE_dggev", as: FunctionType.LAPACKE_dggev.self)
    #elseif os(macOS)
    static let dggev: FunctionType.LAPACKE_dggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev: FunctionType.LAPACKE_cggev? = load(name: "LAPACKE_cggev", as: FunctionType.LAPACKE_cggev.self)
    #elseif os(macOS)
    static let cggev: FunctionType.LAPACKE_cggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev: FunctionType.LAPACKE_zggev? = load(name: "LAPACKE_zggev", as: FunctionType.LAPACKE_zggev.self)
    #elseif os(macOS)
    static let zggev: FunctionType.LAPACKE_zggev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev3: FunctionType.LAPACKE_sggev3? = load(name: "LAPACKE_sggev3", as: FunctionType.LAPACKE_sggev3.self)
    #elseif os(macOS)
    static let sggev3: FunctionType.LAPACKE_sggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev3: FunctionType.LAPACKE_dggev3? = load(name: "LAPACKE_dggev3", as: FunctionType.LAPACKE_dggev3.self)
    #elseif os(macOS)
    static let dggev3: FunctionType.LAPACKE_dggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev3: FunctionType.LAPACKE_cggev3? = load(name: "LAPACKE_cggev3", as: FunctionType.LAPACKE_cggev3.self)
    #elseif os(macOS)
    static let cggev3: FunctionType.LAPACKE_cggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev3: FunctionType.LAPACKE_zggev3? = load(name: "LAPACKE_zggev3", as: FunctionType.LAPACKE_zggev3.self)
    #elseif os(macOS)
    static let zggev3: FunctionType.LAPACKE_zggev3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggevx: FunctionType.LAPACKE_sggevx? = load(name: "LAPACKE_sggevx", as: FunctionType.LAPACKE_sggevx.self)
    #elseif os(macOS)
    static let sggevx: FunctionType.LAPACKE_sggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggevx: FunctionType.LAPACKE_dggevx? = load(name: "LAPACKE_dggevx", as: FunctionType.LAPACKE_dggevx.self)
    #elseif os(macOS)
    static let dggevx: FunctionType.LAPACKE_dggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggevx: FunctionType.LAPACKE_cggevx? = load(name: "LAPACKE_cggevx", as: FunctionType.LAPACKE_cggevx.self)
    #elseif os(macOS)
    static let cggevx: FunctionType.LAPACKE_cggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggevx: FunctionType.LAPACKE_zggevx? = load(name: "LAPACKE_zggevx", as: FunctionType.LAPACKE_zggevx.self)
    #elseif os(macOS)
    static let zggevx: FunctionType.LAPACKE_zggevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggglm: FunctionType.LAPACKE_sggglm? = load(name: "LAPACKE_sggglm", as: FunctionType.LAPACKE_sggglm.self)
    #elseif os(macOS)
    static let sggglm: FunctionType.LAPACKE_sggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggglm: FunctionType.LAPACKE_dggglm? = load(name: "LAPACKE_dggglm", as: FunctionType.LAPACKE_dggglm.self)
    #elseif os(macOS)
    static let dggglm: FunctionType.LAPACKE_dggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggglm: FunctionType.LAPACKE_cggglm? = load(name: "LAPACKE_cggglm", as: FunctionType.LAPACKE_cggglm.self)
    #elseif os(macOS)
    static let cggglm: FunctionType.LAPACKE_cggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggglm: FunctionType.LAPACKE_zggglm? = load(name: "LAPACKE_zggglm", as: FunctionType.LAPACKE_zggglm.self)
    #elseif os(macOS)
    static let zggglm: FunctionType.LAPACKE_zggglm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghrd: FunctionType.LAPACKE_sgghrd? = load(name: "LAPACKE_sgghrd", as: FunctionType.LAPACKE_sgghrd.self)
    #elseif os(macOS)
    static let sgghrd: FunctionType.LAPACKE_sgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghrd: FunctionType.LAPACKE_dgghrd? = load(name: "LAPACKE_dgghrd", as: FunctionType.LAPACKE_dgghrd.self)
    #elseif os(macOS)
    static let dgghrd: FunctionType.LAPACKE_dgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghrd: FunctionType.LAPACKE_cgghrd? = load(name: "LAPACKE_cgghrd", as: FunctionType.LAPACKE_cgghrd.self)
    #elseif os(macOS)
    static let cgghrd: FunctionType.LAPACKE_cgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghrd: FunctionType.LAPACKE_zgghrd? = load(name: "LAPACKE_zgghrd", as: FunctionType.LAPACKE_zgghrd.self)
    #elseif os(macOS)
    static let zgghrd: FunctionType.LAPACKE_zgghrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghd3: FunctionType.LAPACKE_sgghd3? = load(name: "LAPACKE_sgghd3", as: FunctionType.LAPACKE_sgghd3.self)
    #elseif os(macOS)
    static let sgghd3: FunctionType.LAPACKE_sgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghd3: FunctionType.LAPACKE_dgghd3? = load(name: "LAPACKE_dgghd3", as: FunctionType.LAPACKE_dgghd3.self)
    #elseif os(macOS)
    static let dgghd3: FunctionType.LAPACKE_dgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghd3: FunctionType.LAPACKE_cgghd3? = load(name: "LAPACKE_cgghd3", as: FunctionType.LAPACKE_cgghd3.self)
    #elseif os(macOS)
    static let cgghd3: FunctionType.LAPACKE_cgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghd3: FunctionType.LAPACKE_zgghd3? = load(name: "LAPACKE_zgghd3", as: FunctionType.LAPACKE_zgghd3.self)
    #elseif os(macOS)
    static let zgghd3: FunctionType.LAPACKE_zgghd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgglse: FunctionType.LAPACKE_sgglse? = load(name: "LAPACKE_sgglse", as: FunctionType.LAPACKE_sgglse.self)
    #elseif os(macOS)
    static let sgglse: FunctionType.LAPACKE_sgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgglse: FunctionType.LAPACKE_dgglse? = load(name: "LAPACKE_dgglse", as: FunctionType.LAPACKE_dgglse.self)
    #elseif os(macOS)
    static let dgglse: FunctionType.LAPACKE_dgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgglse: FunctionType.LAPACKE_cgglse? = load(name: "LAPACKE_cgglse", as: FunctionType.LAPACKE_cgglse.self)
    #elseif os(macOS)
    static let cgglse: FunctionType.LAPACKE_cgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgglse: FunctionType.LAPACKE_zgglse? = load(name: "LAPACKE_zgglse", as: FunctionType.LAPACKE_zgglse.self)
    #elseif os(macOS)
    static let zgglse: FunctionType.LAPACKE_zgglse? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggqrf: FunctionType.LAPACKE_sggqrf? = load(name: "LAPACKE_sggqrf", as: FunctionType.LAPACKE_sggqrf.self)
    #elseif os(macOS)
    static let sggqrf: FunctionType.LAPACKE_sggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggqrf: FunctionType.LAPACKE_dggqrf? = load(name: "LAPACKE_dggqrf", as: FunctionType.LAPACKE_dggqrf.self)
    #elseif os(macOS)
    static let dggqrf: FunctionType.LAPACKE_dggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggqrf: FunctionType.LAPACKE_cggqrf? = load(name: "LAPACKE_cggqrf", as: FunctionType.LAPACKE_cggqrf.self)
    #elseif os(macOS)
    static let cggqrf: FunctionType.LAPACKE_cggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggqrf: FunctionType.LAPACKE_zggqrf? = load(name: "LAPACKE_zggqrf", as: FunctionType.LAPACKE_zggqrf.self)
    #elseif os(macOS)
    static let zggqrf: FunctionType.LAPACKE_zggqrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggrqf: FunctionType.LAPACKE_sggrqf? = load(name: "LAPACKE_sggrqf", as: FunctionType.LAPACKE_sggrqf.self)
    #elseif os(macOS)
    static let sggrqf: FunctionType.LAPACKE_sggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggrqf: FunctionType.LAPACKE_dggrqf? = load(name: "LAPACKE_dggrqf", as: FunctionType.LAPACKE_dggrqf.self)
    #elseif os(macOS)
    static let dggrqf: FunctionType.LAPACKE_dggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggrqf: FunctionType.LAPACKE_cggrqf? = load(name: "LAPACKE_cggrqf", as: FunctionType.LAPACKE_cggrqf.self)
    #elseif os(macOS)
    static let cggrqf: FunctionType.LAPACKE_cggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggrqf: FunctionType.LAPACKE_zggrqf? = load(name: "LAPACKE_zggrqf", as: FunctionType.LAPACKE_zggrqf.self)
    #elseif os(macOS)
    static let zggrqf: FunctionType.LAPACKE_zggrqf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd: FunctionType.LAPACKE_sggsvd? = load(name: "LAPACKE_sggsvd", as: FunctionType.LAPACKE_sggsvd.self)
    #elseif os(macOS)
    static let sggsvd: FunctionType.LAPACKE_sggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd: FunctionType.LAPACKE_dggsvd? = load(name: "LAPACKE_dggsvd", as: FunctionType.LAPACKE_dggsvd.self)
    #elseif os(macOS)
    static let dggsvd: FunctionType.LAPACKE_dggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd: FunctionType.LAPACKE_cggsvd? = load(name: "LAPACKE_cggsvd", as: FunctionType.LAPACKE_cggsvd.self)
    #elseif os(macOS)
    static let cggsvd: FunctionType.LAPACKE_cggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd: FunctionType.LAPACKE_zggsvd? = load(name: "LAPACKE_zggsvd", as: FunctionType.LAPACKE_zggsvd.self)
    #elseif os(macOS)
    static let zggsvd: FunctionType.LAPACKE_zggsvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd3: FunctionType.LAPACKE_sggsvd3? = load(name: "LAPACKE_sggsvd3", as: FunctionType.LAPACKE_sggsvd3.self)
    #elseif os(macOS)
    static let sggsvd3: FunctionType.LAPACKE_sggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd3: FunctionType.LAPACKE_dggsvd3? = load(name: "LAPACKE_dggsvd3", as: FunctionType.LAPACKE_dggsvd3.self)
    #elseif os(macOS)
    static let dggsvd3: FunctionType.LAPACKE_dggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd3: FunctionType.LAPACKE_cggsvd3? = load(name: "LAPACKE_cggsvd3", as: FunctionType.LAPACKE_cggsvd3.self)
    #elseif os(macOS)
    static let cggsvd3: FunctionType.LAPACKE_cggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd3: FunctionType.LAPACKE_zggsvd3? = load(name: "LAPACKE_zggsvd3", as: FunctionType.LAPACKE_zggsvd3.self)
    #elseif os(macOS)
    static let zggsvd3: FunctionType.LAPACKE_zggsvd3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp: FunctionType.LAPACKE_sggsvp? = load(name: "LAPACKE_sggsvp", as: FunctionType.LAPACKE_sggsvp.self)
    #elseif os(macOS)
    static let sggsvp: FunctionType.LAPACKE_sggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp: FunctionType.LAPACKE_dggsvp? = load(name: "LAPACKE_dggsvp", as: FunctionType.LAPACKE_dggsvp.self)
    #elseif os(macOS)
    static let dggsvp: FunctionType.LAPACKE_dggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp: FunctionType.LAPACKE_cggsvp? = load(name: "LAPACKE_cggsvp", as: FunctionType.LAPACKE_cggsvp.self)
    #elseif os(macOS)
    static let cggsvp: FunctionType.LAPACKE_cggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp: FunctionType.LAPACKE_zggsvp? = load(name: "LAPACKE_zggsvp", as: FunctionType.LAPACKE_zggsvp.self)
    #elseif os(macOS)
    static let zggsvp: FunctionType.LAPACKE_zggsvp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp3: FunctionType.LAPACKE_sggsvp3? = load(name: "LAPACKE_sggsvp3", as: FunctionType.LAPACKE_sggsvp3.self)
    #elseif os(macOS)
    static let sggsvp3: FunctionType.LAPACKE_sggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp3: FunctionType.LAPACKE_dggsvp3? = load(name: "LAPACKE_dggsvp3", as: FunctionType.LAPACKE_dggsvp3.self)
    #elseif os(macOS)
    static let dggsvp3: FunctionType.LAPACKE_dggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp3: FunctionType.LAPACKE_cggsvp3? = load(name: "LAPACKE_cggsvp3", as: FunctionType.LAPACKE_cggsvp3.self)
    #elseif os(macOS)
    static let cggsvp3: FunctionType.LAPACKE_cggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp3: FunctionType.LAPACKE_zggsvp3? = load(name: "LAPACKE_zggsvp3", as: FunctionType.LAPACKE_zggsvp3.self)
    #elseif os(macOS)
    static let zggsvp3: FunctionType.LAPACKE_zggsvp3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtcon: FunctionType.LAPACKE_sgtcon? = load(name: "LAPACKE_sgtcon", as: FunctionType.LAPACKE_sgtcon.self)
    #elseif os(macOS)
    static let sgtcon: FunctionType.LAPACKE_sgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtcon: FunctionType.LAPACKE_dgtcon? = load(name: "LAPACKE_dgtcon", as: FunctionType.LAPACKE_dgtcon.self)
    #elseif os(macOS)
    static let dgtcon: FunctionType.LAPACKE_dgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtcon: FunctionType.LAPACKE_cgtcon? = load(name: "LAPACKE_cgtcon", as: FunctionType.LAPACKE_cgtcon.self)
    #elseif os(macOS)
    static let cgtcon: FunctionType.LAPACKE_cgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtcon: FunctionType.LAPACKE_zgtcon? = load(name: "LAPACKE_zgtcon", as: FunctionType.LAPACKE_zgtcon.self)
    #elseif os(macOS)
    static let zgtcon: FunctionType.LAPACKE_zgtcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtrfs: FunctionType.LAPACKE_sgtrfs? = load(name: "LAPACKE_sgtrfs", as: FunctionType.LAPACKE_sgtrfs.self)
    #elseif os(macOS)
    static let sgtrfs: FunctionType.LAPACKE_sgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtrfs: FunctionType.LAPACKE_dgtrfs? = load(name: "LAPACKE_dgtrfs", as: FunctionType.LAPACKE_dgtrfs.self)
    #elseif os(macOS)
    static let dgtrfs: FunctionType.LAPACKE_dgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtrfs: FunctionType.LAPACKE_cgtrfs? = load(name: "LAPACKE_cgtrfs", as: FunctionType.LAPACKE_cgtrfs.self)
    #elseif os(macOS)
    static let cgtrfs: FunctionType.LAPACKE_cgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtrfs: FunctionType.LAPACKE_zgtrfs? = load(name: "LAPACKE_zgtrfs", as: FunctionType.LAPACKE_zgtrfs.self)
    #elseif os(macOS)
    static let zgtrfs: FunctionType.LAPACKE_zgtrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsv: FunctionType.LAPACKE_sgtsv? = load(name: "LAPACKE_sgtsv", as: FunctionType.LAPACKE_sgtsv.self)
    #elseif os(macOS)
    static let sgtsv: FunctionType.LAPACKE_sgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsv: FunctionType.LAPACKE_dgtsv? = load(name: "LAPACKE_dgtsv", as: FunctionType.LAPACKE_dgtsv.self)
    #elseif os(macOS)
    static let dgtsv: FunctionType.LAPACKE_dgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsv: FunctionType.LAPACKE_cgtsv? = load(name: "LAPACKE_cgtsv", as: FunctionType.LAPACKE_cgtsv.self)
    #elseif os(macOS)
    static let cgtsv: FunctionType.LAPACKE_cgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsv: FunctionType.LAPACKE_zgtsv? = load(name: "LAPACKE_zgtsv", as: FunctionType.LAPACKE_zgtsv.self)
    #elseif os(macOS)
    static let zgtsv: FunctionType.LAPACKE_zgtsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsvx: FunctionType.LAPACKE_sgtsvx? = load(name: "LAPACKE_sgtsvx", as: FunctionType.LAPACKE_sgtsvx.self)
    #elseif os(macOS)
    static let sgtsvx: FunctionType.LAPACKE_sgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsvx: FunctionType.LAPACKE_dgtsvx? = load(name: "LAPACKE_dgtsvx", as: FunctionType.LAPACKE_dgtsvx.self)
    #elseif os(macOS)
    static let dgtsvx: FunctionType.LAPACKE_dgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsvx: FunctionType.LAPACKE_cgtsvx? = load(name: "LAPACKE_cgtsvx", as: FunctionType.LAPACKE_cgtsvx.self)
    #elseif os(macOS)
    static let cgtsvx: FunctionType.LAPACKE_cgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsvx: FunctionType.LAPACKE_zgtsvx? = load(name: "LAPACKE_zgtsvx", as: FunctionType.LAPACKE_zgtsvx.self)
    #elseif os(macOS)
    static let zgtsvx: FunctionType.LAPACKE_zgtsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrf: FunctionType.LAPACKE_sgttrf? = load(name: "LAPACKE_sgttrf", as: FunctionType.LAPACKE_sgttrf.self)
    #elseif os(macOS)
    static let sgttrf: FunctionType.LAPACKE_sgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrf: FunctionType.LAPACKE_dgttrf? = load(name: "LAPACKE_dgttrf", as: FunctionType.LAPACKE_dgttrf.self)
    #elseif os(macOS)
    static let dgttrf: FunctionType.LAPACKE_dgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrf: FunctionType.LAPACKE_cgttrf? = load(name: "LAPACKE_cgttrf", as: FunctionType.LAPACKE_cgttrf.self)
    #elseif os(macOS)
    static let cgttrf: FunctionType.LAPACKE_cgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrf: FunctionType.LAPACKE_zgttrf? = load(name: "LAPACKE_zgttrf", as: FunctionType.LAPACKE_zgttrf.self)
    #elseif os(macOS)
    static let zgttrf: FunctionType.LAPACKE_zgttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrs: FunctionType.LAPACKE_sgttrs? = load(name: "LAPACKE_sgttrs", as: FunctionType.LAPACKE_sgttrs.self)
    #elseif os(macOS)
    static let sgttrs: FunctionType.LAPACKE_sgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrs: FunctionType.LAPACKE_dgttrs? = load(name: "LAPACKE_dgttrs", as: FunctionType.LAPACKE_dgttrs.self)
    #elseif os(macOS)
    static let dgttrs: FunctionType.LAPACKE_dgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrs: FunctionType.LAPACKE_cgttrs? = load(name: "LAPACKE_cgttrs", as: FunctionType.LAPACKE_cgttrs.self)
    #elseif os(macOS)
    static let cgttrs: FunctionType.LAPACKE_cgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrs: FunctionType.LAPACKE_zgttrs? = load(name: "LAPACKE_zgttrs", as: FunctionType.LAPACKE_zgttrs.self)
    #elseif os(macOS)
    static let zgttrs: FunctionType.LAPACKE_zgttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev: FunctionType.LAPACKE_chbev? = load(name: "LAPACKE_chbev", as: FunctionType.LAPACKE_chbev.self)
    #elseif os(macOS)
    static let chbev: FunctionType.LAPACKE_chbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev: FunctionType.LAPACKE_zhbev? = load(name: "LAPACKE_zhbev", as: FunctionType.LAPACKE_zhbev.self)
    #elseif os(macOS)
    static let zhbev: FunctionType.LAPACKE_zhbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd: FunctionType.LAPACKE_chbevd? = load(name: "LAPACKE_chbevd", as: FunctionType.LAPACKE_chbevd.self)
    #elseif os(macOS)
    static let chbevd: FunctionType.LAPACKE_chbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd: FunctionType.LAPACKE_zhbevd? = load(name: "LAPACKE_zhbevd", as: FunctionType.LAPACKE_zhbevd.self)
    #elseif os(macOS)
    static let zhbevd: FunctionType.LAPACKE_zhbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx: FunctionType.LAPACKE_chbevx? = load(name: "LAPACKE_chbevx", as: FunctionType.LAPACKE_chbevx.self)
    #elseif os(macOS)
    static let chbevx: FunctionType.LAPACKE_chbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx: FunctionType.LAPACKE_zhbevx? = load(name: "LAPACKE_zhbevx", as: FunctionType.LAPACKE_zhbevx.self)
    #elseif os(macOS)
    static let zhbevx: FunctionType.LAPACKE_zhbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgst: FunctionType.LAPACKE_chbgst? = load(name: "LAPACKE_chbgst", as: FunctionType.LAPACKE_chbgst.self)
    #elseif os(macOS)
    static let chbgst: FunctionType.LAPACKE_chbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgst: FunctionType.LAPACKE_zhbgst? = load(name: "LAPACKE_zhbgst", as: FunctionType.LAPACKE_zhbgst.self)
    #elseif os(macOS)
    static let zhbgst: FunctionType.LAPACKE_zhbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgv: FunctionType.LAPACKE_chbgv? = load(name: "LAPACKE_chbgv", as: FunctionType.LAPACKE_chbgv.self)
    #elseif os(macOS)
    static let chbgv: FunctionType.LAPACKE_chbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgv: FunctionType.LAPACKE_zhbgv? = load(name: "LAPACKE_zhbgv", as: FunctionType.LAPACKE_zhbgv.self)
    #elseif os(macOS)
    static let zhbgv: FunctionType.LAPACKE_zhbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvd: FunctionType.LAPACKE_chbgvd? = load(name: "LAPACKE_chbgvd", as: FunctionType.LAPACKE_chbgvd.self)
    #elseif os(macOS)
    static let chbgvd: FunctionType.LAPACKE_chbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvd: FunctionType.LAPACKE_zhbgvd? = load(name: "LAPACKE_zhbgvd", as: FunctionType.LAPACKE_zhbgvd.self)
    #elseif os(macOS)
    static let zhbgvd: FunctionType.LAPACKE_zhbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvx: FunctionType.LAPACKE_chbgvx? = load(name: "LAPACKE_chbgvx", as: FunctionType.LAPACKE_chbgvx.self)
    #elseif os(macOS)
    static let chbgvx: FunctionType.LAPACKE_chbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvx: FunctionType.LAPACKE_zhbgvx? = load(name: "LAPACKE_zhbgvx", as: FunctionType.LAPACKE_zhbgvx.self)
    #elseif os(macOS)
    static let zhbgvx: FunctionType.LAPACKE_zhbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbtrd: FunctionType.LAPACKE_chbtrd? = load(name: "LAPACKE_chbtrd", as: FunctionType.LAPACKE_chbtrd.self)
    #elseif os(macOS)
    static let chbtrd: FunctionType.LAPACKE_chbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbtrd: FunctionType.LAPACKE_zhbtrd? = load(name: "LAPACKE_zhbtrd", as: FunctionType.LAPACKE_zhbtrd.self)
    #elseif os(macOS)
    static let zhbtrd: FunctionType.LAPACKE_zhbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon: FunctionType.LAPACKE_checon? = load(name: "LAPACKE_checon", as: FunctionType.LAPACKE_checon.self)
    #elseif os(macOS)
    static let checon: FunctionType.LAPACKE_checon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon: FunctionType.LAPACKE_zhecon? = load(name: "LAPACKE_zhecon", as: FunctionType.LAPACKE_zhecon.self)
    #elseif os(macOS)
    static let zhecon: FunctionType.LAPACKE_zhecon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheequb: FunctionType.LAPACKE_cheequb? = load(name: "LAPACKE_cheequb", as: FunctionType.LAPACKE_cheequb.self)
    #elseif os(macOS)
    static let cheequb: FunctionType.LAPACKE_cheequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheequb: FunctionType.LAPACKE_zheequb? = load(name: "LAPACKE_zheequb", as: FunctionType.LAPACKE_zheequb.self)
    #elseif os(macOS)
    static let zheequb: FunctionType.LAPACKE_zheequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev: FunctionType.LAPACKE_cheev? = load(name: "LAPACKE_cheev", as: FunctionType.LAPACKE_cheev.self)
    #elseif os(macOS)
    static let cheev: FunctionType.LAPACKE_cheev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev: FunctionType.LAPACKE_zheev? = load(name: "LAPACKE_zheev", as: FunctionType.LAPACKE_zheev.self)
    #elseif os(macOS)
    static let zheev: FunctionType.LAPACKE_zheev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd: FunctionType.LAPACKE_cheevd? = load(name: "LAPACKE_cheevd", as: FunctionType.LAPACKE_cheevd.self)
    #elseif os(macOS)
    static let cheevd: FunctionType.LAPACKE_cheevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd: FunctionType.LAPACKE_zheevd? = load(name: "LAPACKE_zheevd", as: FunctionType.LAPACKE_zheevd.self)
    #elseif os(macOS)
    static let zheevd: FunctionType.LAPACKE_zheevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr: FunctionType.LAPACKE_cheevr? = load(name: "LAPACKE_cheevr", as: FunctionType.LAPACKE_cheevr.self)
    #elseif os(macOS)
    static let cheevr: FunctionType.LAPACKE_cheevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr: FunctionType.LAPACKE_zheevr? = load(name: "LAPACKE_zheevr", as: FunctionType.LAPACKE_zheevr.self)
    #elseif os(macOS)
    static let zheevr: FunctionType.LAPACKE_zheevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx: FunctionType.LAPACKE_cheevx? = load(name: "LAPACKE_cheevx", as: FunctionType.LAPACKE_cheevx.self)
    #elseif os(macOS)
    static let cheevx: FunctionType.LAPACKE_cheevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx: FunctionType.LAPACKE_zheevx? = load(name: "LAPACKE_zheevx", as: FunctionType.LAPACKE_zheevx.self)
    #elseif os(macOS)
    static let zheevx: FunctionType.LAPACKE_zheevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegst: FunctionType.LAPACKE_chegst? = load(name: "LAPACKE_chegst", as: FunctionType.LAPACKE_chegst.self)
    #elseif os(macOS)
    static let chegst: FunctionType.LAPACKE_chegst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegst: FunctionType.LAPACKE_zhegst? = load(name: "LAPACKE_zhegst", as: FunctionType.LAPACKE_zhegst.self)
    #elseif os(macOS)
    static let zhegst: FunctionType.LAPACKE_zhegst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv: FunctionType.LAPACKE_chegv? = load(name: "LAPACKE_chegv", as: FunctionType.LAPACKE_chegv.self)
    #elseif os(macOS)
    static let chegv: FunctionType.LAPACKE_chegv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv: FunctionType.LAPACKE_zhegv? = load(name: "LAPACKE_zhegv", as: FunctionType.LAPACKE_zhegv.self)
    #elseif os(macOS)
    static let zhegv: FunctionType.LAPACKE_zhegv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvd: FunctionType.LAPACKE_chegvd? = load(name: "LAPACKE_chegvd", as: FunctionType.LAPACKE_chegvd.self)
    #elseif os(macOS)
    static let chegvd: FunctionType.LAPACKE_chegvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvd: FunctionType.LAPACKE_zhegvd? = load(name: "LAPACKE_zhegvd", as: FunctionType.LAPACKE_zhegvd.self)
    #elseif os(macOS)
    static let zhegvd: FunctionType.LAPACKE_zhegvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvx: FunctionType.LAPACKE_chegvx? = load(name: "LAPACKE_chegvx", as: FunctionType.LAPACKE_chegvx.self)
    #elseif os(macOS)
    static let chegvx: FunctionType.LAPACKE_chegvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvx: FunctionType.LAPACKE_zhegvx? = load(name: "LAPACKE_zhegvx", as: FunctionType.LAPACKE_zhegvx.self)
    #elseif os(macOS)
    static let zhegvx: FunctionType.LAPACKE_zhegvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfs: FunctionType.LAPACKE_cherfs? = load(name: "LAPACKE_cherfs", as: FunctionType.LAPACKE_cherfs.self)
    #elseif os(macOS)
    static let cherfs: FunctionType.LAPACKE_cherfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfs: FunctionType.LAPACKE_zherfs? = load(name: "LAPACKE_zherfs", as: FunctionType.LAPACKE_zherfs.self)
    #elseif os(macOS)
    static let zherfs: FunctionType.LAPACKE_zherfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfsx: FunctionType.LAPACKE_cherfsx? = load(name: "LAPACKE_cherfsx", as: FunctionType.LAPACKE_cherfsx.self)
    #elseif os(macOS)
    static let cherfsx: FunctionType.LAPACKE_cherfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfsx: FunctionType.LAPACKE_zherfsx? = load(name: "LAPACKE_zherfsx", as: FunctionType.LAPACKE_zherfsx.self)
    #elseif os(macOS)
    static let zherfsx: FunctionType.LAPACKE_zherfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv: FunctionType.LAPACKE_chesv? = load(name: "LAPACKE_chesv", as: FunctionType.LAPACKE_chesv.self)
    #elseif os(macOS)
    static let chesv: FunctionType.LAPACKE_chesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv: FunctionType.LAPACKE_zhesv? = load(name: "LAPACKE_zhesv", as: FunctionType.LAPACKE_zhesv.self)
    #elseif os(macOS)
    static let zhesv: FunctionType.LAPACKE_zhesv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvx: FunctionType.LAPACKE_chesvx? = load(name: "LAPACKE_chesvx", as: FunctionType.LAPACKE_chesvx.self)
    #elseif os(macOS)
    static let chesvx: FunctionType.LAPACKE_chesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvx: FunctionType.LAPACKE_zhesvx? = load(name: "LAPACKE_zhesvx", as: FunctionType.LAPACKE_zhesvx.self)
    #elseif os(macOS)
    static let zhesvx: FunctionType.LAPACKE_zhesvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvxx: FunctionType.LAPACKE_chesvxx? = load(name: "LAPACKE_chesvxx", as: FunctionType.LAPACKE_chesvxx.self)
    #elseif os(macOS)
    static let chesvxx: FunctionType.LAPACKE_chesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvxx: FunctionType.LAPACKE_zhesvxx? = load(name: "LAPACKE_zhesvxx", as: FunctionType.LAPACKE_zhesvxx.self)
    #elseif os(macOS)
    static let zhesvxx: FunctionType.LAPACKE_zhesvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrd: FunctionType.LAPACKE_chetrd? = load(name: "LAPACKE_chetrd", as: FunctionType.LAPACKE_chetrd.self)
    #elseif os(macOS)
    static let chetrd: FunctionType.LAPACKE_chetrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrd: FunctionType.LAPACKE_zhetrd? = load(name: "LAPACKE_zhetrd", as: FunctionType.LAPACKE_zhetrd.self)
    #elseif os(macOS)
    static let zhetrd: FunctionType.LAPACKE_zhetrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf: FunctionType.LAPACKE_chetrf? = load(name: "LAPACKE_chetrf", as: FunctionType.LAPACKE_chetrf.self)
    #elseif os(macOS)
    static let chetrf: FunctionType.LAPACKE_chetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf: FunctionType.LAPACKE_zhetrf? = load(name: "LAPACKE_zhetrf", as: FunctionType.LAPACKE_zhetrf.self)
    #elseif os(macOS)
    static let zhetrf: FunctionType.LAPACKE_zhetrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri: FunctionType.LAPACKE_chetri? = load(name: "LAPACKE_chetri", as: FunctionType.LAPACKE_chetri.self)
    #elseif os(macOS)
    static let chetri: FunctionType.LAPACKE_chetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri: FunctionType.LAPACKE_zhetri? = load(name: "LAPACKE_zhetri", as: FunctionType.LAPACKE_zhetri.self)
    #elseif os(macOS)
    static let zhetri: FunctionType.LAPACKE_zhetri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs: FunctionType.LAPACKE_chetrs? = load(name: "LAPACKE_chetrs", as: FunctionType.LAPACKE_chetrs.self)
    #elseif os(macOS)
    static let chetrs: FunctionType.LAPACKE_chetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs: FunctionType.LAPACKE_zhetrs? = load(name: "LAPACKE_zhetrs", as: FunctionType.LAPACKE_zhetrs.self)
    #elseif os(macOS)
    static let zhetrs: FunctionType.LAPACKE_zhetrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chfrk: FunctionType.LAPACKE_chfrk? = load(name: "LAPACKE_chfrk", as: FunctionType.LAPACKE_chfrk.self)
    #elseif os(macOS)
    static let chfrk: FunctionType.LAPACKE_chfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhfrk: FunctionType.LAPACKE_zhfrk? = load(name: "LAPACKE_zhfrk", as: FunctionType.LAPACKE_zhfrk.self)
    #elseif os(macOS)
    static let zhfrk: FunctionType.LAPACKE_zhfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shgeqz: FunctionType.LAPACKE_shgeqz? = load(name: "LAPACKE_shgeqz", as: FunctionType.LAPACKE_shgeqz.self)
    #elseif os(macOS)
    static let shgeqz: FunctionType.LAPACKE_shgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhgeqz: FunctionType.LAPACKE_dhgeqz? = load(name: "LAPACKE_dhgeqz", as: FunctionType.LAPACKE_dhgeqz.self)
    #elseif os(macOS)
    static let dhgeqz: FunctionType.LAPACKE_dhgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chgeqz: FunctionType.LAPACKE_chgeqz? = load(name: "LAPACKE_chgeqz", as: FunctionType.LAPACKE_chgeqz.self)
    #elseif os(macOS)
    static let chgeqz: FunctionType.LAPACKE_chgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhgeqz: FunctionType.LAPACKE_zhgeqz? = load(name: "LAPACKE_zhgeqz", as: FunctionType.LAPACKE_zhgeqz.self)
    #elseif os(macOS)
    static let zhgeqz: FunctionType.LAPACKE_zhgeqz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpcon: FunctionType.LAPACKE_chpcon? = load(name: "LAPACKE_chpcon", as: FunctionType.LAPACKE_chpcon.self)
    #elseif os(macOS)
    static let chpcon: FunctionType.LAPACKE_chpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpcon: FunctionType.LAPACKE_zhpcon? = load(name: "LAPACKE_zhpcon", as: FunctionType.LAPACKE_zhpcon.self)
    #elseif os(macOS)
    static let zhpcon: FunctionType.LAPACKE_zhpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpev: FunctionType.LAPACKE_chpev? = load(name: "LAPACKE_chpev", as: FunctionType.LAPACKE_chpev.self)
    #elseif os(macOS)
    static let chpev: FunctionType.LAPACKE_chpev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpev: FunctionType.LAPACKE_zhpev? = load(name: "LAPACKE_zhpev", as: FunctionType.LAPACKE_zhpev.self)
    #elseif os(macOS)
    static let zhpev: FunctionType.LAPACKE_zhpev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevd: FunctionType.LAPACKE_chpevd? = load(name: "LAPACKE_chpevd", as: FunctionType.LAPACKE_chpevd.self)
    #elseif os(macOS)
    static let chpevd: FunctionType.LAPACKE_chpevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevd: FunctionType.LAPACKE_zhpevd? = load(name: "LAPACKE_zhpevd", as: FunctionType.LAPACKE_zhpevd.self)
    #elseif os(macOS)
    static let zhpevd: FunctionType.LAPACKE_zhpevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevx: FunctionType.LAPACKE_chpevx? = load(name: "LAPACKE_chpevx", as: FunctionType.LAPACKE_chpevx.self)
    #elseif os(macOS)
    static let chpevx: FunctionType.LAPACKE_chpevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevx: FunctionType.LAPACKE_zhpevx? = load(name: "LAPACKE_zhpevx", as: FunctionType.LAPACKE_zhpevx.self)
    #elseif os(macOS)
    static let zhpevx: FunctionType.LAPACKE_zhpevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgst: FunctionType.LAPACKE_chpgst? = load(name: "LAPACKE_chpgst", as: FunctionType.LAPACKE_chpgst.self)
    #elseif os(macOS)
    static let chpgst: FunctionType.LAPACKE_chpgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgst: FunctionType.LAPACKE_zhpgst? = load(name: "LAPACKE_zhpgst", as: FunctionType.LAPACKE_zhpgst.self)
    #elseif os(macOS)
    static let zhpgst: FunctionType.LAPACKE_zhpgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgv: FunctionType.LAPACKE_chpgv? = load(name: "LAPACKE_chpgv", as: FunctionType.LAPACKE_chpgv.self)
    #elseif os(macOS)
    static let chpgv: FunctionType.LAPACKE_chpgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgv: FunctionType.LAPACKE_zhpgv? = load(name: "LAPACKE_zhpgv", as: FunctionType.LAPACKE_zhpgv.self)
    #elseif os(macOS)
    static let zhpgv: FunctionType.LAPACKE_zhpgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvd: FunctionType.LAPACKE_chpgvd? = load(name: "LAPACKE_chpgvd", as: FunctionType.LAPACKE_chpgvd.self)
    #elseif os(macOS)
    static let chpgvd: FunctionType.LAPACKE_chpgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvd: FunctionType.LAPACKE_zhpgvd? = load(name: "LAPACKE_zhpgvd", as: FunctionType.LAPACKE_zhpgvd.self)
    #elseif os(macOS)
    static let zhpgvd: FunctionType.LAPACKE_zhpgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvx: FunctionType.LAPACKE_chpgvx? = load(name: "LAPACKE_chpgvx", as: FunctionType.LAPACKE_chpgvx.self)
    #elseif os(macOS)
    static let chpgvx: FunctionType.LAPACKE_chpgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvx: FunctionType.LAPACKE_zhpgvx? = load(name: "LAPACKE_zhpgvx", as: FunctionType.LAPACKE_zhpgvx.self)
    #elseif os(macOS)
    static let zhpgvx: FunctionType.LAPACKE_zhpgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chprfs: FunctionType.LAPACKE_chprfs? = load(name: "LAPACKE_chprfs", as: FunctionType.LAPACKE_chprfs.self)
    #elseif os(macOS)
    static let chprfs: FunctionType.LAPACKE_chprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhprfs: FunctionType.LAPACKE_zhprfs? = load(name: "LAPACKE_zhprfs", as: FunctionType.LAPACKE_zhprfs.self)
    #elseif os(macOS)
    static let zhprfs: FunctionType.LAPACKE_zhprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsv: FunctionType.LAPACKE_chpsv? = load(name: "LAPACKE_chpsv", as: FunctionType.LAPACKE_chpsv.self)
    #elseif os(macOS)
    static let chpsv: FunctionType.LAPACKE_chpsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsv: FunctionType.LAPACKE_zhpsv? = load(name: "LAPACKE_zhpsv", as: FunctionType.LAPACKE_zhpsv.self)
    #elseif os(macOS)
    static let zhpsv: FunctionType.LAPACKE_zhpsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsvx: FunctionType.LAPACKE_chpsvx? = load(name: "LAPACKE_chpsvx", as: FunctionType.LAPACKE_chpsvx.self)
    #elseif os(macOS)
    static let chpsvx: FunctionType.LAPACKE_chpsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsvx: FunctionType.LAPACKE_zhpsvx? = load(name: "LAPACKE_zhpsvx", as: FunctionType.LAPACKE_zhpsvx.self)
    #elseif os(macOS)
    static let zhpsvx: FunctionType.LAPACKE_zhpsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrd: FunctionType.LAPACKE_chptrd? = load(name: "LAPACKE_chptrd", as: FunctionType.LAPACKE_chptrd.self)
    #elseif os(macOS)
    static let chptrd: FunctionType.LAPACKE_chptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrd: FunctionType.LAPACKE_zhptrd? = load(name: "LAPACKE_zhptrd", as: FunctionType.LAPACKE_zhptrd.self)
    #elseif os(macOS)
    static let zhptrd: FunctionType.LAPACKE_zhptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrf: FunctionType.LAPACKE_chptrf? = load(name: "LAPACKE_chptrf", as: FunctionType.LAPACKE_chptrf.self)
    #elseif os(macOS)
    static let chptrf: FunctionType.LAPACKE_chptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrf: FunctionType.LAPACKE_zhptrf? = load(name: "LAPACKE_zhptrf", as: FunctionType.LAPACKE_zhptrf.self)
    #elseif os(macOS)
    static let zhptrf: FunctionType.LAPACKE_zhptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptri: FunctionType.LAPACKE_chptri? = load(name: "LAPACKE_chptri", as: FunctionType.LAPACKE_chptri.self)
    #elseif os(macOS)
    static let chptri: FunctionType.LAPACKE_chptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptri: FunctionType.LAPACKE_zhptri? = load(name: "LAPACKE_zhptri", as: FunctionType.LAPACKE_zhptri.self)
    #elseif os(macOS)
    static let zhptri: FunctionType.LAPACKE_zhptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrs: FunctionType.LAPACKE_chptrs? = load(name: "LAPACKE_chptrs", as: FunctionType.LAPACKE_chptrs.self)
    #elseif os(macOS)
    static let chptrs: FunctionType.LAPACKE_chptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrs: FunctionType.LAPACKE_zhptrs? = load(name: "LAPACKE_zhptrs", as: FunctionType.LAPACKE_zhptrs.self)
    #elseif os(macOS)
    static let zhptrs: FunctionType.LAPACKE_zhptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shsein: FunctionType.LAPACKE_shsein? = load(name: "LAPACKE_shsein", as: FunctionType.LAPACKE_shsein.self)
    #elseif os(macOS)
    static let shsein: FunctionType.LAPACKE_shsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhsein: FunctionType.LAPACKE_dhsein? = load(name: "LAPACKE_dhsein", as: FunctionType.LAPACKE_dhsein.self)
    #elseif os(macOS)
    static let dhsein: FunctionType.LAPACKE_dhsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chsein: FunctionType.LAPACKE_chsein? = load(name: "LAPACKE_chsein", as: FunctionType.LAPACKE_chsein.self)
    #elseif os(macOS)
    static let chsein: FunctionType.LAPACKE_chsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhsein: FunctionType.LAPACKE_zhsein? = load(name: "LAPACKE_zhsein", as: FunctionType.LAPACKE_zhsein.self)
    #elseif os(macOS)
    static let zhsein: FunctionType.LAPACKE_zhsein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shseqr: FunctionType.LAPACKE_shseqr? = load(name: "LAPACKE_shseqr", as: FunctionType.LAPACKE_shseqr.self)
    #elseif os(macOS)
    static let shseqr: FunctionType.LAPACKE_shseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhseqr: FunctionType.LAPACKE_dhseqr? = load(name: "LAPACKE_dhseqr", as: FunctionType.LAPACKE_dhseqr.self)
    #elseif os(macOS)
    static let dhseqr: FunctionType.LAPACKE_dhseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chseqr: FunctionType.LAPACKE_chseqr? = load(name: "LAPACKE_chseqr", as: FunctionType.LAPACKE_chseqr.self)
    #elseif os(macOS)
    static let chseqr: FunctionType.LAPACKE_chseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhseqr: FunctionType.LAPACKE_zhseqr? = load(name: "LAPACKE_zhseqr", as: FunctionType.LAPACKE_zhseqr.self)
    #elseif os(macOS)
    static let zhseqr: FunctionType.LAPACKE_zhseqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacgv: FunctionType.LAPACKE_clacgv? = load(name: "LAPACKE_clacgv", as: FunctionType.LAPACKE_clacgv.self)
    #elseif os(macOS)
    static let clacgv: FunctionType.LAPACKE_clacgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacgv: FunctionType.LAPACKE_zlacgv? = load(name: "LAPACKE_zlacgv", as: FunctionType.LAPACKE_zlacgv.self)
    #elseif os(macOS)
    static let zlacgv: FunctionType.LAPACKE_zlacgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacn2: FunctionType.LAPACKE_slacn2? = load(name: "LAPACKE_slacn2", as: FunctionType.LAPACKE_slacn2.self)
    #elseif os(macOS)
    static let slacn2: FunctionType.LAPACKE_slacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacn2: FunctionType.LAPACKE_dlacn2? = load(name: "LAPACKE_dlacn2", as: FunctionType.LAPACKE_dlacn2.self)
    #elseif os(macOS)
    static let dlacn2: FunctionType.LAPACKE_dlacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacn2: FunctionType.LAPACKE_clacn2? = load(name: "LAPACKE_clacn2", as: FunctionType.LAPACKE_clacn2.self)
    #elseif os(macOS)
    static let clacn2: FunctionType.LAPACKE_clacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacn2: FunctionType.LAPACKE_zlacn2? = load(name: "LAPACKE_zlacn2", as: FunctionType.LAPACKE_zlacn2.self)
    #elseif os(macOS)
    static let zlacn2: FunctionType.LAPACKE_zlacn2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacpy: FunctionType.LAPACKE_slacpy? = load(name: "LAPACKE_slacpy", as: FunctionType.LAPACKE_slacpy.self)
    #elseif os(macOS)
    static let slacpy: FunctionType.LAPACKE_slacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacpy: FunctionType.LAPACKE_dlacpy? = load(name: "LAPACKE_dlacpy", as: FunctionType.LAPACKE_dlacpy.self)
    #elseif os(macOS)
    static let dlacpy: FunctionType.LAPACKE_dlacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacpy: FunctionType.LAPACKE_clacpy? = load(name: "LAPACKE_clacpy", as: FunctionType.LAPACKE_clacpy.self)
    #elseif os(macOS)
    static let clacpy: FunctionType.LAPACKE_clacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacpy: FunctionType.LAPACKE_zlacpy? = load(name: "LAPACKE_zlacpy", as: FunctionType.LAPACKE_zlacpy.self)
    #elseif os(macOS)
    static let zlacpy: FunctionType.LAPACKE_zlacpy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacp2: FunctionType.LAPACKE_clacp2? = load(name: "LAPACKE_clacp2", as: FunctionType.LAPACKE_clacp2.self)
    #elseif os(macOS)
    static let clacp2: FunctionType.LAPACKE_clacp2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacp2: FunctionType.LAPACKE_zlacp2? = load(name: "LAPACKE_zlacp2", as: FunctionType.LAPACKE_zlacp2.self)
    #elseif os(macOS)
    static let zlacp2: FunctionType.LAPACKE_zlacp2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlag2c: FunctionType.LAPACKE_zlag2c? = load(name: "LAPACKE_zlag2c", as: FunctionType.LAPACKE_zlag2c.self)
    #elseif os(macOS)
    static let zlag2c: FunctionType.LAPACKE_zlag2c? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slag2d: FunctionType.LAPACKE_slag2d? = load(name: "LAPACKE_slag2d", as: FunctionType.LAPACKE_slag2d.self)
    #elseif os(macOS)
    static let slag2d: FunctionType.LAPACKE_slag2d? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlag2s: FunctionType.LAPACKE_dlag2s? = load(name: "LAPACKE_dlag2s", as: FunctionType.LAPACKE_dlag2s.self)
    #elseif os(macOS)
    static let dlag2s: FunctionType.LAPACKE_dlag2s? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clag2z: FunctionType.LAPACKE_clag2z? = load(name: "LAPACKE_clag2z", as: FunctionType.LAPACKE_clag2z.self)
    #elseif os(macOS)
    static let clag2z: FunctionType.LAPACKE_clag2z? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagge: FunctionType.LAPACKE_slagge? = load(name: "LAPACKE_slagge", as: FunctionType.LAPACKE_slagge.self)
    #elseif os(macOS)
    static let slagge: FunctionType.LAPACKE_slagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagge: FunctionType.LAPACKE_dlagge? = load(name: "LAPACKE_dlagge", as: FunctionType.LAPACKE_dlagge.self)
    #elseif os(macOS)
    static let dlagge: FunctionType.LAPACKE_dlagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagge: FunctionType.LAPACKE_clagge? = load(name: "LAPACKE_clagge", as: FunctionType.LAPACKE_clagge.self)
    #elseif os(macOS)
    static let clagge: FunctionType.LAPACKE_clagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagge: FunctionType.LAPACKE_zlagge? = load(name: "LAPACKE_zlagge", as: FunctionType.LAPACKE_zlagge.self)
    #elseif os(macOS)
    static let zlagge: FunctionType.LAPACKE_zlagge? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slamch: FunctionType.LAPACKE_slamch? = load(name: "LAPACKE_slamch", as: FunctionType.LAPACKE_slamch.self)
    #elseif os(macOS)
    static let slamch: FunctionType.LAPACKE_slamch? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlamch: FunctionType.LAPACKE_dlamch? = load(name: "LAPACKE_dlamch", as: FunctionType.LAPACKE_dlamch.self)
    #elseif os(macOS)
    static let dlamch: FunctionType.LAPACKE_dlamch? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slangb: FunctionType.LAPACKE_slangb? = load(name: "LAPACKE_slangb", as: FunctionType.LAPACKE_slangb.self)
    #elseif os(macOS)
    static let slangb: FunctionType.LAPACKE_slangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlangb: FunctionType.LAPACKE_dlangb? = load(name: "LAPACKE_dlangb", as: FunctionType.LAPACKE_dlangb.self)
    #elseif os(macOS)
    static let dlangb: FunctionType.LAPACKE_dlangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clangb: FunctionType.LAPACKE_clangb? = load(name: "LAPACKE_clangb", as: FunctionType.LAPACKE_clangb.self)
    #elseif os(macOS)
    static let clangb: FunctionType.LAPACKE_clangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlangb: FunctionType.LAPACKE_zlangb? = load(name: "LAPACKE_zlangb", as: FunctionType.LAPACKE_zlangb.self)
    #elseif os(macOS)
    static let zlangb: FunctionType.LAPACKE_zlangb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slange: FunctionType.LAPACKE_slange? = load(name: "LAPACKE_slange", as: FunctionType.LAPACKE_slange.self)
    #elseif os(macOS)
    static let slange: FunctionType.LAPACKE_slange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlange: FunctionType.LAPACKE_dlange? = load(name: "LAPACKE_dlange", as: FunctionType.LAPACKE_dlange.self)
    #elseif os(macOS)
    static let dlange: FunctionType.LAPACKE_dlange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clange: FunctionType.LAPACKE_clange? = load(name: "LAPACKE_clange", as: FunctionType.LAPACKE_clange.self)
    #elseif os(macOS)
    static let clange: FunctionType.LAPACKE_clange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlange: FunctionType.LAPACKE_zlange? = load(name: "LAPACKE_zlange", as: FunctionType.LAPACKE_zlange.self)
    #elseif os(macOS)
    static let zlange: FunctionType.LAPACKE_zlange? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clanhe: FunctionType.LAPACKE_clanhe? = load(name: "LAPACKE_clanhe", as: FunctionType.LAPACKE_clanhe.self)
    #elseif os(macOS)
    static let clanhe: FunctionType.LAPACKE_clanhe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlanhe: FunctionType.LAPACKE_zlanhe? = load(name: "LAPACKE_zlanhe", as: FunctionType.LAPACKE_zlanhe.self)
    #elseif os(macOS)
    static let zlanhe: FunctionType.LAPACKE_zlanhe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacrm: FunctionType.LAPACKE_clacrm? = load(name: "LAPACKE_clacrm", as: FunctionType.LAPACKE_clacrm.self)
    #elseif os(macOS)
    static let clacrm: FunctionType.LAPACKE_clacrm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacrm: FunctionType.LAPACKE_zlacrm? = load(name: "LAPACKE_zlacrm", as: FunctionType.LAPACKE_zlacrm.self)
    #elseif os(macOS)
    static let zlacrm: FunctionType.LAPACKE_zlacrm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarcm: FunctionType.LAPACKE_clarcm? = load(name: "LAPACKE_clarcm", as: FunctionType.LAPACKE_clarcm.self)
    #elseif os(macOS)
    static let clarcm: FunctionType.LAPACKE_clarcm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarcm: FunctionType.LAPACKE_zlarcm? = load(name: "LAPACKE_zlarcm", as: FunctionType.LAPACKE_zlarcm.self)
    #elseif os(macOS)
    static let zlarcm: FunctionType.LAPACKE_zlarcm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slansy: FunctionType.LAPACKE_slansy? = load(name: "LAPACKE_slansy", as: FunctionType.LAPACKE_slansy.self)
    #elseif os(macOS)
    static let slansy: FunctionType.LAPACKE_slansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlansy: FunctionType.LAPACKE_dlansy? = load(name: "LAPACKE_dlansy", as: FunctionType.LAPACKE_dlansy.self)
    #elseif os(macOS)
    static let dlansy: FunctionType.LAPACKE_dlansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clansy: FunctionType.LAPACKE_clansy? = load(name: "LAPACKE_clansy", as: FunctionType.LAPACKE_clansy.self)
    #elseif os(macOS)
    static let clansy: FunctionType.LAPACKE_clansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlansy: FunctionType.LAPACKE_zlansy? = load(name: "LAPACKE_zlansy", as: FunctionType.LAPACKE_zlansy.self)
    #elseif os(macOS)
    static let zlansy: FunctionType.LAPACKE_zlansy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slantr: FunctionType.LAPACKE_slantr? = load(name: "LAPACKE_slantr", as: FunctionType.LAPACKE_slantr.self)
    #elseif os(macOS)
    static let slantr: FunctionType.LAPACKE_slantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlantr: FunctionType.LAPACKE_dlantr? = load(name: "LAPACKE_dlantr", as: FunctionType.LAPACKE_dlantr.self)
    #elseif os(macOS)
    static let dlantr: FunctionType.LAPACKE_dlantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clantr: FunctionType.LAPACKE_clantr? = load(name: "LAPACKE_clantr", as: FunctionType.LAPACKE_clantr.self)
    #elseif os(macOS)
    static let clantr: FunctionType.LAPACKE_clantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlantr: FunctionType.LAPACKE_zlantr? = load(name: "LAPACKE_zlantr", as: FunctionType.LAPACKE_zlantr.self)
    #elseif os(macOS)
    static let zlantr: FunctionType.LAPACKE_zlantr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfb: FunctionType.LAPACKE_slarfb? = load(name: "LAPACKE_slarfb", as: FunctionType.LAPACKE_slarfb.self)
    #elseif os(macOS)
    static let slarfb: FunctionType.LAPACKE_slarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfb: FunctionType.LAPACKE_dlarfb? = load(name: "LAPACKE_dlarfb", as: FunctionType.LAPACKE_dlarfb.self)
    #elseif os(macOS)
    static let dlarfb: FunctionType.LAPACKE_dlarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfb: FunctionType.LAPACKE_clarfb? = load(name: "LAPACKE_clarfb", as: FunctionType.LAPACKE_clarfb.self)
    #elseif os(macOS)
    static let clarfb: FunctionType.LAPACKE_clarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfb: FunctionType.LAPACKE_zlarfb? = load(name: "LAPACKE_zlarfb", as: FunctionType.LAPACKE_zlarfb.self)
    #elseif os(macOS)
    static let zlarfb: FunctionType.LAPACKE_zlarfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfg: FunctionType.LAPACKE_slarfg? = load(name: "LAPACKE_slarfg", as: FunctionType.LAPACKE_slarfg.self)
    #elseif os(macOS)
    static let slarfg: FunctionType.LAPACKE_slarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfg: FunctionType.LAPACKE_dlarfg? = load(name: "LAPACKE_dlarfg", as: FunctionType.LAPACKE_dlarfg.self)
    #elseif os(macOS)
    static let dlarfg: FunctionType.LAPACKE_dlarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfg: FunctionType.LAPACKE_clarfg? = load(name: "LAPACKE_clarfg", as: FunctionType.LAPACKE_clarfg.self)
    #elseif os(macOS)
    static let clarfg: FunctionType.LAPACKE_clarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfg: FunctionType.LAPACKE_zlarfg? = load(name: "LAPACKE_zlarfg", as: FunctionType.LAPACKE_zlarfg.self)
    #elseif os(macOS)
    static let zlarfg: FunctionType.LAPACKE_zlarfg? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarft: FunctionType.LAPACKE_slarft? = load(name: "LAPACKE_slarft", as: FunctionType.LAPACKE_slarft.self)
    #elseif os(macOS)
    static let slarft: FunctionType.LAPACKE_slarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarft: FunctionType.LAPACKE_dlarft? = load(name: "LAPACKE_dlarft", as: FunctionType.LAPACKE_dlarft.self)
    #elseif os(macOS)
    static let dlarft: FunctionType.LAPACKE_dlarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarft: FunctionType.LAPACKE_clarft? = load(name: "LAPACKE_clarft", as: FunctionType.LAPACKE_clarft.self)
    #elseif os(macOS)
    static let clarft: FunctionType.LAPACKE_clarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarft: FunctionType.LAPACKE_zlarft? = load(name: "LAPACKE_zlarft", as: FunctionType.LAPACKE_zlarft.self)
    #elseif os(macOS)
    static let zlarft: FunctionType.LAPACKE_zlarft? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfx: FunctionType.LAPACKE_slarfx? = load(name: "LAPACKE_slarfx", as: FunctionType.LAPACKE_slarfx.self)
    #elseif os(macOS)
    static let slarfx: FunctionType.LAPACKE_slarfx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfx: FunctionType.LAPACKE_dlarfx? = load(name: "LAPACKE_dlarfx", as: FunctionType.LAPACKE_dlarfx.self)
    #elseif os(macOS)
    static let dlarfx: FunctionType.LAPACKE_dlarfx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarnv: FunctionType.LAPACKE_slarnv? = load(name: "LAPACKE_slarnv", as: FunctionType.LAPACKE_slarnv.self)
    #elseif os(macOS)
    static let slarnv: FunctionType.LAPACKE_slarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarnv: FunctionType.LAPACKE_dlarnv? = load(name: "LAPACKE_dlarnv", as: FunctionType.LAPACKE_dlarnv.self)
    #elseif os(macOS)
    static let dlarnv: FunctionType.LAPACKE_dlarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarnv: FunctionType.LAPACKE_clarnv? = load(name: "LAPACKE_clarnv", as: FunctionType.LAPACKE_clarnv.self)
    #elseif os(macOS)
    static let clarnv: FunctionType.LAPACKE_clarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarnv: FunctionType.LAPACKE_zlarnv? = load(name: "LAPACKE_zlarnv", as: FunctionType.LAPACKE_zlarnv.self)
    #elseif os(macOS)
    static let zlarnv: FunctionType.LAPACKE_zlarnv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slascl: FunctionType.LAPACKE_slascl? = load(name: "LAPACKE_slascl", as: FunctionType.LAPACKE_slascl.self)
    #elseif os(macOS)
    static let slascl: FunctionType.LAPACKE_slascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlascl: FunctionType.LAPACKE_dlascl? = load(name: "LAPACKE_dlascl", as: FunctionType.LAPACKE_dlascl.self)
    #elseif os(macOS)
    static let dlascl: FunctionType.LAPACKE_dlascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clascl: FunctionType.LAPACKE_clascl? = load(name: "LAPACKE_clascl", as: FunctionType.LAPACKE_clascl.self)
    #elseif os(macOS)
    static let clascl: FunctionType.LAPACKE_clascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlascl: FunctionType.LAPACKE_zlascl? = load(name: "LAPACKE_zlascl", as: FunctionType.LAPACKE_zlascl.self)
    #elseif os(macOS)
    static let zlascl: FunctionType.LAPACKE_zlascl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaset: FunctionType.LAPACKE_slaset? = load(name: "LAPACKE_slaset", as: FunctionType.LAPACKE_slaset.self)
    #elseif os(macOS)
    static let slaset: FunctionType.LAPACKE_slaset? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaset: FunctionType.LAPACKE_dlaset? = load(name: "LAPACKE_dlaset", as: FunctionType.LAPACKE_dlaset.self)
    #elseif os(macOS)
    static let dlaset: FunctionType.LAPACKE_dlaset? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slasrt: FunctionType.LAPACKE_slasrt? = load(name: "LAPACKE_slasrt", as: FunctionType.LAPACKE_slasrt.self)
    #elseif os(macOS)
    static let slasrt: FunctionType.LAPACKE_slasrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlasrt: FunctionType.LAPACKE_dlasrt? = load(name: "LAPACKE_dlasrt", as: FunctionType.LAPACKE_dlasrt.self)
    #elseif os(macOS)
    static let dlasrt: FunctionType.LAPACKE_dlasrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slassq: FunctionType.LAPACKE_slassq? = load(name: "LAPACKE_slassq", as: FunctionType.LAPACKE_slassq.self)
    #elseif os(macOS)
    static let slassq: FunctionType.LAPACKE_slassq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlassq: FunctionType.LAPACKE_dlassq? = load(name: "LAPACKE_dlassq", as: FunctionType.LAPACKE_dlassq.self)
    #elseif os(macOS)
    static let dlassq: FunctionType.LAPACKE_dlassq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let classq: FunctionType.LAPACKE_classq? = load(name: "LAPACKE_classq", as: FunctionType.LAPACKE_classq.self)
    #elseif os(macOS)
    static let classq: FunctionType.LAPACKE_classq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlassq: FunctionType.LAPACKE_zlassq? = load(name: "LAPACKE_zlassq", as: FunctionType.LAPACKE_zlassq.self)
    #elseif os(macOS)
    static let zlassq: FunctionType.LAPACKE_zlassq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaswp: FunctionType.LAPACKE_slaswp? = load(name: "LAPACKE_slaswp", as: FunctionType.LAPACKE_slaswp.self)
    #elseif os(macOS)
    static let slaswp: FunctionType.LAPACKE_slaswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaswp: FunctionType.LAPACKE_dlaswp? = load(name: "LAPACKE_dlaswp", as: FunctionType.LAPACKE_dlaswp.self)
    #elseif os(macOS)
    static let dlaswp: FunctionType.LAPACKE_dlaswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claswp: FunctionType.LAPACKE_claswp? = load(name: "LAPACKE_claswp", as: FunctionType.LAPACKE_claswp.self)
    #elseif os(macOS)
    static let claswp: FunctionType.LAPACKE_claswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaswp: FunctionType.LAPACKE_zlaswp? = load(name: "LAPACKE_zlaswp", as: FunctionType.LAPACKE_zlaswp.self)
    #elseif os(macOS)
    static let zlaswp: FunctionType.LAPACKE_zlaswp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slatms: FunctionType.LAPACKE_slatms? = load(name: "LAPACKE_slatms", as: FunctionType.LAPACKE_slatms.self)
    #elseif os(macOS)
    static let slatms: FunctionType.LAPACKE_slatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlatms: FunctionType.LAPACKE_dlatms? = load(name: "LAPACKE_dlatms", as: FunctionType.LAPACKE_dlatms.self)
    #elseif os(macOS)
    static let dlatms: FunctionType.LAPACKE_dlatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clatms: FunctionType.LAPACKE_clatms? = load(name: "LAPACKE_clatms", as: FunctionType.LAPACKE_clatms.self)
    #elseif os(macOS)
    static let clatms: FunctionType.LAPACKE_clatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlatms: FunctionType.LAPACKE_zlatms? = load(name: "LAPACKE_zlatms", as: FunctionType.LAPACKE_zlatms.self)
    #elseif os(macOS)
    static let zlatms: FunctionType.LAPACKE_zlatms? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slauum: FunctionType.LAPACKE_slauum? = load(name: "LAPACKE_slauum", as: FunctionType.LAPACKE_slauum.self)
    #elseif os(macOS)
    static let slauum: FunctionType.LAPACKE_slauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlauum: FunctionType.LAPACKE_dlauum? = load(name: "LAPACKE_dlauum", as: FunctionType.LAPACKE_dlauum.self)
    #elseif os(macOS)
    static let dlauum: FunctionType.LAPACKE_dlauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clauum: FunctionType.LAPACKE_clauum? = load(name: "LAPACKE_clauum", as: FunctionType.LAPACKE_clauum.self)
    #elseif os(macOS)
    static let clauum: FunctionType.LAPACKE_clauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlauum: FunctionType.LAPACKE_zlauum? = load(name: "LAPACKE_zlauum", as: FunctionType.LAPACKE_zlauum.self)
    #elseif os(macOS)
    static let zlauum: FunctionType.LAPACKE_zlauum? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopgtr: FunctionType.LAPACKE_sopgtr? = load(name: "LAPACKE_sopgtr", as: FunctionType.LAPACKE_sopgtr.self)
    #elseif os(macOS)
    static let sopgtr: FunctionType.LAPACKE_sopgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopgtr: FunctionType.LAPACKE_dopgtr? = load(name: "LAPACKE_dopgtr", as: FunctionType.LAPACKE_dopgtr.self)
    #elseif os(macOS)
    static let dopgtr: FunctionType.LAPACKE_dopgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopmtr: FunctionType.LAPACKE_sopmtr? = load(name: "LAPACKE_sopmtr", as: FunctionType.LAPACKE_sopmtr.self)
    #elseif os(macOS)
    static let sopmtr: FunctionType.LAPACKE_sopmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopmtr: FunctionType.LAPACKE_dopmtr? = load(name: "LAPACKE_dopmtr", as: FunctionType.LAPACKE_dopmtr.self)
    #elseif os(macOS)
    static let dopmtr: FunctionType.LAPACKE_dopmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgbr: FunctionType.LAPACKE_sorgbr? = load(name: "LAPACKE_sorgbr", as: FunctionType.LAPACKE_sorgbr.self)
    #elseif os(macOS)
    static let sorgbr: FunctionType.LAPACKE_sorgbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgbr: FunctionType.LAPACKE_dorgbr? = load(name: "LAPACKE_dorgbr", as: FunctionType.LAPACKE_dorgbr.self)
    #elseif os(macOS)
    static let dorgbr: FunctionType.LAPACKE_dorgbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorghr: FunctionType.LAPACKE_sorghr? = load(name: "LAPACKE_sorghr", as: FunctionType.LAPACKE_sorghr.self)
    #elseif os(macOS)
    static let sorghr: FunctionType.LAPACKE_sorghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorghr: FunctionType.LAPACKE_dorghr? = load(name: "LAPACKE_dorghr", as: FunctionType.LAPACKE_dorghr.self)
    #elseif os(macOS)
    static let dorghr: FunctionType.LAPACKE_dorghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorglq: FunctionType.LAPACKE_sorglq? = load(name: "LAPACKE_sorglq", as: FunctionType.LAPACKE_sorglq.self)
    #elseif os(macOS)
    static let sorglq: FunctionType.LAPACKE_sorglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorglq: FunctionType.LAPACKE_dorglq? = load(name: "LAPACKE_dorglq", as: FunctionType.LAPACKE_dorglq.self)
    #elseif os(macOS)
    static let dorglq: FunctionType.LAPACKE_dorglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgql: FunctionType.LAPACKE_sorgql? = load(name: "LAPACKE_sorgql", as: FunctionType.LAPACKE_sorgql.self)
    #elseif os(macOS)
    static let sorgql: FunctionType.LAPACKE_sorgql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgql: FunctionType.LAPACKE_dorgql? = load(name: "LAPACKE_dorgql", as: FunctionType.LAPACKE_dorgql.self)
    #elseif os(macOS)
    static let dorgql: FunctionType.LAPACKE_dorgql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgqr: FunctionType.LAPACKE_sorgqr? = load(name: "LAPACKE_sorgqr", as: FunctionType.LAPACKE_sorgqr.self)
    #elseif os(macOS)
    static let sorgqr: FunctionType.LAPACKE_sorgqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgqr: FunctionType.LAPACKE_dorgqr? = load(name: "LAPACKE_dorgqr", as: FunctionType.LAPACKE_dorgqr.self)
    #elseif os(macOS)
    static let dorgqr: FunctionType.LAPACKE_dorgqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgrq: FunctionType.LAPACKE_sorgrq? = load(name: "LAPACKE_sorgrq", as: FunctionType.LAPACKE_sorgrq.self)
    #elseif os(macOS)
    static let sorgrq: FunctionType.LAPACKE_sorgrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgrq: FunctionType.LAPACKE_dorgrq? = load(name: "LAPACKE_dorgrq", as: FunctionType.LAPACKE_dorgrq.self)
    #elseif os(macOS)
    static let dorgrq: FunctionType.LAPACKE_dorgrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtr: FunctionType.LAPACKE_sorgtr? = load(name: "LAPACKE_sorgtr", as: FunctionType.LAPACKE_sorgtr.self)
    #elseif os(macOS)
    static let sorgtr: FunctionType.LAPACKE_sorgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtr: FunctionType.LAPACKE_dorgtr? = load(name: "LAPACKE_dorgtr", as: FunctionType.LAPACKE_dorgtr.self)
    #elseif os(macOS)
    static let dorgtr: FunctionType.LAPACKE_dorgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtsqr_row: FunctionType.LAPACKE_sorgtsqr_row? = load(name: "LAPACKE_sorgtsqr_row", as: FunctionType.LAPACKE_sorgtsqr_row.self)
    #elseif os(macOS)
    static let sorgtsqr_row: FunctionType.LAPACKE_sorgtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtsqr_row: FunctionType.LAPACKE_dorgtsqr_row? = load(name: "LAPACKE_dorgtsqr_row", as: FunctionType.LAPACKE_dorgtsqr_row.self)
    #elseif os(macOS)
    static let dorgtsqr_row: FunctionType.LAPACKE_dorgtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormbr: FunctionType.LAPACKE_sormbr? = load(name: "LAPACKE_sormbr", as: FunctionType.LAPACKE_sormbr.self)
    #elseif os(macOS)
    static let sormbr: FunctionType.LAPACKE_sormbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormbr: FunctionType.LAPACKE_dormbr? = load(name: "LAPACKE_dormbr", as: FunctionType.LAPACKE_dormbr.self)
    #elseif os(macOS)
    static let dormbr: FunctionType.LAPACKE_dormbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormhr: FunctionType.LAPACKE_sormhr? = load(name: "LAPACKE_sormhr", as: FunctionType.LAPACKE_sormhr.self)
    #elseif os(macOS)
    static let sormhr: FunctionType.LAPACKE_sormhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormhr: FunctionType.LAPACKE_dormhr? = load(name: "LAPACKE_dormhr", as: FunctionType.LAPACKE_dormhr.self)
    #elseif os(macOS)
    static let dormhr: FunctionType.LAPACKE_dormhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormlq: FunctionType.LAPACKE_sormlq? = load(name: "LAPACKE_sormlq", as: FunctionType.LAPACKE_sormlq.self)
    #elseif os(macOS)
    static let sormlq: FunctionType.LAPACKE_sormlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormlq: FunctionType.LAPACKE_dormlq? = load(name: "LAPACKE_dormlq", as: FunctionType.LAPACKE_dormlq.self)
    #elseif os(macOS)
    static let dormlq: FunctionType.LAPACKE_dormlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormql: FunctionType.LAPACKE_sormql? = load(name: "LAPACKE_sormql", as: FunctionType.LAPACKE_sormql.self)
    #elseif os(macOS)
    static let sormql: FunctionType.LAPACKE_sormql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormql: FunctionType.LAPACKE_dormql? = load(name: "LAPACKE_dormql", as: FunctionType.LAPACKE_dormql.self)
    #elseif os(macOS)
    static let dormql: FunctionType.LAPACKE_dormql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormqr: FunctionType.LAPACKE_sormqr? = load(name: "LAPACKE_sormqr", as: FunctionType.LAPACKE_sormqr.self)
    #elseif os(macOS)
    static let sormqr: FunctionType.LAPACKE_sormqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormqr: FunctionType.LAPACKE_dormqr? = load(name: "LAPACKE_dormqr", as: FunctionType.LAPACKE_dormqr.self)
    #elseif os(macOS)
    static let dormqr: FunctionType.LAPACKE_dormqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrq: FunctionType.LAPACKE_sormrq? = load(name: "LAPACKE_sormrq", as: FunctionType.LAPACKE_sormrq.self)
    #elseif os(macOS)
    static let sormrq: FunctionType.LAPACKE_sormrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrq: FunctionType.LAPACKE_dormrq? = load(name: "LAPACKE_dormrq", as: FunctionType.LAPACKE_dormrq.self)
    #elseif os(macOS)
    static let dormrq: FunctionType.LAPACKE_dormrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrz: FunctionType.LAPACKE_sormrz? = load(name: "LAPACKE_sormrz", as: FunctionType.LAPACKE_sormrz.self)
    #elseif os(macOS)
    static let sormrz: FunctionType.LAPACKE_sormrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrz: FunctionType.LAPACKE_dormrz? = load(name: "LAPACKE_dormrz", as: FunctionType.LAPACKE_dormrz.self)
    #elseif os(macOS)
    static let dormrz: FunctionType.LAPACKE_dormrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormtr: FunctionType.LAPACKE_sormtr? = load(name: "LAPACKE_sormtr", as: FunctionType.LAPACKE_sormtr.self)
    #elseif os(macOS)
    static let sormtr: FunctionType.LAPACKE_sormtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormtr: FunctionType.LAPACKE_dormtr? = load(name: "LAPACKE_dormtr", as: FunctionType.LAPACKE_dormtr.self)
    #elseif os(macOS)
    static let dormtr: FunctionType.LAPACKE_dormtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbcon: FunctionType.LAPACKE_spbcon? = load(name: "LAPACKE_spbcon", as: FunctionType.LAPACKE_spbcon.self)
    #elseif os(macOS)
    static let spbcon: FunctionType.LAPACKE_spbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbcon: FunctionType.LAPACKE_dpbcon? = load(name: "LAPACKE_dpbcon", as: FunctionType.LAPACKE_dpbcon.self)
    #elseif os(macOS)
    static let dpbcon: FunctionType.LAPACKE_dpbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbcon: FunctionType.LAPACKE_cpbcon? = load(name: "LAPACKE_cpbcon", as: FunctionType.LAPACKE_cpbcon.self)
    #elseif os(macOS)
    static let cpbcon: FunctionType.LAPACKE_cpbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbcon: FunctionType.LAPACKE_zpbcon? = load(name: "LAPACKE_zpbcon", as: FunctionType.LAPACKE_zpbcon.self)
    #elseif os(macOS)
    static let zpbcon: FunctionType.LAPACKE_zpbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbequ: FunctionType.LAPACKE_spbequ? = load(name: "LAPACKE_spbequ", as: FunctionType.LAPACKE_spbequ.self)
    #elseif os(macOS)
    static let spbequ: FunctionType.LAPACKE_spbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbequ: FunctionType.LAPACKE_dpbequ? = load(name: "LAPACKE_dpbequ", as: FunctionType.LAPACKE_dpbequ.self)
    #elseif os(macOS)
    static let dpbequ: FunctionType.LAPACKE_dpbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbequ: FunctionType.LAPACKE_cpbequ? = load(name: "LAPACKE_cpbequ", as: FunctionType.LAPACKE_cpbequ.self)
    #elseif os(macOS)
    static let cpbequ: FunctionType.LAPACKE_cpbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbequ: FunctionType.LAPACKE_zpbequ? = load(name: "LAPACKE_zpbequ", as: FunctionType.LAPACKE_zpbequ.self)
    #elseif os(macOS)
    static let zpbequ: FunctionType.LAPACKE_zpbequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbrfs: FunctionType.LAPACKE_spbrfs? = load(name: "LAPACKE_spbrfs", as: FunctionType.LAPACKE_spbrfs.self)
    #elseif os(macOS)
    static let spbrfs: FunctionType.LAPACKE_spbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbrfs: FunctionType.LAPACKE_dpbrfs? = load(name: "LAPACKE_dpbrfs", as: FunctionType.LAPACKE_dpbrfs.self)
    #elseif os(macOS)
    static let dpbrfs: FunctionType.LAPACKE_dpbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbrfs: FunctionType.LAPACKE_cpbrfs? = load(name: "LAPACKE_cpbrfs", as: FunctionType.LAPACKE_cpbrfs.self)
    #elseif os(macOS)
    static let cpbrfs: FunctionType.LAPACKE_cpbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbrfs: FunctionType.LAPACKE_zpbrfs? = load(name: "LAPACKE_zpbrfs", as: FunctionType.LAPACKE_zpbrfs.self)
    #elseif os(macOS)
    static let zpbrfs: FunctionType.LAPACKE_zpbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbstf: FunctionType.LAPACKE_spbstf? = load(name: "LAPACKE_spbstf", as: FunctionType.LAPACKE_spbstf.self)
    #elseif os(macOS)
    static let spbstf: FunctionType.LAPACKE_spbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbstf: FunctionType.LAPACKE_dpbstf? = load(name: "LAPACKE_dpbstf", as: FunctionType.LAPACKE_dpbstf.self)
    #elseif os(macOS)
    static let dpbstf: FunctionType.LAPACKE_dpbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbstf: FunctionType.LAPACKE_cpbstf? = load(name: "LAPACKE_cpbstf", as: FunctionType.LAPACKE_cpbstf.self)
    #elseif os(macOS)
    static let cpbstf: FunctionType.LAPACKE_cpbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbstf: FunctionType.LAPACKE_zpbstf? = load(name: "LAPACKE_zpbstf", as: FunctionType.LAPACKE_zpbstf.self)
    #elseif os(macOS)
    static let zpbstf: FunctionType.LAPACKE_zpbstf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsv: FunctionType.LAPACKE_spbsv? = load(name: "LAPACKE_spbsv", as: FunctionType.LAPACKE_spbsv.self)
    #elseif os(macOS)
    static let spbsv: FunctionType.LAPACKE_spbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsv: FunctionType.LAPACKE_dpbsv? = load(name: "LAPACKE_dpbsv", as: FunctionType.LAPACKE_dpbsv.self)
    #elseif os(macOS)
    static let dpbsv: FunctionType.LAPACKE_dpbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsv: FunctionType.LAPACKE_cpbsv? = load(name: "LAPACKE_cpbsv", as: FunctionType.LAPACKE_cpbsv.self)
    #elseif os(macOS)
    static let cpbsv: FunctionType.LAPACKE_cpbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsv: FunctionType.LAPACKE_zpbsv? = load(name: "LAPACKE_zpbsv", as: FunctionType.LAPACKE_zpbsv.self)
    #elseif os(macOS)
    static let zpbsv: FunctionType.LAPACKE_zpbsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsvx: FunctionType.LAPACKE_spbsvx? = load(name: "LAPACKE_spbsvx", as: FunctionType.LAPACKE_spbsvx.self)
    #elseif os(macOS)
    static let spbsvx: FunctionType.LAPACKE_spbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsvx: FunctionType.LAPACKE_dpbsvx? = load(name: "LAPACKE_dpbsvx", as: FunctionType.LAPACKE_dpbsvx.self)
    #elseif os(macOS)
    static let dpbsvx: FunctionType.LAPACKE_dpbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsvx: FunctionType.LAPACKE_cpbsvx? = load(name: "LAPACKE_cpbsvx", as: FunctionType.LAPACKE_cpbsvx.self)
    #elseif os(macOS)
    static let cpbsvx: FunctionType.LAPACKE_cpbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsvx: FunctionType.LAPACKE_zpbsvx? = load(name: "LAPACKE_zpbsvx", as: FunctionType.LAPACKE_zpbsvx.self)
    #elseif os(macOS)
    static let zpbsvx: FunctionType.LAPACKE_zpbsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrf: FunctionType.LAPACKE_spbtrf? = load(name: "LAPACKE_spbtrf", as: FunctionType.LAPACKE_spbtrf.self)
    #elseif os(macOS)
    static let spbtrf: FunctionType.LAPACKE_spbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrf: FunctionType.LAPACKE_dpbtrf? = load(name: "LAPACKE_dpbtrf", as: FunctionType.LAPACKE_dpbtrf.self)
    #elseif os(macOS)
    static let dpbtrf: FunctionType.LAPACKE_dpbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrf: FunctionType.LAPACKE_cpbtrf? = load(name: "LAPACKE_cpbtrf", as: FunctionType.LAPACKE_cpbtrf.self)
    #elseif os(macOS)
    static let cpbtrf: FunctionType.LAPACKE_cpbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrf: FunctionType.LAPACKE_zpbtrf? = load(name: "LAPACKE_zpbtrf", as: FunctionType.LAPACKE_zpbtrf.self)
    #elseif os(macOS)
    static let zpbtrf: FunctionType.LAPACKE_zpbtrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrs: FunctionType.LAPACKE_spbtrs? = load(name: "LAPACKE_spbtrs", as: FunctionType.LAPACKE_spbtrs.self)
    #elseif os(macOS)
    static let spbtrs: FunctionType.LAPACKE_spbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrs: FunctionType.LAPACKE_dpbtrs? = load(name: "LAPACKE_dpbtrs", as: FunctionType.LAPACKE_dpbtrs.self)
    #elseif os(macOS)
    static let dpbtrs: FunctionType.LAPACKE_dpbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrs: FunctionType.LAPACKE_cpbtrs? = load(name: "LAPACKE_cpbtrs", as: FunctionType.LAPACKE_cpbtrs.self)
    #elseif os(macOS)
    static let cpbtrs: FunctionType.LAPACKE_cpbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrs: FunctionType.LAPACKE_zpbtrs? = load(name: "LAPACKE_zpbtrs", as: FunctionType.LAPACKE_zpbtrs.self)
    #elseif os(macOS)
    static let zpbtrs: FunctionType.LAPACKE_zpbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrf: FunctionType.LAPACKE_spftrf? = load(name: "LAPACKE_spftrf", as: FunctionType.LAPACKE_spftrf.self)
    #elseif os(macOS)
    static let spftrf: FunctionType.LAPACKE_spftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrf: FunctionType.LAPACKE_dpftrf? = load(name: "LAPACKE_dpftrf", as: FunctionType.LAPACKE_dpftrf.self)
    #elseif os(macOS)
    static let dpftrf: FunctionType.LAPACKE_dpftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrf: FunctionType.LAPACKE_cpftrf? = load(name: "LAPACKE_cpftrf", as: FunctionType.LAPACKE_cpftrf.self)
    #elseif os(macOS)
    static let cpftrf: FunctionType.LAPACKE_cpftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrf: FunctionType.LAPACKE_zpftrf? = load(name: "LAPACKE_zpftrf", as: FunctionType.LAPACKE_zpftrf.self)
    #elseif os(macOS)
    static let zpftrf: FunctionType.LAPACKE_zpftrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftri: FunctionType.LAPACKE_spftri? = load(name: "LAPACKE_spftri", as: FunctionType.LAPACKE_spftri.self)
    #elseif os(macOS)
    static let spftri: FunctionType.LAPACKE_spftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftri: FunctionType.LAPACKE_dpftri? = load(name: "LAPACKE_dpftri", as: FunctionType.LAPACKE_dpftri.self)
    #elseif os(macOS)
    static let dpftri: FunctionType.LAPACKE_dpftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftri: FunctionType.LAPACKE_cpftri? = load(name: "LAPACKE_cpftri", as: FunctionType.LAPACKE_cpftri.self)
    #elseif os(macOS)
    static let cpftri: FunctionType.LAPACKE_cpftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftri: FunctionType.LAPACKE_zpftri? = load(name: "LAPACKE_zpftri", as: FunctionType.LAPACKE_zpftri.self)
    #elseif os(macOS)
    static let zpftri: FunctionType.LAPACKE_zpftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrs: FunctionType.LAPACKE_spftrs? = load(name: "LAPACKE_spftrs", as: FunctionType.LAPACKE_spftrs.self)
    #elseif os(macOS)
    static let spftrs: FunctionType.LAPACKE_spftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrs: FunctionType.LAPACKE_dpftrs? = load(name: "LAPACKE_dpftrs", as: FunctionType.LAPACKE_dpftrs.self)
    #elseif os(macOS)
    static let dpftrs: FunctionType.LAPACKE_dpftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrs: FunctionType.LAPACKE_cpftrs? = load(name: "LAPACKE_cpftrs", as: FunctionType.LAPACKE_cpftrs.self)
    #elseif os(macOS)
    static let cpftrs: FunctionType.LAPACKE_cpftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrs: FunctionType.LAPACKE_zpftrs? = load(name: "LAPACKE_zpftrs", as: FunctionType.LAPACKE_zpftrs.self)
    #elseif os(macOS)
    static let zpftrs: FunctionType.LAPACKE_zpftrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spocon: FunctionType.LAPACKE_spocon? = load(name: "LAPACKE_spocon", as: FunctionType.LAPACKE_spocon.self)
    #elseif os(macOS)
    static let spocon: FunctionType.LAPACKE_spocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpocon: FunctionType.LAPACKE_dpocon? = load(name: "LAPACKE_dpocon", as: FunctionType.LAPACKE_dpocon.self)
    #elseif os(macOS)
    static let dpocon: FunctionType.LAPACKE_dpocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpocon: FunctionType.LAPACKE_cpocon? = load(name: "LAPACKE_cpocon", as: FunctionType.LAPACKE_cpocon.self)
    #elseif os(macOS)
    static let cpocon: FunctionType.LAPACKE_cpocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpocon: FunctionType.LAPACKE_zpocon? = load(name: "LAPACKE_zpocon", as: FunctionType.LAPACKE_zpocon.self)
    #elseif os(macOS)
    static let zpocon: FunctionType.LAPACKE_zpocon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequ: FunctionType.LAPACKE_spoequ? = load(name: "LAPACKE_spoequ", as: FunctionType.LAPACKE_spoequ.self)
    #elseif os(macOS)
    static let spoequ: FunctionType.LAPACKE_spoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequ: FunctionType.LAPACKE_dpoequ? = load(name: "LAPACKE_dpoequ", as: FunctionType.LAPACKE_dpoequ.self)
    #elseif os(macOS)
    static let dpoequ: FunctionType.LAPACKE_dpoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequ: FunctionType.LAPACKE_cpoequ? = load(name: "LAPACKE_cpoequ", as: FunctionType.LAPACKE_cpoequ.self)
    #elseif os(macOS)
    static let cpoequ: FunctionType.LAPACKE_cpoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequ: FunctionType.LAPACKE_zpoequ? = load(name: "LAPACKE_zpoequ", as: FunctionType.LAPACKE_zpoequ.self)
    #elseif os(macOS)
    static let zpoequ: FunctionType.LAPACKE_zpoequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequb: FunctionType.LAPACKE_spoequb? = load(name: "LAPACKE_spoequb", as: FunctionType.LAPACKE_spoequb.self)
    #elseif os(macOS)
    static let spoequb: FunctionType.LAPACKE_spoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequb: FunctionType.LAPACKE_dpoequb? = load(name: "LAPACKE_dpoequb", as: FunctionType.LAPACKE_dpoequb.self)
    #elseif os(macOS)
    static let dpoequb: FunctionType.LAPACKE_dpoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequb: FunctionType.LAPACKE_cpoequb? = load(name: "LAPACKE_cpoequb", as: FunctionType.LAPACKE_cpoequb.self)
    #elseif os(macOS)
    static let cpoequb: FunctionType.LAPACKE_cpoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequb: FunctionType.LAPACKE_zpoequb? = load(name: "LAPACKE_zpoequb", as: FunctionType.LAPACKE_zpoequb.self)
    #elseif os(macOS)
    static let zpoequb: FunctionType.LAPACKE_zpoequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfs: FunctionType.LAPACKE_sporfs? = load(name: "LAPACKE_sporfs", as: FunctionType.LAPACKE_sporfs.self)
    #elseif os(macOS)
    static let sporfs: FunctionType.LAPACKE_sporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfs: FunctionType.LAPACKE_dporfs? = load(name: "LAPACKE_dporfs", as: FunctionType.LAPACKE_dporfs.self)
    #elseif os(macOS)
    static let dporfs: FunctionType.LAPACKE_dporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfs: FunctionType.LAPACKE_cporfs? = load(name: "LAPACKE_cporfs", as: FunctionType.LAPACKE_cporfs.self)
    #elseif os(macOS)
    static let cporfs: FunctionType.LAPACKE_cporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfs: FunctionType.LAPACKE_zporfs? = load(name: "LAPACKE_zporfs", as: FunctionType.LAPACKE_zporfs.self)
    #elseif os(macOS)
    static let zporfs: FunctionType.LAPACKE_zporfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfsx: FunctionType.LAPACKE_sporfsx? = load(name: "LAPACKE_sporfsx", as: FunctionType.LAPACKE_sporfsx.self)
    #elseif os(macOS)
    static let sporfsx: FunctionType.LAPACKE_sporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfsx: FunctionType.LAPACKE_dporfsx? = load(name: "LAPACKE_dporfsx", as: FunctionType.LAPACKE_dporfsx.self)
    #elseif os(macOS)
    static let dporfsx: FunctionType.LAPACKE_dporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfsx: FunctionType.LAPACKE_cporfsx? = load(name: "LAPACKE_cporfsx", as: FunctionType.LAPACKE_cporfsx.self)
    #elseif os(macOS)
    static let cporfsx: FunctionType.LAPACKE_cporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfsx: FunctionType.LAPACKE_zporfsx? = load(name: "LAPACKE_zporfsx", as: FunctionType.LAPACKE_zporfsx.self)
    #elseif os(macOS)
    static let zporfsx: FunctionType.LAPACKE_zporfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposv: FunctionType.LAPACKE_sposv? = load(name: "LAPACKE_sposv", as: FunctionType.LAPACKE_sposv.self)
    #elseif os(macOS)
    static let sposv: FunctionType.LAPACKE_sposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposv: FunctionType.LAPACKE_dposv? = load(name: "LAPACKE_dposv", as: FunctionType.LAPACKE_dposv.self)
    #elseif os(macOS)
    static let dposv: FunctionType.LAPACKE_dposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposv: FunctionType.LAPACKE_cposv? = load(name: "LAPACKE_cposv", as: FunctionType.LAPACKE_cposv.self)
    #elseif os(macOS)
    static let cposv: FunctionType.LAPACKE_cposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposv: FunctionType.LAPACKE_zposv? = load(name: "LAPACKE_zposv", as: FunctionType.LAPACKE_zposv.self)
    #elseif os(macOS)
    static let zposv: FunctionType.LAPACKE_zposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsposv: FunctionType.LAPACKE_dsposv? = load(name: "LAPACKE_dsposv", as: FunctionType.LAPACKE_dsposv.self)
    #elseif os(macOS)
    static let dsposv: FunctionType.LAPACKE_dsposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcposv: FunctionType.LAPACKE_zcposv? = load(name: "LAPACKE_zcposv", as: FunctionType.LAPACKE_zcposv.self)
    #elseif os(macOS)
    static let zcposv: FunctionType.LAPACKE_zcposv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvx: FunctionType.LAPACKE_sposvx? = load(name: "LAPACKE_sposvx", as: FunctionType.LAPACKE_sposvx.self)
    #elseif os(macOS)
    static let sposvx: FunctionType.LAPACKE_sposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvx: FunctionType.LAPACKE_dposvx? = load(name: "LAPACKE_dposvx", as: FunctionType.LAPACKE_dposvx.self)
    #elseif os(macOS)
    static let dposvx: FunctionType.LAPACKE_dposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvx: FunctionType.LAPACKE_cposvx? = load(name: "LAPACKE_cposvx", as: FunctionType.LAPACKE_cposvx.self)
    #elseif os(macOS)
    static let cposvx: FunctionType.LAPACKE_cposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvx: FunctionType.LAPACKE_zposvx? = load(name: "LAPACKE_zposvx", as: FunctionType.LAPACKE_zposvx.self)
    #elseif os(macOS)
    static let zposvx: FunctionType.LAPACKE_zposvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvxx: FunctionType.LAPACKE_sposvxx? = load(name: "LAPACKE_sposvxx", as: FunctionType.LAPACKE_sposvxx.self)
    #elseif os(macOS)
    static let sposvxx: FunctionType.LAPACKE_sposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvxx: FunctionType.LAPACKE_dposvxx? = load(name: "LAPACKE_dposvxx", as: FunctionType.LAPACKE_dposvxx.self)
    #elseif os(macOS)
    static let dposvxx: FunctionType.LAPACKE_dposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvxx: FunctionType.LAPACKE_cposvxx? = load(name: "LAPACKE_cposvxx", as: FunctionType.LAPACKE_cposvxx.self)
    #elseif os(macOS)
    static let cposvxx: FunctionType.LAPACKE_cposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvxx: FunctionType.LAPACKE_zposvxx? = load(name: "LAPACKE_zposvxx", as: FunctionType.LAPACKE_zposvxx.self)
    #elseif os(macOS)
    static let zposvxx: FunctionType.LAPACKE_zposvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf2: FunctionType.LAPACKE_spotrf2? = load(name: "LAPACKE_spotrf2", as: FunctionType.LAPACKE_spotrf2.self)
    #elseif os(macOS)
    static let spotrf2: FunctionType.LAPACKE_spotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf2: FunctionType.LAPACKE_dpotrf2? = load(name: "LAPACKE_dpotrf2", as: FunctionType.LAPACKE_dpotrf2.self)
    #elseif os(macOS)
    static let dpotrf2: FunctionType.LAPACKE_dpotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf2: FunctionType.LAPACKE_cpotrf2? = load(name: "LAPACKE_cpotrf2", as: FunctionType.LAPACKE_cpotrf2.self)
    #elseif os(macOS)
    static let cpotrf2: FunctionType.LAPACKE_cpotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf2: FunctionType.LAPACKE_zpotrf2? = load(name: "LAPACKE_zpotrf2", as: FunctionType.LAPACKE_zpotrf2.self)
    #elseif os(macOS)
    static let zpotrf2: FunctionType.LAPACKE_zpotrf2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf: FunctionType.LAPACKE_spotrf? = load(name: "LAPACKE_spotrf", as: FunctionType.LAPACKE_spotrf.self)
    #elseif os(macOS)
    static let spotrf: FunctionType.LAPACKE_spotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf: FunctionType.LAPACKE_dpotrf? = load(name: "LAPACKE_dpotrf", as: FunctionType.LAPACKE_dpotrf.self)
    #elseif os(macOS)
    static let dpotrf: FunctionType.LAPACKE_dpotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf: FunctionType.LAPACKE_cpotrf? = load(name: "LAPACKE_cpotrf", as: FunctionType.LAPACKE_cpotrf.self)
    #elseif os(macOS)
    static let cpotrf: FunctionType.LAPACKE_cpotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf: FunctionType.LAPACKE_zpotrf? = load(name: "LAPACKE_zpotrf", as: FunctionType.LAPACKE_zpotrf.self)
    #elseif os(macOS)
    static let zpotrf: FunctionType.LAPACKE_zpotrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotri: FunctionType.LAPACKE_spotri? = load(name: "LAPACKE_spotri", as: FunctionType.LAPACKE_spotri.self)
    #elseif os(macOS)
    static let spotri: FunctionType.LAPACKE_spotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotri: FunctionType.LAPACKE_dpotri? = load(name: "LAPACKE_dpotri", as: FunctionType.LAPACKE_dpotri.self)
    #elseif os(macOS)
    static let dpotri: FunctionType.LAPACKE_dpotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotri: FunctionType.LAPACKE_cpotri? = load(name: "LAPACKE_cpotri", as: FunctionType.LAPACKE_cpotri.self)
    #elseif os(macOS)
    static let cpotri: FunctionType.LAPACKE_cpotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotri: FunctionType.LAPACKE_zpotri? = load(name: "LAPACKE_zpotri", as: FunctionType.LAPACKE_zpotri.self)
    #elseif os(macOS)
    static let zpotri: FunctionType.LAPACKE_zpotri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrs: FunctionType.LAPACKE_spotrs? = load(name: "LAPACKE_spotrs", as: FunctionType.LAPACKE_spotrs.self)
    #elseif os(macOS)
    static let spotrs: FunctionType.LAPACKE_spotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrs: FunctionType.LAPACKE_dpotrs? = load(name: "LAPACKE_dpotrs", as: FunctionType.LAPACKE_dpotrs.self)
    #elseif os(macOS)
    static let dpotrs: FunctionType.LAPACKE_dpotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrs: FunctionType.LAPACKE_cpotrs? = load(name: "LAPACKE_cpotrs", as: FunctionType.LAPACKE_cpotrs.self)
    #elseif os(macOS)
    static let cpotrs: FunctionType.LAPACKE_cpotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrs: FunctionType.LAPACKE_zpotrs? = load(name: "LAPACKE_zpotrs", as: FunctionType.LAPACKE_zpotrs.self)
    #elseif os(macOS)
    static let zpotrs: FunctionType.LAPACKE_zpotrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppcon: FunctionType.LAPACKE_sppcon? = load(name: "LAPACKE_sppcon", as: FunctionType.LAPACKE_sppcon.self)
    #elseif os(macOS)
    static let sppcon: FunctionType.LAPACKE_sppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppcon: FunctionType.LAPACKE_dppcon? = load(name: "LAPACKE_dppcon", as: FunctionType.LAPACKE_dppcon.self)
    #elseif os(macOS)
    static let dppcon: FunctionType.LAPACKE_dppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppcon: FunctionType.LAPACKE_cppcon? = load(name: "LAPACKE_cppcon", as: FunctionType.LAPACKE_cppcon.self)
    #elseif os(macOS)
    static let cppcon: FunctionType.LAPACKE_cppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppcon: FunctionType.LAPACKE_zppcon? = load(name: "LAPACKE_zppcon", as: FunctionType.LAPACKE_zppcon.self)
    #elseif os(macOS)
    static let zppcon: FunctionType.LAPACKE_zppcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppequ: FunctionType.LAPACKE_sppequ? = load(name: "LAPACKE_sppequ", as: FunctionType.LAPACKE_sppequ.self)
    #elseif os(macOS)
    static let sppequ: FunctionType.LAPACKE_sppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppequ: FunctionType.LAPACKE_dppequ? = load(name: "LAPACKE_dppequ", as: FunctionType.LAPACKE_dppequ.self)
    #elseif os(macOS)
    static let dppequ: FunctionType.LAPACKE_dppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppequ: FunctionType.LAPACKE_cppequ? = load(name: "LAPACKE_cppequ", as: FunctionType.LAPACKE_cppequ.self)
    #elseif os(macOS)
    static let cppequ: FunctionType.LAPACKE_cppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppequ: FunctionType.LAPACKE_zppequ? = load(name: "LAPACKE_zppequ", as: FunctionType.LAPACKE_zppequ.self)
    #elseif os(macOS)
    static let zppequ: FunctionType.LAPACKE_zppequ? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spprfs: FunctionType.LAPACKE_spprfs? = load(name: "LAPACKE_spprfs", as: FunctionType.LAPACKE_spprfs.self)
    #elseif os(macOS)
    static let spprfs: FunctionType.LAPACKE_spprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpprfs: FunctionType.LAPACKE_dpprfs? = load(name: "LAPACKE_dpprfs", as: FunctionType.LAPACKE_dpprfs.self)
    #elseif os(macOS)
    static let dpprfs: FunctionType.LAPACKE_dpprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpprfs: FunctionType.LAPACKE_cpprfs? = load(name: "LAPACKE_cpprfs", as: FunctionType.LAPACKE_cpprfs.self)
    #elseif os(macOS)
    static let cpprfs: FunctionType.LAPACKE_cpprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpprfs: FunctionType.LAPACKE_zpprfs? = load(name: "LAPACKE_zpprfs", as: FunctionType.LAPACKE_zpprfs.self)
    #elseif os(macOS)
    static let zpprfs: FunctionType.LAPACKE_zpprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsv: FunctionType.LAPACKE_sppsv? = load(name: "LAPACKE_sppsv", as: FunctionType.LAPACKE_sppsv.self)
    #elseif os(macOS)
    static let sppsv: FunctionType.LAPACKE_sppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsv: FunctionType.LAPACKE_dppsv? = load(name: "LAPACKE_dppsv", as: FunctionType.LAPACKE_dppsv.self)
    #elseif os(macOS)
    static let dppsv: FunctionType.LAPACKE_dppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsv: FunctionType.LAPACKE_cppsv? = load(name: "LAPACKE_cppsv", as: FunctionType.LAPACKE_cppsv.self)
    #elseif os(macOS)
    static let cppsv: FunctionType.LAPACKE_cppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsv: FunctionType.LAPACKE_zppsv? = load(name: "LAPACKE_zppsv", as: FunctionType.LAPACKE_zppsv.self)
    #elseif os(macOS)
    static let zppsv: FunctionType.LAPACKE_zppsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsvx: FunctionType.LAPACKE_sppsvx? = load(name: "LAPACKE_sppsvx", as: FunctionType.LAPACKE_sppsvx.self)
    #elseif os(macOS)
    static let sppsvx: FunctionType.LAPACKE_sppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsvx: FunctionType.LAPACKE_dppsvx? = load(name: "LAPACKE_dppsvx", as: FunctionType.LAPACKE_dppsvx.self)
    #elseif os(macOS)
    static let dppsvx: FunctionType.LAPACKE_dppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsvx: FunctionType.LAPACKE_cppsvx? = load(name: "LAPACKE_cppsvx", as: FunctionType.LAPACKE_cppsvx.self)
    #elseif os(macOS)
    static let cppsvx: FunctionType.LAPACKE_cppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsvx: FunctionType.LAPACKE_zppsvx? = load(name: "LAPACKE_zppsvx", as: FunctionType.LAPACKE_zppsvx.self)
    #elseif os(macOS)
    static let zppsvx: FunctionType.LAPACKE_zppsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrf: FunctionType.LAPACKE_spptrf? = load(name: "LAPACKE_spptrf", as: FunctionType.LAPACKE_spptrf.self)
    #elseif os(macOS)
    static let spptrf: FunctionType.LAPACKE_spptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrf: FunctionType.LAPACKE_dpptrf? = load(name: "LAPACKE_dpptrf", as: FunctionType.LAPACKE_dpptrf.self)
    #elseif os(macOS)
    static let dpptrf: FunctionType.LAPACKE_dpptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrf: FunctionType.LAPACKE_cpptrf? = load(name: "LAPACKE_cpptrf", as: FunctionType.LAPACKE_cpptrf.self)
    #elseif os(macOS)
    static let cpptrf: FunctionType.LAPACKE_cpptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrf: FunctionType.LAPACKE_zpptrf? = load(name: "LAPACKE_zpptrf", as: FunctionType.LAPACKE_zpptrf.self)
    #elseif os(macOS)
    static let zpptrf: FunctionType.LAPACKE_zpptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptri: FunctionType.LAPACKE_spptri? = load(name: "LAPACKE_spptri", as: FunctionType.LAPACKE_spptri.self)
    #elseif os(macOS)
    static let spptri: FunctionType.LAPACKE_spptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptri: FunctionType.LAPACKE_dpptri? = load(name: "LAPACKE_dpptri", as: FunctionType.LAPACKE_dpptri.self)
    #elseif os(macOS)
    static let dpptri: FunctionType.LAPACKE_dpptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptri: FunctionType.LAPACKE_cpptri? = load(name: "LAPACKE_cpptri", as: FunctionType.LAPACKE_cpptri.self)
    #elseif os(macOS)
    static let cpptri: FunctionType.LAPACKE_cpptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptri: FunctionType.LAPACKE_zpptri? = load(name: "LAPACKE_zpptri", as: FunctionType.LAPACKE_zpptri.self)
    #elseif os(macOS)
    static let zpptri: FunctionType.LAPACKE_zpptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrs: FunctionType.LAPACKE_spptrs? = load(name: "LAPACKE_spptrs", as: FunctionType.LAPACKE_spptrs.self)
    #elseif os(macOS)
    static let spptrs: FunctionType.LAPACKE_spptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrs: FunctionType.LAPACKE_dpptrs? = load(name: "LAPACKE_dpptrs", as: FunctionType.LAPACKE_dpptrs.self)
    #elseif os(macOS)
    static let dpptrs: FunctionType.LAPACKE_dpptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrs: FunctionType.LAPACKE_cpptrs? = load(name: "LAPACKE_cpptrs", as: FunctionType.LAPACKE_cpptrs.self)
    #elseif os(macOS)
    static let cpptrs: FunctionType.LAPACKE_cpptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrs: FunctionType.LAPACKE_zpptrs? = load(name: "LAPACKE_zpptrs", as: FunctionType.LAPACKE_zpptrs.self)
    #elseif os(macOS)
    static let zpptrs: FunctionType.LAPACKE_zpptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spstrf: FunctionType.LAPACKE_spstrf? = load(name: "LAPACKE_spstrf", as: FunctionType.LAPACKE_spstrf.self)
    #elseif os(macOS)
    static let spstrf: FunctionType.LAPACKE_spstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpstrf: FunctionType.LAPACKE_dpstrf? = load(name: "LAPACKE_dpstrf", as: FunctionType.LAPACKE_dpstrf.self)
    #elseif os(macOS)
    static let dpstrf: FunctionType.LAPACKE_dpstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpstrf: FunctionType.LAPACKE_cpstrf? = load(name: "LAPACKE_cpstrf", as: FunctionType.LAPACKE_cpstrf.self)
    #elseif os(macOS)
    static let cpstrf: FunctionType.LAPACKE_cpstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpstrf: FunctionType.LAPACKE_zpstrf? = load(name: "LAPACKE_zpstrf", as: FunctionType.LAPACKE_zpstrf.self)
    #elseif os(macOS)
    static let zpstrf: FunctionType.LAPACKE_zpstrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptcon: FunctionType.LAPACKE_sptcon? = load(name: "LAPACKE_sptcon", as: FunctionType.LAPACKE_sptcon.self)
    #elseif os(macOS)
    static let sptcon: FunctionType.LAPACKE_sptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptcon: FunctionType.LAPACKE_dptcon? = load(name: "LAPACKE_dptcon", as: FunctionType.LAPACKE_dptcon.self)
    #elseif os(macOS)
    static let dptcon: FunctionType.LAPACKE_dptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptcon: FunctionType.LAPACKE_cptcon? = load(name: "LAPACKE_cptcon", as: FunctionType.LAPACKE_cptcon.self)
    #elseif os(macOS)
    static let cptcon: FunctionType.LAPACKE_cptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptcon: FunctionType.LAPACKE_zptcon? = load(name: "LAPACKE_zptcon", as: FunctionType.LAPACKE_zptcon.self)
    #elseif os(macOS)
    static let zptcon: FunctionType.LAPACKE_zptcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spteqr: FunctionType.LAPACKE_spteqr? = load(name: "LAPACKE_spteqr", as: FunctionType.LAPACKE_spteqr.self)
    #elseif os(macOS)
    static let spteqr: FunctionType.LAPACKE_spteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpteqr: FunctionType.LAPACKE_dpteqr? = load(name: "LAPACKE_dpteqr", as: FunctionType.LAPACKE_dpteqr.self)
    #elseif os(macOS)
    static let dpteqr: FunctionType.LAPACKE_dpteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpteqr: FunctionType.LAPACKE_cpteqr? = load(name: "LAPACKE_cpteqr", as: FunctionType.LAPACKE_cpteqr.self)
    #elseif os(macOS)
    static let cpteqr: FunctionType.LAPACKE_cpteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpteqr: FunctionType.LAPACKE_zpteqr? = load(name: "LAPACKE_zpteqr", as: FunctionType.LAPACKE_zpteqr.self)
    #elseif os(macOS)
    static let zpteqr: FunctionType.LAPACKE_zpteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptrfs: FunctionType.LAPACKE_sptrfs? = load(name: "LAPACKE_sptrfs", as: FunctionType.LAPACKE_sptrfs.self)
    #elseif os(macOS)
    static let sptrfs: FunctionType.LAPACKE_sptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptrfs: FunctionType.LAPACKE_dptrfs? = load(name: "LAPACKE_dptrfs", as: FunctionType.LAPACKE_dptrfs.self)
    #elseif os(macOS)
    static let dptrfs: FunctionType.LAPACKE_dptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptrfs: FunctionType.LAPACKE_cptrfs? = load(name: "LAPACKE_cptrfs", as: FunctionType.LAPACKE_cptrfs.self)
    #elseif os(macOS)
    static let cptrfs: FunctionType.LAPACKE_cptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptrfs: FunctionType.LAPACKE_zptrfs? = load(name: "LAPACKE_zptrfs", as: FunctionType.LAPACKE_zptrfs.self)
    #elseif os(macOS)
    static let zptrfs: FunctionType.LAPACKE_zptrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsv: FunctionType.LAPACKE_sptsv? = load(name: "LAPACKE_sptsv", as: FunctionType.LAPACKE_sptsv.self)
    #elseif os(macOS)
    static let sptsv: FunctionType.LAPACKE_sptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsv: FunctionType.LAPACKE_dptsv? = load(name: "LAPACKE_dptsv", as: FunctionType.LAPACKE_dptsv.self)
    #elseif os(macOS)
    static let dptsv: FunctionType.LAPACKE_dptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsv: FunctionType.LAPACKE_cptsv? = load(name: "LAPACKE_cptsv", as: FunctionType.LAPACKE_cptsv.self)
    #elseif os(macOS)
    static let cptsv: FunctionType.LAPACKE_cptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsv: FunctionType.LAPACKE_zptsv? = load(name: "LAPACKE_zptsv", as: FunctionType.LAPACKE_zptsv.self)
    #elseif os(macOS)
    static let zptsv: FunctionType.LAPACKE_zptsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsvx: FunctionType.LAPACKE_sptsvx? = load(name: "LAPACKE_sptsvx", as: FunctionType.LAPACKE_sptsvx.self)
    #elseif os(macOS)
    static let sptsvx: FunctionType.LAPACKE_sptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsvx: FunctionType.LAPACKE_dptsvx? = load(name: "LAPACKE_dptsvx", as: FunctionType.LAPACKE_dptsvx.self)
    #elseif os(macOS)
    static let dptsvx: FunctionType.LAPACKE_dptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsvx: FunctionType.LAPACKE_cptsvx? = load(name: "LAPACKE_cptsvx", as: FunctionType.LAPACKE_cptsvx.self)
    #elseif os(macOS)
    static let cptsvx: FunctionType.LAPACKE_cptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsvx: FunctionType.LAPACKE_zptsvx? = load(name: "LAPACKE_zptsvx", as: FunctionType.LAPACKE_zptsvx.self)
    #elseif os(macOS)
    static let zptsvx: FunctionType.LAPACKE_zptsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrf: FunctionType.LAPACKE_spttrf? = load(name: "LAPACKE_spttrf", as: FunctionType.LAPACKE_spttrf.self)
    #elseif os(macOS)
    static let spttrf: FunctionType.LAPACKE_spttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrf: FunctionType.LAPACKE_dpttrf? = load(name: "LAPACKE_dpttrf", as: FunctionType.LAPACKE_dpttrf.self)
    #elseif os(macOS)
    static let dpttrf: FunctionType.LAPACKE_dpttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrf: FunctionType.LAPACKE_cpttrf? = load(name: "LAPACKE_cpttrf", as: FunctionType.LAPACKE_cpttrf.self)
    #elseif os(macOS)
    static let cpttrf: FunctionType.LAPACKE_cpttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrf: FunctionType.LAPACKE_zpttrf? = load(name: "LAPACKE_zpttrf", as: FunctionType.LAPACKE_zpttrf.self)
    #elseif os(macOS)
    static let zpttrf: FunctionType.LAPACKE_zpttrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrs: FunctionType.LAPACKE_spttrs? = load(name: "LAPACKE_spttrs", as: FunctionType.LAPACKE_spttrs.self)
    #elseif os(macOS)
    static let spttrs: FunctionType.LAPACKE_spttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrs: FunctionType.LAPACKE_dpttrs? = load(name: "LAPACKE_dpttrs", as: FunctionType.LAPACKE_dpttrs.self)
    #elseif os(macOS)
    static let dpttrs: FunctionType.LAPACKE_dpttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrs: FunctionType.LAPACKE_cpttrs? = load(name: "LAPACKE_cpttrs", as: FunctionType.LAPACKE_cpttrs.self)
    #elseif os(macOS)
    static let cpttrs: FunctionType.LAPACKE_cpttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrs: FunctionType.LAPACKE_zpttrs? = load(name: "LAPACKE_zpttrs", as: FunctionType.LAPACKE_zpttrs.self)
    #elseif os(macOS)
    static let zpttrs: FunctionType.LAPACKE_zpttrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev: FunctionType.LAPACKE_ssbev? = load(name: "LAPACKE_ssbev", as: FunctionType.LAPACKE_ssbev.self)
    #elseif os(macOS)
    static let ssbev: FunctionType.LAPACKE_ssbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev: FunctionType.LAPACKE_dsbev? = load(name: "LAPACKE_dsbev", as: FunctionType.LAPACKE_dsbev.self)
    #elseif os(macOS)
    static let dsbev: FunctionType.LAPACKE_dsbev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd: FunctionType.LAPACKE_ssbevd? = load(name: "LAPACKE_ssbevd", as: FunctionType.LAPACKE_ssbevd.self)
    #elseif os(macOS)
    static let ssbevd: FunctionType.LAPACKE_ssbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd: FunctionType.LAPACKE_dsbevd? = load(name: "LAPACKE_dsbevd", as: FunctionType.LAPACKE_dsbevd.self)
    #elseif os(macOS)
    static let dsbevd: FunctionType.LAPACKE_dsbevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx: FunctionType.LAPACKE_ssbevx? = load(name: "LAPACKE_ssbevx", as: FunctionType.LAPACKE_ssbevx.self)
    #elseif os(macOS)
    static let ssbevx: FunctionType.LAPACKE_ssbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx: FunctionType.LAPACKE_dsbevx? = load(name: "LAPACKE_dsbevx", as: FunctionType.LAPACKE_dsbevx.self)
    #elseif os(macOS)
    static let dsbevx: FunctionType.LAPACKE_dsbevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgst: FunctionType.LAPACKE_ssbgst? = load(name: "LAPACKE_ssbgst", as: FunctionType.LAPACKE_ssbgst.self)
    #elseif os(macOS)
    static let ssbgst: FunctionType.LAPACKE_ssbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgst: FunctionType.LAPACKE_dsbgst? = load(name: "LAPACKE_dsbgst", as: FunctionType.LAPACKE_dsbgst.self)
    #elseif os(macOS)
    static let dsbgst: FunctionType.LAPACKE_dsbgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgv: FunctionType.LAPACKE_ssbgv? = load(name: "LAPACKE_ssbgv", as: FunctionType.LAPACKE_ssbgv.self)
    #elseif os(macOS)
    static let ssbgv: FunctionType.LAPACKE_ssbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgv: FunctionType.LAPACKE_dsbgv? = load(name: "LAPACKE_dsbgv", as: FunctionType.LAPACKE_dsbgv.self)
    #elseif os(macOS)
    static let dsbgv: FunctionType.LAPACKE_dsbgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvd: FunctionType.LAPACKE_ssbgvd? = load(name: "LAPACKE_ssbgvd", as: FunctionType.LAPACKE_ssbgvd.self)
    #elseif os(macOS)
    static let ssbgvd: FunctionType.LAPACKE_ssbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvd: FunctionType.LAPACKE_dsbgvd? = load(name: "LAPACKE_dsbgvd", as: FunctionType.LAPACKE_dsbgvd.self)
    #elseif os(macOS)
    static let dsbgvd: FunctionType.LAPACKE_dsbgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvx: FunctionType.LAPACKE_ssbgvx? = load(name: "LAPACKE_ssbgvx", as: FunctionType.LAPACKE_ssbgvx.self)
    #elseif os(macOS)
    static let ssbgvx: FunctionType.LAPACKE_ssbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvx: FunctionType.LAPACKE_dsbgvx? = load(name: "LAPACKE_dsbgvx", as: FunctionType.LAPACKE_dsbgvx.self)
    #elseif os(macOS)
    static let dsbgvx: FunctionType.LAPACKE_dsbgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbtrd: FunctionType.LAPACKE_ssbtrd? = load(name: "LAPACKE_ssbtrd", as: FunctionType.LAPACKE_ssbtrd.self)
    #elseif os(macOS)
    static let ssbtrd: FunctionType.LAPACKE_ssbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbtrd: FunctionType.LAPACKE_dsbtrd? = load(name: "LAPACKE_dsbtrd", as: FunctionType.LAPACKE_dsbtrd.self)
    #elseif os(macOS)
    static let dsbtrd: FunctionType.LAPACKE_dsbtrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssfrk: FunctionType.LAPACKE_ssfrk? = load(name: "LAPACKE_ssfrk", as: FunctionType.LAPACKE_ssfrk.self)
    #elseif os(macOS)
    static let ssfrk: FunctionType.LAPACKE_ssfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsfrk: FunctionType.LAPACKE_dsfrk? = load(name: "LAPACKE_dsfrk", as: FunctionType.LAPACKE_dsfrk.self)
    #elseif os(macOS)
    static let dsfrk: FunctionType.LAPACKE_dsfrk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspcon: FunctionType.LAPACKE_sspcon? = load(name: "LAPACKE_sspcon", as: FunctionType.LAPACKE_sspcon.self)
    #elseif os(macOS)
    static let sspcon: FunctionType.LAPACKE_sspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspcon: FunctionType.LAPACKE_dspcon? = load(name: "LAPACKE_dspcon", as: FunctionType.LAPACKE_dspcon.self)
    #elseif os(macOS)
    static let dspcon: FunctionType.LAPACKE_dspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspcon: FunctionType.LAPACKE_cspcon? = load(name: "LAPACKE_cspcon", as: FunctionType.LAPACKE_cspcon.self)
    #elseif os(macOS)
    static let cspcon: FunctionType.LAPACKE_cspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspcon: FunctionType.LAPACKE_zspcon? = load(name: "LAPACKE_zspcon", as: FunctionType.LAPACKE_zspcon.self)
    #elseif os(macOS)
    static let zspcon: FunctionType.LAPACKE_zspcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspev: FunctionType.LAPACKE_sspev? = load(name: "LAPACKE_sspev", as: FunctionType.LAPACKE_sspev.self)
    #elseif os(macOS)
    static let sspev: FunctionType.LAPACKE_sspev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspev: FunctionType.LAPACKE_dspev? = load(name: "LAPACKE_dspev", as: FunctionType.LAPACKE_dspev.self)
    #elseif os(macOS)
    static let dspev: FunctionType.LAPACKE_dspev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevd: FunctionType.LAPACKE_sspevd? = load(name: "LAPACKE_sspevd", as: FunctionType.LAPACKE_sspevd.self)
    #elseif os(macOS)
    static let sspevd: FunctionType.LAPACKE_sspevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevd: FunctionType.LAPACKE_dspevd? = load(name: "LAPACKE_dspevd", as: FunctionType.LAPACKE_dspevd.self)
    #elseif os(macOS)
    static let dspevd: FunctionType.LAPACKE_dspevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevx: FunctionType.LAPACKE_sspevx? = load(name: "LAPACKE_sspevx", as: FunctionType.LAPACKE_sspevx.self)
    #elseif os(macOS)
    static let sspevx: FunctionType.LAPACKE_sspevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevx: FunctionType.LAPACKE_dspevx? = load(name: "LAPACKE_dspevx", as: FunctionType.LAPACKE_dspevx.self)
    #elseif os(macOS)
    static let dspevx: FunctionType.LAPACKE_dspevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgst: FunctionType.LAPACKE_sspgst? = load(name: "LAPACKE_sspgst", as: FunctionType.LAPACKE_sspgst.self)
    #elseif os(macOS)
    static let sspgst: FunctionType.LAPACKE_sspgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgst: FunctionType.LAPACKE_dspgst? = load(name: "LAPACKE_dspgst", as: FunctionType.LAPACKE_dspgst.self)
    #elseif os(macOS)
    static let dspgst: FunctionType.LAPACKE_dspgst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgv: FunctionType.LAPACKE_sspgv? = load(name: "LAPACKE_sspgv", as: FunctionType.LAPACKE_sspgv.self)
    #elseif os(macOS)
    static let sspgv: FunctionType.LAPACKE_sspgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgv: FunctionType.LAPACKE_dspgv? = load(name: "LAPACKE_dspgv", as: FunctionType.LAPACKE_dspgv.self)
    #elseif os(macOS)
    static let dspgv: FunctionType.LAPACKE_dspgv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvd: FunctionType.LAPACKE_sspgvd? = load(name: "LAPACKE_sspgvd", as: FunctionType.LAPACKE_sspgvd.self)
    #elseif os(macOS)
    static let sspgvd: FunctionType.LAPACKE_sspgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvd: FunctionType.LAPACKE_dspgvd? = load(name: "LAPACKE_dspgvd", as: FunctionType.LAPACKE_dspgvd.self)
    #elseif os(macOS)
    static let dspgvd: FunctionType.LAPACKE_dspgvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvx: FunctionType.LAPACKE_sspgvx? = load(name: "LAPACKE_sspgvx", as: FunctionType.LAPACKE_sspgvx.self)
    #elseif os(macOS)
    static let sspgvx: FunctionType.LAPACKE_sspgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvx: FunctionType.LAPACKE_dspgvx? = load(name: "LAPACKE_dspgvx", as: FunctionType.LAPACKE_dspgvx.self)
    #elseif os(macOS)
    static let dspgvx: FunctionType.LAPACKE_dspgvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssprfs: FunctionType.LAPACKE_ssprfs? = load(name: "LAPACKE_ssprfs", as: FunctionType.LAPACKE_ssprfs.self)
    #elseif os(macOS)
    static let ssprfs: FunctionType.LAPACKE_ssprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsprfs: FunctionType.LAPACKE_dsprfs? = load(name: "LAPACKE_dsprfs", as: FunctionType.LAPACKE_dsprfs.self)
    #elseif os(macOS)
    static let dsprfs: FunctionType.LAPACKE_dsprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csprfs: FunctionType.LAPACKE_csprfs? = load(name: "LAPACKE_csprfs", as: FunctionType.LAPACKE_csprfs.self)
    #elseif os(macOS)
    static let csprfs: FunctionType.LAPACKE_csprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsprfs: FunctionType.LAPACKE_zsprfs? = load(name: "LAPACKE_zsprfs", as: FunctionType.LAPACKE_zsprfs.self)
    #elseif os(macOS)
    static let zsprfs: FunctionType.LAPACKE_zsprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsv: FunctionType.LAPACKE_sspsv? = load(name: "LAPACKE_sspsv", as: FunctionType.LAPACKE_sspsv.self)
    #elseif os(macOS)
    static let sspsv: FunctionType.LAPACKE_sspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsv: FunctionType.LAPACKE_dspsv? = load(name: "LAPACKE_dspsv", as: FunctionType.LAPACKE_dspsv.self)
    #elseif os(macOS)
    static let dspsv: FunctionType.LAPACKE_dspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsv: FunctionType.LAPACKE_cspsv? = load(name: "LAPACKE_cspsv", as: FunctionType.LAPACKE_cspsv.self)
    #elseif os(macOS)
    static let cspsv: FunctionType.LAPACKE_cspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsv: FunctionType.LAPACKE_zspsv? = load(name: "LAPACKE_zspsv", as: FunctionType.LAPACKE_zspsv.self)
    #elseif os(macOS)
    static let zspsv: FunctionType.LAPACKE_zspsv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsvx: FunctionType.LAPACKE_sspsvx? = load(name: "LAPACKE_sspsvx", as: FunctionType.LAPACKE_sspsvx.self)
    #elseif os(macOS)
    static let sspsvx: FunctionType.LAPACKE_sspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsvx: FunctionType.LAPACKE_dspsvx? = load(name: "LAPACKE_dspsvx", as: FunctionType.LAPACKE_dspsvx.self)
    #elseif os(macOS)
    static let dspsvx: FunctionType.LAPACKE_dspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsvx: FunctionType.LAPACKE_cspsvx? = load(name: "LAPACKE_cspsvx", as: FunctionType.LAPACKE_cspsvx.self)
    #elseif os(macOS)
    static let cspsvx: FunctionType.LAPACKE_cspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsvx: FunctionType.LAPACKE_zspsvx? = load(name: "LAPACKE_zspsvx", as: FunctionType.LAPACKE_zspsvx.self)
    #elseif os(macOS)
    static let zspsvx: FunctionType.LAPACKE_zspsvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrd: FunctionType.LAPACKE_ssptrd? = load(name: "LAPACKE_ssptrd", as: FunctionType.LAPACKE_ssptrd.self)
    #elseif os(macOS)
    static let ssptrd: FunctionType.LAPACKE_ssptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrd: FunctionType.LAPACKE_dsptrd? = load(name: "LAPACKE_dsptrd", as: FunctionType.LAPACKE_dsptrd.self)
    #elseif os(macOS)
    static let dsptrd: FunctionType.LAPACKE_dsptrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrf: FunctionType.LAPACKE_ssptrf? = load(name: "LAPACKE_ssptrf", as: FunctionType.LAPACKE_ssptrf.self)
    #elseif os(macOS)
    static let ssptrf: FunctionType.LAPACKE_ssptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrf: FunctionType.LAPACKE_dsptrf? = load(name: "LAPACKE_dsptrf", as: FunctionType.LAPACKE_dsptrf.self)
    #elseif os(macOS)
    static let dsptrf: FunctionType.LAPACKE_dsptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrf: FunctionType.LAPACKE_csptrf? = load(name: "LAPACKE_csptrf", as: FunctionType.LAPACKE_csptrf.self)
    #elseif os(macOS)
    static let csptrf: FunctionType.LAPACKE_csptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrf: FunctionType.LAPACKE_zsptrf? = load(name: "LAPACKE_zsptrf", as: FunctionType.LAPACKE_zsptrf.self)
    #elseif os(macOS)
    static let zsptrf: FunctionType.LAPACKE_zsptrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptri: FunctionType.LAPACKE_ssptri? = load(name: "LAPACKE_ssptri", as: FunctionType.LAPACKE_ssptri.self)
    #elseif os(macOS)
    static let ssptri: FunctionType.LAPACKE_ssptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptri: FunctionType.LAPACKE_dsptri? = load(name: "LAPACKE_dsptri", as: FunctionType.LAPACKE_dsptri.self)
    #elseif os(macOS)
    static let dsptri: FunctionType.LAPACKE_dsptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptri: FunctionType.LAPACKE_csptri? = load(name: "LAPACKE_csptri", as: FunctionType.LAPACKE_csptri.self)
    #elseif os(macOS)
    static let csptri: FunctionType.LAPACKE_csptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptri: FunctionType.LAPACKE_zsptri? = load(name: "LAPACKE_zsptri", as: FunctionType.LAPACKE_zsptri.self)
    #elseif os(macOS)
    static let zsptri: FunctionType.LAPACKE_zsptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrs: FunctionType.LAPACKE_ssptrs? = load(name: "LAPACKE_ssptrs", as: FunctionType.LAPACKE_ssptrs.self)
    #elseif os(macOS)
    static let ssptrs: FunctionType.LAPACKE_ssptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrs: FunctionType.LAPACKE_dsptrs? = load(name: "LAPACKE_dsptrs", as: FunctionType.LAPACKE_dsptrs.self)
    #elseif os(macOS)
    static let dsptrs: FunctionType.LAPACKE_dsptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrs: FunctionType.LAPACKE_csptrs? = load(name: "LAPACKE_csptrs", as: FunctionType.LAPACKE_csptrs.self)
    #elseif os(macOS)
    static let csptrs: FunctionType.LAPACKE_csptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrs: FunctionType.LAPACKE_zsptrs? = load(name: "LAPACKE_zsptrs", as: FunctionType.LAPACKE_zsptrs.self)
    #elseif os(macOS)
    static let zsptrs: FunctionType.LAPACKE_zsptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstebz: FunctionType.LAPACKE_sstebz? = load(name: "LAPACKE_sstebz", as: FunctionType.LAPACKE_sstebz.self)
    #elseif os(macOS)
    static let sstebz: FunctionType.LAPACKE_sstebz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstebz: FunctionType.LAPACKE_dstebz? = load(name: "LAPACKE_dstebz", as: FunctionType.LAPACKE_dstebz.self)
    #elseif os(macOS)
    static let dstebz: FunctionType.LAPACKE_dstebz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstedc: FunctionType.LAPACKE_sstedc? = load(name: "LAPACKE_sstedc", as: FunctionType.LAPACKE_sstedc.self)
    #elseif os(macOS)
    static let sstedc: FunctionType.LAPACKE_sstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstedc: FunctionType.LAPACKE_dstedc? = load(name: "LAPACKE_dstedc", as: FunctionType.LAPACKE_dstedc.self)
    #elseif os(macOS)
    static let dstedc: FunctionType.LAPACKE_dstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstedc: FunctionType.LAPACKE_cstedc? = load(name: "LAPACKE_cstedc", as: FunctionType.LAPACKE_cstedc.self)
    #elseif os(macOS)
    static let cstedc: FunctionType.LAPACKE_cstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstedc: FunctionType.LAPACKE_zstedc? = load(name: "LAPACKE_zstedc", as: FunctionType.LAPACKE_zstedc.self)
    #elseif os(macOS)
    static let zstedc: FunctionType.LAPACKE_zstedc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstegr: FunctionType.LAPACKE_sstegr? = load(name: "LAPACKE_sstegr", as: FunctionType.LAPACKE_sstegr.self)
    #elseif os(macOS)
    static let sstegr: FunctionType.LAPACKE_sstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstegr: FunctionType.LAPACKE_dstegr? = load(name: "LAPACKE_dstegr", as: FunctionType.LAPACKE_dstegr.self)
    #elseif os(macOS)
    static let dstegr: FunctionType.LAPACKE_dstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstegr: FunctionType.LAPACKE_cstegr? = load(name: "LAPACKE_cstegr", as: FunctionType.LAPACKE_cstegr.self)
    #elseif os(macOS)
    static let cstegr: FunctionType.LAPACKE_cstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstegr: FunctionType.LAPACKE_zstegr? = load(name: "LAPACKE_zstegr", as: FunctionType.LAPACKE_zstegr.self)
    #elseif os(macOS)
    static let zstegr: FunctionType.LAPACKE_zstegr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstein: FunctionType.LAPACKE_sstein? = load(name: "LAPACKE_sstein", as: FunctionType.LAPACKE_sstein.self)
    #elseif os(macOS)
    static let sstein: FunctionType.LAPACKE_sstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstein: FunctionType.LAPACKE_dstein? = load(name: "LAPACKE_dstein", as: FunctionType.LAPACKE_dstein.self)
    #elseif os(macOS)
    static let dstein: FunctionType.LAPACKE_dstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstein: FunctionType.LAPACKE_cstein? = load(name: "LAPACKE_cstein", as: FunctionType.LAPACKE_cstein.self)
    #elseif os(macOS)
    static let cstein: FunctionType.LAPACKE_cstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstein: FunctionType.LAPACKE_zstein? = load(name: "LAPACKE_zstein", as: FunctionType.LAPACKE_zstein.self)
    #elseif os(macOS)
    static let zstein: FunctionType.LAPACKE_zstein? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstemr: FunctionType.LAPACKE_sstemr? = load(name: "LAPACKE_sstemr", as: FunctionType.LAPACKE_sstemr.self)
    #elseif os(macOS)
    static let sstemr: FunctionType.LAPACKE_sstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstemr: FunctionType.LAPACKE_dstemr? = load(name: "LAPACKE_dstemr", as: FunctionType.LAPACKE_dstemr.self)
    #elseif os(macOS)
    static let dstemr: FunctionType.LAPACKE_dstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstemr: FunctionType.LAPACKE_cstemr? = load(name: "LAPACKE_cstemr", as: FunctionType.LAPACKE_cstemr.self)
    #elseif os(macOS)
    static let cstemr: FunctionType.LAPACKE_cstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstemr: FunctionType.LAPACKE_zstemr? = load(name: "LAPACKE_zstemr", as: FunctionType.LAPACKE_zstemr.self)
    #elseif os(macOS)
    static let zstemr: FunctionType.LAPACKE_zstemr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssteqr: FunctionType.LAPACKE_ssteqr? = load(name: "LAPACKE_ssteqr", as: FunctionType.LAPACKE_ssteqr.self)
    #elseif os(macOS)
    static let ssteqr: FunctionType.LAPACKE_ssteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsteqr: FunctionType.LAPACKE_dsteqr? = load(name: "LAPACKE_dsteqr", as: FunctionType.LAPACKE_dsteqr.self)
    #elseif os(macOS)
    static let dsteqr: FunctionType.LAPACKE_dsteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csteqr: FunctionType.LAPACKE_csteqr? = load(name: "LAPACKE_csteqr", as: FunctionType.LAPACKE_csteqr.self)
    #elseif os(macOS)
    static let csteqr: FunctionType.LAPACKE_csteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsteqr: FunctionType.LAPACKE_zsteqr? = load(name: "LAPACKE_zsteqr", as: FunctionType.LAPACKE_zsteqr.self)
    #elseif os(macOS)
    static let zsteqr: FunctionType.LAPACKE_zsteqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssterf: FunctionType.LAPACKE_ssterf? = load(name: "LAPACKE_ssterf", as: FunctionType.LAPACKE_ssterf.self)
    #elseif os(macOS)
    static let ssterf: FunctionType.LAPACKE_ssterf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsterf: FunctionType.LAPACKE_dsterf? = load(name: "LAPACKE_dsterf", as: FunctionType.LAPACKE_dsterf.self)
    #elseif os(macOS)
    static let dsterf: FunctionType.LAPACKE_dsterf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstev: FunctionType.LAPACKE_sstev? = load(name: "LAPACKE_sstev", as: FunctionType.LAPACKE_sstev.self)
    #elseif os(macOS)
    static let sstev: FunctionType.LAPACKE_sstev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstev: FunctionType.LAPACKE_dstev? = load(name: "LAPACKE_dstev", as: FunctionType.LAPACKE_dstev.self)
    #elseif os(macOS)
    static let dstev: FunctionType.LAPACKE_dstev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevd: FunctionType.LAPACKE_sstevd? = load(name: "LAPACKE_sstevd", as: FunctionType.LAPACKE_sstevd.self)
    #elseif os(macOS)
    static let sstevd: FunctionType.LAPACKE_sstevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevd: FunctionType.LAPACKE_dstevd? = load(name: "LAPACKE_dstevd", as: FunctionType.LAPACKE_dstevd.self)
    #elseif os(macOS)
    static let dstevd: FunctionType.LAPACKE_dstevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevr: FunctionType.LAPACKE_sstevr? = load(name: "LAPACKE_sstevr", as: FunctionType.LAPACKE_sstevr.self)
    #elseif os(macOS)
    static let sstevr: FunctionType.LAPACKE_sstevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevr: FunctionType.LAPACKE_dstevr? = load(name: "LAPACKE_dstevr", as: FunctionType.LAPACKE_dstevr.self)
    #elseif os(macOS)
    static let dstevr: FunctionType.LAPACKE_dstevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevx: FunctionType.LAPACKE_sstevx? = load(name: "LAPACKE_sstevx", as: FunctionType.LAPACKE_sstevx.self)
    #elseif os(macOS)
    static let sstevx: FunctionType.LAPACKE_sstevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevx: FunctionType.LAPACKE_dstevx? = load(name: "LAPACKE_dstevx", as: FunctionType.LAPACKE_dstevx.self)
    #elseif os(macOS)
    static let dstevx: FunctionType.LAPACKE_dstevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon: FunctionType.LAPACKE_ssycon? = load(name: "LAPACKE_ssycon", as: FunctionType.LAPACKE_ssycon.self)
    #elseif os(macOS)
    static let ssycon: FunctionType.LAPACKE_ssycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon: FunctionType.LAPACKE_dsycon? = load(name: "LAPACKE_dsycon", as: FunctionType.LAPACKE_dsycon.self)
    #elseif os(macOS)
    static let dsycon: FunctionType.LAPACKE_dsycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon: FunctionType.LAPACKE_csycon? = load(name: "LAPACKE_csycon", as: FunctionType.LAPACKE_csycon.self)
    #elseif os(macOS)
    static let csycon: FunctionType.LAPACKE_csycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon: FunctionType.LAPACKE_zsycon? = load(name: "LAPACKE_zsycon", as: FunctionType.LAPACKE_zsycon.self)
    #elseif os(macOS)
    static let zsycon: FunctionType.LAPACKE_zsycon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyequb: FunctionType.LAPACKE_ssyequb? = load(name: "LAPACKE_ssyequb", as: FunctionType.LAPACKE_ssyequb.self)
    #elseif os(macOS)
    static let ssyequb: FunctionType.LAPACKE_ssyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyequb: FunctionType.LAPACKE_dsyequb? = load(name: "LAPACKE_dsyequb", as: FunctionType.LAPACKE_dsyequb.self)
    #elseif os(macOS)
    static let dsyequb: FunctionType.LAPACKE_dsyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyequb: FunctionType.LAPACKE_csyequb? = load(name: "LAPACKE_csyequb", as: FunctionType.LAPACKE_csyequb.self)
    #elseif os(macOS)
    static let csyequb: FunctionType.LAPACKE_csyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyequb: FunctionType.LAPACKE_zsyequb? = load(name: "LAPACKE_zsyequb", as: FunctionType.LAPACKE_zsyequb.self)
    #elseif os(macOS)
    static let zsyequb: FunctionType.LAPACKE_zsyequb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev: FunctionType.LAPACKE_ssyev? = load(name: "LAPACKE_ssyev", as: FunctionType.LAPACKE_ssyev.self)
    #elseif os(macOS)
    static let ssyev: FunctionType.LAPACKE_ssyev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev: FunctionType.LAPACKE_dsyev? = load(name: "LAPACKE_dsyev", as: FunctionType.LAPACKE_dsyev.self)
    #elseif os(macOS)
    static let dsyev: FunctionType.LAPACKE_dsyev? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd: FunctionType.LAPACKE_ssyevd? = load(name: "LAPACKE_ssyevd", as: FunctionType.LAPACKE_ssyevd.self)
    #elseif os(macOS)
    static let ssyevd: FunctionType.LAPACKE_ssyevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd: FunctionType.LAPACKE_dsyevd? = load(name: "LAPACKE_dsyevd", as: FunctionType.LAPACKE_dsyevd.self)
    #elseif os(macOS)
    static let dsyevd: FunctionType.LAPACKE_dsyevd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr: FunctionType.LAPACKE_ssyevr? = load(name: "LAPACKE_ssyevr", as: FunctionType.LAPACKE_ssyevr.self)
    #elseif os(macOS)
    static let ssyevr: FunctionType.LAPACKE_ssyevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr: FunctionType.LAPACKE_dsyevr? = load(name: "LAPACKE_dsyevr", as: FunctionType.LAPACKE_dsyevr.self)
    #elseif os(macOS)
    static let dsyevr: FunctionType.LAPACKE_dsyevr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx: FunctionType.LAPACKE_ssyevx? = load(name: "LAPACKE_ssyevx", as: FunctionType.LAPACKE_ssyevx.self)
    #elseif os(macOS)
    static let ssyevx: FunctionType.LAPACKE_ssyevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx: FunctionType.LAPACKE_dsyevx? = load(name: "LAPACKE_dsyevx", as: FunctionType.LAPACKE_dsyevx.self)
    #elseif os(macOS)
    static let dsyevx: FunctionType.LAPACKE_dsyevx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygst: FunctionType.LAPACKE_ssygst? = load(name: "LAPACKE_ssygst", as: FunctionType.LAPACKE_ssygst.self)
    #elseif os(macOS)
    static let ssygst: FunctionType.LAPACKE_ssygst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygst: FunctionType.LAPACKE_dsygst? = load(name: "LAPACKE_dsygst", as: FunctionType.LAPACKE_dsygst.self)
    #elseif os(macOS)
    static let dsygst: FunctionType.LAPACKE_dsygst? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv: FunctionType.LAPACKE_ssygv? = load(name: "LAPACKE_ssygv", as: FunctionType.LAPACKE_ssygv.self)
    #elseif os(macOS)
    static let ssygv: FunctionType.LAPACKE_ssygv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv: FunctionType.LAPACKE_dsygv? = load(name: "LAPACKE_dsygv", as: FunctionType.LAPACKE_dsygv.self)
    #elseif os(macOS)
    static let dsygv: FunctionType.LAPACKE_dsygv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvd: FunctionType.LAPACKE_ssygvd? = load(name: "LAPACKE_ssygvd", as: FunctionType.LAPACKE_ssygvd.self)
    #elseif os(macOS)
    static let ssygvd: FunctionType.LAPACKE_ssygvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvd: FunctionType.LAPACKE_dsygvd? = load(name: "LAPACKE_dsygvd", as: FunctionType.LAPACKE_dsygvd.self)
    #elseif os(macOS)
    static let dsygvd: FunctionType.LAPACKE_dsygvd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvx: FunctionType.LAPACKE_ssygvx? = load(name: "LAPACKE_ssygvx", as: FunctionType.LAPACKE_ssygvx.self)
    #elseif os(macOS)
    static let ssygvx: FunctionType.LAPACKE_ssygvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvx: FunctionType.LAPACKE_dsygvx? = load(name: "LAPACKE_dsygvx", as: FunctionType.LAPACKE_dsygvx.self)
    #elseif os(macOS)
    static let dsygvx: FunctionType.LAPACKE_dsygvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfs: FunctionType.LAPACKE_ssyrfs? = load(name: "LAPACKE_ssyrfs", as: FunctionType.LAPACKE_ssyrfs.self)
    #elseif os(macOS)
    static let ssyrfs: FunctionType.LAPACKE_ssyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfs: FunctionType.LAPACKE_dsyrfs? = load(name: "LAPACKE_dsyrfs", as: FunctionType.LAPACKE_dsyrfs.self)
    #elseif os(macOS)
    static let dsyrfs: FunctionType.LAPACKE_dsyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfs: FunctionType.LAPACKE_csyrfs? = load(name: "LAPACKE_csyrfs", as: FunctionType.LAPACKE_csyrfs.self)
    #elseif os(macOS)
    static let csyrfs: FunctionType.LAPACKE_csyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfs: FunctionType.LAPACKE_zsyrfs? = load(name: "LAPACKE_zsyrfs", as: FunctionType.LAPACKE_zsyrfs.self)
    #elseif os(macOS)
    static let zsyrfs: FunctionType.LAPACKE_zsyrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfsx: FunctionType.LAPACKE_ssyrfsx? = load(name: "LAPACKE_ssyrfsx", as: FunctionType.LAPACKE_ssyrfsx.self)
    #elseif os(macOS)
    static let ssyrfsx: FunctionType.LAPACKE_ssyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfsx: FunctionType.LAPACKE_dsyrfsx? = load(name: "LAPACKE_dsyrfsx", as: FunctionType.LAPACKE_dsyrfsx.self)
    #elseif os(macOS)
    static let dsyrfsx: FunctionType.LAPACKE_dsyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfsx: FunctionType.LAPACKE_csyrfsx? = load(name: "LAPACKE_csyrfsx", as: FunctionType.LAPACKE_csyrfsx.self)
    #elseif os(macOS)
    static let csyrfsx: FunctionType.LAPACKE_csyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfsx: FunctionType.LAPACKE_zsyrfsx? = load(name: "LAPACKE_zsyrfsx", as: FunctionType.LAPACKE_zsyrfsx.self)
    #elseif os(macOS)
    static let zsyrfsx: FunctionType.LAPACKE_zsyrfsx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv: FunctionType.LAPACKE_ssysv? = load(name: "LAPACKE_ssysv", as: FunctionType.LAPACKE_ssysv.self)
    #elseif os(macOS)
    static let ssysv: FunctionType.LAPACKE_ssysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv: FunctionType.LAPACKE_dsysv? = load(name: "LAPACKE_dsysv", as: FunctionType.LAPACKE_dsysv.self)
    #elseif os(macOS)
    static let dsysv: FunctionType.LAPACKE_dsysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv: FunctionType.LAPACKE_csysv? = load(name: "LAPACKE_csysv", as: FunctionType.LAPACKE_csysv.self)
    #elseif os(macOS)
    static let csysv: FunctionType.LAPACKE_csysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv: FunctionType.LAPACKE_zsysv? = load(name: "LAPACKE_zsysv", as: FunctionType.LAPACKE_zsysv.self)
    #elseif os(macOS)
    static let zsysv: FunctionType.LAPACKE_zsysv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvx: FunctionType.LAPACKE_ssysvx? = load(name: "LAPACKE_ssysvx", as: FunctionType.LAPACKE_ssysvx.self)
    #elseif os(macOS)
    static let ssysvx: FunctionType.LAPACKE_ssysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvx: FunctionType.LAPACKE_dsysvx? = load(name: "LAPACKE_dsysvx", as: FunctionType.LAPACKE_dsysvx.self)
    #elseif os(macOS)
    static let dsysvx: FunctionType.LAPACKE_dsysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvx: FunctionType.LAPACKE_csysvx? = load(name: "LAPACKE_csysvx", as: FunctionType.LAPACKE_csysvx.self)
    #elseif os(macOS)
    static let csysvx: FunctionType.LAPACKE_csysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvx: FunctionType.LAPACKE_zsysvx? = load(name: "LAPACKE_zsysvx", as: FunctionType.LAPACKE_zsysvx.self)
    #elseif os(macOS)
    static let zsysvx: FunctionType.LAPACKE_zsysvx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvxx: FunctionType.LAPACKE_ssysvxx? = load(name: "LAPACKE_ssysvxx", as: FunctionType.LAPACKE_ssysvxx.self)
    #elseif os(macOS)
    static let ssysvxx: FunctionType.LAPACKE_ssysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvxx: FunctionType.LAPACKE_dsysvxx? = load(name: "LAPACKE_dsysvxx", as: FunctionType.LAPACKE_dsysvxx.self)
    #elseif os(macOS)
    static let dsysvxx: FunctionType.LAPACKE_dsysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvxx: FunctionType.LAPACKE_csysvxx? = load(name: "LAPACKE_csysvxx", as: FunctionType.LAPACKE_csysvxx.self)
    #elseif os(macOS)
    static let csysvxx: FunctionType.LAPACKE_csysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvxx: FunctionType.LAPACKE_zsysvxx? = load(name: "LAPACKE_zsysvxx", as: FunctionType.LAPACKE_zsysvxx.self)
    #elseif os(macOS)
    static let zsysvxx: FunctionType.LAPACKE_zsysvxx? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrd: FunctionType.LAPACKE_ssytrd? = load(name: "LAPACKE_ssytrd", as: FunctionType.LAPACKE_ssytrd.self)
    #elseif os(macOS)
    static let ssytrd: FunctionType.LAPACKE_ssytrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrd: FunctionType.LAPACKE_dsytrd? = load(name: "LAPACKE_dsytrd", as: FunctionType.LAPACKE_dsytrd.self)
    #elseif os(macOS)
    static let dsytrd: FunctionType.LAPACKE_dsytrd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf: FunctionType.LAPACKE_ssytrf? = load(name: "LAPACKE_ssytrf", as: FunctionType.LAPACKE_ssytrf.self)
    #elseif os(macOS)
    static let ssytrf: FunctionType.LAPACKE_ssytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf: FunctionType.LAPACKE_dsytrf? = load(name: "LAPACKE_dsytrf", as: FunctionType.LAPACKE_dsytrf.self)
    #elseif os(macOS)
    static let dsytrf: FunctionType.LAPACKE_dsytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf: FunctionType.LAPACKE_csytrf? = load(name: "LAPACKE_csytrf", as: FunctionType.LAPACKE_csytrf.self)
    #elseif os(macOS)
    static let csytrf: FunctionType.LAPACKE_csytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf: FunctionType.LAPACKE_zsytrf? = load(name: "LAPACKE_zsytrf", as: FunctionType.LAPACKE_zsytrf.self)
    #elseif os(macOS)
    static let zsytrf: FunctionType.LAPACKE_zsytrf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri: FunctionType.LAPACKE_ssytri? = load(name: "LAPACKE_ssytri", as: FunctionType.LAPACKE_ssytri.self)
    #elseif os(macOS)
    static let ssytri: FunctionType.LAPACKE_ssytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri: FunctionType.LAPACKE_dsytri? = load(name: "LAPACKE_dsytri", as: FunctionType.LAPACKE_dsytri.self)
    #elseif os(macOS)
    static let dsytri: FunctionType.LAPACKE_dsytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri: FunctionType.LAPACKE_csytri? = load(name: "LAPACKE_csytri", as: FunctionType.LAPACKE_csytri.self)
    #elseif os(macOS)
    static let csytri: FunctionType.LAPACKE_csytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri: FunctionType.LAPACKE_zsytri? = load(name: "LAPACKE_zsytri", as: FunctionType.LAPACKE_zsytri.self)
    #elseif os(macOS)
    static let zsytri: FunctionType.LAPACKE_zsytri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs: FunctionType.LAPACKE_ssytrs? = load(name: "LAPACKE_ssytrs", as: FunctionType.LAPACKE_ssytrs.self)
    #elseif os(macOS)
    static let ssytrs: FunctionType.LAPACKE_ssytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs: FunctionType.LAPACKE_dsytrs? = load(name: "LAPACKE_dsytrs", as: FunctionType.LAPACKE_dsytrs.self)
    #elseif os(macOS)
    static let dsytrs: FunctionType.LAPACKE_dsytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs: FunctionType.LAPACKE_csytrs? = load(name: "LAPACKE_csytrs", as: FunctionType.LAPACKE_csytrs.self)
    #elseif os(macOS)
    static let csytrs: FunctionType.LAPACKE_csytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs: FunctionType.LAPACKE_zsytrs? = load(name: "LAPACKE_zsytrs", as: FunctionType.LAPACKE_zsytrs.self)
    #elseif os(macOS)
    static let zsytrs: FunctionType.LAPACKE_zsytrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbcon: FunctionType.LAPACKE_stbcon? = load(name: "LAPACKE_stbcon", as: FunctionType.LAPACKE_stbcon.self)
    #elseif os(macOS)
    static let stbcon: FunctionType.LAPACKE_stbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbcon: FunctionType.LAPACKE_dtbcon? = load(name: "LAPACKE_dtbcon", as: FunctionType.LAPACKE_dtbcon.self)
    #elseif os(macOS)
    static let dtbcon: FunctionType.LAPACKE_dtbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbcon: FunctionType.LAPACKE_ctbcon? = load(name: "LAPACKE_ctbcon", as: FunctionType.LAPACKE_ctbcon.self)
    #elseif os(macOS)
    static let ctbcon: FunctionType.LAPACKE_ctbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbcon: FunctionType.LAPACKE_ztbcon? = load(name: "LAPACKE_ztbcon", as: FunctionType.LAPACKE_ztbcon.self)
    #elseif os(macOS)
    static let ztbcon: FunctionType.LAPACKE_ztbcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbrfs: FunctionType.LAPACKE_stbrfs? = load(name: "LAPACKE_stbrfs", as: FunctionType.LAPACKE_stbrfs.self)
    #elseif os(macOS)
    static let stbrfs: FunctionType.LAPACKE_stbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbrfs: FunctionType.LAPACKE_dtbrfs? = load(name: "LAPACKE_dtbrfs", as: FunctionType.LAPACKE_dtbrfs.self)
    #elseif os(macOS)
    static let dtbrfs: FunctionType.LAPACKE_dtbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbrfs: FunctionType.LAPACKE_ctbrfs? = load(name: "LAPACKE_ctbrfs", as: FunctionType.LAPACKE_ctbrfs.self)
    #elseif os(macOS)
    static let ctbrfs: FunctionType.LAPACKE_ctbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbrfs: FunctionType.LAPACKE_ztbrfs? = load(name: "LAPACKE_ztbrfs", as: FunctionType.LAPACKE_ztbrfs.self)
    #elseif os(macOS)
    static let ztbrfs: FunctionType.LAPACKE_ztbrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbtrs: FunctionType.LAPACKE_stbtrs? = load(name: "LAPACKE_stbtrs", as: FunctionType.LAPACKE_stbtrs.self)
    #elseif os(macOS)
    static let stbtrs: FunctionType.LAPACKE_stbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbtrs: FunctionType.LAPACKE_dtbtrs? = load(name: "LAPACKE_dtbtrs", as: FunctionType.LAPACKE_dtbtrs.self)
    #elseif os(macOS)
    static let dtbtrs: FunctionType.LAPACKE_dtbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbtrs: FunctionType.LAPACKE_ctbtrs? = load(name: "LAPACKE_ctbtrs", as: FunctionType.LAPACKE_ctbtrs.self)
    #elseif os(macOS)
    static let ctbtrs: FunctionType.LAPACKE_ctbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbtrs: FunctionType.LAPACKE_ztbtrs? = load(name: "LAPACKE_ztbtrs", as: FunctionType.LAPACKE_ztbtrs.self)
    #elseif os(macOS)
    static let ztbtrs: FunctionType.LAPACKE_ztbtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfsm: FunctionType.LAPACKE_stfsm? = load(name: "LAPACKE_stfsm", as: FunctionType.LAPACKE_stfsm.self)
    #elseif os(macOS)
    static let stfsm: FunctionType.LAPACKE_stfsm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfsm: FunctionType.LAPACKE_dtfsm? = load(name: "LAPACKE_dtfsm", as: FunctionType.LAPACKE_dtfsm.self)
    #elseif os(macOS)
    static let dtfsm: FunctionType.LAPACKE_dtfsm? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stftri: FunctionType.LAPACKE_stftri? = load(name: "LAPACKE_stftri", as: FunctionType.LAPACKE_stftri.self)
    #elseif os(macOS)
    static let stftri: FunctionType.LAPACKE_stftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtftri: FunctionType.LAPACKE_dtftri? = load(name: "LAPACKE_dtftri", as: FunctionType.LAPACKE_dtftri.self)
    #elseif os(macOS)
    static let dtftri: FunctionType.LAPACKE_dtftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctftri: FunctionType.LAPACKE_ctftri? = load(name: "LAPACKE_ctftri", as: FunctionType.LAPACKE_ctftri.self)
    #elseif os(macOS)
    static let ctftri: FunctionType.LAPACKE_ctftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztftri: FunctionType.LAPACKE_ztftri? = load(name: "LAPACKE_ztftri", as: FunctionType.LAPACKE_ztftri.self)
    #elseif os(macOS)
    static let ztftri: FunctionType.LAPACKE_ztftri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttp: FunctionType.LAPACKE_stfttp? = load(name: "LAPACKE_stfttp", as: FunctionType.LAPACKE_stfttp.self)
    #elseif os(macOS)
    static let stfttp: FunctionType.LAPACKE_stfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttp: FunctionType.LAPACKE_dtfttp? = load(name: "LAPACKE_dtfttp", as: FunctionType.LAPACKE_dtfttp.self)
    #elseif os(macOS)
    static let dtfttp: FunctionType.LAPACKE_dtfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttp: FunctionType.LAPACKE_ctfttp? = load(name: "LAPACKE_ctfttp", as: FunctionType.LAPACKE_ctfttp.self)
    #elseif os(macOS)
    static let ctfttp: FunctionType.LAPACKE_ctfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttp: FunctionType.LAPACKE_ztfttp? = load(name: "LAPACKE_ztfttp", as: FunctionType.LAPACKE_ztfttp.self)
    #elseif os(macOS)
    static let ztfttp: FunctionType.LAPACKE_ztfttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttr: FunctionType.LAPACKE_stfttr? = load(name: "LAPACKE_stfttr", as: FunctionType.LAPACKE_stfttr.self)
    #elseif os(macOS)
    static let stfttr: FunctionType.LAPACKE_stfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttr: FunctionType.LAPACKE_dtfttr? = load(name: "LAPACKE_dtfttr", as: FunctionType.LAPACKE_dtfttr.self)
    #elseif os(macOS)
    static let dtfttr: FunctionType.LAPACKE_dtfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttr: FunctionType.LAPACKE_ctfttr? = load(name: "LAPACKE_ctfttr", as: FunctionType.LAPACKE_ctfttr.self)
    #elseif os(macOS)
    static let ctfttr: FunctionType.LAPACKE_ctfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttr: FunctionType.LAPACKE_ztfttr? = load(name: "LAPACKE_ztfttr", as: FunctionType.LAPACKE_ztfttr.self)
    #elseif os(macOS)
    static let ztfttr: FunctionType.LAPACKE_ztfttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgevc: FunctionType.LAPACKE_stgevc? = load(name: "LAPACKE_stgevc", as: FunctionType.LAPACKE_stgevc.self)
    #elseif os(macOS)
    static let stgevc: FunctionType.LAPACKE_stgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgevc: FunctionType.LAPACKE_dtgevc? = load(name: "LAPACKE_dtgevc", as: FunctionType.LAPACKE_dtgevc.self)
    #elseif os(macOS)
    static let dtgevc: FunctionType.LAPACKE_dtgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgevc: FunctionType.LAPACKE_ctgevc? = load(name: "LAPACKE_ctgevc", as: FunctionType.LAPACKE_ctgevc.self)
    #elseif os(macOS)
    static let ctgevc: FunctionType.LAPACKE_ctgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgevc: FunctionType.LAPACKE_ztgevc? = load(name: "LAPACKE_ztgevc", as: FunctionType.LAPACKE_ztgevc.self)
    #elseif os(macOS)
    static let ztgevc: FunctionType.LAPACKE_ztgevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgexc: FunctionType.LAPACKE_stgexc? = load(name: "LAPACKE_stgexc", as: FunctionType.LAPACKE_stgexc.self)
    #elseif os(macOS)
    static let stgexc: FunctionType.LAPACKE_stgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgexc: FunctionType.LAPACKE_dtgexc? = load(name: "LAPACKE_dtgexc", as: FunctionType.LAPACKE_dtgexc.self)
    #elseif os(macOS)
    static let dtgexc: FunctionType.LAPACKE_dtgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgexc: FunctionType.LAPACKE_ctgexc? = load(name: "LAPACKE_ctgexc", as: FunctionType.LAPACKE_ctgexc.self)
    #elseif os(macOS)
    static let ctgexc: FunctionType.LAPACKE_ctgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgexc: FunctionType.LAPACKE_ztgexc? = load(name: "LAPACKE_ztgexc", as: FunctionType.LAPACKE_ztgexc.self)
    #elseif os(macOS)
    static let ztgexc: FunctionType.LAPACKE_ztgexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsen: FunctionType.LAPACKE_stgsen? = load(name: "LAPACKE_stgsen", as: FunctionType.LAPACKE_stgsen.self)
    #elseif os(macOS)
    static let stgsen: FunctionType.LAPACKE_stgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsen: FunctionType.LAPACKE_dtgsen? = load(name: "LAPACKE_dtgsen", as: FunctionType.LAPACKE_dtgsen.self)
    #elseif os(macOS)
    static let dtgsen: FunctionType.LAPACKE_dtgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsen: FunctionType.LAPACKE_ctgsen? = load(name: "LAPACKE_ctgsen", as: FunctionType.LAPACKE_ctgsen.self)
    #elseif os(macOS)
    static let ctgsen: FunctionType.LAPACKE_ctgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsen: FunctionType.LAPACKE_ztgsen? = load(name: "LAPACKE_ztgsen", as: FunctionType.LAPACKE_ztgsen.self)
    #elseif os(macOS)
    static let ztgsen: FunctionType.LAPACKE_ztgsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsja: FunctionType.LAPACKE_stgsja? = load(name: "LAPACKE_stgsja", as: FunctionType.LAPACKE_stgsja.self)
    #elseif os(macOS)
    static let stgsja: FunctionType.LAPACKE_stgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsja: FunctionType.LAPACKE_dtgsja? = load(name: "LAPACKE_dtgsja", as: FunctionType.LAPACKE_dtgsja.self)
    #elseif os(macOS)
    static let dtgsja: FunctionType.LAPACKE_dtgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsja: FunctionType.LAPACKE_ctgsja? = load(name: "LAPACKE_ctgsja", as: FunctionType.LAPACKE_ctgsja.self)
    #elseif os(macOS)
    static let ctgsja: FunctionType.LAPACKE_ctgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsja: FunctionType.LAPACKE_ztgsja? = load(name: "LAPACKE_ztgsja", as: FunctionType.LAPACKE_ztgsja.self)
    #elseif os(macOS)
    static let ztgsja: FunctionType.LAPACKE_ztgsja? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsna: FunctionType.LAPACKE_stgsna? = load(name: "LAPACKE_stgsna", as: FunctionType.LAPACKE_stgsna.self)
    #elseif os(macOS)
    static let stgsna: FunctionType.LAPACKE_stgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsna: FunctionType.LAPACKE_dtgsna? = load(name: "LAPACKE_dtgsna", as: FunctionType.LAPACKE_dtgsna.self)
    #elseif os(macOS)
    static let dtgsna: FunctionType.LAPACKE_dtgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsna: FunctionType.LAPACKE_ctgsna? = load(name: "LAPACKE_ctgsna", as: FunctionType.LAPACKE_ctgsna.self)
    #elseif os(macOS)
    static let ctgsna: FunctionType.LAPACKE_ctgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsna: FunctionType.LAPACKE_ztgsna? = load(name: "LAPACKE_ztgsna", as: FunctionType.LAPACKE_ztgsna.self)
    #elseif os(macOS)
    static let ztgsna: FunctionType.LAPACKE_ztgsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsyl: FunctionType.LAPACKE_stgsyl? = load(name: "LAPACKE_stgsyl", as: FunctionType.LAPACKE_stgsyl.self)
    #elseif os(macOS)
    static let stgsyl: FunctionType.LAPACKE_stgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsyl: FunctionType.LAPACKE_dtgsyl? = load(name: "LAPACKE_dtgsyl", as: FunctionType.LAPACKE_dtgsyl.self)
    #elseif os(macOS)
    static let dtgsyl: FunctionType.LAPACKE_dtgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsyl: FunctionType.LAPACKE_ctgsyl? = load(name: "LAPACKE_ctgsyl", as: FunctionType.LAPACKE_ctgsyl.self)
    #elseif os(macOS)
    static let ctgsyl: FunctionType.LAPACKE_ctgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsyl: FunctionType.LAPACKE_ztgsyl? = load(name: "LAPACKE_ztgsyl", as: FunctionType.LAPACKE_ztgsyl.self)
    #elseif os(macOS)
    static let ztgsyl: FunctionType.LAPACKE_ztgsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpcon: FunctionType.LAPACKE_stpcon? = load(name: "LAPACKE_stpcon", as: FunctionType.LAPACKE_stpcon.self)
    #elseif os(macOS)
    static let stpcon: FunctionType.LAPACKE_stpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpcon: FunctionType.LAPACKE_dtpcon? = load(name: "LAPACKE_dtpcon", as: FunctionType.LAPACKE_dtpcon.self)
    #elseif os(macOS)
    static let dtpcon: FunctionType.LAPACKE_dtpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpcon: FunctionType.LAPACKE_ctpcon? = load(name: "LAPACKE_ctpcon", as: FunctionType.LAPACKE_ctpcon.self)
    #elseif os(macOS)
    static let ctpcon: FunctionType.LAPACKE_ctpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpcon: FunctionType.LAPACKE_ztpcon? = load(name: "LAPACKE_ztpcon", as: FunctionType.LAPACKE_ztpcon.self)
    #elseif os(macOS)
    static let ztpcon: FunctionType.LAPACKE_ztpcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfs: FunctionType.LAPACKE_stprfs? = load(name: "LAPACKE_stprfs", as: FunctionType.LAPACKE_stprfs.self)
    #elseif os(macOS)
    static let stprfs: FunctionType.LAPACKE_stprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfs: FunctionType.LAPACKE_dtprfs? = load(name: "LAPACKE_dtprfs", as: FunctionType.LAPACKE_dtprfs.self)
    #elseif os(macOS)
    static let dtprfs: FunctionType.LAPACKE_dtprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfs: FunctionType.LAPACKE_ctprfs? = load(name: "LAPACKE_ctprfs", as: FunctionType.LAPACKE_ctprfs.self)
    #elseif os(macOS)
    static let ctprfs: FunctionType.LAPACKE_ctprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfs: FunctionType.LAPACKE_ztprfs? = load(name: "LAPACKE_ztprfs", as: FunctionType.LAPACKE_ztprfs.self)
    #elseif os(macOS)
    static let ztprfs: FunctionType.LAPACKE_ztprfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptri: FunctionType.LAPACKE_stptri? = load(name: "LAPACKE_stptri", as: FunctionType.LAPACKE_stptri.self)
    #elseif os(macOS)
    static let stptri: FunctionType.LAPACKE_stptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptri: FunctionType.LAPACKE_dtptri? = load(name: "LAPACKE_dtptri", as: FunctionType.LAPACKE_dtptri.self)
    #elseif os(macOS)
    static let dtptri: FunctionType.LAPACKE_dtptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptri: FunctionType.LAPACKE_ctptri? = load(name: "LAPACKE_ctptri", as: FunctionType.LAPACKE_ctptri.self)
    #elseif os(macOS)
    static let ctptri: FunctionType.LAPACKE_ctptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptri: FunctionType.LAPACKE_ztptri? = load(name: "LAPACKE_ztptri", as: FunctionType.LAPACKE_ztptri.self)
    #elseif os(macOS)
    static let ztptri: FunctionType.LAPACKE_ztptri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptrs: FunctionType.LAPACKE_stptrs? = load(name: "LAPACKE_stptrs", as: FunctionType.LAPACKE_stptrs.self)
    #elseif os(macOS)
    static let stptrs: FunctionType.LAPACKE_stptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptrs: FunctionType.LAPACKE_dtptrs? = load(name: "LAPACKE_dtptrs", as: FunctionType.LAPACKE_dtptrs.self)
    #elseif os(macOS)
    static let dtptrs: FunctionType.LAPACKE_dtptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptrs: FunctionType.LAPACKE_ctptrs? = load(name: "LAPACKE_ctptrs", as: FunctionType.LAPACKE_ctptrs.self)
    #elseif os(macOS)
    static let ctptrs: FunctionType.LAPACKE_ctptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptrs: FunctionType.LAPACKE_ztptrs? = load(name: "LAPACKE_ztptrs", as: FunctionType.LAPACKE_ztptrs.self)
    #elseif os(macOS)
    static let ztptrs: FunctionType.LAPACKE_ztptrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttf: FunctionType.LAPACKE_stpttf? = load(name: "LAPACKE_stpttf", as: FunctionType.LAPACKE_stpttf.self)
    #elseif os(macOS)
    static let stpttf: FunctionType.LAPACKE_stpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttf: FunctionType.LAPACKE_dtpttf? = load(name: "LAPACKE_dtpttf", as: FunctionType.LAPACKE_dtpttf.self)
    #elseif os(macOS)
    static let dtpttf: FunctionType.LAPACKE_dtpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttf: FunctionType.LAPACKE_ctpttf? = load(name: "LAPACKE_ctpttf", as: FunctionType.LAPACKE_ctpttf.self)
    #elseif os(macOS)
    static let ctpttf: FunctionType.LAPACKE_ctpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttf: FunctionType.LAPACKE_ztpttf? = load(name: "LAPACKE_ztpttf", as: FunctionType.LAPACKE_ztpttf.self)
    #elseif os(macOS)
    static let ztpttf: FunctionType.LAPACKE_ztpttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttr: FunctionType.LAPACKE_stpttr? = load(name: "LAPACKE_stpttr", as: FunctionType.LAPACKE_stpttr.self)
    #elseif os(macOS)
    static let stpttr: FunctionType.LAPACKE_stpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttr: FunctionType.LAPACKE_dtpttr? = load(name: "LAPACKE_dtpttr", as: FunctionType.LAPACKE_dtpttr.self)
    #elseif os(macOS)
    static let dtpttr: FunctionType.LAPACKE_dtpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttr: FunctionType.LAPACKE_ctpttr? = load(name: "LAPACKE_ctpttr", as: FunctionType.LAPACKE_ctpttr.self)
    #elseif os(macOS)
    static let ctpttr: FunctionType.LAPACKE_ctpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttr: FunctionType.LAPACKE_ztpttr? = load(name: "LAPACKE_ztpttr", as: FunctionType.LAPACKE_ztpttr.self)
    #elseif os(macOS)
    static let ztpttr: FunctionType.LAPACKE_ztpttr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strcon: FunctionType.LAPACKE_strcon? = load(name: "LAPACKE_strcon", as: FunctionType.LAPACKE_strcon.self)
    #elseif os(macOS)
    static let strcon: FunctionType.LAPACKE_strcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrcon: FunctionType.LAPACKE_dtrcon? = load(name: "LAPACKE_dtrcon", as: FunctionType.LAPACKE_dtrcon.self)
    #elseif os(macOS)
    static let dtrcon: FunctionType.LAPACKE_dtrcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrcon: FunctionType.LAPACKE_ctrcon? = load(name: "LAPACKE_ctrcon", as: FunctionType.LAPACKE_ctrcon.self)
    #elseif os(macOS)
    static let ctrcon: FunctionType.LAPACKE_ctrcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrcon: FunctionType.LAPACKE_ztrcon? = load(name: "LAPACKE_ztrcon", as: FunctionType.LAPACKE_ztrcon.self)
    #elseif os(macOS)
    static let ztrcon: FunctionType.LAPACKE_ztrcon? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strevc: FunctionType.LAPACKE_strevc? = load(name: "LAPACKE_strevc", as: FunctionType.LAPACKE_strevc.self)
    #elseif os(macOS)
    static let strevc: FunctionType.LAPACKE_strevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrevc: FunctionType.LAPACKE_dtrevc? = load(name: "LAPACKE_dtrevc", as: FunctionType.LAPACKE_dtrevc.self)
    #elseif os(macOS)
    static let dtrevc: FunctionType.LAPACKE_dtrevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrevc: FunctionType.LAPACKE_ctrevc? = load(name: "LAPACKE_ctrevc", as: FunctionType.LAPACKE_ctrevc.self)
    #elseif os(macOS)
    static let ctrevc: FunctionType.LAPACKE_ctrevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrevc: FunctionType.LAPACKE_ztrevc? = load(name: "LAPACKE_ztrevc", as: FunctionType.LAPACKE_ztrevc.self)
    #elseif os(macOS)
    static let ztrevc: FunctionType.LAPACKE_ztrevc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strexc: FunctionType.LAPACKE_strexc? = load(name: "LAPACKE_strexc", as: FunctionType.LAPACKE_strexc.self)
    #elseif os(macOS)
    static let strexc: FunctionType.LAPACKE_strexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrexc: FunctionType.LAPACKE_dtrexc? = load(name: "LAPACKE_dtrexc", as: FunctionType.LAPACKE_dtrexc.self)
    #elseif os(macOS)
    static let dtrexc: FunctionType.LAPACKE_dtrexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrexc: FunctionType.LAPACKE_ctrexc? = load(name: "LAPACKE_ctrexc", as: FunctionType.LAPACKE_ctrexc.self)
    #elseif os(macOS)
    static let ctrexc: FunctionType.LAPACKE_ctrexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrexc: FunctionType.LAPACKE_ztrexc? = load(name: "LAPACKE_ztrexc", as: FunctionType.LAPACKE_ztrexc.self)
    #elseif os(macOS)
    static let ztrexc: FunctionType.LAPACKE_ztrexc? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strrfs: FunctionType.LAPACKE_strrfs? = load(name: "LAPACKE_strrfs", as: FunctionType.LAPACKE_strrfs.self)
    #elseif os(macOS)
    static let strrfs: FunctionType.LAPACKE_strrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrrfs: FunctionType.LAPACKE_dtrrfs? = load(name: "LAPACKE_dtrrfs", as: FunctionType.LAPACKE_dtrrfs.self)
    #elseif os(macOS)
    static let dtrrfs: FunctionType.LAPACKE_dtrrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrrfs: FunctionType.LAPACKE_ctrrfs? = load(name: "LAPACKE_ctrrfs", as: FunctionType.LAPACKE_ctrrfs.self)
    #elseif os(macOS)
    static let ctrrfs: FunctionType.LAPACKE_ctrrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrrfs: FunctionType.LAPACKE_ztrrfs? = load(name: "LAPACKE_ztrrfs", as: FunctionType.LAPACKE_ztrrfs.self)
    #elseif os(macOS)
    static let ztrrfs: FunctionType.LAPACKE_ztrrfs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsen: FunctionType.LAPACKE_strsen? = load(name: "LAPACKE_strsen", as: FunctionType.LAPACKE_strsen.self)
    #elseif os(macOS)
    static let strsen: FunctionType.LAPACKE_strsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsen: FunctionType.LAPACKE_dtrsen? = load(name: "LAPACKE_dtrsen", as: FunctionType.LAPACKE_dtrsen.self)
    #elseif os(macOS)
    static let dtrsen: FunctionType.LAPACKE_dtrsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsen: FunctionType.LAPACKE_ctrsen? = load(name: "LAPACKE_ctrsen", as: FunctionType.LAPACKE_ctrsen.self)
    #elseif os(macOS)
    static let ctrsen: FunctionType.LAPACKE_ctrsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsen: FunctionType.LAPACKE_ztrsen? = load(name: "LAPACKE_ztrsen", as: FunctionType.LAPACKE_ztrsen.self)
    #elseif os(macOS)
    static let ztrsen: FunctionType.LAPACKE_ztrsen? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsna: FunctionType.LAPACKE_strsna? = load(name: "LAPACKE_strsna", as: FunctionType.LAPACKE_strsna.self)
    #elseif os(macOS)
    static let strsna: FunctionType.LAPACKE_strsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsna: FunctionType.LAPACKE_dtrsna? = load(name: "LAPACKE_dtrsna", as: FunctionType.LAPACKE_dtrsna.self)
    #elseif os(macOS)
    static let dtrsna: FunctionType.LAPACKE_dtrsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsna: FunctionType.LAPACKE_ctrsna? = load(name: "LAPACKE_ctrsna", as: FunctionType.LAPACKE_ctrsna.self)
    #elseif os(macOS)
    static let ctrsna: FunctionType.LAPACKE_ctrsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsna: FunctionType.LAPACKE_ztrsna? = load(name: "LAPACKE_ztrsna", as: FunctionType.LAPACKE_ztrsna.self)
    #elseif os(macOS)
    static let ztrsna: FunctionType.LAPACKE_ztrsna? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl: FunctionType.LAPACKE_strsyl? = load(name: "LAPACKE_strsyl", as: FunctionType.LAPACKE_strsyl.self)
    #elseif os(macOS)
    static let strsyl: FunctionType.LAPACKE_strsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl: FunctionType.LAPACKE_dtrsyl? = load(name: "LAPACKE_dtrsyl", as: FunctionType.LAPACKE_dtrsyl.self)
    #elseif os(macOS)
    static let dtrsyl: FunctionType.LAPACKE_dtrsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsyl: FunctionType.LAPACKE_ctrsyl? = load(name: "LAPACKE_ctrsyl", as: FunctionType.LAPACKE_ctrsyl.self)
    #elseif os(macOS)
    static let ctrsyl: FunctionType.LAPACKE_ctrsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl: FunctionType.LAPACKE_ztrsyl? = load(name: "LAPACKE_ztrsyl", as: FunctionType.LAPACKE_ztrsyl.self)
    #elseif os(macOS)
    static let ztrsyl: FunctionType.LAPACKE_ztrsyl? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl3: FunctionType.LAPACKE_strsyl3? = load(name: "LAPACKE_strsyl3", as: FunctionType.LAPACKE_strsyl3.self)
    #elseif os(macOS)
    static let strsyl3: FunctionType.LAPACKE_strsyl3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl3: FunctionType.LAPACKE_dtrsyl3? = load(name: "LAPACKE_dtrsyl3", as: FunctionType.LAPACKE_dtrsyl3.self)
    #elseif os(macOS)
    static let dtrsyl3: FunctionType.LAPACKE_dtrsyl3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl3: FunctionType.LAPACKE_ztrsyl3? = load(name: "LAPACKE_ztrsyl3", as: FunctionType.LAPACKE_ztrsyl3.self)
    #elseif os(macOS)
    static let ztrsyl3: FunctionType.LAPACKE_ztrsyl3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtri: FunctionType.LAPACKE_strtri? = load(name: "LAPACKE_strtri", as: FunctionType.LAPACKE_strtri.self)
    #elseif os(macOS)
    static let strtri: FunctionType.LAPACKE_strtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtri: FunctionType.LAPACKE_dtrtri? = load(name: "LAPACKE_dtrtri", as: FunctionType.LAPACKE_dtrtri.self)
    #elseif os(macOS)
    static let dtrtri: FunctionType.LAPACKE_dtrtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtri: FunctionType.LAPACKE_ctrtri? = load(name: "LAPACKE_ctrtri", as: FunctionType.LAPACKE_ctrtri.self)
    #elseif os(macOS)
    static let ctrtri: FunctionType.LAPACKE_ctrtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtri: FunctionType.LAPACKE_ztrtri? = load(name: "LAPACKE_ztrtri", as: FunctionType.LAPACKE_ztrtri.self)
    #elseif os(macOS)
    static let ztrtri: FunctionType.LAPACKE_ztrtri? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtrs: FunctionType.LAPACKE_strtrs? = load(name: "LAPACKE_strtrs", as: FunctionType.LAPACKE_strtrs.self)
    #elseif os(macOS)
    static let strtrs: FunctionType.LAPACKE_strtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtrs: FunctionType.LAPACKE_dtrtrs? = load(name: "LAPACKE_dtrtrs", as: FunctionType.LAPACKE_dtrtrs.self)
    #elseif os(macOS)
    static let dtrtrs: FunctionType.LAPACKE_dtrtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtrs: FunctionType.LAPACKE_ctrtrs? = load(name: "LAPACKE_ctrtrs", as: FunctionType.LAPACKE_ctrtrs.self)
    #elseif os(macOS)
    static let ctrtrs: FunctionType.LAPACKE_ctrtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtrs: FunctionType.LAPACKE_ztrtrs? = load(name: "LAPACKE_ztrtrs", as: FunctionType.LAPACKE_ztrtrs.self)
    #elseif os(macOS)
    static let ztrtrs: FunctionType.LAPACKE_ztrtrs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttf: FunctionType.LAPACKE_strttf? = load(name: "LAPACKE_strttf", as: FunctionType.LAPACKE_strttf.self)
    #elseif os(macOS)
    static let strttf: FunctionType.LAPACKE_strttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttf: FunctionType.LAPACKE_dtrttf? = load(name: "LAPACKE_dtrttf", as: FunctionType.LAPACKE_dtrttf.self)
    #elseif os(macOS)
    static let dtrttf: FunctionType.LAPACKE_dtrttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttf: FunctionType.LAPACKE_ctrttf? = load(name: "LAPACKE_ctrttf", as: FunctionType.LAPACKE_ctrttf.self)
    #elseif os(macOS)
    static let ctrttf: FunctionType.LAPACKE_ctrttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttf: FunctionType.LAPACKE_ztrttf? = load(name: "LAPACKE_ztrttf", as: FunctionType.LAPACKE_ztrttf.self)
    #elseif os(macOS)
    static let ztrttf: FunctionType.LAPACKE_ztrttf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttp: FunctionType.LAPACKE_strttp? = load(name: "LAPACKE_strttp", as: FunctionType.LAPACKE_strttp.self)
    #elseif os(macOS)
    static let strttp: FunctionType.LAPACKE_strttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttp: FunctionType.LAPACKE_dtrttp? = load(name: "LAPACKE_dtrttp", as: FunctionType.LAPACKE_dtrttp.self)
    #elseif os(macOS)
    static let dtrttp: FunctionType.LAPACKE_dtrttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttp: FunctionType.LAPACKE_ctrttp? = load(name: "LAPACKE_ctrttp", as: FunctionType.LAPACKE_ctrttp.self)
    #elseif os(macOS)
    static let ctrttp: FunctionType.LAPACKE_ctrttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttp: FunctionType.LAPACKE_ztrttp? = load(name: "LAPACKE_ztrttp", as: FunctionType.LAPACKE_ztrttp.self)
    #elseif os(macOS)
    static let ztrttp: FunctionType.LAPACKE_ztrttp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stzrzf: FunctionType.LAPACKE_stzrzf? = load(name: "LAPACKE_stzrzf", as: FunctionType.LAPACKE_stzrzf.self)
    #elseif os(macOS)
    static let stzrzf: FunctionType.LAPACKE_stzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtzrzf: FunctionType.LAPACKE_dtzrzf? = load(name: "LAPACKE_dtzrzf", as: FunctionType.LAPACKE_dtzrzf.self)
    #elseif os(macOS)
    static let dtzrzf: FunctionType.LAPACKE_dtzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctzrzf: FunctionType.LAPACKE_ctzrzf? = load(name: "LAPACKE_ctzrzf", as: FunctionType.LAPACKE_ctzrzf.self)
    #elseif os(macOS)
    static let ctzrzf: FunctionType.LAPACKE_ctzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztzrzf: FunctionType.LAPACKE_ztzrzf? = load(name: "LAPACKE_ztzrzf", as: FunctionType.LAPACKE_ztzrzf.self)
    #elseif os(macOS)
    static let ztzrzf: FunctionType.LAPACKE_ztzrzf? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungbr: FunctionType.LAPACKE_cungbr? = load(name: "LAPACKE_cungbr", as: FunctionType.LAPACKE_cungbr.self)
    #elseif os(macOS)
    static let cungbr: FunctionType.LAPACKE_cungbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungbr: FunctionType.LAPACKE_zungbr? = load(name: "LAPACKE_zungbr", as: FunctionType.LAPACKE_zungbr.self)
    #elseif os(macOS)
    static let zungbr: FunctionType.LAPACKE_zungbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunghr: FunctionType.LAPACKE_cunghr? = load(name: "LAPACKE_cunghr", as: FunctionType.LAPACKE_cunghr.self)
    #elseif os(macOS)
    static let cunghr: FunctionType.LAPACKE_cunghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunghr: FunctionType.LAPACKE_zunghr? = load(name: "LAPACKE_zunghr", as: FunctionType.LAPACKE_zunghr.self)
    #elseif os(macOS)
    static let zunghr: FunctionType.LAPACKE_zunghr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunglq: FunctionType.LAPACKE_cunglq? = load(name: "LAPACKE_cunglq", as: FunctionType.LAPACKE_cunglq.self)
    #elseif os(macOS)
    static let cunglq: FunctionType.LAPACKE_cunglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunglq: FunctionType.LAPACKE_zunglq? = load(name: "LAPACKE_zunglq", as: FunctionType.LAPACKE_zunglq.self)
    #elseif os(macOS)
    static let zunglq: FunctionType.LAPACKE_zunglq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungql: FunctionType.LAPACKE_cungql? = load(name: "LAPACKE_cungql", as: FunctionType.LAPACKE_cungql.self)
    #elseif os(macOS)
    static let cungql: FunctionType.LAPACKE_cungql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungql: FunctionType.LAPACKE_zungql? = load(name: "LAPACKE_zungql", as: FunctionType.LAPACKE_zungql.self)
    #elseif os(macOS)
    static let zungql: FunctionType.LAPACKE_zungql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungqr: FunctionType.LAPACKE_cungqr? = load(name: "LAPACKE_cungqr", as: FunctionType.LAPACKE_cungqr.self)
    #elseif os(macOS)
    static let cungqr: FunctionType.LAPACKE_cungqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungqr: FunctionType.LAPACKE_zungqr? = load(name: "LAPACKE_zungqr", as: FunctionType.LAPACKE_zungqr.self)
    #elseif os(macOS)
    static let zungqr: FunctionType.LAPACKE_zungqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungrq: FunctionType.LAPACKE_cungrq? = load(name: "LAPACKE_cungrq", as: FunctionType.LAPACKE_cungrq.self)
    #elseif os(macOS)
    static let cungrq: FunctionType.LAPACKE_cungrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungrq: FunctionType.LAPACKE_zungrq? = load(name: "LAPACKE_zungrq", as: FunctionType.LAPACKE_zungrq.self)
    #elseif os(macOS)
    static let zungrq: FunctionType.LAPACKE_zungrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtr: FunctionType.LAPACKE_cungtr? = load(name: "LAPACKE_cungtr", as: FunctionType.LAPACKE_cungtr.self)
    #elseif os(macOS)
    static let cungtr: FunctionType.LAPACKE_cungtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtr: FunctionType.LAPACKE_zungtr? = load(name: "LAPACKE_zungtr", as: FunctionType.LAPACKE_zungtr.self)
    #elseif os(macOS)
    static let zungtr: FunctionType.LAPACKE_zungtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtsqr_row: FunctionType.LAPACKE_cungtsqr_row? = load(name: "LAPACKE_cungtsqr_row", as: FunctionType.LAPACKE_cungtsqr_row.self)
    #elseif os(macOS)
    static let cungtsqr_row: FunctionType.LAPACKE_cungtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtsqr_row: FunctionType.LAPACKE_zungtsqr_row? = load(name: "LAPACKE_zungtsqr_row", as: FunctionType.LAPACKE_zungtsqr_row.self)
    #elseif os(macOS)
    static let zungtsqr_row: FunctionType.LAPACKE_zungtsqr_row? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmbr: FunctionType.LAPACKE_cunmbr? = load(name: "LAPACKE_cunmbr", as: FunctionType.LAPACKE_cunmbr.self)
    #elseif os(macOS)
    static let cunmbr: FunctionType.LAPACKE_cunmbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmbr: FunctionType.LAPACKE_zunmbr? = load(name: "LAPACKE_zunmbr", as: FunctionType.LAPACKE_zunmbr.self)
    #elseif os(macOS)
    static let zunmbr: FunctionType.LAPACKE_zunmbr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmhr: FunctionType.LAPACKE_cunmhr? = load(name: "LAPACKE_cunmhr", as: FunctionType.LAPACKE_cunmhr.self)
    #elseif os(macOS)
    static let cunmhr: FunctionType.LAPACKE_cunmhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmhr: FunctionType.LAPACKE_zunmhr? = load(name: "LAPACKE_zunmhr", as: FunctionType.LAPACKE_zunmhr.self)
    #elseif os(macOS)
    static let zunmhr: FunctionType.LAPACKE_zunmhr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmlq: FunctionType.LAPACKE_cunmlq? = load(name: "LAPACKE_cunmlq", as: FunctionType.LAPACKE_cunmlq.self)
    #elseif os(macOS)
    static let cunmlq: FunctionType.LAPACKE_cunmlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmlq: FunctionType.LAPACKE_zunmlq? = load(name: "LAPACKE_zunmlq", as: FunctionType.LAPACKE_zunmlq.self)
    #elseif os(macOS)
    static let zunmlq: FunctionType.LAPACKE_zunmlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmql: FunctionType.LAPACKE_cunmql? = load(name: "LAPACKE_cunmql", as: FunctionType.LAPACKE_cunmql.self)
    #elseif os(macOS)
    static let cunmql: FunctionType.LAPACKE_cunmql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmql: FunctionType.LAPACKE_zunmql? = load(name: "LAPACKE_zunmql", as: FunctionType.LAPACKE_zunmql.self)
    #elseif os(macOS)
    static let zunmql: FunctionType.LAPACKE_zunmql? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmqr: FunctionType.LAPACKE_cunmqr? = load(name: "LAPACKE_cunmqr", as: FunctionType.LAPACKE_cunmqr.self)
    #elseif os(macOS)
    static let cunmqr: FunctionType.LAPACKE_cunmqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmqr: FunctionType.LAPACKE_zunmqr? = load(name: "LAPACKE_zunmqr", as: FunctionType.LAPACKE_zunmqr.self)
    #elseif os(macOS)
    static let zunmqr: FunctionType.LAPACKE_zunmqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrq: FunctionType.LAPACKE_cunmrq? = load(name: "LAPACKE_cunmrq", as: FunctionType.LAPACKE_cunmrq.self)
    #elseif os(macOS)
    static let cunmrq: FunctionType.LAPACKE_cunmrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrq: FunctionType.LAPACKE_zunmrq? = load(name: "LAPACKE_zunmrq", as: FunctionType.LAPACKE_zunmrq.self)
    #elseif os(macOS)
    static let zunmrq: FunctionType.LAPACKE_zunmrq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrz: FunctionType.LAPACKE_cunmrz? = load(name: "LAPACKE_cunmrz", as: FunctionType.LAPACKE_cunmrz.self)
    #elseif os(macOS)
    static let cunmrz: FunctionType.LAPACKE_cunmrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrz: FunctionType.LAPACKE_zunmrz? = load(name: "LAPACKE_zunmrz", as: FunctionType.LAPACKE_zunmrz.self)
    #elseif os(macOS)
    static let zunmrz: FunctionType.LAPACKE_zunmrz? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmtr: FunctionType.LAPACKE_cunmtr? = load(name: "LAPACKE_cunmtr", as: FunctionType.LAPACKE_cunmtr.self)
    #elseif os(macOS)
    static let cunmtr: FunctionType.LAPACKE_cunmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmtr: FunctionType.LAPACKE_zunmtr? = load(name: "LAPACKE_zunmtr", as: FunctionType.LAPACKE_zunmtr.self)
    #elseif os(macOS)
    static let zunmtr: FunctionType.LAPACKE_zunmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupgtr: FunctionType.LAPACKE_cupgtr? = load(name: "LAPACKE_cupgtr", as: FunctionType.LAPACKE_cupgtr.self)
    #elseif os(macOS)
    static let cupgtr: FunctionType.LAPACKE_cupgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupgtr: FunctionType.LAPACKE_zupgtr? = load(name: "LAPACKE_zupgtr", as: FunctionType.LAPACKE_zupgtr.self)
    #elseif os(macOS)
    static let zupgtr: FunctionType.LAPACKE_zupgtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupmtr: FunctionType.LAPACKE_cupmtr? = load(name: "LAPACKE_cupmtr", as: FunctionType.LAPACKE_cupmtr.self)
    #elseif os(macOS)
    static let cupmtr: FunctionType.LAPACKE_cupmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupmtr: FunctionType.LAPACKE_zupmtr? = load(name: "LAPACKE_zupmtr", as: FunctionType.LAPACKE_zupmtr.self)
    #elseif os(macOS)
    static let zupmtr: FunctionType.LAPACKE_zupmtr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsdc_work: FunctionType.LAPACKE_sbdsdc_work? = load(name: "LAPACKE_sbdsdc_work", as: FunctionType.LAPACKE_sbdsdc_work.self)
    #elseif os(macOS)
    static let sbdsdc_work: FunctionType.LAPACKE_sbdsdc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsdc_work: FunctionType.LAPACKE_dbdsdc_work? = load(name: "LAPACKE_dbdsdc_work", as: FunctionType.LAPACKE_dbdsdc_work.self)
    #elseif os(macOS)
    static let dbdsdc_work: FunctionType.LAPACKE_dbdsdc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsvdx_work: FunctionType.LAPACKE_sbdsvdx_work? = load(name: "LAPACKE_sbdsvdx_work", as: FunctionType.LAPACKE_sbdsvdx_work.self)
    #elseif os(macOS)
    static let sbdsvdx_work: FunctionType.LAPACKE_sbdsvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsvdx_work: FunctionType.LAPACKE_dbdsvdx_work? = load(name: "LAPACKE_dbdsvdx_work", as: FunctionType.LAPACKE_dbdsvdx_work.self)
    #elseif os(macOS)
    static let dbdsvdx_work: FunctionType.LAPACKE_dbdsvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbdsqr_work: FunctionType.LAPACKE_sbdsqr_work? = load(name: "LAPACKE_sbdsqr_work", as: FunctionType.LAPACKE_sbdsqr_work.self)
    #elseif os(macOS)
    static let sbdsqr_work: FunctionType.LAPACKE_sbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbdsqr_work: FunctionType.LAPACKE_dbdsqr_work? = load(name: "LAPACKE_dbdsqr_work", as: FunctionType.LAPACKE_dbdsqr_work.self)
    #elseif os(macOS)
    static let dbdsqr_work: FunctionType.LAPACKE_dbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbdsqr_work: FunctionType.LAPACKE_cbdsqr_work? = load(name: "LAPACKE_cbdsqr_work", as: FunctionType.LAPACKE_cbdsqr_work.self)
    #elseif os(macOS)
    static let cbdsqr_work: FunctionType.LAPACKE_cbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbdsqr_work: FunctionType.LAPACKE_zbdsqr_work? = load(name: "LAPACKE_zbdsqr_work", as: FunctionType.LAPACKE_zbdsqr_work.self)
    #elseif os(macOS)
    static let zbdsqr_work: FunctionType.LAPACKE_zbdsqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sdisna_work: FunctionType.LAPACKE_sdisna_work? = load(name: "LAPACKE_sdisna_work", as: FunctionType.LAPACKE_sdisna_work.self)
    #elseif os(macOS)
    static let sdisna_work: FunctionType.LAPACKE_sdisna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ddisna_work: FunctionType.LAPACKE_ddisna_work? = load(name: "LAPACKE_ddisna_work", as: FunctionType.LAPACKE_ddisna_work.self)
    #elseif os(macOS)
    static let ddisna_work: FunctionType.LAPACKE_ddisna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbbrd_work: FunctionType.LAPACKE_sgbbrd_work? = load(name: "LAPACKE_sgbbrd_work", as: FunctionType.LAPACKE_sgbbrd_work.self)
    #elseif os(macOS)
    static let sgbbrd_work: FunctionType.LAPACKE_sgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbbrd_work: FunctionType.LAPACKE_dgbbrd_work? = load(name: "LAPACKE_dgbbrd_work", as: FunctionType.LAPACKE_dgbbrd_work.self)
    #elseif os(macOS)
    static let dgbbrd_work: FunctionType.LAPACKE_dgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbbrd_work: FunctionType.LAPACKE_cgbbrd_work? = load(name: "LAPACKE_cgbbrd_work", as: FunctionType.LAPACKE_cgbbrd_work.self)
    #elseif os(macOS)
    static let cgbbrd_work: FunctionType.LAPACKE_cgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbbrd_work: FunctionType.LAPACKE_zgbbrd_work? = load(name: "LAPACKE_zgbbrd_work", as: FunctionType.LAPACKE_zgbbrd_work.self)
    #elseif os(macOS)
    static let zgbbrd_work: FunctionType.LAPACKE_zgbbrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbcon_work: FunctionType.LAPACKE_sgbcon_work? = load(name: "LAPACKE_sgbcon_work", as: FunctionType.LAPACKE_sgbcon_work.self)
    #elseif os(macOS)
    static let sgbcon_work: FunctionType.LAPACKE_sgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbcon_work: FunctionType.LAPACKE_dgbcon_work? = load(name: "LAPACKE_dgbcon_work", as: FunctionType.LAPACKE_dgbcon_work.self)
    #elseif os(macOS)
    static let dgbcon_work: FunctionType.LAPACKE_dgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbcon_work: FunctionType.LAPACKE_cgbcon_work? = load(name: "LAPACKE_cgbcon_work", as: FunctionType.LAPACKE_cgbcon_work.self)
    #elseif os(macOS)
    static let cgbcon_work: FunctionType.LAPACKE_cgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbcon_work: FunctionType.LAPACKE_zgbcon_work? = load(name: "LAPACKE_zgbcon_work", as: FunctionType.LAPACKE_zgbcon_work.self)
    #elseif os(macOS)
    static let zgbcon_work: FunctionType.LAPACKE_zgbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequ_work: FunctionType.LAPACKE_sgbequ_work? = load(name: "LAPACKE_sgbequ_work", as: FunctionType.LAPACKE_sgbequ_work.self)
    #elseif os(macOS)
    static let sgbequ_work: FunctionType.LAPACKE_sgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequ_work: FunctionType.LAPACKE_dgbequ_work? = load(name: "LAPACKE_dgbequ_work", as: FunctionType.LAPACKE_dgbequ_work.self)
    #elseif os(macOS)
    static let dgbequ_work: FunctionType.LAPACKE_dgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequ_work: FunctionType.LAPACKE_cgbequ_work? = load(name: "LAPACKE_cgbequ_work", as: FunctionType.LAPACKE_cgbequ_work.self)
    #elseif os(macOS)
    static let cgbequ_work: FunctionType.LAPACKE_cgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequ_work: FunctionType.LAPACKE_zgbequ_work? = load(name: "LAPACKE_zgbequ_work", as: FunctionType.LAPACKE_zgbequ_work.self)
    #elseif os(macOS)
    static let zgbequ_work: FunctionType.LAPACKE_zgbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbequb_work: FunctionType.LAPACKE_sgbequb_work? = load(name: "LAPACKE_sgbequb_work", as: FunctionType.LAPACKE_sgbequb_work.self)
    #elseif os(macOS)
    static let sgbequb_work: FunctionType.LAPACKE_sgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbequb_work: FunctionType.LAPACKE_dgbequb_work? = load(name: "LAPACKE_dgbequb_work", as: FunctionType.LAPACKE_dgbequb_work.self)
    #elseif os(macOS)
    static let dgbequb_work: FunctionType.LAPACKE_dgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbequb_work: FunctionType.LAPACKE_cgbequb_work? = load(name: "LAPACKE_cgbequb_work", as: FunctionType.LAPACKE_cgbequb_work.self)
    #elseif os(macOS)
    static let cgbequb_work: FunctionType.LAPACKE_cgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbequb_work: FunctionType.LAPACKE_zgbequb_work? = load(name: "LAPACKE_zgbequb_work", as: FunctionType.LAPACKE_zgbequb_work.self)
    #elseif os(macOS)
    static let zgbequb_work: FunctionType.LAPACKE_zgbequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfs_work: FunctionType.LAPACKE_sgbrfs_work? = load(name: "LAPACKE_sgbrfs_work", as: FunctionType.LAPACKE_sgbrfs_work.self)
    #elseif os(macOS)
    static let sgbrfs_work: FunctionType.LAPACKE_sgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfs_work: FunctionType.LAPACKE_dgbrfs_work? = load(name: "LAPACKE_dgbrfs_work", as: FunctionType.LAPACKE_dgbrfs_work.self)
    #elseif os(macOS)
    static let dgbrfs_work: FunctionType.LAPACKE_dgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfs_work: FunctionType.LAPACKE_cgbrfs_work? = load(name: "LAPACKE_cgbrfs_work", as: FunctionType.LAPACKE_cgbrfs_work.self)
    #elseif os(macOS)
    static let cgbrfs_work: FunctionType.LAPACKE_cgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfs_work: FunctionType.LAPACKE_zgbrfs_work? = load(name: "LAPACKE_zgbrfs_work", as: FunctionType.LAPACKE_zgbrfs_work.self)
    #elseif os(macOS)
    static let zgbrfs_work: FunctionType.LAPACKE_zgbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbrfsx_work: FunctionType.LAPACKE_sgbrfsx_work? = load(name: "LAPACKE_sgbrfsx_work", as: FunctionType.LAPACKE_sgbrfsx_work.self)
    #elseif os(macOS)
    static let sgbrfsx_work: FunctionType.LAPACKE_sgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbrfsx_work: FunctionType.LAPACKE_dgbrfsx_work? = load(name: "LAPACKE_dgbrfsx_work", as: FunctionType.LAPACKE_dgbrfsx_work.self)
    #elseif os(macOS)
    static let dgbrfsx_work: FunctionType.LAPACKE_dgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbrfsx_work: FunctionType.LAPACKE_cgbrfsx_work? = load(name: "LAPACKE_cgbrfsx_work", as: FunctionType.LAPACKE_cgbrfsx_work.self)
    #elseif os(macOS)
    static let cgbrfsx_work: FunctionType.LAPACKE_cgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbrfsx_work: FunctionType.LAPACKE_zgbrfsx_work? = load(name: "LAPACKE_zgbrfsx_work", as: FunctionType.LAPACKE_zgbrfsx_work.self)
    #elseif os(macOS)
    static let zgbrfsx_work: FunctionType.LAPACKE_zgbrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsv_work: FunctionType.LAPACKE_sgbsv_work? = load(name: "LAPACKE_sgbsv_work", as: FunctionType.LAPACKE_sgbsv_work.self)
    #elseif os(macOS)
    static let sgbsv_work: FunctionType.LAPACKE_sgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsv_work: FunctionType.LAPACKE_dgbsv_work? = load(name: "LAPACKE_dgbsv_work", as: FunctionType.LAPACKE_dgbsv_work.self)
    #elseif os(macOS)
    static let dgbsv_work: FunctionType.LAPACKE_dgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsv_work: FunctionType.LAPACKE_cgbsv_work? = load(name: "LAPACKE_cgbsv_work", as: FunctionType.LAPACKE_cgbsv_work.self)
    #elseif os(macOS)
    static let cgbsv_work: FunctionType.LAPACKE_cgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsv_work: FunctionType.LAPACKE_zgbsv_work? = load(name: "LAPACKE_zgbsv_work", as: FunctionType.LAPACKE_zgbsv_work.self)
    #elseif os(macOS)
    static let zgbsv_work: FunctionType.LAPACKE_zgbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvx_work: FunctionType.LAPACKE_sgbsvx_work? = load(name: "LAPACKE_sgbsvx_work", as: FunctionType.LAPACKE_sgbsvx_work.self)
    #elseif os(macOS)
    static let sgbsvx_work: FunctionType.LAPACKE_sgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvx_work: FunctionType.LAPACKE_dgbsvx_work? = load(name: "LAPACKE_dgbsvx_work", as: FunctionType.LAPACKE_dgbsvx_work.self)
    #elseif os(macOS)
    static let dgbsvx_work: FunctionType.LAPACKE_dgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvx_work: FunctionType.LAPACKE_cgbsvx_work? = load(name: "LAPACKE_cgbsvx_work", as: FunctionType.LAPACKE_cgbsvx_work.self)
    #elseif os(macOS)
    static let cgbsvx_work: FunctionType.LAPACKE_cgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvx_work: FunctionType.LAPACKE_zgbsvx_work? = load(name: "LAPACKE_zgbsvx_work", as: FunctionType.LAPACKE_zgbsvx_work.self)
    #elseif os(macOS)
    static let zgbsvx_work: FunctionType.LAPACKE_zgbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbsvxx_work: FunctionType.LAPACKE_sgbsvxx_work? = load(name: "LAPACKE_sgbsvxx_work", as: FunctionType.LAPACKE_sgbsvxx_work.self)
    #elseif os(macOS)
    static let sgbsvxx_work: FunctionType.LAPACKE_sgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbsvxx_work: FunctionType.LAPACKE_dgbsvxx_work? = load(name: "LAPACKE_dgbsvxx_work", as: FunctionType.LAPACKE_dgbsvxx_work.self)
    #elseif os(macOS)
    static let dgbsvxx_work: FunctionType.LAPACKE_dgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbsvxx_work: FunctionType.LAPACKE_cgbsvxx_work? = load(name: "LAPACKE_cgbsvxx_work", as: FunctionType.LAPACKE_cgbsvxx_work.self)
    #elseif os(macOS)
    static let cgbsvxx_work: FunctionType.LAPACKE_cgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbsvxx_work: FunctionType.LAPACKE_zgbsvxx_work? = load(name: "LAPACKE_zgbsvxx_work", as: FunctionType.LAPACKE_zgbsvxx_work.self)
    #elseif os(macOS)
    static let zgbsvxx_work: FunctionType.LAPACKE_zgbsvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrf_work: FunctionType.LAPACKE_sgbtrf_work? = load(name: "LAPACKE_sgbtrf_work", as: FunctionType.LAPACKE_sgbtrf_work.self)
    #elseif os(macOS)
    static let sgbtrf_work: FunctionType.LAPACKE_sgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrf_work: FunctionType.LAPACKE_dgbtrf_work? = load(name: "LAPACKE_dgbtrf_work", as: FunctionType.LAPACKE_dgbtrf_work.self)
    #elseif os(macOS)
    static let dgbtrf_work: FunctionType.LAPACKE_dgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrf_work: FunctionType.LAPACKE_cgbtrf_work? = load(name: "LAPACKE_cgbtrf_work", as: FunctionType.LAPACKE_cgbtrf_work.self)
    #elseif os(macOS)
    static let cgbtrf_work: FunctionType.LAPACKE_cgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrf_work: FunctionType.LAPACKE_zgbtrf_work? = load(name: "LAPACKE_zgbtrf_work", as: FunctionType.LAPACKE_zgbtrf_work.self)
    #elseif os(macOS)
    static let zgbtrf_work: FunctionType.LAPACKE_zgbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgbtrs_work: FunctionType.LAPACKE_sgbtrs_work? = load(name: "LAPACKE_sgbtrs_work", as: FunctionType.LAPACKE_sgbtrs_work.self)
    #elseif os(macOS)
    static let sgbtrs_work: FunctionType.LAPACKE_sgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgbtrs_work: FunctionType.LAPACKE_dgbtrs_work? = load(name: "LAPACKE_dgbtrs_work", as: FunctionType.LAPACKE_dgbtrs_work.self)
    #elseif os(macOS)
    static let dgbtrs_work: FunctionType.LAPACKE_dgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgbtrs_work: FunctionType.LAPACKE_cgbtrs_work? = load(name: "LAPACKE_cgbtrs_work", as: FunctionType.LAPACKE_cgbtrs_work.self)
    #elseif os(macOS)
    static let cgbtrs_work: FunctionType.LAPACKE_cgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgbtrs_work: FunctionType.LAPACKE_zgbtrs_work? = load(name: "LAPACKE_zgbtrs_work", as: FunctionType.LAPACKE_zgbtrs_work.self)
    #elseif os(macOS)
    static let zgbtrs_work: FunctionType.LAPACKE_zgbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebak_work: FunctionType.LAPACKE_sgebak_work? = load(name: "LAPACKE_sgebak_work", as: FunctionType.LAPACKE_sgebak_work.self)
    #elseif os(macOS)
    static let sgebak_work: FunctionType.LAPACKE_sgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebak_work: FunctionType.LAPACKE_dgebak_work? = load(name: "LAPACKE_dgebak_work", as: FunctionType.LAPACKE_dgebak_work.self)
    #elseif os(macOS)
    static let dgebak_work: FunctionType.LAPACKE_dgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebak_work: FunctionType.LAPACKE_cgebak_work? = load(name: "LAPACKE_cgebak_work", as: FunctionType.LAPACKE_cgebak_work.self)
    #elseif os(macOS)
    static let cgebak_work: FunctionType.LAPACKE_cgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebak_work: FunctionType.LAPACKE_zgebak_work? = load(name: "LAPACKE_zgebak_work", as: FunctionType.LAPACKE_zgebak_work.self)
    #elseif os(macOS)
    static let zgebak_work: FunctionType.LAPACKE_zgebak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebal_work: FunctionType.LAPACKE_sgebal_work? = load(name: "LAPACKE_sgebal_work", as: FunctionType.LAPACKE_sgebal_work.self)
    #elseif os(macOS)
    static let sgebal_work: FunctionType.LAPACKE_sgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebal_work: FunctionType.LAPACKE_dgebal_work? = load(name: "LAPACKE_dgebal_work", as: FunctionType.LAPACKE_dgebal_work.self)
    #elseif os(macOS)
    static let dgebal_work: FunctionType.LAPACKE_dgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebal_work: FunctionType.LAPACKE_cgebal_work? = load(name: "LAPACKE_cgebal_work", as: FunctionType.LAPACKE_cgebal_work.self)
    #elseif os(macOS)
    static let cgebal_work: FunctionType.LAPACKE_cgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebal_work: FunctionType.LAPACKE_zgebal_work? = load(name: "LAPACKE_zgebal_work", as: FunctionType.LAPACKE_zgebal_work.self)
    #elseif os(macOS)
    static let zgebal_work: FunctionType.LAPACKE_zgebal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgebrd_work: FunctionType.LAPACKE_sgebrd_work? = load(name: "LAPACKE_sgebrd_work", as: FunctionType.LAPACKE_sgebrd_work.self)
    #elseif os(macOS)
    static let sgebrd_work: FunctionType.LAPACKE_sgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgebrd_work: FunctionType.LAPACKE_dgebrd_work? = load(name: "LAPACKE_dgebrd_work", as: FunctionType.LAPACKE_dgebrd_work.self)
    #elseif os(macOS)
    static let dgebrd_work: FunctionType.LAPACKE_dgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgebrd_work: FunctionType.LAPACKE_cgebrd_work? = load(name: "LAPACKE_cgebrd_work", as: FunctionType.LAPACKE_cgebrd_work.self)
    #elseif os(macOS)
    static let cgebrd_work: FunctionType.LAPACKE_cgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgebrd_work: FunctionType.LAPACKE_zgebrd_work? = load(name: "LAPACKE_zgebrd_work", as: FunctionType.LAPACKE_zgebrd_work.self)
    #elseif os(macOS)
    static let zgebrd_work: FunctionType.LAPACKE_zgebrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgecon_work: FunctionType.LAPACKE_sgecon_work? = load(name: "LAPACKE_sgecon_work", as: FunctionType.LAPACKE_sgecon_work.self)
    #elseif os(macOS)
    static let sgecon_work: FunctionType.LAPACKE_sgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgecon_work: FunctionType.LAPACKE_dgecon_work? = load(name: "LAPACKE_dgecon_work", as: FunctionType.LAPACKE_dgecon_work.self)
    #elseif os(macOS)
    static let dgecon_work: FunctionType.LAPACKE_dgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgecon_work: FunctionType.LAPACKE_cgecon_work? = load(name: "LAPACKE_cgecon_work", as: FunctionType.LAPACKE_cgecon_work.self)
    #elseif os(macOS)
    static let cgecon_work: FunctionType.LAPACKE_cgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgecon_work: FunctionType.LAPACKE_zgecon_work? = load(name: "LAPACKE_zgecon_work", as: FunctionType.LAPACKE_zgecon_work.self)
    #elseif os(macOS)
    static let zgecon_work: FunctionType.LAPACKE_zgecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequ_work: FunctionType.LAPACKE_sgeequ_work? = load(name: "LAPACKE_sgeequ_work", as: FunctionType.LAPACKE_sgeequ_work.self)
    #elseif os(macOS)
    static let sgeequ_work: FunctionType.LAPACKE_sgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequ_work: FunctionType.LAPACKE_dgeequ_work? = load(name: "LAPACKE_dgeequ_work", as: FunctionType.LAPACKE_dgeequ_work.self)
    #elseif os(macOS)
    static let dgeequ_work: FunctionType.LAPACKE_dgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequ_work: FunctionType.LAPACKE_cgeequ_work? = load(name: "LAPACKE_cgeequ_work", as: FunctionType.LAPACKE_cgeequ_work.self)
    #elseif os(macOS)
    static let cgeequ_work: FunctionType.LAPACKE_cgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequ_work: FunctionType.LAPACKE_zgeequ_work? = load(name: "LAPACKE_zgeequ_work", as: FunctionType.LAPACKE_zgeequ_work.self)
    #elseif os(macOS)
    static let zgeequ_work: FunctionType.LAPACKE_zgeequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeequb_work: FunctionType.LAPACKE_sgeequb_work? = load(name: "LAPACKE_sgeequb_work", as: FunctionType.LAPACKE_sgeequb_work.self)
    #elseif os(macOS)
    static let sgeequb_work: FunctionType.LAPACKE_sgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeequb_work: FunctionType.LAPACKE_dgeequb_work? = load(name: "LAPACKE_dgeequb_work", as: FunctionType.LAPACKE_dgeequb_work.self)
    #elseif os(macOS)
    static let dgeequb_work: FunctionType.LAPACKE_dgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeequb_work: FunctionType.LAPACKE_cgeequb_work? = load(name: "LAPACKE_cgeequb_work", as: FunctionType.LAPACKE_cgeequb_work.self)
    #elseif os(macOS)
    static let cgeequb_work: FunctionType.LAPACKE_cgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeequb_work: FunctionType.LAPACKE_zgeequb_work? = load(name: "LAPACKE_zgeequb_work", as: FunctionType.LAPACKE_zgeequb_work.self)
    #elseif os(macOS)
    static let zgeequb_work: FunctionType.LAPACKE_zgeequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgees_work: FunctionType.LAPACKE_sgees_work? = load(name: "LAPACKE_sgees_work", as: FunctionType.LAPACKE_sgees_work.self)
    #elseif os(macOS)
    static let sgees_work: FunctionType.LAPACKE_sgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgees_work: FunctionType.LAPACKE_dgees_work? = load(name: "LAPACKE_dgees_work", as: FunctionType.LAPACKE_dgees_work.self)
    #elseif os(macOS)
    static let dgees_work: FunctionType.LAPACKE_dgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgees_work: FunctionType.LAPACKE_cgees_work? = load(name: "LAPACKE_cgees_work", as: FunctionType.LAPACKE_cgees_work.self)
    #elseif os(macOS)
    static let cgees_work: FunctionType.LAPACKE_cgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgees_work: FunctionType.LAPACKE_zgees_work? = load(name: "LAPACKE_zgees_work", as: FunctionType.LAPACKE_zgees_work.self)
    #elseif os(macOS)
    static let zgees_work: FunctionType.LAPACKE_zgees_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeesx_work: FunctionType.LAPACKE_sgeesx_work? = load(name: "LAPACKE_sgeesx_work", as: FunctionType.LAPACKE_sgeesx_work.self)
    #elseif os(macOS)
    static let sgeesx_work: FunctionType.LAPACKE_sgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeesx_work: FunctionType.LAPACKE_dgeesx_work? = load(name: "LAPACKE_dgeesx_work", as: FunctionType.LAPACKE_dgeesx_work.self)
    #elseif os(macOS)
    static let dgeesx_work: FunctionType.LAPACKE_dgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeesx_work: FunctionType.LAPACKE_cgeesx_work? = load(name: "LAPACKE_cgeesx_work", as: FunctionType.LAPACKE_cgeesx_work.self)
    #elseif os(macOS)
    static let cgeesx_work: FunctionType.LAPACKE_cgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeesx_work: FunctionType.LAPACKE_zgeesx_work? = load(name: "LAPACKE_zgeesx_work", as: FunctionType.LAPACKE_zgeesx_work.self)
    #elseif os(macOS)
    static let zgeesx_work: FunctionType.LAPACKE_zgeesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeev_work: FunctionType.LAPACKE_sgeev_work? = load(name: "LAPACKE_sgeev_work", as: FunctionType.LAPACKE_sgeev_work.self)
    #elseif os(macOS)
    static let sgeev_work: FunctionType.LAPACKE_sgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeev_work: FunctionType.LAPACKE_dgeev_work? = load(name: "LAPACKE_dgeev_work", as: FunctionType.LAPACKE_dgeev_work.self)
    #elseif os(macOS)
    static let dgeev_work: FunctionType.LAPACKE_dgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeev_work: FunctionType.LAPACKE_cgeev_work? = load(name: "LAPACKE_cgeev_work", as: FunctionType.LAPACKE_cgeev_work.self)
    #elseif os(macOS)
    static let cgeev_work: FunctionType.LAPACKE_cgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeev_work: FunctionType.LAPACKE_zgeev_work? = load(name: "LAPACKE_zgeev_work", as: FunctionType.LAPACKE_zgeev_work.self)
    #elseif os(macOS)
    static let zgeev_work: FunctionType.LAPACKE_zgeev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeevx_work: FunctionType.LAPACKE_sgeevx_work? = load(name: "LAPACKE_sgeevx_work", as: FunctionType.LAPACKE_sgeevx_work.self)
    #elseif os(macOS)
    static let sgeevx_work: FunctionType.LAPACKE_sgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeevx_work: FunctionType.LAPACKE_dgeevx_work? = load(name: "LAPACKE_dgeevx_work", as: FunctionType.LAPACKE_dgeevx_work.self)
    #elseif os(macOS)
    static let dgeevx_work: FunctionType.LAPACKE_dgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeevx_work: FunctionType.LAPACKE_cgeevx_work? = load(name: "LAPACKE_cgeevx_work", as: FunctionType.LAPACKE_cgeevx_work.self)
    #elseif os(macOS)
    static let cgeevx_work: FunctionType.LAPACKE_cgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeevx_work: FunctionType.LAPACKE_zgeevx_work? = load(name: "LAPACKE_zgeevx_work", as: FunctionType.LAPACKE_zgeevx_work.self)
    #elseif os(macOS)
    static let zgeevx_work: FunctionType.LAPACKE_zgeevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgehrd_work: FunctionType.LAPACKE_sgehrd_work? = load(name: "LAPACKE_sgehrd_work", as: FunctionType.LAPACKE_sgehrd_work.self)
    #elseif os(macOS)
    static let sgehrd_work: FunctionType.LAPACKE_sgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgehrd_work: FunctionType.LAPACKE_dgehrd_work? = load(name: "LAPACKE_dgehrd_work", as: FunctionType.LAPACKE_dgehrd_work.self)
    #elseif os(macOS)
    static let dgehrd_work: FunctionType.LAPACKE_dgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgehrd_work: FunctionType.LAPACKE_cgehrd_work? = load(name: "LAPACKE_cgehrd_work", as: FunctionType.LAPACKE_cgehrd_work.self)
    #elseif os(macOS)
    static let cgehrd_work: FunctionType.LAPACKE_cgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgehrd_work: FunctionType.LAPACKE_zgehrd_work? = load(name: "LAPACKE_zgehrd_work", as: FunctionType.LAPACKE_zgehrd_work.self)
    #elseif os(macOS)
    static let zgehrd_work: FunctionType.LAPACKE_zgehrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgejsv_work: FunctionType.LAPACKE_sgejsv_work? = load(name: "LAPACKE_sgejsv_work", as: FunctionType.LAPACKE_sgejsv_work.self)
    #elseif os(macOS)
    static let sgejsv_work: FunctionType.LAPACKE_sgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgejsv_work: FunctionType.LAPACKE_dgejsv_work? = load(name: "LAPACKE_dgejsv_work", as: FunctionType.LAPACKE_dgejsv_work.self)
    #elseif os(macOS)
    static let dgejsv_work: FunctionType.LAPACKE_dgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgejsv_work: FunctionType.LAPACKE_cgejsv_work? = load(name: "LAPACKE_cgejsv_work", as: FunctionType.LAPACKE_cgejsv_work.self)
    #elseif os(macOS)
    static let cgejsv_work: FunctionType.LAPACKE_cgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgejsv_work: FunctionType.LAPACKE_zgejsv_work? = load(name: "LAPACKE_zgejsv_work", as: FunctionType.LAPACKE_zgejsv_work.self)
    #elseif os(macOS)
    static let zgejsv_work: FunctionType.LAPACKE_zgejsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq2_work: FunctionType.LAPACKE_sgelq2_work? = load(name: "LAPACKE_sgelq2_work", as: FunctionType.LAPACKE_sgelq2_work.self)
    #elseif os(macOS)
    static let sgelq2_work: FunctionType.LAPACKE_sgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq2_work: FunctionType.LAPACKE_dgelq2_work? = load(name: "LAPACKE_dgelq2_work", as: FunctionType.LAPACKE_dgelq2_work.self)
    #elseif os(macOS)
    static let dgelq2_work: FunctionType.LAPACKE_dgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq2_work: FunctionType.LAPACKE_cgelq2_work? = load(name: "LAPACKE_cgelq2_work", as: FunctionType.LAPACKE_cgelq2_work.self)
    #elseif os(macOS)
    static let cgelq2_work: FunctionType.LAPACKE_cgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq2_work: FunctionType.LAPACKE_zgelq2_work? = load(name: "LAPACKE_zgelq2_work", as: FunctionType.LAPACKE_zgelq2_work.self)
    #elseif os(macOS)
    static let zgelq2_work: FunctionType.LAPACKE_zgelq2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelqf_work: FunctionType.LAPACKE_sgelqf_work? = load(name: "LAPACKE_sgelqf_work", as: FunctionType.LAPACKE_sgelqf_work.self)
    #elseif os(macOS)
    static let sgelqf_work: FunctionType.LAPACKE_sgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelqf_work: FunctionType.LAPACKE_dgelqf_work? = load(name: "LAPACKE_dgelqf_work", as: FunctionType.LAPACKE_dgelqf_work.self)
    #elseif os(macOS)
    static let dgelqf_work: FunctionType.LAPACKE_dgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelqf_work: FunctionType.LAPACKE_cgelqf_work? = load(name: "LAPACKE_cgelqf_work", as: FunctionType.LAPACKE_cgelqf_work.self)
    #elseif os(macOS)
    static let cgelqf_work: FunctionType.LAPACKE_cgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelqf_work: FunctionType.LAPACKE_zgelqf_work? = load(name: "LAPACKE_zgelqf_work", as: FunctionType.LAPACKE_zgelqf_work.self)
    #elseif os(macOS)
    static let zgelqf_work: FunctionType.LAPACKE_zgelqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgels_work: FunctionType.LAPACKE_sgels_work? = load(name: "LAPACKE_sgels_work", as: FunctionType.LAPACKE_sgels_work.self)
    #elseif os(macOS)
    static let sgels_work: FunctionType.LAPACKE_sgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgels_work: FunctionType.LAPACKE_dgels_work? = load(name: "LAPACKE_dgels_work", as: FunctionType.LAPACKE_dgels_work.self)
    #elseif os(macOS)
    static let dgels_work: FunctionType.LAPACKE_dgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgels_work: FunctionType.LAPACKE_cgels_work? = load(name: "LAPACKE_cgels_work", as: FunctionType.LAPACKE_cgels_work.self)
    #elseif os(macOS)
    static let cgels_work: FunctionType.LAPACKE_cgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgels_work: FunctionType.LAPACKE_zgels_work? = load(name: "LAPACKE_zgels_work", as: FunctionType.LAPACKE_zgels_work.self)
    #elseif os(macOS)
    static let zgels_work: FunctionType.LAPACKE_zgels_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsd_work: FunctionType.LAPACKE_sgelsd_work? = load(name: "LAPACKE_sgelsd_work", as: FunctionType.LAPACKE_sgelsd_work.self)
    #elseif os(macOS)
    static let sgelsd_work: FunctionType.LAPACKE_sgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsd_work: FunctionType.LAPACKE_dgelsd_work? = load(name: "LAPACKE_dgelsd_work", as: FunctionType.LAPACKE_dgelsd_work.self)
    #elseif os(macOS)
    static let dgelsd_work: FunctionType.LAPACKE_dgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsd_work: FunctionType.LAPACKE_cgelsd_work? = load(name: "LAPACKE_cgelsd_work", as: FunctionType.LAPACKE_cgelsd_work.self)
    #elseif os(macOS)
    static let cgelsd_work: FunctionType.LAPACKE_cgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsd_work: FunctionType.LAPACKE_zgelsd_work? = load(name: "LAPACKE_zgelsd_work", as: FunctionType.LAPACKE_zgelsd_work.self)
    #elseif os(macOS)
    static let zgelsd_work: FunctionType.LAPACKE_zgelsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelss_work: FunctionType.LAPACKE_sgelss_work? = load(name: "LAPACKE_sgelss_work", as: FunctionType.LAPACKE_sgelss_work.self)
    #elseif os(macOS)
    static let sgelss_work: FunctionType.LAPACKE_sgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelss_work: FunctionType.LAPACKE_dgelss_work? = load(name: "LAPACKE_dgelss_work", as: FunctionType.LAPACKE_dgelss_work.self)
    #elseif os(macOS)
    static let dgelss_work: FunctionType.LAPACKE_dgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelss_work: FunctionType.LAPACKE_cgelss_work? = load(name: "LAPACKE_cgelss_work", as: FunctionType.LAPACKE_cgelss_work.self)
    #elseif os(macOS)
    static let cgelss_work: FunctionType.LAPACKE_cgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelss_work: FunctionType.LAPACKE_zgelss_work? = load(name: "LAPACKE_zgelss_work", as: FunctionType.LAPACKE_zgelss_work.self)
    #elseif os(macOS)
    static let zgelss_work: FunctionType.LAPACKE_zgelss_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelsy_work: FunctionType.LAPACKE_sgelsy_work? = load(name: "LAPACKE_sgelsy_work", as: FunctionType.LAPACKE_sgelsy_work.self)
    #elseif os(macOS)
    static let sgelsy_work: FunctionType.LAPACKE_sgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelsy_work: FunctionType.LAPACKE_dgelsy_work? = load(name: "LAPACKE_dgelsy_work", as: FunctionType.LAPACKE_dgelsy_work.self)
    #elseif os(macOS)
    static let dgelsy_work: FunctionType.LAPACKE_dgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelsy_work: FunctionType.LAPACKE_cgelsy_work? = load(name: "LAPACKE_cgelsy_work", as: FunctionType.LAPACKE_cgelsy_work.self)
    #elseif os(macOS)
    static let cgelsy_work: FunctionType.LAPACKE_cgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelsy_work: FunctionType.LAPACKE_zgelsy_work? = load(name: "LAPACKE_zgelsy_work", as: FunctionType.LAPACKE_zgelsy_work.self)
    #elseif os(macOS)
    static let zgelsy_work: FunctionType.LAPACKE_zgelsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqlf_work: FunctionType.LAPACKE_sgeqlf_work? = load(name: "LAPACKE_sgeqlf_work", as: FunctionType.LAPACKE_sgeqlf_work.self)
    #elseif os(macOS)
    static let sgeqlf_work: FunctionType.LAPACKE_sgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqlf_work: FunctionType.LAPACKE_dgeqlf_work? = load(name: "LAPACKE_dgeqlf_work", as: FunctionType.LAPACKE_dgeqlf_work.self)
    #elseif os(macOS)
    static let dgeqlf_work: FunctionType.LAPACKE_dgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqlf_work: FunctionType.LAPACKE_cgeqlf_work? = load(name: "LAPACKE_cgeqlf_work", as: FunctionType.LAPACKE_cgeqlf_work.self)
    #elseif os(macOS)
    static let cgeqlf_work: FunctionType.LAPACKE_cgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqlf_work: FunctionType.LAPACKE_zgeqlf_work? = load(name: "LAPACKE_zgeqlf_work", as: FunctionType.LAPACKE_zgeqlf_work.self)
    #elseif os(macOS)
    static let zgeqlf_work: FunctionType.LAPACKE_zgeqlf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqp3_work: FunctionType.LAPACKE_sgeqp3_work? = load(name: "LAPACKE_sgeqp3_work", as: FunctionType.LAPACKE_sgeqp3_work.self)
    #elseif os(macOS)
    static let sgeqp3_work: FunctionType.LAPACKE_sgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqp3_work: FunctionType.LAPACKE_dgeqp3_work? = load(name: "LAPACKE_dgeqp3_work", as: FunctionType.LAPACKE_dgeqp3_work.self)
    #elseif os(macOS)
    static let dgeqp3_work: FunctionType.LAPACKE_dgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqp3_work: FunctionType.LAPACKE_cgeqp3_work? = load(name: "LAPACKE_cgeqp3_work", as: FunctionType.LAPACKE_cgeqp3_work.self)
    #elseif os(macOS)
    static let cgeqp3_work: FunctionType.LAPACKE_cgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqp3_work: FunctionType.LAPACKE_zgeqp3_work? = load(name: "LAPACKE_zgeqp3_work", as: FunctionType.LAPACKE_zgeqp3_work.self)
    #elseif os(macOS)
    static let zgeqp3_work: FunctionType.LAPACKE_zgeqp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqpf_work: FunctionType.LAPACKE_sgeqpf_work? = load(name: "LAPACKE_sgeqpf_work", as: FunctionType.LAPACKE_sgeqpf_work.self)
    #elseif os(macOS)
    static let sgeqpf_work: FunctionType.LAPACKE_sgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqpf_work: FunctionType.LAPACKE_dgeqpf_work? = load(name: "LAPACKE_dgeqpf_work", as: FunctionType.LAPACKE_dgeqpf_work.self)
    #elseif os(macOS)
    static let dgeqpf_work: FunctionType.LAPACKE_dgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqpf_work: FunctionType.LAPACKE_cgeqpf_work? = load(name: "LAPACKE_cgeqpf_work", as: FunctionType.LAPACKE_cgeqpf_work.self)
    #elseif os(macOS)
    static let cgeqpf_work: FunctionType.LAPACKE_cgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqpf_work: FunctionType.LAPACKE_zgeqpf_work? = load(name: "LAPACKE_zgeqpf_work", as: FunctionType.LAPACKE_zgeqpf_work.self)
    #elseif os(macOS)
    static let zgeqpf_work: FunctionType.LAPACKE_zgeqpf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr2_work: FunctionType.LAPACKE_sgeqr2_work? = load(name: "LAPACKE_sgeqr2_work", as: FunctionType.LAPACKE_sgeqr2_work.self)
    #elseif os(macOS)
    static let sgeqr2_work: FunctionType.LAPACKE_sgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr2_work: FunctionType.LAPACKE_dgeqr2_work? = load(name: "LAPACKE_dgeqr2_work", as: FunctionType.LAPACKE_dgeqr2_work.self)
    #elseif os(macOS)
    static let dgeqr2_work: FunctionType.LAPACKE_dgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr2_work: FunctionType.LAPACKE_cgeqr2_work? = load(name: "LAPACKE_cgeqr2_work", as: FunctionType.LAPACKE_cgeqr2_work.self)
    #elseif os(macOS)
    static let cgeqr2_work: FunctionType.LAPACKE_cgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr2_work: FunctionType.LAPACKE_zgeqr2_work? = load(name: "LAPACKE_zgeqr2_work", as: FunctionType.LAPACKE_zgeqr2_work.self)
    #elseif os(macOS)
    static let zgeqr2_work: FunctionType.LAPACKE_zgeqr2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrf_work: FunctionType.LAPACKE_sgeqrf_work? = load(name: "LAPACKE_sgeqrf_work", as: FunctionType.LAPACKE_sgeqrf_work.self)
    #elseif os(macOS)
    static let sgeqrf_work: FunctionType.LAPACKE_sgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrf_work: FunctionType.LAPACKE_dgeqrf_work? = load(name: "LAPACKE_dgeqrf_work", as: FunctionType.LAPACKE_dgeqrf_work.self)
    #elseif os(macOS)
    static let dgeqrf_work: FunctionType.LAPACKE_dgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrf_work: FunctionType.LAPACKE_cgeqrf_work? = load(name: "LAPACKE_cgeqrf_work", as: FunctionType.LAPACKE_cgeqrf_work.self)
    #elseif os(macOS)
    static let cgeqrf_work: FunctionType.LAPACKE_cgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrf_work: FunctionType.LAPACKE_zgeqrf_work? = load(name: "LAPACKE_zgeqrf_work", as: FunctionType.LAPACKE_zgeqrf_work.self)
    #elseif os(macOS)
    static let zgeqrf_work: FunctionType.LAPACKE_zgeqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrfp_work: FunctionType.LAPACKE_sgeqrfp_work? = load(name: "LAPACKE_sgeqrfp_work", as: FunctionType.LAPACKE_sgeqrfp_work.self)
    #elseif os(macOS)
    static let sgeqrfp_work: FunctionType.LAPACKE_sgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrfp_work: FunctionType.LAPACKE_dgeqrfp_work? = load(name: "LAPACKE_dgeqrfp_work", as: FunctionType.LAPACKE_dgeqrfp_work.self)
    #elseif os(macOS)
    static let dgeqrfp_work: FunctionType.LAPACKE_dgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrfp_work: FunctionType.LAPACKE_cgeqrfp_work? = load(name: "LAPACKE_cgeqrfp_work", as: FunctionType.LAPACKE_cgeqrfp_work.self)
    #elseif os(macOS)
    static let cgeqrfp_work: FunctionType.LAPACKE_cgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrfp_work: FunctionType.LAPACKE_zgeqrfp_work? = load(name: "LAPACKE_zgeqrfp_work", as: FunctionType.LAPACKE_zgeqrfp_work.self)
    #elseif os(macOS)
    static let zgeqrfp_work: FunctionType.LAPACKE_zgeqrfp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfs_work: FunctionType.LAPACKE_sgerfs_work? = load(name: "LAPACKE_sgerfs_work", as: FunctionType.LAPACKE_sgerfs_work.self)
    #elseif os(macOS)
    static let sgerfs_work: FunctionType.LAPACKE_sgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfs_work: FunctionType.LAPACKE_dgerfs_work? = load(name: "LAPACKE_dgerfs_work", as: FunctionType.LAPACKE_dgerfs_work.self)
    #elseif os(macOS)
    static let dgerfs_work: FunctionType.LAPACKE_dgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfs_work: FunctionType.LAPACKE_cgerfs_work? = load(name: "LAPACKE_cgerfs_work", as: FunctionType.LAPACKE_cgerfs_work.self)
    #elseif os(macOS)
    static let cgerfs_work: FunctionType.LAPACKE_cgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfs_work: FunctionType.LAPACKE_zgerfs_work? = load(name: "LAPACKE_zgerfs_work", as: FunctionType.LAPACKE_zgerfs_work.self)
    #elseif os(macOS)
    static let zgerfs_work: FunctionType.LAPACKE_zgerfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerfsx_work: FunctionType.LAPACKE_sgerfsx_work? = load(name: "LAPACKE_sgerfsx_work", as: FunctionType.LAPACKE_sgerfsx_work.self)
    #elseif os(macOS)
    static let sgerfsx_work: FunctionType.LAPACKE_sgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerfsx_work: FunctionType.LAPACKE_dgerfsx_work? = load(name: "LAPACKE_dgerfsx_work", as: FunctionType.LAPACKE_dgerfsx_work.self)
    #elseif os(macOS)
    static let dgerfsx_work: FunctionType.LAPACKE_dgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerfsx_work: FunctionType.LAPACKE_cgerfsx_work? = load(name: "LAPACKE_cgerfsx_work", as: FunctionType.LAPACKE_cgerfsx_work.self)
    #elseif os(macOS)
    static let cgerfsx_work: FunctionType.LAPACKE_cgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerfsx_work: FunctionType.LAPACKE_zgerfsx_work? = load(name: "LAPACKE_zgerfsx_work", as: FunctionType.LAPACKE_zgerfsx_work.self)
    #elseif os(macOS)
    static let zgerfsx_work: FunctionType.LAPACKE_zgerfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgerqf_work: FunctionType.LAPACKE_sgerqf_work? = load(name: "LAPACKE_sgerqf_work", as: FunctionType.LAPACKE_sgerqf_work.self)
    #elseif os(macOS)
    static let sgerqf_work: FunctionType.LAPACKE_sgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgerqf_work: FunctionType.LAPACKE_dgerqf_work? = load(name: "LAPACKE_dgerqf_work", as: FunctionType.LAPACKE_dgerqf_work.self)
    #elseif os(macOS)
    static let dgerqf_work: FunctionType.LAPACKE_dgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgerqf_work: FunctionType.LAPACKE_cgerqf_work? = load(name: "LAPACKE_cgerqf_work", as: FunctionType.LAPACKE_cgerqf_work.self)
    #elseif os(macOS)
    static let cgerqf_work: FunctionType.LAPACKE_cgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgerqf_work: FunctionType.LAPACKE_zgerqf_work? = load(name: "LAPACKE_zgerqf_work", as: FunctionType.LAPACKE_zgerqf_work.self)
    #elseif os(macOS)
    static let zgerqf_work: FunctionType.LAPACKE_zgerqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesdd_work: FunctionType.LAPACKE_sgesdd_work? = load(name: "LAPACKE_sgesdd_work", as: FunctionType.LAPACKE_sgesdd_work.self)
    #elseif os(macOS)
    static let sgesdd_work: FunctionType.LAPACKE_sgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesdd_work: FunctionType.LAPACKE_dgesdd_work? = load(name: "LAPACKE_dgesdd_work", as: FunctionType.LAPACKE_dgesdd_work.self)
    #elseif os(macOS)
    static let dgesdd_work: FunctionType.LAPACKE_dgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesdd_work: FunctionType.LAPACKE_cgesdd_work? = load(name: "LAPACKE_cgesdd_work", as: FunctionType.LAPACKE_cgesdd_work.self)
    #elseif os(macOS)
    static let cgesdd_work: FunctionType.LAPACKE_cgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesdd_work: FunctionType.LAPACKE_zgesdd_work? = load(name: "LAPACKE_zgesdd_work", as: FunctionType.LAPACKE_zgesdd_work.self)
    #elseif os(macOS)
    static let zgesdd_work: FunctionType.LAPACKE_zgesdd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgedmd_work: FunctionType.LAPACKE_sgedmd_work? = load(name: "LAPACKE_sgedmd_work", as: FunctionType.LAPACKE_sgedmd_work.self)
    #elseif os(macOS)
    static let sgedmd_work: FunctionType.LAPACKE_sgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgedmd_work: FunctionType.LAPACKE_dgedmd_work? = load(name: "LAPACKE_dgedmd_work", as: FunctionType.LAPACKE_dgedmd_work.self)
    #elseif os(macOS)
    static let dgedmd_work: FunctionType.LAPACKE_dgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgedmd_work: FunctionType.LAPACKE_cgedmd_work? = load(name: "LAPACKE_cgedmd_work", as: FunctionType.LAPACKE_cgedmd_work.self)
    #elseif os(macOS)
    static let cgedmd_work: FunctionType.LAPACKE_cgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgedmd_work: FunctionType.LAPACKE_zgedmd_work? = load(name: "LAPACKE_zgedmd_work", as: FunctionType.LAPACKE_zgedmd_work.self)
    #elseif os(macOS)
    static let zgedmd_work: FunctionType.LAPACKE_zgedmd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgedmdq_work: FunctionType.LAPACKE_sgedmdq_work? = load(name: "LAPACKE_sgedmdq_work", as: FunctionType.LAPACKE_sgedmdq_work.self)
    #elseif os(macOS)
    static let sgedmdq_work: FunctionType.LAPACKE_sgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgedmdq_work: FunctionType.LAPACKE_dgedmdq_work? = load(name: "LAPACKE_dgedmdq_work", as: FunctionType.LAPACKE_dgedmdq_work.self)
    #elseif os(macOS)
    static let dgedmdq_work: FunctionType.LAPACKE_dgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgedmdq_work: FunctionType.LAPACKE_cgedmdq_work? = load(name: "LAPACKE_cgedmdq_work", as: FunctionType.LAPACKE_cgedmdq_work.self)
    #elseif os(macOS)
    static let cgedmdq_work: FunctionType.LAPACKE_cgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgedmdq_work: FunctionType.LAPACKE_zgedmdq_work? = load(name: "LAPACKE_zgedmdq_work", as: FunctionType.LAPACKE_zgedmdq_work.self)
    #elseif os(macOS)
    static let zgedmdq_work: FunctionType.LAPACKE_zgedmdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesv_work: FunctionType.LAPACKE_sgesv_work? = load(name: "LAPACKE_sgesv_work", as: FunctionType.LAPACKE_sgesv_work.self)
    #elseif os(macOS)
    static let sgesv_work: FunctionType.LAPACKE_sgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesv_work: FunctionType.LAPACKE_dgesv_work? = load(name: "LAPACKE_dgesv_work", as: FunctionType.LAPACKE_dgesv_work.self)
    #elseif os(macOS)
    static let dgesv_work: FunctionType.LAPACKE_dgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesv_work: FunctionType.LAPACKE_cgesv_work? = load(name: "LAPACKE_cgesv_work", as: FunctionType.LAPACKE_cgesv_work.self)
    #elseif os(macOS)
    static let cgesv_work: FunctionType.LAPACKE_cgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesv_work: FunctionType.LAPACKE_zgesv_work? = load(name: "LAPACKE_zgesv_work", as: FunctionType.LAPACKE_zgesv_work.self)
    #elseif os(macOS)
    static let zgesv_work: FunctionType.LAPACKE_zgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsgesv_work: FunctionType.LAPACKE_dsgesv_work? = load(name: "LAPACKE_dsgesv_work", as: FunctionType.LAPACKE_dsgesv_work.self)
    #elseif os(macOS)
    static let dsgesv_work: FunctionType.LAPACKE_dsgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcgesv_work: FunctionType.LAPACKE_zcgesv_work? = load(name: "LAPACKE_zcgesv_work", as: FunctionType.LAPACKE_zcgesv_work.self)
    #elseif os(macOS)
    static let zcgesv_work: FunctionType.LAPACKE_zcgesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvd_work: FunctionType.LAPACKE_sgesvd_work? = load(name: "LAPACKE_sgesvd_work", as: FunctionType.LAPACKE_sgesvd_work.self)
    #elseif os(macOS)
    static let sgesvd_work: FunctionType.LAPACKE_sgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvd_work: FunctionType.LAPACKE_dgesvd_work? = load(name: "LAPACKE_dgesvd_work", as: FunctionType.LAPACKE_dgesvd_work.self)
    #elseif os(macOS)
    static let dgesvd_work: FunctionType.LAPACKE_dgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvd_work: FunctionType.LAPACKE_cgesvd_work? = load(name: "LAPACKE_cgesvd_work", as: FunctionType.LAPACKE_cgesvd_work.self)
    #elseif os(macOS)
    static let cgesvd_work: FunctionType.LAPACKE_cgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvd_work: FunctionType.LAPACKE_zgesvd_work? = load(name: "LAPACKE_zgesvd_work", as: FunctionType.LAPACKE_zgesvd_work.self)
    #elseif os(macOS)
    static let zgesvd_work: FunctionType.LAPACKE_zgesvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdx_work: FunctionType.LAPACKE_sgesvdx_work? = load(name: "LAPACKE_sgesvdx_work", as: FunctionType.LAPACKE_sgesvdx_work.self)
    #elseif os(macOS)
    static let sgesvdx_work: FunctionType.LAPACKE_sgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdx_work: FunctionType.LAPACKE_dgesvdx_work? = load(name: "LAPACKE_dgesvdx_work", as: FunctionType.LAPACKE_dgesvdx_work.self)
    #elseif os(macOS)
    static let dgesvdx_work: FunctionType.LAPACKE_dgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdx_work: FunctionType.LAPACKE_cgesvdx_work? = load(name: "LAPACKE_cgesvdx_work", as: FunctionType.LAPACKE_cgesvdx_work.self)
    #elseif os(macOS)
    static let cgesvdx_work: FunctionType.LAPACKE_cgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdx_work: FunctionType.LAPACKE_zgesvdx_work? = load(name: "LAPACKE_zgesvdx_work", as: FunctionType.LAPACKE_zgesvdx_work.self)
    #elseif os(macOS)
    static let zgesvdx_work: FunctionType.LAPACKE_zgesvdx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvdq_work: FunctionType.LAPACKE_sgesvdq_work? = load(name: "LAPACKE_sgesvdq_work", as: FunctionType.LAPACKE_sgesvdq_work.self)
    #elseif os(macOS)
    static let sgesvdq_work: FunctionType.LAPACKE_sgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvdq_work: FunctionType.LAPACKE_dgesvdq_work? = load(name: "LAPACKE_dgesvdq_work", as: FunctionType.LAPACKE_dgesvdq_work.self)
    #elseif os(macOS)
    static let dgesvdq_work: FunctionType.LAPACKE_dgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvdq_work: FunctionType.LAPACKE_cgesvdq_work? = load(name: "LAPACKE_cgesvdq_work", as: FunctionType.LAPACKE_cgesvdq_work.self)
    #elseif os(macOS)
    static let cgesvdq_work: FunctionType.LAPACKE_cgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvdq_work: FunctionType.LAPACKE_zgesvdq_work? = load(name: "LAPACKE_zgesvdq_work", as: FunctionType.LAPACKE_zgesvdq_work.self)
    #elseif os(macOS)
    static let zgesvdq_work: FunctionType.LAPACKE_zgesvdq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvj_work: FunctionType.LAPACKE_sgesvj_work? = load(name: "LAPACKE_sgesvj_work", as: FunctionType.LAPACKE_sgesvj_work.self)
    #elseif os(macOS)
    static let sgesvj_work: FunctionType.LAPACKE_sgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvj_work: FunctionType.LAPACKE_dgesvj_work? = load(name: "LAPACKE_dgesvj_work", as: FunctionType.LAPACKE_dgesvj_work.self)
    #elseif os(macOS)
    static let dgesvj_work: FunctionType.LAPACKE_dgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvj_work: FunctionType.LAPACKE_cgesvj_work? = load(name: "LAPACKE_cgesvj_work", as: FunctionType.LAPACKE_cgesvj_work.self)
    #elseif os(macOS)
    static let cgesvj_work: FunctionType.LAPACKE_cgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvj_work: FunctionType.LAPACKE_zgesvj_work? = load(name: "LAPACKE_zgesvj_work", as: FunctionType.LAPACKE_zgesvj_work.self)
    #elseif os(macOS)
    static let zgesvj_work: FunctionType.LAPACKE_zgesvj_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvx_work: FunctionType.LAPACKE_sgesvx_work? = load(name: "LAPACKE_sgesvx_work", as: FunctionType.LAPACKE_sgesvx_work.self)
    #elseif os(macOS)
    static let sgesvx_work: FunctionType.LAPACKE_sgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvx_work: FunctionType.LAPACKE_dgesvx_work? = load(name: "LAPACKE_dgesvx_work", as: FunctionType.LAPACKE_dgesvx_work.self)
    #elseif os(macOS)
    static let dgesvx_work: FunctionType.LAPACKE_dgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvx_work: FunctionType.LAPACKE_cgesvx_work? = load(name: "LAPACKE_cgesvx_work", as: FunctionType.LAPACKE_cgesvx_work.self)
    #elseif os(macOS)
    static let cgesvx_work: FunctionType.LAPACKE_cgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvx_work: FunctionType.LAPACKE_zgesvx_work? = load(name: "LAPACKE_zgesvx_work", as: FunctionType.LAPACKE_zgesvx_work.self)
    #elseif os(macOS)
    static let zgesvx_work: FunctionType.LAPACKE_zgesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgesvxx_work: FunctionType.LAPACKE_sgesvxx_work? = load(name: "LAPACKE_sgesvxx_work", as: FunctionType.LAPACKE_sgesvxx_work.self)
    #elseif os(macOS)
    static let sgesvxx_work: FunctionType.LAPACKE_sgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgesvxx_work: FunctionType.LAPACKE_dgesvxx_work? = load(name: "LAPACKE_dgesvxx_work", as: FunctionType.LAPACKE_dgesvxx_work.self)
    #elseif os(macOS)
    static let dgesvxx_work: FunctionType.LAPACKE_dgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgesvxx_work: FunctionType.LAPACKE_cgesvxx_work? = load(name: "LAPACKE_cgesvxx_work", as: FunctionType.LAPACKE_cgesvxx_work.self)
    #elseif os(macOS)
    static let cgesvxx_work: FunctionType.LAPACKE_cgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgesvxx_work: FunctionType.LAPACKE_zgesvxx_work? = load(name: "LAPACKE_zgesvxx_work", as: FunctionType.LAPACKE_zgesvxx_work.self)
    #elseif os(macOS)
    static let zgesvxx_work: FunctionType.LAPACKE_zgesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetf2_work: FunctionType.LAPACKE_sgetf2_work? = load(name: "LAPACKE_sgetf2_work", as: FunctionType.LAPACKE_sgetf2_work.self)
    #elseif os(macOS)
    static let sgetf2_work: FunctionType.LAPACKE_sgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetf2_work: FunctionType.LAPACKE_dgetf2_work? = load(name: "LAPACKE_dgetf2_work", as: FunctionType.LAPACKE_dgetf2_work.self)
    #elseif os(macOS)
    static let dgetf2_work: FunctionType.LAPACKE_dgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetf2_work: FunctionType.LAPACKE_cgetf2_work? = load(name: "LAPACKE_cgetf2_work", as: FunctionType.LAPACKE_cgetf2_work.self)
    #elseif os(macOS)
    static let cgetf2_work: FunctionType.LAPACKE_cgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetf2_work: FunctionType.LAPACKE_zgetf2_work? = load(name: "LAPACKE_zgetf2_work", as: FunctionType.LAPACKE_zgetf2_work.self)
    #elseif os(macOS)
    static let zgetf2_work: FunctionType.LAPACKE_zgetf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf_work: FunctionType.LAPACKE_sgetrf_work? = load(name: "LAPACKE_sgetrf_work", as: FunctionType.LAPACKE_sgetrf_work.self)
    #elseif os(macOS)
    static let sgetrf_work: FunctionType.LAPACKE_sgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf_work: FunctionType.LAPACKE_dgetrf_work? = load(name: "LAPACKE_dgetrf_work", as: FunctionType.LAPACKE_dgetrf_work.self)
    #elseif os(macOS)
    static let dgetrf_work: FunctionType.LAPACKE_dgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf_work: FunctionType.LAPACKE_cgetrf_work? = load(name: "LAPACKE_cgetrf_work", as: FunctionType.LAPACKE_cgetrf_work.self)
    #elseif os(macOS)
    static let cgetrf_work: FunctionType.LAPACKE_cgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf_work: FunctionType.LAPACKE_zgetrf_work? = load(name: "LAPACKE_zgetrf_work", as: FunctionType.LAPACKE_zgetrf_work.self)
    #elseif os(macOS)
    static let zgetrf_work: FunctionType.LAPACKE_zgetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrf2_work: FunctionType.LAPACKE_sgetrf2_work? = load(name: "LAPACKE_sgetrf2_work", as: FunctionType.LAPACKE_sgetrf2_work.self)
    #elseif os(macOS)
    static let sgetrf2_work: FunctionType.LAPACKE_sgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrf2_work: FunctionType.LAPACKE_dgetrf2_work? = load(name: "LAPACKE_dgetrf2_work", as: FunctionType.LAPACKE_dgetrf2_work.self)
    #elseif os(macOS)
    static let dgetrf2_work: FunctionType.LAPACKE_dgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrf2_work: FunctionType.LAPACKE_cgetrf2_work? = load(name: "LAPACKE_cgetrf2_work", as: FunctionType.LAPACKE_cgetrf2_work.self)
    #elseif os(macOS)
    static let cgetrf2_work: FunctionType.LAPACKE_cgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrf2_work: FunctionType.LAPACKE_zgetrf2_work? = load(name: "LAPACKE_zgetrf2_work", as: FunctionType.LAPACKE_zgetrf2_work.self)
    #elseif os(macOS)
    static let zgetrf2_work: FunctionType.LAPACKE_zgetrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetri_work: FunctionType.LAPACKE_sgetri_work? = load(name: "LAPACKE_sgetri_work", as: FunctionType.LAPACKE_sgetri_work.self)
    #elseif os(macOS)
    static let sgetri_work: FunctionType.LAPACKE_sgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetri_work: FunctionType.LAPACKE_dgetri_work? = load(name: "LAPACKE_dgetri_work", as: FunctionType.LAPACKE_dgetri_work.self)
    #elseif os(macOS)
    static let dgetri_work: FunctionType.LAPACKE_dgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetri_work: FunctionType.LAPACKE_cgetri_work? = load(name: "LAPACKE_cgetri_work", as: FunctionType.LAPACKE_cgetri_work.self)
    #elseif os(macOS)
    static let cgetri_work: FunctionType.LAPACKE_cgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetri_work: FunctionType.LAPACKE_zgetri_work? = load(name: "LAPACKE_zgetri_work", as: FunctionType.LAPACKE_zgetri_work.self)
    #elseif os(macOS)
    static let zgetri_work: FunctionType.LAPACKE_zgetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetrs_work: FunctionType.LAPACKE_sgetrs_work? = load(name: "LAPACKE_sgetrs_work", as: FunctionType.LAPACKE_sgetrs_work.self)
    #elseif os(macOS)
    static let sgetrs_work: FunctionType.LAPACKE_sgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetrs_work: FunctionType.LAPACKE_dgetrs_work? = load(name: "LAPACKE_dgetrs_work", as: FunctionType.LAPACKE_dgetrs_work.self)
    #elseif os(macOS)
    static let dgetrs_work: FunctionType.LAPACKE_dgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetrs_work: FunctionType.LAPACKE_cgetrs_work? = load(name: "LAPACKE_cgetrs_work", as: FunctionType.LAPACKE_cgetrs_work.self)
    #elseif os(macOS)
    static let cgetrs_work: FunctionType.LAPACKE_cgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetrs_work: FunctionType.LAPACKE_zgetrs_work? = load(name: "LAPACKE_zgetrs_work", as: FunctionType.LAPACKE_zgetrs_work.self)
    #elseif os(macOS)
    static let zgetrs_work: FunctionType.LAPACKE_zgetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbak_work: FunctionType.LAPACKE_sggbak_work? = load(name: "LAPACKE_sggbak_work", as: FunctionType.LAPACKE_sggbak_work.self)
    #elseif os(macOS)
    static let sggbak_work: FunctionType.LAPACKE_sggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbak_work: FunctionType.LAPACKE_dggbak_work? = load(name: "LAPACKE_dggbak_work", as: FunctionType.LAPACKE_dggbak_work.self)
    #elseif os(macOS)
    static let dggbak_work: FunctionType.LAPACKE_dggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbak_work: FunctionType.LAPACKE_cggbak_work? = load(name: "LAPACKE_cggbak_work", as: FunctionType.LAPACKE_cggbak_work.self)
    #elseif os(macOS)
    static let cggbak_work: FunctionType.LAPACKE_cggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbak_work: FunctionType.LAPACKE_zggbak_work? = load(name: "LAPACKE_zggbak_work", as: FunctionType.LAPACKE_zggbak_work.self)
    #elseif os(macOS)
    static let zggbak_work: FunctionType.LAPACKE_zggbak_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggbal_work: FunctionType.LAPACKE_sggbal_work? = load(name: "LAPACKE_sggbal_work", as: FunctionType.LAPACKE_sggbal_work.self)
    #elseif os(macOS)
    static let sggbal_work: FunctionType.LAPACKE_sggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggbal_work: FunctionType.LAPACKE_dggbal_work? = load(name: "LAPACKE_dggbal_work", as: FunctionType.LAPACKE_dggbal_work.self)
    #elseif os(macOS)
    static let dggbal_work: FunctionType.LAPACKE_dggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggbal_work: FunctionType.LAPACKE_cggbal_work? = load(name: "LAPACKE_cggbal_work", as: FunctionType.LAPACKE_cggbal_work.self)
    #elseif os(macOS)
    static let cggbal_work: FunctionType.LAPACKE_cggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggbal_work: FunctionType.LAPACKE_zggbal_work? = load(name: "LAPACKE_zggbal_work", as: FunctionType.LAPACKE_zggbal_work.self)
    #elseif os(macOS)
    static let zggbal_work: FunctionType.LAPACKE_zggbal_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges_work: FunctionType.LAPACKE_sgges_work? = load(name: "LAPACKE_sgges_work", as: FunctionType.LAPACKE_sgges_work.self)
    #elseif os(macOS)
    static let sgges_work: FunctionType.LAPACKE_sgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges_work: FunctionType.LAPACKE_dgges_work? = load(name: "LAPACKE_dgges_work", as: FunctionType.LAPACKE_dgges_work.self)
    #elseif os(macOS)
    static let dgges_work: FunctionType.LAPACKE_dgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges_work: FunctionType.LAPACKE_cgges_work? = load(name: "LAPACKE_cgges_work", as: FunctionType.LAPACKE_cgges_work.self)
    #elseif os(macOS)
    static let cgges_work: FunctionType.LAPACKE_cgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges_work: FunctionType.LAPACKE_zgges_work? = load(name: "LAPACKE_zgges_work", as: FunctionType.LAPACKE_zgges_work.self)
    #elseif os(macOS)
    static let zgges_work: FunctionType.LAPACKE_zgges_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgges3_work: FunctionType.LAPACKE_sgges3_work? = load(name: "LAPACKE_sgges3_work", as: FunctionType.LAPACKE_sgges3_work.self)
    #elseif os(macOS)
    static let sgges3_work: FunctionType.LAPACKE_sgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgges3_work: FunctionType.LAPACKE_dgges3_work? = load(name: "LAPACKE_dgges3_work", as: FunctionType.LAPACKE_dgges3_work.self)
    #elseif os(macOS)
    static let dgges3_work: FunctionType.LAPACKE_dgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgges3_work: FunctionType.LAPACKE_cgges3_work? = load(name: "LAPACKE_cgges3_work", as: FunctionType.LAPACKE_cgges3_work.self)
    #elseif os(macOS)
    static let cgges3_work: FunctionType.LAPACKE_cgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgges3_work: FunctionType.LAPACKE_zgges3_work? = load(name: "LAPACKE_zgges3_work", as: FunctionType.LAPACKE_zgges3_work.self)
    #elseif os(macOS)
    static let zgges3_work: FunctionType.LAPACKE_zgges3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggesx_work: FunctionType.LAPACKE_sggesx_work? = load(name: "LAPACKE_sggesx_work", as: FunctionType.LAPACKE_sggesx_work.self)
    #elseif os(macOS)
    static let sggesx_work: FunctionType.LAPACKE_sggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggesx_work: FunctionType.LAPACKE_dggesx_work? = load(name: "LAPACKE_dggesx_work", as: FunctionType.LAPACKE_dggesx_work.self)
    #elseif os(macOS)
    static let dggesx_work: FunctionType.LAPACKE_dggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggesx_work: FunctionType.LAPACKE_cggesx_work? = load(name: "LAPACKE_cggesx_work", as: FunctionType.LAPACKE_cggesx_work.self)
    #elseif os(macOS)
    static let cggesx_work: FunctionType.LAPACKE_cggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggesx_work: FunctionType.LAPACKE_zggesx_work? = load(name: "LAPACKE_zggesx_work", as: FunctionType.LAPACKE_zggesx_work.self)
    #elseif os(macOS)
    static let zggesx_work: FunctionType.LAPACKE_zggesx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev_work: FunctionType.LAPACKE_sggev_work? = load(name: "LAPACKE_sggev_work", as: FunctionType.LAPACKE_sggev_work.self)
    #elseif os(macOS)
    static let sggev_work: FunctionType.LAPACKE_sggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev_work: FunctionType.LAPACKE_dggev_work? = load(name: "LAPACKE_dggev_work", as: FunctionType.LAPACKE_dggev_work.self)
    #elseif os(macOS)
    static let dggev_work: FunctionType.LAPACKE_dggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev_work: FunctionType.LAPACKE_cggev_work? = load(name: "LAPACKE_cggev_work", as: FunctionType.LAPACKE_cggev_work.self)
    #elseif os(macOS)
    static let cggev_work: FunctionType.LAPACKE_cggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev_work: FunctionType.LAPACKE_zggev_work? = load(name: "LAPACKE_zggev_work", as: FunctionType.LAPACKE_zggev_work.self)
    #elseif os(macOS)
    static let zggev_work: FunctionType.LAPACKE_zggev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggev3_work: FunctionType.LAPACKE_sggev3_work? = load(name: "LAPACKE_sggev3_work", as: FunctionType.LAPACKE_sggev3_work.self)
    #elseif os(macOS)
    static let sggev3_work: FunctionType.LAPACKE_sggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggev3_work: FunctionType.LAPACKE_dggev3_work? = load(name: "LAPACKE_dggev3_work", as: FunctionType.LAPACKE_dggev3_work.self)
    #elseif os(macOS)
    static let dggev3_work: FunctionType.LAPACKE_dggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggev3_work: FunctionType.LAPACKE_cggev3_work? = load(name: "LAPACKE_cggev3_work", as: FunctionType.LAPACKE_cggev3_work.self)
    #elseif os(macOS)
    static let cggev3_work: FunctionType.LAPACKE_cggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggev3_work: FunctionType.LAPACKE_zggev3_work? = load(name: "LAPACKE_zggev3_work", as: FunctionType.LAPACKE_zggev3_work.self)
    #elseif os(macOS)
    static let zggev3_work: FunctionType.LAPACKE_zggev3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggevx_work: FunctionType.LAPACKE_sggevx_work? = load(name: "LAPACKE_sggevx_work", as: FunctionType.LAPACKE_sggevx_work.self)
    #elseif os(macOS)
    static let sggevx_work: FunctionType.LAPACKE_sggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggevx_work: FunctionType.LAPACKE_dggevx_work? = load(name: "LAPACKE_dggevx_work", as: FunctionType.LAPACKE_dggevx_work.self)
    #elseif os(macOS)
    static let dggevx_work: FunctionType.LAPACKE_dggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggevx_work: FunctionType.LAPACKE_cggevx_work? = load(name: "LAPACKE_cggevx_work", as: FunctionType.LAPACKE_cggevx_work.self)
    #elseif os(macOS)
    static let cggevx_work: FunctionType.LAPACKE_cggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggevx_work: FunctionType.LAPACKE_zggevx_work? = load(name: "LAPACKE_zggevx_work", as: FunctionType.LAPACKE_zggevx_work.self)
    #elseif os(macOS)
    static let zggevx_work: FunctionType.LAPACKE_zggevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggglm_work: FunctionType.LAPACKE_sggglm_work? = load(name: "LAPACKE_sggglm_work", as: FunctionType.LAPACKE_sggglm_work.self)
    #elseif os(macOS)
    static let sggglm_work: FunctionType.LAPACKE_sggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggglm_work: FunctionType.LAPACKE_dggglm_work? = load(name: "LAPACKE_dggglm_work", as: FunctionType.LAPACKE_dggglm_work.self)
    #elseif os(macOS)
    static let dggglm_work: FunctionType.LAPACKE_dggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggglm_work: FunctionType.LAPACKE_cggglm_work? = load(name: "LAPACKE_cggglm_work", as: FunctionType.LAPACKE_cggglm_work.self)
    #elseif os(macOS)
    static let cggglm_work: FunctionType.LAPACKE_cggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggglm_work: FunctionType.LAPACKE_zggglm_work? = load(name: "LAPACKE_zggglm_work", as: FunctionType.LAPACKE_zggglm_work.self)
    #elseif os(macOS)
    static let zggglm_work: FunctionType.LAPACKE_zggglm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghrd_work: FunctionType.LAPACKE_sgghrd_work? = load(name: "LAPACKE_sgghrd_work", as: FunctionType.LAPACKE_sgghrd_work.self)
    #elseif os(macOS)
    static let sgghrd_work: FunctionType.LAPACKE_sgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghrd_work: FunctionType.LAPACKE_dgghrd_work? = load(name: "LAPACKE_dgghrd_work", as: FunctionType.LAPACKE_dgghrd_work.self)
    #elseif os(macOS)
    static let dgghrd_work: FunctionType.LAPACKE_dgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghrd_work: FunctionType.LAPACKE_cgghrd_work? = load(name: "LAPACKE_cgghrd_work", as: FunctionType.LAPACKE_cgghrd_work.self)
    #elseif os(macOS)
    static let cgghrd_work: FunctionType.LAPACKE_cgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghrd_work: FunctionType.LAPACKE_zgghrd_work? = load(name: "LAPACKE_zgghrd_work", as: FunctionType.LAPACKE_zgghrd_work.self)
    #elseif os(macOS)
    static let zgghrd_work: FunctionType.LAPACKE_zgghrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgghd3_work: FunctionType.LAPACKE_sgghd3_work? = load(name: "LAPACKE_sgghd3_work", as: FunctionType.LAPACKE_sgghd3_work.self)
    #elseif os(macOS)
    static let sgghd3_work: FunctionType.LAPACKE_sgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgghd3_work: FunctionType.LAPACKE_dgghd3_work? = load(name: "LAPACKE_dgghd3_work", as: FunctionType.LAPACKE_dgghd3_work.self)
    #elseif os(macOS)
    static let dgghd3_work: FunctionType.LAPACKE_dgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgghd3_work: FunctionType.LAPACKE_cgghd3_work? = load(name: "LAPACKE_cgghd3_work", as: FunctionType.LAPACKE_cgghd3_work.self)
    #elseif os(macOS)
    static let cgghd3_work: FunctionType.LAPACKE_cgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgghd3_work: FunctionType.LAPACKE_zgghd3_work? = load(name: "LAPACKE_zgghd3_work", as: FunctionType.LAPACKE_zgghd3_work.self)
    #elseif os(macOS)
    static let zgghd3_work: FunctionType.LAPACKE_zgghd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgglse_work: FunctionType.LAPACKE_sgglse_work? = load(name: "LAPACKE_sgglse_work", as: FunctionType.LAPACKE_sgglse_work.self)
    #elseif os(macOS)
    static let sgglse_work: FunctionType.LAPACKE_sgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgglse_work: FunctionType.LAPACKE_dgglse_work? = load(name: "LAPACKE_dgglse_work", as: FunctionType.LAPACKE_dgglse_work.self)
    #elseif os(macOS)
    static let dgglse_work: FunctionType.LAPACKE_dgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgglse_work: FunctionType.LAPACKE_cgglse_work? = load(name: "LAPACKE_cgglse_work", as: FunctionType.LAPACKE_cgglse_work.self)
    #elseif os(macOS)
    static let cgglse_work: FunctionType.LAPACKE_cgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgglse_work: FunctionType.LAPACKE_zgglse_work? = load(name: "LAPACKE_zgglse_work", as: FunctionType.LAPACKE_zgglse_work.self)
    #elseif os(macOS)
    static let zgglse_work: FunctionType.LAPACKE_zgglse_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggqrf_work: FunctionType.LAPACKE_sggqrf_work? = load(name: "LAPACKE_sggqrf_work", as: FunctionType.LAPACKE_sggqrf_work.self)
    #elseif os(macOS)
    static let sggqrf_work: FunctionType.LAPACKE_sggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggqrf_work: FunctionType.LAPACKE_dggqrf_work? = load(name: "LAPACKE_dggqrf_work", as: FunctionType.LAPACKE_dggqrf_work.self)
    #elseif os(macOS)
    static let dggqrf_work: FunctionType.LAPACKE_dggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggqrf_work: FunctionType.LAPACKE_cggqrf_work? = load(name: "LAPACKE_cggqrf_work", as: FunctionType.LAPACKE_cggqrf_work.self)
    #elseif os(macOS)
    static let cggqrf_work: FunctionType.LAPACKE_cggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggqrf_work: FunctionType.LAPACKE_zggqrf_work? = load(name: "LAPACKE_zggqrf_work", as: FunctionType.LAPACKE_zggqrf_work.self)
    #elseif os(macOS)
    static let zggqrf_work: FunctionType.LAPACKE_zggqrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggrqf_work: FunctionType.LAPACKE_sggrqf_work? = load(name: "LAPACKE_sggrqf_work", as: FunctionType.LAPACKE_sggrqf_work.self)
    #elseif os(macOS)
    static let sggrqf_work: FunctionType.LAPACKE_sggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggrqf_work: FunctionType.LAPACKE_dggrqf_work? = load(name: "LAPACKE_dggrqf_work", as: FunctionType.LAPACKE_dggrqf_work.self)
    #elseif os(macOS)
    static let dggrqf_work: FunctionType.LAPACKE_dggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggrqf_work: FunctionType.LAPACKE_cggrqf_work? = load(name: "LAPACKE_cggrqf_work", as: FunctionType.LAPACKE_cggrqf_work.self)
    #elseif os(macOS)
    static let cggrqf_work: FunctionType.LAPACKE_cggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggrqf_work: FunctionType.LAPACKE_zggrqf_work? = load(name: "LAPACKE_zggrqf_work", as: FunctionType.LAPACKE_zggrqf_work.self)
    #elseif os(macOS)
    static let zggrqf_work: FunctionType.LAPACKE_zggrqf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd_work: FunctionType.LAPACKE_sggsvd_work? = load(name: "LAPACKE_sggsvd_work", as: FunctionType.LAPACKE_sggsvd_work.self)
    #elseif os(macOS)
    static let sggsvd_work: FunctionType.LAPACKE_sggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd_work: FunctionType.LAPACKE_dggsvd_work? = load(name: "LAPACKE_dggsvd_work", as: FunctionType.LAPACKE_dggsvd_work.self)
    #elseif os(macOS)
    static let dggsvd_work: FunctionType.LAPACKE_dggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd_work: FunctionType.LAPACKE_cggsvd_work? = load(name: "LAPACKE_cggsvd_work", as: FunctionType.LAPACKE_cggsvd_work.self)
    #elseif os(macOS)
    static let cggsvd_work: FunctionType.LAPACKE_cggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd_work: FunctionType.LAPACKE_zggsvd_work? = load(name: "LAPACKE_zggsvd_work", as: FunctionType.LAPACKE_zggsvd_work.self)
    #elseif os(macOS)
    static let zggsvd_work: FunctionType.LAPACKE_zggsvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvd3_work: FunctionType.LAPACKE_sggsvd3_work? = load(name: "LAPACKE_sggsvd3_work", as: FunctionType.LAPACKE_sggsvd3_work.self)
    #elseif os(macOS)
    static let sggsvd3_work: FunctionType.LAPACKE_sggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvd3_work: FunctionType.LAPACKE_dggsvd3_work? = load(name: "LAPACKE_dggsvd3_work", as: FunctionType.LAPACKE_dggsvd3_work.self)
    #elseif os(macOS)
    static let dggsvd3_work: FunctionType.LAPACKE_dggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvd3_work: FunctionType.LAPACKE_cggsvd3_work? = load(name: "LAPACKE_cggsvd3_work", as: FunctionType.LAPACKE_cggsvd3_work.self)
    #elseif os(macOS)
    static let cggsvd3_work: FunctionType.LAPACKE_cggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvd3_work: FunctionType.LAPACKE_zggsvd3_work? = load(name: "LAPACKE_zggsvd3_work", as: FunctionType.LAPACKE_zggsvd3_work.self)
    #elseif os(macOS)
    static let zggsvd3_work: FunctionType.LAPACKE_zggsvd3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp_work: FunctionType.LAPACKE_sggsvp_work? = load(name: "LAPACKE_sggsvp_work", as: FunctionType.LAPACKE_sggsvp_work.self)
    #elseif os(macOS)
    static let sggsvp_work: FunctionType.LAPACKE_sggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp_work: FunctionType.LAPACKE_dggsvp_work? = load(name: "LAPACKE_dggsvp_work", as: FunctionType.LAPACKE_dggsvp_work.self)
    #elseif os(macOS)
    static let dggsvp_work: FunctionType.LAPACKE_dggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp_work: FunctionType.LAPACKE_cggsvp_work? = load(name: "LAPACKE_cggsvp_work", as: FunctionType.LAPACKE_cggsvp_work.self)
    #elseif os(macOS)
    static let cggsvp_work: FunctionType.LAPACKE_cggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp_work: FunctionType.LAPACKE_zggsvp_work? = load(name: "LAPACKE_zggsvp_work", as: FunctionType.LAPACKE_zggsvp_work.self)
    #elseif os(macOS)
    static let zggsvp_work: FunctionType.LAPACKE_zggsvp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sggsvp3_work: FunctionType.LAPACKE_sggsvp3_work? = load(name: "LAPACKE_sggsvp3_work", as: FunctionType.LAPACKE_sggsvp3_work.self)
    #elseif os(macOS)
    static let sggsvp3_work: FunctionType.LAPACKE_sggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dggsvp3_work: FunctionType.LAPACKE_dggsvp3_work? = load(name: "LAPACKE_dggsvp3_work", as: FunctionType.LAPACKE_dggsvp3_work.self)
    #elseif os(macOS)
    static let dggsvp3_work: FunctionType.LAPACKE_dggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cggsvp3_work: FunctionType.LAPACKE_cggsvp3_work? = load(name: "LAPACKE_cggsvp3_work", as: FunctionType.LAPACKE_cggsvp3_work.self)
    #elseif os(macOS)
    static let cggsvp3_work: FunctionType.LAPACKE_cggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zggsvp3_work: FunctionType.LAPACKE_zggsvp3_work? = load(name: "LAPACKE_zggsvp3_work", as: FunctionType.LAPACKE_zggsvp3_work.self)
    #elseif os(macOS)
    static let zggsvp3_work: FunctionType.LAPACKE_zggsvp3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtcon_work: FunctionType.LAPACKE_sgtcon_work? = load(name: "LAPACKE_sgtcon_work", as: FunctionType.LAPACKE_sgtcon_work.self)
    #elseif os(macOS)
    static let sgtcon_work: FunctionType.LAPACKE_sgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtcon_work: FunctionType.LAPACKE_dgtcon_work? = load(name: "LAPACKE_dgtcon_work", as: FunctionType.LAPACKE_dgtcon_work.self)
    #elseif os(macOS)
    static let dgtcon_work: FunctionType.LAPACKE_dgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtcon_work: FunctionType.LAPACKE_cgtcon_work? = load(name: "LAPACKE_cgtcon_work", as: FunctionType.LAPACKE_cgtcon_work.self)
    #elseif os(macOS)
    static let cgtcon_work: FunctionType.LAPACKE_cgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtcon_work: FunctionType.LAPACKE_zgtcon_work? = load(name: "LAPACKE_zgtcon_work", as: FunctionType.LAPACKE_zgtcon_work.self)
    #elseif os(macOS)
    static let zgtcon_work: FunctionType.LAPACKE_zgtcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtrfs_work: FunctionType.LAPACKE_sgtrfs_work? = load(name: "LAPACKE_sgtrfs_work", as: FunctionType.LAPACKE_sgtrfs_work.self)
    #elseif os(macOS)
    static let sgtrfs_work: FunctionType.LAPACKE_sgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtrfs_work: FunctionType.LAPACKE_dgtrfs_work? = load(name: "LAPACKE_dgtrfs_work", as: FunctionType.LAPACKE_dgtrfs_work.self)
    #elseif os(macOS)
    static let dgtrfs_work: FunctionType.LAPACKE_dgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtrfs_work: FunctionType.LAPACKE_cgtrfs_work? = load(name: "LAPACKE_cgtrfs_work", as: FunctionType.LAPACKE_cgtrfs_work.self)
    #elseif os(macOS)
    static let cgtrfs_work: FunctionType.LAPACKE_cgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtrfs_work: FunctionType.LAPACKE_zgtrfs_work? = load(name: "LAPACKE_zgtrfs_work", as: FunctionType.LAPACKE_zgtrfs_work.self)
    #elseif os(macOS)
    static let zgtrfs_work: FunctionType.LAPACKE_zgtrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsv_work: FunctionType.LAPACKE_sgtsv_work? = load(name: "LAPACKE_sgtsv_work", as: FunctionType.LAPACKE_sgtsv_work.self)
    #elseif os(macOS)
    static let sgtsv_work: FunctionType.LAPACKE_sgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsv_work: FunctionType.LAPACKE_dgtsv_work? = load(name: "LAPACKE_dgtsv_work", as: FunctionType.LAPACKE_dgtsv_work.self)
    #elseif os(macOS)
    static let dgtsv_work: FunctionType.LAPACKE_dgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsv_work: FunctionType.LAPACKE_cgtsv_work? = load(name: "LAPACKE_cgtsv_work", as: FunctionType.LAPACKE_cgtsv_work.self)
    #elseif os(macOS)
    static let cgtsv_work: FunctionType.LAPACKE_cgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsv_work: FunctionType.LAPACKE_zgtsv_work? = load(name: "LAPACKE_zgtsv_work", as: FunctionType.LAPACKE_zgtsv_work.self)
    #elseif os(macOS)
    static let zgtsv_work: FunctionType.LAPACKE_zgtsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgtsvx_work: FunctionType.LAPACKE_sgtsvx_work? = load(name: "LAPACKE_sgtsvx_work", as: FunctionType.LAPACKE_sgtsvx_work.self)
    #elseif os(macOS)
    static let sgtsvx_work: FunctionType.LAPACKE_sgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgtsvx_work: FunctionType.LAPACKE_dgtsvx_work? = load(name: "LAPACKE_dgtsvx_work", as: FunctionType.LAPACKE_dgtsvx_work.self)
    #elseif os(macOS)
    static let dgtsvx_work: FunctionType.LAPACKE_dgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgtsvx_work: FunctionType.LAPACKE_cgtsvx_work? = load(name: "LAPACKE_cgtsvx_work", as: FunctionType.LAPACKE_cgtsvx_work.self)
    #elseif os(macOS)
    static let cgtsvx_work: FunctionType.LAPACKE_cgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgtsvx_work: FunctionType.LAPACKE_zgtsvx_work? = load(name: "LAPACKE_zgtsvx_work", as: FunctionType.LAPACKE_zgtsvx_work.self)
    #elseif os(macOS)
    static let zgtsvx_work: FunctionType.LAPACKE_zgtsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrf_work: FunctionType.LAPACKE_sgttrf_work? = load(name: "LAPACKE_sgttrf_work", as: FunctionType.LAPACKE_sgttrf_work.self)
    #elseif os(macOS)
    static let sgttrf_work: FunctionType.LAPACKE_sgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrf_work: FunctionType.LAPACKE_dgttrf_work? = load(name: "LAPACKE_dgttrf_work", as: FunctionType.LAPACKE_dgttrf_work.self)
    #elseif os(macOS)
    static let dgttrf_work: FunctionType.LAPACKE_dgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrf_work: FunctionType.LAPACKE_cgttrf_work? = load(name: "LAPACKE_cgttrf_work", as: FunctionType.LAPACKE_cgttrf_work.self)
    #elseif os(macOS)
    static let cgttrf_work: FunctionType.LAPACKE_cgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrf_work: FunctionType.LAPACKE_zgttrf_work? = load(name: "LAPACKE_zgttrf_work", as: FunctionType.LAPACKE_zgttrf_work.self)
    #elseif os(macOS)
    static let zgttrf_work: FunctionType.LAPACKE_zgttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgttrs_work: FunctionType.LAPACKE_sgttrs_work? = load(name: "LAPACKE_sgttrs_work", as: FunctionType.LAPACKE_sgttrs_work.self)
    #elseif os(macOS)
    static let sgttrs_work: FunctionType.LAPACKE_sgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgttrs_work: FunctionType.LAPACKE_dgttrs_work? = load(name: "LAPACKE_dgttrs_work", as: FunctionType.LAPACKE_dgttrs_work.self)
    #elseif os(macOS)
    static let dgttrs_work: FunctionType.LAPACKE_dgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgttrs_work: FunctionType.LAPACKE_cgttrs_work? = load(name: "LAPACKE_cgttrs_work", as: FunctionType.LAPACKE_cgttrs_work.self)
    #elseif os(macOS)
    static let cgttrs_work: FunctionType.LAPACKE_cgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgttrs_work: FunctionType.LAPACKE_zgttrs_work? = load(name: "LAPACKE_zgttrs_work", as: FunctionType.LAPACKE_zgttrs_work.self)
    #elseif os(macOS)
    static let zgttrs_work: FunctionType.LAPACKE_zgttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev_work: FunctionType.LAPACKE_chbev_work? = load(name: "LAPACKE_chbev_work", as: FunctionType.LAPACKE_chbev_work.self)
    #elseif os(macOS)
    static let chbev_work: FunctionType.LAPACKE_chbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev_work: FunctionType.LAPACKE_zhbev_work? = load(name: "LAPACKE_zhbev_work", as: FunctionType.LAPACKE_zhbev_work.self)
    #elseif os(macOS)
    static let zhbev_work: FunctionType.LAPACKE_zhbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd_work: FunctionType.LAPACKE_chbevd_work? = load(name: "LAPACKE_chbevd_work", as: FunctionType.LAPACKE_chbevd_work.self)
    #elseif os(macOS)
    static let chbevd_work: FunctionType.LAPACKE_chbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd_work: FunctionType.LAPACKE_zhbevd_work? = load(name: "LAPACKE_zhbevd_work", as: FunctionType.LAPACKE_zhbevd_work.self)
    #elseif os(macOS)
    static let zhbevd_work: FunctionType.LAPACKE_zhbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx_work: FunctionType.LAPACKE_chbevx_work? = load(name: "LAPACKE_chbevx_work", as: FunctionType.LAPACKE_chbevx_work.self)
    #elseif os(macOS)
    static let chbevx_work: FunctionType.LAPACKE_chbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx_work: FunctionType.LAPACKE_zhbevx_work? = load(name: "LAPACKE_zhbevx_work", as: FunctionType.LAPACKE_zhbevx_work.self)
    #elseif os(macOS)
    static let zhbevx_work: FunctionType.LAPACKE_zhbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgst_work: FunctionType.LAPACKE_chbgst_work? = load(name: "LAPACKE_chbgst_work", as: FunctionType.LAPACKE_chbgst_work.self)
    #elseif os(macOS)
    static let chbgst_work: FunctionType.LAPACKE_chbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgst_work: FunctionType.LAPACKE_zhbgst_work? = load(name: "LAPACKE_zhbgst_work", as: FunctionType.LAPACKE_zhbgst_work.self)
    #elseif os(macOS)
    static let zhbgst_work: FunctionType.LAPACKE_zhbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgv_work: FunctionType.LAPACKE_chbgv_work? = load(name: "LAPACKE_chbgv_work", as: FunctionType.LAPACKE_chbgv_work.self)
    #elseif os(macOS)
    static let chbgv_work: FunctionType.LAPACKE_chbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgv_work: FunctionType.LAPACKE_zhbgv_work? = load(name: "LAPACKE_zhbgv_work", as: FunctionType.LAPACKE_zhbgv_work.self)
    #elseif os(macOS)
    static let zhbgv_work: FunctionType.LAPACKE_zhbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvd_work: FunctionType.LAPACKE_chbgvd_work? = load(name: "LAPACKE_chbgvd_work", as: FunctionType.LAPACKE_chbgvd_work.self)
    #elseif os(macOS)
    static let chbgvd_work: FunctionType.LAPACKE_chbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvd_work: FunctionType.LAPACKE_zhbgvd_work? = load(name: "LAPACKE_zhbgvd_work", as: FunctionType.LAPACKE_zhbgvd_work.self)
    #elseif os(macOS)
    static let zhbgvd_work: FunctionType.LAPACKE_zhbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbgvx_work: FunctionType.LAPACKE_chbgvx_work? = load(name: "LAPACKE_chbgvx_work", as: FunctionType.LAPACKE_chbgvx_work.self)
    #elseif os(macOS)
    static let chbgvx_work: FunctionType.LAPACKE_chbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbgvx_work: FunctionType.LAPACKE_zhbgvx_work? = load(name: "LAPACKE_zhbgvx_work", as: FunctionType.LAPACKE_zhbgvx_work.self)
    #elseif os(macOS)
    static let zhbgvx_work: FunctionType.LAPACKE_zhbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbtrd_work: FunctionType.LAPACKE_chbtrd_work? = load(name: "LAPACKE_chbtrd_work", as: FunctionType.LAPACKE_chbtrd_work.self)
    #elseif os(macOS)
    static let chbtrd_work: FunctionType.LAPACKE_chbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbtrd_work: FunctionType.LAPACKE_zhbtrd_work? = load(name: "LAPACKE_zhbtrd_work", as: FunctionType.LAPACKE_zhbtrd_work.self)
    #elseif os(macOS)
    static let zhbtrd_work: FunctionType.LAPACKE_zhbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon_work: FunctionType.LAPACKE_checon_work? = load(name: "LAPACKE_checon_work", as: FunctionType.LAPACKE_checon_work.self)
    #elseif os(macOS)
    static let checon_work: FunctionType.LAPACKE_checon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon_work: FunctionType.LAPACKE_zhecon_work? = load(name: "LAPACKE_zhecon_work", as: FunctionType.LAPACKE_zhecon_work.self)
    #elseif os(macOS)
    static let zhecon_work: FunctionType.LAPACKE_zhecon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheequb_work: FunctionType.LAPACKE_cheequb_work? = load(name: "LAPACKE_cheequb_work", as: FunctionType.LAPACKE_cheequb_work.self)
    #elseif os(macOS)
    static let cheequb_work: FunctionType.LAPACKE_cheequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheequb_work: FunctionType.LAPACKE_zheequb_work? = load(name: "LAPACKE_zheequb_work", as: FunctionType.LAPACKE_zheequb_work.self)
    #elseif os(macOS)
    static let zheequb_work: FunctionType.LAPACKE_zheequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev_work: FunctionType.LAPACKE_cheev_work? = load(name: "LAPACKE_cheev_work", as: FunctionType.LAPACKE_cheev_work.self)
    #elseif os(macOS)
    static let cheev_work: FunctionType.LAPACKE_cheev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev_work: FunctionType.LAPACKE_zheev_work? = load(name: "LAPACKE_zheev_work", as: FunctionType.LAPACKE_zheev_work.self)
    #elseif os(macOS)
    static let zheev_work: FunctionType.LAPACKE_zheev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd_work: FunctionType.LAPACKE_cheevd_work? = load(name: "LAPACKE_cheevd_work", as: FunctionType.LAPACKE_cheevd_work.self)
    #elseif os(macOS)
    static let cheevd_work: FunctionType.LAPACKE_cheevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd_work: FunctionType.LAPACKE_zheevd_work? = load(name: "LAPACKE_zheevd_work", as: FunctionType.LAPACKE_zheevd_work.self)
    #elseif os(macOS)
    static let zheevd_work: FunctionType.LAPACKE_zheevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr_work: FunctionType.LAPACKE_cheevr_work? = load(name: "LAPACKE_cheevr_work", as: FunctionType.LAPACKE_cheevr_work.self)
    #elseif os(macOS)
    static let cheevr_work: FunctionType.LAPACKE_cheevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr_work: FunctionType.LAPACKE_zheevr_work? = load(name: "LAPACKE_zheevr_work", as: FunctionType.LAPACKE_zheevr_work.self)
    #elseif os(macOS)
    static let zheevr_work: FunctionType.LAPACKE_zheevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx_work: FunctionType.LAPACKE_cheevx_work? = load(name: "LAPACKE_cheevx_work", as: FunctionType.LAPACKE_cheevx_work.self)
    #elseif os(macOS)
    static let cheevx_work: FunctionType.LAPACKE_cheevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx_work: FunctionType.LAPACKE_zheevx_work? = load(name: "LAPACKE_zheevx_work", as: FunctionType.LAPACKE_zheevx_work.self)
    #elseif os(macOS)
    static let zheevx_work: FunctionType.LAPACKE_zheevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegst_work: FunctionType.LAPACKE_chegst_work? = load(name: "LAPACKE_chegst_work", as: FunctionType.LAPACKE_chegst_work.self)
    #elseif os(macOS)
    static let chegst_work: FunctionType.LAPACKE_chegst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegst_work: FunctionType.LAPACKE_zhegst_work? = load(name: "LAPACKE_zhegst_work", as: FunctionType.LAPACKE_zhegst_work.self)
    #elseif os(macOS)
    static let zhegst_work: FunctionType.LAPACKE_zhegst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv_work: FunctionType.LAPACKE_chegv_work? = load(name: "LAPACKE_chegv_work", as: FunctionType.LAPACKE_chegv_work.self)
    #elseif os(macOS)
    static let chegv_work: FunctionType.LAPACKE_chegv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv_work: FunctionType.LAPACKE_zhegv_work? = load(name: "LAPACKE_zhegv_work", as: FunctionType.LAPACKE_zhegv_work.self)
    #elseif os(macOS)
    static let zhegv_work: FunctionType.LAPACKE_zhegv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvd_work: FunctionType.LAPACKE_chegvd_work? = load(name: "LAPACKE_chegvd_work", as: FunctionType.LAPACKE_chegvd_work.self)
    #elseif os(macOS)
    static let chegvd_work: FunctionType.LAPACKE_chegvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvd_work: FunctionType.LAPACKE_zhegvd_work? = load(name: "LAPACKE_zhegvd_work", as: FunctionType.LAPACKE_zhegvd_work.self)
    #elseif os(macOS)
    static let zhegvd_work: FunctionType.LAPACKE_zhegvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegvx_work: FunctionType.LAPACKE_chegvx_work? = load(name: "LAPACKE_chegvx_work", as: FunctionType.LAPACKE_chegvx_work.self)
    #elseif os(macOS)
    static let chegvx_work: FunctionType.LAPACKE_chegvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegvx_work: FunctionType.LAPACKE_zhegvx_work? = load(name: "LAPACKE_zhegvx_work", as: FunctionType.LAPACKE_zhegvx_work.self)
    #elseif os(macOS)
    static let zhegvx_work: FunctionType.LAPACKE_zhegvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfs_work: FunctionType.LAPACKE_cherfs_work? = load(name: "LAPACKE_cherfs_work", as: FunctionType.LAPACKE_cherfs_work.self)
    #elseif os(macOS)
    static let cherfs_work: FunctionType.LAPACKE_cherfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfs_work: FunctionType.LAPACKE_zherfs_work? = load(name: "LAPACKE_zherfs_work", as: FunctionType.LAPACKE_zherfs_work.self)
    #elseif os(macOS)
    static let zherfs_work: FunctionType.LAPACKE_zherfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cherfsx_work: FunctionType.LAPACKE_cherfsx_work? = load(name: "LAPACKE_cherfsx_work", as: FunctionType.LAPACKE_cherfsx_work.self)
    #elseif os(macOS)
    static let cherfsx_work: FunctionType.LAPACKE_cherfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zherfsx_work: FunctionType.LAPACKE_zherfsx_work? = load(name: "LAPACKE_zherfsx_work", as: FunctionType.LAPACKE_zherfsx_work.self)
    #elseif os(macOS)
    static let zherfsx_work: FunctionType.LAPACKE_zherfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_work: FunctionType.LAPACKE_chesv_work? = load(name: "LAPACKE_chesv_work", as: FunctionType.LAPACKE_chesv_work.self)
    #elseif os(macOS)
    static let chesv_work: FunctionType.LAPACKE_chesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_work: FunctionType.LAPACKE_zhesv_work? = load(name: "LAPACKE_zhesv_work", as: FunctionType.LAPACKE_zhesv_work.self)
    #elseif os(macOS)
    static let zhesv_work: FunctionType.LAPACKE_zhesv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvx_work: FunctionType.LAPACKE_chesvx_work? = load(name: "LAPACKE_chesvx_work", as: FunctionType.LAPACKE_chesvx_work.self)
    #elseif os(macOS)
    static let chesvx_work: FunctionType.LAPACKE_chesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvx_work: FunctionType.LAPACKE_zhesvx_work? = load(name: "LAPACKE_zhesvx_work", as: FunctionType.LAPACKE_zhesvx_work.self)
    #elseif os(macOS)
    static let zhesvx_work: FunctionType.LAPACKE_zhesvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesvxx_work: FunctionType.LAPACKE_chesvxx_work? = load(name: "LAPACKE_chesvxx_work", as: FunctionType.LAPACKE_chesvxx_work.self)
    #elseif os(macOS)
    static let chesvxx_work: FunctionType.LAPACKE_chesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesvxx_work: FunctionType.LAPACKE_zhesvxx_work? = load(name: "LAPACKE_zhesvxx_work", as: FunctionType.LAPACKE_zhesvxx_work.self)
    #elseif os(macOS)
    static let zhesvxx_work: FunctionType.LAPACKE_zhesvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrd_work: FunctionType.LAPACKE_chetrd_work? = load(name: "LAPACKE_chetrd_work", as: FunctionType.LAPACKE_chetrd_work.self)
    #elseif os(macOS)
    static let chetrd_work: FunctionType.LAPACKE_chetrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrd_work: FunctionType.LAPACKE_zhetrd_work? = load(name: "LAPACKE_zhetrd_work", as: FunctionType.LAPACKE_zhetrd_work.self)
    #elseif os(macOS)
    static let zhetrd_work: FunctionType.LAPACKE_zhetrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_work: FunctionType.LAPACKE_chetrf_work? = load(name: "LAPACKE_chetrf_work", as: FunctionType.LAPACKE_chetrf_work.self)
    #elseif os(macOS)
    static let chetrf_work: FunctionType.LAPACKE_chetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_work: FunctionType.LAPACKE_zhetrf_work? = load(name: "LAPACKE_zhetrf_work", as: FunctionType.LAPACKE_zhetrf_work.self)
    #elseif os(macOS)
    static let zhetrf_work: FunctionType.LAPACKE_zhetrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri_work: FunctionType.LAPACKE_chetri_work? = load(name: "LAPACKE_chetri_work", as: FunctionType.LAPACKE_chetri_work.self)
    #elseif os(macOS)
    static let chetri_work: FunctionType.LAPACKE_chetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri_work: FunctionType.LAPACKE_zhetri_work? = load(name: "LAPACKE_zhetri_work", as: FunctionType.LAPACKE_zhetri_work.self)
    #elseif os(macOS)
    static let zhetri_work: FunctionType.LAPACKE_zhetri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_work: FunctionType.LAPACKE_chetrs_work? = load(name: "LAPACKE_chetrs_work", as: FunctionType.LAPACKE_chetrs_work.self)
    #elseif os(macOS)
    static let chetrs_work: FunctionType.LAPACKE_chetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_work: FunctionType.LAPACKE_zhetrs_work? = load(name: "LAPACKE_zhetrs_work", as: FunctionType.LAPACKE_zhetrs_work.self)
    #elseif os(macOS)
    static let zhetrs_work: FunctionType.LAPACKE_zhetrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chfrk_work: FunctionType.LAPACKE_chfrk_work? = load(name: "LAPACKE_chfrk_work", as: FunctionType.LAPACKE_chfrk_work.self)
    #elseif os(macOS)
    static let chfrk_work: FunctionType.LAPACKE_chfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhfrk_work: FunctionType.LAPACKE_zhfrk_work? = load(name: "LAPACKE_zhfrk_work", as: FunctionType.LAPACKE_zhfrk_work.self)
    #elseif os(macOS)
    static let zhfrk_work: FunctionType.LAPACKE_zhfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shgeqz_work: FunctionType.LAPACKE_shgeqz_work? = load(name: "LAPACKE_shgeqz_work", as: FunctionType.LAPACKE_shgeqz_work.self)
    #elseif os(macOS)
    static let shgeqz_work: FunctionType.LAPACKE_shgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhgeqz_work: FunctionType.LAPACKE_dhgeqz_work? = load(name: "LAPACKE_dhgeqz_work", as: FunctionType.LAPACKE_dhgeqz_work.self)
    #elseif os(macOS)
    static let dhgeqz_work: FunctionType.LAPACKE_dhgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chgeqz_work: FunctionType.LAPACKE_chgeqz_work? = load(name: "LAPACKE_chgeqz_work", as: FunctionType.LAPACKE_chgeqz_work.self)
    #elseif os(macOS)
    static let chgeqz_work: FunctionType.LAPACKE_chgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhgeqz_work: FunctionType.LAPACKE_zhgeqz_work? = load(name: "LAPACKE_zhgeqz_work", as: FunctionType.LAPACKE_zhgeqz_work.self)
    #elseif os(macOS)
    static let zhgeqz_work: FunctionType.LAPACKE_zhgeqz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpcon_work: FunctionType.LAPACKE_chpcon_work? = load(name: "LAPACKE_chpcon_work", as: FunctionType.LAPACKE_chpcon_work.self)
    #elseif os(macOS)
    static let chpcon_work: FunctionType.LAPACKE_chpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpcon_work: FunctionType.LAPACKE_zhpcon_work? = load(name: "LAPACKE_zhpcon_work", as: FunctionType.LAPACKE_zhpcon_work.self)
    #elseif os(macOS)
    static let zhpcon_work: FunctionType.LAPACKE_zhpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpev_work: FunctionType.LAPACKE_chpev_work? = load(name: "LAPACKE_chpev_work", as: FunctionType.LAPACKE_chpev_work.self)
    #elseif os(macOS)
    static let chpev_work: FunctionType.LAPACKE_chpev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpev_work: FunctionType.LAPACKE_zhpev_work? = load(name: "LAPACKE_zhpev_work", as: FunctionType.LAPACKE_zhpev_work.self)
    #elseif os(macOS)
    static let zhpev_work: FunctionType.LAPACKE_zhpev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevd_work: FunctionType.LAPACKE_chpevd_work? = load(name: "LAPACKE_chpevd_work", as: FunctionType.LAPACKE_chpevd_work.self)
    #elseif os(macOS)
    static let chpevd_work: FunctionType.LAPACKE_chpevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevd_work: FunctionType.LAPACKE_zhpevd_work? = load(name: "LAPACKE_zhpevd_work", as: FunctionType.LAPACKE_zhpevd_work.self)
    #elseif os(macOS)
    static let zhpevd_work: FunctionType.LAPACKE_zhpevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpevx_work: FunctionType.LAPACKE_chpevx_work? = load(name: "LAPACKE_chpevx_work", as: FunctionType.LAPACKE_chpevx_work.self)
    #elseif os(macOS)
    static let chpevx_work: FunctionType.LAPACKE_chpevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpevx_work: FunctionType.LAPACKE_zhpevx_work? = load(name: "LAPACKE_zhpevx_work", as: FunctionType.LAPACKE_zhpevx_work.self)
    #elseif os(macOS)
    static let zhpevx_work: FunctionType.LAPACKE_zhpevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgst_work: FunctionType.LAPACKE_chpgst_work? = load(name: "LAPACKE_chpgst_work", as: FunctionType.LAPACKE_chpgst_work.self)
    #elseif os(macOS)
    static let chpgst_work: FunctionType.LAPACKE_chpgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgst_work: FunctionType.LAPACKE_zhpgst_work? = load(name: "LAPACKE_zhpgst_work", as: FunctionType.LAPACKE_zhpgst_work.self)
    #elseif os(macOS)
    static let zhpgst_work: FunctionType.LAPACKE_zhpgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgv_work: FunctionType.LAPACKE_chpgv_work? = load(name: "LAPACKE_chpgv_work", as: FunctionType.LAPACKE_chpgv_work.self)
    #elseif os(macOS)
    static let chpgv_work: FunctionType.LAPACKE_chpgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgv_work: FunctionType.LAPACKE_zhpgv_work? = load(name: "LAPACKE_zhpgv_work", as: FunctionType.LAPACKE_zhpgv_work.self)
    #elseif os(macOS)
    static let zhpgv_work: FunctionType.LAPACKE_zhpgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvd_work: FunctionType.LAPACKE_chpgvd_work? = load(name: "LAPACKE_chpgvd_work", as: FunctionType.LAPACKE_chpgvd_work.self)
    #elseif os(macOS)
    static let chpgvd_work: FunctionType.LAPACKE_chpgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvd_work: FunctionType.LAPACKE_zhpgvd_work? = load(name: "LAPACKE_zhpgvd_work", as: FunctionType.LAPACKE_zhpgvd_work.self)
    #elseif os(macOS)
    static let zhpgvd_work: FunctionType.LAPACKE_zhpgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpgvx_work: FunctionType.LAPACKE_chpgvx_work? = load(name: "LAPACKE_chpgvx_work", as: FunctionType.LAPACKE_chpgvx_work.self)
    #elseif os(macOS)
    static let chpgvx_work: FunctionType.LAPACKE_chpgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpgvx_work: FunctionType.LAPACKE_zhpgvx_work? = load(name: "LAPACKE_zhpgvx_work", as: FunctionType.LAPACKE_zhpgvx_work.self)
    #elseif os(macOS)
    static let zhpgvx_work: FunctionType.LAPACKE_zhpgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chprfs_work: FunctionType.LAPACKE_chprfs_work? = load(name: "LAPACKE_chprfs_work", as: FunctionType.LAPACKE_chprfs_work.self)
    #elseif os(macOS)
    static let chprfs_work: FunctionType.LAPACKE_chprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhprfs_work: FunctionType.LAPACKE_zhprfs_work? = load(name: "LAPACKE_zhprfs_work", as: FunctionType.LAPACKE_zhprfs_work.self)
    #elseif os(macOS)
    static let zhprfs_work: FunctionType.LAPACKE_zhprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsv_work: FunctionType.LAPACKE_chpsv_work? = load(name: "LAPACKE_chpsv_work", as: FunctionType.LAPACKE_chpsv_work.self)
    #elseif os(macOS)
    static let chpsv_work: FunctionType.LAPACKE_chpsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsv_work: FunctionType.LAPACKE_zhpsv_work? = load(name: "LAPACKE_zhpsv_work", as: FunctionType.LAPACKE_zhpsv_work.self)
    #elseif os(macOS)
    static let zhpsv_work: FunctionType.LAPACKE_zhpsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chpsvx_work: FunctionType.LAPACKE_chpsvx_work? = load(name: "LAPACKE_chpsvx_work", as: FunctionType.LAPACKE_chpsvx_work.self)
    #elseif os(macOS)
    static let chpsvx_work: FunctionType.LAPACKE_chpsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhpsvx_work: FunctionType.LAPACKE_zhpsvx_work? = load(name: "LAPACKE_zhpsvx_work", as: FunctionType.LAPACKE_zhpsvx_work.self)
    #elseif os(macOS)
    static let zhpsvx_work: FunctionType.LAPACKE_zhpsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrd_work: FunctionType.LAPACKE_chptrd_work? = load(name: "LAPACKE_chptrd_work", as: FunctionType.LAPACKE_chptrd_work.self)
    #elseif os(macOS)
    static let chptrd_work: FunctionType.LAPACKE_chptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrd_work: FunctionType.LAPACKE_zhptrd_work? = load(name: "LAPACKE_zhptrd_work", as: FunctionType.LAPACKE_zhptrd_work.self)
    #elseif os(macOS)
    static let zhptrd_work: FunctionType.LAPACKE_zhptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrf_work: FunctionType.LAPACKE_chptrf_work? = load(name: "LAPACKE_chptrf_work", as: FunctionType.LAPACKE_chptrf_work.self)
    #elseif os(macOS)
    static let chptrf_work: FunctionType.LAPACKE_chptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrf_work: FunctionType.LAPACKE_zhptrf_work? = load(name: "LAPACKE_zhptrf_work", as: FunctionType.LAPACKE_zhptrf_work.self)
    #elseif os(macOS)
    static let zhptrf_work: FunctionType.LAPACKE_zhptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptri_work: FunctionType.LAPACKE_chptri_work? = load(name: "LAPACKE_chptri_work", as: FunctionType.LAPACKE_chptri_work.self)
    #elseif os(macOS)
    static let chptri_work: FunctionType.LAPACKE_chptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptri_work: FunctionType.LAPACKE_zhptri_work? = load(name: "LAPACKE_zhptri_work", as: FunctionType.LAPACKE_zhptri_work.self)
    #elseif os(macOS)
    static let zhptri_work: FunctionType.LAPACKE_zhptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chptrs_work: FunctionType.LAPACKE_chptrs_work? = load(name: "LAPACKE_chptrs_work", as: FunctionType.LAPACKE_chptrs_work.self)
    #elseif os(macOS)
    static let chptrs_work: FunctionType.LAPACKE_chptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhptrs_work: FunctionType.LAPACKE_zhptrs_work? = load(name: "LAPACKE_zhptrs_work", as: FunctionType.LAPACKE_zhptrs_work.self)
    #elseif os(macOS)
    static let zhptrs_work: FunctionType.LAPACKE_zhptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shsein_work: FunctionType.LAPACKE_shsein_work? = load(name: "LAPACKE_shsein_work", as: FunctionType.LAPACKE_shsein_work.self)
    #elseif os(macOS)
    static let shsein_work: FunctionType.LAPACKE_shsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhsein_work: FunctionType.LAPACKE_dhsein_work? = load(name: "LAPACKE_dhsein_work", as: FunctionType.LAPACKE_dhsein_work.self)
    #elseif os(macOS)
    static let dhsein_work: FunctionType.LAPACKE_dhsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chsein_work: FunctionType.LAPACKE_chsein_work? = load(name: "LAPACKE_chsein_work", as: FunctionType.LAPACKE_chsein_work.self)
    #elseif os(macOS)
    static let chsein_work: FunctionType.LAPACKE_chsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhsein_work: FunctionType.LAPACKE_zhsein_work? = load(name: "LAPACKE_zhsein_work", as: FunctionType.LAPACKE_zhsein_work.self)
    #elseif os(macOS)
    static let zhsein_work: FunctionType.LAPACKE_zhsein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let shseqr_work: FunctionType.LAPACKE_shseqr_work? = load(name: "LAPACKE_shseqr_work", as: FunctionType.LAPACKE_shseqr_work.self)
    #elseif os(macOS)
    static let shseqr_work: FunctionType.LAPACKE_shseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dhseqr_work: FunctionType.LAPACKE_dhseqr_work? = load(name: "LAPACKE_dhseqr_work", as: FunctionType.LAPACKE_dhseqr_work.self)
    #elseif os(macOS)
    static let dhseqr_work: FunctionType.LAPACKE_dhseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chseqr_work: FunctionType.LAPACKE_chseqr_work? = load(name: "LAPACKE_chseqr_work", as: FunctionType.LAPACKE_chseqr_work.self)
    #elseif os(macOS)
    static let chseqr_work: FunctionType.LAPACKE_chseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhseqr_work: FunctionType.LAPACKE_zhseqr_work? = load(name: "LAPACKE_zhseqr_work", as: FunctionType.LAPACKE_zhseqr_work.self)
    #elseif os(macOS)
    static let zhseqr_work: FunctionType.LAPACKE_zhseqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacgv_work: FunctionType.LAPACKE_clacgv_work? = load(name: "LAPACKE_clacgv_work", as: FunctionType.LAPACKE_clacgv_work.self)
    #elseif os(macOS)
    static let clacgv_work: FunctionType.LAPACKE_clacgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacgv_work: FunctionType.LAPACKE_zlacgv_work? = load(name: "LAPACKE_zlacgv_work", as: FunctionType.LAPACKE_zlacgv_work.self)
    #elseif os(macOS)
    static let zlacgv_work: FunctionType.LAPACKE_zlacgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacn2_work: FunctionType.LAPACKE_slacn2_work? = load(name: "LAPACKE_slacn2_work", as: FunctionType.LAPACKE_slacn2_work.self)
    #elseif os(macOS)
    static let slacn2_work: FunctionType.LAPACKE_slacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacn2_work: FunctionType.LAPACKE_dlacn2_work? = load(name: "LAPACKE_dlacn2_work", as: FunctionType.LAPACKE_dlacn2_work.self)
    #elseif os(macOS)
    static let dlacn2_work: FunctionType.LAPACKE_dlacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacn2_work: FunctionType.LAPACKE_clacn2_work? = load(name: "LAPACKE_clacn2_work", as: FunctionType.LAPACKE_clacn2_work.self)
    #elseif os(macOS)
    static let clacn2_work: FunctionType.LAPACKE_clacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacn2_work: FunctionType.LAPACKE_zlacn2_work? = load(name: "LAPACKE_zlacn2_work", as: FunctionType.LAPACKE_zlacn2_work.self)
    #elseif os(macOS)
    static let zlacn2_work: FunctionType.LAPACKE_zlacn2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slacpy_work: FunctionType.LAPACKE_slacpy_work? = load(name: "LAPACKE_slacpy_work", as: FunctionType.LAPACKE_slacpy_work.self)
    #elseif os(macOS)
    static let slacpy_work: FunctionType.LAPACKE_slacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlacpy_work: FunctionType.LAPACKE_dlacpy_work? = load(name: "LAPACKE_dlacpy_work", as: FunctionType.LAPACKE_dlacpy_work.self)
    #elseif os(macOS)
    static let dlacpy_work: FunctionType.LAPACKE_dlacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacpy_work: FunctionType.LAPACKE_clacpy_work? = load(name: "LAPACKE_clacpy_work", as: FunctionType.LAPACKE_clacpy_work.self)
    #elseif os(macOS)
    static let clacpy_work: FunctionType.LAPACKE_clacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacpy_work: FunctionType.LAPACKE_zlacpy_work? = load(name: "LAPACKE_zlacpy_work", as: FunctionType.LAPACKE_zlacpy_work.self)
    #elseif os(macOS)
    static let zlacpy_work: FunctionType.LAPACKE_zlacpy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacp2_work: FunctionType.LAPACKE_clacp2_work? = load(name: "LAPACKE_clacp2_work", as: FunctionType.LAPACKE_clacp2_work.self)
    #elseif os(macOS)
    static let clacp2_work: FunctionType.LAPACKE_clacp2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacp2_work: FunctionType.LAPACKE_zlacp2_work? = load(name: "LAPACKE_zlacp2_work", as: FunctionType.LAPACKE_zlacp2_work.self)
    #elseif os(macOS)
    static let zlacp2_work: FunctionType.LAPACKE_zlacp2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlag2c_work: FunctionType.LAPACKE_zlag2c_work? = load(name: "LAPACKE_zlag2c_work", as: FunctionType.LAPACKE_zlag2c_work.self)
    #elseif os(macOS)
    static let zlag2c_work: FunctionType.LAPACKE_zlag2c_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slag2d_work: FunctionType.LAPACKE_slag2d_work? = load(name: "LAPACKE_slag2d_work", as: FunctionType.LAPACKE_slag2d_work.self)
    #elseif os(macOS)
    static let slag2d_work: FunctionType.LAPACKE_slag2d_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlag2s_work: FunctionType.LAPACKE_dlag2s_work? = load(name: "LAPACKE_dlag2s_work", as: FunctionType.LAPACKE_dlag2s_work.self)
    #elseif os(macOS)
    static let dlag2s_work: FunctionType.LAPACKE_dlag2s_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clag2z_work: FunctionType.LAPACKE_clag2z_work? = load(name: "LAPACKE_clag2z_work", as: FunctionType.LAPACKE_clag2z_work.self)
    #elseif os(macOS)
    static let clag2z_work: FunctionType.LAPACKE_clag2z_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagge_work: FunctionType.LAPACKE_slagge_work? = load(name: "LAPACKE_slagge_work", as: FunctionType.LAPACKE_slagge_work.self)
    #elseif os(macOS)
    static let slagge_work: FunctionType.LAPACKE_slagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagge_work: FunctionType.LAPACKE_dlagge_work? = load(name: "LAPACKE_dlagge_work", as: FunctionType.LAPACKE_dlagge_work.self)
    #elseif os(macOS)
    static let dlagge_work: FunctionType.LAPACKE_dlagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagge_work: FunctionType.LAPACKE_clagge_work? = load(name: "LAPACKE_clagge_work", as: FunctionType.LAPACKE_clagge_work.self)
    #elseif os(macOS)
    static let clagge_work: FunctionType.LAPACKE_clagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagge_work: FunctionType.LAPACKE_zlagge_work? = load(name: "LAPACKE_zlagge_work", as: FunctionType.LAPACKE_zlagge_work.self)
    #elseif os(macOS)
    static let zlagge_work: FunctionType.LAPACKE_zlagge_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claghe_work: FunctionType.LAPACKE_claghe_work? = load(name: "LAPACKE_claghe_work", as: FunctionType.LAPACKE_claghe_work.self)
    #elseif os(macOS)
    static let claghe_work: FunctionType.LAPACKE_claghe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaghe_work: FunctionType.LAPACKE_zlaghe_work? = load(name: "LAPACKE_zlaghe_work", as: FunctionType.LAPACKE_zlaghe_work.self)
    #elseif os(macOS)
    static let zlaghe_work: FunctionType.LAPACKE_zlaghe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagsy_work: FunctionType.LAPACKE_slagsy_work? = load(name: "LAPACKE_slagsy_work", as: FunctionType.LAPACKE_slagsy_work.self)
    #elseif os(macOS)
    static let slagsy_work: FunctionType.LAPACKE_slagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagsy_work: FunctionType.LAPACKE_dlagsy_work? = load(name: "LAPACKE_dlagsy_work", as: FunctionType.LAPACKE_dlagsy_work.self)
    #elseif os(macOS)
    static let dlagsy_work: FunctionType.LAPACKE_dlagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagsy_work: FunctionType.LAPACKE_clagsy_work? = load(name: "LAPACKE_clagsy_work", as: FunctionType.LAPACKE_clagsy_work.self)
    #elseif os(macOS)
    static let clagsy_work: FunctionType.LAPACKE_clagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagsy_work: FunctionType.LAPACKE_zlagsy_work? = load(name: "LAPACKE_zlagsy_work", as: FunctionType.LAPACKE_zlagsy_work.self)
    #elseif os(macOS)
    static let zlagsy_work: FunctionType.LAPACKE_zlagsy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmr_work: FunctionType.LAPACKE_slapmr_work? = load(name: "LAPACKE_slapmr_work", as: FunctionType.LAPACKE_slapmr_work.self)
    #elseif os(macOS)
    static let slapmr_work: FunctionType.LAPACKE_slapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmr_work: FunctionType.LAPACKE_dlapmr_work? = load(name: "LAPACKE_dlapmr_work", as: FunctionType.LAPACKE_dlapmr_work.self)
    #elseif os(macOS)
    static let dlapmr_work: FunctionType.LAPACKE_dlapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmr_work: FunctionType.LAPACKE_clapmr_work? = load(name: "LAPACKE_clapmr_work", as: FunctionType.LAPACKE_clapmr_work.self)
    #elseif os(macOS)
    static let clapmr_work: FunctionType.LAPACKE_clapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmr_work: FunctionType.LAPACKE_zlapmr_work? = load(name: "LAPACKE_zlapmr_work", as: FunctionType.LAPACKE_zlapmr_work.self)
    #elseif os(macOS)
    static let zlapmr_work: FunctionType.LAPACKE_zlapmr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmt_work: FunctionType.LAPACKE_slapmt_work? = load(name: "LAPACKE_slapmt_work", as: FunctionType.LAPACKE_slapmt_work.self)
    #elseif os(macOS)
    static let slapmt_work: FunctionType.LAPACKE_slapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmt_work: FunctionType.LAPACKE_dlapmt_work? = load(name: "LAPACKE_dlapmt_work", as: FunctionType.LAPACKE_dlapmt_work.self)
    #elseif os(macOS)
    static let dlapmt_work: FunctionType.LAPACKE_dlapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmt_work: FunctionType.LAPACKE_clapmt_work? = load(name: "LAPACKE_clapmt_work", as: FunctionType.LAPACKE_clapmt_work.self)
    #elseif os(macOS)
    static let clapmt_work: FunctionType.LAPACKE_clapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmt_work: FunctionType.LAPACKE_zlapmt_work? = load(name: "LAPACKE_zlapmt_work", as: FunctionType.LAPACKE_zlapmt_work.self)
    #elseif os(macOS)
    static let zlapmt_work: FunctionType.LAPACKE_zlapmt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgp_work: FunctionType.LAPACKE_slartgp_work? = load(name: "LAPACKE_slartgp_work", as: FunctionType.LAPACKE_slartgp_work.self)
    #elseif os(macOS)
    static let slartgp_work: FunctionType.LAPACKE_slartgp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgp_work: FunctionType.LAPACKE_dlartgp_work? = load(name: "LAPACKE_dlartgp_work", as: FunctionType.LAPACKE_dlartgp_work.self)
    #elseif os(macOS)
    static let dlartgp_work: FunctionType.LAPACKE_dlartgp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgs_work: FunctionType.LAPACKE_slartgs_work? = load(name: "LAPACKE_slartgs_work", as: FunctionType.LAPACKE_slartgs_work.self)
    #elseif os(macOS)
    static let slartgs_work: FunctionType.LAPACKE_slartgs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgs_work: FunctionType.LAPACKE_dlartgs_work? = load(name: "LAPACKE_dlartgs_work", as: FunctionType.LAPACKE_dlartgs_work.self)
    #elseif os(macOS)
    static let dlartgs_work: FunctionType.LAPACKE_dlartgs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy2_work: FunctionType.LAPACKE_slapy2_work? = load(name: "LAPACKE_slapy2_work", as: FunctionType.LAPACKE_slapy2_work.self)
    #elseif os(macOS)
    static let slapy2_work: FunctionType.LAPACKE_slapy2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy2_work: FunctionType.LAPACKE_dlapy2_work? = load(name: "LAPACKE_dlapy2_work", as: FunctionType.LAPACKE_dlapy2_work.self)
    #elseif os(macOS)
    static let dlapy2_work: FunctionType.LAPACKE_dlapy2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy3_work: FunctionType.LAPACKE_slapy3_work? = load(name: "LAPACKE_slapy3_work", as: FunctionType.LAPACKE_slapy3_work.self)
    #elseif os(macOS)
    static let slapy3_work: FunctionType.LAPACKE_slapy3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy3_work: FunctionType.LAPACKE_dlapy3_work? = load(name: "LAPACKE_dlapy3_work", as: FunctionType.LAPACKE_dlapy3_work.self)
    #elseif os(macOS)
    static let dlapy3_work: FunctionType.LAPACKE_dlapy3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slamch_work: FunctionType.LAPACKE_slamch_work? = load(name: "LAPACKE_slamch_work", as: FunctionType.LAPACKE_slamch_work.self)
    #elseif os(macOS)
    static let slamch_work: FunctionType.LAPACKE_slamch_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlamch_work: FunctionType.LAPACKE_dlamch_work? = load(name: "LAPACKE_dlamch_work", as: FunctionType.LAPACKE_dlamch_work.self)
    #elseif os(macOS)
    static let dlamch_work: FunctionType.LAPACKE_dlamch_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slangb_work: FunctionType.LAPACKE_slangb_work? = load(name: "LAPACKE_slangb_work", as: FunctionType.LAPACKE_slangb_work.self)
    #elseif os(macOS)
    static let slangb_work: FunctionType.LAPACKE_slangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlangb_work: FunctionType.LAPACKE_dlangb_work? = load(name: "LAPACKE_dlangb_work", as: FunctionType.LAPACKE_dlangb_work.self)
    #elseif os(macOS)
    static let dlangb_work: FunctionType.LAPACKE_dlangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clangb_work: FunctionType.LAPACKE_clangb_work? = load(name: "LAPACKE_clangb_work", as: FunctionType.LAPACKE_clangb_work.self)
    #elseif os(macOS)
    static let clangb_work: FunctionType.LAPACKE_clangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlangb_work: FunctionType.LAPACKE_zlangb_work? = load(name: "LAPACKE_zlangb_work", as: FunctionType.LAPACKE_zlangb_work.self)
    #elseif os(macOS)
    static let zlangb_work: FunctionType.LAPACKE_zlangb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slange_work: FunctionType.LAPACKE_slange_work? = load(name: "LAPACKE_slange_work", as: FunctionType.LAPACKE_slange_work.self)
    #elseif os(macOS)
    static let slange_work: FunctionType.LAPACKE_slange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlange_work: FunctionType.LAPACKE_dlange_work? = load(name: "LAPACKE_dlange_work", as: FunctionType.LAPACKE_dlange_work.self)
    #elseif os(macOS)
    static let dlange_work: FunctionType.LAPACKE_dlange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clange_work: FunctionType.LAPACKE_clange_work? = load(name: "LAPACKE_clange_work", as: FunctionType.LAPACKE_clange_work.self)
    #elseif os(macOS)
    static let clange_work: FunctionType.LAPACKE_clange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlange_work: FunctionType.LAPACKE_zlange_work? = load(name: "LAPACKE_zlange_work", as: FunctionType.LAPACKE_zlange_work.self)
    #elseif os(macOS)
    static let zlange_work: FunctionType.LAPACKE_zlange_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clanhe_work: FunctionType.LAPACKE_clanhe_work? = load(name: "LAPACKE_clanhe_work", as: FunctionType.LAPACKE_clanhe_work.self)
    #elseif os(macOS)
    static let clanhe_work: FunctionType.LAPACKE_clanhe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlanhe_work: FunctionType.LAPACKE_zlanhe_work? = load(name: "LAPACKE_zlanhe_work", as: FunctionType.LAPACKE_zlanhe_work.self)
    #elseif os(macOS)
    static let zlanhe_work: FunctionType.LAPACKE_zlanhe_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clacrm_work: FunctionType.LAPACKE_clacrm_work? = load(name: "LAPACKE_clacrm_work", as: FunctionType.LAPACKE_clacrm_work.self)
    #elseif os(macOS)
    static let clacrm_work: FunctionType.LAPACKE_clacrm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlacrm_work: FunctionType.LAPACKE_zlacrm_work? = load(name: "LAPACKE_zlacrm_work", as: FunctionType.LAPACKE_zlacrm_work.self)
    #elseif os(macOS)
    static let zlacrm_work: FunctionType.LAPACKE_zlacrm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarcm_work: FunctionType.LAPACKE_clarcm_work? = load(name: "LAPACKE_clarcm_work", as: FunctionType.LAPACKE_clarcm_work.self)
    #elseif os(macOS)
    static let clarcm_work: FunctionType.LAPACKE_clarcm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarcm_work: FunctionType.LAPACKE_zlarcm_work? = load(name: "LAPACKE_zlarcm_work", as: FunctionType.LAPACKE_zlarcm_work.self)
    #elseif os(macOS)
    static let zlarcm_work: FunctionType.LAPACKE_zlarcm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slansy_work: FunctionType.LAPACKE_slansy_work? = load(name: "LAPACKE_slansy_work", as: FunctionType.LAPACKE_slansy_work.self)
    #elseif os(macOS)
    static let slansy_work: FunctionType.LAPACKE_slansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlansy_work: FunctionType.LAPACKE_dlansy_work? = load(name: "LAPACKE_dlansy_work", as: FunctionType.LAPACKE_dlansy_work.self)
    #elseif os(macOS)
    static let dlansy_work: FunctionType.LAPACKE_dlansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clansy_work: FunctionType.LAPACKE_clansy_work? = load(name: "LAPACKE_clansy_work", as: FunctionType.LAPACKE_clansy_work.self)
    #elseif os(macOS)
    static let clansy_work: FunctionType.LAPACKE_clansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlansy_work: FunctionType.LAPACKE_zlansy_work? = load(name: "LAPACKE_zlansy_work", as: FunctionType.LAPACKE_zlansy_work.self)
    #elseif os(macOS)
    static let zlansy_work: FunctionType.LAPACKE_zlansy_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slantr_work: FunctionType.LAPACKE_slantr_work? = load(name: "LAPACKE_slantr_work", as: FunctionType.LAPACKE_slantr_work.self)
    #elseif os(macOS)
    static let slantr_work: FunctionType.LAPACKE_slantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlantr_work: FunctionType.LAPACKE_dlantr_work? = load(name: "LAPACKE_dlantr_work", as: FunctionType.LAPACKE_dlantr_work.self)
    #elseif os(macOS)
    static let dlantr_work: FunctionType.LAPACKE_dlantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clantr_work: FunctionType.LAPACKE_clantr_work? = load(name: "LAPACKE_clantr_work", as: FunctionType.LAPACKE_clantr_work.self)
    #elseif os(macOS)
    static let clantr_work: FunctionType.LAPACKE_clantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlantr_work: FunctionType.LAPACKE_zlantr_work? = load(name: "LAPACKE_zlantr_work", as: FunctionType.LAPACKE_zlantr_work.self)
    #elseif os(macOS)
    static let zlantr_work: FunctionType.LAPACKE_zlantr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfb_work: FunctionType.LAPACKE_slarfb_work? = load(name: "LAPACKE_slarfb_work", as: FunctionType.LAPACKE_slarfb_work.self)
    #elseif os(macOS)
    static let slarfb_work: FunctionType.LAPACKE_slarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfb_work: FunctionType.LAPACKE_dlarfb_work? = load(name: "LAPACKE_dlarfb_work", as: FunctionType.LAPACKE_dlarfb_work.self)
    #elseif os(macOS)
    static let dlarfb_work: FunctionType.LAPACKE_dlarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfb_work: FunctionType.LAPACKE_clarfb_work? = load(name: "LAPACKE_clarfb_work", as: FunctionType.LAPACKE_clarfb_work.self)
    #elseif os(macOS)
    static let clarfb_work: FunctionType.LAPACKE_clarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfb_work: FunctionType.LAPACKE_zlarfb_work? = load(name: "LAPACKE_zlarfb_work", as: FunctionType.LAPACKE_zlarfb_work.self)
    #elseif os(macOS)
    static let zlarfb_work: FunctionType.LAPACKE_zlarfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfg_work: FunctionType.LAPACKE_slarfg_work? = load(name: "LAPACKE_slarfg_work", as: FunctionType.LAPACKE_slarfg_work.self)
    #elseif os(macOS)
    static let slarfg_work: FunctionType.LAPACKE_slarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfg_work: FunctionType.LAPACKE_dlarfg_work? = load(name: "LAPACKE_dlarfg_work", as: FunctionType.LAPACKE_dlarfg_work.self)
    #elseif os(macOS)
    static let dlarfg_work: FunctionType.LAPACKE_dlarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarfg_work: FunctionType.LAPACKE_clarfg_work? = load(name: "LAPACKE_clarfg_work", as: FunctionType.LAPACKE_clarfg_work.self)
    #elseif os(macOS)
    static let clarfg_work: FunctionType.LAPACKE_clarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarfg_work: FunctionType.LAPACKE_zlarfg_work? = load(name: "LAPACKE_zlarfg_work", as: FunctionType.LAPACKE_zlarfg_work.self)
    #elseif os(macOS)
    static let zlarfg_work: FunctionType.LAPACKE_zlarfg_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarft_work: FunctionType.LAPACKE_slarft_work? = load(name: "LAPACKE_slarft_work", as: FunctionType.LAPACKE_slarft_work.self)
    #elseif os(macOS)
    static let slarft_work: FunctionType.LAPACKE_slarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarft_work: FunctionType.LAPACKE_dlarft_work? = load(name: "LAPACKE_dlarft_work", as: FunctionType.LAPACKE_dlarft_work.self)
    #elseif os(macOS)
    static let dlarft_work: FunctionType.LAPACKE_dlarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarft_work: FunctionType.LAPACKE_clarft_work? = load(name: "LAPACKE_clarft_work", as: FunctionType.LAPACKE_clarft_work.self)
    #elseif os(macOS)
    static let clarft_work: FunctionType.LAPACKE_clarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarft_work: FunctionType.LAPACKE_zlarft_work? = load(name: "LAPACKE_zlarft_work", as: FunctionType.LAPACKE_zlarft_work.self)
    #elseif os(macOS)
    static let zlarft_work: FunctionType.LAPACKE_zlarft_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarfx_work: FunctionType.LAPACKE_slarfx_work? = load(name: "LAPACKE_slarfx_work", as: FunctionType.LAPACKE_slarfx_work.self)
    #elseif os(macOS)
    static let slarfx_work: FunctionType.LAPACKE_slarfx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarfx_work: FunctionType.LAPACKE_dlarfx_work? = load(name: "LAPACKE_dlarfx_work", as: FunctionType.LAPACKE_dlarfx_work.self)
    #elseif os(macOS)
    static let dlarfx_work: FunctionType.LAPACKE_dlarfx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slarnv_work: FunctionType.LAPACKE_slarnv_work? = load(name: "LAPACKE_slarnv_work", as: FunctionType.LAPACKE_slarnv_work.self)
    #elseif os(macOS)
    static let slarnv_work: FunctionType.LAPACKE_slarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlarnv_work: FunctionType.LAPACKE_dlarnv_work? = load(name: "LAPACKE_dlarnv_work", as: FunctionType.LAPACKE_dlarnv_work.self)
    #elseif os(macOS)
    static let dlarnv_work: FunctionType.LAPACKE_dlarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clarnv_work: FunctionType.LAPACKE_clarnv_work? = load(name: "LAPACKE_clarnv_work", as: FunctionType.LAPACKE_clarnv_work.self)
    #elseif os(macOS)
    static let clarnv_work: FunctionType.LAPACKE_clarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlarnv_work: FunctionType.LAPACKE_zlarnv_work? = load(name: "LAPACKE_zlarnv_work", as: FunctionType.LAPACKE_zlarnv_work.self)
    #elseif os(macOS)
    static let zlarnv_work: FunctionType.LAPACKE_zlarnv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slascl_work: FunctionType.LAPACKE_slascl_work? = load(name: "LAPACKE_slascl_work", as: FunctionType.LAPACKE_slascl_work.self)
    #elseif os(macOS)
    static let slascl_work: FunctionType.LAPACKE_slascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlascl_work: FunctionType.LAPACKE_dlascl_work? = load(name: "LAPACKE_dlascl_work", as: FunctionType.LAPACKE_dlascl_work.self)
    #elseif os(macOS)
    static let dlascl_work: FunctionType.LAPACKE_dlascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clascl_work: FunctionType.LAPACKE_clascl_work? = load(name: "LAPACKE_clascl_work", as: FunctionType.LAPACKE_clascl_work.self)
    #elseif os(macOS)
    static let clascl_work: FunctionType.LAPACKE_clascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlascl_work: FunctionType.LAPACKE_zlascl_work? = load(name: "LAPACKE_zlascl_work", as: FunctionType.LAPACKE_zlascl_work.self)
    #elseif os(macOS)
    static let zlascl_work: FunctionType.LAPACKE_zlascl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaset_work: FunctionType.LAPACKE_slaset_work? = load(name: "LAPACKE_slaset_work", as: FunctionType.LAPACKE_slaset_work.self)
    #elseif os(macOS)
    static let slaset_work: FunctionType.LAPACKE_slaset_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaset_work: FunctionType.LAPACKE_dlaset_work? = load(name: "LAPACKE_dlaset_work", as: FunctionType.LAPACKE_dlaset_work.self)
    #elseif os(macOS)
    static let dlaset_work: FunctionType.LAPACKE_dlaset_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slasrt_work: FunctionType.LAPACKE_slasrt_work? = load(name: "LAPACKE_slasrt_work", as: FunctionType.LAPACKE_slasrt_work.self)
    #elseif os(macOS)
    static let slasrt_work: FunctionType.LAPACKE_slasrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlasrt_work: FunctionType.LAPACKE_dlasrt_work? = load(name: "LAPACKE_dlasrt_work", as: FunctionType.LAPACKE_dlasrt_work.self)
    #elseif os(macOS)
    static let dlasrt_work: FunctionType.LAPACKE_dlasrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slassq_work: FunctionType.LAPACKE_slassq_work? = load(name: "LAPACKE_slassq_work", as: FunctionType.LAPACKE_slassq_work.self)
    #elseif os(macOS)
    static let slassq_work: FunctionType.LAPACKE_slassq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlassq_work: FunctionType.LAPACKE_dlassq_work? = load(name: "LAPACKE_dlassq_work", as: FunctionType.LAPACKE_dlassq_work.self)
    #elseif os(macOS)
    static let dlassq_work: FunctionType.LAPACKE_dlassq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let classq_work: FunctionType.LAPACKE_classq_work? = load(name: "LAPACKE_classq_work", as: FunctionType.LAPACKE_classq_work.self)
    #elseif os(macOS)
    static let classq_work: FunctionType.LAPACKE_classq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlassq_work: FunctionType.LAPACKE_zlassq_work? = load(name: "LAPACKE_zlassq_work", as: FunctionType.LAPACKE_zlassq_work.self)
    #elseif os(macOS)
    static let zlassq_work: FunctionType.LAPACKE_zlassq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slaswp_work: FunctionType.LAPACKE_slaswp_work? = load(name: "LAPACKE_slaswp_work", as: FunctionType.LAPACKE_slaswp_work.self)
    #elseif os(macOS)
    static let slaswp_work: FunctionType.LAPACKE_slaswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlaswp_work: FunctionType.LAPACKE_dlaswp_work? = load(name: "LAPACKE_dlaswp_work", as: FunctionType.LAPACKE_dlaswp_work.self)
    #elseif os(macOS)
    static let dlaswp_work: FunctionType.LAPACKE_dlaswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claswp_work: FunctionType.LAPACKE_claswp_work? = load(name: "LAPACKE_claswp_work", as: FunctionType.LAPACKE_claswp_work.self)
    #elseif os(macOS)
    static let claswp_work: FunctionType.LAPACKE_claswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaswp_work: FunctionType.LAPACKE_zlaswp_work? = load(name: "LAPACKE_zlaswp_work", as: FunctionType.LAPACKE_zlaswp_work.self)
    #elseif os(macOS)
    static let zlaswp_work: FunctionType.LAPACKE_zlaswp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slatms_work: FunctionType.LAPACKE_slatms_work? = load(name: "LAPACKE_slatms_work", as: FunctionType.LAPACKE_slatms_work.self)
    #elseif os(macOS)
    static let slatms_work: FunctionType.LAPACKE_slatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlatms_work: FunctionType.LAPACKE_dlatms_work? = load(name: "LAPACKE_dlatms_work", as: FunctionType.LAPACKE_dlatms_work.self)
    #elseif os(macOS)
    static let dlatms_work: FunctionType.LAPACKE_dlatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clatms_work: FunctionType.LAPACKE_clatms_work? = load(name: "LAPACKE_clatms_work", as: FunctionType.LAPACKE_clatms_work.self)
    #elseif os(macOS)
    static let clatms_work: FunctionType.LAPACKE_clatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlatms_work: FunctionType.LAPACKE_zlatms_work? = load(name: "LAPACKE_zlatms_work", as: FunctionType.LAPACKE_zlatms_work.self)
    #elseif os(macOS)
    static let zlatms_work: FunctionType.LAPACKE_zlatms_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slauum_work: FunctionType.LAPACKE_slauum_work? = load(name: "LAPACKE_slauum_work", as: FunctionType.LAPACKE_slauum_work.self)
    #elseif os(macOS)
    static let slauum_work: FunctionType.LAPACKE_slauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlauum_work: FunctionType.LAPACKE_dlauum_work? = load(name: "LAPACKE_dlauum_work", as: FunctionType.LAPACKE_dlauum_work.self)
    #elseif os(macOS)
    static let dlauum_work: FunctionType.LAPACKE_dlauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clauum_work: FunctionType.LAPACKE_clauum_work? = load(name: "LAPACKE_clauum_work", as: FunctionType.LAPACKE_clauum_work.self)
    #elseif os(macOS)
    static let clauum_work: FunctionType.LAPACKE_clauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlauum_work: FunctionType.LAPACKE_zlauum_work? = load(name: "LAPACKE_zlauum_work", as: FunctionType.LAPACKE_zlauum_work.self)
    #elseif os(macOS)
    static let zlauum_work: FunctionType.LAPACKE_zlauum_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopgtr_work: FunctionType.LAPACKE_sopgtr_work? = load(name: "LAPACKE_sopgtr_work", as: FunctionType.LAPACKE_sopgtr_work.self)
    #elseif os(macOS)
    static let sopgtr_work: FunctionType.LAPACKE_sopgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopgtr_work: FunctionType.LAPACKE_dopgtr_work? = load(name: "LAPACKE_dopgtr_work", as: FunctionType.LAPACKE_dopgtr_work.self)
    #elseif os(macOS)
    static let dopgtr_work: FunctionType.LAPACKE_dopgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sopmtr_work: FunctionType.LAPACKE_sopmtr_work? = load(name: "LAPACKE_sopmtr_work", as: FunctionType.LAPACKE_sopmtr_work.self)
    #elseif os(macOS)
    static let sopmtr_work: FunctionType.LAPACKE_sopmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dopmtr_work: FunctionType.LAPACKE_dopmtr_work? = load(name: "LAPACKE_dopmtr_work", as: FunctionType.LAPACKE_dopmtr_work.self)
    #elseif os(macOS)
    static let dopmtr_work: FunctionType.LAPACKE_dopmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgbr_work: FunctionType.LAPACKE_sorgbr_work? = load(name: "LAPACKE_sorgbr_work", as: FunctionType.LAPACKE_sorgbr_work.self)
    #elseif os(macOS)
    static let sorgbr_work: FunctionType.LAPACKE_sorgbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgbr_work: FunctionType.LAPACKE_dorgbr_work? = load(name: "LAPACKE_dorgbr_work", as: FunctionType.LAPACKE_dorgbr_work.self)
    #elseif os(macOS)
    static let dorgbr_work: FunctionType.LAPACKE_dorgbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorghr_work: FunctionType.LAPACKE_sorghr_work? = load(name: "LAPACKE_sorghr_work", as: FunctionType.LAPACKE_sorghr_work.self)
    #elseif os(macOS)
    static let sorghr_work: FunctionType.LAPACKE_sorghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorghr_work: FunctionType.LAPACKE_dorghr_work? = load(name: "LAPACKE_dorghr_work", as: FunctionType.LAPACKE_dorghr_work.self)
    #elseif os(macOS)
    static let dorghr_work: FunctionType.LAPACKE_dorghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorglq_work: FunctionType.LAPACKE_sorglq_work? = load(name: "LAPACKE_sorglq_work", as: FunctionType.LAPACKE_sorglq_work.self)
    #elseif os(macOS)
    static let sorglq_work: FunctionType.LAPACKE_sorglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorglq_work: FunctionType.LAPACKE_dorglq_work? = load(name: "LAPACKE_dorglq_work", as: FunctionType.LAPACKE_dorglq_work.self)
    #elseif os(macOS)
    static let dorglq_work: FunctionType.LAPACKE_dorglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgql_work: FunctionType.LAPACKE_sorgql_work? = load(name: "LAPACKE_sorgql_work", as: FunctionType.LAPACKE_sorgql_work.self)
    #elseif os(macOS)
    static let sorgql_work: FunctionType.LAPACKE_sorgql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgql_work: FunctionType.LAPACKE_dorgql_work? = load(name: "LAPACKE_dorgql_work", as: FunctionType.LAPACKE_dorgql_work.self)
    #elseif os(macOS)
    static let dorgql_work: FunctionType.LAPACKE_dorgql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgqr_work: FunctionType.LAPACKE_sorgqr_work? = load(name: "LAPACKE_sorgqr_work", as: FunctionType.LAPACKE_sorgqr_work.self)
    #elseif os(macOS)
    static let sorgqr_work: FunctionType.LAPACKE_sorgqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgqr_work: FunctionType.LAPACKE_dorgqr_work? = load(name: "LAPACKE_dorgqr_work", as: FunctionType.LAPACKE_dorgqr_work.self)
    #elseif os(macOS)
    static let dorgqr_work: FunctionType.LAPACKE_dorgqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgrq_work: FunctionType.LAPACKE_sorgrq_work? = load(name: "LAPACKE_sorgrq_work", as: FunctionType.LAPACKE_sorgrq_work.self)
    #elseif os(macOS)
    static let sorgrq_work: FunctionType.LAPACKE_sorgrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgrq_work: FunctionType.LAPACKE_dorgrq_work? = load(name: "LAPACKE_dorgrq_work", as: FunctionType.LAPACKE_dorgrq_work.self)
    #elseif os(macOS)
    static let dorgrq_work: FunctionType.LAPACKE_dorgrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtr_work: FunctionType.LAPACKE_sorgtr_work? = load(name: "LAPACKE_sorgtr_work", as: FunctionType.LAPACKE_sorgtr_work.self)
    #elseif os(macOS)
    static let sorgtr_work: FunctionType.LAPACKE_sorgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtr_work: FunctionType.LAPACKE_dorgtr_work? = load(name: "LAPACKE_dorgtr_work", as: FunctionType.LAPACKE_dorgtr_work.self)
    #elseif os(macOS)
    static let dorgtr_work: FunctionType.LAPACKE_dorgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorgtsqr_row_work: FunctionType.LAPACKE_sorgtsqr_row_work? = load(name: "LAPACKE_sorgtsqr_row_work", as: FunctionType.LAPACKE_sorgtsqr_row_work.self)
    #elseif os(macOS)
    static let sorgtsqr_row_work: FunctionType.LAPACKE_sorgtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorgtsqr_row_work: FunctionType.LAPACKE_dorgtsqr_row_work? = load(name: "LAPACKE_dorgtsqr_row_work", as: FunctionType.LAPACKE_dorgtsqr_row_work.self)
    #elseif os(macOS)
    static let dorgtsqr_row_work: FunctionType.LAPACKE_dorgtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormbr_work: FunctionType.LAPACKE_sormbr_work? = load(name: "LAPACKE_sormbr_work", as: FunctionType.LAPACKE_sormbr_work.self)
    #elseif os(macOS)
    static let sormbr_work: FunctionType.LAPACKE_sormbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormbr_work: FunctionType.LAPACKE_dormbr_work? = load(name: "LAPACKE_dormbr_work", as: FunctionType.LAPACKE_dormbr_work.self)
    #elseif os(macOS)
    static let dormbr_work: FunctionType.LAPACKE_dormbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormhr_work: FunctionType.LAPACKE_sormhr_work? = load(name: "LAPACKE_sormhr_work", as: FunctionType.LAPACKE_sormhr_work.self)
    #elseif os(macOS)
    static let sormhr_work: FunctionType.LAPACKE_sormhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormhr_work: FunctionType.LAPACKE_dormhr_work? = load(name: "LAPACKE_dormhr_work", as: FunctionType.LAPACKE_dormhr_work.self)
    #elseif os(macOS)
    static let dormhr_work: FunctionType.LAPACKE_dormhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormlq_work: FunctionType.LAPACKE_sormlq_work? = load(name: "LAPACKE_sormlq_work", as: FunctionType.LAPACKE_sormlq_work.self)
    #elseif os(macOS)
    static let sormlq_work: FunctionType.LAPACKE_sormlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormlq_work: FunctionType.LAPACKE_dormlq_work? = load(name: "LAPACKE_dormlq_work", as: FunctionType.LAPACKE_dormlq_work.self)
    #elseif os(macOS)
    static let dormlq_work: FunctionType.LAPACKE_dormlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormql_work: FunctionType.LAPACKE_sormql_work? = load(name: "LAPACKE_sormql_work", as: FunctionType.LAPACKE_sormql_work.self)
    #elseif os(macOS)
    static let sormql_work: FunctionType.LAPACKE_sormql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormql_work: FunctionType.LAPACKE_dormql_work? = load(name: "LAPACKE_dormql_work", as: FunctionType.LAPACKE_dormql_work.self)
    #elseif os(macOS)
    static let dormql_work: FunctionType.LAPACKE_dormql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormqr_work: FunctionType.LAPACKE_sormqr_work? = load(name: "LAPACKE_sormqr_work", as: FunctionType.LAPACKE_sormqr_work.self)
    #elseif os(macOS)
    static let sormqr_work: FunctionType.LAPACKE_sormqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormqr_work: FunctionType.LAPACKE_dormqr_work? = load(name: "LAPACKE_dormqr_work", as: FunctionType.LAPACKE_dormqr_work.self)
    #elseif os(macOS)
    static let dormqr_work: FunctionType.LAPACKE_dormqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrq_work: FunctionType.LAPACKE_sormrq_work? = load(name: "LAPACKE_sormrq_work", as: FunctionType.LAPACKE_sormrq_work.self)
    #elseif os(macOS)
    static let sormrq_work: FunctionType.LAPACKE_sormrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrq_work: FunctionType.LAPACKE_dormrq_work? = load(name: "LAPACKE_dormrq_work", as: FunctionType.LAPACKE_dormrq_work.self)
    #elseif os(macOS)
    static let dormrq_work: FunctionType.LAPACKE_dormrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormrz_work: FunctionType.LAPACKE_sormrz_work? = load(name: "LAPACKE_sormrz_work", as: FunctionType.LAPACKE_sormrz_work.self)
    #elseif os(macOS)
    static let sormrz_work: FunctionType.LAPACKE_sormrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormrz_work: FunctionType.LAPACKE_dormrz_work? = load(name: "LAPACKE_dormrz_work", as: FunctionType.LAPACKE_dormrz_work.self)
    #elseif os(macOS)
    static let dormrz_work: FunctionType.LAPACKE_dormrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sormtr_work: FunctionType.LAPACKE_sormtr_work? = load(name: "LAPACKE_sormtr_work", as: FunctionType.LAPACKE_sormtr_work.self)
    #elseif os(macOS)
    static let sormtr_work: FunctionType.LAPACKE_sormtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dormtr_work: FunctionType.LAPACKE_dormtr_work? = load(name: "LAPACKE_dormtr_work", as: FunctionType.LAPACKE_dormtr_work.self)
    #elseif os(macOS)
    static let dormtr_work: FunctionType.LAPACKE_dormtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbcon_work: FunctionType.LAPACKE_spbcon_work? = load(name: "LAPACKE_spbcon_work", as: FunctionType.LAPACKE_spbcon_work.self)
    #elseif os(macOS)
    static let spbcon_work: FunctionType.LAPACKE_spbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbcon_work: FunctionType.LAPACKE_dpbcon_work? = load(name: "LAPACKE_dpbcon_work", as: FunctionType.LAPACKE_dpbcon_work.self)
    #elseif os(macOS)
    static let dpbcon_work: FunctionType.LAPACKE_dpbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbcon_work: FunctionType.LAPACKE_cpbcon_work? = load(name: "LAPACKE_cpbcon_work", as: FunctionType.LAPACKE_cpbcon_work.self)
    #elseif os(macOS)
    static let cpbcon_work: FunctionType.LAPACKE_cpbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbcon_work: FunctionType.LAPACKE_zpbcon_work? = load(name: "LAPACKE_zpbcon_work", as: FunctionType.LAPACKE_zpbcon_work.self)
    #elseif os(macOS)
    static let zpbcon_work: FunctionType.LAPACKE_zpbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbequ_work: FunctionType.LAPACKE_spbequ_work? = load(name: "LAPACKE_spbequ_work", as: FunctionType.LAPACKE_spbequ_work.self)
    #elseif os(macOS)
    static let spbequ_work: FunctionType.LAPACKE_spbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbequ_work: FunctionType.LAPACKE_dpbequ_work? = load(name: "LAPACKE_dpbequ_work", as: FunctionType.LAPACKE_dpbequ_work.self)
    #elseif os(macOS)
    static let dpbequ_work: FunctionType.LAPACKE_dpbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbequ_work: FunctionType.LAPACKE_cpbequ_work? = load(name: "LAPACKE_cpbequ_work", as: FunctionType.LAPACKE_cpbequ_work.self)
    #elseif os(macOS)
    static let cpbequ_work: FunctionType.LAPACKE_cpbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbequ_work: FunctionType.LAPACKE_zpbequ_work? = load(name: "LAPACKE_zpbequ_work", as: FunctionType.LAPACKE_zpbequ_work.self)
    #elseif os(macOS)
    static let zpbequ_work: FunctionType.LAPACKE_zpbequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbrfs_work: FunctionType.LAPACKE_spbrfs_work? = load(name: "LAPACKE_spbrfs_work", as: FunctionType.LAPACKE_spbrfs_work.self)
    #elseif os(macOS)
    static let spbrfs_work: FunctionType.LAPACKE_spbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbrfs_work: FunctionType.LAPACKE_dpbrfs_work? = load(name: "LAPACKE_dpbrfs_work", as: FunctionType.LAPACKE_dpbrfs_work.self)
    #elseif os(macOS)
    static let dpbrfs_work: FunctionType.LAPACKE_dpbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbrfs_work: FunctionType.LAPACKE_cpbrfs_work? = load(name: "LAPACKE_cpbrfs_work", as: FunctionType.LAPACKE_cpbrfs_work.self)
    #elseif os(macOS)
    static let cpbrfs_work: FunctionType.LAPACKE_cpbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbrfs_work: FunctionType.LAPACKE_zpbrfs_work? = load(name: "LAPACKE_zpbrfs_work", as: FunctionType.LAPACKE_zpbrfs_work.self)
    #elseif os(macOS)
    static let zpbrfs_work: FunctionType.LAPACKE_zpbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbstf_work: FunctionType.LAPACKE_spbstf_work? = load(name: "LAPACKE_spbstf_work", as: FunctionType.LAPACKE_spbstf_work.self)
    #elseif os(macOS)
    static let spbstf_work: FunctionType.LAPACKE_spbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbstf_work: FunctionType.LAPACKE_dpbstf_work? = load(name: "LAPACKE_dpbstf_work", as: FunctionType.LAPACKE_dpbstf_work.self)
    #elseif os(macOS)
    static let dpbstf_work: FunctionType.LAPACKE_dpbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbstf_work: FunctionType.LAPACKE_cpbstf_work? = load(name: "LAPACKE_cpbstf_work", as: FunctionType.LAPACKE_cpbstf_work.self)
    #elseif os(macOS)
    static let cpbstf_work: FunctionType.LAPACKE_cpbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbstf_work: FunctionType.LAPACKE_zpbstf_work? = load(name: "LAPACKE_zpbstf_work", as: FunctionType.LAPACKE_zpbstf_work.self)
    #elseif os(macOS)
    static let zpbstf_work: FunctionType.LAPACKE_zpbstf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsv_work: FunctionType.LAPACKE_spbsv_work? = load(name: "LAPACKE_spbsv_work", as: FunctionType.LAPACKE_spbsv_work.self)
    #elseif os(macOS)
    static let spbsv_work: FunctionType.LAPACKE_spbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsv_work: FunctionType.LAPACKE_dpbsv_work? = load(name: "LAPACKE_dpbsv_work", as: FunctionType.LAPACKE_dpbsv_work.self)
    #elseif os(macOS)
    static let dpbsv_work: FunctionType.LAPACKE_dpbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsv_work: FunctionType.LAPACKE_cpbsv_work? = load(name: "LAPACKE_cpbsv_work", as: FunctionType.LAPACKE_cpbsv_work.self)
    #elseif os(macOS)
    static let cpbsv_work: FunctionType.LAPACKE_cpbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsv_work: FunctionType.LAPACKE_zpbsv_work? = load(name: "LAPACKE_zpbsv_work", as: FunctionType.LAPACKE_zpbsv_work.self)
    #elseif os(macOS)
    static let zpbsv_work: FunctionType.LAPACKE_zpbsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbsvx_work: FunctionType.LAPACKE_spbsvx_work? = load(name: "LAPACKE_spbsvx_work", as: FunctionType.LAPACKE_spbsvx_work.self)
    #elseif os(macOS)
    static let spbsvx_work: FunctionType.LAPACKE_spbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbsvx_work: FunctionType.LAPACKE_dpbsvx_work? = load(name: "LAPACKE_dpbsvx_work", as: FunctionType.LAPACKE_dpbsvx_work.self)
    #elseif os(macOS)
    static let dpbsvx_work: FunctionType.LAPACKE_dpbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbsvx_work: FunctionType.LAPACKE_cpbsvx_work? = load(name: "LAPACKE_cpbsvx_work", as: FunctionType.LAPACKE_cpbsvx_work.self)
    #elseif os(macOS)
    static let cpbsvx_work: FunctionType.LAPACKE_cpbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbsvx_work: FunctionType.LAPACKE_zpbsvx_work? = load(name: "LAPACKE_zpbsvx_work", as: FunctionType.LAPACKE_zpbsvx_work.self)
    #elseif os(macOS)
    static let zpbsvx_work: FunctionType.LAPACKE_zpbsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrf_work: FunctionType.LAPACKE_spbtrf_work? = load(name: "LAPACKE_spbtrf_work", as: FunctionType.LAPACKE_spbtrf_work.self)
    #elseif os(macOS)
    static let spbtrf_work: FunctionType.LAPACKE_spbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrf_work: FunctionType.LAPACKE_dpbtrf_work? = load(name: "LAPACKE_dpbtrf_work", as: FunctionType.LAPACKE_dpbtrf_work.self)
    #elseif os(macOS)
    static let dpbtrf_work: FunctionType.LAPACKE_dpbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrf_work: FunctionType.LAPACKE_cpbtrf_work? = load(name: "LAPACKE_cpbtrf_work", as: FunctionType.LAPACKE_cpbtrf_work.self)
    #elseif os(macOS)
    static let cpbtrf_work: FunctionType.LAPACKE_cpbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrf_work: FunctionType.LAPACKE_zpbtrf_work? = load(name: "LAPACKE_zpbtrf_work", as: FunctionType.LAPACKE_zpbtrf_work.self)
    #elseif os(macOS)
    static let zpbtrf_work: FunctionType.LAPACKE_zpbtrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spbtrs_work: FunctionType.LAPACKE_spbtrs_work? = load(name: "LAPACKE_spbtrs_work", as: FunctionType.LAPACKE_spbtrs_work.self)
    #elseif os(macOS)
    static let spbtrs_work: FunctionType.LAPACKE_spbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpbtrs_work: FunctionType.LAPACKE_dpbtrs_work? = load(name: "LAPACKE_dpbtrs_work", as: FunctionType.LAPACKE_dpbtrs_work.self)
    #elseif os(macOS)
    static let dpbtrs_work: FunctionType.LAPACKE_dpbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpbtrs_work: FunctionType.LAPACKE_cpbtrs_work? = load(name: "LAPACKE_cpbtrs_work", as: FunctionType.LAPACKE_cpbtrs_work.self)
    #elseif os(macOS)
    static let cpbtrs_work: FunctionType.LAPACKE_cpbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpbtrs_work: FunctionType.LAPACKE_zpbtrs_work? = load(name: "LAPACKE_zpbtrs_work", as: FunctionType.LAPACKE_zpbtrs_work.self)
    #elseif os(macOS)
    static let zpbtrs_work: FunctionType.LAPACKE_zpbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrf_work: FunctionType.LAPACKE_spftrf_work? = load(name: "LAPACKE_spftrf_work", as: FunctionType.LAPACKE_spftrf_work.self)
    #elseif os(macOS)
    static let spftrf_work: FunctionType.LAPACKE_spftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrf_work: FunctionType.LAPACKE_dpftrf_work? = load(name: "LAPACKE_dpftrf_work", as: FunctionType.LAPACKE_dpftrf_work.self)
    #elseif os(macOS)
    static let dpftrf_work: FunctionType.LAPACKE_dpftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrf_work: FunctionType.LAPACKE_cpftrf_work? = load(name: "LAPACKE_cpftrf_work", as: FunctionType.LAPACKE_cpftrf_work.self)
    #elseif os(macOS)
    static let cpftrf_work: FunctionType.LAPACKE_cpftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrf_work: FunctionType.LAPACKE_zpftrf_work? = load(name: "LAPACKE_zpftrf_work", as: FunctionType.LAPACKE_zpftrf_work.self)
    #elseif os(macOS)
    static let zpftrf_work: FunctionType.LAPACKE_zpftrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftri_work: FunctionType.LAPACKE_spftri_work? = load(name: "LAPACKE_spftri_work", as: FunctionType.LAPACKE_spftri_work.self)
    #elseif os(macOS)
    static let spftri_work: FunctionType.LAPACKE_spftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftri_work: FunctionType.LAPACKE_dpftri_work? = load(name: "LAPACKE_dpftri_work", as: FunctionType.LAPACKE_dpftri_work.self)
    #elseif os(macOS)
    static let dpftri_work: FunctionType.LAPACKE_dpftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftri_work: FunctionType.LAPACKE_cpftri_work? = load(name: "LAPACKE_cpftri_work", as: FunctionType.LAPACKE_cpftri_work.self)
    #elseif os(macOS)
    static let cpftri_work: FunctionType.LAPACKE_cpftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftri_work: FunctionType.LAPACKE_zpftri_work? = load(name: "LAPACKE_zpftri_work", as: FunctionType.LAPACKE_zpftri_work.self)
    #elseif os(macOS)
    static let zpftri_work: FunctionType.LAPACKE_zpftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spftrs_work: FunctionType.LAPACKE_spftrs_work? = load(name: "LAPACKE_spftrs_work", as: FunctionType.LAPACKE_spftrs_work.self)
    #elseif os(macOS)
    static let spftrs_work: FunctionType.LAPACKE_spftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpftrs_work: FunctionType.LAPACKE_dpftrs_work? = load(name: "LAPACKE_dpftrs_work", as: FunctionType.LAPACKE_dpftrs_work.self)
    #elseif os(macOS)
    static let dpftrs_work: FunctionType.LAPACKE_dpftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpftrs_work: FunctionType.LAPACKE_cpftrs_work? = load(name: "LAPACKE_cpftrs_work", as: FunctionType.LAPACKE_cpftrs_work.self)
    #elseif os(macOS)
    static let cpftrs_work: FunctionType.LAPACKE_cpftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpftrs_work: FunctionType.LAPACKE_zpftrs_work? = load(name: "LAPACKE_zpftrs_work", as: FunctionType.LAPACKE_zpftrs_work.self)
    #elseif os(macOS)
    static let zpftrs_work: FunctionType.LAPACKE_zpftrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spocon_work: FunctionType.LAPACKE_spocon_work? = load(name: "LAPACKE_spocon_work", as: FunctionType.LAPACKE_spocon_work.self)
    #elseif os(macOS)
    static let spocon_work: FunctionType.LAPACKE_spocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpocon_work: FunctionType.LAPACKE_dpocon_work? = load(name: "LAPACKE_dpocon_work", as: FunctionType.LAPACKE_dpocon_work.self)
    #elseif os(macOS)
    static let dpocon_work: FunctionType.LAPACKE_dpocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpocon_work: FunctionType.LAPACKE_cpocon_work? = load(name: "LAPACKE_cpocon_work", as: FunctionType.LAPACKE_cpocon_work.self)
    #elseif os(macOS)
    static let cpocon_work: FunctionType.LAPACKE_cpocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpocon_work: FunctionType.LAPACKE_zpocon_work? = load(name: "LAPACKE_zpocon_work", as: FunctionType.LAPACKE_zpocon_work.self)
    #elseif os(macOS)
    static let zpocon_work: FunctionType.LAPACKE_zpocon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequ_work: FunctionType.LAPACKE_spoequ_work? = load(name: "LAPACKE_spoequ_work", as: FunctionType.LAPACKE_spoequ_work.self)
    #elseif os(macOS)
    static let spoequ_work: FunctionType.LAPACKE_spoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequ_work: FunctionType.LAPACKE_dpoequ_work? = load(name: "LAPACKE_dpoequ_work", as: FunctionType.LAPACKE_dpoequ_work.self)
    #elseif os(macOS)
    static let dpoequ_work: FunctionType.LAPACKE_dpoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequ_work: FunctionType.LAPACKE_cpoequ_work? = load(name: "LAPACKE_cpoequ_work", as: FunctionType.LAPACKE_cpoequ_work.self)
    #elseif os(macOS)
    static let cpoequ_work: FunctionType.LAPACKE_cpoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequ_work: FunctionType.LAPACKE_zpoequ_work? = load(name: "LAPACKE_zpoequ_work", as: FunctionType.LAPACKE_zpoequ_work.self)
    #elseif os(macOS)
    static let zpoequ_work: FunctionType.LAPACKE_zpoequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spoequb_work: FunctionType.LAPACKE_spoequb_work? = load(name: "LAPACKE_spoequb_work", as: FunctionType.LAPACKE_spoequb_work.self)
    #elseif os(macOS)
    static let spoequb_work: FunctionType.LAPACKE_spoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpoequb_work: FunctionType.LAPACKE_dpoequb_work? = load(name: "LAPACKE_dpoequb_work", as: FunctionType.LAPACKE_dpoequb_work.self)
    #elseif os(macOS)
    static let dpoequb_work: FunctionType.LAPACKE_dpoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpoequb_work: FunctionType.LAPACKE_cpoequb_work? = load(name: "LAPACKE_cpoequb_work", as: FunctionType.LAPACKE_cpoequb_work.self)
    #elseif os(macOS)
    static let cpoequb_work: FunctionType.LAPACKE_cpoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpoequb_work: FunctionType.LAPACKE_zpoequb_work? = load(name: "LAPACKE_zpoequb_work", as: FunctionType.LAPACKE_zpoequb_work.self)
    #elseif os(macOS)
    static let zpoequb_work: FunctionType.LAPACKE_zpoequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfs_work: FunctionType.LAPACKE_sporfs_work? = load(name: "LAPACKE_sporfs_work", as: FunctionType.LAPACKE_sporfs_work.self)
    #elseif os(macOS)
    static let sporfs_work: FunctionType.LAPACKE_sporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfs_work: FunctionType.LAPACKE_dporfs_work? = load(name: "LAPACKE_dporfs_work", as: FunctionType.LAPACKE_dporfs_work.self)
    #elseif os(macOS)
    static let dporfs_work: FunctionType.LAPACKE_dporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfs_work: FunctionType.LAPACKE_cporfs_work? = load(name: "LAPACKE_cporfs_work", as: FunctionType.LAPACKE_cporfs_work.self)
    #elseif os(macOS)
    static let cporfs_work: FunctionType.LAPACKE_cporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfs_work: FunctionType.LAPACKE_zporfs_work? = load(name: "LAPACKE_zporfs_work", as: FunctionType.LAPACKE_zporfs_work.self)
    #elseif os(macOS)
    static let zporfs_work: FunctionType.LAPACKE_zporfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sporfsx_work: FunctionType.LAPACKE_sporfsx_work? = load(name: "LAPACKE_sporfsx_work", as: FunctionType.LAPACKE_sporfsx_work.self)
    #elseif os(macOS)
    static let sporfsx_work: FunctionType.LAPACKE_sporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dporfsx_work: FunctionType.LAPACKE_dporfsx_work? = load(name: "LAPACKE_dporfsx_work", as: FunctionType.LAPACKE_dporfsx_work.self)
    #elseif os(macOS)
    static let dporfsx_work: FunctionType.LAPACKE_dporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cporfsx_work: FunctionType.LAPACKE_cporfsx_work? = load(name: "LAPACKE_cporfsx_work", as: FunctionType.LAPACKE_cporfsx_work.self)
    #elseif os(macOS)
    static let cporfsx_work: FunctionType.LAPACKE_cporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zporfsx_work: FunctionType.LAPACKE_zporfsx_work? = load(name: "LAPACKE_zporfsx_work", as: FunctionType.LAPACKE_zporfsx_work.self)
    #elseif os(macOS)
    static let zporfsx_work: FunctionType.LAPACKE_zporfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposv_work: FunctionType.LAPACKE_sposv_work? = load(name: "LAPACKE_sposv_work", as: FunctionType.LAPACKE_sposv_work.self)
    #elseif os(macOS)
    static let sposv_work: FunctionType.LAPACKE_sposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposv_work: FunctionType.LAPACKE_dposv_work? = load(name: "LAPACKE_dposv_work", as: FunctionType.LAPACKE_dposv_work.self)
    #elseif os(macOS)
    static let dposv_work: FunctionType.LAPACKE_dposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposv_work: FunctionType.LAPACKE_cposv_work? = load(name: "LAPACKE_cposv_work", as: FunctionType.LAPACKE_cposv_work.self)
    #elseif os(macOS)
    static let cposv_work: FunctionType.LAPACKE_cposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposv_work: FunctionType.LAPACKE_zposv_work? = load(name: "LAPACKE_zposv_work", as: FunctionType.LAPACKE_zposv_work.self)
    #elseif os(macOS)
    static let zposv_work: FunctionType.LAPACKE_zposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsposv_work: FunctionType.LAPACKE_dsposv_work? = load(name: "LAPACKE_dsposv_work", as: FunctionType.LAPACKE_dsposv_work.self)
    #elseif os(macOS)
    static let dsposv_work: FunctionType.LAPACKE_dsposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zcposv_work: FunctionType.LAPACKE_zcposv_work? = load(name: "LAPACKE_zcposv_work", as: FunctionType.LAPACKE_zcposv_work.self)
    #elseif os(macOS)
    static let zcposv_work: FunctionType.LAPACKE_zcposv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvx_work: FunctionType.LAPACKE_sposvx_work? = load(name: "LAPACKE_sposvx_work", as: FunctionType.LAPACKE_sposvx_work.self)
    #elseif os(macOS)
    static let sposvx_work: FunctionType.LAPACKE_sposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvx_work: FunctionType.LAPACKE_dposvx_work? = load(name: "LAPACKE_dposvx_work", as: FunctionType.LAPACKE_dposvx_work.self)
    #elseif os(macOS)
    static let dposvx_work: FunctionType.LAPACKE_dposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvx_work: FunctionType.LAPACKE_cposvx_work? = load(name: "LAPACKE_cposvx_work", as: FunctionType.LAPACKE_cposvx_work.self)
    #elseif os(macOS)
    static let cposvx_work: FunctionType.LAPACKE_cposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvx_work: FunctionType.LAPACKE_zposvx_work? = load(name: "LAPACKE_zposvx_work", as: FunctionType.LAPACKE_zposvx_work.self)
    #elseif os(macOS)
    static let zposvx_work: FunctionType.LAPACKE_zposvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sposvxx_work: FunctionType.LAPACKE_sposvxx_work? = load(name: "LAPACKE_sposvxx_work", as: FunctionType.LAPACKE_sposvxx_work.self)
    #elseif os(macOS)
    static let sposvxx_work: FunctionType.LAPACKE_sposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dposvxx_work: FunctionType.LAPACKE_dposvxx_work? = load(name: "LAPACKE_dposvxx_work", as: FunctionType.LAPACKE_dposvxx_work.self)
    #elseif os(macOS)
    static let dposvxx_work: FunctionType.LAPACKE_dposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cposvxx_work: FunctionType.LAPACKE_cposvxx_work? = load(name: "LAPACKE_cposvxx_work", as: FunctionType.LAPACKE_cposvxx_work.self)
    #elseif os(macOS)
    static let cposvxx_work: FunctionType.LAPACKE_cposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zposvxx_work: FunctionType.LAPACKE_zposvxx_work? = load(name: "LAPACKE_zposvxx_work", as: FunctionType.LAPACKE_zposvxx_work.self)
    #elseif os(macOS)
    static let zposvxx_work: FunctionType.LAPACKE_zposvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf2_work: FunctionType.LAPACKE_spotrf2_work? = load(name: "LAPACKE_spotrf2_work", as: FunctionType.LAPACKE_spotrf2_work.self)
    #elseif os(macOS)
    static let spotrf2_work: FunctionType.LAPACKE_spotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf2_work: FunctionType.LAPACKE_dpotrf2_work? = load(name: "LAPACKE_dpotrf2_work", as: FunctionType.LAPACKE_dpotrf2_work.self)
    #elseif os(macOS)
    static let dpotrf2_work: FunctionType.LAPACKE_dpotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf2_work: FunctionType.LAPACKE_cpotrf2_work? = load(name: "LAPACKE_cpotrf2_work", as: FunctionType.LAPACKE_cpotrf2_work.self)
    #elseif os(macOS)
    static let cpotrf2_work: FunctionType.LAPACKE_cpotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf2_work: FunctionType.LAPACKE_zpotrf2_work? = load(name: "LAPACKE_zpotrf2_work", as: FunctionType.LAPACKE_zpotrf2_work.self)
    #elseif os(macOS)
    static let zpotrf2_work: FunctionType.LAPACKE_zpotrf2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrf_work: FunctionType.LAPACKE_spotrf_work? = load(name: "LAPACKE_spotrf_work", as: FunctionType.LAPACKE_spotrf_work.self)
    #elseif os(macOS)
    static let spotrf_work: FunctionType.LAPACKE_spotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrf_work: FunctionType.LAPACKE_dpotrf_work? = load(name: "LAPACKE_dpotrf_work", as: FunctionType.LAPACKE_dpotrf_work.self)
    #elseif os(macOS)
    static let dpotrf_work: FunctionType.LAPACKE_dpotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrf_work: FunctionType.LAPACKE_cpotrf_work? = load(name: "LAPACKE_cpotrf_work", as: FunctionType.LAPACKE_cpotrf_work.self)
    #elseif os(macOS)
    static let cpotrf_work: FunctionType.LAPACKE_cpotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrf_work: FunctionType.LAPACKE_zpotrf_work? = load(name: "LAPACKE_zpotrf_work", as: FunctionType.LAPACKE_zpotrf_work.self)
    #elseif os(macOS)
    static let zpotrf_work: FunctionType.LAPACKE_zpotrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotri_work: FunctionType.LAPACKE_spotri_work? = load(name: "LAPACKE_spotri_work", as: FunctionType.LAPACKE_spotri_work.self)
    #elseif os(macOS)
    static let spotri_work: FunctionType.LAPACKE_spotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotri_work: FunctionType.LAPACKE_dpotri_work? = load(name: "LAPACKE_dpotri_work", as: FunctionType.LAPACKE_dpotri_work.self)
    #elseif os(macOS)
    static let dpotri_work: FunctionType.LAPACKE_dpotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotri_work: FunctionType.LAPACKE_cpotri_work? = load(name: "LAPACKE_cpotri_work", as: FunctionType.LAPACKE_cpotri_work.self)
    #elseif os(macOS)
    static let cpotri_work: FunctionType.LAPACKE_cpotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotri_work: FunctionType.LAPACKE_zpotri_work? = load(name: "LAPACKE_zpotri_work", as: FunctionType.LAPACKE_zpotri_work.self)
    #elseif os(macOS)
    static let zpotri_work: FunctionType.LAPACKE_zpotri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spotrs_work: FunctionType.LAPACKE_spotrs_work? = load(name: "LAPACKE_spotrs_work", as: FunctionType.LAPACKE_spotrs_work.self)
    #elseif os(macOS)
    static let spotrs_work: FunctionType.LAPACKE_spotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpotrs_work: FunctionType.LAPACKE_dpotrs_work? = load(name: "LAPACKE_dpotrs_work", as: FunctionType.LAPACKE_dpotrs_work.self)
    #elseif os(macOS)
    static let dpotrs_work: FunctionType.LAPACKE_dpotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpotrs_work: FunctionType.LAPACKE_cpotrs_work? = load(name: "LAPACKE_cpotrs_work", as: FunctionType.LAPACKE_cpotrs_work.self)
    #elseif os(macOS)
    static let cpotrs_work: FunctionType.LAPACKE_cpotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpotrs_work: FunctionType.LAPACKE_zpotrs_work? = load(name: "LAPACKE_zpotrs_work", as: FunctionType.LAPACKE_zpotrs_work.self)
    #elseif os(macOS)
    static let zpotrs_work: FunctionType.LAPACKE_zpotrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppcon_work: FunctionType.LAPACKE_sppcon_work? = load(name: "LAPACKE_sppcon_work", as: FunctionType.LAPACKE_sppcon_work.self)
    #elseif os(macOS)
    static let sppcon_work: FunctionType.LAPACKE_sppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppcon_work: FunctionType.LAPACKE_dppcon_work? = load(name: "LAPACKE_dppcon_work", as: FunctionType.LAPACKE_dppcon_work.self)
    #elseif os(macOS)
    static let dppcon_work: FunctionType.LAPACKE_dppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppcon_work: FunctionType.LAPACKE_cppcon_work? = load(name: "LAPACKE_cppcon_work", as: FunctionType.LAPACKE_cppcon_work.self)
    #elseif os(macOS)
    static let cppcon_work: FunctionType.LAPACKE_cppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppcon_work: FunctionType.LAPACKE_zppcon_work? = load(name: "LAPACKE_zppcon_work", as: FunctionType.LAPACKE_zppcon_work.self)
    #elseif os(macOS)
    static let zppcon_work: FunctionType.LAPACKE_zppcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppequ_work: FunctionType.LAPACKE_sppequ_work? = load(name: "LAPACKE_sppequ_work", as: FunctionType.LAPACKE_sppequ_work.self)
    #elseif os(macOS)
    static let sppequ_work: FunctionType.LAPACKE_sppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppequ_work: FunctionType.LAPACKE_dppequ_work? = load(name: "LAPACKE_dppequ_work", as: FunctionType.LAPACKE_dppequ_work.self)
    #elseif os(macOS)
    static let dppequ_work: FunctionType.LAPACKE_dppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppequ_work: FunctionType.LAPACKE_cppequ_work? = load(name: "LAPACKE_cppequ_work", as: FunctionType.LAPACKE_cppequ_work.self)
    #elseif os(macOS)
    static let cppequ_work: FunctionType.LAPACKE_cppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppequ_work: FunctionType.LAPACKE_zppequ_work? = load(name: "LAPACKE_zppequ_work", as: FunctionType.LAPACKE_zppequ_work.self)
    #elseif os(macOS)
    static let zppequ_work: FunctionType.LAPACKE_zppequ_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spprfs_work: FunctionType.LAPACKE_spprfs_work? = load(name: "LAPACKE_spprfs_work", as: FunctionType.LAPACKE_spprfs_work.self)
    #elseif os(macOS)
    static let spprfs_work: FunctionType.LAPACKE_spprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpprfs_work: FunctionType.LAPACKE_dpprfs_work? = load(name: "LAPACKE_dpprfs_work", as: FunctionType.LAPACKE_dpprfs_work.self)
    #elseif os(macOS)
    static let dpprfs_work: FunctionType.LAPACKE_dpprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpprfs_work: FunctionType.LAPACKE_cpprfs_work? = load(name: "LAPACKE_cpprfs_work", as: FunctionType.LAPACKE_cpprfs_work.self)
    #elseif os(macOS)
    static let cpprfs_work: FunctionType.LAPACKE_cpprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpprfs_work: FunctionType.LAPACKE_zpprfs_work? = load(name: "LAPACKE_zpprfs_work", as: FunctionType.LAPACKE_zpprfs_work.self)
    #elseif os(macOS)
    static let zpprfs_work: FunctionType.LAPACKE_zpprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsv_work: FunctionType.LAPACKE_sppsv_work? = load(name: "LAPACKE_sppsv_work", as: FunctionType.LAPACKE_sppsv_work.self)
    #elseif os(macOS)
    static let sppsv_work: FunctionType.LAPACKE_sppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsv_work: FunctionType.LAPACKE_dppsv_work? = load(name: "LAPACKE_dppsv_work", as: FunctionType.LAPACKE_dppsv_work.self)
    #elseif os(macOS)
    static let dppsv_work: FunctionType.LAPACKE_dppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsv_work: FunctionType.LAPACKE_cppsv_work? = load(name: "LAPACKE_cppsv_work", as: FunctionType.LAPACKE_cppsv_work.self)
    #elseif os(macOS)
    static let cppsv_work: FunctionType.LAPACKE_cppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsv_work: FunctionType.LAPACKE_zppsv_work? = load(name: "LAPACKE_zppsv_work", as: FunctionType.LAPACKE_zppsv_work.self)
    #elseif os(macOS)
    static let zppsv_work: FunctionType.LAPACKE_zppsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sppsvx_work: FunctionType.LAPACKE_sppsvx_work? = load(name: "LAPACKE_sppsvx_work", as: FunctionType.LAPACKE_sppsvx_work.self)
    #elseif os(macOS)
    static let sppsvx_work: FunctionType.LAPACKE_sppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dppsvx_work: FunctionType.LAPACKE_dppsvx_work? = load(name: "LAPACKE_dppsvx_work", as: FunctionType.LAPACKE_dppsvx_work.self)
    #elseif os(macOS)
    static let dppsvx_work: FunctionType.LAPACKE_dppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cppsvx_work: FunctionType.LAPACKE_cppsvx_work? = load(name: "LAPACKE_cppsvx_work", as: FunctionType.LAPACKE_cppsvx_work.self)
    #elseif os(macOS)
    static let cppsvx_work: FunctionType.LAPACKE_cppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zppsvx_work: FunctionType.LAPACKE_zppsvx_work? = load(name: "LAPACKE_zppsvx_work", as: FunctionType.LAPACKE_zppsvx_work.self)
    #elseif os(macOS)
    static let zppsvx_work: FunctionType.LAPACKE_zppsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrf_work: FunctionType.LAPACKE_spptrf_work? = load(name: "LAPACKE_spptrf_work", as: FunctionType.LAPACKE_spptrf_work.self)
    #elseif os(macOS)
    static let spptrf_work: FunctionType.LAPACKE_spptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrf_work: FunctionType.LAPACKE_dpptrf_work? = load(name: "LAPACKE_dpptrf_work", as: FunctionType.LAPACKE_dpptrf_work.self)
    #elseif os(macOS)
    static let dpptrf_work: FunctionType.LAPACKE_dpptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrf_work: FunctionType.LAPACKE_cpptrf_work? = load(name: "LAPACKE_cpptrf_work", as: FunctionType.LAPACKE_cpptrf_work.self)
    #elseif os(macOS)
    static let cpptrf_work: FunctionType.LAPACKE_cpptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrf_work: FunctionType.LAPACKE_zpptrf_work? = load(name: "LAPACKE_zpptrf_work", as: FunctionType.LAPACKE_zpptrf_work.self)
    #elseif os(macOS)
    static let zpptrf_work: FunctionType.LAPACKE_zpptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptri_work: FunctionType.LAPACKE_spptri_work? = load(name: "LAPACKE_spptri_work", as: FunctionType.LAPACKE_spptri_work.self)
    #elseif os(macOS)
    static let spptri_work: FunctionType.LAPACKE_spptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptri_work: FunctionType.LAPACKE_dpptri_work? = load(name: "LAPACKE_dpptri_work", as: FunctionType.LAPACKE_dpptri_work.self)
    #elseif os(macOS)
    static let dpptri_work: FunctionType.LAPACKE_dpptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptri_work: FunctionType.LAPACKE_cpptri_work? = load(name: "LAPACKE_cpptri_work", as: FunctionType.LAPACKE_cpptri_work.self)
    #elseif os(macOS)
    static let cpptri_work: FunctionType.LAPACKE_cpptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptri_work: FunctionType.LAPACKE_zpptri_work? = load(name: "LAPACKE_zpptri_work", as: FunctionType.LAPACKE_zpptri_work.self)
    #elseif os(macOS)
    static let zpptri_work: FunctionType.LAPACKE_zpptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spptrs_work: FunctionType.LAPACKE_spptrs_work? = load(name: "LAPACKE_spptrs_work", as: FunctionType.LAPACKE_spptrs_work.self)
    #elseif os(macOS)
    static let spptrs_work: FunctionType.LAPACKE_spptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpptrs_work: FunctionType.LAPACKE_dpptrs_work? = load(name: "LAPACKE_dpptrs_work", as: FunctionType.LAPACKE_dpptrs_work.self)
    #elseif os(macOS)
    static let dpptrs_work: FunctionType.LAPACKE_dpptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpptrs_work: FunctionType.LAPACKE_cpptrs_work? = load(name: "LAPACKE_cpptrs_work", as: FunctionType.LAPACKE_cpptrs_work.self)
    #elseif os(macOS)
    static let cpptrs_work: FunctionType.LAPACKE_cpptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpptrs_work: FunctionType.LAPACKE_zpptrs_work? = load(name: "LAPACKE_zpptrs_work", as: FunctionType.LAPACKE_zpptrs_work.self)
    #elseif os(macOS)
    static let zpptrs_work: FunctionType.LAPACKE_zpptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spstrf_work: FunctionType.LAPACKE_spstrf_work? = load(name: "LAPACKE_spstrf_work", as: FunctionType.LAPACKE_spstrf_work.self)
    #elseif os(macOS)
    static let spstrf_work: FunctionType.LAPACKE_spstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpstrf_work: FunctionType.LAPACKE_dpstrf_work? = load(name: "LAPACKE_dpstrf_work", as: FunctionType.LAPACKE_dpstrf_work.self)
    #elseif os(macOS)
    static let dpstrf_work: FunctionType.LAPACKE_dpstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpstrf_work: FunctionType.LAPACKE_cpstrf_work? = load(name: "LAPACKE_cpstrf_work", as: FunctionType.LAPACKE_cpstrf_work.self)
    #elseif os(macOS)
    static let cpstrf_work: FunctionType.LAPACKE_cpstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpstrf_work: FunctionType.LAPACKE_zpstrf_work? = load(name: "LAPACKE_zpstrf_work", as: FunctionType.LAPACKE_zpstrf_work.self)
    #elseif os(macOS)
    static let zpstrf_work: FunctionType.LAPACKE_zpstrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptcon_work: FunctionType.LAPACKE_sptcon_work? = load(name: "LAPACKE_sptcon_work", as: FunctionType.LAPACKE_sptcon_work.self)
    #elseif os(macOS)
    static let sptcon_work: FunctionType.LAPACKE_sptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptcon_work: FunctionType.LAPACKE_dptcon_work? = load(name: "LAPACKE_dptcon_work", as: FunctionType.LAPACKE_dptcon_work.self)
    #elseif os(macOS)
    static let dptcon_work: FunctionType.LAPACKE_dptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptcon_work: FunctionType.LAPACKE_cptcon_work? = load(name: "LAPACKE_cptcon_work", as: FunctionType.LAPACKE_cptcon_work.self)
    #elseif os(macOS)
    static let cptcon_work: FunctionType.LAPACKE_cptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptcon_work: FunctionType.LAPACKE_zptcon_work? = load(name: "LAPACKE_zptcon_work", as: FunctionType.LAPACKE_zptcon_work.self)
    #elseif os(macOS)
    static let zptcon_work: FunctionType.LAPACKE_zptcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spteqr_work: FunctionType.LAPACKE_spteqr_work? = load(name: "LAPACKE_spteqr_work", as: FunctionType.LAPACKE_spteqr_work.self)
    #elseif os(macOS)
    static let spteqr_work: FunctionType.LAPACKE_spteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpteqr_work: FunctionType.LAPACKE_dpteqr_work? = load(name: "LAPACKE_dpteqr_work", as: FunctionType.LAPACKE_dpteqr_work.self)
    #elseif os(macOS)
    static let dpteqr_work: FunctionType.LAPACKE_dpteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpteqr_work: FunctionType.LAPACKE_cpteqr_work? = load(name: "LAPACKE_cpteqr_work", as: FunctionType.LAPACKE_cpteqr_work.self)
    #elseif os(macOS)
    static let cpteqr_work: FunctionType.LAPACKE_cpteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpteqr_work: FunctionType.LAPACKE_zpteqr_work? = load(name: "LAPACKE_zpteqr_work", as: FunctionType.LAPACKE_zpteqr_work.self)
    #elseif os(macOS)
    static let zpteqr_work: FunctionType.LAPACKE_zpteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptrfs_work: FunctionType.LAPACKE_sptrfs_work? = load(name: "LAPACKE_sptrfs_work", as: FunctionType.LAPACKE_sptrfs_work.self)
    #elseif os(macOS)
    static let sptrfs_work: FunctionType.LAPACKE_sptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptrfs_work: FunctionType.LAPACKE_dptrfs_work? = load(name: "LAPACKE_dptrfs_work", as: FunctionType.LAPACKE_dptrfs_work.self)
    #elseif os(macOS)
    static let dptrfs_work: FunctionType.LAPACKE_dptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptrfs_work: FunctionType.LAPACKE_cptrfs_work? = load(name: "LAPACKE_cptrfs_work", as: FunctionType.LAPACKE_cptrfs_work.self)
    #elseif os(macOS)
    static let cptrfs_work: FunctionType.LAPACKE_cptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptrfs_work: FunctionType.LAPACKE_zptrfs_work? = load(name: "LAPACKE_zptrfs_work", as: FunctionType.LAPACKE_zptrfs_work.self)
    #elseif os(macOS)
    static let zptrfs_work: FunctionType.LAPACKE_zptrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsv_work: FunctionType.LAPACKE_sptsv_work? = load(name: "LAPACKE_sptsv_work", as: FunctionType.LAPACKE_sptsv_work.self)
    #elseif os(macOS)
    static let sptsv_work: FunctionType.LAPACKE_sptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsv_work: FunctionType.LAPACKE_dptsv_work? = load(name: "LAPACKE_dptsv_work", as: FunctionType.LAPACKE_dptsv_work.self)
    #elseif os(macOS)
    static let dptsv_work: FunctionType.LAPACKE_dptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsv_work: FunctionType.LAPACKE_cptsv_work? = load(name: "LAPACKE_cptsv_work", as: FunctionType.LAPACKE_cptsv_work.self)
    #elseif os(macOS)
    static let cptsv_work: FunctionType.LAPACKE_cptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsv_work: FunctionType.LAPACKE_zptsv_work? = load(name: "LAPACKE_zptsv_work", as: FunctionType.LAPACKE_zptsv_work.self)
    #elseif os(macOS)
    static let zptsv_work: FunctionType.LAPACKE_zptsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sptsvx_work: FunctionType.LAPACKE_sptsvx_work? = load(name: "LAPACKE_sptsvx_work", as: FunctionType.LAPACKE_sptsvx_work.self)
    #elseif os(macOS)
    static let sptsvx_work: FunctionType.LAPACKE_sptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dptsvx_work: FunctionType.LAPACKE_dptsvx_work? = load(name: "LAPACKE_dptsvx_work", as: FunctionType.LAPACKE_dptsvx_work.self)
    #elseif os(macOS)
    static let dptsvx_work: FunctionType.LAPACKE_dptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cptsvx_work: FunctionType.LAPACKE_cptsvx_work? = load(name: "LAPACKE_cptsvx_work", as: FunctionType.LAPACKE_cptsvx_work.self)
    #elseif os(macOS)
    static let cptsvx_work: FunctionType.LAPACKE_cptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zptsvx_work: FunctionType.LAPACKE_zptsvx_work? = load(name: "LAPACKE_zptsvx_work", as: FunctionType.LAPACKE_zptsvx_work.self)
    #elseif os(macOS)
    static let zptsvx_work: FunctionType.LAPACKE_zptsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrf_work: FunctionType.LAPACKE_spttrf_work? = load(name: "LAPACKE_spttrf_work", as: FunctionType.LAPACKE_spttrf_work.self)
    #elseif os(macOS)
    static let spttrf_work: FunctionType.LAPACKE_spttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrf_work: FunctionType.LAPACKE_dpttrf_work? = load(name: "LAPACKE_dpttrf_work", as: FunctionType.LAPACKE_dpttrf_work.self)
    #elseif os(macOS)
    static let dpttrf_work: FunctionType.LAPACKE_dpttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrf_work: FunctionType.LAPACKE_cpttrf_work? = load(name: "LAPACKE_cpttrf_work", as: FunctionType.LAPACKE_cpttrf_work.self)
    #elseif os(macOS)
    static let cpttrf_work: FunctionType.LAPACKE_cpttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrf_work: FunctionType.LAPACKE_zpttrf_work? = load(name: "LAPACKE_zpttrf_work", as: FunctionType.LAPACKE_zpttrf_work.self)
    #elseif os(macOS)
    static let zpttrf_work: FunctionType.LAPACKE_zpttrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let spttrs_work: FunctionType.LAPACKE_spttrs_work? = load(name: "LAPACKE_spttrs_work", as: FunctionType.LAPACKE_spttrs_work.self)
    #elseif os(macOS)
    static let spttrs_work: FunctionType.LAPACKE_spttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dpttrs_work: FunctionType.LAPACKE_dpttrs_work? = load(name: "LAPACKE_dpttrs_work", as: FunctionType.LAPACKE_dpttrs_work.self)
    #elseif os(macOS)
    static let dpttrs_work: FunctionType.LAPACKE_dpttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cpttrs_work: FunctionType.LAPACKE_cpttrs_work? = load(name: "LAPACKE_cpttrs_work", as: FunctionType.LAPACKE_cpttrs_work.self)
    #elseif os(macOS)
    static let cpttrs_work: FunctionType.LAPACKE_cpttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zpttrs_work: FunctionType.LAPACKE_zpttrs_work? = load(name: "LAPACKE_zpttrs_work", as: FunctionType.LAPACKE_zpttrs_work.self)
    #elseif os(macOS)
    static let zpttrs_work: FunctionType.LAPACKE_zpttrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev_work: FunctionType.LAPACKE_ssbev_work? = load(name: "LAPACKE_ssbev_work", as: FunctionType.LAPACKE_ssbev_work.self)
    #elseif os(macOS)
    static let ssbev_work: FunctionType.LAPACKE_ssbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev_work: FunctionType.LAPACKE_dsbev_work? = load(name: "LAPACKE_dsbev_work", as: FunctionType.LAPACKE_dsbev_work.self)
    #elseif os(macOS)
    static let dsbev_work: FunctionType.LAPACKE_dsbev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd_work: FunctionType.LAPACKE_ssbevd_work? = load(name: "LAPACKE_ssbevd_work", as: FunctionType.LAPACKE_ssbevd_work.self)
    #elseif os(macOS)
    static let ssbevd_work: FunctionType.LAPACKE_ssbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd_work: FunctionType.LAPACKE_dsbevd_work? = load(name: "LAPACKE_dsbevd_work", as: FunctionType.LAPACKE_dsbevd_work.self)
    #elseif os(macOS)
    static let dsbevd_work: FunctionType.LAPACKE_dsbevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx_work: FunctionType.LAPACKE_ssbevx_work? = load(name: "LAPACKE_ssbevx_work", as: FunctionType.LAPACKE_ssbevx_work.self)
    #elseif os(macOS)
    static let ssbevx_work: FunctionType.LAPACKE_ssbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx_work: FunctionType.LAPACKE_dsbevx_work? = load(name: "LAPACKE_dsbevx_work", as: FunctionType.LAPACKE_dsbevx_work.self)
    #elseif os(macOS)
    static let dsbevx_work: FunctionType.LAPACKE_dsbevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgst_work: FunctionType.LAPACKE_ssbgst_work? = load(name: "LAPACKE_ssbgst_work", as: FunctionType.LAPACKE_ssbgst_work.self)
    #elseif os(macOS)
    static let ssbgst_work: FunctionType.LAPACKE_ssbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgst_work: FunctionType.LAPACKE_dsbgst_work? = load(name: "LAPACKE_dsbgst_work", as: FunctionType.LAPACKE_dsbgst_work.self)
    #elseif os(macOS)
    static let dsbgst_work: FunctionType.LAPACKE_dsbgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgv_work: FunctionType.LAPACKE_ssbgv_work? = load(name: "LAPACKE_ssbgv_work", as: FunctionType.LAPACKE_ssbgv_work.self)
    #elseif os(macOS)
    static let ssbgv_work: FunctionType.LAPACKE_ssbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgv_work: FunctionType.LAPACKE_dsbgv_work? = load(name: "LAPACKE_dsbgv_work", as: FunctionType.LAPACKE_dsbgv_work.self)
    #elseif os(macOS)
    static let dsbgv_work: FunctionType.LAPACKE_dsbgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvd_work: FunctionType.LAPACKE_ssbgvd_work? = load(name: "LAPACKE_ssbgvd_work", as: FunctionType.LAPACKE_ssbgvd_work.self)
    #elseif os(macOS)
    static let ssbgvd_work: FunctionType.LAPACKE_ssbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvd_work: FunctionType.LAPACKE_dsbgvd_work? = load(name: "LAPACKE_dsbgvd_work", as: FunctionType.LAPACKE_dsbgvd_work.self)
    #elseif os(macOS)
    static let dsbgvd_work: FunctionType.LAPACKE_dsbgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbgvx_work: FunctionType.LAPACKE_ssbgvx_work? = load(name: "LAPACKE_ssbgvx_work", as: FunctionType.LAPACKE_ssbgvx_work.self)
    #elseif os(macOS)
    static let ssbgvx_work: FunctionType.LAPACKE_ssbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbgvx_work: FunctionType.LAPACKE_dsbgvx_work? = load(name: "LAPACKE_dsbgvx_work", as: FunctionType.LAPACKE_dsbgvx_work.self)
    #elseif os(macOS)
    static let dsbgvx_work: FunctionType.LAPACKE_dsbgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbtrd_work: FunctionType.LAPACKE_ssbtrd_work? = load(name: "LAPACKE_ssbtrd_work", as: FunctionType.LAPACKE_ssbtrd_work.self)
    #elseif os(macOS)
    static let ssbtrd_work: FunctionType.LAPACKE_ssbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbtrd_work: FunctionType.LAPACKE_dsbtrd_work? = load(name: "LAPACKE_dsbtrd_work", as: FunctionType.LAPACKE_dsbtrd_work.self)
    #elseif os(macOS)
    static let dsbtrd_work: FunctionType.LAPACKE_dsbtrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssfrk_work: FunctionType.LAPACKE_ssfrk_work? = load(name: "LAPACKE_ssfrk_work", as: FunctionType.LAPACKE_ssfrk_work.self)
    #elseif os(macOS)
    static let ssfrk_work: FunctionType.LAPACKE_ssfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsfrk_work: FunctionType.LAPACKE_dsfrk_work? = load(name: "LAPACKE_dsfrk_work", as: FunctionType.LAPACKE_dsfrk_work.self)
    #elseif os(macOS)
    static let dsfrk_work: FunctionType.LAPACKE_dsfrk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspcon_work: FunctionType.LAPACKE_sspcon_work? = load(name: "LAPACKE_sspcon_work", as: FunctionType.LAPACKE_sspcon_work.self)
    #elseif os(macOS)
    static let sspcon_work: FunctionType.LAPACKE_sspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspcon_work: FunctionType.LAPACKE_dspcon_work? = load(name: "LAPACKE_dspcon_work", as: FunctionType.LAPACKE_dspcon_work.self)
    #elseif os(macOS)
    static let dspcon_work: FunctionType.LAPACKE_dspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspcon_work: FunctionType.LAPACKE_cspcon_work? = load(name: "LAPACKE_cspcon_work", as: FunctionType.LAPACKE_cspcon_work.self)
    #elseif os(macOS)
    static let cspcon_work: FunctionType.LAPACKE_cspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspcon_work: FunctionType.LAPACKE_zspcon_work? = load(name: "LAPACKE_zspcon_work", as: FunctionType.LAPACKE_zspcon_work.self)
    #elseif os(macOS)
    static let zspcon_work: FunctionType.LAPACKE_zspcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspev_work: FunctionType.LAPACKE_sspev_work? = load(name: "LAPACKE_sspev_work", as: FunctionType.LAPACKE_sspev_work.self)
    #elseif os(macOS)
    static let sspev_work: FunctionType.LAPACKE_sspev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspev_work: FunctionType.LAPACKE_dspev_work? = load(name: "LAPACKE_dspev_work", as: FunctionType.LAPACKE_dspev_work.self)
    #elseif os(macOS)
    static let dspev_work: FunctionType.LAPACKE_dspev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevd_work: FunctionType.LAPACKE_sspevd_work? = load(name: "LAPACKE_sspevd_work", as: FunctionType.LAPACKE_sspevd_work.self)
    #elseif os(macOS)
    static let sspevd_work: FunctionType.LAPACKE_sspevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevd_work: FunctionType.LAPACKE_dspevd_work? = load(name: "LAPACKE_dspevd_work", as: FunctionType.LAPACKE_dspevd_work.self)
    #elseif os(macOS)
    static let dspevd_work: FunctionType.LAPACKE_dspevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspevx_work: FunctionType.LAPACKE_sspevx_work? = load(name: "LAPACKE_sspevx_work", as: FunctionType.LAPACKE_sspevx_work.self)
    #elseif os(macOS)
    static let sspevx_work: FunctionType.LAPACKE_sspevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspevx_work: FunctionType.LAPACKE_dspevx_work? = load(name: "LAPACKE_dspevx_work", as: FunctionType.LAPACKE_dspevx_work.self)
    #elseif os(macOS)
    static let dspevx_work: FunctionType.LAPACKE_dspevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgst_work: FunctionType.LAPACKE_sspgst_work? = load(name: "LAPACKE_sspgst_work", as: FunctionType.LAPACKE_sspgst_work.self)
    #elseif os(macOS)
    static let sspgst_work: FunctionType.LAPACKE_sspgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgst_work: FunctionType.LAPACKE_dspgst_work? = load(name: "LAPACKE_dspgst_work", as: FunctionType.LAPACKE_dspgst_work.self)
    #elseif os(macOS)
    static let dspgst_work: FunctionType.LAPACKE_dspgst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgv_work: FunctionType.LAPACKE_sspgv_work? = load(name: "LAPACKE_sspgv_work", as: FunctionType.LAPACKE_sspgv_work.self)
    #elseif os(macOS)
    static let sspgv_work: FunctionType.LAPACKE_sspgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgv_work: FunctionType.LAPACKE_dspgv_work? = load(name: "LAPACKE_dspgv_work", as: FunctionType.LAPACKE_dspgv_work.self)
    #elseif os(macOS)
    static let dspgv_work: FunctionType.LAPACKE_dspgv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvd_work: FunctionType.LAPACKE_sspgvd_work? = load(name: "LAPACKE_sspgvd_work", as: FunctionType.LAPACKE_sspgvd_work.self)
    #elseif os(macOS)
    static let sspgvd_work: FunctionType.LAPACKE_sspgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvd_work: FunctionType.LAPACKE_dspgvd_work? = load(name: "LAPACKE_dspgvd_work", as: FunctionType.LAPACKE_dspgvd_work.self)
    #elseif os(macOS)
    static let dspgvd_work: FunctionType.LAPACKE_dspgvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspgvx_work: FunctionType.LAPACKE_sspgvx_work? = load(name: "LAPACKE_sspgvx_work", as: FunctionType.LAPACKE_sspgvx_work.self)
    #elseif os(macOS)
    static let sspgvx_work: FunctionType.LAPACKE_sspgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspgvx_work: FunctionType.LAPACKE_dspgvx_work? = load(name: "LAPACKE_dspgvx_work", as: FunctionType.LAPACKE_dspgvx_work.self)
    #elseif os(macOS)
    static let dspgvx_work: FunctionType.LAPACKE_dspgvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssprfs_work: FunctionType.LAPACKE_ssprfs_work? = load(name: "LAPACKE_ssprfs_work", as: FunctionType.LAPACKE_ssprfs_work.self)
    #elseif os(macOS)
    static let ssprfs_work: FunctionType.LAPACKE_ssprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsprfs_work: FunctionType.LAPACKE_dsprfs_work? = load(name: "LAPACKE_dsprfs_work", as: FunctionType.LAPACKE_dsprfs_work.self)
    #elseif os(macOS)
    static let dsprfs_work: FunctionType.LAPACKE_dsprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csprfs_work: FunctionType.LAPACKE_csprfs_work? = load(name: "LAPACKE_csprfs_work", as: FunctionType.LAPACKE_csprfs_work.self)
    #elseif os(macOS)
    static let csprfs_work: FunctionType.LAPACKE_csprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsprfs_work: FunctionType.LAPACKE_zsprfs_work? = load(name: "LAPACKE_zsprfs_work", as: FunctionType.LAPACKE_zsprfs_work.self)
    #elseif os(macOS)
    static let zsprfs_work: FunctionType.LAPACKE_zsprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsv_work: FunctionType.LAPACKE_sspsv_work? = load(name: "LAPACKE_sspsv_work", as: FunctionType.LAPACKE_sspsv_work.self)
    #elseif os(macOS)
    static let sspsv_work: FunctionType.LAPACKE_sspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsv_work: FunctionType.LAPACKE_dspsv_work? = load(name: "LAPACKE_dspsv_work", as: FunctionType.LAPACKE_dspsv_work.self)
    #elseif os(macOS)
    static let dspsv_work: FunctionType.LAPACKE_dspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsv_work: FunctionType.LAPACKE_cspsv_work? = load(name: "LAPACKE_cspsv_work", as: FunctionType.LAPACKE_cspsv_work.self)
    #elseif os(macOS)
    static let cspsv_work: FunctionType.LAPACKE_cspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsv_work: FunctionType.LAPACKE_zspsv_work? = load(name: "LAPACKE_zspsv_work", as: FunctionType.LAPACKE_zspsv_work.self)
    #elseif os(macOS)
    static let zspsv_work: FunctionType.LAPACKE_zspsv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sspsvx_work: FunctionType.LAPACKE_sspsvx_work? = load(name: "LAPACKE_sspsvx_work", as: FunctionType.LAPACKE_sspsvx_work.self)
    #elseif os(macOS)
    static let sspsvx_work: FunctionType.LAPACKE_sspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dspsvx_work: FunctionType.LAPACKE_dspsvx_work? = load(name: "LAPACKE_dspsvx_work", as: FunctionType.LAPACKE_dspsvx_work.self)
    #elseif os(macOS)
    static let dspsvx_work: FunctionType.LAPACKE_dspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cspsvx_work: FunctionType.LAPACKE_cspsvx_work? = load(name: "LAPACKE_cspsvx_work", as: FunctionType.LAPACKE_cspsvx_work.self)
    #elseif os(macOS)
    static let cspsvx_work: FunctionType.LAPACKE_cspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zspsvx_work: FunctionType.LAPACKE_zspsvx_work? = load(name: "LAPACKE_zspsvx_work", as: FunctionType.LAPACKE_zspsvx_work.self)
    #elseif os(macOS)
    static let zspsvx_work: FunctionType.LAPACKE_zspsvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrd_work: FunctionType.LAPACKE_ssptrd_work? = load(name: "LAPACKE_ssptrd_work", as: FunctionType.LAPACKE_ssptrd_work.self)
    #elseif os(macOS)
    static let ssptrd_work: FunctionType.LAPACKE_ssptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrd_work: FunctionType.LAPACKE_dsptrd_work? = load(name: "LAPACKE_dsptrd_work", as: FunctionType.LAPACKE_dsptrd_work.self)
    #elseif os(macOS)
    static let dsptrd_work: FunctionType.LAPACKE_dsptrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrf_work: FunctionType.LAPACKE_ssptrf_work? = load(name: "LAPACKE_ssptrf_work", as: FunctionType.LAPACKE_ssptrf_work.self)
    #elseif os(macOS)
    static let ssptrf_work: FunctionType.LAPACKE_ssptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrf_work: FunctionType.LAPACKE_dsptrf_work? = load(name: "LAPACKE_dsptrf_work", as: FunctionType.LAPACKE_dsptrf_work.self)
    #elseif os(macOS)
    static let dsptrf_work: FunctionType.LAPACKE_dsptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrf_work: FunctionType.LAPACKE_csptrf_work? = load(name: "LAPACKE_csptrf_work", as: FunctionType.LAPACKE_csptrf_work.self)
    #elseif os(macOS)
    static let csptrf_work: FunctionType.LAPACKE_csptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrf_work: FunctionType.LAPACKE_zsptrf_work? = load(name: "LAPACKE_zsptrf_work", as: FunctionType.LAPACKE_zsptrf_work.self)
    #elseif os(macOS)
    static let zsptrf_work: FunctionType.LAPACKE_zsptrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptri_work: FunctionType.LAPACKE_ssptri_work? = load(name: "LAPACKE_ssptri_work", as: FunctionType.LAPACKE_ssptri_work.self)
    #elseif os(macOS)
    static let ssptri_work: FunctionType.LAPACKE_ssptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptri_work: FunctionType.LAPACKE_dsptri_work? = load(name: "LAPACKE_dsptri_work", as: FunctionType.LAPACKE_dsptri_work.self)
    #elseif os(macOS)
    static let dsptri_work: FunctionType.LAPACKE_dsptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptri_work: FunctionType.LAPACKE_csptri_work? = load(name: "LAPACKE_csptri_work", as: FunctionType.LAPACKE_csptri_work.self)
    #elseif os(macOS)
    static let csptri_work: FunctionType.LAPACKE_csptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptri_work: FunctionType.LAPACKE_zsptri_work? = load(name: "LAPACKE_zsptri_work", as: FunctionType.LAPACKE_zsptri_work.self)
    #elseif os(macOS)
    static let zsptri_work: FunctionType.LAPACKE_zsptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssptrs_work: FunctionType.LAPACKE_ssptrs_work? = load(name: "LAPACKE_ssptrs_work", as: FunctionType.LAPACKE_ssptrs_work.self)
    #elseif os(macOS)
    static let ssptrs_work: FunctionType.LAPACKE_ssptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsptrs_work: FunctionType.LAPACKE_dsptrs_work? = load(name: "LAPACKE_dsptrs_work", as: FunctionType.LAPACKE_dsptrs_work.self)
    #elseif os(macOS)
    static let dsptrs_work: FunctionType.LAPACKE_dsptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csptrs_work: FunctionType.LAPACKE_csptrs_work? = load(name: "LAPACKE_csptrs_work", as: FunctionType.LAPACKE_csptrs_work.self)
    #elseif os(macOS)
    static let csptrs_work: FunctionType.LAPACKE_csptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsptrs_work: FunctionType.LAPACKE_zsptrs_work? = load(name: "LAPACKE_zsptrs_work", as: FunctionType.LAPACKE_zsptrs_work.self)
    #elseif os(macOS)
    static let zsptrs_work: FunctionType.LAPACKE_zsptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstebz_work: FunctionType.LAPACKE_sstebz_work? = load(name: "LAPACKE_sstebz_work", as: FunctionType.LAPACKE_sstebz_work.self)
    #elseif os(macOS)
    static let sstebz_work: FunctionType.LAPACKE_sstebz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstebz_work: FunctionType.LAPACKE_dstebz_work? = load(name: "LAPACKE_dstebz_work", as: FunctionType.LAPACKE_dstebz_work.self)
    #elseif os(macOS)
    static let dstebz_work: FunctionType.LAPACKE_dstebz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstedc_work: FunctionType.LAPACKE_sstedc_work? = load(name: "LAPACKE_sstedc_work", as: FunctionType.LAPACKE_sstedc_work.self)
    #elseif os(macOS)
    static let sstedc_work: FunctionType.LAPACKE_sstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstedc_work: FunctionType.LAPACKE_dstedc_work? = load(name: "LAPACKE_dstedc_work", as: FunctionType.LAPACKE_dstedc_work.self)
    #elseif os(macOS)
    static let dstedc_work: FunctionType.LAPACKE_dstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstedc_work: FunctionType.LAPACKE_cstedc_work? = load(name: "LAPACKE_cstedc_work", as: FunctionType.LAPACKE_cstedc_work.self)
    #elseif os(macOS)
    static let cstedc_work: FunctionType.LAPACKE_cstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstedc_work: FunctionType.LAPACKE_zstedc_work? = load(name: "LAPACKE_zstedc_work", as: FunctionType.LAPACKE_zstedc_work.self)
    #elseif os(macOS)
    static let zstedc_work: FunctionType.LAPACKE_zstedc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstegr_work: FunctionType.LAPACKE_sstegr_work? = load(name: "LAPACKE_sstegr_work", as: FunctionType.LAPACKE_sstegr_work.self)
    #elseif os(macOS)
    static let sstegr_work: FunctionType.LAPACKE_sstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstegr_work: FunctionType.LAPACKE_dstegr_work? = load(name: "LAPACKE_dstegr_work", as: FunctionType.LAPACKE_dstegr_work.self)
    #elseif os(macOS)
    static let dstegr_work: FunctionType.LAPACKE_dstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstegr_work: FunctionType.LAPACKE_cstegr_work? = load(name: "LAPACKE_cstegr_work", as: FunctionType.LAPACKE_cstegr_work.self)
    #elseif os(macOS)
    static let cstegr_work: FunctionType.LAPACKE_cstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstegr_work: FunctionType.LAPACKE_zstegr_work? = load(name: "LAPACKE_zstegr_work", as: FunctionType.LAPACKE_zstegr_work.self)
    #elseif os(macOS)
    static let zstegr_work: FunctionType.LAPACKE_zstegr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstein_work: FunctionType.LAPACKE_sstein_work? = load(name: "LAPACKE_sstein_work", as: FunctionType.LAPACKE_sstein_work.self)
    #elseif os(macOS)
    static let sstein_work: FunctionType.LAPACKE_sstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstein_work: FunctionType.LAPACKE_dstein_work? = load(name: "LAPACKE_dstein_work", as: FunctionType.LAPACKE_dstein_work.self)
    #elseif os(macOS)
    static let dstein_work: FunctionType.LAPACKE_dstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstein_work: FunctionType.LAPACKE_cstein_work? = load(name: "LAPACKE_cstein_work", as: FunctionType.LAPACKE_cstein_work.self)
    #elseif os(macOS)
    static let cstein_work: FunctionType.LAPACKE_cstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstein_work: FunctionType.LAPACKE_zstein_work? = load(name: "LAPACKE_zstein_work", as: FunctionType.LAPACKE_zstein_work.self)
    #elseif os(macOS)
    static let zstein_work: FunctionType.LAPACKE_zstein_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstemr_work: FunctionType.LAPACKE_sstemr_work? = load(name: "LAPACKE_sstemr_work", as: FunctionType.LAPACKE_sstemr_work.self)
    #elseif os(macOS)
    static let sstemr_work: FunctionType.LAPACKE_sstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstemr_work: FunctionType.LAPACKE_dstemr_work? = load(name: "LAPACKE_dstemr_work", as: FunctionType.LAPACKE_dstemr_work.self)
    #elseif os(macOS)
    static let dstemr_work: FunctionType.LAPACKE_dstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cstemr_work: FunctionType.LAPACKE_cstemr_work? = load(name: "LAPACKE_cstemr_work", as: FunctionType.LAPACKE_cstemr_work.self)
    #elseif os(macOS)
    static let cstemr_work: FunctionType.LAPACKE_cstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zstemr_work: FunctionType.LAPACKE_zstemr_work? = load(name: "LAPACKE_zstemr_work", as: FunctionType.LAPACKE_zstemr_work.self)
    #elseif os(macOS)
    static let zstemr_work: FunctionType.LAPACKE_zstemr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssteqr_work: FunctionType.LAPACKE_ssteqr_work? = load(name: "LAPACKE_ssteqr_work", as: FunctionType.LAPACKE_ssteqr_work.self)
    #elseif os(macOS)
    static let ssteqr_work: FunctionType.LAPACKE_ssteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsteqr_work: FunctionType.LAPACKE_dsteqr_work? = load(name: "LAPACKE_dsteqr_work", as: FunctionType.LAPACKE_dsteqr_work.self)
    #elseif os(macOS)
    static let dsteqr_work: FunctionType.LAPACKE_dsteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csteqr_work: FunctionType.LAPACKE_csteqr_work? = load(name: "LAPACKE_csteqr_work", as: FunctionType.LAPACKE_csteqr_work.self)
    #elseif os(macOS)
    static let csteqr_work: FunctionType.LAPACKE_csteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsteqr_work: FunctionType.LAPACKE_zsteqr_work? = load(name: "LAPACKE_zsteqr_work", as: FunctionType.LAPACKE_zsteqr_work.self)
    #elseif os(macOS)
    static let zsteqr_work: FunctionType.LAPACKE_zsteqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssterf_work: FunctionType.LAPACKE_ssterf_work? = load(name: "LAPACKE_ssterf_work", as: FunctionType.LAPACKE_ssterf_work.self)
    #elseif os(macOS)
    static let ssterf_work: FunctionType.LAPACKE_ssterf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsterf_work: FunctionType.LAPACKE_dsterf_work? = load(name: "LAPACKE_dsterf_work", as: FunctionType.LAPACKE_dsterf_work.self)
    #elseif os(macOS)
    static let dsterf_work: FunctionType.LAPACKE_dsterf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstev_work: FunctionType.LAPACKE_sstev_work? = load(name: "LAPACKE_sstev_work", as: FunctionType.LAPACKE_sstev_work.self)
    #elseif os(macOS)
    static let sstev_work: FunctionType.LAPACKE_sstev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstev_work: FunctionType.LAPACKE_dstev_work? = load(name: "LAPACKE_dstev_work", as: FunctionType.LAPACKE_dstev_work.self)
    #elseif os(macOS)
    static let dstev_work: FunctionType.LAPACKE_dstev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevd_work: FunctionType.LAPACKE_sstevd_work? = load(name: "LAPACKE_sstevd_work", as: FunctionType.LAPACKE_sstevd_work.self)
    #elseif os(macOS)
    static let sstevd_work: FunctionType.LAPACKE_sstevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevd_work: FunctionType.LAPACKE_dstevd_work? = load(name: "LAPACKE_dstevd_work", as: FunctionType.LAPACKE_dstevd_work.self)
    #elseif os(macOS)
    static let dstevd_work: FunctionType.LAPACKE_dstevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevr_work: FunctionType.LAPACKE_sstevr_work? = load(name: "LAPACKE_sstevr_work", as: FunctionType.LAPACKE_sstevr_work.self)
    #elseif os(macOS)
    static let sstevr_work: FunctionType.LAPACKE_sstevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevr_work: FunctionType.LAPACKE_dstevr_work? = load(name: "LAPACKE_dstevr_work", as: FunctionType.LAPACKE_dstevr_work.self)
    #elseif os(macOS)
    static let dstevr_work: FunctionType.LAPACKE_dstevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sstevx_work: FunctionType.LAPACKE_sstevx_work? = load(name: "LAPACKE_sstevx_work", as: FunctionType.LAPACKE_sstevx_work.self)
    #elseif os(macOS)
    static let sstevx_work: FunctionType.LAPACKE_sstevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dstevx_work: FunctionType.LAPACKE_dstevx_work? = load(name: "LAPACKE_dstevx_work", as: FunctionType.LAPACKE_dstevx_work.self)
    #elseif os(macOS)
    static let dstevx_work: FunctionType.LAPACKE_dstevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon_work: FunctionType.LAPACKE_ssycon_work? = load(name: "LAPACKE_ssycon_work", as: FunctionType.LAPACKE_ssycon_work.self)
    #elseif os(macOS)
    static let ssycon_work: FunctionType.LAPACKE_ssycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon_work: FunctionType.LAPACKE_dsycon_work? = load(name: "LAPACKE_dsycon_work", as: FunctionType.LAPACKE_dsycon_work.self)
    #elseif os(macOS)
    static let dsycon_work: FunctionType.LAPACKE_dsycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon_work: FunctionType.LAPACKE_csycon_work? = load(name: "LAPACKE_csycon_work", as: FunctionType.LAPACKE_csycon_work.self)
    #elseif os(macOS)
    static let csycon_work: FunctionType.LAPACKE_csycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon_work: FunctionType.LAPACKE_zsycon_work? = load(name: "LAPACKE_zsycon_work", as: FunctionType.LAPACKE_zsycon_work.self)
    #elseif os(macOS)
    static let zsycon_work: FunctionType.LAPACKE_zsycon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyequb_work: FunctionType.LAPACKE_ssyequb_work? = load(name: "LAPACKE_ssyequb_work", as: FunctionType.LAPACKE_ssyequb_work.self)
    #elseif os(macOS)
    static let ssyequb_work: FunctionType.LAPACKE_ssyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyequb_work: FunctionType.LAPACKE_dsyequb_work? = load(name: "LAPACKE_dsyequb_work", as: FunctionType.LAPACKE_dsyequb_work.self)
    #elseif os(macOS)
    static let dsyequb_work: FunctionType.LAPACKE_dsyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyequb_work: FunctionType.LAPACKE_csyequb_work? = load(name: "LAPACKE_csyequb_work", as: FunctionType.LAPACKE_csyequb_work.self)
    #elseif os(macOS)
    static let csyequb_work: FunctionType.LAPACKE_csyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyequb_work: FunctionType.LAPACKE_zsyequb_work? = load(name: "LAPACKE_zsyequb_work", as: FunctionType.LAPACKE_zsyequb_work.self)
    #elseif os(macOS)
    static let zsyequb_work: FunctionType.LAPACKE_zsyequb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev_work: FunctionType.LAPACKE_ssyev_work? = load(name: "LAPACKE_ssyev_work", as: FunctionType.LAPACKE_ssyev_work.self)
    #elseif os(macOS)
    static let ssyev_work: FunctionType.LAPACKE_ssyev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev_work: FunctionType.LAPACKE_dsyev_work? = load(name: "LAPACKE_dsyev_work", as: FunctionType.LAPACKE_dsyev_work.self)
    #elseif os(macOS)
    static let dsyev_work: FunctionType.LAPACKE_dsyev_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd_work: FunctionType.LAPACKE_ssyevd_work? = load(name: "LAPACKE_ssyevd_work", as: FunctionType.LAPACKE_ssyevd_work.self)
    #elseif os(macOS)
    static let ssyevd_work: FunctionType.LAPACKE_ssyevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd_work: FunctionType.LAPACKE_dsyevd_work? = load(name: "LAPACKE_dsyevd_work", as: FunctionType.LAPACKE_dsyevd_work.self)
    #elseif os(macOS)
    static let dsyevd_work: FunctionType.LAPACKE_dsyevd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr_work: FunctionType.LAPACKE_ssyevr_work? = load(name: "LAPACKE_ssyevr_work", as: FunctionType.LAPACKE_ssyevr_work.self)
    #elseif os(macOS)
    static let ssyevr_work: FunctionType.LAPACKE_ssyevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr_work: FunctionType.LAPACKE_dsyevr_work? = load(name: "LAPACKE_dsyevr_work", as: FunctionType.LAPACKE_dsyevr_work.self)
    #elseif os(macOS)
    static let dsyevr_work: FunctionType.LAPACKE_dsyevr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx_work: FunctionType.LAPACKE_ssyevx_work? = load(name: "LAPACKE_ssyevx_work", as: FunctionType.LAPACKE_ssyevx_work.self)
    #elseif os(macOS)
    static let ssyevx_work: FunctionType.LAPACKE_ssyevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx_work: FunctionType.LAPACKE_dsyevx_work? = load(name: "LAPACKE_dsyevx_work", as: FunctionType.LAPACKE_dsyevx_work.self)
    #elseif os(macOS)
    static let dsyevx_work: FunctionType.LAPACKE_dsyevx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygst_work: FunctionType.LAPACKE_ssygst_work? = load(name: "LAPACKE_ssygst_work", as: FunctionType.LAPACKE_ssygst_work.self)
    #elseif os(macOS)
    static let ssygst_work: FunctionType.LAPACKE_ssygst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygst_work: FunctionType.LAPACKE_dsygst_work? = load(name: "LAPACKE_dsygst_work", as: FunctionType.LAPACKE_dsygst_work.self)
    #elseif os(macOS)
    static let dsygst_work: FunctionType.LAPACKE_dsygst_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv_work: FunctionType.LAPACKE_ssygv_work? = load(name: "LAPACKE_ssygv_work", as: FunctionType.LAPACKE_ssygv_work.self)
    #elseif os(macOS)
    static let ssygv_work: FunctionType.LAPACKE_ssygv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv_work: FunctionType.LAPACKE_dsygv_work? = load(name: "LAPACKE_dsygv_work", as: FunctionType.LAPACKE_dsygv_work.self)
    #elseif os(macOS)
    static let dsygv_work: FunctionType.LAPACKE_dsygv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvd_work: FunctionType.LAPACKE_ssygvd_work? = load(name: "LAPACKE_ssygvd_work", as: FunctionType.LAPACKE_ssygvd_work.self)
    #elseif os(macOS)
    static let ssygvd_work: FunctionType.LAPACKE_ssygvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvd_work: FunctionType.LAPACKE_dsygvd_work? = load(name: "LAPACKE_dsygvd_work", as: FunctionType.LAPACKE_dsygvd_work.self)
    #elseif os(macOS)
    static let dsygvd_work: FunctionType.LAPACKE_dsygvd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygvx_work: FunctionType.LAPACKE_ssygvx_work? = load(name: "LAPACKE_ssygvx_work", as: FunctionType.LAPACKE_ssygvx_work.self)
    #elseif os(macOS)
    static let ssygvx_work: FunctionType.LAPACKE_ssygvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygvx_work: FunctionType.LAPACKE_dsygvx_work? = load(name: "LAPACKE_dsygvx_work", as: FunctionType.LAPACKE_dsygvx_work.self)
    #elseif os(macOS)
    static let dsygvx_work: FunctionType.LAPACKE_dsygvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfs_work: FunctionType.LAPACKE_ssyrfs_work? = load(name: "LAPACKE_ssyrfs_work", as: FunctionType.LAPACKE_ssyrfs_work.self)
    #elseif os(macOS)
    static let ssyrfs_work: FunctionType.LAPACKE_ssyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfs_work: FunctionType.LAPACKE_dsyrfs_work? = load(name: "LAPACKE_dsyrfs_work", as: FunctionType.LAPACKE_dsyrfs_work.self)
    #elseif os(macOS)
    static let dsyrfs_work: FunctionType.LAPACKE_dsyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfs_work: FunctionType.LAPACKE_csyrfs_work? = load(name: "LAPACKE_csyrfs_work", as: FunctionType.LAPACKE_csyrfs_work.self)
    #elseif os(macOS)
    static let csyrfs_work: FunctionType.LAPACKE_csyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfs_work: FunctionType.LAPACKE_zsyrfs_work? = load(name: "LAPACKE_zsyrfs_work", as: FunctionType.LAPACKE_zsyrfs_work.self)
    #elseif os(macOS)
    static let zsyrfs_work: FunctionType.LAPACKE_zsyrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyrfsx_work: FunctionType.LAPACKE_ssyrfsx_work? = load(name: "LAPACKE_ssyrfsx_work", as: FunctionType.LAPACKE_ssyrfsx_work.self)
    #elseif os(macOS)
    static let ssyrfsx_work: FunctionType.LAPACKE_ssyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyrfsx_work: FunctionType.LAPACKE_dsyrfsx_work? = load(name: "LAPACKE_dsyrfsx_work", as: FunctionType.LAPACKE_dsyrfsx_work.self)
    #elseif os(macOS)
    static let dsyrfsx_work: FunctionType.LAPACKE_dsyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyrfsx_work: FunctionType.LAPACKE_csyrfsx_work? = load(name: "LAPACKE_csyrfsx_work", as: FunctionType.LAPACKE_csyrfsx_work.self)
    #elseif os(macOS)
    static let csyrfsx_work: FunctionType.LAPACKE_csyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyrfsx_work: FunctionType.LAPACKE_zsyrfsx_work? = load(name: "LAPACKE_zsyrfsx_work", as: FunctionType.LAPACKE_zsyrfsx_work.self)
    #elseif os(macOS)
    static let zsyrfsx_work: FunctionType.LAPACKE_zsyrfsx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_work: FunctionType.LAPACKE_ssysv_work? = load(name: "LAPACKE_ssysv_work", as: FunctionType.LAPACKE_ssysv_work.self)
    #elseif os(macOS)
    static let ssysv_work: FunctionType.LAPACKE_ssysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_work: FunctionType.LAPACKE_dsysv_work? = load(name: "LAPACKE_dsysv_work", as: FunctionType.LAPACKE_dsysv_work.self)
    #elseif os(macOS)
    static let dsysv_work: FunctionType.LAPACKE_dsysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_work: FunctionType.LAPACKE_csysv_work? = load(name: "LAPACKE_csysv_work", as: FunctionType.LAPACKE_csysv_work.self)
    #elseif os(macOS)
    static let csysv_work: FunctionType.LAPACKE_csysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_work: FunctionType.LAPACKE_zsysv_work? = load(name: "LAPACKE_zsysv_work", as: FunctionType.LAPACKE_zsysv_work.self)
    #elseif os(macOS)
    static let zsysv_work: FunctionType.LAPACKE_zsysv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvx_work: FunctionType.LAPACKE_ssysvx_work? = load(name: "LAPACKE_ssysvx_work", as: FunctionType.LAPACKE_ssysvx_work.self)
    #elseif os(macOS)
    static let ssysvx_work: FunctionType.LAPACKE_ssysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvx_work: FunctionType.LAPACKE_dsysvx_work? = load(name: "LAPACKE_dsysvx_work", as: FunctionType.LAPACKE_dsysvx_work.self)
    #elseif os(macOS)
    static let dsysvx_work: FunctionType.LAPACKE_dsysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvx_work: FunctionType.LAPACKE_csysvx_work? = load(name: "LAPACKE_csysvx_work", as: FunctionType.LAPACKE_csysvx_work.self)
    #elseif os(macOS)
    static let csysvx_work: FunctionType.LAPACKE_csysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvx_work: FunctionType.LAPACKE_zsysvx_work? = load(name: "LAPACKE_zsysvx_work", as: FunctionType.LAPACKE_zsysvx_work.self)
    #elseif os(macOS)
    static let zsysvx_work: FunctionType.LAPACKE_zsysvx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysvxx_work: FunctionType.LAPACKE_ssysvxx_work? = load(name: "LAPACKE_ssysvxx_work", as: FunctionType.LAPACKE_ssysvxx_work.self)
    #elseif os(macOS)
    static let ssysvxx_work: FunctionType.LAPACKE_ssysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysvxx_work: FunctionType.LAPACKE_dsysvxx_work? = load(name: "LAPACKE_dsysvxx_work", as: FunctionType.LAPACKE_dsysvxx_work.self)
    #elseif os(macOS)
    static let dsysvxx_work: FunctionType.LAPACKE_dsysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysvxx_work: FunctionType.LAPACKE_csysvxx_work? = load(name: "LAPACKE_csysvxx_work", as: FunctionType.LAPACKE_csysvxx_work.self)
    #elseif os(macOS)
    static let csysvxx_work: FunctionType.LAPACKE_csysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysvxx_work: FunctionType.LAPACKE_zsysvxx_work? = load(name: "LAPACKE_zsysvxx_work", as: FunctionType.LAPACKE_zsysvxx_work.self)
    #elseif os(macOS)
    static let zsysvxx_work: FunctionType.LAPACKE_zsysvxx_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrd_work: FunctionType.LAPACKE_ssytrd_work? = load(name: "LAPACKE_ssytrd_work", as: FunctionType.LAPACKE_ssytrd_work.self)
    #elseif os(macOS)
    static let ssytrd_work: FunctionType.LAPACKE_ssytrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrd_work: FunctionType.LAPACKE_dsytrd_work? = load(name: "LAPACKE_dsytrd_work", as: FunctionType.LAPACKE_dsytrd_work.self)
    #elseif os(macOS)
    static let dsytrd_work: FunctionType.LAPACKE_dsytrd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_work: FunctionType.LAPACKE_ssytrf_work? = load(name: "LAPACKE_ssytrf_work", as: FunctionType.LAPACKE_ssytrf_work.self)
    #elseif os(macOS)
    static let ssytrf_work: FunctionType.LAPACKE_ssytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_work: FunctionType.LAPACKE_dsytrf_work? = load(name: "LAPACKE_dsytrf_work", as: FunctionType.LAPACKE_dsytrf_work.self)
    #elseif os(macOS)
    static let dsytrf_work: FunctionType.LAPACKE_dsytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_work: FunctionType.LAPACKE_csytrf_work? = load(name: "LAPACKE_csytrf_work", as: FunctionType.LAPACKE_csytrf_work.self)
    #elseif os(macOS)
    static let csytrf_work: FunctionType.LAPACKE_csytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_work: FunctionType.LAPACKE_zsytrf_work? = load(name: "LAPACKE_zsytrf_work", as: FunctionType.LAPACKE_zsytrf_work.self)
    #elseif os(macOS)
    static let zsytrf_work: FunctionType.LAPACKE_zsytrf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri_work: FunctionType.LAPACKE_ssytri_work? = load(name: "LAPACKE_ssytri_work", as: FunctionType.LAPACKE_ssytri_work.self)
    #elseif os(macOS)
    static let ssytri_work: FunctionType.LAPACKE_ssytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri_work: FunctionType.LAPACKE_dsytri_work? = load(name: "LAPACKE_dsytri_work", as: FunctionType.LAPACKE_dsytri_work.self)
    #elseif os(macOS)
    static let dsytri_work: FunctionType.LAPACKE_dsytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri_work: FunctionType.LAPACKE_csytri_work? = load(name: "LAPACKE_csytri_work", as: FunctionType.LAPACKE_csytri_work.self)
    #elseif os(macOS)
    static let csytri_work: FunctionType.LAPACKE_csytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri_work: FunctionType.LAPACKE_zsytri_work? = load(name: "LAPACKE_zsytri_work", as: FunctionType.LAPACKE_zsytri_work.self)
    #elseif os(macOS)
    static let zsytri_work: FunctionType.LAPACKE_zsytri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_work: FunctionType.LAPACKE_ssytrs_work? = load(name: "LAPACKE_ssytrs_work", as: FunctionType.LAPACKE_ssytrs_work.self)
    #elseif os(macOS)
    static let ssytrs_work: FunctionType.LAPACKE_ssytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_work: FunctionType.LAPACKE_dsytrs_work? = load(name: "LAPACKE_dsytrs_work", as: FunctionType.LAPACKE_dsytrs_work.self)
    #elseif os(macOS)
    static let dsytrs_work: FunctionType.LAPACKE_dsytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_work: FunctionType.LAPACKE_csytrs_work? = load(name: "LAPACKE_csytrs_work", as: FunctionType.LAPACKE_csytrs_work.self)
    #elseif os(macOS)
    static let csytrs_work: FunctionType.LAPACKE_csytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_work: FunctionType.LAPACKE_zsytrs_work? = load(name: "LAPACKE_zsytrs_work", as: FunctionType.LAPACKE_zsytrs_work.self)
    #elseif os(macOS)
    static let zsytrs_work: FunctionType.LAPACKE_zsytrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbcon_work: FunctionType.LAPACKE_stbcon_work? = load(name: "LAPACKE_stbcon_work", as: FunctionType.LAPACKE_stbcon_work.self)
    #elseif os(macOS)
    static let stbcon_work: FunctionType.LAPACKE_stbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbcon_work: FunctionType.LAPACKE_dtbcon_work? = load(name: "LAPACKE_dtbcon_work", as: FunctionType.LAPACKE_dtbcon_work.self)
    #elseif os(macOS)
    static let dtbcon_work: FunctionType.LAPACKE_dtbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbcon_work: FunctionType.LAPACKE_ctbcon_work? = load(name: "LAPACKE_ctbcon_work", as: FunctionType.LAPACKE_ctbcon_work.self)
    #elseif os(macOS)
    static let ctbcon_work: FunctionType.LAPACKE_ctbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbcon_work: FunctionType.LAPACKE_ztbcon_work? = load(name: "LAPACKE_ztbcon_work", as: FunctionType.LAPACKE_ztbcon_work.self)
    #elseif os(macOS)
    static let ztbcon_work: FunctionType.LAPACKE_ztbcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbrfs_work: FunctionType.LAPACKE_stbrfs_work? = load(name: "LAPACKE_stbrfs_work", as: FunctionType.LAPACKE_stbrfs_work.self)
    #elseif os(macOS)
    static let stbrfs_work: FunctionType.LAPACKE_stbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbrfs_work: FunctionType.LAPACKE_dtbrfs_work? = load(name: "LAPACKE_dtbrfs_work", as: FunctionType.LAPACKE_dtbrfs_work.self)
    #elseif os(macOS)
    static let dtbrfs_work: FunctionType.LAPACKE_dtbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbrfs_work: FunctionType.LAPACKE_ctbrfs_work? = load(name: "LAPACKE_ctbrfs_work", as: FunctionType.LAPACKE_ctbrfs_work.self)
    #elseif os(macOS)
    static let ctbrfs_work: FunctionType.LAPACKE_ctbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbrfs_work: FunctionType.LAPACKE_ztbrfs_work? = load(name: "LAPACKE_ztbrfs_work", as: FunctionType.LAPACKE_ztbrfs_work.self)
    #elseif os(macOS)
    static let ztbrfs_work: FunctionType.LAPACKE_ztbrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stbtrs_work: FunctionType.LAPACKE_stbtrs_work? = load(name: "LAPACKE_stbtrs_work", as: FunctionType.LAPACKE_stbtrs_work.self)
    #elseif os(macOS)
    static let stbtrs_work: FunctionType.LAPACKE_stbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtbtrs_work: FunctionType.LAPACKE_dtbtrs_work? = load(name: "LAPACKE_dtbtrs_work", as: FunctionType.LAPACKE_dtbtrs_work.self)
    #elseif os(macOS)
    static let dtbtrs_work: FunctionType.LAPACKE_dtbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctbtrs_work: FunctionType.LAPACKE_ctbtrs_work? = load(name: "LAPACKE_ctbtrs_work", as: FunctionType.LAPACKE_ctbtrs_work.self)
    #elseif os(macOS)
    static let ctbtrs_work: FunctionType.LAPACKE_ctbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztbtrs_work: FunctionType.LAPACKE_ztbtrs_work? = load(name: "LAPACKE_ztbtrs_work", as: FunctionType.LAPACKE_ztbtrs_work.self)
    #elseif os(macOS)
    static let ztbtrs_work: FunctionType.LAPACKE_ztbtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfsm_work: FunctionType.LAPACKE_stfsm_work? = load(name: "LAPACKE_stfsm_work", as: FunctionType.LAPACKE_stfsm_work.self)
    #elseif os(macOS)
    static let stfsm_work: FunctionType.LAPACKE_stfsm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfsm_work: FunctionType.LAPACKE_dtfsm_work? = load(name: "LAPACKE_dtfsm_work", as: FunctionType.LAPACKE_dtfsm_work.self)
    #elseif os(macOS)
    static let dtfsm_work: FunctionType.LAPACKE_dtfsm_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stftri_work: FunctionType.LAPACKE_stftri_work? = load(name: "LAPACKE_stftri_work", as: FunctionType.LAPACKE_stftri_work.self)
    #elseif os(macOS)
    static let stftri_work: FunctionType.LAPACKE_stftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtftri_work: FunctionType.LAPACKE_dtftri_work? = load(name: "LAPACKE_dtftri_work", as: FunctionType.LAPACKE_dtftri_work.self)
    #elseif os(macOS)
    static let dtftri_work: FunctionType.LAPACKE_dtftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctftri_work: FunctionType.LAPACKE_ctftri_work? = load(name: "LAPACKE_ctftri_work", as: FunctionType.LAPACKE_ctftri_work.self)
    #elseif os(macOS)
    static let ctftri_work: FunctionType.LAPACKE_ctftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztftri_work: FunctionType.LAPACKE_ztftri_work? = load(name: "LAPACKE_ztftri_work", as: FunctionType.LAPACKE_ztftri_work.self)
    #elseif os(macOS)
    static let ztftri_work: FunctionType.LAPACKE_ztftri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttp_work: FunctionType.LAPACKE_stfttp_work? = load(name: "LAPACKE_stfttp_work", as: FunctionType.LAPACKE_stfttp_work.self)
    #elseif os(macOS)
    static let stfttp_work: FunctionType.LAPACKE_stfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttp_work: FunctionType.LAPACKE_dtfttp_work? = load(name: "LAPACKE_dtfttp_work", as: FunctionType.LAPACKE_dtfttp_work.self)
    #elseif os(macOS)
    static let dtfttp_work: FunctionType.LAPACKE_dtfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttp_work: FunctionType.LAPACKE_ctfttp_work? = load(name: "LAPACKE_ctfttp_work", as: FunctionType.LAPACKE_ctfttp_work.self)
    #elseif os(macOS)
    static let ctfttp_work: FunctionType.LAPACKE_ctfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttp_work: FunctionType.LAPACKE_ztfttp_work? = load(name: "LAPACKE_ztfttp_work", as: FunctionType.LAPACKE_ztfttp_work.self)
    #elseif os(macOS)
    static let ztfttp_work: FunctionType.LAPACKE_ztfttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stfttr_work: FunctionType.LAPACKE_stfttr_work? = load(name: "LAPACKE_stfttr_work", as: FunctionType.LAPACKE_stfttr_work.self)
    #elseif os(macOS)
    static let stfttr_work: FunctionType.LAPACKE_stfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtfttr_work: FunctionType.LAPACKE_dtfttr_work? = load(name: "LAPACKE_dtfttr_work", as: FunctionType.LAPACKE_dtfttr_work.self)
    #elseif os(macOS)
    static let dtfttr_work: FunctionType.LAPACKE_dtfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctfttr_work: FunctionType.LAPACKE_ctfttr_work? = load(name: "LAPACKE_ctfttr_work", as: FunctionType.LAPACKE_ctfttr_work.self)
    #elseif os(macOS)
    static let ctfttr_work: FunctionType.LAPACKE_ctfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztfttr_work: FunctionType.LAPACKE_ztfttr_work? = load(name: "LAPACKE_ztfttr_work", as: FunctionType.LAPACKE_ztfttr_work.self)
    #elseif os(macOS)
    static let ztfttr_work: FunctionType.LAPACKE_ztfttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgevc_work: FunctionType.LAPACKE_stgevc_work? = load(name: "LAPACKE_stgevc_work", as: FunctionType.LAPACKE_stgevc_work.self)
    #elseif os(macOS)
    static let stgevc_work: FunctionType.LAPACKE_stgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgevc_work: FunctionType.LAPACKE_dtgevc_work? = load(name: "LAPACKE_dtgevc_work", as: FunctionType.LAPACKE_dtgevc_work.self)
    #elseif os(macOS)
    static let dtgevc_work: FunctionType.LAPACKE_dtgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgevc_work: FunctionType.LAPACKE_ctgevc_work? = load(name: "LAPACKE_ctgevc_work", as: FunctionType.LAPACKE_ctgevc_work.self)
    #elseif os(macOS)
    static let ctgevc_work: FunctionType.LAPACKE_ctgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgevc_work: FunctionType.LAPACKE_ztgevc_work? = load(name: "LAPACKE_ztgevc_work", as: FunctionType.LAPACKE_ztgevc_work.self)
    #elseif os(macOS)
    static let ztgevc_work: FunctionType.LAPACKE_ztgevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgexc_work: FunctionType.LAPACKE_stgexc_work? = load(name: "LAPACKE_stgexc_work", as: FunctionType.LAPACKE_stgexc_work.self)
    #elseif os(macOS)
    static let stgexc_work: FunctionType.LAPACKE_stgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgexc_work: FunctionType.LAPACKE_dtgexc_work? = load(name: "LAPACKE_dtgexc_work", as: FunctionType.LAPACKE_dtgexc_work.self)
    #elseif os(macOS)
    static let dtgexc_work: FunctionType.LAPACKE_dtgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgexc_work: FunctionType.LAPACKE_ctgexc_work? = load(name: "LAPACKE_ctgexc_work", as: FunctionType.LAPACKE_ctgexc_work.self)
    #elseif os(macOS)
    static let ctgexc_work: FunctionType.LAPACKE_ctgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgexc_work: FunctionType.LAPACKE_ztgexc_work? = load(name: "LAPACKE_ztgexc_work", as: FunctionType.LAPACKE_ztgexc_work.self)
    #elseif os(macOS)
    static let ztgexc_work: FunctionType.LAPACKE_ztgexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsen_work: FunctionType.LAPACKE_stgsen_work? = load(name: "LAPACKE_stgsen_work", as: FunctionType.LAPACKE_stgsen_work.self)
    #elseif os(macOS)
    static let stgsen_work: FunctionType.LAPACKE_stgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsen_work: FunctionType.LAPACKE_dtgsen_work? = load(name: "LAPACKE_dtgsen_work", as: FunctionType.LAPACKE_dtgsen_work.self)
    #elseif os(macOS)
    static let dtgsen_work: FunctionType.LAPACKE_dtgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsen_work: FunctionType.LAPACKE_ctgsen_work? = load(name: "LAPACKE_ctgsen_work", as: FunctionType.LAPACKE_ctgsen_work.self)
    #elseif os(macOS)
    static let ctgsen_work: FunctionType.LAPACKE_ctgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsen_work: FunctionType.LAPACKE_ztgsen_work? = load(name: "LAPACKE_ztgsen_work", as: FunctionType.LAPACKE_ztgsen_work.self)
    #elseif os(macOS)
    static let ztgsen_work: FunctionType.LAPACKE_ztgsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsja_work: FunctionType.LAPACKE_stgsja_work? = load(name: "LAPACKE_stgsja_work", as: FunctionType.LAPACKE_stgsja_work.self)
    #elseif os(macOS)
    static let stgsja_work: FunctionType.LAPACKE_stgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsja_work: FunctionType.LAPACKE_dtgsja_work? = load(name: "LAPACKE_dtgsja_work", as: FunctionType.LAPACKE_dtgsja_work.self)
    #elseif os(macOS)
    static let dtgsja_work: FunctionType.LAPACKE_dtgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsja_work: FunctionType.LAPACKE_ctgsja_work? = load(name: "LAPACKE_ctgsja_work", as: FunctionType.LAPACKE_ctgsja_work.self)
    #elseif os(macOS)
    static let ctgsja_work: FunctionType.LAPACKE_ctgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsja_work: FunctionType.LAPACKE_ztgsja_work? = load(name: "LAPACKE_ztgsja_work", as: FunctionType.LAPACKE_ztgsja_work.self)
    #elseif os(macOS)
    static let ztgsja_work: FunctionType.LAPACKE_ztgsja_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsna_work: FunctionType.LAPACKE_stgsna_work? = load(name: "LAPACKE_stgsna_work", as: FunctionType.LAPACKE_stgsna_work.self)
    #elseif os(macOS)
    static let stgsna_work: FunctionType.LAPACKE_stgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsna_work: FunctionType.LAPACKE_dtgsna_work? = load(name: "LAPACKE_dtgsna_work", as: FunctionType.LAPACKE_dtgsna_work.self)
    #elseif os(macOS)
    static let dtgsna_work: FunctionType.LAPACKE_dtgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsna_work: FunctionType.LAPACKE_ctgsna_work? = load(name: "LAPACKE_ctgsna_work", as: FunctionType.LAPACKE_ctgsna_work.self)
    #elseif os(macOS)
    static let ctgsna_work: FunctionType.LAPACKE_ctgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsna_work: FunctionType.LAPACKE_ztgsna_work? = load(name: "LAPACKE_ztgsna_work", as: FunctionType.LAPACKE_ztgsna_work.self)
    #elseif os(macOS)
    static let ztgsna_work: FunctionType.LAPACKE_ztgsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stgsyl_work: FunctionType.LAPACKE_stgsyl_work? = load(name: "LAPACKE_stgsyl_work", as: FunctionType.LAPACKE_stgsyl_work.self)
    #elseif os(macOS)
    static let stgsyl_work: FunctionType.LAPACKE_stgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtgsyl_work: FunctionType.LAPACKE_dtgsyl_work? = load(name: "LAPACKE_dtgsyl_work", as: FunctionType.LAPACKE_dtgsyl_work.self)
    #elseif os(macOS)
    static let dtgsyl_work: FunctionType.LAPACKE_dtgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctgsyl_work: FunctionType.LAPACKE_ctgsyl_work? = load(name: "LAPACKE_ctgsyl_work", as: FunctionType.LAPACKE_ctgsyl_work.self)
    #elseif os(macOS)
    static let ctgsyl_work: FunctionType.LAPACKE_ctgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztgsyl_work: FunctionType.LAPACKE_ztgsyl_work? = load(name: "LAPACKE_ztgsyl_work", as: FunctionType.LAPACKE_ztgsyl_work.self)
    #elseif os(macOS)
    static let ztgsyl_work: FunctionType.LAPACKE_ztgsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpcon_work: FunctionType.LAPACKE_stpcon_work? = load(name: "LAPACKE_stpcon_work", as: FunctionType.LAPACKE_stpcon_work.self)
    #elseif os(macOS)
    static let stpcon_work: FunctionType.LAPACKE_stpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpcon_work: FunctionType.LAPACKE_dtpcon_work? = load(name: "LAPACKE_dtpcon_work", as: FunctionType.LAPACKE_dtpcon_work.self)
    #elseif os(macOS)
    static let dtpcon_work: FunctionType.LAPACKE_dtpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpcon_work: FunctionType.LAPACKE_ctpcon_work? = load(name: "LAPACKE_ctpcon_work", as: FunctionType.LAPACKE_ctpcon_work.self)
    #elseif os(macOS)
    static let ctpcon_work: FunctionType.LAPACKE_ctpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpcon_work: FunctionType.LAPACKE_ztpcon_work? = load(name: "LAPACKE_ztpcon_work", as: FunctionType.LAPACKE_ztpcon_work.self)
    #elseif os(macOS)
    static let ztpcon_work: FunctionType.LAPACKE_ztpcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfs_work: FunctionType.LAPACKE_stprfs_work? = load(name: "LAPACKE_stprfs_work", as: FunctionType.LAPACKE_stprfs_work.self)
    #elseif os(macOS)
    static let stprfs_work: FunctionType.LAPACKE_stprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfs_work: FunctionType.LAPACKE_dtprfs_work? = load(name: "LAPACKE_dtprfs_work", as: FunctionType.LAPACKE_dtprfs_work.self)
    #elseif os(macOS)
    static let dtprfs_work: FunctionType.LAPACKE_dtprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfs_work: FunctionType.LAPACKE_ctprfs_work? = load(name: "LAPACKE_ctprfs_work", as: FunctionType.LAPACKE_ctprfs_work.self)
    #elseif os(macOS)
    static let ctprfs_work: FunctionType.LAPACKE_ctprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfs_work: FunctionType.LAPACKE_ztprfs_work? = load(name: "LAPACKE_ztprfs_work", as: FunctionType.LAPACKE_ztprfs_work.self)
    #elseif os(macOS)
    static let ztprfs_work: FunctionType.LAPACKE_ztprfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptri_work: FunctionType.LAPACKE_stptri_work? = load(name: "LAPACKE_stptri_work", as: FunctionType.LAPACKE_stptri_work.self)
    #elseif os(macOS)
    static let stptri_work: FunctionType.LAPACKE_stptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptri_work: FunctionType.LAPACKE_dtptri_work? = load(name: "LAPACKE_dtptri_work", as: FunctionType.LAPACKE_dtptri_work.self)
    #elseif os(macOS)
    static let dtptri_work: FunctionType.LAPACKE_dtptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptri_work: FunctionType.LAPACKE_ctptri_work? = load(name: "LAPACKE_ctptri_work", as: FunctionType.LAPACKE_ctptri_work.self)
    #elseif os(macOS)
    static let ctptri_work: FunctionType.LAPACKE_ctptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptri_work: FunctionType.LAPACKE_ztptri_work? = load(name: "LAPACKE_ztptri_work", as: FunctionType.LAPACKE_ztptri_work.self)
    #elseif os(macOS)
    static let ztptri_work: FunctionType.LAPACKE_ztptri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stptrs_work: FunctionType.LAPACKE_stptrs_work? = load(name: "LAPACKE_stptrs_work", as: FunctionType.LAPACKE_stptrs_work.self)
    #elseif os(macOS)
    static let stptrs_work: FunctionType.LAPACKE_stptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtptrs_work: FunctionType.LAPACKE_dtptrs_work? = load(name: "LAPACKE_dtptrs_work", as: FunctionType.LAPACKE_dtptrs_work.self)
    #elseif os(macOS)
    static let dtptrs_work: FunctionType.LAPACKE_dtptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctptrs_work: FunctionType.LAPACKE_ctptrs_work? = load(name: "LAPACKE_ctptrs_work", as: FunctionType.LAPACKE_ctptrs_work.self)
    #elseif os(macOS)
    static let ctptrs_work: FunctionType.LAPACKE_ctptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztptrs_work: FunctionType.LAPACKE_ztptrs_work? = load(name: "LAPACKE_ztptrs_work", as: FunctionType.LAPACKE_ztptrs_work.self)
    #elseif os(macOS)
    static let ztptrs_work: FunctionType.LAPACKE_ztptrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttf_work: FunctionType.LAPACKE_stpttf_work? = load(name: "LAPACKE_stpttf_work", as: FunctionType.LAPACKE_stpttf_work.self)
    #elseif os(macOS)
    static let stpttf_work: FunctionType.LAPACKE_stpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttf_work: FunctionType.LAPACKE_dtpttf_work? = load(name: "LAPACKE_dtpttf_work", as: FunctionType.LAPACKE_dtpttf_work.self)
    #elseif os(macOS)
    static let dtpttf_work: FunctionType.LAPACKE_dtpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttf_work: FunctionType.LAPACKE_ctpttf_work? = load(name: "LAPACKE_ctpttf_work", as: FunctionType.LAPACKE_ctpttf_work.self)
    #elseif os(macOS)
    static let ctpttf_work: FunctionType.LAPACKE_ctpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttf_work: FunctionType.LAPACKE_ztpttf_work? = load(name: "LAPACKE_ztpttf_work", as: FunctionType.LAPACKE_ztpttf_work.self)
    #elseif os(macOS)
    static let ztpttf_work: FunctionType.LAPACKE_ztpttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpttr_work: FunctionType.LAPACKE_stpttr_work? = load(name: "LAPACKE_stpttr_work", as: FunctionType.LAPACKE_stpttr_work.self)
    #elseif os(macOS)
    static let stpttr_work: FunctionType.LAPACKE_stpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpttr_work: FunctionType.LAPACKE_dtpttr_work? = load(name: "LAPACKE_dtpttr_work", as: FunctionType.LAPACKE_dtpttr_work.self)
    #elseif os(macOS)
    static let dtpttr_work: FunctionType.LAPACKE_dtpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpttr_work: FunctionType.LAPACKE_ctpttr_work? = load(name: "LAPACKE_ctpttr_work", as: FunctionType.LAPACKE_ctpttr_work.self)
    #elseif os(macOS)
    static let ctpttr_work: FunctionType.LAPACKE_ctpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpttr_work: FunctionType.LAPACKE_ztpttr_work? = load(name: "LAPACKE_ztpttr_work", as: FunctionType.LAPACKE_ztpttr_work.self)
    #elseif os(macOS)
    static let ztpttr_work: FunctionType.LAPACKE_ztpttr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strcon_work: FunctionType.LAPACKE_strcon_work? = load(name: "LAPACKE_strcon_work", as: FunctionType.LAPACKE_strcon_work.self)
    #elseif os(macOS)
    static let strcon_work: FunctionType.LAPACKE_strcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrcon_work: FunctionType.LAPACKE_dtrcon_work? = load(name: "LAPACKE_dtrcon_work", as: FunctionType.LAPACKE_dtrcon_work.self)
    #elseif os(macOS)
    static let dtrcon_work: FunctionType.LAPACKE_dtrcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrcon_work: FunctionType.LAPACKE_ctrcon_work? = load(name: "LAPACKE_ctrcon_work", as: FunctionType.LAPACKE_ctrcon_work.self)
    #elseif os(macOS)
    static let ctrcon_work: FunctionType.LAPACKE_ctrcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrcon_work: FunctionType.LAPACKE_ztrcon_work? = load(name: "LAPACKE_ztrcon_work", as: FunctionType.LAPACKE_ztrcon_work.self)
    #elseif os(macOS)
    static let ztrcon_work: FunctionType.LAPACKE_ztrcon_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strevc_work: FunctionType.LAPACKE_strevc_work? = load(name: "LAPACKE_strevc_work", as: FunctionType.LAPACKE_strevc_work.self)
    #elseif os(macOS)
    static let strevc_work: FunctionType.LAPACKE_strevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrevc_work: FunctionType.LAPACKE_dtrevc_work? = load(name: "LAPACKE_dtrevc_work", as: FunctionType.LAPACKE_dtrevc_work.self)
    #elseif os(macOS)
    static let dtrevc_work: FunctionType.LAPACKE_dtrevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrevc_work: FunctionType.LAPACKE_ctrevc_work? = load(name: "LAPACKE_ctrevc_work", as: FunctionType.LAPACKE_ctrevc_work.self)
    #elseif os(macOS)
    static let ctrevc_work: FunctionType.LAPACKE_ctrevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrevc_work: FunctionType.LAPACKE_ztrevc_work? = load(name: "LAPACKE_ztrevc_work", as: FunctionType.LAPACKE_ztrevc_work.self)
    #elseif os(macOS)
    static let ztrevc_work: FunctionType.LAPACKE_ztrevc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strexc_work: FunctionType.LAPACKE_strexc_work? = load(name: "LAPACKE_strexc_work", as: FunctionType.LAPACKE_strexc_work.self)
    #elseif os(macOS)
    static let strexc_work: FunctionType.LAPACKE_strexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrexc_work: FunctionType.LAPACKE_dtrexc_work? = load(name: "LAPACKE_dtrexc_work", as: FunctionType.LAPACKE_dtrexc_work.self)
    #elseif os(macOS)
    static let dtrexc_work: FunctionType.LAPACKE_dtrexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrexc_work: FunctionType.LAPACKE_ctrexc_work? = load(name: "LAPACKE_ctrexc_work", as: FunctionType.LAPACKE_ctrexc_work.self)
    #elseif os(macOS)
    static let ctrexc_work: FunctionType.LAPACKE_ctrexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrexc_work: FunctionType.LAPACKE_ztrexc_work? = load(name: "LAPACKE_ztrexc_work", as: FunctionType.LAPACKE_ztrexc_work.self)
    #elseif os(macOS)
    static let ztrexc_work: FunctionType.LAPACKE_ztrexc_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strrfs_work: FunctionType.LAPACKE_strrfs_work? = load(name: "LAPACKE_strrfs_work", as: FunctionType.LAPACKE_strrfs_work.self)
    #elseif os(macOS)
    static let strrfs_work: FunctionType.LAPACKE_strrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrrfs_work: FunctionType.LAPACKE_dtrrfs_work? = load(name: "LAPACKE_dtrrfs_work", as: FunctionType.LAPACKE_dtrrfs_work.self)
    #elseif os(macOS)
    static let dtrrfs_work: FunctionType.LAPACKE_dtrrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrrfs_work: FunctionType.LAPACKE_ctrrfs_work? = load(name: "LAPACKE_ctrrfs_work", as: FunctionType.LAPACKE_ctrrfs_work.self)
    #elseif os(macOS)
    static let ctrrfs_work: FunctionType.LAPACKE_ctrrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrrfs_work: FunctionType.LAPACKE_ztrrfs_work? = load(name: "LAPACKE_ztrrfs_work", as: FunctionType.LAPACKE_ztrrfs_work.self)
    #elseif os(macOS)
    static let ztrrfs_work: FunctionType.LAPACKE_ztrrfs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsen_work: FunctionType.LAPACKE_strsen_work? = load(name: "LAPACKE_strsen_work", as: FunctionType.LAPACKE_strsen_work.self)
    #elseif os(macOS)
    static let strsen_work: FunctionType.LAPACKE_strsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsen_work: FunctionType.LAPACKE_dtrsen_work? = load(name: "LAPACKE_dtrsen_work", as: FunctionType.LAPACKE_dtrsen_work.self)
    #elseif os(macOS)
    static let dtrsen_work: FunctionType.LAPACKE_dtrsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsen_work: FunctionType.LAPACKE_ctrsen_work? = load(name: "LAPACKE_ctrsen_work", as: FunctionType.LAPACKE_ctrsen_work.self)
    #elseif os(macOS)
    static let ctrsen_work: FunctionType.LAPACKE_ctrsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsen_work: FunctionType.LAPACKE_ztrsen_work? = load(name: "LAPACKE_ztrsen_work", as: FunctionType.LAPACKE_ztrsen_work.self)
    #elseif os(macOS)
    static let ztrsen_work: FunctionType.LAPACKE_ztrsen_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsna_work: FunctionType.LAPACKE_strsna_work? = load(name: "LAPACKE_strsna_work", as: FunctionType.LAPACKE_strsna_work.self)
    #elseif os(macOS)
    static let strsna_work: FunctionType.LAPACKE_strsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsna_work: FunctionType.LAPACKE_dtrsna_work? = load(name: "LAPACKE_dtrsna_work", as: FunctionType.LAPACKE_dtrsna_work.self)
    #elseif os(macOS)
    static let dtrsna_work: FunctionType.LAPACKE_dtrsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsna_work: FunctionType.LAPACKE_ctrsna_work? = load(name: "LAPACKE_ctrsna_work", as: FunctionType.LAPACKE_ctrsna_work.self)
    #elseif os(macOS)
    static let ctrsna_work: FunctionType.LAPACKE_ctrsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsna_work: FunctionType.LAPACKE_ztrsna_work? = load(name: "LAPACKE_ztrsna_work", as: FunctionType.LAPACKE_ztrsna_work.self)
    #elseif os(macOS)
    static let ztrsna_work: FunctionType.LAPACKE_ztrsna_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl_work: FunctionType.LAPACKE_strsyl_work? = load(name: "LAPACKE_strsyl_work", as: FunctionType.LAPACKE_strsyl_work.self)
    #elseif os(macOS)
    static let strsyl_work: FunctionType.LAPACKE_strsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl_work: FunctionType.LAPACKE_dtrsyl_work? = load(name: "LAPACKE_dtrsyl_work", as: FunctionType.LAPACKE_dtrsyl_work.self)
    #elseif os(macOS)
    static let dtrsyl_work: FunctionType.LAPACKE_dtrsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsyl_work: FunctionType.LAPACKE_ctrsyl_work? = load(name: "LAPACKE_ctrsyl_work", as: FunctionType.LAPACKE_ctrsyl_work.self)
    #elseif os(macOS)
    static let ctrsyl_work: FunctionType.LAPACKE_ctrsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl_work: FunctionType.LAPACKE_ztrsyl_work? = load(name: "LAPACKE_ztrsyl_work", as: FunctionType.LAPACKE_ztrsyl_work.self)
    #elseif os(macOS)
    static let ztrsyl_work: FunctionType.LAPACKE_ztrsyl_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strsyl3_work: FunctionType.LAPACKE_strsyl3_work? = load(name: "LAPACKE_strsyl3_work", as: FunctionType.LAPACKE_strsyl3_work.self)
    #elseif os(macOS)
    static let strsyl3_work: FunctionType.LAPACKE_strsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrsyl3_work: FunctionType.LAPACKE_dtrsyl3_work? = load(name: "LAPACKE_dtrsyl3_work", as: FunctionType.LAPACKE_dtrsyl3_work.self)
    #elseif os(macOS)
    static let dtrsyl3_work: FunctionType.LAPACKE_dtrsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrsyl3_work: FunctionType.LAPACKE_ctrsyl3_work? = load(name: "LAPACKE_ctrsyl3_work", as: FunctionType.LAPACKE_ctrsyl3_work.self)
    #elseif os(macOS)
    static let ctrsyl3_work: FunctionType.LAPACKE_ctrsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrsyl3_work: FunctionType.LAPACKE_ztrsyl3_work? = load(name: "LAPACKE_ztrsyl3_work", as: FunctionType.LAPACKE_ztrsyl3_work.self)
    #elseif os(macOS)
    static let ztrsyl3_work: FunctionType.LAPACKE_ztrsyl3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtri_work: FunctionType.LAPACKE_strtri_work? = load(name: "LAPACKE_strtri_work", as: FunctionType.LAPACKE_strtri_work.self)
    #elseif os(macOS)
    static let strtri_work: FunctionType.LAPACKE_strtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtri_work: FunctionType.LAPACKE_dtrtri_work? = load(name: "LAPACKE_dtrtri_work", as: FunctionType.LAPACKE_dtrtri_work.self)
    #elseif os(macOS)
    static let dtrtri_work: FunctionType.LAPACKE_dtrtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtri_work: FunctionType.LAPACKE_ctrtri_work? = load(name: "LAPACKE_ctrtri_work", as: FunctionType.LAPACKE_ctrtri_work.self)
    #elseif os(macOS)
    static let ctrtri_work: FunctionType.LAPACKE_ctrtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtri_work: FunctionType.LAPACKE_ztrtri_work? = load(name: "LAPACKE_ztrtri_work", as: FunctionType.LAPACKE_ztrtri_work.self)
    #elseif os(macOS)
    static let ztrtri_work: FunctionType.LAPACKE_ztrtri_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strtrs_work: FunctionType.LAPACKE_strtrs_work? = load(name: "LAPACKE_strtrs_work", as: FunctionType.LAPACKE_strtrs_work.self)
    #elseif os(macOS)
    static let strtrs_work: FunctionType.LAPACKE_strtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrtrs_work: FunctionType.LAPACKE_dtrtrs_work? = load(name: "LAPACKE_dtrtrs_work", as: FunctionType.LAPACKE_dtrtrs_work.self)
    #elseif os(macOS)
    static let dtrtrs_work: FunctionType.LAPACKE_dtrtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrtrs_work: FunctionType.LAPACKE_ctrtrs_work? = load(name: "LAPACKE_ctrtrs_work", as: FunctionType.LAPACKE_ctrtrs_work.self)
    #elseif os(macOS)
    static let ctrtrs_work: FunctionType.LAPACKE_ctrtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrtrs_work: FunctionType.LAPACKE_ztrtrs_work? = load(name: "LAPACKE_ztrtrs_work", as: FunctionType.LAPACKE_ztrtrs_work.self)
    #elseif os(macOS)
    static let ztrtrs_work: FunctionType.LAPACKE_ztrtrs_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttf_work: FunctionType.LAPACKE_strttf_work? = load(name: "LAPACKE_strttf_work", as: FunctionType.LAPACKE_strttf_work.self)
    #elseif os(macOS)
    static let strttf_work: FunctionType.LAPACKE_strttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttf_work: FunctionType.LAPACKE_dtrttf_work? = load(name: "LAPACKE_dtrttf_work", as: FunctionType.LAPACKE_dtrttf_work.self)
    #elseif os(macOS)
    static let dtrttf_work: FunctionType.LAPACKE_dtrttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttf_work: FunctionType.LAPACKE_ctrttf_work? = load(name: "LAPACKE_ctrttf_work", as: FunctionType.LAPACKE_ctrttf_work.self)
    #elseif os(macOS)
    static let ctrttf_work: FunctionType.LAPACKE_ctrttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttf_work: FunctionType.LAPACKE_ztrttf_work? = load(name: "LAPACKE_ztrttf_work", as: FunctionType.LAPACKE_ztrttf_work.self)
    #elseif os(macOS)
    static let ztrttf_work: FunctionType.LAPACKE_ztrttf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let strttp_work: FunctionType.LAPACKE_strttp_work? = load(name: "LAPACKE_strttp_work", as: FunctionType.LAPACKE_strttp_work.self)
    #elseif os(macOS)
    static let strttp_work: FunctionType.LAPACKE_strttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtrttp_work: FunctionType.LAPACKE_dtrttp_work? = load(name: "LAPACKE_dtrttp_work", as: FunctionType.LAPACKE_dtrttp_work.self)
    #elseif os(macOS)
    static let dtrttp_work: FunctionType.LAPACKE_dtrttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctrttp_work: FunctionType.LAPACKE_ctrttp_work? = load(name: "LAPACKE_ctrttp_work", as: FunctionType.LAPACKE_ctrttp_work.self)
    #elseif os(macOS)
    static let ctrttp_work: FunctionType.LAPACKE_ctrttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztrttp_work: FunctionType.LAPACKE_ztrttp_work? = load(name: "LAPACKE_ztrttp_work", as: FunctionType.LAPACKE_ztrttp_work.self)
    #elseif os(macOS)
    static let ztrttp_work: FunctionType.LAPACKE_ztrttp_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stzrzf_work: FunctionType.LAPACKE_stzrzf_work? = load(name: "LAPACKE_stzrzf_work", as: FunctionType.LAPACKE_stzrzf_work.self)
    #elseif os(macOS)
    static let stzrzf_work: FunctionType.LAPACKE_stzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtzrzf_work: FunctionType.LAPACKE_dtzrzf_work? = load(name: "LAPACKE_dtzrzf_work", as: FunctionType.LAPACKE_dtzrzf_work.self)
    #elseif os(macOS)
    static let dtzrzf_work: FunctionType.LAPACKE_dtzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctzrzf_work: FunctionType.LAPACKE_ctzrzf_work? = load(name: "LAPACKE_ctzrzf_work", as: FunctionType.LAPACKE_ctzrzf_work.self)
    #elseif os(macOS)
    static let ctzrzf_work: FunctionType.LAPACKE_ctzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztzrzf_work: FunctionType.LAPACKE_ztzrzf_work? = load(name: "LAPACKE_ztzrzf_work", as: FunctionType.LAPACKE_ztzrzf_work.self)
    #elseif os(macOS)
    static let ztzrzf_work: FunctionType.LAPACKE_ztzrzf_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungbr_work: FunctionType.LAPACKE_cungbr_work? = load(name: "LAPACKE_cungbr_work", as: FunctionType.LAPACKE_cungbr_work.self)
    #elseif os(macOS)
    static let cungbr_work: FunctionType.LAPACKE_cungbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungbr_work: FunctionType.LAPACKE_zungbr_work? = load(name: "LAPACKE_zungbr_work", as: FunctionType.LAPACKE_zungbr_work.self)
    #elseif os(macOS)
    static let zungbr_work: FunctionType.LAPACKE_zungbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunghr_work: FunctionType.LAPACKE_cunghr_work? = load(name: "LAPACKE_cunghr_work", as: FunctionType.LAPACKE_cunghr_work.self)
    #elseif os(macOS)
    static let cunghr_work: FunctionType.LAPACKE_cunghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunghr_work: FunctionType.LAPACKE_zunghr_work? = load(name: "LAPACKE_zunghr_work", as: FunctionType.LAPACKE_zunghr_work.self)
    #elseif os(macOS)
    static let zunghr_work: FunctionType.LAPACKE_zunghr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunglq_work: FunctionType.LAPACKE_cunglq_work? = load(name: "LAPACKE_cunglq_work", as: FunctionType.LAPACKE_cunglq_work.self)
    #elseif os(macOS)
    static let cunglq_work: FunctionType.LAPACKE_cunglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunglq_work: FunctionType.LAPACKE_zunglq_work? = load(name: "LAPACKE_zunglq_work", as: FunctionType.LAPACKE_zunglq_work.self)
    #elseif os(macOS)
    static let zunglq_work: FunctionType.LAPACKE_zunglq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungql_work: FunctionType.LAPACKE_cungql_work? = load(name: "LAPACKE_cungql_work", as: FunctionType.LAPACKE_cungql_work.self)
    #elseif os(macOS)
    static let cungql_work: FunctionType.LAPACKE_cungql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungql_work: FunctionType.LAPACKE_zungql_work? = load(name: "LAPACKE_zungql_work", as: FunctionType.LAPACKE_zungql_work.self)
    #elseif os(macOS)
    static let zungql_work: FunctionType.LAPACKE_zungql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungqr_work: FunctionType.LAPACKE_cungqr_work? = load(name: "LAPACKE_cungqr_work", as: FunctionType.LAPACKE_cungqr_work.self)
    #elseif os(macOS)
    static let cungqr_work: FunctionType.LAPACKE_cungqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungqr_work: FunctionType.LAPACKE_zungqr_work? = load(name: "LAPACKE_zungqr_work", as: FunctionType.LAPACKE_zungqr_work.self)
    #elseif os(macOS)
    static let zungqr_work: FunctionType.LAPACKE_zungqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungrq_work: FunctionType.LAPACKE_cungrq_work? = load(name: "LAPACKE_cungrq_work", as: FunctionType.LAPACKE_cungrq_work.self)
    #elseif os(macOS)
    static let cungrq_work: FunctionType.LAPACKE_cungrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungrq_work: FunctionType.LAPACKE_zungrq_work? = load(name: "LAPACKE_zungrq_work", as: FunctionType.LAPACKE_zungrq_work.self)
    #elseif os(macOS)
    static let zungrq_work: FunctionType.LAPACKE_zungrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtr_work: FunctionType.LAPACKE_cungtr_work? = load(name: "LAPACKE_cungtr_work", as: FunctionType.LAPACKE_cungtr_work.self)
    #elseif os(macOS)
    static let cungtr_work: FunctionType.LAPACKE_cungtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtr_work: FunctionType.LAPACKE_zungtr_work? = load(name: "LAPACKE_zungtr_work", as: FunctionType.LAPACKE_zungtr_work.self)
    #elseif os(macOS)
    static let zungtr_work: FunctionType.LAPACKE_zungtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cungtsqr_row_work: FunctionType.LAPACKE_cungtsqr_row_work? = load(name: "LAPACKE_cungtsqr_row_work", as: FunctionType.LAPACKE_cungtsqr_row_work.self)
    #elseif os(macOS)
    static let cungtsqr_row_work: FunctionType.LAPACKE_cungtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zungtsqr_row_work: FunctionType.LAPACKE_zungtsqr_row_work? = load(name: "LAPACKE_zungtsqr_row_work", as: FunctionType.LAPACKE_zungtsqr_row_work.self)
    #elseif os(macOS)
    static let zungtsqr_row_work: FunctionType.LAPACKE_zungtsqr_row_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmbr_work: FunctionType.LAPACKE_cunmbr_work? = load(name: "LAPACKE_cunmbr_work", as: FunctionType.LAPACKE_cunmbr_work.self)
    #elseif os(macOS)
    static let cunmbr_work: FunctionType.LAPACKE_cunmbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmbr_work: FunctionType.LAPACKE_zunmbr_work? = load(name: "LAPACKE_zunmbr_work", as: FunctionType.LAPACKE_zunmbr_work.self)
    #elseif os(macOS)
    static let zunmbr_work: FunctionType.LAPACKE_zunmbr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmhr_work: FunctionType.LAPACKE_cunmhr_work? = load(name: "LAPACKE_cunmhr_work", as: FunctionType.LAPACKE_cunmhr_work.self)
    #elseif os(macOS)
    static let cunmhr_work: FunctionType.LAPACKE_cunmhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmhr_work: FunctionType.LAPACKE_zunmhr_work? = load(name: "LAPACKE_zunmhr_work", as: FunctionType.LAPACKE_zunmhr_work.self)
    #elseif os(macOS)
    static let zunmhr_work: FunctionType.LAPACKE_zunmhr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmlq_work: FunctionType.LAPACKE_cunmlq_work? = load(name: "LAPACKE_cunmlq_work", as: FunctionType.LAPACKE_cunmlq_work.self)
    #elseif os(macOS)
    static let cunmlq_work: FunctionType.LAPACKE_cunmlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmlq_work: FunctionType.LAPACKE_zunmlq_work? = load(name: "LAPACKE_zunmlq_work", as: FunctionType.LAPACKE_zunmlq_work.self)
    #elseif os(macOS)
    static let zunmlq_work: FunctionType.LAPACKE_zunmlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmql_work: FunctionType.LAPACKE_cunmql_work? = load(name: "LAPACKE_cunmql_work", as: FunctionType.LAPACKE_cunmql_work.self)
    #elseif os(macOS)
    static let cunmql_work: FunctionType.LAPACKE_cunmql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmql_work: FunctionType.LAPACKE_zunmql_work? = load(name: "LAPACKE_zunmql_work", as: FunctionType.LAPACKE_zunmql_work.self)
    #elseif os(macOS)
    static let zunmql_work: FunctionType.LAPACKE_zunmql_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmqr_work: FunctionType.LAPACKE_cunmqr_work? = load(name: "LAPACKE_cunmqr_work", as: FunctionType.LAPACKE_cunmqr_work.self)
    #elseif os(macOS)
    static let cunmqr_work: FunctionType.LAPACKE_cunmqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmqr_work: FunctionType.LAPACKE_zunmqr_work? = load(name: "LAPACKE_zunmqr_work", as: FunctionType.LAPACKE_zunmqr_work.self)
    #elseif os(macOS)
    static let zunmqr_work: FunctionType.LAPACKE_zunmqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrq_work: FunctionType.LAPACKE_cunmrq_work? = load(name: "LAPACKE_cunmrq_work", as: FunctionType.LAPACKE_cunmrq_work.self)
    #elseif os(macOS)
    static let cunmrq_work: FunctionType.LAPACKE_cunmrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrq_work: FunctionType.LAPACKE_zunmrq_work? = load(name: "LAPACKE_zunmrq_work", as: FunctionType.LAPACKE_zunmrq_work.self)
    #elseif os(macOS)
    static let zunmrq_work: FunctionType.LAPACKE_zunmrq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmrz_work: FunctionType.LAPACKE_cunmrz_work? = load(name: "LAPACKE_cunmrz_work", as: FunctionType.LAPACKE_cunmrz_work.self)
    #elseif os(macOS)
    static let cunmrz_work: FunctionType.LAPACKE_cunmrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmrz_work: FunctionType.LAPACKE_zunmrz_work? = load(name: "LAPACKE_zunmrz_work", as: FunctionType.LAPACKE_zunmrz_work.self)
    #elseif os(macOS)
    static let zunmrz_work: FunctionType.LAPACKE_zunmrz_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunmtr_work: FunctionType.LAPACKE_cunmtr_work? = load(name: "LAPACKE_cunmtr_work", as: FunctionType.LAPACKE_cunmtr_work.self)
    #elseif os(macOS)
    static let cunmtr_work: FunctionType.LAPACKE_cunmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunmtr_work: FunctionType.LAPACKE_zunmtr_work? = load(name: "LAPACKE_zunmtr_work", as: FunctionType.LAPACKE_zunmtr_work.self)
    #elseif os(macOS)
    static let zunmtr_work: FunctionType.LAPACKE_zunmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupgtr_work: FunctionType.LAPACKE_cupgtr_work? = load(name: "LAPACKE_cupgtr_work", as: FunctionType.LAPACKE_cupgtr_work.self)
    #elseif os(macOS)
    static let cupgtr_work: FunctionType.LAPACKE_cupgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupgtr_work: FunctionType.LAPACKE_zupgtr_work? = load(name: "LAPACKE_zupgtr_work", as: FunctionType.LAPACKE_zupgtr_work.self)
    #elseif os(macOS)
    static let zupgtr_work: FunctionType.LAPACKE_zupgtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cupmtr_work: FunctionType.LAPACKE_cupmtr_work? = load(name: "LAPACKE_cupmtr_work", as: FunctionType.LAPACKE_cupmtr_work.self)
    #elseif os(macOS)
    static let cupmtr_work: FunctionType.LAPACKE_cupmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zupmtr_work: FunctionType.LAPACKE_zupmtr_work? = load(name: "LAPACKE_zupmtr_work", as: FunctionType.LAPACKE_zupmtr_work.self)
    #elseif os(macOS)
    static let zupmtr_work: FunctionType.LAPACKE_zupmtr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let claghe: FunctionType.LAPACKE_claghe? = load(name: "LAPACKE_claghe", as: FunctionType.LAPACKE_claghe.self)
    #elseif os(macOS)
    static let claghe: FunctionType.LAPACKE_claghe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlaghe: FunctionType.LAPACKE_zlaghe? = load(name: "LAPACKE_zlaghe", as: FunctionType.LAPACKE_zlaghe.self)
    #elseif os(macOS)
    static let zlaghe: FunctionType.LAPACKE_zlaghe? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slagsy: FunctionType.LAPACKE_slagsy? = load(name: "LAPACKE_slagsy", as: FunctionType.LAPACKE_slagsy.self)
    #elseif os(macOS)
    static let slagsy: FunctionType.LAPACKE_slagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlagsy: FunctionType.LAPACKE_dlagsy? = load(name: "LAPACKE_dlagsy", as: FunctionType.LAPACKE_dlagsy.self)
    #elseif os(macOS)
    static let dlagsy: FunctionType.LAPACKE_dlagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clagsy: FunctionType.LAPACKE_clagsy? = load(name: "LAPACKE_clagsy", as: FunctionType.LAPACKE_clagsy.self)
    #elseif os(macOS)
    static let clagsy: FunctionType.LAPACKE_clagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlagsy: FunctionType.LAPACKE_zlagsy? = load(name: "LAPACKE_zlagsy", as: FunctionType.LAPACKE_zlagsy.self)
    #elseif os(macOS)
    static let zlagsy: FunctionType.LAPACKE_zlagsy? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmr: FunctionType.LAPACKE_slapmr? = load(name: "LAPACKE_slapmr", as: FunctionType.LAPACKE_slapmr.self)
    #elseif os(macOS)
    static let slapmr: FunctionType.LAPACKE_slapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmr: FunctionType.LAPACKE_dlapmr? = load(name: "LAPACKE_dlapmr", as: FunctionType.LAPACKE_dlapmr.self)
    #elseif os(macOS)
    static let dlapmr: FunctionType.LAPACKE_dlapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmr: FunctionType.LAPACKE_clapmr? = load(name: "LAPACKE_clapmr", as: FunctionType.LAPACKE_clapmr.self)
    #elseif os(macOS)
    static let clapmr: FunctionType.LAPACKE_clapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmr: FunctionType.LAPACKE_zlapmr? = load(name: "LAPACKE_zlapmr", as: FunctionType.LAPACKE_zlapmr.self)
    #elseif os(macOS)
    static let zlapmr: FunctionType.LAPACKE_zlapmr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapmt: FunctionType.LAPACKE_slapmt? = load(name: "LAPACKE_slapmt", as: FunctionType.LAPACKE_slapmt.self)
    #elseif os(macOS)
    static let slapmt: FunctionType.LAPACKE_slapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapmt: FunctionType.LAPACKE_dlapmt? = load(name: "LAPACKE_dlapmt", as: FunctionType.LAPACKE_dlapmt.self)
    #elseif os(macOS)
    static let dlapmt: FunctionType.LAPACKE_dlapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let clapmt: FunctionType.LAPACKE_clapmt? = load(name: "LAPACKE_clapmt", as: FunctionType.LAPACKE_clapmt.self)
    #elseif os(macOS)
    static let clapmt: FunctionType.LAPACKE_clapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zlapmt: FunctionType.LAPACKE_zlapmt? = load(name: "LAPACKE_zlapmt", as: FunctionType.LAPACKE_zlapmt.self)
    #elseif os(macOS)
    static let zlapmt: FunctionType.LAPACKE_zlapmt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy2: FunctionType.LAPACKE_slapy2? = load(name: "LAPACKE_slapy2", as: FunctionType.LAPACKE_slapy2.self)
    #elseif os(macOS)
    static let slapy2: FunctionType.LAPACKE_slapy2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy2: FunctionType.LAPACKE_dlapy2? = load(name: "LAPACKE_dlapy2", as: FunctionType.LAPACKE_dlapy2.self)
    #elseif os(macOS)
    static let dlapy2: FunctionType.LAPACKE_dlapy2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slapy3: FunctionType.LAPACKE_slapy3? = load(name: "LAPACKE_slapy3", as: FunctionType.LAPACKE_slapy3.self)
    #elseif os(macOS)
    static let slapy3: FunctionType.LAPACKE_slapy3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlapy3: FunctionType.LAPACKE_dlapy3? = load(name: "LAPACKE_dlapy3", as: FunctionType.LAPACKE_dlapy3.self)
    #elseif os(macOS)
    static let dlapy3: FunctionType.LAPACKE_dlapy3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgp: FunctionType.LAPACKE_slartgp? = load(name: "LAPACKE_slartgp", as: FunctionType.LAPACKE_slartgp.self)
    #elseif os(macOS)
    static let slartgp: FunctionType.LAPACKE_slartgp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgp: FunctionType.LAPACKE_dlartgp? = load(name: "LAPACKE_dlartgp", as: FunctionType.LAPACKE_dlartgp.self)
    #elseif os(macOS)
    static let dlartgp: FunctionType.LAPACKE_dlartgp? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let slartgs: FunctionType.LAPACKE_slartgs? = load(name: "LAPACKE_slartgs", as: FunctionType.LAPACKE_slartgs.self)
    #elseif os(macOS)
    static let slartgs: FunctionType.LAPACKE_slartgs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dlartgs: FunctionType.LAPACKE_dlartgs? = load(name: "LAPACKE_dlartgs", as: FunctionType.LAPACKE_dlartgs.self)
    #elseif os(macOS)
    static let dlartgs: FunctionType.LAPACKE_dlartgs? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbbcsd: FunctionType.LAPACKE_cbbcsd? = load(name: "LAPACKE_cbbcsd", as: FunctionType.LAPACKE_cbbcsd.self)
    #elseif os(macOS)
    static let cbbcsd: FunctionType.LAPACKE_cbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cbbcsd_work: FunctionType.LAPACKE_cbbcsd_work? = load(name: "LAPACKE_cbbcsd_work", as: FunctionType.LAPACKE_cbbcsd_work.self)
    #elseif os(macOS)
    static let cbbcsd_work: FunctionType.LAPACKE_cbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheswapr: FunctionType.LAPACKE_cheswapr? = load(name: "LAPACKE_cheswapr", as: FunctionType.LAPACKE_cheswapr.self)
    #elseif os(macOS)
    static let cheswapr: FunctionType.LAPACKE_cheswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheswapr_work: FunctionType.LAPACKE_cheswapr_work? = load(name: "LAPACKE_cheswapr_work", as: FunctionType.LAPACKE_cheswapr_work.self)
    #elseif os(macOS)
    static let cheswapr_work: FunctionType.LAPACKE_cheswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2: FunctionType.LAPACKE_chetri2? = load(name: "LAPACKE_chetri2", as: FunctionType.LAPACKE_chetri2.self)
    #elseif os(macOS)
    static let chetri2: FunctionType.LAPACKE_chetri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2_work: FunctionType.LAPACKE_chetri2_work? = load(name: "LAPACKE_chetri2_work", as: FunctionType.LAPACKE_chetri2_work.self)
    #elseif os(macOS)
    static let chetri2_work: FunctionType.LAPACKE_chetri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2x: FunctionType.LAPACKE_chetri2x? = load(name: "LAPACKE_chetri2x", as: FunctionType.LAPACKE_chetri2x.self)
    #elseif os(macOS)
    static let chetri2x: FunctionType.LAPACKE_chetri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri2x_work: FunctionType.LAPACKE_chetri2x_work? = load(name: "LAPACKE_chetri2x_work", as: FunctionType.LAPACKE_chetri2x_work.self)
    #elseif os(macOS)
    static let chetri2x_work: FunctionType.LAPACKE_chetri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs2: FunctionType.LAPACKE_chetrs2? = load(name: "LAPACKE_chetrs2", as: FunctionType.LAPACKE_chetrs2.self)
    #elseif os(macOS)
    static let chetrs2: FunctionType.LAPACKE_chetrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs2_work: FunctionType.LAPACKE_chetrs2_work? = load(name: "LAPACKE_chetrs2_work", as: FunctionType.LAPACKE_chetrs2_work.self)
    #elseif os(macOS)
    static let chetrs2_work: FunctionType.LAPACKE_chetrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyconv: FunctionType.LAPACKE_csyconv? = load(name: "LAPACKE_csyconv", as: FunctionType.LAPACKE_csyconv.self)
    #elseif os(macOS)
    static let csyconv: FunctionType.LAPACKE_csyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyconv_work: FunctionType.LAPACKE_csyconv_work? = load(name: "LAPACKE_csyconv_work", as: FunctionType.LAPACKE_csyconv_work.self)
    #elseif os(macOS)
    static let csyconv_work: FunctionType.LAPACKE_csyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyswapr: FunctionType.LAPACKE_csyswapr? = load(name: "LAPACKE_csyswapr", as: FunctionType.LAPACKE_csyswapr.self)
    #elseif os(macOS)
    static let csyswapr: FunctionType.LAPACKE_csyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csyswapr_work: FunctionType.LAPACKE_csyswapr_work? = load(name: "LAPACKE_csyswapr_work", as: FunctionType.LAPACKE_csyswapr_work.self)
    #elseif os(macOS)
    static let csyswapr_work: FunctionType.LAPACKE_csyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2: FunctionType.LAPACKE_csytri2? = load(name: "LAPACKE_csytri2", as: FunctionType.LAPACKE_csytri2.self)
    #elseif os(macOS)
    static let csytri2: FunctionType.LAPACKE_csytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2_work: FunctionType.LAPACKE_csytri2_work? = load(name: "LAPACKE_csytri2_work", as: FunctionType.LAPACKE_csytri2_work.self)
    #elseif os(macOS)
    static let csytri2_work: FunctionType.LAPACKE_csytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2x: FunctionType.LAPACKE_csytri2x? = load(name: "LAPACKE_csytri2x", as: FunctionType.LAPACKE_csytri2x.self)
    #elseif os(macOS)
    static let csytri2x: FunctionType.LAPACKE_csytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri2x_work: FunctionType.LAPACKE_csytri2x_work? = load(name: "LAPACKE_csytri2x_work", as: FunctionType.LAPACKE_csytri2x_work.self)
    #elseif os(macOS)
    static let csytri2x_work: FunctionType.LAPACKE_csytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs2: FunctionType.LAPACKE_csytrs2? = load(name: "LAPACKE_csytrs2", as: FunctionType.LAPACKE_csytrs2.self)
    #elseif os(macOS)
    static let csytrs2: FunctionType.LAPACKE_csytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs2_work: FunctionType.LAPACKE_csytrs2_work? = load(name: "LAPACKE_csytrs2_work", as: FunctionType.LAPACKE_csytrs2_work.self)
    #elseif os(macOS)
    static let csytrs2_work: FunctionType.LAPACKE_csytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunbdb: FunctionType.LAPACKE_cunbdb? = load(name: "LAPACKE_cunbdb", as: FunctionType.LAPACKE_cunbdb.self)
    #elseif os(macOS)
    static let cunbdb: FunctionType.LAPACKE_cunbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunbdb_work: FunctionType.LAPACKE_cunbdb_work? = load(name: "LAPACKE_cunbdb_work", as: FunctionType.LAPACKE_cunbdb_work.self)
    #elseif os(macOS)
    static let cunbdb_work: FunctionType.LAPACKE_cunbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd: FunctionType.LAPACKE_cuncsd? = load(name: "LAPACKE_cuncsd", as: FunctionType.LAPACKE_cuncsd.self)
    #elseif os(macOS)
    static let cuncsd: FunctionType.LAPACKE_cuncsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd_work: FunctionType.LAPACKE_cuncsd_work? = load(name: "LAPACKE_cuncsd_work", as: FunctionType.LAPACKE_cuncsd_work.self)
    #elseif os(macOS)
    static let cuncsd_work: FunctionType.LAPACKE_cuncsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd2by1: FunctionType.LAPACKE_cuncsd2by1? = load(name: "LAPACKE_cuncsd2by1", as: FunctionType.LAPACKE_cuncsd2by1.self)
    #elseif os(macOS)
    static let cuncsd2by1: FunctionType.LAPACKE_cuncsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cuncsd2by1_work: FunctionType.LAPACKE_cuncsd2by1_work? = load(name: "LAPACKE_cuncsd2by1_work", as: FunctionType.LAPACKE_cuncsd2by1_work.self)
    #elseif os(macOS)
    static let cuncsd2by1_work: FunctionType.LAPACKE_cuncsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbbcsd: FunctionType.LAPACKE_dbbcsd? = load(name: "LAPACKE_dbbcsd", as: FunctionType.LAPACKE_dbbcsd.self)
    #elseif os(macOS)
    static let dbbcsd: FunctionType.LAPACKE_dbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dbbcsd_work: FunctionType.LAPACKE_dbbcsd_work? = load(name: "LAPACKE_dbbcsd_work", as: FunctionType.LAPACKE_dbbcsd_work.self)
    #elseif os(macOS)
    static let dbbcsd_work: FunctionType.LAPACKE_dbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorbdb: FunctionType.LAPACKE_dorbdb? = load(name: "LAPACKE_dorbdb", as: FunctionType.LAPACKE_dorbdb.self)
    #elseif os(macOS)
    static let dorbdb: FunctionType.LAPACKE_dorbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorbdb_work: FunctionType.LAPACKE_dorbdb_work? = load(name: "LAPACKE_dorbdb_work", as: FunctionType.LAPACKE_dorbdb_work.self)
    #elseif os(macOS)
    static let dorbdb_work: FunctionType.LAPACKE_dorbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd: FunctionType.LAPACKE_dorcsd? = load(name: "LAPACKE_dorcsd", as: FunctionType.LAPACKE_dorcsd.self)
    #elseif os(macOS)
    static let dorcsd: FunctionType.LAPACKE_dorcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd_work: FunctionType.LAPACKE_dorcsd_work? = load(name: "LAPACKE_dorcsd_work", as: FunctionType.LAPACKE_dorcsd_work.self)
    #elseif os(macOS)
    static let dorcsd_work: FunctionType.LAPACKE_dorcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd2by1: FunctionType.LAPACKE_dorcsd2by1? = load(name: "LAPACKE_dorcsd2by1", as: FunctionType.LAPACKE_dorcsd2by1.self)
    #elseif os(macOS)
    static let dorcsd2by1: FunctionType.LAPACKE_dorcsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorcsd2by1_work: FunctionType.LAPACKE_dorcsd2by1_work? = load(name: "LAPACKE_dorcsd2by1_work", as: FunctionType.LAPACKE_dorcsd2by1_work.self)
    #elseif os(macOS)
    static let dorcsd2by1_work: FunctionType.LAPACKE_dorcsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyconv: FunctionType.LAPACKE_dsyconv? = load(name: "LAPACKE_dsyconv", as: FunctionType.LAPACKE_dsyconv.self)
    #elseif os(macOS)
    static let dsyconv: FunctionType.LAPACKE_dsyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyconv_work: FunctionType.LAPACKE_dsyconv_work? = load(name: "LAPACKE_dsyconv_work", as: FunctionType.LAPACKE_dsyconv_work.self)
    #elseif os(macOS)
    static let dsyconv_work: FunctionType.LAPACKE_dsyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyswapr: FunctionType.LAPACKE_dsyswapr? = load(name: "LAPACKE_dsyswapr", as: FunctionType.LAPACKE_dsyswapr.self)
    #elseif os(macOS)
    static let dsyswapr: FunctionType.LAPACKE_dsyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyswapr_work: FunctionType.LAPACKE_dsyswapr_work? = load(name: "LAPACKE_dsyswapr_work", as: FunctionType.LAPACKE_dsyswapr_work.self)
    #elseif os(macOS)
    static let dsyswapr_work: FunctionType.LAPACKE_dsyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2: FunctionType.LAPACKE_dsytri2? = load(name: "LAPACKE_dsytri2", as: FunctionType.LAPACKE_dsytri2.self)
    #elseif os(macOS)
    static let dsytri2: FunctionType.LAPACKE_dsytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2_work: FunctionType.LAPACKE_dsytri2_work? = load(name: "LAPACKE_dsytri2_work", as: FunctionType.LAPACKE_dsytri2_work.self)
    #elseif os(macOS)
    static let dsytri2_work: FunctionType.LAPACKE_dsytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2x: FunctionType.LAPACKE_dsytri2x? = load(name: "LAPACKE_dsytri2x", as: FunctionType.LAPACKE_dsytri2x.self)
    #elseif os(macOS)
    static let dsytri2x: FunctionType.LAPACKE_dsytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri2x_work: FunctionType.LAPACKE_dsytri2x_work? = load(name: "LAPACKE_dsytri2x_work", as: FunctionType.LAPACKE_dsytri2x_work.self)
    #elseif os(macOS)
    static let dsytri2x_work: FunctionType.LAPACKE_dsytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs2: FunctionType.LAPACKE_dsytrs2? = load(name: "LAPACKE_dsytrs2", as: FunctionType.LAPACKE_dsytrs2.self)
    #elseif os(macOS)
    static let dsytrs2: FunctionType.LAPACKE_dsytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs2_work: FunctionType.LAPACKE_dsytrs2_work? = load(name: "LAPACKE_dsytrs2_work", as: FunctionType.LAPACKE_dsytrs2_work.self)
    #elseif os(macOS)
    static let dsytrs2_work: FunctionType.LAPACKE_dsytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbbcsd: FunctionType.LAPACKE_sbbcsd? = load(name: "LAPACKE_sbbcsd", as: FunctionType.LAPACKE_sbbcsd.self)
    #elseif os(macOS)
    static let sbbcsd: FunctionType.LAPACKE_sbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sbbcsd_work: FunctionType.LAPACKE_sbbcsd_work? = load(name: "LAPACKE_sbbcsd_work", as: FunctionType.LAPACKE_sbbcsd_work.self)
    #elseif os(macOS)
    static let sbbcsd_work: FunctionType.LAPACKE_sbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorbdb: FunctionType.LAPACKE_sorbdb? = load(name: "LAPACKE_sorbdb", as: FunctionType.LAPACKE_sorbdb.self)
    #elseif os(macOS)
    static let sorbdb: FunctionType.LAPACKE_sorbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorbdb_work: FunctionType.LAPACKE_sorbdb_work? = load(name: "LAPACKE_sorbdb_work", as: FunctionType.LAPACKE_sorbdb_work.self)
    #elseif os(macOS)
    static let sorbdb_work: FunctionType.LAPACKE_sorbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd: FunctionType.LAPACKE_sorcsd? = load(name: "LAPACKE_sorcsd", as: FunctionType.LAPACKE_sorcsd.self)
    #elseif os(macOS)
    static let sorcsd: FunctionType.LAPACKE_sorcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd_work: FunctionType.LAPACKE_sorcsd_work? = load(name: "LAPACKE_sorcsd_work", as: FunctionType.LAPACKE_sorcsd_work.self)
    #elseif os(macOS)
    static let sorcsd_work: FunctionType.LAPACKE_sorcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd2by1: FunctionType.LAPACKE_sorcsd2by1? = load(name: "LAPACKE_sorcsd2by1", as: FunctionType.LAPACKE_sorcsd2by1.self)
    #elseif os(macOS)
    static let sorcsd2by1: FunctionType.LAPACKE_sorcsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorcsd2by1_work: FunctionType.LAPACKE_sorcsd2by1_work? = load(name: "LAPACKE_sorcsd2by1_work", as: FunctionType.LAPACKE_sorcsd2by1_work.self)
    #elseif os(macOS)
    static let sorcsd2by1_work: FunctionType.LAPACKE_sorcsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyconv: FunctionType.LAPACKE_ssyconv? = load(name: "LAPACKE_ssyconv", as: FunctionType.LAPACKE_ssyconv.self)
    #elseif os(macOS)
    static let ssyconv: FunctionType.LAPACKE_ssyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyconv_work: FunctionType.LAPACKE_ssyconv_work? = load(name: "LAPACKE_ssyconv_work", as: FunctionType.LAPACKE_ssyconv_work.self)
    #elseif os(macOS)
    static let ssyconv_work: FunctionType.LAPACKE_ssyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyswapr: FunctionType.LAPACKE_ssyswapr? = load(name: "LAPACKE_ssyswapr", as: FunctionType.LAPACKE_ssyswapr.self)
    #elseif os(macOS)
    static let ssyswapr: FunctionType.LAPACKE_ssyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyswapr_work: FunctionType.LAPACKE_ssyswapr_work? = load(name: "LAPACKE_ssyswapr_work", as: FunctionType.LAPACKE_ssyswapr_work.self)
    #elseif os(macOS)
    static let ssyswapr_work: FunctionType.LAPACKE_ssyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2: FunctionType.LAPACKE_ssytri2? = load(name: "LAPACKE_ssytri2", as: FunctionType.LAPACKE_ssytri2.self)
    #elseif os(macOS)
    static let ssytri2: FunctionType.LAPACKE_ssytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2_work: FunctionType.LAPACKE_ssytri2_work? = load(name: "LAPACKE_ssytri2_work", as: FunctionType.LAPACKE_ssytri2_work.self)
    #elseif os(macOS)
    static let ssytri2_work: FunctionType.LAPACKE_ssytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2x: FunctionType.LAPACKE_ssytri2x? = load(name: "LAPACKE_ssytri2x", as: FunctionType.LAPACKE_ssytri2x.self)
    #elseif os(macOS)
    static let ssytri2x: FunctionType.LAPACKE_ssytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri2x_work: FunctionType.LAPACKE_ssytri2x_work? = load(name: "LAPACKE_ssytri2x_work", as: FunctionType.LAPACKE_ssytri2x_work.self)
    #elseif os(macOS)
    static let ssytri2x_work: FunctionType.LAPACKE_ssytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs2: FunctionType.LAPACKE_ssytrs2? = load(name: "LAPACKE_ssytrs2", as: FunctionType.LAPACKE_ssytrs2.self)
    #elseif os(macOS)
    static let ssytrs2: FunctionType.LAPACKE_ssytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs2_work: FunctionType.LAPACKE_ssytrs2_work? = load(name: "LAPACKE_ssytrs2_work", as: FunctionType.LAPACKE_ssytrs2_work.self)
    #elseif os(macOS)
    static let ssytrs2_work: FunctionType.LAPACKE_ssytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbbcsd: FunctionType.LAPACKE_zbbcsd? = load(name: "LAPACKE_zbbcsd", as: FunctionType.LAPACKE_zbbcsd.self)
    #elseif os(macOS)
    static let zbbcsd: FunctionType.LAPACKE_zbbcsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zbbcsd_work: FunctionType.LAPACKE_zbbcsd_work? = load(name: "LAPACKE_zbbcsd_work", as: FunctionType.LAPACKE_zbbcsd_work.self)
    #elseif os(macOS)
    static let zbbcsd_work: FunctionType.LAPACKE_zbbcsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheswapr: FunctionType.LAPACKE_zheswapr? = load(name: "LAPACKE_zheswapr", as: FunctionType.LAPACKE_zheswapr.self)
    #elseif os(macOS)
    static let zheswapr: FunctionType.LAPACKE_zheswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheswapr_work: FunctionType.LAPACKE_zheswapr_work? = load(name: "LAPACKE_zheswapr_work", as: FunctionType.LAPACKE_zheswapr_work.self)
    #elseif os(macOS)
    static let zheswapr_work: FunctionType.LAPACKE_zheswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2: FunctionType.LAPACKE_zhetri2? = load(name: "LAPACKE_zhetri2", as: FunctionType.LAPACKE_zhetri2.self)
    #elseif os(macOS)
    static let zhetri2: FunctionType.LAPACKE_zhetri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2_work: FunctionType.LAPACKE_zhetri2_work? = load(name: "LAPACKE_zhetri2_work", as: FunctionType.LAPACKE_zhetri2_work.self)
    #elseif os(macOS)
    static let zhetri2_work: FunctionType.LAPACKE_zhetri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2x: FunctionType.LAPACKE_zhetri2x? = load(name: "LAPACKE_zhetri2x", as: FunctionType.LAPACKE_zhetri2x.self)
    #elseif os(macOS)
    static let zhetri2x: FunctionType.LAPACKE_zhetri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri2x_work: FunctionType.LAPACKE_zhetri2x_work? = load(name: "LAPACKE_zhetri2x_work", as: FunctionType.LAPACKE_zhetri2x_work.self)
    #elseif os(macOS)
    static let zhetri2x_work: FunctionType.LAPACKE_zhetri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs2: FunctionType.LAPACKE_zhetrs2? = load(name: "LAPACKE_zhetrs2", as: FunctionType.LAPACKE_zhetrs2.self)
    #elseif os(macOS)
    static let zhetrs2: FunctionType.LAPACKE_zhetrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs2_work: FunctionType.LAPACKE_zhetrs2_work? = load(name: "LAPACKE_zhetrs2_work", as: FunctionType.LAPACKE_zhetrs2_work.self)
    #elseif os(macOS)
    static let zhetrs2_work: FunctionType.LAPACKE_zhetrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyconv: FunctionType.LAPACKE_zsyconv? = load(name: "LAPACKE_zsyconv", as: FunctionType.LAPACKE_zsyconv.self)
    #elseif os(macOS)
    static let zsyconv: FunctionType.LAPACKE_zsyconv? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyconv_work: FunctionType.LAPACKE_zsyconv_work? = load(name: "LAPACKE_zsyconv_work", as: FunctionType.LAPACKE_zsyconv_work.self)
    #elseif os(macOS)
    static let zsyconv_work: FunctionType.LAPACKE_zsyconv_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyswapr: FunctionType.LAPACKE_zsyswapr? = load(name: "LAPACKE_zsyswapr", as: FunctionType.LAPACKE_zsyswapr.self)
    #elseif os(macOS)
    static let zsyswapr: FunctionType.LAPACKE_zsyswapr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsyswapr_work: FunctionType.LAPACKE_zsyswapr_work? = load(name: "LAPACKE_zsyswapr_work", as: FunctionType.LAPACKE_zsyswapr_work.self)
    #elseif os(macOS)
    static let zsyswapr_work: FunctionType.LAPACKE_zsyswapr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2: FunctionType.LAPACKE_zsytri2? = load(name: "LAPACKE_zsytri2", as: FunctionType.LAPACKE_zsytri2.self)
    #elseif os(macOS)
    static let zsytri2: FunctionType.LAPACKE_zsytri2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2_work: FunctionType.LAPACKE_zsytri2_work? = load(name: "LAPACKE_zsytri2_work", as: FunctionType.LAPACKE_zsytri2_work.self)
    #elseif os(macOS)
    static let zsytri2_work: FunctionType.LAPACKE_zsytri2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2x: FunctionType.LAPACKE_zsytri2x? = load(name: "LAPACKE_zsytri2x", as: FunctionType.LAPACKE_zsytri2x.self)
    #elseif os(macOS)
    static let zsytri2x: FunctionType.LAPACKE_zsytri2x? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri2x_work: FunctionType.LAPACKE_zsytri2x_work? = load(name: "LAPACKE_zsytri2x_work", as: FunctionType.LAPACKE_zsytri2x_work.self)
    #elseif os(macOS)
    static let zsytri2x_work: FunctionType.LAPACKE_zsytri2x_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs2: FunctionType.LAPACKE_zsytrs2? = load(name: "LAPACKE_zsytrs2", as: FunctionType.LAPACKE_zsytrs2.self)
    #elseif os(macOS)
    static let zsytrs2: FunctionType.LAPACKE_zsytrs2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs2_work: FunctionType.LAPACKE_zsytrs2_work? = load(name: "LAPACKE_zsytrs2_work", as: FunctionType.LAPACKE_zsytrs2_work.self)
    #elseif os(macOS)
    static let zsytrs2_work: FunctionType.LAPACKE_zsytrs2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunbdb: FunctionType.LAPACKE_zunbdb? = load(name: "LAPACKE_zunbdb", as: FunctionType.LAPACKE_zunbdb.self)
    #elseif os(macOS)
    static let zunbdb: FunctionType.LAPACKE_zunbdb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunbdb_work: FunctionType.LAPACKE_zunbdb_work? = load(name: "LAPACKE_zunbdb_work", as: FunctionType.LAPACKE_zunbdb_work.self)
    #elseif os(macOS)
    static let zunbdb_work: FunctionType.LAPACKE_zunbdb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd: FunctionType.LAPACKE_zuncsd? = load(name: "LAPACKE_zuncsd", as: FunctionType.LAPACKE_zuncsd.self)
    #elseif os(macOS)
    static let zuncsd: FunctionType.LAPACKE_zuncsd? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd_work: FunctionType.LAPACKE_zuncsd_work? = load(name: "LAPACKE_zuncsd_work", as: FunctionType.LAPACKE_zuncsd_work.self)
    #elseif os(macOS)
    static let zuncsd_work: FunctionType.LAPACKE_zuncsd_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd2by1: FunctionType.LAPACKE_zuncsd2by1? = load(name: "LAPACKE_zuncsd2by1", as: FunctionType.LAPACKE_zuncsd2by1.self)
    #elseif os(macOS)
    static let zuncsd2by1: FunctionType.LAPACKE_zuncsd2by1? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zuncsd2by1_work: FunctionType.LAPACKE_zuncsd2by1_work? = load(name: "LAPACKE_zuncsd2by1_work", as: FunctionType.LAPACKE_zuncsd2by1_work.self)
    #elseif os(macOS)
    static let zuncsd2by1_work: FunctionType.LAPACKE_zuncsd2by1_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqrt: FunctionType.LAPACKE_sgemqrt? = load(name: "LAPACKE_sgemqrt", as: FunctionType.LAPACKE_sgemqrt.self)
    #elseif os(macOS)
    static let sgemqrt: FunctionType.LAPACKE_sgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqrt: FunctionType.LAPACKE_dgemqrt? = load(name: "LAPACKE_dgemqrt", as: FunctionType.LAPACKE_dgemqrt.self)
    #elseif os(macOS)
    static let dgemqrt: FunctionType.LAPACKE_dgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqrt: FunctionType.LAPACKE_cgemqrt? = load(name: "LAPACKE_cgemqrt", as: FunctionType.LAPACKE_cgemqrt.self)
    #elseif os(macOS)
    static let cgemqrt: FunctionType.LAPACKE_cgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqrt: FunctionType.LAPACKE_zgemqrt? = load(name: "LAPACKE_zgemqrt", as: FunctionType.LAPACKE_zgemqrt.self)
    #elseif os(macOS)
    static let zgemqrt: FunctionType.LAPACKE_zgemqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt: FunctionType.LAPACKE_sgeqrt? = load(name: "LAPACKE_sgeqrt", as: FunctionType.LAPACKE_sgeqrt.self)
    #elseif os(macOS)
    static let sgeqrt: FunctionType.LAPACKE_sgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt: FunctionType.LAPACKE_dgeqrt? = load(name: "LAPACKE_dgeqrt", as: FunctionType.LAPACKE_dgeqrt.self)
    #elseif os(macOS)
    static let dgeqrt: FunctionType.LAPACKE_dgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt: FunctionType.LAPACKE_cgeqrt? = load(name: "LAPACKE_cgeqrt", as: FunctionType.LAPACKE_cgeqrt.self)
    #elseif os(macOS)
    static let cgeqrt: FunctionType.LAPACKE_cgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt: FunctionType.LAPACKE_zgeqrt? = load(name: "LAPACKE_zgeqrt", as: FunctionType.LAPACKE_zgeqrt.self)
    #elseif os(macOS)
    static let zgeqrt: FunctionType.LAPACKE_zgeqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt2: FunctionType.LAPACKE_sgeqrt2? = load(name: "LAPACKE_sgeqrt2", as: FunctionType.LAPACKE_sgeqrt2.self)
    #elseif os(macOS)
    static let sgeqrt2: FunctionType.LAPACKE_sgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt2: FunctionType.LAPACKE_dgeqrt2? = load(name: "LAPACKE_dgeqrt2", as: FunctionType.LAPACKE_dgeqrt2.self)
    #elseif os(macOS)
    static let dgeqrt2: FunctionType.LAPACKE_dgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt2: FunctionType.LAPACKE_cgeqrt2? = load(name: "LAPACKE_cgeqrt2", as: FunctionType.LAPACKE_cgeqrt2.self)
    #elseif os(macOS)
    static let cgeqrt2: FunctionType.LAPACKE_cgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt2: FunctionType.LAPACKE_zgeqrt2? = load(name: "LAPACKE_zgeqrt2", as: FunctionType.LAPACKE_zgeqrt2.self)
    #elseif os(macOS)
    static let zgeqrt2: FunctionType.LAPACKE_zgeqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt3: FunctionType.LAPACKE_sgeqrt3? = load(name: "LAPACKE_sgeqrt3", as: FunctionType.LAPACKE_sgeqrt3.self)
    #elseif os(macOS)
    static let sgeqrt3: FunctionType.LAPACKE_sgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt3: FunctionType.LAPACKE_dgeqrt3? = load(name: "LAPACKE_dgeqrt3", as: FunctionType.LAPACKE_dgeqrt3.self)
    #elseif os(macOS)
    static let dgeqrt3: FunctionType.LAPACKE_dgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt3: FunctionType.LAPACKE_cgeqrt3? = load(name: "LAPACKE_cgeqrt3", as: FunctionType.LAPACKE_cgeqrt3.self)
    #elseif os(macOS)
    static let cgeqrt3: FunctionType.LAPACKE_cgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt3: FunctionType.LAPACKE_zgeqrt3? = load(name: "LAPACKE_zgeqrt3", as: FunctionType.LAPACKE_zgeqrt3.self)
    #elseif os(macOS)
    static let zgeqrt3: FunctionType.LAPACKE_zgeqrt3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpmqrt: FunctionType.LAPACKE_stpmqrt? = load(name: "LAPACKE_stpmqrt", as: FunctionType.LAPACKE_stpmqrt.self)
    #elseif os(macOS)
    static let stpmqrt: FunctionType.LAPACKE_stpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpmqrt: FunctionType.LAPACKE_dtpmqrt? = load(name: "LAPACKE_dtpmqrt", as: FunctionType.LAPACKE_dtpmqrt.self)
    #elseif os(macOS)
    static let dtpmqrt: FunctionType.LAPACKE_dtpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpmqrt: FunctionType.LAPACKE_ctpmqrt? = load(name: "LAPACKE_ctpmqrt", as: FunctionType.LAPACKE_ctpmqrt.self)
    #elseif os(macOS)
    static let ctpmqrt: FunctionType.LAPACKE_ctpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpmqrt: FunctionType.LAPACKE_ztpmqrt? = load(name: "LAPACKE_ztpmqrt", as: FunctionType.LAPACKE_ztpmqrt.self)
    #elseif os(macOS)
    static let ztpmqrt: FunctionType.LAPACKE_ztpmqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt: FunctionType.LAPACKE_stpqrt? = load(name: "LAPACKE_stpqrt", as: FunctionType.LAPACKE_stpqrt.self)
    #elseif os(macOS)
    static let stpqrt: FunctionType.LAPACKE_stpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt: FunctionType.LAPACKE_dtpqrt? = load(name: "LAPACKE_dtpqrt", as: FunctionType.LAPACKE_dtpqrt.self)
    #elseif os(macOS)
    static let dtpqrt: FunctionType.LAPACKE_dtpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt: FunctionType.LAPACKE_ctpqrt? = load(name: "LAPACKE_ctpqrt", as: FunctionType.LAPACKE_ctpqrt.self)
    #elseif os(macOS)
    static let ctpqrt: FunctionType.LAPACKE_ctpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt: FunctionType.LAPACKE_ztpqrt? = load(name: "LAPACKE_ztpqrt", as: FunctionType.LAPACKE_ztpqrt.self)
    #elseif os(macOS)
    static let ztpqrt: FunctionType.LAPACKE_ztpqrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt2: FunctionType.LAPACKE_stpqrt2? = load(name: "LAPACKE_stpqrt2", as: FunctionType.LAPACKE_stpqrt2.self)
    #elseif os(macOS)
    static let stpqrt2: FunctionType.LAPACKE_stpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt2: FunctionType.LAPACKE_dtpqrt2? = load(name: "LAPACKE_dtpqrt2", as: FunctionType.LAPACKE_dtpqrt2.self)
    #elseif os(macOS)
    static let dtpqrt2: FunctionType.LAPACKE_dtpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt2: FunctionType.LAPACKE_ctpqrt2? = load(name: "LAPACKE_ctpqrt2", as: FunctionType.LAPACKE_ctpqrt2.self)
    #elseif os(macOS)
    static let ctpqrt2: FunctionType.LAPACKE_ctpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt2: FunctionType.LAPACKE_ztpqrt2? = load(name: "LAPACKE_ztpqrt2", as: FunctionType.LAPACKE_ztpqrt2.self)
    #elseif os(macOS)
    static let ztpqrt2: FunctionType.LAPACKE_ztpqrt2? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfb: FunctionType.LAPACKE_stprfb? = load(name: "LAPACKE_stprfb", as: FunctionType.LAPACKE_stprfb.self)
    #elseif os(macOS)
    static let stprfb: FunctionType.LAPACKE_stprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfb: FunctionType.LAPACKE_dtprfb? = load(name: "LAPACKE_dtprfb", as: FunctionType.LAPACKE_dtprfb.self)
    #elseif os(macOS)
    static let dtprfb: FunctionType.LAPACKE_dtprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfb: FunctionType.LAPACKE_ctprfb? = load(name: "LAPACKE_ctprfb", as: FunctionType.LAPACKE_ctprfb.self)
    #elseif os(macOS)
    static let ctprfb: FunctionType.LAPACKE_ctprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfb: FunctionType.LAPACKE_ztprfb? = load(name: "LAPACKE_ztprfb", as: FunctionType.LAPACKE_ztprfb.self)
    #elseif os(macOS)
    static let ztprfb: FunctionType.LAPACKE_ztprfb? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqrt_work: FunctionType.LAPACKE_sgemqrt_work? = load(name: "LAPACKE_sgemqrt_work", as: FunctionType.LAPACKE_sgemqrt_work.self)
    #elseif os(macOS)
    static let sgemqrt_work: FunctionType.LAPACKE_sgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqrt_work: FunctionType.LAPACKE_dgemqrt_work? = load(name: "LAPACKE_dgemqrt_work", as: FunctionType.LAPACKE_dgemqrt_work.self)
    #elseif os(macOS)
    static let dgemqrt_work: FunctionType.LAPACKE_dgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqrt_work: FunctionType.LAPACKE_cgemqrt_work? = load(name: "LAPACKE_cgemqrt_work", as: FunctionType.LAPACKE_cgemqrt_work.self)
    #elseif os(macOS)
    static let cgemqrt_work: FunctionType.LAPACKE_cgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqrt_work: FunctionType.LAPACKE_zgemqrt_work? = load(name: "LAPACKE_zgemqrt_work", as: FunctionType.LAPACKE_zgemqrt_work.self)
    #elseif os(macOS)
    static let zgemqrt_work: FunctionType.LAPACKE_zgemqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt_work: FunctionType.LAPACKE_sgeqrt_work? = load(name: "LAPACKE_sgeqrt_work", as: FunctionType.LAPACKE_sgeqrt_work.self)
    #elseif os(macOS)
    static let sgeqrt_work: FunctionType.LAPACKE_sgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt_work: FunctionType.LAPACKE_dgeqrt_work? = load(name: "LAPACKE_dgeqrt_work", as: FunctionType.LAPACKE_dgeqrt_work.self)
    #elseif os(macOS)
    static let dgeqrt_work: FunctionType.LAPACKE_dgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt_work: FunctionType.LAPACKE_cgeqrt_work? = load(name: "LAPACKE_cgeqrt_work", as: FunctionType.LAPACKE_cgeqrt_work.self)
    #elseif os(macOS)
    static let cgeqrt_work: FunctionType.LAPACKE_cgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt_work: FunctionType.LAPACKE_zgeqrt_work? = load(name: "LAPACKE_zgeqrt_work", as: FunctionType.LAPACKE_zgeqrt_work.self)
    #elseif os(macOS)
    static let zgeqrt_work: FunctionType.LAPACKE_zgeqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt2_work: FunctionType.LAPACKE_sgeqrt2_work? = load(name: "LAPACKE_sgeqrt2_work", as: FunctionType.LAPACKE_sgeqrt2_work.self)
    #elseif os(macOS)
    static let sgeqrt2_work: FunctionType.LAPACKE_sgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt2_work: FunctionType.LAPACKE_dgeqrt2_work? = load(name: "LAPACKE_dgeqrt2_work", as: FunctionType.LAPACKE_dgeqrt2_work.self)
    #elseif os(macOS)
    static let dgeqrt2_work: FunctionType.LAPACKE_dgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt2_work: FunctionType.LAPACKE_cgeqrt2_work? = load(name: "LAPACKE_cgeqrt2_work", as: FunctionType.LAPACKE_cgeqrt2_work.self)
    #elseif os(macOS)
    static let cgeqrt2_work: FunctionType.LAPACKE_cgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt2_work: FunctionType.LAPACKE_zgeqrt2_work? = load(name: "LAPACKE_zgeqrt2_work", as: FunctionType.LAPACKE_zgeqrt2_work.self)
    #elseif os(macOS)
    static let zgeqrt2_work: FunctionType.LAPACKE_zgeqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqrt3_work: FunctionType.LAPACKE_sgeqrt3_work? = load(name: "LAPACKE_sgeqrt3_work", as: FunctionType.LAPACKE_sgeqrt3_work.self)
    #elseif os(macOS)
    static let sgeqrt3_work: FunctionType.LAPACKE_sgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqrt3_work: FunctionType.LAPACKE_dgeqrt3_work? = load(name: "LAPACKE_dgeqrt3_work", as: FunctionType.LAPACKE_dgeqrt3_work.self)
    #elseif os(macOS)
    static let dgeqrt3_work: FunctionType.LAPACKE_dgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqrt3_work: FunctionType.LAPACKE_cgeqrt3_work? = load(name: "LAPACKE_cgeqrt3_work", as: FunctionType.LAPACKE_cgeqrt3_work.self)
    #elseif os(macOS)
    static let cgeqrt3_work: FunctionType.LAPACKE_cgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqrt3_work: FunctionType.LAPACKE_zgeqrt3_work? = load(name: "LAPACKE_zgeqrt3_work", as: FunctionType.LAPACKE_zgeqrt3_work.self)
    #elseif os(macOS)
    static let zgeqrt3_work: FunctionType.LAPACKE_zgeqrt3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpmqrt_work: FunctionType.LAPACKE_stpmqrt_work? = load(name: "LAPACKE_stpmqrt_work", as: FunctionType.LAPACKE_stpmqrt_work.self)
    #elseif os(macOS)
    static let stpmqrt_work: FunctionType.LAPACKE_stpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpmqrt_work: FunctionType.LAPACKE_dtpmqrt_work? = load(name: "LAPACKE_dtpmqrt_work", as: FunctionType.LAPACKE_dtpmqrt_work.self)
    #elseif os(macOS)
    static let dtpmqrt_work: FunctionType.LAPACKE_dtpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpmqrt_work: FunctionType.LAPACKE_ctpmqrt_work? = load(name: "LAPACKE_ctpmqrt_work", as: FunctionType.LAPACKE_ctpmqrt_work.self)
    #elseif os(macOS)
    static let ctpmqrt_work: FunctionType.LAPACKE_ctpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpmqrt_work: FunctionType.LAPACKE_ztpmqrt_work? = load(name: "LAPACKE_ztpmqrt_work", as: FunctionType.LAPACKE_ztpmqrt_work.self)
    #elseif os(macOS)
    static let ztpmqrt_work: FunctionType.LAPACKE_ztpmqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt_work: FunctionType.LAPACKE_stpqrt_work? = load(name: "LAPACKE_stpqrt_work", as: FunctionType.LAPACKE_stpqrt_work.self)
    #elseif os(macOS)
    static let stpqrt_work: FunctionType.LAPACKE_stpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt_work: FunctionType.LAPACKE_dtpqrt_work? = load(name: "LAPACKE_dtpqrt_work", as: FunctionType.LAPACKE_dtpqrt_work.self)
    #elseif os(macOS)
    static let dtpqrt_work: FunctionType.LAPACKE_dtpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt_work: FunctionType.LAPACKE_ctpqrt_work? = load(name: "LAPACKE_ctpqrt_work", as: FunctionType.LAPACKE_ctpqrt_work.self)
    #elseif os(macOS)
    static let ctpqrt_work: FunctionType.LAPACKE_ctpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt_work: FunctionType.LAPACKE_ztpqrt_work? = load(name: "LAPACKE_ztpqrt_work", as: FunctionType.LAPACKE_ztpqrt_work.self)
    #elseif os(macOS)
    static let ztpqrt_work: FunctionType.LAPACKE_ztpqrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stpqrt2_work: FunctionType.LAPACKE_stpqrt2_work? = load(name: "LAPACKE_stpqrt2_work", as: FunctionType.LAPACKE_stpqrt2_work.self)
    #elseif os(macOS)
    static let stpqrt2_work: FunctionType.LAPACKE_stpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtpqrt2_work: FunctionType.LAPACKE_dtpqrt2_work? = load(name: "LAPACKE_dtpqrt2_work", as: FunctionType.LAPACKE_dtpqrt2_work.self)
    #elseif os(macOS)
    static let dtpqrt2_work: FunctionType.LAPACKE_dtpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctpqrt2_work: FunctionType.LAPACKE_ctpqrt2_work? = load(name: "LAPACKE_ctpqrt2_work", as: FunctionType.LAPACKE_ctpqrt2_work.self)
    #elseif os(macOS)
    static let ctpqrt2_work: FunctionType.LAPACKE_ctpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztpqrt2_work: FunctionType.LAPACKE_ztpqrt2_work? = load(name: "LAPACKE_ztpqrt2_work", as: FunctionType.LAPACKE_ztpqrt2_work.self)
    #elseif os(macOS)
    static let ztpqrt2_work: FunctionType.LAPACKE_ztpqrt2_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let stprfb_work: FunctionType.LAPACKE_stprfb_work? = load(name: "LAPACKE_stprfb_work", as: FunctionType.LAPACKE_stprfb_work.self)
    #elseif os(macOS)
    static let stprfb_work: FunctionType.LAPACKE_stprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dtprfb_work: FunctionType.LAPACKE_dtprfb_work? = load(name: "LAPACKE_dtprfb_work", as: FunctionType.LAPACKE_dtprfb_work.self)
    #elseif os(macOS)
    static let dtprfb_work: FunctionType.LAPACKE_dtprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ctprfb_work: FunctionType.LAPACKE_ctprfb_work? = load(name: "LAPACKE_ctprfb_work", as: FunctionType.LAPACKE_ctprfb_work.self)
    #elseif os(macOS)
    static let ctprfb_work: FunctionType.LAPACKE_ctprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ztprfb_work: FunctionType.LAPACKE_ztprfb_work? = load(name: "LAPACKE_ztprfb_work", as: FunctionType.LAPACKE_ztprfb_work.self)
    #elseif os(macOS)
    static let ztprfb_work: FunctionType.LAPACKE_ztprfb_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rook: FunctionType.LAPACKE_ssysv_rook? = load(name: "LAPACKE_ssysv_rook", as: FunctionType.LAPACKE_ssysv_rook.self)
    #elseif os(macOS)
    static let ssysv_rook: FunctionType.LAPACKE_ssysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rook: FunctionType.LAPACKE_dsysv_rook? = load(name: "LAPACKE_dsysv_rook", as: FunctionType.LAPACKE_dsysv_rook.self)
    #elseif os(macOS)
    static let dsysv_rook: FunctionType.LAPACKE_dsysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rook: FunctionType.LAPACKE_csysv_rook? = load(name: "LAPACKE_csysv_rook", as: FunctionType.LAPACKE_csysv_rook.self)
    #elseif os(macOS)
    static let csysv_rook: FunctionType.LAPACKE_csysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rook: FunctionType.LAPACKE_zsysv_rook? = load(name: "LAPACKE_zsysv_rook", as: FunctionType.LAPACKE_zsysv_rook.self)
    #elseif os(macOS)
    static let zsysv_rook: FunctionType.LAPACKE_zsysv_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rook: FunctionType.LAPACKE_ssytrf_rook? = load(name: "LAPACKE_ssytrf_rook", as: FunctionType.LAPACKE_ssytrf_rook.self)
    #elseif os(macOS)
    static let ssytrf_rook: FunctionType.LAPACKE_ssytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rook: FunctionType.LAPACKE_dsytrf_rook? = load(name: "LAPACKE_dsytrf_rook", as: FunctionType.LAPACKE_dsytrf_rook.self)
    #elseif os(macOS)
    static let dsytrf_rook: FunctionType.LAPACKE_dsytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rook: FunctionType.LAPACKE_csytrf_rook? = load(name: "LAPACKE_csytrf_rook", as: FunctionType.LAPACKE_csytrf_rook.self)
    #elseif os(macOS)
    static let csytrf_rook: FunctionType.LAPACKE_csytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rook: FunctionType.LAPACKE_zsytrf_rook? = load(name: "LAPACKE_zsytrf_rook", as: FunctionType.LAPACKE_zsytrf_rook.self)
    #elseif os(macOS)
    static let zsytrf_rook: FunctionType.LAPACKE_zsytrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_rook: FunctionType.LAPACKE_ssytrs_rook? = load(name: "LAPACKE_ssytrs_rook", as: FunctionType.LAPACKE_ssytrs_rook.self)
    #elseif os(macOS)
    static let ssytrs_rook: FunctionType.LAPACKE_ssytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_rook: FunctionType.LAPACKE_dsytrs_rook? = load(name: "LAPACKE_dsytrs_rook", as: FunctionType.LAPACKE_dsytrs_rook.self)
    #elseif os(macOS)
    static let dsytrs_rook: FunctionType.LAPACKE_dsytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_rook: FunctionType.LAPACKE_csytrs_rook? = load(name: "LAPACKE_csytrs_rook", as: FunctionType.LAPACKE_csytrs_rook.self)
    #elseif os(macOS)
    static let csytrs_rook: FunctionType.LAPACKE_csytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_rook: FunctionType.LAPACKE_zsytrs_rook? = load(name: "LAPACKE_zsytrs_rook", as: FunctionType.LAPACKE_zsytrs_rook.self)
    #elseif os(macOS)
    static let zsytrs_rook: FunctionType.LAPACKE_zsytrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rook: FunctionType.LAPACKE_chetrf_rook? = load(name: "LAPACKE_chetrf_rook", as: FunctionType.LAPACKE_chetrf_rook.self)
    #elseif os(macOS)
    static let chetrf_rook: FunctionType.LAPACKE_chetrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rook: FunctionType.LAPACKE_zhetrf_rook? = load(name: "LAPACKE_zhetrf_rook", as: FunctionType.LAPACKE_zhetrf_rook.self)
    #elseif os(macOS)
    static let zhetrf_rook: FunctionType.LAPACKE_zhetrf_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_rook: FunctionType.LAPACKE_chetrs_rook? = load(name: "LAPACKE_chetrs_rook", as: FunctionType.LAPACKE_chetrs_rook.self)
    #elseif os(macOS)
    static let chetrs_rook: FunctionType.LAPACKE_chetrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_rook: FunctionType.LAPACKE_zhetrs_rook? = load(name: "LAPACKE_zhetrs_rook", as: FunctionType.LAPACKE_zhetrs_rook.self)
    #elseif os(macOS)
    static let zhetrs_rook: FunctionType.LAPACKE_zhetrs_rook? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rook_work: FunctionType.LAPACKE_ssysv_rook_work? = load(name: "LAPACKE_ssysv_rook_work", as: FunctionType.LAPACKE_ssysv_rook_work.self)
    #elseif os(macOS)
    static let ssysv_rook_work: FunctionType.LAPACKE_ssysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rook_work: FunctionType.LAPACKE_dsysv_rook_work? = load(name: "LAPACKE_dsysv_rook_work", as: FunctionType.LAPACKE_dsysv_rook_work.self)
    #elseif os(macOS)
    static let dsysv_rook_work: FunctionType.LAPACKE_dsysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rook_work: FunctionType.LAPACKE_csysv_rook_work? = load(name: "LAPACKE_csysv_rook_work", as: FunctionType.LAPACKE_csysv_rook_work.self)
    #elseif os(macOS)
    static let csysv_rook_work: FunctionType.LAPACKE_csysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rook_work: FunctionType.LAPACKE_zsysv_rook_work? = load(name: "LAPACKE_zsysv_rook_work", as: FunctionType.LAPACKE_zsysv_rook_work.self)
    #elseif os(macOS)
    static let zsysv_rook_work: FunctionType.LAPACKE_zsysv_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rook_work: FunctionType.LAPACKE_ssytrf_rook_work? = load(name: "LAPACKE_ssytrf_rook_work", as: FunctionType.LAPACKE_ssytrf_rook_work.self)
    #elseif os(macOS)
    static let ssytrf_rook_work: FunctionType.LAPACKE_ssytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rook_work: FunctionType.LAPACKE_dsytrf_rook_work? = load(name: "LAPACKE_dsytrf_rook_work", as: FunctionType.LAPACKE_dsytrf_rook_work.self)
    #elseif os(macOS)
    static let dsytrf_rook_work: FunctionType.LAPACKE_dsytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rook_work: FunctionType.LAPACKE_csytrf_rook_work? = load(name: "LAPACKE_csytrf_rook_work", as: FunctionType.LAPACKE_csytrf_rook_work.self)
    #elseif os(macOS)
    static let csytrf_rook_work: FunctionType.LAPACKE_csytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rook_work: FunctionType.LAPACKE_zsytrf_rook_work? = load(name: "LAPACKE_zsytrf_rook_work", as: FunctionType.LAPACKE_zsytrf_rook_work.self)
    #elseif os(macOS)
    static let zsytrf_rook_work: FunctionType.LAPACKE_zsytrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_rook_work: FunctionType.LAPACKE_ssytrs_rook_work? = load(name: "LAPACKE_ssytrs_rook_work", as: FunctionType.LAPACKE_ssytrs_rook_work.self)
    #elseif os(macOS)
    static let ssytrs_rook_work: FunctionType.LAPACKE_ssytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_rook_work: FunctionType.LAPACKE_dsytrs_rook_work? = load(name: "LAPACKE_dsytrs_rook_work", as: FunctionType.LAPACKE_dsytrs_rook_work.self)
    #elseif os(macOS)
    static let dsytrs_rook_work: FunctionType.LAPACKE_dsytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_rook_work: FunctionType.LAPACKE_csytrs_rook_work? = load(name: "LAPACKE_csytrs_rook_work", as: FunctionType.LAPACKE_csytrs_rook_work.self)
    #elseif os(macOS)
    static let csytrs_rook_work: FunctionType.LAPACKE_csytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_rook_work: FunctionType.LAPACKE_zsytrs_rook_work? = load(name: "LAPACKE_zsytrs_rook_work", as: FunctionType.LAPACKE_zsytrs_rook_work.self)
    #elseif os(macOS)
    static let zsytrs_rook_work: FunctionType.LAPACKE_zsytrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rook_work: FunctionType.LAPACKE_chetrf_rook_work? = load(name: "LAPACKE_chetrf_rook_work", as: FunctionType.LAPACKE_chetrf_rook_work.self)
    #elseif os(macOS)
    static let chetrf_rook_work: FunctionType.LAPACKE_chetrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rook_work: FunctionType.LAPACKE_zhetrf_rook_work? = load(name: "LAPACKE_zhetrf_rook_work", as: FunctionType.LAPACKE_zhetrf_rook_work.self)
    #elseif os(macOS)
    static let zhetrf_rook_work: FunctionType.LAPACKE_zhetrf_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_rook_work: FunctionType.LAPACKE_chetrs_rook_work? = load(name: "LAPACKE_chetrs_rook_work", as: FunctionType.LAPACKE_chetrs_rook_work.self)
    #elseif os(macOS)
    static let chetrs_rook_work: FunctionType.LAPACKE_chetrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_rook_work: FunctionType.LAPACKE_zhetrs_rook_work? = load(name: "LAPACKE_zhetrs_rook_work", as: FunctionType.LAPACKE_zhetrs_rook_work.self)
    #elseif os(macOS)
    static let zhetrs_rook_work: FunctionType.LAPACKE_zhetrs_rook_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ilaver: FunctionType.LAPACKE_ilaver? = load(name: "LAPACKE_ilaver", as: FunctionType.LAPACKE_ilaver.self)
    #elseif os(macOS)
    static let ilaver: FunctionType.LAPACKE_ilaver? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa: FunctionType.LAPACKE_ssysv_aa? = load(name: "LAPACKE_ssysv_aa", as: FunctionType.LAPACKE_ssysv_aa.self)
    #elseif os(macOS)
    static let ssysv_aa: FunctionType.LAPACKE_ssysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa_work: FunctionType.LAPACKE_ssysv_aa_work? = load(name: "LAPACKE_ssysv_aa_work", as: FunctionType.LAPACKE_ssysv_aa_work.self)
    #elseif os(macOS)
    static let ssysv_aa_work: FunctionType.LAPACKE_ssysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa: FunctionType.LAPACKE_dsysv_aa? = load(name: "LAPACKE_dsysv_aa", as: FunctionType.LAPACKE_dsysv_aa.self)
    #elseif os(macOS)
    static let dsysv_aa: FunctionType.LAPACKE_dsysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa_work: FunctionType.LAPACKE_dsysv_aa_work? = load(name: "LAPACKE_dsysv_aa_work", as: FunctionType.LAPACKE_dsysv_aa_work.self)
    #elseif os(macOS)
    static let dsysv_aa_work: FunctionType.LAPACKE_dsysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa: FunctionType.LAPACKE_csysv_aa? = load(name: "LAPACKE_csysv_aa", as: FunctionType.LAPACKE_csysv_aa.self)
    #elseif os(macOS)
    static let csysv_aa: FunctionType.LAPACKE_csysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa_work: FunctionType.LAPACKE_csysv_aa_work? = load(name: "LAPACKE_csysv_aa_work", as: FunctionType.LAPACKE_csysv_aa_work.self)
    #elseif os(macOS)
    static let csysv_aa_work: FunctionType.LAPACKE_csysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa: FunctionType.LAPACKE_zsysv_aa? = load(name: "LAPACKE_zsysv_aa", as: FunctionType.LAPACKE_zsysv_aa.self)
    #elseif os(macOS)
    static let zsysv_aa: FunctionType.LAPACKE_zsysv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa_work: FunctionType.LAPACKE_zsysv_aa_work? = load(name: "LAPACKE_zsysv_aa_work", as: FunctionType.LAPACKE_zsysv_aa_work.self)
    #elseif os(macOS)
    static let zsysv_aa_work: FunctionType.LAPACKE_zsysv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa: FunctionType.LAPACKE_chesv_aa? = load(name: "LAPACKE_chesv_aa", as: FunctionType.LAPACKE_chesv_aa.self)
    #elseif os(macOS)
    static let chesv_aa: FunctionType.LAPACKE_chesv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa_work: FunctionType.LAPACKE_chesv_aa_work? = load(name: "LAPACKE_chesv_aa_work", as: FunctionType.LAPACKE_chesv_aa_work.self)
    #elseif os(macOS)
    static let chesv_aa_work: FunctionType.LAPACKE_chesv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa: FunctionType.LAPACKE_zhesv_aa? = load(name: "LAPACKE_zhesv_aa", as: FunctionType.LAPACKE_zhesv_aa.self)
    #elseif os(macOS)
    static let zhesv_aa: FunctionType.LAPACKE_zhesv_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa_work: FunctionType.LAPACKE_zhesv_aa_work? = load(name: "LAPACKE_zhesv_aa_work", as: FunctionType.LAPACKE_zhesv_aa_work.self)
    #elseif os(macOS)
    static let zhesv_aa_work: FunctionType.LAPACKE_zhesv_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa: FunctionType.LAPACKE_ssytrf_aa? = load(name: "LAPACKE_ssytrf_aa", as: FunctionType.LAPACKE_ssytrf_aa.self)
    #elseif os(macOS)
    static let ssytrf_aa: FunctionType.LAPACKE_ssytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa: FunctionType.LAPACKE_dsytrf_aa? = load(name: "LAPACKE_dsytrf_aa", as: FunctionType.LAPACKE_dsytrf_aa.self)
    #elseif os(macOS)
    static let dsytrf_aa: FunctionType.LAPACKE_dsytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa: FunctionType.LAPACKE_csytrf_aa? = load(name: "LAPACKE_csytrf_aa", as: FunctionType.LAPACKE_csytrf_aa.self)
    #elseif os(macOS)
    static let csytrf_aa: FunctionType.LAPACKE_csytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa: FunctionType.LAPACKE_zsytrf_aa? = load(name: "LAPACKE_zsytrf_aa", as: FunctionType.LAPACKE_zsytrf_aa.self)
    #elseif os(macOS)
    static let zsytrf_aa: FunctionType.LAPACKE_zsytrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa: FunctionType.LAPACKE_chetrf_aa? = load(name: "LAPACKE_chetrf_aa", as: FunctionType.LAPACKE_chetrf_aa.self)
    #elseif os(macOS)
    static let chetrf_aa: FunctionType.LAPACKE_chetrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa: FunctionType.LAPACKE_zhetrf_aa? = load(name: "LAPACKE_zhetrf_aa", as: FunctionType.LAPACKE_zhetrf_aa.self)
    #elseif os(macOS)
    static let zhetrf_aa: FunctionType.LAPACKE_zhetrf_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa_work: FunctionType.LAPACKE_ssytrf_aa_work? = load(name: "LAPACKE_ssytrf_aa_work", as: FunctionType.LAPACKE_ssytrf_aa_work.self)
    #elseif os(macOS)
    static let ssytrf_aa_work: FunctionType.LAPACKE_ssytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa_work: FunctionType.LAPACKE_dsytrf_aa_work? = load(name: "LAPACKE_dsytrf_aa_work", as: FunctionType.LAPACKE_dsytrf_aa_work.self)
    #elseif os(macOS)
    static let dsytrf_aa_work: FunctionType.LAPACKE_dsytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa_work: FunctionType.LAPACKE_csytrf_aa_work? = load(name: "LAPACKE_csytrf_aa_work", as: FunctionType.LAPACKE_csytrf_aa_work.self)
    #elseif os(macOS)
    static let csytrf_aa_work: FunctionType.LAPACKE_csytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa_work: FunctionType.LAPACKE_zsytrf_aa_work? = load(name: "LAPACKE_zsytrf_aa_work", as: FunctionType.LAPACKE_zsytrf_aa_work.self)
    #elseif os(macOS)
    static let zsytrf_aa_work: FunctionType.LAPACKE_zsytrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa_work: FunctionType.LAPACKE_chetrf_aa_work? = load(name: "LAPACKE_chetrf_aa_work", as: FunctionType.LAPACKE_chetrf_aa_work.self)
    #elseif os(macOS)
    static let chetrf_aa_work: FunctionType.LAPACKE_chetrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa_work: FunctionType.LAPACKE_zhetrf_aa_work? = load(name: "LAPACKE_zhetrf_aa_work", as: FunctionType.LAPACKE_zhetrf_aa_work.self)
    #elseif os(macOS)
    static let zhetrf_aa_work: FunctionType.LAPACKE_zhetrf_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa: FunctionType.LAPACKE_csytrs_aa? = load(name: "LAPACKE_csytrs_aa", as: FunctionType.LAPACKE_csytrs_aa.self)
    #elseif os(macOS)
    static let csytrs_aa: FunctionType.LAPACKE_csytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa_work: FunctionType.LAPACKE_csytrs_aa_work? = load(name: "LAPACKE_csytrs_aa_work", as: FunctionType.LAPACKE_csytrs_aa_work.self)
    #elseif os(macOS)
    static let csytrs_aa_work: FunctionType.LAPACKE_csytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa: FunctionType.LAPACKE_chetrs_aa? = load(name: "LAPACKE_chetrs_aa", as: FunctionType.LAPACKE_chetrs_aa.self)
    #elseif os(macOS)
    static let chetrs_aa: FunctionType.LAPACKE_chetrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa_work: FunctionType.LAPACKE_chetrs_aa_work? = load(name: "LAPACKE_chetrs_aa_work", as: FunctionType.LAPACKE_chetrs_aa_work.self)
    #elseif os(macOS)
    static let chetrs_aa_work: FunctionType.LAPACKE_chetrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa: FunctionType.LAPACKE_dsytrs_aa? = load(name: "LAPACKE_dsytrs_aa", as: FunctionType.LAPACKE_dsytrs_aa.self)
    #elseif os(macOS)
    static let dsytrs_aa: FunctionType.LAPACKE_dsytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa_work: FunctionType.LAPACKE_dsytrs_aa_work? = load(name: "LAPACKE_dsytrs_aa_work", as: FunctionType.LAPACKE_dsytrs_aa_work.self)
    #elseif os(macOS)
    static let dsytrs_aa_work: FunctionType.LAPACKE_dsytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa: FunctionType.LAPACKE_ssytrs_aa? = load(name: "LAPACKE_ssytrs_aa", as: FunctionType.LAPACKE_ssytrs_aa.self)
    #elseif os(macOS)
    static let ssytrs_aa: FunctionType.LAPACKE_ssytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa_work: FunctionType.LAPACKE_ssytrs_aa_work? = load(name: "LAPACKE_ssytrs_aa_work", as: FunctionType.LAPACKE_ssytrs_aa_work.self)
    #elseif os(macOS)
    static let ssytrs_aa_work: FunctionType.LAPACKE_ssytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa: FunctionType.LAPACKE_zsytrs_aa? = load(name: "LAPACKE_zsytrs_aa", as: FunctionType.LAPACKE_zsytrs_aa.self)
    #elseif os(macOS)
    static let zsytrs_aa: FunctionType.LAPACKE_zsytrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa_work: FunctionType.LAPACKE_zsytrs_aa_work? = load(name: "LAPACKE_zsytrs_aa_work", as: FunctionType.LAPACKE_zsytrs_aa_work.self)
    #elseif os(macOS)
    static let zsytrs_aa_work: FunctionType.LAPACKE_zsytrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa: FunctionType.LAPACKE_zhetrs_aa? = load(name: "LAPACKE_zhetrs_aa", as: FunctionType.LAPACKE_zhetrs_aa.self)
    #elseif os(macOS)
    static let zhetrs_aa: FunctionType.LAPACKE_zhetrs_aa? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa_work: FunctionType.LAPACKE_zhetrs_aa_work? = load(name: "LAPACKE_zhetrs_aa_work", as: FunctionType.LAPACKE_zhetrs_aa_work.self)
    #elseif os(macOS)
    static let zhetrs_aa_work: FunctionType.LAPACKE_zhetrs_aa_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rk: FunctionType.LAPACKE_ssysv_rk? = load(name: "LAPACKE_ssysv_rk", as: FunctionType.LAPACKE_ssysv_rk.self)
    #elseif os(macOS)
    static let ssysv_rk: FunctionType.LAPACKE_ssysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_rk_work: FunctionType.LAPACKE_ssysv_rk_work? = load(name: "LAPACKE_ssysv_rk_work", as: FunctionType.LAPACKE_ssysv_rk_work.self)
    #elseif os(macOS)
    static let ssysv_rk_work: FunctionType.LAPACKE_ssysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rk: FunctionType.LAPACKE_dsysv_rk? = load(name: "LAPACKE_dsysv_rk", as: FunctionType.LAPACKE_dsysv_rk.self)
    #elseif os(macOS)
    static let dsysv_rk: FunctionType.LAPACKE_dsysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_rk_work: FunctionType.LAPACKE_dsysv_rk_work? = load(name: "LAPACKE_dsysv_rk_work", as: FunctionType.LAPACKE_dsysv_rk_work.self)
    #elseif os(macOS)
    static let dsysv_rk_work: FunctionType.LAPACKE_dsysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rk: FunctionType.LAPACKE_csysv_rk? = load(name: "LAPACKE_csysv_rk", as: FunctionType.LAPACKE_csysv_rk.self)
    #elseif os(macOS)
    static let csysv_rk: FunctionType.LAPACKE_csysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_rk_work: FunctionType.LAPACKE_csysv_rk_work? = load(name: "LAPACKE_csysv_rk_work", as: FunctionType.LAPACKE_csysv_rk_work.self)
    #elseif os(macOS)
    static let csysv_rk_work: FunctionType.LAPACKE_csysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rk: FunctionType.LAPACKE_zsysv_rk? = load(name: "LAPACKE_zsysv_rk", as: FunctionType.LAPACKE_zsysv_rk.self)
    #elseif os(macOS)
    static let zsysv_rk: FunctionType.LAPACKE_zsysv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_rk_work: FunctionType.LAPACKE_zsysv_rk_work? = load(name: "LAPACKE_zsysv_rk_work", as: FunctionType.LAPACKE_zsysv_rk_work.self)
    #elseif os(macOS)
    static let zsysv_rk_work: FunctionType.LAPACKE_zsysv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_rk: FunctionType.LAPACKE_chesv_rk? = load(name: "LAPACKE_chesv_rk", as: FunctionType.LAPACKE_chesv_rk.self)
    #elseif os(macOS)
    static let chesv_rk: FunctionType.LAPACKE_chesv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_rk_work: FunctionType.LAPACKE_chesv_rk_work? = load(name: "LAPACKE_chesv_rk_work", as: FunctionType.LAPACKE_chesv_rk_work.self)
    #elseif os(macOS)
    static let chesv_rk_work: FunctionType.LAPACKE_chesv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_rk: FunctionType.LAPACKE_zhesv_rk? = load(name: "LAPACKE_zhesv_rk", as: FunctionType.LAPACKE_zhesv_rk.self)
    #elseif os(macOS)
    static let zhesv_rk: FunctionType.LAPACKE_zhesv_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_rk_work: FunctionType.LAPACKE_zhesv_rk_work? = load(name: "LAPACKE_zhesv_rk_work", as: FunctionType.LAPACKE_zhesv_rk_work.self)
    #elseif os(macOS)
    static let zhesv_rk_work: FunctionType.LAPACKE_zhesv_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rk: FunctionType.LAPACKE_ssytrf_rk? = load(name: "LAPACKE_ssytrf_rk", as: FunctionType.LAPACKE_ssytrf_rk.self)
    #elseif os(macOS)
    static let ssytrf_rk: FunctionType.LAPACKE_ssytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rk: FunctionType.LAPACKE_dsytrf_rk? = load(name: "LAPACKE_dsytrf_rk", as: FunctionType.LAPACKE_dsytrf_rk.self)
    #elseif os(macOS)
    static let dsytrf_rk: FunctionType.LAPACKE_dsytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rk: FunctionType.LAPACKE_csytrf_rk? = load(name: "LAPACKE_csytrf_rk", as: FunctionType.LAPACKE_csytrf_rk.self)
    #elseif os(macOS)
    static let csytrf_rk: FunctionType.LAPACKE_csytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rk: FunctionType.LAPACKE_zsytrf_rk? = load(name: "LAPACKE_zsytrf_rk", as: FunctionType.LAPACKE_zsytrf_rk.self)
    #elseif os(macOS)
    static let zsytrf_rk: FunctionType.LAPACKE_zsytrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rk: FunctionType.LAPACKE_chetrf_rk? = load(name: "LAPACKE_chetrf_rk", as: FunctionType.LAPACKE_chetrf_rk.self)
    #elseif os(macOS)
    static let chetrf_rk: FunctionType.LAPACKE_chetrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rk: FunctionType.LAPACKE_zhetrf_rk? = load(name: "LAPACKE_zhetrf_rk", as: FunctionType.LAPACKE_zhetrf_rk.self)
    #elseif os(macOS)
    static let zhetrf_rk: FunctionType.LAPACKE_zhetrf_rk? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_rk_work: FunctionType.LAPACKE_ssytrf_rk_work? = load(name: "LAPACKE_ssytrf_rk_work", as: FunctionType.LAPACKE_ssytrf_rk_work.self)
    #elseif os(macOS)
    static let ssytrf_rk_work: FunctionType.LAPACKE_ssytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_rk_work: FunctionType.LAPACKE_dsytrf_rk_work? = load(name: "LAPACKE_dsytrf_rk_work", as: FunctionType.LAPACKE_dsytrf_rk_work.self)
    #elseif os(macOS)
    static let dsytrf_rk_work: FunctionType.LAPACKE_dsytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_rk_work: FunctionType.LAPACKE_csytrf_rk_work? = load(name: "LAPACKE_csytrf_rk_work", as: FunctionType.LAPACKE_csytrf_rk_work.self)
    #elseif os(macOS)
    static let csytrf_rk_work: FunctionType.LAPACKE_csytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_rk_work: FunctionType.LAPACKE_zsytrf_rk_work? = load(name: "LAPACKE_zsytrf_rk_work", as: FunctionType.LAPACKE_zsytrf_rk_work.self)
    #elseif os(macOS)
    static let zsytrf_rk_work: FunctionType.LAPACKE_zsytrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_rk_work: FunctionType.LAPACKE_chetrf_rk_work? = load(name: "LAPACKE_chetrf_rk_work", as: FunctionType.LAPACKE_chetrf_rk_work.self)
    #elseif os(macOS)
    static let chetrf_rk_work: FunctionType.LAPACKE_chetrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_rk_work: FunctionType.LAPACKE_zhetrf_rk_work? = load(name: "LAPACKE_zhetrf_rk_work", as: FunctionType.LAPACKE_zhetrf_rk_work.self)
    #elseif os(macOS)
    static let zhetrf_rk_work: FunctionType.LAPACKE_zhetrf_rk_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_3: FunctionType.LAPACKE_csytrs_3? = load(name: "LAPACKE_csytrs_3", as: FunctionType.LAPACKE_csytrs_3.self)
    #elseif os(macOS)
    static let csytrs_3: FunctionType.LAPACKE_csytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_3_work: FunctionType.LAPACKE_csytrs_3_work? = load(name: "LAPACKE_csytrs_3_work", as: FunctionType.LAPACKE_csytrs_3_work.self)
    #elseif os(macOS)
    static let csytrs_3_work: FunctionType.LAPACKE_csytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_3: FunctionType.LAPACKE_chetrs_3? = load(name: "LAPACKE_chetrs_3", as: FunctionType.LAPACKE_chetrs_3.self)
    #elseif os(macOS)
    static let chetrs_3: FunctionType.LAPACKE_chetrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_3_work: FunctionType.LAPACKE_chetrs_3_work? = load(name: "LAPACKE_chetrs_3_work", as: FunctionType.LAPACKE_chetrs_3_work.self)
    #elseif os(macOS)
    static let chetrs_3_work: FunctionType.LAPACKE_chetrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_3: FunctionType.LAPACKE_dsytrs_3? = load(name: "LAPACKE_dsytrs_3", as: FunctionType.LAPACKE_dsytrs_3.self)
    #elseif os(macOS)
    static let dsytrs_3: FunctionType.LAPACKE_dsytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_3_work: FunctionType.LAPACKE_dsytrs_3_work? = load(name: "LAPACKE_dsytrs_3_work", as: FunctionType.LAPACKE_dsytrs_3_work.self)
    #elseif os(macOS)
    static let dsytrs_3_work: FunctionType.LAPACKE_dsytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_3: FunctionType.LAPACKE_ssytrs_3? = load(name: "LAPACKE_ssytrs_3", as: FunctionType.LAPACKE_ssytrs_3.self)
    #elseif os(macOS)
    static let ssytrs_3: FunctionType.LAPACKE_ssytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_3_work: FunctionType.LAPACKE_ssytrs_3_work? = load(name: "LAPACKE_ssytrs_3_work", as: FunctionType.LAPACKE_ssytrs_3_work.self)
    #elseif os(macOS)
    static let ssytrs_3_work: FunctionType.LAPACKE_ssytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_3: FunctionType.LAPACKE_zsytrs_3? = load(name: "LAPACKE_zsytrs_3", as: FunctionType.LAPACKE_zsytrs_3.self)
    #elseif os(macOS)
    static let zsytrs_3: FunctionType.LAPACKE_zsytrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_3_work: FunctionType.LAPACKE_zsytrs_3_work? = load(name: "LAPACKE_zsytrs_3_work", as: FunctionType.LAPACKE_zsytrs_3_work.self)
    #elseif os(macOS)
    static let zsytrs_3_work: FunctionType.LAPACKE_zsytrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_3: FunctionType.LAPACKE_zhetrs_3? = load(name: "LAPACKE_zhetrs_3", as: FunctionType.LAPACKE_zhetrs_3.self)
    #elseif os(macOS)
    static let zhetrs_3: FunctionType.LAPACKE_zhetrs_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_3_work: FunctionType.LAPACKE_zhetrs_3_work? = load(name: "LAPACKE_zhetrs_3_work", as: FunctionType.LAPACKE_zhetrs_3_work.self)
    #elseif os(macOS)
    static let zhetrs_3_work: FunctionType.LAPACKE_zhetrs_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri_3: FunctionType.LAPACKE_ssytri_3? = load(name: "LAPACKE_ssytri_3", as: FunctionType.LAPACKE_ssytri_3.self)
    #elseif os(macOS)
    static let ssytri_3: FunctionType.LAPACKE_ssytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri_3: FunctionType.LAPACKE_dsytri_3? = load(name: "LAPACKE_dsytri_3", as: FunctionType.LAPACKE_dsytri_3.self)
    #elseif os(macOS)
    static let dsytri_3: FunctionType.LAPACKE_dsytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri_3: FunctionType.LAPACKE_csytri_3? = load(name: "LAPACKE_csytri_3", as: FunctionType.LAPACKE_csytri_3.self)
    #elseif os(macOS)
    static let csytri_3: FunctionType.LAPACKE_csytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri_3: FunctionType.LAPACKE_zsytri_3? = load(name: "LAPACKE_zsytri_3", as: FunctionType.LAPACKE_zsytri_3.self)
    #elseif os(macOS)
    static let zsytri_3: FunctionType.LAPACKE_zsytri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri_3: FunctionType.LAPACKE_chetri_3? = load(name: "LAPACKE_chetri_3", as: FunctionType.LAPACKE_chetri_3.self)
    #elseif os(macOS)
    static let chetri_3: FunctionType.LAPACKE_chetri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri_3: FunctionType.LAPACKE_zhetri_3? = load(name: "LAPACKE_zhetri_3", as: FunctionType.LAPACKE_zhetri_3.self)
    #elseif os(macOS)
    static let zhetri_3: FunctionType.LAPACKE_zhetri_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytri_3_work: FunctionType.LAPACKE_ssytri_3_work? = load(name: "LAPACKE_ssytri_3_work", as: FunctionType.LAPACKE_ssytri_3_work.self)
    #elseif os(macOS)
    static let ssytri_3_work: FunctionType.LAPACKE_ssytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytri_3_work: FunctionType.LAPACKE_dsytri_3_work? = load(name: "LAPACKE_dsytri_3_work", as: FunctionType.LAPACKE_dsytri_3_work.self)
    #elseif os(macOS)
    static let dsytri_3_work: FunctionType.LAPACKE_dsytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytri_3_work: FunctionType.LAPACKE_csytri_3_work? = load(name: "LAPACKE_csytri_3_work", as: FunctionType.LAPACKE_csytri_3_work.self)
    #elseif os(macOS)
    static let csytri_3_work: FunctionType.LAPACKE_csytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytri_3_work: FunctionType.LAPACKE_zsytri_3_work? = load(name: "LAPACKE_zsytri_3_work", as: FunctionType.LAPACKE_zsytri_3_work.self)
    #elseif os(macOS)
    static let zsytri_3_work: FunctionType.LAPACKE_zsytri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetri_3_work: FunctionType.LAPACKE_chetri_3_work? = load(name: "LAPACKE_chetri_3_work", as: FunctionType.LAPACKE_chetri_3_work.self)
    #elseif os(macOS)
    static let chetri_3_work: FunctionType.LAPACKE_chetri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetri_3_work: FunctionType.LAPACKE_zhetri_3_work? = load(name: "LAPACKE_zhetri_3_work", as: FunctionType.LAPACKE_zhetri_3_work.self)
    #elseif os(macOS)
    static let zhetri_3_work: FunctionType.LAPACKE_zhetri_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon_3: FunctionType.LAPACKE_ssycon_3? = load(name: "LAPACKE_ssycon_3", as: FunctionType.LAPACKE_ssycon_3.self)
    #elseif os(macOS)
    static let ssycon_3: FunctionType.LAPACKE_ssycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon_3: FunctionType.LAPACKE_dsycon_3? = load(name: "LAPACKE_dsycon_3", as: FunctionType.LAPACKE_dsycon_3.self)
    #elseif os(macOS)
    static let dsycon_3: FunctionType.LAPACKE_dsycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon_3: FunctionType.LAPACKE_csycon_3? = load(name: "LAPACKE_csycon_3", as: FunctionType.LAPACKE_csycon_3.self)
    #elseif os(macOS)
    static let csycon_3: FunctionType.LAPACKE_csycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon_3: FunctionType.LAPACKE_zsycon_3? = load(name: "LAPACKE_zsycon_3", as: FunctionType.LAPACKE_zsycon_3.self)
    #elseif os(macOS)
    static let zsycon_3: FunctionType.LAPACKE_zsycon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon_3: FunctionType.LAPACKE_checon_3? = load(name: "LAPACKE_checon_3", as: FunctionType.LAPACKE_checon_3.self)
    #elseif os(macOS)
    static let checon_3: FunctionType.LAPACKE_checon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon_3: FunctionType.LAPACKE_zhecon_3? = load(name: "LAPACKE_zhecon_3", as: FunctionType.LAPACKE_zhecon_3.self)
    #elseif os(macOS)
    static let zhecon_3: FunctionType.LAPACKE_zhecon_3? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssycon_3_work: FunctionType.LAPACKE_ssycon_3_work? = load(name: "LAPACKE_ssycon_3_work", as: FunctionType.LAPACKE_ssycon_3_work.self)
    #elseif os(macOS)
    static let ssycon_3_work: FunctionType.LAPACKE_ssycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsycon_3_work: FunctionType.LAPACKE_dsycon_3_work? = load(name: "LAPACKE_dsycon_3_work", as: FunctionType.LAPACKE_dsycon_3_work.self)
    #elseif os(macOS)
    static let dsycon_3_work: FunctionType.LAPACKE_dsycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csycon_3_work: FunctionType.LAPACKE_csycon_3_work? = load(name: "LAPACKE_csycon_3_work", as: FunctionType.LAPACKE_csycon_3_work.self)
    #elseif os(macOS)
    static let csycon_3_work: FunctionType.LAPACKE_csycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsycon_3_work: FunctionType.LAPACKE_zsycon_3_work? = load(name: "LAPACKE_zsycon_3_work", as: FunctionType.LAPACKE_zsycon_3_work.self)
    #elseif os(macOS)
    static let zsycon_3_work: FunctionType.LAPACKE_zsycon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let checon_3_work: FunctionType.LAPACKE_checon_3_work? = load(name: "LAPACKE_checon_3_work", as: FunctionType.LAPACKE_checon_3_work.self)
    #elseif os(macOS)
    static let checon_3_work: FunctionType.LAPACKE_checon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhecon_3_work: FunctionType.LAPACKE_zhecon_3_work? = load(name: "LAPACKE_zhecon_3_work", as: FunctionType.LAPACKE_zhecon_3_work.self)
    #elseif os(macOS)
    static let zhecon_3_work: FunctionType.LAPACKE_zhecon_3_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq: FunctionType.LAPACKE_sgelq? = load(name: "LAPACKE_sgelq", as: FunctionType.LAPACKE_sgelq.self)
    #elseif os(macOS)
    static let sgelq: FunctionType.LAPACKE_sgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq: FunctionType.LAPACKE_dgelq? = load(name: "LAPACKE_dgelq", as: FunctionType.LAPACKE_dgelq.self)
    #elseif os(macOS)
    static let dgelq: FunctionType.LAPACKE_dgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq: FunctionType.LAPACKE_cgelq? = load(name: "LAPACKE_cgelq", as: FunctionType.LAPACKE_cgelq.self)
    #elseif os(macOS)
    static let cgelq: FunctionType.LAPACKE_cgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq: FunctionType.LAPACKE_zgelq? = load(name: "LAPACKE_zgelq", as: FunctionType.LAPACKE_zgelq.self)
    #elseif os(macOS)
    static let zgelq: FunctionType.LAPACKE_zgelq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgelq_work: FunctionType.LAPACKE_sgelq_work? = load(name: "LAPACKE_sgelq_work", as: FunctionType.LAPACKE_sgelq_work.self)
    #elseif os(macOS)
    static let sgelq_work: FunctionType.LAPACKE_sgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgelq_work: FunctionType.LAPACKE_dgelq_work? = load(name: "LAPACKE_dgelq_work", as: FunctionType.LAPACKE_dgelq_work.self)
    #elseif os(macOS)
    static let dgelq_work: FunctionType.LAPACKE_dgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgelq_work: FunctionType.LAPACKE_cgelq_work? = load(name: "LAPACKE_cgelq_work", as: FunctionType.LAPACKE_cgelq_work.self)
    #elseif os(macOS)
    static let cgelq_work: FunctionType.LAPACKE_cgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgelq_work: FunctionType.LAPACKE_zgelq_work? = load(name: "LAPACKE_zgelq_work", as: FunctionType.LAPACKE_zgelq_work.self)
    #elseif os(macOS)
    static let zgelq_work: FunctionType.LAPACKE_zgelq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemlq: FunctionType.LAPACKE_sgemlq? = load(name: "LAPACKE_sgemlq", as: FunctionType.LAPACKE_sgemlq.self)
    #elseif os(macOS)
    static let sgemlq: FunctionType.LAPACKE_sgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemlq: FunctionType.LAPACKE_dgemlq? = load(name: "LAPACKE_dgemlq", as: FunctionType.LAPACKE_dgemlq.self)
    #elseif os(macOS)
    static let dgemlq: FunctionType.LAPACKE_dgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemlq: FunctionType.LAPACKE_cgemlq? = load(name: "LAPACKE_cgemlq", as: FunctionType.LAPACKE_cgemlq.self)
    #elseif os(macOS)
    static let cgemlq: FunctionType.LAPACKE_cgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemlq: FunctionType.LAPACKE_zgemlq? = load(name: "LAPACKE_zgemlq", as: FunctionType.LAPACKE_zgemlq.self)
    #elseif os(macOS)
    static let zgemlq: FunctionType.LAPACKE_zgemlq? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemlq_work: FunctionType.LAPACKE_sgemlq_work? = load(name: "LAPACKE_sgemlq_work", as: FunctionType.LAPACKE_sgemlq_work.self)
    #elseif os(macOS)
    static let sgemlq_work: FunctionType.LAPACKE_sgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemlq_work: FunctionType.LAPACKE_dgemlq_work? = load(name: "LAPACKE_dgemlq_work", as: FunctionType.LAPACKE_dgemlq_work.self)
    #elseif os(macOS)
    static let dgemlq_work: FunctionType.LAPACKE_dgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemlq_work: FunctionType.LAPACKE_cgemlq_work? = load(name: "LAPACKE_cgemlq_work", as: FunctionType.LAPACKE_cgemlq_work.self)
    #elseif os(macOS)
    static let cgemlq_work: FunctionType.LAPACKE_cgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemlq_work: FunctionType.LAPACKE_zgemlq_work? = load(name: "LAPACKE_zgemlq_work", as: FunctionType.LAPACKE_zgemlq_work.self)
    #elseif os(macOS)
    static let zgemlq_work: FunctionType.LAPACKE_zgemlq_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr: FunctionType.LAPACKE_sgeqr? = load(name: "LAPACKE_sgeqr", as: FunctionType.LAPACKE_sgeqr.self)
    #elseif os(macOS)
    static let sgeqr: FunctionType.LAPACKE_sgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr: FunctionType.LAPACKE_dgeqr? = load(name: "LAPACKE_dgeqr", as: FunctionType.LAPACKE_dgeqr.self)
    #elseif os(macOS)
    static let dgeqr: FunctionType.LAPACKE_dgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr: FunctionType.LAPACKE_cgeqr? = load(name: "LAPACKE_cgeqr", as: FunctionType.LAPACKE_cgeqr.self)
    #elseif os(macOS)
    static let cgeqr: FunctionType.LAPACKE_cgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr: FunctionType.LAPACKE_zgeqr? = load(name: "LAPACKE_zgeqr", as: FunctionType.LAPACKE_zgeqr.self)
    #elseif os(macOS)
    static let zgeqr: FunctionType.LAPACKE_zgeqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgeqr_work: FunctionType.LAPACKE_sgeqr_work? = load(name: "LAPACKE_sgeqr_work", as: FunctionType.LAPACKE_sgeqr_work.self)
    #elseif os(macOS)
    static let sgeqr_work: FunctionType.LAPACKE_sgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgeqr_work: FunctionType.LAPACKE_dgeqr_work? = load(name: "LAPACKE_dgeqr_work", as: FunctionType.LAPACKE_dgeqr_work.self)
    #elseif os(macOS)
    static let dgeqr_work: FunctionType.LAPACKE_dgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgeqr_work: FunctionType.LAPACKE_cgeqr_work? = load(name: "LAPACKE_cgeqr_work", as: FunctionType.LAPACKE_cgeqr_work.self)
    #elseif os(macOS)
    static let cgeqr_work: FunctionType.LAPACKE_cgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgeqr_work: FunctionType.LAPACKE_zgeqr_work? = load(name: "LAPACKE_zgeqr_work", as: FunctionType.LAPACKE_zgeqr_work.self)
    #elseif os(macOS)
    static let zgeqr_work: FunctionType.LAPACKE_zgeqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqr: FunctionType.LAPACKE_sgemqr? = load(name: "LAPACKE_sgemqr", as: FunctionType.LAPACKE_sgemqr.self)
    #elseif os(macOS)
    static let sgemqr: FunctionType.LAPACKE_sgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqr: FunctionType.LAPACKE_dgemqr? = load(name: "LAPACKE_dgemqr", as: FunctionType.LAPACKE_dgemqr.self)
    #elseif os(macOS)
    static let dgemqr: FunctionType.LAPACKE_dgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqr: FunctionType.LAPACKE_cgemqr? = load(name: "LAPACKE_cgemqr", as: FunctionType.LAPACKE_cgemqr.self)
    #elseif os(macOS)
    static let cgemqr: FunctionType.LAPACKE_cgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqr: FunctionType.LAPACKE_zgemqr? = load(name: "LAPACKE_zgemqr", as: FunctionType.LAPACKE_zgemqr.self)
    #elseif os(macOS)
    static let zgemqr: FunctionType.LAPACKE_zgemqr? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgemqr_work: FunctionType.LAPACKE_sgemqr_work? = load(name: "LAPACKE_sgemqr_work", as: FunctionType.LAPACKE_sgemqr_work.self)
    #elseif os(macOS)
    static let sgemqr_work: FunctionType.LAPACKE_sgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgemqr_work: FunctionType.LAPACKE_dgemqr_work? = load(name: "LAPACKE_dgemqr_work", as: FunctionType.LAPACKE_dgemqr_work.self)
    #elseif os(macOS)
    static let dgemqr_work: FunctionType.LAPACKE_dgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgemqr_work: FunctionType.LAPACKE_cgemqr_work? = load(name: "LAPACKE_cgemqr_work", as: FunctionType.LAPACKE_cgemqr_work.self)
    #elseif os(macOS)
    static let cgemqr_work: FunctionType.LAPACKE_cgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgemqr_work: FunctionType.LAPACKE_zgemqr_work? = load(name: "LAPACKE_zgemqr_work", as: FunctionType.LAPACKE_zgemqr_work.self)
    #elseif os(macOS)
    static let zgemqr_work: FunctionType.LAPACKE_zgemqr_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsls: FunctionType.LAPACKE_sgetsls? = load(name: "LAPACKE_sgetsls", as: FunctionType.LAPACKE_sgetsls.self)
    #elseif os(macOS)
    static let sgetsls: FunctionType.LAPACKE_sgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsls: FunctionType.LAPACKE_dgetsls? = load(name: "LAPACKE_dgetsls", as: FunctionType.LAPACKE_dgetsls.self)
    #elseif os(macOS)
    static let dgetsls: FunctionType.LAPACKE_dgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsls: FunctionType.LAPACKE_cgetsls? = load(name: "LAPACKE_cgetsls", as: FunctionType.LAPACKE_cgetsls.self)
    #elseif os(macOS)
    static let cgetsls: FunctionType.LAPACKE_cgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsls: FunctionType.LAPACKE_zgetsls? = load(name: "LAPACKE_zgetsls", as: FunctionType.LAPACKE_zgetsls.self)
    #elseif os(macOS)
    static let zgetsls: FunctionType.LAPACKE_zgetsls? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsls_work: FunctionType.LAPACKE_sgetsls_work? = load(name: "LAPACKE_sgetsls_work", as: FunctionType.LAPACKE_sgetsls_work.self)
    #elseif os(macOS)
    static let sgetsls_work: FunctionType.LAPACKE_sgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsls_work: FunctionType.LAPACKE_dgetsls_work? = load(name: "LAPACKE_dgetsls_work", as: FunctionType.LAPACKE_dgetsls_work.self)
    #elseif os(macOS)
    static let dgetsls_work: FunctionType.LAPACKE_dgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsls_work: FunctionType.LAPACKE_cgetsls_work? = load(name: "LAPACKE_cgetsls_work", as: FunctionType.LAPACKE_cgetsls_work.self)
    #elseif os(macOS)
    static let cgetsls_work: FunctionType.LAPACKE_cgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsls_work: FunctionType.LAPACKE_zgetsls_work? = load(name: "LAPACKE_zgetsls_work", as: FunctionType.LAPACKE_zgetsls_work.self)
    #elseif os(macOS)
    static let zgetsls_work: FunctionType.LAPACKE_zgetsls_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsqrhrt: FunctionType.LAPACKE_sgetsqrhrt? = load(name: "LAPACKE_sgetsqrhrt", as: FunctionType.LAPACKE_sgetsqrhrt.self)
    #elseif os(macOS)
    static let sgetsqrhrt: FunctionType.LAPACKE_sgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsqrhrt: FunctionType.LAPACKE_dgetsqrhrt? = load(name: "LAPACKE_dgetsqrhrt", as: FunctionType.LAPACKE_dgetsqrhrt.self)
    #elseif os(macOS)
    static let dgetsqrhrt: FunctionType.LAPACKE_dgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsqrhrt: FunctionType.LAPACKE_cgetsqrhrt? = load(name: "LAPACKE_cgetsqrhrt", as: FunctionType.LAPACKE_cgetsqrhrt.self)
    #elseif os(macOS)
    static let cgetsqrhrt: FunctionType.LAPACKE_cgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsqrhrt: FunctionType.LAPACKE_zgetsqrhrt? = load(name: "LAPACKE_zgetsqrhrt", as: FunctionType.LAPACKE_zgetsqrhrt.self)
    #elseif os(macOS)
    static let zgetsqrhrt: FunctionType.LAPACKE_zgetsqrhrt? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sgetsqrhrt_work: FunctionType.LAPACKE_sgetsqrhrt_work? = load(name: "LAPACKE_sgetsqrhrt_work", as: FunctionType.LAPACKE_sgetsqrhrt_work.self)
    #elseif os(macOS)
    static let sgetsqrhrt_work: FunctionType.LAPACKE_sgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dgetsqrhrt_work: FunctionType.LAPACKE_dgetsqrhrt_work? = load(name: "LAPACKE_dgetsqrhrt_work", as: FunctionType.LAPACKE_dgetsqrhrt_work.self)
    #elseif os(macOS)
    static let dgetsqrhrt_work: FunctionType.LAPACKE_dgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cgetsqrhrt_work: FunctionType.LAPACKE_cgetsqrhrt_work? = load(name: "LAPACKE_cgetsqrhrt_work", as: FunctionType.LAPACKE_cgetsqrhrt_work.self)
    #elseif os(macOS)
    static let cgetsqrhrt_work: FunctionType.LAPACKE_cgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zgetsqrhrt_work: FunctionType.LAPACKE_zgetsqrhrt_work? = load(name: "LAPACKE_zgetsqrhrt_work", as: FunctionType.LAPACKE_zgetsqrhrt_work.self)
    #elseif os(macOS)
    static let zgetsqrhrt_work: FunctionType.LAPACKE_zgetsqrhrt_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev_2stage: FunctionType.LAPACKE_ssyev_2stage? = load(name: "LAPACKE_ssyev_2stage", as: FunctionType.LAPACKE_ssyev_2stage.self)
    #elseif os(macOS)
    static let ssyev_2stage: FunctionType.LAPACKE_ssyev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev_2stage: FunctionType.LAPACKE_dsyev_2stage? = load(name: "LAPACKE_dsyev_2stage", as: FunctionType.LAPACKE_dsyev_2stage.self)
    #elseif os(macOS)
    static let dsyev_2stage: FunctionType.LAPACKE_dsyev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd_2stage: FunctionType.LAPACKE_ssyevd_2stage? = load(name: "LAPACKE_ssyevd_2stage", as: FunctionType.LAPACKE_ssyevd_2stage.self)
    #elseif os(macOS)
    static let ssyevd_2stage: FunctionType.LAPACKE_ssyevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd_2stage: FunctionType.LAPACKE_dsyevd_2stage? = load(name: "LAPACKE_dsyevd_2stage", as: FunctionType.LAPACKE_dsyevd_2stage.self)
    #elseif os(macOS)
    static let dsyevd_2stage: FunctionType.LAPACKE_dsyevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr_2stage: FunctionType.LAPACKE_ssyevr_2stage? = load(name: "LAPACKE_ssyevr_2stage", as: FunctionType.LAPACKE_ssyevr_2stage.self)
    #elseif os(macOS)
    static let ssyevr_2stage: FunctionType.LAPACKE_ssyevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr_2stage: FunctionType.LAPACKE_dsyevr_2stage? = load(name: "LAPACKE_dsyevr_2stage", as: FunctionType.LAPACKE_dsyevr_2stage.self)
    #elseif os(macOS)
    static let dsyevr_2stage: FunctionType.LAPACKE_dsyevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx_2stage: FunctionType.LAPACKE_ssyevx_2stage? = load(name: "LAPACKE_ssyevx_2stage", as: FunctionType.LAPACKE_ssyevx_2stage.self)
    #elseif os(macOS)
    static let ssyevx_2stage: FunctionType.LAPACKE_ssyevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx_2stage: FunctionType.LAPACKE_dsyevx_2stage? = load(name: "LAPACKE_dsyevx_2stage", as: FunctionType.LAPACKE_dsyevx_2stage.self)
    #elseif os(macOS)
    static let dsyevx_2stage: FunctionType.LAPACKE_dsyevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyev_2stage_work: FunctionType.LAPACKE_ssyev_2stage_work? = load(name: "LAPACKE_ssyev_2stage_work", as: FunctionType.LAPACKE_ssyev_2stage_work.self)
    #elseif os(macOS)
    static let ssyev_2stage_work: FunctionType.LAPACKE_ssyev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyev_2stage_work: FunctionType.LAPACKE_dsyev_2stage_work? = load(name: "LAPACKE_dsyev_2stage_work", as: FunctionType.LAPACKE_dsyev_2stage_work.self)
    #elseif os(macOS)
    static let dsyev_2stage_work: FunctionType.LAPACKE_dsyev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevd_2stage_work: FunctionType.LAPACKE_ssyevd_2stage_work? = load(name: "LAPACKE_ssyevd_2stage_work", as: FunctionType.LAPACKE_ssyevd_2stage_work.self)
    #elseif os(macOS)
    static let ssyevd_2stage_work: FunctionType.LAPACKE_ssyevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevd_2stage_work: FunctionType.LAPACKE_dsyevd_2stage_work? = load(name: "LAPACKE_dsyevd_2stage_work", as: FunctionType.LAPACKE_dsyevd_2stage_work.self)
    #elseif os(macOS)
    static let dsyevd_2stage_work: FunctionType.LAPACKE_dsyevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevr_2stage_work: FunctionType.LAPACKE_ssyevr_2stage_work? = load(name: "LAPACKE_ssyevr_2stage_work", as: FunctionType.LAPACKE_ssyevr_2stage_work.self)
    #elseif os(macOS)
    static let ssyevr_2stage_work: FunctionType.LAPACKE_ssyevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevr_2stage_work: FunctionType.LAPACKE_dsyevr_2stage_work? = load(name: "LAPACKE_dsyevr_2stage_work", as: FunctionType.LAPACKE_dsyevr_2stage_work.self)
    #elseif os(macOS)
    static let dsyevr_2stage_work: FunctionType.LAPACKE_dsyevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssyevx_2stage_work: FunctionType.LAPACKE_ssyevx_2stage_work? = load(name: "LAPACKE_ssyevx_2stage_work", as: FunctionType.LAPACKE_ssyevx_2stage_work.self)
    #elseif os(macOS)
    static let ssyevx_2stage_work: FunctionType.LAPACKE_ssyevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsyevx_2stage_work: FunctionType.LAPACKE_dsyevx_2stage_work? = load(name: "LAPACKE_dsyevx_2stage_work", as: FunctionType.LAPACKE_dsyevx_2stage_work.self)
    #elseif os(macOS)
    static let dsyevx_2stage_work: FunctionType.LAPACKE_dsyevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev_2stage: FunctionType.LAPACKE_cheev_2stage? = load(name: "LAPACKE_cheev_2stage", as: FunctionType.LAPACKE_cheev_2stage.self)
    #elseif os(macOS)
    static let cheev_2stage: FunctionType.LAPACKE_cheev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev_2stage: FunctionType.LAPACKE_zheev_2stage? = load(name: "LAPACKE_zheev_2stage", as: FunctionType.LAPACKE_zheev_2stage.self)
    #elseif os(macOS)
    static let zheev_2stage: FunctionType.LAPACKE_zheev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd_2stage: FunctionType.LAPACKE_cheevd_2stage? = load(name: "LAPACKE_cheevd_2stage", as: FunctionType.LAPACKE_cheevd_2stage.self)
    #elseif os(macOS)
    static let cheevd_2stage: FunctionType.LAPACKE_cheevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd_2stage: FunctionType.LAPACKE_zheevd_2stage? = load(name: "LAPACKE_zheevd_2stage", as: FunctionType.LAPACKE_zheevd_2stage.self)
    #elseif os(macOS)
    static let zheevd_2stage: FunctionType.LAPACKE_zheevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr_2stage: FunctionType.LAPACKE_cheevr_2stage? = load(name: "LAPACKE_cheevr_2stage", as: FunctionType.LAPACKE_cheevr_2stage.self)
    #elseif os(macOS)
    static let cheevr_2stage: FunctionType.LAPACKE_cheevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr_2stage: FunctionType.LAPACKE_zheevr_2stage? = load(name: "LAPACKE_zheevr_2stage", as: FunctionType.LAPACKE_zheevr_2stage.self)
    #elseif os(macOS)
    static let zheevr_2stage: FunctionType.LAPACKE_zheevr_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx_2stage: FunctionType.LAPACKE_cheevx_2stage? = load(name: "LAPACKE_cheevx_2stage", as: FunctionType.LAPACKE_cheevx_2stage.self)
    #elseif os(macOS)
    static let cheevx_2stage: FunctionType.LAPACKE_cheevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx_2stage: FunctionType.LAPACKE_zheevx_2stage? = load(name: "LAPACKE_zheevx_2stage", as: FunctionType.LAPACKE_zheevx_2stage.self)
    #elseif os(macOS)
    static let zheevx_2stage: FunctionType.LAPACKE_zheevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheev_2stage_work: FunctionType.LAPACKE_cheev_2stage_work? = load(name: "LAPACKE_cheev_2stage_work", as: FunctionType.LAPACKE_cheev_2stage_work.self)
    #elseif os(macOS)
    static let cheev_2stage_work: FunctionType.LAPACKE_cheev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheev_2stage_work: FunctionType.LAPACKE_zheev_2stage_work? = load(name: "LAPACKE_zheev_2stage_work", as: FunctionType.LAPACKE_zheev_2stage_work.self)
    #elseif os(macOS)
    static let zheev_2stage_work: FunctionType.LAPACKE_zheev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevd_2stage_work: FunctionType.LAPACKE_cheevd_2stage_work? = load(name: "LAPACKE_cheevd_2stage_work", as: FunctionType.LAPACKE_cheevd_2stage_work.self)
    #elseif os(macOS)
    static let cheevd_2stage_work: FunctionType.LAPACKE_cheevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevd_2stage_work: FunctionType.LAPACKE_zheevd_2stage_work? = load(name: "LAPACKE_zheevd_2stage_work", as: FunctionType.LAPACKE_zheevd_2stage_work.self)
    #elseif os(macOS)
    static let zheevd_2stage_work: FunctionType.LAPACKE_zheevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevr_2stage_work: FunctionType.LAPACKE_cheevr_2stage_work? = load(name: "LAPACKE_cheevr_2stage_work", as: FunctionType.LAPACKE_cheevr_2stage_work.self)
    #elseif os(macOS)
    static let cheevr_2stage_work: FunctionType.LAPACKE_cheevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevr_2stage_work: FunctionType.LAPACKE_zheevr_2stage_work? = load(name: "LAPACKE_zheevr_2stage_work", as: FunctionType.LAPACKE_zheevr_2stage_work.self)
    #elseif os(macOS)
    static let zheevr_2stage_work: FunctionType.LAPACKE_zheevr_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cheevx_2stage_work: FunctionType.LAPACKE_cheevx_2stage_work? = load(name: "LAPACKE_cheevx_2stage_work", as: FunctionType.LAPACKE_cheevx_2stage_work.self)
    #elseif os(macOS)
    static let cheevx_2stage_work: FunctionType.LAPACKE_cheevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zheevx_2stage_work: FunctionType.LAPACKE_zheevx_2stage_work? = load(name: "LAPACKE_zheevx_2stage_work", as: FunctionType.LAPACKE_zheevx_2stage_work.self)
    #elseif os(macOS)
    static let zheevx_2stage_work: FunctionType.LAPACKE_zheevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev_2stage: FunctionType.LAPACKE_ssbev_2stage? = load(name: "LAPACKE_ssbev_2stage", as: FunctionType.LAPACKE_ssbev_2stage.self)
    #elseif os(macOS)
    static let ssbev_2stage: FunctionType.LAPACKE_ssbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev_2stage: FunctionType.LAPACKE_dsbev_2stage? = load(name: "LAPACKE_dsbev_2stage", as: FunctionType.LAPACKE_dsbev_2stage.self)
    #elseif os(macOS)
    static let dsbev_2stage: FunctionType.LAPACKE_dsbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd_2stage: FunctionType.LAPACKE_ssbevd_2stage? = load(name: "LAPACKE_ssbevd_2stage", as: FunctionType.LAPACKE_ssbevd_2stage.self)
    #elseif os(macOS)
    static let ssbevd_2stage: FunctionType.LAPACKE_ssbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd_2stage: FunctionType.LAPACKE_dsbevd_2stage? = load(name: "LAPACKE_dsbevd_2stage", as: FunctionType.LAPACKE_dsbevd_2stage.self)
    #elseif os(macOS)
    static let dsbevd_2stage: FunctionType.LAPACKE_dsbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx_2stage: FunctionType.LAPACKE_ssbevx_2stage? = load(name: "LAPACKE_ssbevx_2stage", as: FunctionType.LAPACKE_ssbevx_2stage.self)
    #elseif os(macOS)
    static let ssbevx_2stage: FunctionType.LAPACKE_ssbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx_2stage: FunctionType.LAPACKE_dsbevx_2stage? = load(name: "LAPACKE_dsbevx_2stage", as: FunctionType.LAPACKE_dsbevx_2stage.self)
    #elseif os(macOS)
    static let dsbevx_2stage: FunctionType.LAPACKE_dsbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbev_2stage_work: FunctionType.LAPACKE_ssbev_2stage_work? = load(name: "LAPACKE_ssbev_2stage_work", as: FunctionType.LAPACKE_ssbev_2stage_work.self)
    #elseif os(macOS)
    static let ssbev_2stage_work: FunctionType.LAPACKE_ssbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbev_2stage_work: FunctionType.LAPACKE_dsbev_2stage_work? = load(name: "LAPACKE_dsbev_2stage_work", as: FunctionType.LAPACKE_dsbev_2stage_work.self)
    #elseif os(macOS)
    static let dsbev_2stage_work: FunctionType.LAPACKE_dsbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevd_2stage_work: FunctionType.LAPACKE_ssbevd_2stage_work? = load(name: "LAPACKE_ssbevd_2stage_work", as: FunctionType.LAPACKE_ssbevd_2stage_work.self)
    #elseif os(macOS)
    static let ssbevd_2stage_work: FunctionType.LAPACKE_ssbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevd_2stage_work: FunctionType.LAPACKE_dsbevd_2stage_work? = load(name: "LAPACKE_dsbevd_2stage_work", as: FunctionType.LAPACKE_dsbevd_2stage_work.self)
    #elseif os(macOS)
    static let dsbevd_2stage_work: FunctionType.LAPACKE_dsbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssbevx_2stage_work: FunctionType.LAPACKE_ssbevx_2stage_work? = load(name: "LAPACKE_ssbevx_2stage_work", as: FunctionType.LAPACKE_ssbevx_2stage_work.self)
    #elseif os(macOS)
    static let ssbevx_2stage_work: FunctionType.LAPACKE_ssbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsbevx_2stage_work: FunctionType.LAPACKE_dsbevx_2stage_work? = load(name: "LAPACKE_dsbevx_2stage_work", as: FunctionType.LAPACKE_dsbevx_2stage_work.self)
    #elseif os(macOS)
    static let dsbevx_2stage_work: FunctionType.LAPACKE_dsbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev_2stage: FunctionType.LAPACKE_chbev_2stage? = load(name: "LAPACKE_chbev_2stage", as: FunctionType.LAPACKE_chbev_2stage.self)
    #elseif os(macOS)
    static let chbev_2stage: FunctionType.LAPACKE_chbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev_2stage: FunctionType.LAPACKE_zhbev_2stage? = load(name: "LAPACKE_zhbev_2stage", as: FunctionType.LAPACKE_zhbev_2stage.self)
    #elseif os(macOS)
    static let zhbev_2stage: FunctionType.LAPACKE_zhbev_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd_2stage: FunctionType.LAPACKE_chbevd_2stage? = load(name: "LAPACKE_chbevd_2stage", as: FunctionType.LAPACKE_chbevd_2stage.self)
    #elseif os(macOS)
    static let chbevd_2stage: FunctionType.LAPACKE_chbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd_2stage: FunctionType.LAPACKE_zhbevd_2stage? = load(name: "LAPACKE_zhbevd_2stage", as: FunctionType.LAPACKE_zhbevd_2stage.self)
    #elseif os(macOS)
    static let zhbevd_2stage: FunctionType.LAPACKE_zhbevd_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx_2stage: FunctionType.LAPACKE_chbevx_2stage? = load(name: "LAPACKE_chbevx_2stage", as: FunctionType.LAPACKE_chbevx_2stage.self)
    #elseif os(macOS)
    static let chbevx_2stage: FunctionType.LAPACKE_chbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx_2stage: FunctionType.LAPACKE_zhbevx_2stage? = load(name: "LAPACKE_zhbevx_2stage", as: FunctionType.LAPACKE_zhbevx_2stage.self)
    #elseif os(macOS)
    static let zhbevx_2stage: FunctionType.LAPACKE_zhbevx_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbev_2stage_work: FunctionType.LAPACKE_chbev_2stage_work? = load(name: "LAPACKE_chbev_2stage_work", as: FunctionType.LAPACKE_chbev_2stage_work.self)
    #elseif os(macOS)
    static let chbev_2stage_work: FunctionType.LAPACKE_chbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbev_2stage_work: FunctionType.LAPACKE_zhbev_2stage_work? = load(name: "LAPACKE_zhbev_2stage_work", as: FunctionType.LAPACKE_zhbev_2stage_work.self)
    #elseif os(macOS)
    static let zhbev_2stage_work: FunctionType.LAPACKE_zhbev_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevd_2stage_work: FunctionType.LAPACKE_chbevd_2stage_work? = load(name: "LAPACKE_chbevd_2stage_work", as: FunctionType.LAPACKE_chbevd_2stage_work.self)
    #elseif os(macOS)
    static let chbevd_2stage_work: FunctionType.LAPACKE_chbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevd_2stage_work: FunctionType.LAPACKE_zhbevd_2stage_work? = load(name: "LAPACKE_zhbevd_2stage_work", as: FunctionType.LAPACKE_zhbevd_2stage_work.self)
    #elseif os(macOS)
    static let zhbevd_2stage_work: FunctionType.LAPACKE_zhbevd_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chbevx_2stage_work: FunctionType.LAPACKE_chbevx_2stage_work? = load(name: "LAPACKE_chbevx_2stage_work", as: FunctionType.LAPACKE_chbevx_2stage_work.self)
    #elseif os(macOS)
    static let chbevx_2stage_work: FunctionType.LAPACKE_chbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhbevx_2stage_work: FunctionType.LAPACKE_zhbevx_2stage_work? = load(name: "LAPACKE_zhbevx_2stage_work", as: FunctionType.LAPACKE_zhbevx_2stage_work.self)
    #elseif os(macOS)
    static let zhbevx_2stage_work: FunctionType.LAPACKE_zhbevx_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv_2stage: FunctionType.LAPACKE_ssygv_2stage? = load(name: "LAPACKE_ssygv_2stage", as: FunctionType.LAPACKE_ssygv_2stage.self)
    #elseif os(macOS)
    static let ssygv_2stage: FunctionType.LAPACKE_ssygv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv_2stage: FunctionType.LAPACKE_dsygv_2stage? = load(name: "LAPACKE_dsygv_2stage", as: FunctionType.LAPACKE_dsygv_2stage.self)
    #elseif os(macOS)
    static let dsygv_2stage: FunctionType.LAPACKE_dsygv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssygv_2stage_work: FunctionType.LAPACKE_ssygv_2stage_work? = load(name: "LAPACKE_ssygv_2stage_work", as: FunctionType.LAPACKE_ssygv_2stage_work.self)
    #elseif os(macOS)
    static let ssygv_2stage_work: FunctionType.LAPACKE_ssygv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsygv_2stage_work: FunctionType.LAPACKE_dsygv_2stage_work? = load(name: "LAPACKE_dsygv_2stage_work", as: FunctionType.LAPACKE_dsygv_2stage_work.self)
    #elseif os(macOS)
    static let dsygv_2stage_work: FunctionType.LAPACKE_dsygv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv_2stage: FunctionType.LAPACKE_chegv_2stage? = load(name: "LAPACKE_chegv_2stage", as: FunctionType.LAPACKE_chegv_2stage.self)
    #elseif os(macOS)
    static let chegv_2stage: FunctionType.LAPACKE_chegv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv_2stage: FunctionType.LAPACKE_zhegv_2stage? = load(name: "LAPACKE_zhegv_2stage", as: FunctionType.LAPACKE_zhegv_2stage.self)
    #elseif os(macOS)
    static let zhegv_2stage: FunctionType.LAPACKE_zhegv_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chegv_2stage_work: FunctionType.LAPACKE_chegv_2stage_work? = load(name: "LAPACKE_chegv_2stage_work", as: FunctionType.LAPACKE_chegv_2stage_work.self)
    #elseif os(macOS)
    static let chegv_2stage_work: FunctionType.LAPACKE_chegv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhegv_2stage_work: FunctionType.LAPACKE_zhegv_2stage_work? = load(name: "LAPACKE_zhegv_2stage_work", as: FunctionType.LAPACKE_zhegv_2stage_work.self)
    #elseif os(macOS)
    static let zhegv_2stage_work: FunctionType.LAPACKE_zhegv_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa_2stage: FunctionType.LAPACKE_ssysv_aa_2stage? = load(name: "LAPACKE_ssysv_aa_2stage", as: FunctionType.LAPACKE_ssysv_aa_2stage.self)
    #elseif os(macOS)
    static let ssysv_aa_2stage: FunctionType.LAPACKE_ssysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssysv_aa_2stage_work: FunctionType.LAPACKE_ssysv_aa_2stage_work? = load(name: "LAPACKE_ssysv_aa_2stage_work", as: FunctionType.LAPACKE_ssysv_aa_2stage_work.self)
    #elseif os(macOS)
    static let ssysv_aa_2stage_work: FunctionType.LAPACKE_ssysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa_2stage: FunctionType.LAPACKE_dsysv_aa_2stage? = load(name: "LAPACKE_dsysv_aa_2stage", as: FunctionType.LAPACKE_dsysv_aa_2stage.self)
    #elseif os(macOS)
    static let dsysv_aa_2stage: FunctionType.LAPACKE_dsysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsysv_aa_2stage_work: FunctionType.LAPACKE_dsysv_aa_2stage_work? = load(name: "LAPACKE_dsysv_aa_2stage_work", as: FunctionType.LAPACKE_dsysv_aa_2stage_work.self)
    #elseif os(macOS)
    static let dsysv_aa_2stage_work: FunctionType.LAPACKE_dsysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa_2stage: FunctionType.LAPACKE_csysv_aa_2stage? = load(name: "LAPACKE_csysv_aa_2stage", as: FunctionType.LAPACKE_csysv_aa_2stage.self)
    #elseif os(macOS)
    static let csysv_aa_2stage: FunctionType.LAPACKE_csysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csysv_aa_2stage_work: FunctionType.LAPACKE_csysv_aa_2stage_work? = load(name: "LAPACKE_csysv_aa_2stage_work", as: FunctionType.LAPACKE_csysv_aa_2stage_work.self)
    #elseif os(macOS)
    static let csysv_aa_2stage_work: FunctionType.LAPACKE_csysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa_2stage: FunctionType.LAPACKE_zsysv_aa_2stage? = load(name: "LAPACKE_zsysv_aa_2stage", as: FunctionType.LAPACKE_zsysv_aa_2stage.self)
    #elseif os(macOS)
    static let zsysv_aa_2stage: FunctionType.LAPACKE_zsysv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsysv_aa_2stage_work: FunctionType.LAPACKE_zsysv_aa_2stage_work? = load(name: "LAPACKE_zsysv_aa_2stage_work", as: FunctionType.LAPACKE_zsysv_aa_2stage_work.self)
    #elseif os(macOS)
    static let zsysv_aa_2stage_work: FunctionType.LAPACKE_zsysv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa_2stage: FunctionType.LAPACKE_chesv_aa_2stage? = load(name: "LAPACKE_chesv_aa_2stage", as: FunctionType.LAPACKE_chesv_aa_2stage.self)
    #elseif os(macOS)
    static let chesv_aa_2stage: FunctionType.LAPACKE_chesv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chesv_aa_2stage_work: FunctionType.LAPACKE_chesv_aa_2stage_work? = load(name: "LAPACKE_chesv_aa_2stage_work", as: FunctionType.LAPACKE_chesv_aa_2stage_work.self)
    #elseif os(macOS)
    static let chesv_aa_2stage_work: FunctionType.LAPACKE_chesv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa_2stage: FunctionType.LAPACKE_zhesv_aa_2stage? = load(name: "LAPACKE_zhesv_aa_2stage", as: FunctionType.LAPACKE_zhesv_aa_2stage.self)
    #elseif os(macOS)
    static let zhesv_aa_2stage: FunctionType.LAPACKE_zhesv_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhesv_aa_2stage_work: FunctionType.LAPACKE_zhesv_aa_2stage_work? = load(name: "LAPACKE_zhesv_aa_2stage_work", as: FunctionType.LAPACKE_zhesv_aa_2stage_work.self)
    #elseif os(macOS)
    static let zhesv_aa_2stage_work: FunctionType.LAPACKE_zhesv_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa_2stage: FunctionType.LAPACKE_ssytrf_aa_2stage? = load(name: "LAPACKE_ssytrf_aa_2stage", as: FunctionType.LAPACKE_ssytrf_aa_2stage.self)
    #elseif os(macOS)
    static let ssytrf_aa_2stage: FunctionType.LAPACKE_ssytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrf_aa_2stage_work: FunctionType.LAPACKE_ssytrf_aa_2stage_work? = load(name: "LAPACKE_ssytrf_aa_2stage_work", as: FunctionType.LAPACKE_ssytrf_aa_2stage_work.self)
    #elseif os(macOS)
    static let ssytrf_aa_2stage_work: FunctionType.LAPACKE_ssytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa_2stage: FunctionType.LAPACKE_dsytrf_aa_2stage? = load(name: "LAPACKE_dsytrf_aa_2stage", as: FunctionType.LAPACKE_dsytrf_aa_2stage.self)
    #elseif os(macOS)
    static let dsytrf_aa_2stage: FunctionType.LAPACKE_dsytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrf_aa_2stage_work: FunctionType.LAPACKE_dsytrf_aa_2stage_work? = load(name: "LAPACKE_dsytrf_aa_2stage_work", as: FunctionType.LAPACKE_dsytrf_aa_2stage_work.self)
    #elseif os(macOS)
    static let dsytrf_aa_2stage_work: FunctionType.LAPACKE_dsytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa_2stage: FunctionType.LAPACKE_csytrf_aa_2stage? = load(name: "LAPACKE_csytrf_aa_2stage", as: FunctionType.LAPACKE_csytrf_aa_2stage.self)
    #elseif os(macOS)
    static let csytrf_aa_2stage: FunctionType.LAPACKE_csytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrf_aa_2stage_work: FunctionType.LAPACKE_csytrf_aa_2stage_work? = load(name: "LAPACKE_csytrf_aa_2stage_work", as: FunctionType.LAPACKE_csytrf_aa_2stage_work.self)
    #elseif os(macOS)
    static let csytrf_aa_2stage_work: FunctionType.LAPACKE_csytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa_2stage: FunctionType.LAPACKE_zsytrf_aa_2stage? = load(name: "LAPACKE_zsytrf_aa_2stage", as: FunctionType.LAPACKE_zsytrf_aa_2stage.self)
    #elseif os(macOS)
    static let zsytrf_aa_2stage: FunctionType.LAPACKE_zsytrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrf_aa_2stage_work: FunctionType.LAPACKE_zsytrf_aa_2stage_work? = load(name: "LAPACKE_zsytrf_aa_2stage_work", as: FunctionType.LAPACKE_zsytrf_aa_2stage_work.self)
    #elseif os(macOS)
    static let zsytrf_aa_2stage_work: FunctionType.LAPACKE_zsytrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa_2stage: FunctionType.LAPACKE_chetrf_aa_2stage? = load(name: "LAPACKE_chetrf_aa_2stage", as: FunctionType.LAPACKE_chetrf_aa_2stage.self)
    #elseif os(macOS)
    static let chetrf_aa_2stage: FunctionType.LAPACKE_chetrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrf_aa_2stage_work: FunctionType.LAPACKE_chetrf_aa_2stage_work? = load(name: "LAPACKE_chetrf_aa_2stage_work", as: FunctionType.LAPACKE_chetrf_aa_2stage_work.self)
    #elseif os(macOS)
    static let chetrf_aa_2stage_work: FunctionType.LAPACKE_chetrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa_2stage: FunctionType.LAPACKE_zhetrf_aa_2stage? = load(name: "LAPACKE_zhetrf_aa_2stage", as: FunctionType.LAPACKE_zhetrf_aa_2stage.self)
    #elseif os(macOS)
    static let zhetrf_aa_2stage: FunctionType.LAPACKE_zhetrf_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrf_aa_2stage_work: FunctionType.LAPACKE_zhetrf_aa_2stage_work? = load(name: "LAPACKE_zhetrf_aa_2stage_work", as: FunctionType.LAPACKE_zhetrf_aa_2stage_work.self)
    #elseif os(macOS)
    static let zhetrf_aa_2stage_work: FunctionType.LAPACKE_zhetrf_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa_2stage: FunctionType.LAPACKE_ssytrs_aa_2stage? = load(name: "LAPACKE_ssytrs_aa_2stage", as: FunctionType.LAPACKE_ssytrs_aa_2stage.self)
    #elseif os(macOS)
    static let ssytrs_aa_2stage: FunctionType.LAPACKE_ssytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let ssytrs_aa_2stage_work: FunctionType.LAPACKE_ssytrs_aa_2stage_work? = load(name: "LAPACKE_ssytrs_aa_2stage_work", as: FunctionType.LAPACKE_ssytrs_aa_2stage_work.self)
    #elseif os(macOS)
    static let ssytrs_aa_2stage_work: FunctionType.LAPACKE_ssytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa_2stage: FunctionType.LAPACKE_dsytrs_aa_2stage? = load(name: "LAPACKE_dsytrs_aa_2stage", as: FunctionType.LAPACKE_dsytrs_aa_2stage.self)
    #elseif os(macOS)
    static let dsytrs_aa_2stage: FunctionType.LAPACKE_dsytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dsytrs_aa_2stage_work: FunctionType.LAPACKE_dsytrs_aa_2stage_work? = load(name: "LAPACKE_dsytrs_aa_2stage_work", as: FunctionType.LAPACKE_dsytrs_aa_2stage_work.self)
    #elseif os(macOS)
    static let dsytrs_aa_2stage_work: FunctionType.LAPACKE_dsytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa_2stage: FunctionType.LAPACKE_csytrs_aa_2stage? = load(name: "LAPACKE_csytrs_aa_2stage", as: FunctionType.LAPACKE_csytrs_aa_2stage.self)
    #elseif os(macOS)
    static let csytrs_aa_2stage: FunctionType.LAPACKE_csytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let csytrs_aa_2stage_work: FunctionType.LAPACKE_csytrs_aa_2stage_work? = load(name: "LAPACKE_csytrs_aa_2stage_work", as: FunctionType.LAPACKE_csytrs_aa_2stage_work.self)
    #elseif os(macOS)
    static let csytrs_aa_2stage_work: FunctionType.LAPACKE_csytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa_2stage: FunctionType.LAPACKE_zsytrs_aa_2stage? = load(name: "LAPACKE_zsytrs_aa_2stage", as: FunctionType.LAPACKE_zsytrs_aa_2stage.self)
    #elseif os(macOS)
    static let zsytrs_aa_2stage: FunctionType.LAPACKE_zsytrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zsytrs_aa_2stage_work: FunctionType.LAPACKE_zsytrs_aa_2stage_work? = load(name: "LAPACKE_zsytrs_aa_2stage_work", as: FunctionType.LAPACKE_zsytrs_aa_2stage_work.self)
    #elseif os(macOS)
    static let zsytrs_aa_2stage_work: FunctionType.LAPACKE_zsytrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa_2stage: FunctionType.LAPACKE_chetrs_aa_2stage? = load(name: "LAPACKE_chetrs_aa_2stage", as: FunctionType.LAPACKE_chetrs_aa_2stage.self)
    #elseif os(macOS)
    static let chetrs_aa_2stage: FunctionType.LAPACKE_chetrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let chetrs_aa_2stage_work: FunctionType.LAPACKE_chetrs_aa_2stage_work? = load(name: "LAPACKE_chetrs_aa_2stage_work", as: FunctionType.LAPACKE_chetrs_aa_2stage_work.self)
    #elseif os(macOS)
    static let chetrs_aa_2stage_work: FunctionType.LAPACKE_chetrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa_2stage: FunctionType.LAPACKE_zhetrs_aa_2stage? = load(name: "LAPACKE_zhetrs_aa_2stage", as: FunctionType.LAPACKE_zhetrs_aa_2stage.self)
    #elseif os(macOS)
    static let zhetrs_aa_2stage: FunctionType.LAPACKE_zhetrs_aa_2stage? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zhetrs_aa_2stage_work: FunctionType.LAPACKE_zhetrs_aa_2stage_work? = load(name: "LAPACKE_zhetrs_aa_2stage_work", as: FunctionType.LAPACKE_zhetrs_aa_2stage_work.self)
    #elseif os(macOS)
    static let zhetrs_aa_2stage_work: FunctionType.LAPACKE_zhetrs_aa_2stage_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorhr_col: FunctionType.LAPACKE_sorhr_col? = load(name: "LAPACKE_sorhr_col", as: FunctionType.LAPACKE_sorhr_col.self)
    #elseif os(macOS)
    static let sorhr_col: FunctionType.LAPACKE_sorhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let sorhr_col_work: FunctionType.LAPACKE_sorhr_col_work? = load(name: "LAPACKE_sorhr_col_work", as: FunctionType.LAPACKE_sorhr_col_work.self)
    #elseif os(macOS)
    static let sorhr_col_work: FunctionType.LAPACKE_sorhr_col_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorhr_col: FunctionType.LAPACKE_dorhr_col? = load(name: "LAPACKE_dorhr_col", as: FunctionType.LAPACKE_dorhr_col.self)
    #elseif os(macOS)
    static let dorhr_col: FunctionType.LAPACKE_dorhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let dorhr_col_work: FunctionType.LAPACKE_dorhr_col_work? = load(name: "LAPACKE_dorhr_col_work", as: FunctionType.LAPACKE_dorhr_col_work.self)
    #elseif os(macOS)
    static let dorhr_col_work: FunctionType.LAPACKE_dorhr_col_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunhr_col: FunctionType.LAPACKE_cunhr_col? = load(name: "LAPACKE_cunhr_col", as: FunctionType.LAPACKE_cunhr_col.self)
    #elseif os(macOS)
    static let cunhr_col: FunctionType.LAPACKE_cunhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let cunhr_col_work: FunctionType.LAPACKE_cunhr_col_work? = load(name: "LAPACKE_cunhr_col_work", as: FunctionType.LAPACKE_cunhr_col_work.self)
    #elseif os(macOS)
    static let cunhr_col_work: FunctionType.LAPACKE_cunhr_col_work? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunhr_col: FunctionType.LAPACKE_zunhr_col? = load(name: "LAPACKE_zunhr_col", as: FunctionType.LAPACKE_zunhr_col.self)
    #elseif os(macOS)
    static let zunhr_col: FunctionType.LAPACKE_zunhr_col? = nil
    #endif
    #if os(Windows) || os(Linux)
    static let zunhr_col_work: FunctionType.LAPACKE_zunhr_col_work? = load(name: "LAPACKE_zunhr_col_work", as: FunctionType.LAPACKE_zunhr_col_work.self)
    #elseif os(macOS)
    static let zunhr_col_work: FunctionType.LAPACKE_zunhr_col_work? = nil
    #endif
}
