//
//  FFT+FFTW.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//
#if canImport(CFFTW)
import CFFTW
import Numerics
import Synchronization

public extension FFT {
    nonisolated private static let planMutex = Mutex<Void>(())
    internal final class FFTWPlan: FFTPlan {
        internal let buffer: UnsafeMutableRawPointer?
        internal let plan: OpaquePointer?
        
        public override init(sampleSize: Int, measure: Bool = false) {
            let buffer = FFTW.alloc_complex(sampleSize)
            self.buffer = buffer
            FFT.planMutex._unsafeLock()
            self.plan = FFTW.plan_dft_1d(numericCast(sampleSize), buffer, buffer, FFTW_FORWARD, measure ? FFTW_MEASURE : FFTW_ESTIMATE)
            FFT.planMutex._unsafeUnlock()
            super.init(sampleSize: sampleSize, measure: measure)
        }
        
        public override func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
            precondition(x.count == sampleSize)
            let N = x.count
            x.withUnsafeBytes { bytes in
                let bufferBufferPointer = UnsafeMutableRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                let bytesCopied = bytes.copyBytes(to: bufferBufferPointer)
                guard bytesCopied == sampleSize * MemoryLayout<fftw_complex>.size else { fatalError("Copied memory didn't match the buffer size") }
            }
            FFTW.execute(plan)
            let result = [Complex<Double>](unsafeUninitializedCapacity: sampleSize) { resultBuffer, initializedCount in
                let rawResultBuffer = UnsafeMutableRawBufferPointer(resultBuffer)
                let rawBufferPointer = UnsafeRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                rawResultBuffer.copyMemory(from: rawBufferPointer)
                initializedCount = sampleSize
            }
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
            return (frequencies, result)
        }
        
        deinit {
            FFT.planMutex.withLock { _ in
                FFTW.destroy_plan(plan)
                FFTW.free(buffer)
            }
        }
    }
    
    internal final class iFFTWPlan: iFFTPlan {
        internal let buffer: UnsafeMutableRawPointer?
        internal let plan: OpaquePointer?
        
        public override init(sampleSize: Int, measure: Bool = false) {
            let buffer = FFTW.alloc_complex(sampleSize)
            self.buffer = buffer
            FFT.planMutex._unsafeLock()
            self.plan = FFTW.plan_dft_1d(numericCast(sampleSize), buffer, buffer, FFTW_BACKWARD, measure ? FFTW_MEASURE : FFTW_ESTIMATE)
            FFT.planMutex._unsafeUnlock()
            super.init(sampleSize: sampleSize, measure: measure)
        }
        
        public override func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (t: [Double], signal: [Complex<Double>]) {
            precondition(x.count == sampleSize)
            let N = x.count
            x.withUnsafeBytes { bytes in
                let bufferBufferPointer = UnsafeMutableRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                let bytesCopied = bytes.copyBytes(to: bufferBufferPointer)
                guard bytesCopied == sampleSize * MemoryLayout<fftw_complex>.size else { fatalError("Copied memory didn't match the buffer size") }
            }
            FFTW.execute(plan)
            let result = [Complex<Double>](unsafeUninitializedCapacity: sampleSize) { resultBuffer, initializedCount in
                let rawResultBuffer = UnsafeMutableRawBufferPointer(resultBuffer)
                let rawBufferPointer = UnsafeRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                rawResultBuffer.copyMemory(from: rawBufferPointer)
                let scalingFactor = 1 / Double(N)
                for i in resultBuffer.indices {
                    resultBuffer[i].real *= scalingFactor
                    resultBuffer[i].imaginary *= scalingFactor
                }
                initializedCount = sampleSize
            }
            let range = (0..<N)
            let denominator = spacing * Double(N)
            let t = range.map { 2.0 * .pi * Double($0) / denominator }
            return (t, result)
        }
        
        deinit {
            FFT.planMutex.withLock { _ in
                FFTW.destroy_plan(plan)
                FFTW.free(buffer)
            }
        }
    }
}
#endif
