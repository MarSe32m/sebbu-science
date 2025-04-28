public extension BLAS {
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
}