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
}
