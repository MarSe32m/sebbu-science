
public extension Optimize {
    struct GaussNewtonResult<Value> {
        public enum Reason {
            case residualTolerance
            case stepTolerance
            case maxIterations
            case linearSolveFailed
        }

        public var parameters: Vector<Value>
        public var cost: Value
        public var iterations: Int
        public var converged: Bool
        public var reason: Reason
        
        @inlinable
        public init(parameters: Vector<Value>, cost: Value, iterations: Int, converged: Bool, reason: Reason) {
            self.parameters = parameters
            self.cost = cost
            self.iterations = iterations
            self.converged = converged
            self.reason = reason
        }
    }
    
    @inlinable
    static func gaussNewton(
        initial: Vector<Double>,
        maxIterations: Int = 1000,
        stepTolerance: Double = 1e-10,
        residualTolerance: Double = 1e-10,
        residuals: (_ parameters: Vector<Double>) -> Vector<Double>,
        jacobian: ((_ parameters: Vector<Double>) -> Matrix<Double>)? = nil
    ) -> GaussNewtonResult<Double> {
        var x = initial
        var r = residuals(x)
        var cost = 0.5 * r.normSquared
        for i in 1...max(1, maxIterations) {
            if r.norm <= residualTolerance {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: i,
                    converged: true,
                    reason: .residualTolerance)
            }
            let J = if let jacobian {
                jacobian(x)
            } else {
                finiteDifferenceJacobian(parameters: x, residual: residuals)
            }
            precondition(J.rows == r.count)
            precondition(J.columns == x.count)
            r.multiply(by: -1)
            guard let step = try? Optimize.linearLeastSquares(A: J, r).result else {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: i,
                    converged: false,
                    reason: .linearSolveFailed)
            }
            let trial = x + step
            r = residuals(trial)
            cost = 0.5 * r.normSquared
            if step.norm <= stepTolerance * (x.norm + stepTolerance) {
                return .init(
                    parameters: trial,
                    cost: cost,
                    iterations: i,
                    converged: true,
                    reason: .stepTolerance
                )
            }
            x = trial
        }
        return .init(
            parameters: x,
            cost: cost,
            iterations: maxIterations,
            converged: false,
            reason: .maxIterations)
    }
    
    @inlinable
    static func gaussNewton(
        initial: Vector<Float>,
        maxIterations: Int = 1000,
        stepTolerance: Float = 1e-5,
        residualTolerance: Float = 1e-5,
        residuals: (_ parameters: Vector<Float>) -> Vector<Float>,
        jacobian: ((_ parameters: Vector<Float>) -> Matrix<Float>)? = nil
    ) -> GaussNewtonResult<Float> {
        var x = initial
        var r = residuals(x)
        var cost = 0.5 * r.normSquared
        for i in 1...max(1, maxIterations) {
            if r.norm <= residualTolerance {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: i,
                    converged: true,
                    reason: .residualTolerance)
            }
            let J = if let jacobian {
                jacobian(x)
            } else {
                finiteDifferenceJacobian(parameters: x, residual: residuals)
            }
            precondition(J.rows == r.count)
            precondition(J.columns == x.count)
            r.multiply(by: -1)
            guard let step = try? Optimize.linearLeastSquares(A: J, r).result else {
                return .init(
                    parameters: x,
                    cost: cost,
                    iterations: i,
                    converged: false,
                    reason: .linearSolveFailed)
            }
            let trial = x + step
            r = residuals(trial)
            cost = 0.5 * r.normSquared
            if step.norm <= stepTolerance * (x.norm + stepTolerance) {
                return .init(
                    parameters: trial,
                    cost: cost,
                    iterations: i,
                    converged: true,
                    reason: .stepTolerance
                )
            }
            x = trial
        }
        return .init(
            parameters: x,
            cost: cost,
            iterations: maxIterations,
            converged: false,
            reason: .maxIterations)
    }
}
