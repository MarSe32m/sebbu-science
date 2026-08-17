// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Testing
@testable import SebbuScience

@Suite("Correlated Karhunen-Loeve decomposition")
struct CorrelatedKarhunenLoeveTests {
    @Test("Vector-valued modes reconstruct a complex correlated kernel")
    func reconstructsCorrelatedKernel() throws {
        let times = [0.0, 0.25, 0.7, 1.0]
        let weights = try KarhunenLoeve.trapezoidalWeights(for: times)
        let basis = try KarhunenLoeve.correlatedBasis(
            times: times,
            quadratureWeights: weights,
            channelCount: 2,
            relativeEigenvalueTolerance: 1e-13
        ) { lag, alpha in
            fillCorrelation(lag: lag, into: &alpha)
        }

        #expect(basis.modeCount == times.count * 2)
        #expect(abs(basis.totalVariance - 1.8) < 1e-12)
        #expect(abs(basis.capturedVarianceFraction - 1) < 1e-12)

        for mode in 1..<basis.modeCount {
            #expect(basis.eigenValues[mode - 1] >= basis.eigenValues[mode])
            #expect(basis.eigenValues[mode] > 0)
        }

        for timeRow in times.indices {
            for timeColumn in times.indices {
                for rowChannel in 0..<2 {
                    for columnChannel in 0..<2 {
                        let expected: Complex<Double>
                        if timeRow >= timeColumn {
                            expected = correlation(
                                lag: times[timeRow] - times[timeColumn],
                                rowChannel: rowChannel,
                                columnChannel: columnChannel
                            )
                        } else {
                            expected = correlation(
                                lag: times[timeColumn] - times[timeRow],
                                rowChannel: columnChannel,
                                columnChannel: rowChannel
                            ).conjugate
                        }
                        let reconstructed = basis.reconstructedCorrelation(
                            timeRow: timeRow,
                            rowChannel: rowChannel,
                            timeColumn: timeColumn,
                            columnChannel: columnChannel
                        )
                        #expect((reconstructed - expected).magnitude < 1e-10)
                    }
                }
            }
        }

        // The recovered functions are orthonormal in the quadrature-weighted
        // L2([0,T]) tensor channel inner product.
        for leftMode in 0..<basis.modeCount {
            for rightMode in 0..<basis.modeCount {
                var innerProduct = Complex<Double>.zero
                for time in times.indices {
                    for channel in 0..<2 {
                        let left = basis[
                            time: time,
                            channel: channel,
                            mode: leftMode
                        ]
                        let right = basis[
                            time: time,
                            channel: channel,
                            mode: rightMode
                        ]
                        innerProduct += (left.conjugate * right)
                            .multiplied(by: weights[time])
                    }
                }
                let expected = leftMode == rightMode ? 1.0 : 0.0
                #expect(abs(innerProduct.real - expected) < 1e-10)
                #expect(abs(innerProduct.imaginary) < 1e-10)
            }
        }
    }

    @Test("A perfectly shared bath produces one collective KL mode")
    func sharedBathHasOneMode() throws {
        let times = [0.0, 0.3, 1.0]
        let couplings = [Complex<Double>(1), Complex<Double>(0, 1)]
        let basis = try KarhunenLoeve.correlatedBasis(
            times: times,
            channelCount: 2,
            relativeEigenvalueTolerance: 1e-10
        ) { _, alpha in
            for row in 0..<2 {
                for column in 0..<2 {
                    alpha[row, column] = couplings[row]
                        * couplings[column].conjugate
                }
            }
        }

        #expect(basis.modeCount == 1)
        #expect(abs(basis.eigenValues[0] - 2) < 1e-10)
        #expect(abs(basis.totalVariance - 2) < 1e-10)

        for timeRow in times.indices {
            for timeColumn in times.indices {
                for rowChannel in 0..<2 {
                    for columnChannel in 0..<2 {
                        let expected = couplings[rowChannel]
                            * couplings[columnChannel].conjugate
                        let reconstructed = basis.reconstructedCorrelation(
                            timeRow: timeRow,
                            rowChannel: rowChannel,
                            timeColumn: timeColumn,
                            columnChannel: columnChannel
                        )
                        #expect((reconstructed - expected).magnitude < 1e-10)
                    }
                }
            }
        }
    }

    @Test("Mode count truncation retains the leading modes")
    func truncatesToLeadingModes() throws {
        let times = [0.0, 0.2, 0.5, 1.0]
        let basis = try KarhunenLoeve.correlatedBasis(
            times: times,
            channelCount: 2,
            maximumModeCount: 2
        ) { lag, alpha in
            fillCorrelation(lag: lag, into: &alpha)
        }

        #expect(basis.modeCount == 2)
        #expect(basis.eigenValues[0] >= basis.eigenValues[1])
        #expect(basis.retainedVariance > 0)
        #expect(basis.capturedVarianceFraction > 0)
        #expect(basis.capturedVarianceFraction < 1)
    }

    @Test("Trapezoidal weights support nonuniform grids")
    func nonuniformTrapezoidalWeights() throws {
        let weights = try KarhunenLoeve.trapezoidalWeights(
            for: [0, 0.25, 1]
        )
        #expect(weights.count == 3)
        #expect(abs(weights[0] - 0.125) < 1e-15)
        #expect(abs(weights[1] - 0.5) < 1e-15)
        #expect(abs(weights[2] - 0.375) < 1e-15)
        #expect(abs(weights.reduce(0, +) - 1) < 1e-15)
    }

    private func fillCorrelation(
        lag: Double,
        into alpha: inout UniqueMatrix<Complex<Double>>
    ) {
        for row in 0..<2 {
            for column in 0..<2 {
                alpha[row, column] = correlation(
                    lag: lag,
                    rowChannel: row,
                    columnChannel: column
                )
            }
        }
    }

    private func correlation(
        lag: Double,
        rowChannel: Int,
        columnChannel: Int
    ) -> Complex<Double> {
        let channelCorrelation: Complex<Double>
        switch (rowChannel, columnChannel) {
        case (0, 0):
            channelCorrelation = 1
        case (0, 1):
            channelCorrelation = Complex(0.3, 0.2)
        case (1, 0):
            channelCorrelation = Complex(0.3, -0.2)
        case (1, 1):
            channelCorrelation = Complex(0.8)
        default:
            preconditionFailure("The test correlation has two channels")
        }

        let decay: Double = .exp(-0.7 * lag)
        let phase = Complex(.cos(1.3 * lag), -.sin(1.3 * lag))
        return (channelCorrelation * phase).multiplied(by: decay)
    }
}
