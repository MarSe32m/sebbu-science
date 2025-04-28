//
//  BLASFunctions6.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 28.4.2025.
//

public extension BLAS {
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
