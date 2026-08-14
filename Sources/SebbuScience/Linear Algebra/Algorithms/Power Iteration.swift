// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import NumericsExtensions

public extension LinearAlgebraAlgorithms {
    enum PowerIterationError: Error, Sendable {
        case iterationProducedZeroVector
    }
    
    /// Finds the approximate dominant eigenvalue and the corresponding eigenvector of the matrix A using power iteration
    /// - Parameters:
    ///   - A: Diagonalizable matrix for which to compute the approximate eigenvalue / eigenvector
    ///   - iterations: The number of iterations to run
    ///   - initialGuess: Initial guess for the eigenvector
    /// - Returns: Eigenvalue and eigenvector pair after `iterations` runs of the method
    @inlinable
    static func powerIteration<T: ConjugatableScalar>(_ A: Matrix<T>, iterations: Int, initialGuess: Vector<T>) throws(PowerIterationError) -> (eigenvalue: T, eigenvector: Vector<T>) {
        precondition(A.isSquare, "The matrix for power iteration must be a square matrix.")
        var b: Vector<T> = initialGuess
        b.divide(by: b.inner(b))
        var scratch: Vector<T> = .zero(A.rows)
        var eigenvalue: T = .zero
        for _ in 0..<iterations {
            A.dot(b, into: &scratch)
            let scratchNorm = scratch.inner(scratch)
            if scratchNorm.isApproximatelyZero {
                throw PowerIterationError.iterationProducedZeroVector
            }
            eigenvalue = b.inner(scratch) / b.inner(b)
            scratch.divide(by: scratchNorm)
            b.copyComponents(from: scratch)
        }
        return (eigenvalue, b)
    }
    
    /// Finds the approximate dominan eigenvalue and the corresponding eigenvector of the matrix A using power iterations
    /// - Parameters:
    ///   - A: Diagonalizable matrix for which to compute the approximate eigenvalue / eigenvector
    ///   - iterations: The number of iterations to run
    ///   - eigenvector: On entry, supplied initial, non-zero, guess of the dominan eigenvector. On exit, the approximate dominant eigenvector.
    /// - Returns: The approximate eigenvalue corresponding to the approximate eigenvector stored in `eigenvector`.
    @inlinable
    static func powerIteration<T: ConjugatableScalar>(_ A: borrowing UniqueMatrix<T>, iterations: Int, eigenvector: inout UniqueVector<T>) throws(PowerIterationError) -> T {
        precondition(A.isSquare, "The matrix for power iteration must be a square matrix.")
        eigenvector.normalize()
        var scratch: UniqueVector<T> = .zero(A.rows)
        var eigenvalue: T = .zero
        for _ in 0..<iterations {
            A.dot(eigenvector, into: &scratch)
            let scratchNorm = scratch.inner(scratch)
            if scratchNorm.isApproximatelyZero {
                throw PowerIterationError.iterationProducedZeroVector
            }
            eigenvalue = eigenvector.inner(scratch) / eigenvector.inner(eigenvector)
            scratch.divide(by: scratchNorm)
            eigenvector.copyComponents(from: scratch)
        }
        return eigenvalue
    }
}
