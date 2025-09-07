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
public func benchmarkVectorOperationDouble(name: String, runs: Int, iterations: Int, maxDimension: Int, 
                                     naiveFunc: (_ multiplier: Double, _ x: inout Vector<Double>, _ y: inout Vector<Double>) -> Void, 
                                     blasFunc:  (_ multiplier: Double, _ x: inout Vector<Double>, _ y: inout Vector<Double>) -> Void) -> BenchmarkResult {
    var naiveTimes: [Int] = []
    var blasTimes: [Int] = []
    let dimensions = (2...maxDimension).map { $0 }

    for dimension in 2...maxDimension {
        print(dimension)
        var x: Vector<Double> = .init((0..<dimension).map { _ in .random(in: -10...10) } )
        var y: Vector<Double> = .init((0..<dimension).map { _ in .random(in: -10...10) } )
        var multiplier: Double = .random(in: -1...1)
        while multiplier == 0 { multiplier = .random(in: -1...1) }

        var bestNaiveTime: Duration = ContinuousClock.Duration.seconds(10)
        var bestBlasTime: Duration = ContinuousClock.Duration.seconds(10)

        for _ in 0..<runs {
            let naiveTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    naiveFunc(multiplier, &x, &y)
                }
            } / iterations
            if naiveTime < bestNaiveTime { bestNaiveTime = naiveTime }

            let blasTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    blasFunc(multiplier, &x, &y)
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
public func benchmarkVectorOperationFloat(name: String, runs: Int, iterations: Int, maxDimension: Int, 
                                     naiveFunc: (_ multiplier: Float, _ x: inout Vector<Float>, _ y: inout Vector<Float>) -> Void, 
                                     blasFunc:  (_ multiplier: Float, _ x: inout Vector<Float>, _ y: inout Vector<Float>) -> Void) -> BenchmarkResult {
    var naiveTimes: [Int] = []
    var blasTimes: [Int] = []
    let dimensions = (2...maxDimension).map { $0 }

    for dimension in 2...maxDimension {
        print(dimension)
        var x: Vector<Float> = .init((0..<dimension).map { _ in .random(in: -10...10) } )
        var y: Vector<Float> = .init((0..<dimension).map { _ in .random(in: -10...10) } )
        var multiplier: Float = .random(in: -1...1)
        while multiplier == 0 { multiplier = .random(in: -1...1) }

        var bestNaiveTime: Duration = ContinuousClock.Duration.seconds(10)
        var bestBlasTime: Duration = ContinuousClock.Duration.seconds(10)

        for _ in 0..<runs {
            let naiveTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    naiveFunc(multiplier, &x, &y)
                }
            } / iterations
            if naiveTime < bestNaiveTime { bestNaiveTime = naiveTime }

            let blasTime = ContinuousClock().measure {
                for _ in 0..<iterations {
                    blasFunc(multiplier, &x, &y)
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