// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import CMinpack

public extension Optimize {
    enum LevenbergMarquardtError: Error {
        case invalidDimensions
        case residualCountChanged(expected: Int, actual: Int)
        case invalidJacobianShape(
            expectedRows: Int,
            expectedColumns: Int,
            actualRows: Int,
            actualColumns: Int
        )
        case nonFiniteResidual
        case nonFiniteJacobian
        case invalidScaling
    }
    
    struct LevenbergMarquardtResult {
        public let parameters: Vector<Double>
        public let residuals: Vector<Double>
        
        public let info: Int32
        
        public let functionEvaluations: Int
        public let jacobianEvaluations: Int?
        
        public var converged: Bool { (1...4).contains(info) }
        
        public var sumOfSquares: Double {
            residuals.normSquared
        }
        
        public var cost: Double { 0.5 * sumOfSquares }
        
        @inlinable
        internal init(parameters: Vector<Double>, residuals: Vector<Double>, info: Int32, functionEvaluations: Int, jacobianEvaluations: Int?) {
            self.parameters = parameters
            self.residuals = residuals
            self.info = info
            self.functionEvaluations = functionEvaluations
            self.jacobianEvaluations = jacobianEvaluations
        }
    }
    
    @usableFromInline
    package final class LevenbergMarquardtContext {
        @usableFromInline
        let residuals: (Vector<Double>) -> Vector<Double>
        @usableFromInline
        let jacobian: ((Vector<Double>) -> Matrix<Double>)?
        
        @usableFromInline
        var error: LevenbergMarquardtError?
        
        @inlinable
        init(residuals: @escaping (Vector<Double>) -> Vector<Double>, jacobian: ((Vector<Double>) -> Matrix<Double>)?) {
            self.residuals = residuals
            self.jacobian = jacobian
        }
    }
    
    @inlinable
    static func levenbergMarquardt(
        initial: Vector<Double>,
        functionTolerance ftol: Double = 1e-8,
        stepTolerance xtol: Double = 1e-8,
        gradientTolerance gtol: Double = 1e-8,
        maxFunctionEvaluations: Int? = nil,
        finiteDifferenceFunctionError epsfcn: Double = .zero,
        scaling: [Double]? = nil,
        initialStepFactor: Double = 100,
        residuals: (Vector<Double>) -> Vector<Double>,
        jacobian: ((Vector<Double>) -> Matrix<Double>)? = nil
    ) throws -> LevenbergMarquardtResult {
        let initialResiduals = residuals(initial)
        let parameterCount = initial.count
        let residualCount = initialResiduals.count
        guard parameterCount > 0,
              residualCount >= parameterCount,
              parameterCount <= Int(Int32.max),
              residualCount <= Int(Int32.max),
              ftol >= 0, xtol >= 0, gtol >= 0, epsfcn >= 0,
              initialStepFactor > 0 else {
            throw LevenbergMarquardtError.invalidDimensions
        }
        let n = parameterCount
        let m = residualCount
        // mode = 1 -> MINPACK determines parameter scaling automatically
        // mode = 2 -> the user supplies positive scaling values in diag
        var diag = scaling ?? .init(repeating: 1, count: n)
        let mode: Int32 = scaling == nil ? 1 : 2
        guard diag.count == n, diag.allSatisfy({ $0.isFinite && $0 > 0 }) else {
            throw LevenbergMarquardtError.invalidScaling
        }
        // MINPACK's drivers use
        // lmdif -> 200 * (n + 1)
        // lmder -> 100 * (n + 1)
        let defaultMaximum = jacobian == nil ? 200 * (n + 1) : 100 * (n + 1)
        let maxfev = maxFunctionEvaluations ?? defaultMaximum
        guard maxfev > 0, maxfev <= Int(Int32.max) else {
            throw LevenbergMarquardtError.invalidDimensions
        }
        var x = initial.components
        var fvec: [Double] = .init(repeating: .zero, count: m)
        var fjac: [Double] = .init(repeating: .zero, count: m * n)
        var ipvt: [Int32] = .init(repeating: .zero, count: n)
        var qtf: [Double] = .init(repeating: .zero, count: n)
        var wa1: [Double] = .init(repeating: .zero, count: n)
        var wa2: [Double] = .init(repeating: .zero, count: n)
        var wa3: [Double] = .init(repeating: .zero, count: n)
        var wa4: [Double] = .init(repeating: .zero, count: m)
        
        var functionEvaluations: Int32 = 0
        var jacobianEvaluations: Int32 = 0
        return try withoutActuallyEscaping(residuals) { residuals in
            let context = LevenbergMarquardtContext(residuals: residuals, jacobian: jacobian)
            let contextPtr = Unmanaged.passUnretained(context).toOpaque()
            let info: Int32 = if jacobian == nil {
                lmdif(cminpackLMDIFCallback, contextPtr, Int32(m), Int32(n), &x, &fvec, ftol, xtol, gtol, Int32(maxfev), epsfcn, &diag, mode, initialStepFactor, 0, &functionEvaluations, &fjac, Int32(m), &ipvt, &qtf, &wa1, &wa2, &wa3, &wa4)
            } else {
                lmder(cminpackLMDERCallback, contextPtr, Int32(m), Int32(n), &x, &fvec, &fjac, Int32(m), ftol, xtol, gtol, Int32(maxfev), &diag, mode, initialStepFactor, 0, &functionEvaluations, &jacobianEvaluations, &ipvt, &qtf, &wa1, &wa2, &wa3, &wa4)
            }
            if let error = context.error {
                throw error
            }
            return LevenbergMarquardtResult(parameters: Vector(x), residuals: Vector(fvec), info: info, functionEvaluations: Int(functionEvaluations), jacobianEvaluations: jacobian == nil ? nil : Int(jacobianEvaluations))
        }
    }
}

