//
//  FFTPlan+Swift.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//

import Numerics

public extension FFT {
    class FFTPlan {
        public let sampleSize: Int
        
        public init(sampleSize: Int, measure: Bool = false) {
            self.sampleSize = sampleSize
        }
        
        public func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
            fatalError("TODO: Implement Cooley-Tukey FFT")
//            let N = x.count
//            let frequencies: [Double] = [Double](unsafeUninitializedCapacity: N) { buffer, initializedCount in
//                initializedCount = N
//                let upperBound = N.isMultiple(of: 2) ? N/2 : (N/2 + 1)
//                let lowerRange = (0..<upperBound)
//                let upperRange = (-N/2..<0)
//                let denominator = spacing * Double(N)
//                var index = 0
//                for i in lowerRange {
//                    buffer.initializeElement(at: index, to: 2.0 * .pi * Double(i) / denominator)
//                    index += 1
//                }
//                for i in upperRange {
//                    buffer.initializeElement(at: index, to: 2.0 * .pi * Double(i) / denominator)
//                    index += 1
//                }
//            }
//            return (frequencies, result)
        }
        
        public static func makePlan(sampleSize: Int, measure: Bool = false) -> FFTPlan {
            #if os(macOS)
            AccelerateFFTPlan(sampleSize: sampleSize, measure: measure)
            #else
            FFTW.isAvailable ? FFTWPlan(sampleSize: sampleSize, measure: measure) : FFTPlan(sampleSize: sampleSize, measure: measure)
            #endif
        }
    }
    
    class iFFTPlan {
        public let sampleSize: Int
        
        public init(sampleSize: Int, measure: Bool = false) {
            self.sampleSize = sampleSize
        }
        
        public func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (t: [Double], signal: [Complex<Double>]) {
            fatalError("TODO: Implement Cooley-Tukey FFT")
//            let N = x.count
//            let range = (0..<N)
//            let denominator = spacing * Double(N)
//            let t = range.map { 2.0 * .pi * Double($0) / denominator }
//            return (t, result)
        }
        
        public static func makePlan(sampleSize: Int, measure: Bool = false) -> iFFTPlan {
            #if os(macOS)
            AccelerateiFFTPlan(sampleSize: sampleSize, measure: measure)
            #else
            FFTW.isAvailable ? iFFTWPlan(sampleSize: sampleSize, measure: measure) : iFFTPlan(sampleSize: sampleSize, measure: measure)
            #endif
        }
    }
}
