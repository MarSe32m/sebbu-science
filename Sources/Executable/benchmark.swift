import SebbuScience

import PythonKit
import PythonKitUtilities

public struct BenchmarkResult: Codable {
    let name: String
    let dimensions: [Int]
    // Times (nanoseconds) per dimension of the array [dimension : time]
    let naiveTimes: [Int]
    let blasTimes: [Int]

    public init(name: String, dimensions: [Int], naiveTimes: [Int], blasTimes: [Int]) {
        self.name = name
        self.dimensions = dimensions
        self.naiveTimes = naiveTimes
        self.blasTimes = blasTimes
    }
}

@inlinable
public func benchmarkOperationDouble(name: String, runs: Int, iterations: Int, maxDimension: Int, 
                                     naiveFunc: (_ alpha: Double, _ beta: Double, _ x: inout Vector<Double>, _ y: inout Vector<Double>, _ A: inout Matrix<Double>, _ B: inout Matrix<Double>, _ C: inout Matrix<Double>) -> Void, 
                                     blasFunc:  (_ alpha: Double, _ beta: Double, _ x: inout Vector<Double>, _ y: inout Vector<Double>, _ A: inout Matrix<Double>, _ B: inout Matrix<Double>, _ C: inout Matrix<Double>) -> Void) -> BenchmarkResult {
    var naiveTimes: [Int] = []
    var blasTimes: [Int] = []
    let dimensions = (2...maxDimension).map { $0 }
    var random = NumPyRandom()
    for dimension in dimensions {
        print("\(name): \((100 * dimension) / maxDimension) %")
        var x: Vector<Double> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var y: Vector<Double> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var A: Matrix<Double> = generateSymmetricMatrix(dimension: dimension, rng: &random)
        var B: Matrix<Double> = generateSymmetricMatrix(dimension: dimension, rng: &random)
        var C: Matrix<Double> = generateSymmetricMatrix(dimension: dimension, rng: &random)
        var alpha: Double = .random(in: -5...5)
        var beta: Double = .random(in: -5...5)
        while alpha == .zero { alpha = .random(in: -5...5) }
        while beta == .zero { beta = .random(in: -5...5) }

        var bestNaiveTime: Duration = ContinuousClock.Duration.seconds(10)
        var bestBlasTime: Duration = ContinuousClock.Duration.seconds(10)

        for _ in 0..<runs {
            let naiveTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    naiveFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if naiveTime < bestNaiveTime { bestNaiveTime = naiveTime }

            let blasTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    blasFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if blasTime < bestBlasTime { bestBlasTime = blasTime}
        }
        naiveTimes.append(Int(bestNaiveTime.attoseconds / 1_000_000_000))
        blasTimes.append(Int(bestBlasTime.attoseconds / 1_000_000_000))
    }

    return BenchmarkResult(name: name, dimensions: dimensions, naiveTimes: naiveTimes, blasTimes: blasTimes)
}