@c
@inlinable
package func cminpackLMDIFCallback(_ contextPtr: UnsafeMutableRawPointer?, _ m: Int32, _ n: Int32, _ x: UnsafePointer<Double>?, _ fvec: UnsafeMutablePointer<Double>?, _ iflag: Int32) -> Int32 {
    // iflag == 0 is an optional printing / progress callback
    guard iflag != 0 else { return 0 }
    guard let contextPtr, let x, let fvec else { return -1 }
    
    let context = Unmanaged<Optimize.LevenbergMarquardtContext>.fromOpaque(contextPtr).takeUnretainedValue()
    let parameters: Vector<Double> = .init(Array(UnsafeBufferPointer(start: x, count: Int(n))))
    let residuals = context.residuals(parameters)
    guard residuals.count == Int(m) else {
        context.error = .residualCountChanged(expected: Int(m), actual: residuals.count)
        return -1
    }
    guard residuals.components.allSatisfy(\.isFinite) else {
        context.error = .nonFiniteResidual
        return -1
    }
    for i in 0..<Int(m) {
        fvec[i] = residuals[i]
    }
    return 0
}

@c
@inlinable
package func cminpackLMDERCallback(_ contextPtr: UnsafeMutableRawPointer?, _ m: Int32, _ n: Int32, _ x: UnsafePointer<Double>?, _ fvec: UnsafeMutablePointer<Double>?, _ fjac: UnsafeMutablePointer<Double>?, _ ldfjac: Int32, _ iflag: Int32) -> Int32 {
    // iflag == 0 is an optional printing / progress callback
    guard iflag != 0 else { return 0 }
    guard let contextPtr, let x else { return -1 }
    
    let context = Unmanaged<Optimize.LevenbergMarquardtContext>.fromOpaque(contextPtr).takeUnretainedValue()
    let parameters: Vector<Double> = .init(Array(UnsafeBufferPointer(start: x, count: Int(n))))
    switch iflag {
    case 1:
        guard let fvec else { return -1 }
        let residuals = context.residuals(parameters)
        guard residuals.count == Int(m) else {
            context.error = .residualCountChanged(expected: Int(m), actual: residuals.count)
            return -1
        }
        guard residuals.components.allSatisfy(\.isFinite) else {
            context.error = .nonFiniteResidual
            return -1
        }
        for i in 0..<Int(m) {
            fvec[i] = residuals[i]
        }
    case 2:
        guard let fjac, let jacobian = context.jacobian else { return -1 }
        let J = jacobian(parameters)
        guard J.rows == Int(m), J.columns == Int(n) else {
            context.error = .invalidJacobianShape(expectedRows: Int(m), expectedColumns: Int(n), actualRows: J.rows, actualColumns: J.columns)
            return -1
        }
        guard J.elements.allSatisfy(\.isFinite) else {
            context.error = .nonFiniteJacobian
            return -1
        }
        let leadingDimension = Int(ldfjac)
        for column in 0..<Int(n) {
            for row in 0..<Int(m) {
                // cminpack expects column-major layout
                fjac[row + column * leadingDimension] = J[row, column]
            }
        }
    default:
        break
    }
    return 0
}
