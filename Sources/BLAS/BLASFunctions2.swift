//
//  BLASFunctions2.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 28.4.2025.
//

public extension BLAS {
    #if os(Windows) || os(Linux)
    static let snrm2: FunctionTypes.cblas_snrm2? = load(name: "cblas_snrm2")
    #elseif os(macOS)
    static let snrm2: Optional<_> = _snrm2
    #endif
    
    #if os(Windows) || os(Linux)
    static let dnrm2: FunctionTypes.cblas_dnrm2? = load(name: "cblas_dnrm2")
    #elseif os(macOS)
    static let dnrm2: Optional<_> = _dnrm2
    #endif
    
    #if os(Windows) || os(Linux)
    static let scnrm2: FunctionTypes.cblas_scnrm2? = load(name: "cblas_scnrm2")
    #elseif os(macOS)
    static let scnrm2: Optional<_> = _scnrm2
    #endif
    
    #if os(Windows) || os(Linux)
    static let dznrm2: FunctionTypes.cblas_dznrm2? = load(name: "cblas_dznrm2")
    #elseif os(macOS)
    static let dznrm2: Optional<_> = _dznrm2
    #endif
    
    #if os(Windows) || os(Linux)
    static let isamax: FunctionTypes.cblas_isamax? = load(name: "cblas_isamax")
    #elseif os(macOS)
    static let isamax: Optional<_> = _isamax
    #endif
    
    #if os(Windows) || os(Linux)
    static let idamax: FunctionTypes.cblas_idamax? = load(name: "cblas_idamax")
    #elseif os(macOS)
    static let idamax: Optional<_> = _idamax
    #endif
    
    #if os(Windows) || os(Linux)
    static let icamax: FunctionTypes.cblas_icamax? = load(name: "cblas_icamax")
    #elseif os(macOS)
    static let icamax: Optional<_> = _icamax
    #endif
    
    #if os(Windows) || os(Linux)
    static let izamax: FunctionTypes.cblas_izamax? = load(name: "cblas_izamax")
    #elseif os(macOS)
    static let izamax: Optional<_> = _izamax
    #endif
    
    #if os(Windows) || os(Linux)
    static let isamin: FunctionTypes.cblas_isamin? = load(name: "cblas_isamin")
    #elseif os(macOS)
    static let isamin: Optional<_> = _isamin
    #endif
    
    #if os(Windows) || os(Linux)
    static let idamin: FunctionTypes.cblas_idamin? = load(name: "cblas_idamin")
    #elseif os(macOS)
    static let idamin: Optional<_> = _idamin
    #endif
    
    #if os(Windows) || os(Linux)
    static let icamin: FunctionTypes.cblas_icamin? = load(name: "cblas_icamin")
    #elseif os(macOS)
    static let icamin: Optional<_> = _icamin
    #endif
    
    #if os(Windows) || os(Linux)
    static let izamin: FunctionTypes.cblas_izamin? = load(name: "cblas_izamin")
    #elseif os(macOS)
    static let izamin: Optional<_> = _izamin
    #endif
    
    #if os(Windows) || os(Linux)
    static let samax: FunctionTypes.cblas_samax? = load(name: "cblas_samax")
    #elseif os(macOS)
    static let samax: Optional<_> = _samax
    #endif
    
    #if os(Windows) || os(Linux)
    static let damax: FunctionTypes.cblas_damax? = load(name: "cblas_damax")
    #elseif os(macOS)
    static let damax: Optional<_> = _damax
    #endif
    
    #if os(Windows) || os(Linux)
    static let scamax: FunctionTypes.cblas_scamax? = load(name: "cblas_scamax")
    #elseif os(macOS)
    static let scamax: Optional<_> = _scamax
    #endif
    
    #if os(Windows) || os(Linux)
    static let dzamax: FunctionTypes.cblas_dzamax? = load(name: "cblas_dzamax")
    #elseif os(macOS)
    static let dzamax: Optional<_> = _dzamax
    #endif
    
    #if os(Windows) || os(Linux)
    static let samin: FunctionTypes.cblas_samin? = load(name: "cblas_samin")
    #elseif os(macOS)
    static let samin: Optional<_> = _samin
    #endif
    
    #if os(Windows) || os(Linux)
    static let damin: FunctionTypes.cblas_damin? = load(name: "cblas_damin")
    #elseif os(macOS)
    static let damin: Optional<_> = _damin
    #endif
    
    #if os(Windows) || os(Linux)
    static let scamin: FunctionTypes.cblas_scamin? = load(name: "cblas_scamin")
    #elseif os(macOS)
    static let scamin: Optional<_> = _scamin
    #endif
    
    #if os(Windows) || os(Linux)
    static let dzamin: FunctionTypes.cblas_dzamin? = load(name: "cblas_dzamin")
    #elseif os(macOS)
    static let dzamin: Optional<_> = _dzamin
    #endif
    
    #if os(Windows) || os(Linux)
    static let ismax: FunctionTypes.cblas_ismax? = load(name: "cblas_ismax")
    #elseif os(macOS)
    static let ismax: Optional<_> = _ismax
    #endif
    
    #if os(Windows) || os(Linux)
    static let idmax: FunctionTypes.cblas_idmax? = load(name: "cblas_idmax")
    #elseif os(macOS)
    static let idmax: Optional<_> = _idmax
    #endif
    
    #if os(Windows) || os(Linux)
    static let icmax: FunctionTypes.cblas_icmax? = load(name: "cblas_icmax")
    #elseif os(macOS)
    static let icmax: Optional<_> = _icmax
    #endif
    
    #if os(Windows) || os(Linux)
    static let izmax: FunctionTypes.cblas_izmax? = load(name: "cblas_izmax")
    #elseif os(macOS)
    static let izmax: Optional<_> = _izmax
    #endif
    
    #if os(Windows) || os(Linux)
    static let ismin: FunctionTypes.cblas_ismin? = load(name: "cblas_ismin")
    #elseif os(macOS)
    static let ismin: Optional<_> = _ismin
    #endif
    
    #if os(Windows) || os(Linux)
    static let idmin: FunctionTypes.cblas_idmin? = load(name: "cblas_idmin")
    #elseif os(macOS)
    static let idmin: Optional<_> = _idmin
    #endif
    
    #if os(Windows) || os(Linux)
    static let icmin: FunctionTypes.cblas_icmin? = load(name: "cblas_icmin")
    #elseif os(macOS)
    static let icmin: Optional<_> = _icmin
    #endif
    
    #if os(Windows) || os(Linux)
    static let izmin: FunctionTypes.cblas_izmin? = load(name: "cblas_izmin")
    #elseif os(macOS)
    static let izmin: Optional<_> = _izmin
    #endif
}
