//
//  FFT.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 29.4.2025.
//

import CFFTW
import ComplexModule
import Synchronization
import Foundation
import RealModule
import NumericsExtensions

public final class FFT {
    private nonisolated(unsafe) static let _shared: FFT = FFT()

    // Creating and destroying plans isn't thread safe but executing them is!
    private let _planMutex: Mutex<Void> = Mutex(())

    private init() {}
    
    nonisolated public static func fftShift(_ spectrum: inout [Complex<Double>], _ frequencies: inout [Double]) {
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
    
    nonisolated public static func ifftShift(_ spectrum: inout [Complex<Double>], _ frequencies: inout [Double]) {
        assert(spectrum.count == frequencies.count)
        let N = spectrum.count
        if N.isMultiple(of: 2) {
            // Same as fftShift
            fftShift(&spectrum, &frequencies)
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
    
    nonisolated public static func fft(_ x: [Complex<Double>], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
        let plan = FFTPlan(sampleSize: x.count, measure: false)
        return plan.execute(x, spacing: spacing)
    }
    
    nonisolated public static func fft(_ x: [Double], spacing: Double = 1.0) -> (frequencies: [Double], spectrum: [Complex<Double>]) {
        //TODO: Implement real-to-real transforms aswell?
        fft(x.map { Complex($0) }, spacing: spacing)
    }
    
    nonisolated public static func ifft(_ x: [Complex<Double>], spacing: Double = 1.0) -> (t: [Double], signal: [Complex<Double>]) {
        let plan = iFFTPlan(simpleSize: x.count, measure: false)
        return plan.execute(x, spacing: spacing)
    }

    nonisolated internal func withPlanMutex<T>(_ body: () throws -> T) rethrows -> T {
        _planMutex._unsafeLock(); defer { _planMutex._unsafeUnlock() }
        let result = try body()
        return result
    }
}

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
