// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import NumericsExtensions
import SebbuLAPACK

/// Matrix pencil routines for finding exponential-series representations.
public enum MatrixPencil {
    /// Fits a scalar complex function such that
    /// `f(t) ≈ Σᵢ Gᵢ exp(-Wᵢ t)`.
    ///
    /// - Parameters:
    ///   - samples: Uniformly spaced samples of the function.
    ///   - step: Spacing of the samples.
    ///   - pencilParameter: Number of columns in the Hankel matrices. The
    ///     default is half the number of samples.
    ///   - terms: Number of exponentials to retain. When omitted, the
    ///     numerical rank of the Hankel matrix is used.
    /// - Returns: The fitted amplitudes `G` and exponents `W`.
    public static func fit(
        samples y: [Complex<Double>],
        step dt: Double,
        pencilParameter: Int? = nil,
        terms: Int? = nil
    ) -> (G: [Complex<Double>], W: [Complex<Double>]) {
        let samples = Matrix<Complex<Double>>(
            elements: y,
            rows: y.count,
            columns: 1
        )
        let result = fit(
            samples: samples,
            step: dt,
            pencilParameter: pencilParameter,
            terms: terms
        )
        return (
            G: (0..<result.G.rows).map { result.G[$0, 0] },
            W: result.W
        )
    }

    /// Fits a scalar real function such that
    /// `f(t) ≈ Σᵢ Gᵢ exp(-Wᵢ t)`.
    ///
    /// The returned amplitudes and exponents are complex because a real
    /// function may be represented by complex-conjugate exponential pairs.
    public static func fit(
        samples y: [Double],
        step dt: Double,
        pencilParameter: Int? = nil,
        terms: Int? = nil
    ) -> (G: [Complex<Double>], W: [Complex<Double>]) {
        fit(
            samples: y.map { Complex($0) },
            step: dt,
            pencilParameter: pencilParameter,
            terms: terms
        )
    }

    /// Fits vector-valued samples with one common set of exponents:
    /// `y(t) ≈ Σᵢ Gᵢ exp(-Wᵢ t)`.
    ///
    /// Every sample must have the same number of outputs. A mode may have a
    /// zero amplitude in any individual output as long as it is observable
    /// in the combined sample sequence.
    ///
    /// - Returns: One amplitude vector for every exponent in `W`.
    public static func fit(
        samples y: [Vector<Complex<Double>>],
        step dt: Double,
        pencilParameter: Int? = nil,
        terms: Int? = nil
    ) -> (G: [Vector<Complex<Double>>], W: [Complex<Double>]) {
        precondition(!y.isEmpty, "At least two samples are required")
        let outputCount = y[0].count
        precondition(outputCount > 0, "Samples must contain at least one output")
        precondition(
            y.allSatisfy { $0.count == outputCount },
            "All samples must have the same number of outputs"
        )

        let samples = Matrix<Complex<Double>>(
            rows: y.count,
            columns: outputCount
        ) { buffer in
            for sample in y.indices {
                for output in 0..<outputCount {
                    buffer[sample * outputCount + output] = y[sample][output]
                }
            }
        }
        let result = fit(
            samples: samples,
            step: dt,
            pencilParameter: pencilParameter,
            terms: terms
        )
        return (
            G: result.G.extractRows().map(Vector.init),
            W: result.W
        )
    }

    /// Fits matrix-valued samples with one common set of exponents:
    /// `A(t) ≈ Σᵢ Gᵢ exp(-Wᵢ t)`.
    ///
    /// The matrices are vectorized in their native row-major storage order
    /// before applying the multi-output pencil. Consequently, each common
    /// exponential appears once even when its residue matrix has rank greater
    /// than one.
    ///
    /// - Returns: One residue matrix for every exponent in `W`.
    public static func fit(
        samples y: [Matrix<Complex<Double>>],
        step dt: Double,
        pencilParameter: Int? = nil,
        terms: Int? = nil
    ) -> (G: [Matrix<Complex<Double>>], W: [Complex<Double>]) {
        precondition(!y.isEmpty, "At least two samples are required")
        let rows = y[0].rows
        let columns = y[0].columns
        precondition(rows > 0 && columns > 0, "Sample matrices must not be empty")
        precondition(
            y.allSatisfy { $0.rows == rows && $0.columns == columns },
            "All sample matrices must have the same dimensions"
        )

        let vectorSamples = y.map { Vector($0.elements) }
        let result = fit(
            samples: vectorSamples,
            step: dt,
            pencilParameter: pencilParameter,
            terms: terms
        )
        return (
            G: result.G.map {
                Matrix(elements: $0.components, rows: rows, columns: columns)
            },
            W: result.W
        )
    }

