//
//  BLASFunctions5.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 28.4.2025.
//

public extension BLAS {
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
}
