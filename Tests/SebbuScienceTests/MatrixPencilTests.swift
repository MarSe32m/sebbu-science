// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import Testing
@testable import SebbuScience

struct MatrixPencilTests {
    @Test("Scalar complex samples recover poles and amplitudes")
    func scalarComplexFit() {
        let dt = 0.06
        let expectedW = [
            Complex(0.18, 0.70),
            Complex(0.57, -1.05),
            Complex(1.10, 0.25),
        ]
        let expectedG = [
            Complex(1.20, 0.30),
            Complex(-0.45, 0.80),
            Complex(0.25, -0.15),
        ]
        let samples = scalarSamples(
            amplitudes: expectedG,
            exponents: expectedW,
            count: 80,
            step: dt
        )

        let result = MatrixPencil.fit(
            samples: samples,
            step: dt,
            pencilParameter: 37,
            terms: expectedW.count
        )

        #expect(result.W.count == expectedW.count)
        #expect(result.G.count == expectedG.count)
        guard result.W.count == expectedW.count else { return }
        let indices = matchingIndices(recovered: result.W, expected: expectedW)
        for term in expectedW.indices {
            let recovered = indices[term]
            #expect((result.W[recovered] - expectedW[term]).length < 1e-8)
            #expect((result.G[recovered] - expectedG[term]).length < 1e-8)
        }
    }

    @Test("Scalar real samples infer the number of terms")
    func scalarRealAutomaticRank() {
        let dt = 0.08
        let expectedW = [Complex(0.24), Complex(0.91)]
        let expectedG = [Complex(1.75), Complex(-0.40)]
        let complexSamples = scalarSamples(
            amplitudes: expectedG,
            exponents: expectedW,
            count: 64,
            step: dt
        )
        let samples = complexSamples.map(\.real)

        let result = MatrixPencil.fit(samples: samples, step: dt)

        #expect(result.W.count == expectedW.count)
        #expect(result.G.count == expectedG.count)
        guard result.W.count == expectedW.count else { return }
        let indices = matchingIndices(recovered: result.W, expected: expectedW)
        for term in expectedW.indices {
            let recovered = indices[term]
            #expect((result.W[recovered] - expectedW[term]).length < 1e-8)
            #expect((result.G[recovered] - expectedG[term]).length < 1e-8)
        }
    }

    @Test("A zero scalar function has zero inferred terms")
    func scalarZeroFunction() {
        let result = MatrixPencil.fit(
            samples: [Complex<Double>](repeating: .zero, count: 16),
            step: 0.1
        )

        #expect(result.G.isEmpty)
        #expect(result.W.isEmpty)
    }

    @Test("Multi-output samples use one common pole set")
    func vectorValuedFit() {
        let dt = 0.05
        let expectedW = [
            Complex(0.16, 0.45),
            Complex(0.61, -0.85),
            Complex(1.25, 1.20),
        ]
        let expectedG: [Vector<Complex<Double>>] = [
            Vector([Complex(1.0, 0.2), .zero, Complex(-0.3, 0.7), Complex(1.5)]),
            Vector([.zero, Complex(0.8, -0.1), Complex(1.1), Complex(-0.4, 0.2)]),
            Vector([Complex(0.2, -0.5), Complex(-0.6, 0.3), .zero, Complex(0.7, 0.9)]),
        ]
        let samples = vectorSamples(
            amplitudes: expectedG,
            exponents: expectedW,
            count: 72,
            step: dt
        )

        // Leave `terms` unspecified to exercise rank selection from the
        // combined output Hankel matrix.
        let result = MatrixPencil.fit(
            samples: samples,
            step: dt,
            pencilParameter: 32
        )

        #expect(result.W.count == expectedW.count)
        #expect(result.G.count == expectedG.count)
        guard result.W.count == expectedW.count else { return }
        let indices = matchingIndices(recovered: result.W, expected: expectedW)
        for term in expectedW.indices {
            let recovered = indices[term]
            #expect((result.W[recovered] - expectedW[term]).length < 1e-8)
            #expect(result.G[recovered].count == expectedG[term].count)
            for output in 0..<expectedG[term].count {
                #expect(
                    (result.G[recovered][output] - expectedG[term][output]).length
                        < 1e-8
                )
            }
        }
    }

    @Test("Matrix samples recover full-rank residue matrices without duplicate poles")
    func matrixValuedFit() {
        let dt = 0.07
        let expectedW = [Complex(0.22, 0.65), Complex(0.83, -0.40)]
        let expectedG = [
            Matrix<Complex<Double>>(
                elements: [
                    Complex(1.0, 0.2), Complex(0.3, -0.4),
                    Complex(-0.2, 0.6), Complex(0.8, 0.1),
                ],
                rows: 2,
                columns: 2
            ),
            Matrix<Complex<Double>>(
                elements: [
                    Complex(-0.4, 0.3), Complex(0.7, 0.2),
                    Complex(0.5, -0.1), Complex(1.2, -0.5),
                ],
                rows: 2,
                columns: 2
            ),
        ]
        let samples = matrixSamples(
            amplitudes: expectedG,
            exponents: expectedW,
            count: 68,
            step: dt
        )

        let result = MatrixPencil.fit(
            samples: samples,
            step: dt,
            pencilParameter: 30,
            terms: expectedW.count
        )

        #expect(result.W.count == expectedW.count)
        #expect(result.G.count == expectedG.count)
        guard result.W.count == expectedW.count else { return }
        let indices = matchingIndices(recovered: result.W, expected: expectedW)
        for term in expectedW.indices {
            let recovered = indices[term]
            #expect((result.W[recovered] - expectedW[term]).length < 1e-8)
            #expect(result.G[recovered].rows == 2)
            #expect(result.G[recovered].columns == 2)
            for element in expectedG[term].elements.indices {
                #expect(
                    (result.G[recovered].elements[element]
                        - expectedG[term].elements[element]).length < 1e-8
                )
            }
        }
    }
}

