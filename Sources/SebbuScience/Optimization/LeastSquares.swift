//
//  LeastSquares.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 8.6.2026.
//

@inlinable
package func finiteDifferenceJacobian(
    parameters: Vector<Double>,
    residual: (Vector<Double>) -> Vector<Double>,
    eps: Double = 1e-6
) -> Matrix<Double> {
    let r0 = residual(parameters)
    let m = r0.count
    let p = parameters.count
    var parametersPlus = parameters
    var parametersMinus = parameters
    var J: Matrix<Double> = .zeros(rows: m, columns: p)
    for j in 0..<p {
        let h = eps * (1.0 + parameters[j].magnitude)
        parametersPlus[j] += h
        parametersMinus[j] -= h
        let rPlus = residual(parametersPlus)
        let rMinus = residual(parametersMinus)
        for i in 0..<m {
            J[i, j] = (rPlus[i] - rMinus[i]) / (2 * h)
        }
        parametersPlus[j] = parameters[j]
        parametersMinus[j] = parameters[j]
    }
    return J
}

@inlinable
package func finiteDifferenceJacobian(
    parameters: Vector<Float>,
    residual: (Vector<Float>) -> Vector<Float>,
    eps: Float = 1e-3
) -> Matrix<Float> {
    let r0 = residual(parameters)
    let m = r0.count
    let p = parameters.count
    var parametersPlus = parameters
    var parametersMinus = parameters
    var J: Matrix<Float> = .zeros(rows: m, columns: p)
    for j in 0..<p {
        let h = eps * (1.0 + parameters[j].magnitude)
        parametersPlus[j] += h
        parametersMinus[j] -= h
        let rPlus = residual(parametersPlus)
        let rMinus = residual(parametersMinus)
        for i in 0..<m {
            J[i, j] = (rPlus[i] - rMinus[i]) / (2 * h)
        }
        parametersPlus[j] = parameters[j]
        parametersMinus[j] = parameters[j]
    }
    return J
}
