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
            let N = x.count
            guard N > 0 else { return ([], []) }
            
            let spectrum: [Complex<Double>]
            if N & (N - 1) == 0 {
                spectrum = FFT.radix2FFT(x)
            } else {
                spectrum = FFT.bluesteinFFT(x)
            }
            let frequencies: [Double] = [Double](unsafeUninitializedCapacity: N) { buffer, initializedCount in
                initializedCount = N
                let upperBound = N.isMultiple(of: 2) ? N/2 : (N/2 + 1)
                let lowerRange = (0..<upperBound)
                let upperRange = (-N/2..<0)
                let denominator = spacing * Double(N)
                let factor = 2.0 * .pi / denominator
                var index = 0
                for i in lowerRange {
                    buffer.initializeElement(at: index, to: Double(i) * factor)
                    index += 1
                }
                for i in upperRange {
                    buffer.initializeElement(at: index, to: Double(i) * factor)
                    index += 1
                }
            }
            return (frequencies, spectrum)
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
            let N = x.count
            guard N > 0 else { return ([], []) }
            let conjugate = x.map { $0.conjugate }
            var signal: [Complex<Double>]
            if N & (N - 1) == 0 {
                signal = FFT.radix2FFT(conjugate).map { Complex($0.real / Double(N), -$0.imaginary / Double(N)) }
            } else {
                signal = FFT.bluesteinFFT(conjugate).map { Complex($0.real / Double(N), -$0.imaginary / Double(N)) }
            }
            let range = (0..<N)
            let factor = 2.0 * .pi / (spacing * Double(N))
            let t = range.map { Double($0) * factor }
            return (t, signal)
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

internal extension FFT {
    static func bluesteinFFT(_ x: [Complex<Double>]) -> [Complex<Double>] {
        let N = x.count
        let m = (2 * N - 1).nextPowerOfTwo
        let piOverN = Double.pi / Double(N)
        var a = [Complex<Double>](repeating: .zero, count: m)
        var b = [Complex<Double>](repeating: .zero, count: m)
        for n in 0..<N {
            let angle = piOverN * Double(n * n)
            let w = Complex(length: 1.0, phase: -angle)
            a[n] = Relaxed.product(x[n], w)
            b[n] = w.conjugate
            if n != 0 {
                b[m - n] = b[n]
            }
        }

        // Perform convolution via FFT
        let A = radix2FFT(a)
        let B = radix2FFT(b)
        
        var C = [Complex<Double>](repeating: .zero, count: m)
        for i in 0..<m {
            C[i] = Relaxed.product(A[i], B[i])
        }
        let scalingFactor = 1 / Double(m)
        let c = radix2iFFT(C).map { Complex(Relaxed.product($0.real, scalingFactor),
                                               Relaxed.product($0.imaginary, scalingFactor)) }

        var result = [Complex<Double>](repeating: .zero, count: N)
        for k in 0..<N {
            let angle = piOverN * Double(k * k)
            let w = Complex(length: 1.0, phase: -angle)
            result[k] = Relaxed.product(c[k], w)
        }

        return result
    }

    // Cooley-Tukey radix 2 FFT algorithm
    static func radix2FFT(_ input: [Complex<Double>]) -> [Complex<Double>] {
        let n = input.count
        precondition(n > 0 && (n & (n - 1)) == 0, "Input size must be a power of 2")

        var a = input

        let logN = n.log2
        for i in 0..<n {
            let j = bitReversed(i, bits: logN)
            if i < j {
                a.swapAt(i, j)
            }
        }
        
        var m = 2
        while m <= n {
            let theta = -2.0 * Double.pi / Double(m)
            let wm = Complex<Double>(length: 1.0, phase: theta)
            for k in stride(from: 0, to: n, by: m) {
                var w = Complex<Double>(1, 0)
                for j in 0..<(m / 2) {
                    let t = Relaxed.product(w, a[k + j + m / 2])
                    let u = a[k + j]
                    a[k + j] = Relaxed.sum(u, t)
                    a[k + j + m / 2] = Relaxed.sum(u, -t)
                    w = Relaxed.product(w, wm)
                }
            }
            m *= 2
        }

        return a
    }

    static func radix2iFFT(_ input: [Complex<Double>]) -> [Complex<Double>] {
        let conjugate = input.map { $0.conjugate }
        let result = radix2FFT(conjugate)
        return result.map { $0.conjugate }
    }

    @inline(__always)
    static func bitReversed(_ x: Int, bits: Int) -> Int {
        var x = x
        var result = 0
        for _ in 0..<bits {
            result = (result << 1) | (x & 1)
            x >>= 1
        }
        return result
    }
}
