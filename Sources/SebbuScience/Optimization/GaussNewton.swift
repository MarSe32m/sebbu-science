
public extension Optimize {
    @inlinable
    static func gaussNewton(
        initial: Vector<Double>,
        maxIterations: Int = 1000,
        stepTolerance: Double = 1e-10,
        residualTolerance: Double = 1e-10,
        residuals: (_ parameters: Vector<Double>) -> Vector<Double>,
        jacobian: (_ parameters: Vector<Double>) -> Matrix<Double>
    ) -> Vector<Double>? {
        var x = initial
        for _ in 0..<max(2, maxIterations) {
            var r = residuals(x)
            r.multiply(by: -1)
            if r.norm <= residualTolerance { return x }
            let J = jacobian(x)
            precondition(J.rows == r.count)
            precondition(J.columns == x.count)
            guard let step = try? Optimize.linearLeastSquares(A: J, /*this is -r*/r).result else { return nil }
            let trial = x + step
            if step.norm <= stepTolerance * (x.norm + stepTolerance) { return trial }
            x = trial
        }
        return x
    }
    
    @inlinable
    static func gaussNewton(
        initial: Vector<Float>,
        maxIterations: Int = 1000,
        stepTolerance: Float = 1e-5,
        residualTolerance: Float = 1e-5,
        residuals: (_ parameters: Vector<Float>) -> Vector<Float>,
        jacobian: (_ parameters: Vector<Float>) -> Matrix<Float>
    ) -> Vector<Float>? {
        var x = initial
        for _ in 0..<max(2, maxIterations) {
            var r = residuals(x)
            r.multiply(by: -1)
            if r.norm <= residualTolerance { return x }
            let J = jacobian(x)
            precondition(J.rows == r.count)
            precondition(J.columns == x.count)
            guard let step = try? Optimize.linearLeastSquares(A: J, /*this is -r*/r).result else { return nil }
            let trial = x + step
            if step.norm <= stepTolerance * (x.norm + stepTolerance) { return trial }
            x = trial
        }
        return x
    }
}
