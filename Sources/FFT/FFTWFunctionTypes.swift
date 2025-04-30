//
//  FFTWFunctionTypes.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//

#if canImport(CFFTW)
import CFFTW
#endif

public enum FFTW {
    //TODO: Handle to libfftw3-3.dll and something similar on linux
    //TODO: Check whether necessary functions are available
    nonisolated static let isAvailable: Bool = { fatalError("TODO: Implement") }()
    
    //TODO: Load necessary functions
}
