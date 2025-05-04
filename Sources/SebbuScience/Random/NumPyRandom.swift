//
//  NumPyRandom.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics

/// Random number generator implementing the NumPy's C [implementation](https://github.com/numpy/numpy/blob/v1.0/numpy/random/mtrand/randomkit.c).
/// The implementation uses a Mersenne Twister 19937 generator under the hood.
public struct NumPyRandom: RandomNumberGenerator {
    @usableFromInline
    internal struct _RandomGeneratorState {
        @usableFromInline
        var key = [UInt32](repeating: 0, count: 624)
        @usableFromInline
        var pos: Int = 0
        @usableFromInline
        var nextGaussianNumber: Double?
    }

    @usableFromInline
    internal var state: _RandomGeneratorState

    /// Initialize with possibly a random seed
    ///
    /// - Parameter seed: The seed for underlying Mersenne Twister 19937 generator
    public init(seed: UInt32 = .random(in: .min ... .max)) {
        state = .init()
        var s = seed & 0xffffffff
        for i in 0 ..< state.key.count {
            state.key[i] = s
            s = UInt32((UInt64(1812433253) * UInt64(s ^ (s >> 30)) &+ UInt64(i) &+ 1) & 0xffffffff)
        }
        state.pos = state.key.count
    }

    /// Generate the next `UInt32` from the Mersenne Twister generator
    public mutating func next() -> UInt32 {
        let n = 624
        let m = 397
        let matrixA: UInt64    = 0x9908b0df
        let upperMask: UInt32  = 0x80000000
        let lowerMask: UInt32  = 0x7fffffff

        var y: UInt32
        if state.pos == state.key.count {
            for i in 0 ..< (n - m) {
                y = (state.key[i] & upperMask) | (state.key[i + 1] & lowerMask)
                state.key[i] = state.key[i + m] ^ (y >> 1) ^ UInt32((UInt64(~(y & 1)) + 1) & matrixA)
            }
            for i in (n - m) ..< (n - 1) {
                y = (state.key[i] & upperMask) | (state.key[i + 1] & lowerMask)
                state.key[i] = state.key[i + (m - n)] ^ (y >> 1) ^ UInt32((UInt64(~(y & 1)) + 1) & matrixA)
            }
            y = (state.key[n - 1] & upperMask) | (state.key[0] & lowerMask)
            state.key[n - 1] = state.key[m - 1] ^ (y >> 1) ^ UInt32((UInt64(~(y & 1)) + 1) & matrixA)
            state.pos = 0
        }
        y = state.key[state.pos]
        state.pos &+= 1

        y ^= (y >> 11)
        y ^= (y << 7) & 0x9d2c5680
        y ^= (y << 15) & 0xefc60000
        y ^= (y >> 18)

        return y
    }

    /// Generate the next `UInt64` from the Mersenne Twister generator
    @inline(__always)
    public mutating func next() -> UInt64 {
        let low = next() as UInt32
        let high = next() as UInt32
        return (UInt64(high) << 32) | UInt64(low)
    }

    /// Generate the next random `Double` from the Mersenne Twister generator
    public mutating func next() -> Double {
        let a = Double(next() as UInt32 >> 5)
        let b = Double(next() as UInt32 >> 6)
        return (a * 67108864.0 + b) / 9007199254740992.0
    }
    
    /// Generate the next random `Float` from the Mersenne Twister generator
    public mutating func next() -> Float {
        Float(next() as Double)
    }
    
    /// Generate the next random `Complex<Double>` from the Mersenne Twister generator
    public mutating func next() -> Complex<Double> {
        Complex(next() as Double, next() as Double)
    }
    
    /// Generate the next random `Complex<Double>` from the Mersenne Twister generator
    public mutating func next() -> Complex<Float> {
        Complex(next() as Float, next() as Float)
    }

    /// Generate next random value from a standard normal
    @inlinable
    internal mutating func _nextGaussian() -> Double {
        if let nextGaussian = state.nextGaussianNumber {
            state.nextGaussianNumber = nil
            return nextGaussian
        }
        var x1, x2, r2: Double
        repeat {
            x1 = 2.0 * next() as Double - 1.0
            x2 = 2.0 * next() as Double - 1.0
            r2 = x1 * x1 + x2 * x2
        } while r2 >= 1.0 || r2 == 0.0

        // Box-Muller transform
        let f = (-2.0 * Double.log(r2) / r2).squareRoot()
        state.nextGaussianNumber = f * x1
        return f * x2
    }

    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    public mutating func nextNormal(mean: Double = 0.0, stdev: Double = 1.0) -> Double {
        _nextGaussian() * stdev + mean
    }
    
    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    public mutating func nextNormal(mean: Float = 0.0, stdev: Float = 1.0) -> Float {
        Float(_nextGaussian()) * stdev + mean
    }
    
    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    public mutating func nextNormal(mean: Double = 0.0, stdev: Double = 1.0) -> Complex<Double> {
        let real = nextNormal(mean: mean, stdev: stdev) as Double
        let imag = nextNormal(mean: mean, stdev: stdev) as Double
        return Complex(real, imag)
    }
    
    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    public mutating func nextNormal(mean: Float = 0.0, stdev: Float = 1.0) -> Complex<Float> {
        let real = nextNormal(mean: mean, stdev: stdev) as Float
        let imag = nextNormal(mean: mean, stdev: stdev) as Float
        return Complex(real, imag)
    }

    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    public mutating func nextNormal(count: Int, mean: Double = 0.0, stdev: Double = 1.0) -> [Double] {
        (0 ..< count).map { _ in nextNormal(mean: mean, stdev: stdev) }
    }
    
    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    public mutating func nextNormal(count: Int, mean: Float = 0.0, stdev: Float = 1.0) -> [Float] {
        (0 ..< count).map { _ in nextNormal(mean: mean, stdev: stdev) }
    }
    
    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    public mutating func nextNormal(count: Int, mean: Double = 0.0, stdev: Double = 1.0) -> [Complex<Double>] {
        (0 ..< count).map { _ in nextNormal(mean: mean, stdev: stdev) }
    }
    
    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    public mutating func nextNormal(count: Int, mean: Float = 0.0, stdev: Float = 1.0) -> [Complex<Float>] {
        (0 ..< count).map { _ in nextNormal(mean: mean, stdev: stdev) }
    }
}
