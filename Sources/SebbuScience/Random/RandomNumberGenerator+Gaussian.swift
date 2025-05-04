//
//  RandomNumberGenerator+Gaussian.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Numerics

public extension RandomNumberGenerator {
    /// Generate next random value from a standard normal
    @inlinable
    mutating func nextGaussian() -> (Double, Double) {
        var x1, x2, r2: Double
        repeat {
            x1 = Double.random(in: -1...1, using: &self)
            x2 = Double.random(in: -1...1, using: &self)
            r2 = x1 * x1 + x2 * x2
        } while r2 >= 1.0 || r2 == 0
        // Box-Muller transform
        let f = (-2.0 * Double.log(r2) / r2).squareRoot()
        return (f * x1, f * x2)
    }
    
    @inlinable
    mutating func nextGaussian(count: Int) -> [Double] {
        if count == 0 { return [] }
        if count == 1 { return [nextGaussian().0] }
        var result: [Double] = [Double](repeating: .zero, count: count)
        var index = 0
        while result.count - index > 1 {
            let gaussian = nextGaussian()
            result[index] = gaussian.0
            result[index + 1] = gaussian.1
            index += 2
        }
        if result.count - index == 1 {
            result[index] = nextGaussian().0
        }
        return result
    }

    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    mutating func nextNormal(mean: Double = 0.0, stdev: Double = 1.0) -> Double {
        nextGaussian().0 * stdev + mean
    }
    
    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    mutating func nextNormal(mean: Float = 0.0, stdev: Float = 1.0) -> Float {
        Float(nextGaussian().0) * stdev + mean
    }
    
    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    mutating func nextNormal(mean: Double = 0.0, stdev: Double = 1.0) -> Complex<Double> {
        let gaussian = nextGaussian()
        return Complex(gaussian.0 * stdev + mean, gaussian.1 * stdev + mean)
    }
    
    /// Generates a random value from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter mean: The mean of the distribution.
    /// - Parameter stdev: The standard deviation of the distribution.
    mutating func nextNormal(mean: Float = 0.0, stdev: Float = 1.0) -> Complex<Float> {
        let gaussian = nextGaussian()
        return Complex(Float(gaussian.0), Float(gaussian.1))
    }

    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    mutating func nextNormal(count: Int, mean: Double = 0.0, stdev: Double = 1.0) -> [Double] {
        nextGaussian(count: count).map { $0 * stdev + mean }
    }
    
    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    mutating func nextNormal(count: Int, mean: Float = 0.0, stdev: Float = 1.0) -> [Float] {
        (nextNormal(count: count, mean: Double(mean), stdev: Double(stdev)) as [Double]).map { Float($0) }
    }
    
    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    mutating func nextNormal(count: Int, mean: Double = 0.0, stdev: Double = 1.0) -> [Complex<Double>] {
        let reals: [Double] = nextNormal(count: 2 * count, mean: mean, stdev: stdev)
        return (0..<count).map { Complex(reals[2 * $0], reals[2 * $0 + 1]) }
    }
    
    /// Generates an array of random values from a normal distribution with given mean and standard deviation using the Box-Muller transformation.
    /// - Parameter count: The number of values to generate
    /// - Parameter mean: The mean of the distribution where the values are drawn from.
    /// - Parameter stdev: The standard deviation of the distribution where the values are drawn from.
    mutating func nextNormal(count: Int, mean: Float = 0.0, stdev: Float = 1.0) -> [Complex<Float>] {
        let reals: [Float] = nextNormal(count: count * 2, mean: mean, stdev: stdev)
        return (0..<count).map { Complex(reals[2 * $0], reals[2 * $0 + 1]) }
    }
}

public extension SystemRandomNumberGenerator {
    @inlinable
    mutating func nextGaussian(count: Int) -> [Double] {
        if count == 0 { return [] }
        if count == 1 { return [nextGaussian().0] }
        var result: [Double] = [Double](repeating: .zero, count: count)
        var index = 0
        var randomBuffer = Double.random(count: 4 * count, in: -1...1, using: &self)
        while index < result.count {
            var x1, x2, r2: Double
            repeat {
                if randomBuffer.count < 2 {
                    randomBuffer = Double.random(count: 4 * (count - index), in: -1...1, using: &self)
                }
                x1 = randomBuffer.removeLast()
                x2 = randomBuffer.removeLast()
                r2 = x1 * x1 + x2 * x2
            } while r2 >= 1.0 || r2 == 0
            
            let f = (-2.0 * Double.log(r2) / r2).squareRoot()
            result[index] = f * x1
            index += 1
            if index < result.count {
                result[index] = f * x2
                index += 1
            }
        }
        return result
    }
}
