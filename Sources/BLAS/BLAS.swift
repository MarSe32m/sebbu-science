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
import DynamicCOpenBLAS
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