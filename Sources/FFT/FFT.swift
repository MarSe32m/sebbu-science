//
//  FFT.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 29.4.2025.
//

import ComplexModule
import Synchronization
import Foundation
import RealModule
import NumericsExtensions

public enum FFT {
    public static func isCompatibleSampleSize(_ n: Int) -> Bool {
        #if os(macOS)
        guard n >= 8 else { return false }
        let factors = [1, 3, 5, 15]
        for f in factors {
            if n % f == 0 {
                let pow = n / f
                if (pow & (pow - 1)) == 0 {
                    return true
                }
            }
        }
        return false
        #else
        return n >= 8
        #endif
    }
    
    public static func nextCompatibleSampleSize(_ n: Int) -> Int {
        #if os(macOS)
        let factors = [1, 3, 5, 15]
        var exponent: Int = max(n.log2 >> 4, 1)
        var bestCandidate: Int = n.nextPowerOfTwo
        while true {
            let base = 1 << exponent
            defer { exponent += 1}
            var largerThanBestCandidateCount = 0
            for factor in factors {
                let candidate = factor * base
                if candidate > bestCandidate {
                    largerThanBestCandidateCount += 1
                    continue
                }
                if candidate >= n {
                    bestCandidate = candidate
                }
            }
            if largerThanBestCandidateCount == factors.count { return bestCandidate }
        }
        #else
        return n
        #endif
    }
    
    public static func fft(_ x: [Complex<Double>], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
        #if os(macOS)
        let plan = AccelerateFFTPlan(sampleSize: x.count)
        #else
        let plan = FFTW.isAvailable ? FFTWPlan(sampleSize: x.count) : FFTPlan(sampleSize: x.count)
        #endif
        return plan.execute(x, spacing: spacing)
    }
    
    nonisolated public static func fft(_ x: [Double], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
        //TODO: Implement real-to-real transforms aswell?
        fft(x.map { Complex($0) }, spacing: spacing)
    }
    
    nonisolated public static func ifft(_ x: [Complex<Double>], spacing: Double = 1.0) -> (t: [Double], signal: [Complex<Double>]) {
            #if os(macOS)
            let plan = AccelerateiFFTPlan(sampleSize: x.count)
            #else
            let plan = FFTW.isAvailable ? iFFTWPlan(sampleSize: x.count) : iFFTPlan(sampleSize: x.count)
            #endif
            return plan.execute(x, spacing: spacing)
    }
    
    nonisolated public static func fftShift(_ frequencies: inout [Double], _ spectrum: inout [Complex<Double>]) {
        assert(spectrum.count == frequencies.count)
        let N = spectrum.count
        if N.isMultiple(of: 2) {
            for i in 0..<N/2 {
                spectrum.swapAt(i, i + N/2)
                frequencies.swapAt(i, i + N/2)
            }
        } else {
            // Swap non-zero elements
            for i in 1...N/2 {
                spectrum.swapAt(i, i + N/2)
                frequencies.swapAt(i, i + N/2)
            }
            // Shift the zero to the middle
            for i in 0..<N/2 {
                spectrum.swapAt(i, i + 1)
                frequencies.swapAt(i, i + 1)
            }
        }
    }
    
    nonisolated public static func ifftShift(_ frequencies: inout [Double], _ spectrum: inout [Complex<Double>]) {
        assert(spectrum.count == frequencies.count)
        let N = spectrum.count
        if N.isMultiple(of: 2) {
            // Same as fftShift
            fftShift(&frequencies, &spectrum)
        } else {
            // Swap non-zero elements
            for i in 0..<N/2 {
                spectrum.swapAt(i, i + N/2 + 1)
                frequencies.swapAt(i, i + N/2 + 1)
            }
            // Shift the zero to the left
            for i in stride(from: N/2, to: 0, by: -1) {
                spectrum.swapAt(i, i - 1)
                frequencies.swapAt(i, i - 1)
            }
        }
    }
}
