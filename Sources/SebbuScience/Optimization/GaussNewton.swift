
public extension Optimize {
    static func gaussNewton(
        initial: Vector<Double>,
        maxIterations: Int = 1000,
        tolerance: Double = 1e-10,
        residuals: (_ parameters: Vector<Double>) -> Vector<Double>,
        jacobian: (_ parameters: Vector<Double>) -> Matrix<Double>
    ) -> Vector<Double>? {
        var currentParameters = initial
        for _ in 0..<max(1, maxIterations) {
            let r = residuals(currentParameters)
            let J = jacobian(currentParameters)
            
            guard let JpseudoInverse = J.pseudoInverse else { return nil }
            
            let step = JpseudoInverse.dot(r)
            let newParameters = currentParameters - step
            
            if step.norm < tolerance || r.norm < tolerance {
                return newParameters
            }
            currentParameters = newParameters
        }
        return nil // did not converge
    }
    
    static func gaussNewton(
        initial: [Double],
        maxIterations: Int = 1000,
        tolerance: Double = 1e-10,
        residuals: (_ parameters: [Double]) -> [Double],
        jacobian: (_ parameters: [Double]) -> Matrix<Double>
    ) -> [Double]? {
        return gaussNewton(initial: Vector(initial), maxIterations: maxIterations, tolerance: tolerance) { parameters in
            Vector(residuals(parameters.components))
        } jacobian: { parameters in
            jacobian(parameters.components)
        }?.components
    }
    
    static func gaussNewton(
        initial: Vector<Float>,
        maxIterations: Int = 1000,
        tolerance: Float = 1e-5,
        residuals: (_ parameters: Vector<Float>) -> Vector<Float>,
        jacobian: (_ parameters: Vector<Float>) -> Matrix<Float>
    ) -> Vector<Float>? {
        var currentParameters = initial
        for _ in 0..<max(1, maxIterations) {
            let r = residuals(currentParameters)
            let J = jacobian(currentParameters)
            
            guard let JpseudoInverse = J.pseudoInverse else { return nil }
            
            let step = JpseudoInverse.dot(r)
            let newParameters = currentParameters - step
            
            if step.norm < tolerance || r.norm < tolerance {
                return newParameters
            }
            currentParameters = newParameters
        }
        return nil // did not converge
    }
    
    static func gaussNewton(
        initial: [Float],
        maxIterations: Int = 1000,
        tolerance: Float = 1e-5,
        residuals: (_ parameters: [Float]) -> [Float],
        jacobian: (_ parameters: [Float]) -> Matrix<Float>
    ) -> [Float]? {
        return gaussNewton(initial: Vector(initial), maxIterations: maxIterations, tolerance: tolerance) { parameters in
            Vector(residuals(parameters.components))
        } jacobian: { parameters in
            jacobian(parameters.components)
        }?.components
    }
    
    static func gaussNewton(
        initial: Vector<Complex<Double>>,
        maxIterations: Int = 1000,
        tolerance: Double = 1e-10,
        residuals: (_ parameters: Vector<Complex<Double>>) -> Vector<Complex<Double>>,
        jacobian: (_ parameters: Vector<Complex<Double>>) -> Matrix<Complex<Double>>
    ) -> Vector<Complex<Double>>? {
        var currentParameters = initial
        for _ in 0..<max(1, maxIterations) {
            let r = residuals(currentParameters)
            let J = jacobian(currentParameters)
            
            guard let JpseudoInverse = J.pseudoInverse else { return nil }
            
            let step = JpseudoInverse.dot(r)
            let newParameters = currentParameters - step
            
            if step.norm < tolerance || r.norm < tolerance {
                return newParameters
            }
            currentParameters = newParameters
        }
        return nil // did not converge
    }
    
    static func gaussNewton(
        initial: [Complex<Double>],
        maxIterations: Int = 1000,
        tolerance: Double = 1e-10,
        residuals: (_ parameters: [Complex<Double>]) -> [Complex<Double>],
        jacobian: (_ parameters: [Complex<Double>]) -> Matrix<Complex<Double>>
    ) -> [Complex<Double>]? {
        return gaussNewton(initial: Vector(initial), maxIterations: maxIterations, tolerance: tolerance) { parameters in
            Vector(residuals(parameters.components))
        } jacobian: { parameters in
            jacobian(parameters.components)
        }?.components
    }
    
    static func gaussNewton(
        initial: Vector<Complex<Float>>,
        maxIterations: Int = 1000,
        tolerance: Float = 1e-5,
        residuals: (_ parameters: Vector<Complex<Float>>) -> Vector<Complex<Float>>,
        jacobian: (_ parameters: Vector<Complex<Float>>) -> Matrix<Complex<Float>>
    ) -> Vector<Complex<Float>>? {
        var currentParameters = initial
        for _ in 0..<max(1, maxIterations) {
            let r = residuals(currentParameters)
            let J = jacobian(currentParameters)
            
            guard let JpseudoInverse = J.pseudoInverse else { return nil }
            
            let step = JpseudoInverse.dot(r)
            let newParameters = currentParameters - step
            
            if step.norm < tolerance || r.norm < tolerance {
                return newParameters
            }
            currentParameters = newParameters
        }
        return nil // did not converge
    }
    
    static func gaussNewton(
        initial: [Complex<Float>],
        maxIterations: Int = 1000,
        tolerance: Float = 1e-5,
        residuals: (_ parameters: [Complex<Float>]) -> [Complex<Float>],
        jacobian: (_ parameters: [Complex<Float>]) -> Matrix<Complex<Float>>
    ) -> [Complex<Float>]? {
        return gaussNewton(initial: Vector(initial), maxIterations: maxIterations, tolerance: tolerance) { parameters in
            Vector(residuals(parameters.components))
        } jacobian: { parameters in
            jacobian(parameters.components)
        }?.components
    }
}