private func scalarSamples(
    amplitudes: [Complex<Double>],
    exponents: [Complex<Double>],
    count: Int,
    step: Double
) -> [Complex<Double>] {
    precondition(amplitudes.count == exponents.count)
    return (0..<count).map { sample in
        var value = Complex<Double>.zero
        for term in amplitudes.indices {
            value += amplitudes[term]
                * .exp(-Double(sample) * step * exponents[term])
        }
        return value
    }
}

private func vectorSamples(
    amplitudes: [Vector<Complex<Double>>],
    exponents: [Complex<Double>],
    count: Int,
    step: Double
) -> [Vector<Complex<Double>>] {
    precondition(amplitudes.count == exponents.count)
    let outputCount = amplitudes[0].count
    precondition(amplitudes.allSatisfy { $0.count == outputCount })
    return (0..<count).map { sample in
        var value = [Complex<Double>](repeating: .zero, count: outputCount)
        for term in amplitudes.indices {
            let factor = Complex<Double>.exp(
                -Double(sample) * step * exponents[term]
            )
            for output in 0..<outputCount {
                value[output] += amplitudes[term][output] * factor
            }
        }
        return Vector(value)
    }
}

private func matrixSamples(
    amplitudes: [Matrix<Complex<Double>>],
    exponents: [Complex<Double>],
    count: Int,
    step: Double
) -> [Matrix<Complex<Double>>] {
    precondition(amplitudes.count == exponents.count)
    let rows = amplitudes[0].rows
    let columns = amplitudes[0].columns
    precondition(
        amplitudes.allSatisfy { $0.rows == rows && $0.columns == columns }
    )
    return (0..<count).map { sample in
        var elements = [Complex<Double>](
            repeating: .zero,
            count: rows * columns
        )
        for term in amplitudes.indices {
            let factor = Complex<Double>.exp(
                -Double(sample) * step * exponents[term]
            )
            for element in elements.indices {
                elements[element] += amplitudes[term].elements[element] * factor
            }
        }
        return Matrix(elements: elements, rows: rows, columns: columns)
    }
}

/// Greedily matches each expected pole to the nearest unused recovered pole.
/// The synthetic tests use well-separated poles, so the matching is unique.
private func matchingIndices(
    recovered: [Complex<Double>],
    expected: [Complex<Double>]
) -> [Int] {
    precondition(recovered.count == expected.count)
    var available = Array(recovered.indices)
    return expected.map { expectedPole in
        let position = available.indices.min { lhs, rhs in
            (recovered[available[lhs]] - expectedPole).length
                < (recovered[available[rhs]] - expectedPole).length
        }!
        return available.remove(at: position)
    }
}
