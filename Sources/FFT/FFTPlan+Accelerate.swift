//
//  FFT+Accelerate.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//



#if canImport(Accelerate)
import Numerics
import Accelerate

public extension FFT {
    internal final class AccelerateFFTPlan: FFTPlan {
        internal let setup: OpaquePointer?
        public override init(sampleSize: Int, measure: Bool = false) {
            self.setup = vDSP_DFT_zop_CreateSetupD(nil, vDSP_Length(sampleSize), .FORWARD)
            super.init(sampleSize: sampleSize, measure: measure)
        }
        
        public override func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
            let N = x.count
            let frequencies: [Double] = [Double](unsafeUninitializedCapacity: N) { buffer, initializedCount in
                initializedCount = N
                let upperBound = N.isMultiple(of: 2) ? N/2 : (N/2 + 1)
                let lowerRange = (0..<upperBound)
                let upperRange = (-N/2..<0)
                let denominator = spacing * Double(N)
                var index = 0
                for i in lowerRange {
                    buffer.initializeElement(at: index, to: 2.0 * .pi * Double(i) / denominator)
                    index += 1
                }
                for i in upperRange {
                    buffer.initializeElement(at: index, to: 2.0 * .pi * Double(i) / denominator)
                    index += 1
                }
            }
            
            if let setup = setup {
                let realParts = x.map { $0.real }
                let imaginaryParts = x.map { $0.imaginary }
                var realPartsOutput = [Double](repeating: 0, count: x.count)
                var imaginaryPartsOutput = [Double](repeating: 0, count: x.count)
                vDSP_DFT_ExecuteD(setup, realParts, imaginaryParts, &realPartsOutput, &imaginaryPartsOutput)
                let spectrum = zip(realPartsOutput, imaginaryPartsOutput).map { Complex($0, $1) }
                return (frequencies, spectrum)
            }
            return super.execute(x, spacing: spacing)
        }
        
        deinit {
            if let setup {
                vDSP_DFT_DestroySetupD(setup)
            }
        }
    }
    
    internal final class AccelerateiFFTPlan: iFFTPlan {
        internal let setup: OpaquePointer?
        public override init(sampleSize: Int, measure: Bool = false) {
            self.setup = vDSP_DFT_zop_CreateSetupD(nil, vDSP_Length(sampleSize), .INVERSE)
            super.init(sampleSize: sampleSize, measure: measure)
        }
        
        public override func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (t: [Double], signal: [Complex<Double>]) {
            let N = x.count
            let range = (0..<N)
            let denominator = spacing * Double(N)
            let t = range.map { 2.0 * .pi * Double($0) / denominator }
            
            if let setup = setup {
                let realParts = x.map { $0.real }
                let imaginaryParts = x.map { $0.imaginary }
                var realPartsOutput = [Double](repeating: 0, count: x.count)
                var imaginaryPartsOutput = [Double](repeating: 0, count: x.count)
                vDSP_DFT_ExecuteD(setup, realParts, imaginaryParts, &realPartsOutput, &imaginaryPartsOutput)
                let signal = zip(realPartsOutput, imaginaryPartsOutput).map { Complex($0 / Double(N), $1 / Double(N)) }
                return (t, signal)
            }
            return super.execute(x, spacing: spacing)
        }
        
        deinit {
            if let setup {
                vDSP_DFT_DestroySetupD(setup)
            }
        }
    }
}
#endif
