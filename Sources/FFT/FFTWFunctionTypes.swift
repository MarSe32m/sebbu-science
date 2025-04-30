//
//  FFTWFunctionTypes.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//

#if canImport(CFFTW)
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
#elseif os(Linux)
    @usableFromInline
    internal nonisolated(unsafe) static let handle: UnsafeMutableRawPointer? = {
        if let handle = loadLibrary(name: "libfftw3.so") {
            return handle
        }
        let dlErrorMessage = getDLErrorMessage()
        print("Failed to load libfftw3.so: \(dlErrorMessage)")
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

#if canImport(CFFTW)
extension FFTW {
    typealias FFTW_PLAN_DFT_1D = @convention(c) (_ n: Int32, _ in: UnsafeMutableRawPointer?, _ out: UnsafeMutableRawPointer?, _ sign: Int32, _ flags: UInt32) -> fftw_plan?
    static let plan_dft_1d: FFTW_PLAN_DFT_1D = load(name: "fftw_plan_dft_1d")!

    typealias FFTW_EXECUTE = @convention(c) (_ p: fftw_plan?) -> Void
    static let execute: FFTW_EXECUTE = load(name: "fftw_execute")!

    typealias FFTW_DESTROY_PLAN = @convention(c) (_ p: fftw_plan?) -> Void
    static let destroy_plan: FFTW_DESTROY_PLAN = load(name: "fftw_destroy_plan")!

    typealias FFTW_FREE = @convention(c) (_ p: UnsafeMutableRawPointer?) -> Void
    static let free: FFTW_FREE = load(name: "fftw_free")!

    typealias FFTW_ALLOC_COMPLEX = @convention(c) (_ n: Int) -> UnsafeMutableRawPointer?
    static let alloc_complex: FFTW_ALLOC_COMPLEX = load(name: "fftw_alloc_complex")!
}
#endif