@inlinable
public func benchmarkOperationFloat(name: String, runs: Int, iterations: Int, maxDimension: Int, 
                                     naiveFunc: (_ alpha: Float, _ beta: Float, _ x: inout Vector<Float>, _ y: inout Vector<Float>, _ A: inout Matrix<Float>, _ B: inout Matrix<Float>, _ C: inout Matrix<Float>) -> Void, 
                                     blasFunc:  (_ alpha: Float, _ beta: Float, _ x: inout Vector<Float>, _ y: inout Vector<Float>, _ A: inout Matrix<Float>, _ B: inout Matrix<Float>, _ C: inout Matrix<Float>) -> Void) -> BenchmarkResult {
    var naiveTimes: [Int] = []
    var blasTimes: [Int] = []
    let dimensions = (2...maxDimension).map { $0 }
    var random = NumPyRandom()
    for dimension in dimensions {
        print("\(name): \((100 * dimension) / maxDimension) %")
        var x: Vector<Float> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var y: Vector<Float> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var A: Matrix<Float> = generateSymmetricMatrix(dimension: dimension, rng: &random)
        var B: Matrix<Float> = generateSymmetricMatrix(dimension: dimension, rng: &random)
        var C: Matrix<Float> = generateSymmetricMatrix(dimension: dimension, rng: &random)
        var alpha: Float = .random(in: -5...5)
        var beta: Float = .random(in: -5...5)
        while alpha == .zero { alpha = .random(in: -5...5) }
        while beta == .zero { beta = .random(in: -5...5) }

        var bestNaiveTime: Duration = ContinuousClock.Duration.seconds(10)
        var bestBlasTime: Duration = ContinuousClock.Duration.seconds(10)

        for _ in 0..<runs {
            let naiveTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    naiveFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if naiveTime < bestNaiveTime { bestNaiveTime = naiveTime }

            let blasTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    blasFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if blasTime < bestBlasTime { bestBlasTime = blasTime}
        }
        naiveTimes.append(Int(bestNaiveTime.attoseconds / 1_000_000_000))
        blasTimes.append(Int(bestBlasTime.attoseconds / 1_000_000_000))
    }

    return BenchmarkResult(name: name, dimensions: dimensions, naiveTimes: naiveTimes, blasTimes: blasTimes)
}

@inlinable
public func benchmarkOperationComplexDouble(name: String, runs: Int, iterations: Int, maxDimension: Int, 
                                     naiveFunc: (_ alpha: Complex<Double>, _ beta: Complex<Double>, _ x: inout Vector<Complex<Double>>, _ y: inout Vector<Complex<Double>>, _ A: inout Matrix<Complex<Double>>, _ B: inout Matrix<Complex<Double>>, _ C: inout Matrix<Complex<Double>>) -> Void, 
                                     blasFunc:  (_ alpha: Complex<Double>, _ beta: Complex<Double>, _ x: inout Vector<Complex<Double>>, _ y: inout Vector<Complex<Double>>, _ A: inout Matrix<Complex<Double>>, _ B: inout Matrix<Complex<Double>>, _ C: inout Matrix<Complex<Double>>) -> Void) -> BenchmarkResult {
    var naiveTimes: [Int] = []
    var blasTimes: [Int] = []
    let dimensions = (2...maxDimension).map { $0 }
    var random = NumPyRandom()
    for dimension in dimensions {
        print("\(name): \((100 * dimension) / maxDimension) %")
        var x: Vector<Complex<Double>> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var y: Vector<Complex<Double>> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var A: Matrix<Complex<Double>> = generateHermitianMatrix(dimension: dimension, rng: &random)
        var B: Matrix<Complex<Double>> = generateHermitianMatrix(dimension: dimension, rng: &random)
        var C: Matrix<Complex<Double>> = generateHermitianMatrix(dimension: dimension, rng: &random)
        var alpha: Complex<Double> = .random(in: -5...5)
        var beta: Complex<Double> = .random(in: -5...5)
        while alpha == .zero { alpha = .random(in: -5...5) }
        while beta == .zero { beta = .random(in: -5...5) }

        var bestNaiveTime: Duration = ContinuousClock.Duration.seconds(10)
        var bestBlasTime: Duration = ContinuousClock.Duration.seconds(10)

        for _ in 0..<runs {
            let naiveTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    naiveFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if naiveTime < bestNaiveTime { bestNaiveTime = naiveTime }

            let blasTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    blasFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if blasTime < bestBlasTime { bestBlasTime = blasTime}
        }
        naiveTimes.append(Int(bestNaiveTime.attoseconds / 1_000_000_000))
        blasTimes.append(Int(bestBlasTime.attoseconds / 1_000_000_000))
    }

    return BenchmarkResult(name: name, dimensions: dimensions, naiveTimes: naiveTimes, blasTimes: blasTimes)
}

