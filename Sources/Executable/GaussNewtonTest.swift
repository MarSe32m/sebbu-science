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
    let initialParameters: Vector<Double> = [-1000, -1000, -1000, -1000]
    let targetFunc: (Double) -> Double = { x in
        x*x*x + -2 * x * x - 4 * x + 5.0
    }
    let tSpace = [Double].linearSpace(-10, 10, 200)
    var random = NumPyRandom()
    let exact = tSpace.map { x in targetFunc(x) + random.nextNormal(mean: 0.0, stdev: 100.0) as Double }
    for iterations in 0..<1000 {
        guard let params = Optimize.gaussNewton(initial: initialParameters, maxIterations: iterations, residuals: { parameters in
            var residuals: Vector<Double> = .zero(tSpace.count)
            for (i, x) in tSpace.enumerated() {
                residuals[i] = exact[i] - (parameters[0] + parameters[1] * x + parameters[2] * x * x + parameters[3] * x * x * x)
            }
            return residuals
        }, jacobian: { parameters in
            var jacobian: Matrix<Double> = .zeros(rows: tSpace.count, columns: parameters.count)
            for i in 0..<jacobian.rows {
                for j in 0..<jacobian.columns {
                    jacobian[i, j] = -Double.pow(tSpace[i], j)
                }
            }
            return jacobian
        }) else { fatalError() }
        plt.figure()
        plt.plot(x: tSpace, y: exact, label: "Exact")
        plt.plot(x: tSpace, y: tSpace.map { x in params[0] + params[1] * x + params[2] * x * x + params[3] * x * x * x}, label: "Fit", linestyle: "--")
        plt.title("Iterations: \(iterations)")
        plt.legend()
        plt.xlabel("x")
        plt.ylabel("y")
        plt.show()
        plt.close()
    }
    
        
}
