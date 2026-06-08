//
//  LeastSquares.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 8.6.2026.
//

public extension Optimize {
    enum LeastSquaresResult<Value> {
        case gaussNewton(GaussNewtonResult<Value>)
        case levenbergMarquardt(LevenbergMarquardtResult<Value>)
    }
    
    enum Method {
        case gaussNewton
        case levenbergMarquardt
    }
    
    @inlinable
    static func leastSquares(
        initial: Vector<Double>,
        method: Method = .levenbergMarquardt,
        maxIterations: Int = 1000,
        residualTolerance: Double = 1e-10,
        stepTolerance: Double = 1e-10,
        costTolerance: Double = 1e-12,
        gradientTolerance: Double = 1e-10,
        initialDamping: Double = 1e-3,
        dampingIncrease: Double = 10.0,
        dampingDecrease: Double = 0.3,
        minDamping: Double = 1e-30,
        maxDamping: Double = 1e30,
        residuals: (_ parameters: Vector<Double>) -> Vector<Double>,
        jacobian: ((_ parameters: Vector<Double>) -> Matrix<Double>)? = nil
    ) -> LeastSquaresResult<Double> {
        switch method {
        case .gaussNewton:
            let result = gaussNewton(
                initial: initial,
                maxIterations: maxIterations,
                stepTolerance: stepTolerance,
                residualTolerance: residualTolerance,
                residuals: residuals,
                jacobian: jacobian
            )
            return LeastSquaresResult.gaussNewton(result)
        case .levenbergMarquardt:
            let result = levenbergMarquardt(
                initial: initial,
                maxIterations: maxIterations,
                residualTolerance: residualTolerance,
                stepTolerance: stepTolerance,
                costTolerance: costTolerance,
                gradientTolerance: gradientTolerance,
                initialDamping: initialDamping,
                dampingIncrease: dampingIncrease,
                dampingDecrease: dampingDecrease,
                minDamping: minDamping,
                maxDamping: maxDamping,
                residuals: residuals,
                jacobian: jacobian
            )
            return LeastSquaresResult.levenbergMarquardt(result)
        }
    }
    
    @inlinable
    static func leastSquares(
        initial: Vector<Float>,
        method: Method = .levenbergMarquardt,
        maxIterations: Int = 1000,
        residualTolerance: Float = 1e-5,
        stepTolerance: Float = 1e-5,
        costTolerance: Float = 1e-6,
        gradientTolerance: Float = 1e-5,
        initialDamping: Float = 1e-3,
        dampingIncrease: Float = 10.0,
        dampingDecrease: Float = 0.3,
        minDamping: Float = 1e-30,
        maxDamping: Float = 1e30,
        residuals: (_ parameters: Vector<Float>) -> Vector<Float>,
        jacobian: ((_ parameters: Vector<Float>) -> Matrix<Float>)? = nil
    ) -> LeastSquaresResult<Float> {
        switch method {
        case .gaussNewton:
            let result = gaussNewton(
                initial: initial,
                maxIterations: maxIterations,
                stepTolerance: stepTolerance,
                residualTolerance: residualTolerance,
                residuals: residuals,
                jacobian: jacobian
            )
            return LeastSquaresResult.gaussNewton(result)
        case .levenbergMarquardt:
            let result = levenbergMarquardt(
                initial: initial,
                maxIterations: maxIterations,
                residualTolerance: residualTolerance,
                stepTolerance: stepTolerance,
                costTolerance: costTolerance,
                gradientTolerance: gradientTolerance,
                initialDamping: initialDamping,
                dampingIncrease: dampingIncrease,
                dampingDecrease: dampingDecrease,
                minDamping: minDamping,
                maxDamping: maxDamping,
                residuals: residuals,
                jacobian: jacobian
            )
            return LeastSquaresResult.levenbergMarquardt(result)
        }
    }
}


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