    /// Fits a multi-output sample matrix with one common set of exponents.
    ///
    /// Each row contains the outputs at one uniformly spaced time, while each
    /// column is one scalar output channel. If the returned amplitude matrix
    /// is `G`, row `i` contains the amplitudes associated with `W[i]`.
    public static func fit(
        samples y: Matrix<Complex<Double>>,
        step dt: Double,
        pencilParameter: Int? = nil,
        terms requestedTerms: Int? = nil
    ) -> (G: Matrix<Complex<Double>>, W: [Complex<Double>]) {
        let sampleCount = y.rows
        let outputCount = y.columns
        precondition(sampleCount >= 2, "At least two samples are required")
        precondition(outputCount > 0, "Samples must contain at least one output")
        precondition(dt.isFinite && dt > 0, "The sample spacing must be finite and positive")

        let pencilParameter = pencilParameter ?? sampleCount / 2
        precondition(
            pencilParameter > 0 && pencilParameter < sampleCount,
            "The pencil parameter must be between zero and the number of samples"
        )

        let blockRows = sampleCount - pencilParameter
        let hankelRows = blockRows * outputCount
        let Y0 = Matrix<Complex<Double>>(
            rows: hankelRows,
            columns: pencilParameter
        ) { buffer in
            for blockRow in 0..<blockRows {
                for output in 0..<outputCount {
                    let row = blockRow * outputCount + output
                    for column in 0..<pencilParameter {
                        buffer[row * pencilParameter + column] =
                            y[blockRow + column, output]
                    }
                }
            }
        }
        let Y1 = Matrix<Complex<Double>>(
            rows: hankelRows,
            columns: pencilParameter
        ) { buffer in
            for blockRow in 0..<blockRows {
                for output in 0..<outputCount {
                    let row = blockRow * outputCount + output
                    for column in 0..<pencilParameter {
                        buffer[row * pencilParameter + column] =
                            y[blockRow + column + 1, output]
                    }
                }
            }
        }

        // An economy-sized SVD is essential here: for many output channels,
        // the full left singular-vector matrix would be unnecessarily huge.
        let (U, singularValues, VH) = try! thinSingularValueDecomposition(Y0)
        let terms = requestedTerms ?? numericalRank(singularValues)
        precondition(terms >= 0, "The number of terms must not be negative")
        precondition(
            terms <= singularValues.count,
            "The number of terms exceeds the maximum pencil rank"
        )

        if terms == 0 {
            return (
                G: Matrix(elements: [], rows: 0, columns: outputCount),
                W: []
            )
        }
        precondition(
            singularValues[terms - 1] > 0,
            "The requested number of terms exceeds the numerical rank"
        )

        var Uk = Matrix<Complex<Double>>.zeros(rows: U.rows, columns: terms)
        for row in 0..<Uk.rows {
            for column in 0..<terms {
                Uk[row, column] = U[row, column]
            }
        }
        var Vk = Matrix<Complex<Double>>.zeros(rows: terms, columns: VH.columns)
        for row in 0..<terms {
            for column in 0..<Vk.columns {
                Vk[row, column] = VH[row, column]
            }
        }
        Uk = Uk.conjugateTranspose
        Vk = Vk.conjugateTranspose

        // The eigenvalues of Σ⁻¹ Uᴴ Y₁ V are the common discrete-time
        // poles zᵢ = exp(-Wᵢ dt).
        let projectedShift = Uk.dot(Y1).dot(Vk)
        let reducedPencil = Matrix<Complex<Double>>(
            rows: terms,
            columns: terms
        ) { buffer in
            for row in 0..<terms {
                for column in 0..<terms {
                    buffer[row * terms + column] =
                        projectedShift[row, column] / singularValues[row]
                }
            }
        }

        let discretePoles = try! MatrixOperations.eigenValues(reducedPencil)
        let W = discretePoles.map { -Complex.log($0) / dt }

        // Once the common poles are known, solve all output amplitudes in one
        // multiple-right-hand-side least-squares problem.
        let vandermonde = Matrix<Complex<Double>>(
            rows: sampleCount,
            columns: terms
        ) { buffer in
            for sample in 0..<sampleCount {
                for term in 0..<terms {
                    buffer[sample * terms + term] =
                        .exp(-Double(sample) * dt * W[term])
                }
            }
        }
        let (G, _) = try! Optimize.linearLeastSquares(A: vandermonde, y)
        return (G, W)
    }

    @inline(__always)
    private static func numericalRank(_ singularValues: [Double]) -> Int {
        guard let largest = singularValues.first, largest > 0 else { return 0 }
        let tolerance = largest * 1e-12
        return singularValues.prefix { $0 > tolerance }.count
    }

    /// Computes only the first `min(m, n)` singular vectors on each side.
    private static func thinSingularValueDecomposition(
        _ A: Matrix<Complex<Double>>
    ) throws -> (
        U: Matrix<Complex<Double>>,
        singularValues: [Double],
        VH: Matrix<Complex<Double>>
    ) {
        let m = A.rows
        let n = A.columns
        let rank = min(m, n)
        var a = A.elements
        var U = Matrix<Complex<Double>>.zeros(rows: m, columns: rank)
        var VH = Matrix<Complex<Double>>.zeros(rows: rank, columns: n)
        var singularValues = [Double](repeating: 0, count: rank)
        var superb = [Double](repeating: 0, count: max(1, rank - 1))
        let info = LAPACK.zgesvd(
            layout: .rowMajor,
            jobU: .some,
            jobVT: .some,
            m: m,
            n: n,
            a: &a,
            lda: n,
            s: &singularValues,
            u: &U.elements,
            ldu: rank,
            vt: &VH.elements,
            ldvt: n,
            superb: &superb
        )
        if info != 0 {
            throw MatrixOperations.MatrixOperationError.info(info)
        }
        return (U, singularValues, VH)
    }
}
