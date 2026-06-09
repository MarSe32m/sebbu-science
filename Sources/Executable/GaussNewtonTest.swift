//
//  GaussNewtonTest.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 19.9.2025.
//

import SebbuScience
import Numerics
import PythonKitUtilities

public func _testGaussNewtonDouble() {
    let initialParameters: Vector<Double> = [0.0, 0.0, 0.0, 0.0]
    let targetFunc: (Double) -> Double = { x in
        x*x*x + -2 * x * x - 4 * x + 5.0
            //.cos(x)
    }
    let tSpace = [Double].linearSpace(0, .pi, 200)
    var random = NumPyRandom()
    let exact = tSpace.map { x in targetFunc(x) + random.nextNormal(mean: 0.0, stdev: 0.001) as Double }
    for iterations in 1..<1000 {
        let result = Optimize.gaussNewton(initial: initialParameters, maxIterations: iterations, residuals: { parameters in
            var residuals: Vector<Double> = .zero(tSpace.count)
            for (i, x) in tSpace.enumerated() {
                let fitted = parameters.components.enumerated().reduce(into: 0.0) { (partialResult, p) in
                    let n = p.offset
                    let coefficient = p.element
                    partialResult += coefficient * .pow(x, n)
                }
                residuals[i] = exact[i] - fitted
            }
            return residuals
        })
        let params = result.parameters
        print(params)
        let fitted = tSpace.map { x in
            var t = 1.0
            var result = 0.0
            for param in params.components {
                result += param * t
                t *= x
            }
            return result
        }
        plt.figure()
        plt.plot(x: tSpace, y: exact, label: "Exact")
        plt.plot(x: tSpace, y: fitted, label: "Fit", linestyle: "--")
        plt.title("Iterations: \(iterations), cost: \(result.cost)")
        plt.legend()
        plt.xlabel("x")
        plt.ylabel("y")
        plt.show()
        plt.close()
    }
    
        
}