@inlinable
public func benchmarkOperationComplexFloat(name: String, runs: Int, iterations: Int, maxDimension: Int, 
                                     naiveFunc: (_ alpha: Complex<Float>, _ beta: Complex<Float>, _ x: inout Vector<Complex<Float>>, _ y: inout Vector<Complex<Float>>, _ A: inout Matrix<Complex<Float>>, _ B: inout Matrix<Complex<Float>>, _ C: inout Matrix<Complex<Float>>) -> Void, 
                                     blasFunc:  (_ alpha: Complex<Float>, _ beta: Complex<Float>, _ x: inout Vector<Complex<Float>>, _ y: inout Vector<Complex<Float>>, _ A: inout Matrix<Complex<Float>>, _ B: inout Matrix<Complex<Float>>, _ C: inout Matrix<Complex<Float>>) -> Void) -> BenchmarkResult {
    var naiveTimes: [Int] = []
    var blasTimes: [Int] = []
    let dimensions = (2...maxDimension).map { $0 }
    var random = NumPyRandom()
    for dimension in dimensions {
        print("\(name): \((100 * dimension) / maxDimension) %")
        var x: Vector<Complex<Float>> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var y: Vector<Complex<Float>> = .init((0..<dimension).map { _ in .random(in: -10...10, using: &random) } )
        var A: Matrix<Complex<Float>> = generateHermitianMatrix(dimension: dimension, rng: &random)
        var B: Matrix<Complex<Float>> = generateHermitianMatrix(dimension: dimension, rng: &random)
        var C: Matrix<Complex<Float>> = generateHermitianMatrix(dimension: dimension, rng: &random)
        var alpha: Complex<Float> = .random(in: -5...5)
        var beta: Complex<Float> = .random(in: -5...5)
        while alpha == .zero { alpha = .random(in: -5...5) }
        while beta == .zero { beta = .random(in: -5...5) }

        var bestNaiveTime: Duration = ContinuousClock.Duration.seconds(10)
        var bestBlasTime: Duration = ContinuousClock.Duration.seconds(10)

        for _ in 0..<runs {
            let naiveTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    naiveFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if naiveTime < bestNaiveTime { bestNaiveTime = naiveTime }

            let blasTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    blasFunc(alpha, beta, &x, &y, &A, &B, &C)
                }
            } / iterations
            if blasTime < bestBlasTime { bestBlasTime = blasTime}
        }
        naiveTimes.append(Int(bestNaiveTime.attoseconds / 1_000_000_000))
        blasTimes.append(Int(bestBlasTime.attoseconds / 1_000_000_000))
    }

    return BenchmarkResult(name: name, dimensions: dimensions, naiveTimes: naiveTimes, blasTimes: blasTimes)
}

public func plot(_ result: BenchmarkResult) {
    plt.figure()
    plt.plot(x: result.dimensions.map { Double($0) }, y: result.naiveTimes.map { Double($0) }, label: "Naive")
    plt.plot(x: result.dimensions.map { Double($0) }, y: result.blasTimes.map { Double($0) }, label: "Blas")
    plt.title(result.name)
    plt.xlabel("Dimension")
    plt.ylabel("Time (ns)")
    plt.legend()
    plt.show()
    plt.close()
}

public func generateSymmetricMatrix<T: BinaryFloatingPoint & AlgebraicField>(dimension: Int, rng: inout NumPyRandom) -> Matrix<T> where T.RawSignificand: FixedWidthInteger {
    var result: Matrix<T> = .zeros(rows: dimension, columns: dimension)
    for i in 0..<dimension {
        for j in i..<dimension {
            let value = T.random(in: -5...5, using: &rng)
            result[i, j] = value
            result[j, i] = value
        }
    }
    return result
}

public func generateHermitianMatrix<R: Real>(dimension: Int, rng: inout NumPyRandom) -> Matrix<Complex<R>> where R: BinaryFloatingPoint, R.RawSignificand: FixedWidthInteger {
    var result: Matrix<Complex<R>> = .zeros(rows: dimension, columns: dimension)
    for i in 0..<dimension {
        for j in i..<dimension {
            let real = R.random(in: -5...5, using: &rng)
            let imag = R.random(in: -5...5, using: &rng)
            if i == j { result[i, j] = Complex(real) }
            else { 
                result[i, j] = Complex(real, imag)
                result[j, i] = Complex(real, -imag)
            }
        }
    }
    return result
}