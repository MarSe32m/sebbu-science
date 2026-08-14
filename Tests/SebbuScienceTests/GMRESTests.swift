// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

struct GMRESTests {
    @Test("GMRES solves a real dense system")
    func realDenseSystem() {
        let matrix = Matrix<Double>(
            elements: [
                4, 1, 2,
                0, 3, -1,
                2, 0, 5
            ],
            rows: 3,
            columns: 3
        )
        let expected: Vector<Double> = [1, -2, 0.5]
        let b = UniqueVector(matrix.dot(expected).components)
        var solution: UniqueVector<Double> = .zero(3)

        let result = MatrixOperations.gmres(
            linearOperator: matrix,
            b: b,
            solution: &solution,
            restart: 3,
            maxIterations: 3,
            relativeTolerance: 1e-12,
            absoluteTolerance: 1e-14,
            reorthogonalization: .always
        )

        #expect(result.converged)
        #expect(result.reason == .converged)
        #expect(result.iterations <= 3)
        #expect(result.residualNorm <= 1e-11)
        #expect(Vector(copying: solution).isApproximatelyEqual(to: expected, absoluteTolerance: 1e-11))
    }

    @Test("Restarted GMRES solves a complex non-Hermitian system")
    func complexRestartedSystem() {
        let matrix = Matrix<Complex<Double>>(
            elements: [
                Complex(4, 1), 1, 0,
                0, Complex(3, -0.5), 1,
                1, 0, Complex(2, 0.25)
            ],
            rows: 3,
            columns: 3
        )
        let expected: Vector<Complex<Double>> = [
            Complex(1, -0.5),
            Complex(-2, 0.25),
            Complex(0.75, 1)
        ]
        let b = UniqueVector(matrix.dot(expected).components)
        var solution: UniqueVector<Complex<Double>> = .zero(3)

        let result = MatrixOperations.gmres(
            linearOperator: matrix,
            b: b,
            solution: &solution,
            restart: 2,
            maxIterations: 40,
            relativeTolerance: 1e-12,
            absoluteTolerance: 1e-14
        )

        #expect(result.converged)
        #expect(result.restartCycles > 1)
        #expect(result.residualNorm <= 1e-10)
        #expect(Vector(copying: solution).isApproximatelyEqual(to: expected, absoluteTolerance: 1e-10))
    }

    @Test("GMRES accepts a CSR linear operator")
    func sparseSystem() {
        let matrix = CSRMatrix<Double>(
            rows: 4,
            columns: 4,
            values: [4, -1, -1, 4, -1, -1, 4, -1, -1, 3],
            rowIndices: [0, 2, 5, 8, 10],
            columnIndices: [0, 1, 0, 1, 2, 1, 2, 3, 2, 3]
        )
        let expected: Vector<Double> = [1, 2, -1, 0.5]
        let b = UniqueVector(matrix.dot(expected).components)
        var solution: UniqueVector<Double> = .zero(4)

        let result = MatrixOperations.gmres(
            linearOperator: matrix,
            b: b,
            solution: &solution,
            restart: 4,
            maxIterations: 4,
            relativeTolerance: 1e-12,
            absoluteTolerance: 1e-14
        )

        #expect(result.converged)
        #expect(Vector(copying: solution).isApproximatelyEqual(to: expected, absoluteTolerance: 1e-11))
    }

    @Test("GMRES detects an exact initial guess")
    func exactInitialGuess() {
        let matrix = Matrix<Double>.identity(rows: 3)
        let b = UniqueVector<Double>([1, -2, 3])
        var solution = UniqueVector<Double>([1, -2, 3])

        let result = MatrixOperations.gmres(
            linearOperator: matrix,
            b: b,
            solution: &solution
        )

        #expect(result.converged)
        #expect(result.iterations == 0)
        #expect(result.restartCycles == 0)
        #expect(result.residualNorm == 0)
    }

    @Test("GMRES reports Arnoldi breakdown")
    func breakdown() {
        let matrix = Matrix<Double>.zeros(rows: 2, columns: 2)
        let b = UniqueVector<Double>([1, -1])
        var solution: UniqueVector<Double> = .zero(2)

        let result = MatrixOperations.gmres(
            linearOperator: matrix,
            b: b,
            solution: &solution,
            restart: 2,
            maxIterations: 2,
            relativeTolerance: 1e-12
        )

        #expect(!result.converged)
        #expect(result.reason == .breakdown)
        #expect(result.iterations == 1)
    }

    @Test("GMRES respects the maximum iteration count")
    func maximumIterations() {
        let matrix = Matrix<Double>(
            elements: [
                4, 1,
                2, 3
            ],
            rows: 2,
            columns: 2
        )
        let b = UniqueVector<Double>([1, 0])
        var solution: UniqueVector<Double> = .zero(2)

        let result = MatrixOperations.gmres(
            linearOperator: matrix,
            b: b,
            solution: &solution,
            restart: 1,
            maxIterations: 1,
            relativeTolerance: 1e-15
        )

        #expect(!result.converged)
        #expect(result.reason == .maximumIterations)
        #expect(result.iterations == 1)
    }
}
