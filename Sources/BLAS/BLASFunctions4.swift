public extension BLAS {
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
}