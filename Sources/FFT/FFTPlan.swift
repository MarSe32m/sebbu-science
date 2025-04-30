//
//  FFTPlan+Swift.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 30.4.2025.
//

public extension FFT {
    class FFTPlan {
        internal let buffer: UnsafeMutablePointer<fftw_complex>!
        internal let plan: fftw_plan!
        internal let sampleSize: Int
        
        public init(sampleSize: Int, measure: Bool = false) {
            self.sampleSize = sampleSize
            let buffer = fftw_alloc_complex(sampleSize)
            self.buffer = buffer
            self.plan = FFT._shared.withPlanMutex {
                fftw_plan_dft_1d(numericCast(sampleSize), buffer, buffer, FFTW_FORWARD, measure ? FFTW_MEASURE : FFTW_ESTIMATE)
            }
        }
        
        
        
        public func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
            precondition(MemoryLayout<fftw_complex>.size == MemoryLayout<Complex<Double>>.size)
            precondition(MemoryLayout<fftw_complex>.stride == MemoryLayout<Complex<Double>>.stride)
            precondition(MemoryLayout<fftw_complex>.alignment == MemoryLayout<Complex<Double>>.alignment)
            precondition(x.count == sampleSize)
            let N = x.count
            x.withUnsafeBytes { bytes in
                let bufferBufferPointer = UnsafeMutableRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                let bytesCopied = bytes.copyBytes(to: bufferBufferPointer)
                guard bytesCopied == sampleSize * MemoryLayout<fftw_complex>.size else { fatalError("Copied memory didn't match the buffer size") }
            }
            fftw_execute(plan)
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
            FFT._shared.withPlanMutex {
                fftw_destroy_plan(plan)
            }
            fftw_free(buffer)
        }
    }
    
    class iFFTPlan {
        internal let buffer: UnsafeMutablePointer<fftw_complex>!
        internal let plan: fftw_plan!
        internal let sampleSize: Int
        
        public init(simpleSize: Int, measure: Bool = false) {
            self.sampleSize = simpleSize
            let buffer = fftw_alloc_complex(simpleSize)
            self.buffer = buffer
            self.plan = FFT._shared.withPlanMutex {
                fftw_plan_dft_1d(numericCast(simpleSize), buffer, buffer, FFTW_BACKWARD, measure ? FFTW_MEASURE : FFTW_ESTIMATE)
            }
        }
        
        public func execute(_ x: [Complex<Double>], spacing: Double = 1.0) -> (t: [Double], signal: [Complex<Double>]) {
            assert(MemoryLayout<fftw_complex>.size == MemoryLayout<Complex<Double>>.size)
            assert(MemoryLayout<fftw_complex>.stride == MemoryLayout<Complex<Double>>.stride)
            assert(MemoryLayout<fftw_complex>.alignment == MemoryLayout<Complex<Double>>.alignment)
            let N = x.count
            x.withUnsafeBytes { bytes in
                let bufferBufferPointer = UnsafeMutableRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                let bytesCopied = bytes.copyBytes(to: bufferBufferPointer)
                guard bytesCopied == sampleSize * MemoryLayout<fftw_complex>.size else { fatalError("Copied memory didn't match the buffer size") }
            }
            fftw_execute(plan)
            let result = [Complex<Double>](unsafeUninitializedCapacity: sampleSize) { resultBuffer, initializedCount in
                let rawResultBuffer = UnsafeMutableRawBufferPointer(resultBuffer)
                let rawBufferPointer = UnsafeRawBufferPointer(start: buffer, count: sampleSize * MemoryLayout<fftw_complex>.size)
                rawResultBuffer.copyMemory(from: rawBufferPointer)
                let scalingFactor = 1 / Double(N)
                for i in resultBuffer.indices { resultBuffer[i] *= scalingFactor }
                initializedCount = sampleSize
            }
            let range = (0..<N)
            let denominator = spacing * Double(N)
            let t = range.map { 2.0 * .pi * Double($0) / denominator }
            return (t, result)
        }
        
        deinit {
            fftw_destroy_plan(plan)
            fftw_free(buffer)
        }
    }
}
