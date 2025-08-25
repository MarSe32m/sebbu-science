//
//  FFTWFunctionTypes.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//

#if canImport(DynamicCFFTW)
import DynamicCFFTW
#elseif canImport(CFFTW)
import CFFTW
#endif

#if canImport(WinSDK)
import WinSDK
#endif

import _SebbuScienceCommon

internal enum FFTW {
    nonisolated static let isAvailable: Bool = { 
        #if os(macOS)
        return false
        #elseif os(Linux)
        return true
        #else
        guard let handle else { return false }
        guard load(name: "fftw_plan_dft_1d", as: FFTW_PLAN_DFT_1D.self) != nil else { return false }
        guard load(name: "fftw_execute", as: FFTW_EXECUTE.self) != nil else { return false }
        guard load(name: "fftw_destroy_plan", as: FFTW_DESTROY_PLAN.self) != nil else { return false }
        guard load(name: "fftw_free", as: FFTW_FREE.self) != nil else { return false }
        guard load(name: "fftw_alloc_complex", as: FFTW_ALLOC_COMPLEX.self) != nil else { return false }
        return true
        #endif
     }()

#if os(Windows)
    @usableFromInline
    internal nonisolated(unsafe) static let handle: HMODULE? = {
        if let handle = loadLibrary(name: "libfftw3-3.dll") {
            return handle
        }
        print("Failed to load libfftw3-3.dll")
        return nil
    }()
#endif

#if os(Windows)
    @inlinable
    internal static func load<T>(name: String, as type: T.Type = T.self) -> T? {
        loadSymbol(name:name, handle: handle)
    }
#endif
}

#if canImport(DynamicCFFTW) || canImport(CFFTW)
extension FFTW {
    typealias FFTW_PLAN_DFT_1D = @convention(c) (_ n: Int32, _ in: UnsafeMutableRawPointer?, _ out: UnsafeMutableRawPointer?, _ sign: Int32, _ flags: UInt32) -> fftw_plan?
    #if canImport(DynamicCFFTW)
    static let plan_dft_1d: FFTW_PLAN_DFT_1D = load(name: "fftw_plan_dft_1d")!
    #elseif canImport(CFFTW)
    static let plan_dft_1d: @Sendable (Int32, UnsafeMutablePointer<fftw_complex>?, UnsafeMutablePointer<fftw_complex>?, Int32, UInt32) -> fftw_plan? = CFFTW.fftw_plan_dft_1d
    #endif

    typealias FFTW_EXECUTE = @convention(c) (_ p: fftw_plan?) -> Void
    #if canImport(DynamicCFFTW)
    static let execute: FFTW_EXECUTE = load(name: "fftw_execute")!
    #elseif canImport(CFFTW)
    static let execute: @Sendable (fftw_plan?) -> Void = CFFTW.fftw_execute
    #endif

    typealias FFTW_DESTROY_PLAN = @convention(c) (_ p: fftw_plan?) -> Void
    #if canImport(DynamicCFFTW)
    static let destroy_plan: FFTW_DESTROY_PLAN = load(name: "fftw_destroy_plan")!
    #elseif canImport(CFFTW)
    static let destroy_plan: @Sendable (fftw_plan?) -> Void = CFFTW.fftw_destroy_plan
    #endif

    typealias FFTW_FREE = @convention(c) (_ p: UnsafeMutableRawPointer?) -> Void
    #if canImport(DynamicCFFTW)
    static let free: FFTW_FREE = load(name: "fftw_free")!
    #elseif canImport(CFFTW)
    static let free: @Sendable (UnsafeMutableRawPointer?) -> Void = CFFTW.fftw_free
    #endif

    typealias FFTW_ALLOC_COMPLEX = @convention(c) (_ n: Int) -> UnsafeMutableRawPointer?
    #if canImport(DynamicCFFTW)
    static let alloc_complex: FFTW_ALLOC_COMPLEX = load(name: "fftw_alloc_complex")!
    #elseif canImport(CFFTW)
    static let alloc_complex: @Sendable (Int) -> UnsafeMutablePointer<fftw_complex>? = fftw_alloc_complex
    #endif
}
#endif