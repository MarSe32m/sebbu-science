// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

/// Numerical Karhunen-Loève decompositions.
public enum KarhunenLoeve {
    /// Errors detected while constructing a discretized KL basis.
    public enum DecompositionError: Error, Equatable, Sendable {
        case emptyTimeGrid
        case trapezoidalRuleRequiresAtLeastTwoTimePoints
        case quadratureWeightCountMismatch(expected: Int, actual: Int)
        case invalidChannelCount(Int)
        case nonFiniteTime(index: Int)
        case timeGridNotStrictlyIncreasing(index: Int)
        case invalidQuadratureWeight(index: Int)
        case invalidMaximumModeCount(Int)
        case invalidMinimumEigenvalue
        case invalidRelativeEigenvalueTolerance
        case invalidNegativeEigenvalueTolerance
        case dimensionOverflow
        case nonFiniteCorrelation(
            timeRow: Int,
            timeColumn: Int,
            rowChannel: Int,
            columnChannel: Int
        )
        case correlationMatrixDimensionMismatch(
            expected: Int,
            actualRows: Int,
            actualColumns: Int
        )
        case correlationMatrixNotPositiveSemidefinite(
            minimumEigenvalue: Double,
            tolerance: Double
        )
    }

    /// A vector-valued KL basis sampled on a quadrature grid.
    ///
    /// `eigenFunctions` has `timeCount * channelCount` rows and `modeCount`
    /// columns. The row corresponding to `(timeIndex, channel)` is
    /// `timeIndex * channelCount + channel`.
    public struct CorrelatedBasis: ~Copyable {
        /// Quadrature nodes used to construct the basis.
        public let times: [Double]

        /// Positive quadrature weights used to construct the basis.
        public let quadratureWeights: [Double]

        /// Number of components of the vector-valued stochastic process.
        public let channelCount: Int

        /// Retained eigenvalues, ordered from largest to smallest.
        public let eigenValues: [Double]

        /// Sampled eigenfunctions. Columns correspond to KL modes.
        public let eigenFunctions: UniqueMatrix<Complex<Double>>

        /// Sum of all nonnegative eigenvalues before mode truncation.
        public let totalVariance: Double

        init(
            times: [Double],
            quadratureWeights: [Double],
            channelCount: Int,
            eigenValues: [Double],
            eigenFunctions: consuming UniqueMatrix<Complex<Double>>,
            totalVariance: Double
        ) {
            self.times = times
            self.quadratureWeights = quadratureWeights
            self.channelCount = channelCount
            self.eigenValues = eigenValues
            self.eigenFunctions = eigenFunctions
            self.totalVariance = totalVariance
        }

        /// Number of time nodes in the basis.
        @inlinable
        public var timeCount: Int { times.count }

        /// Number of retained KL modes.
        @inlinable
        public var modeCount: Int { eigenValues.count }

        /// Sum of the retained eigenvalues.
        @inlinable
        public var retainedVariance: Double {
            eigenValues.reduce(.zero, +)
        }

        /// Fraction of the total integrated variance represented by the
        /// retained modes.
        @inlinable
        public var capturedVarianceFraction: Double {
            if totalVariance == .zero { return 1 }
            return retainedVariance / totalVariance
        }

        /// Returns the sampled value of one vector-valued KL eigenfunction.
        @inlinable
        public subscript(
            time timeIndex: Int,
            channel channel: Int,
            mode mode: Int
        ) -> Complex<Double> {
            precondition(timeIndex >= 0 && timeIndex < timeCount)
            precondition(channel >= 0 && channel < channelCount)
            precondition(mode >= 0 && mode < modeCount)
            return eigenFunctions[timeIndex * channelCount + channel, mode]
        }

        /// Reconstructs one element of the retained covariance kernel.
        ///
        /// The result is
        /// `sum_k eigenValues[k] * u_k(t, i) * u_k(s, j).conjugate`.
        @inlinable
        public func reconstructedCorrelation(
            timeRow: Int,
            rowChannel: Int,
            timeColumn: Int,
            columnChannel: Int
        ) -> Complex<Double> {
            var result = Complex<Double>.zero
            for mode in 0..<modeCount {
                let rowValue = self[
                    time: timeRow,
                    channel: rowChannel,
                    mode: mode
                ].multiplied(by: eigenValues[mode])
                let columnValue = self[
                    time: timeColumn,
                    channel: columnChannel,
                    mode: mode
                ]
                result += rowValue * columnValue.conjugate
            }
            return result
        }
    }

    /// Constructs a vector-valued KL basis using a weighted Nyström method.
    ///
    /// The callback receives a nonnegative lag and an `channelCount` by
    /// `channelCount` scratch matrix. It must overwrite the complete scratch
    /// matrix with `alpha_ij(lag)`. The negative-lag half of the covariance
    /// kernel is generated using
    /// `alpha_ij(-lag) = alpha_ji(lag).conjugate`.
    ///
    /// The discretized Hermitian eigenproblem is
    ///
    /// ```
    /// B[(a, i), (b, j)] = sqrt(w[a] * w[b]) * alpha_ij(t[a] - t[b]).
    /// ```
    ///
    /// Eigenvalues below the larger of `minimumEigenvalue` and
    /// `relativeEigenvalueTolerance * largestEigenvalue` are discarded.
    /// Numerical negative eigenvalues are accepted up to an automatically
    /// scaled roundoff threshold unless `negativeEigenvalueTolerance` is
    /// supplied explicitly.
    public static func correlatedBasis(
        times: [Double],
        quadratureWeights: [Double],
        channelCount: Int,
        maximumModeCount: Int? = nil,
        minimumEigenvalue: Double = 0,
        relativeEigenvalueTolerance: Double = 0,
        negativeEigenvalueTolerance: Double? = nil,
        correlation: (
            _ nonnegativeLag: Double,
            _ values: inout UniqueMatrix<Complex<Double>>
        ) -> Void
    ) throws -> CorrelatedBasis {
        try validateTimes(times)

        guard quadratureWeights.count == times.count else {
            throw DecompositionError.quadratureWeightCountMismatch(
                expected: times.count,
                actual: quadratureWeights.count
            )
        }
        guard channelCount > 0 else {
            throw DecompositionError.invalidChannelCount(channelCount)
        }
        for index in quadratureWeights.indices {
            let weight = quadratureWeights[index]
            guard weight.isFinite && weight > 0 else {
                throw DecompositionError.invalidQuadratureWeight(index: index)
            }
        }
        if let maximumModeCount, maximumModeCount < 0 {
            throw DecompositionError.invalidMaximumModeCount(maximumModeCount)
        }
        guard minimumEigenvalue.isFinite && minimumEigenvalue >= 0 else {
            throw DecompositionError.invalidMinimumEigenvalue
        }
        guard relativeEigenvalueTolerance.isFinite
                && relativeEigenvalueTolerance >= 0 else {
            throw DecompositionError.invalidRelativeEigenvalueTolerance
        }
        if let negativeEigenvalueTolerance {
            guard negativeEigenvalueTolerance.isFinite
                    && negativeEigenvalueTolerance >= 0 else {
                throw DecompositionError.invalidNegativeEigenvalueTolerance
            }
        }

        let (dimension, overflow) = times.count.multipliedReportingOverflow(
            by: channelCount
        )
        guard !overflow else { throw DecompositionError.dimensionOverflow }
        let (_, squareOverflow) = dimension.multipliedReportingOverflow(
            by: dimension
        )
        guard !squareOverflow else {
            throw DecompositionError.dimensionOverflow
        }

        let squareRootWeights = quadratureWeights.map { $0.squareRoot() }
        var covariance = UniqueMatrix<Complex<Double>>(
            rows: dimension,
            columns: dimension
        ) { buffer in
            for index in buffer.indices {
                buffer.initializeElement(at: index, to: .zero)
            }
        }
        var correlationAtLag = UniqueMatrix<Complex<Double>>.zeros(
            rows: channelCount,
            columns: channelCount
        )

        func coordinate(time: Int, channel: Int) -> Int {
            time * channelCount + channel
        }

        func scaled(
            _ value: Complex<Double>,
            by scale: Double
        ) -> Complex<Double> {
            Complex(value.real * scale, value.imaginary * scale)
        }

        for timeRow in times.indices {
            for timeColumn in 0...timeRow {
                let lag = times[timeRow] - times[timeColumn]
                correlationAtLag.zeroElements()
                correlation(lag, &correlationAtLag)

                guard correlationAtLag.rows == channelCount
                        && correlationAtLag.columns == channelCount else {
                    throw DecompositionError.correlationMatrixDimensionMismatch(
                        expected: channelCount,
                        actualRows: correlationAtLag.rows,
                        actualColumns: correlationAtLag.columns
                    )
                }

                for rowChannel in 0..<channelCount {
                    for columnChannel in 0..<channelCount {
                        let value = correlationAtLag[rowChannel, columnChannel]
                        guard value.real.isFinite && value.imaginary.isFinite else {
                            throw DecompositionError.nonFiniteCorrelation(
                                timeRow: timeRow,
                                timeColumn: timeColumn,
                                rowChannel: rowChannel,
                                columnChannel: columnChannel
                            )
                        }
                    }
                }

                let weight = squareRootWeights[timeRow]
                    * squareRootWeights[timeColumn]

                if timeRow == timeColumn {
                    // alpha(0) must be Hermitian. Averaging the two supplied
                    // triangles removes harmless fitting roundoff while still
                    // producing an exactly Hermitian Nyström matrix.
                    for rowChannel in 0..<channelCount {
                        for columnChannel in 0...rowChannel {
                            let value: Complex<Double>
                            if rowChannel == columnChannel {
                                value = Complex(
                                    correlationAtLag[rowChannel, rowChannel].real
                                )
                            } else {
                                let lower = correlationAtLag[
                                    rowChannel,
                                    columnChannel
                                ]
                                let upper = correlationAtLag[
                                    columnChannel,
                                    rowChannel
                                ].conjugate
                                value = Complex(
                                    0.5 * (lower.real + upper.real),
                                    0.5 * (lower.imaginary + upper.imaginary)
                                )
                            }

                            let row = coordinate(
                                time: timeRow,
                                channel: rowChannel
                            )
                            let column = coordinate(
                                time: timeColumn,
                                channel: columnChannel
                            )
                            let weighted = scaled(value, by: weight)
                            covariance[row, column] = weighted
                            covariance[column, row] = weighted.conjugate
                        }
                    }
                } else {
                    for rowChannel in 0..<channelCount {
                        for columnChannel in 0..<channelCount {
                            let row = coordinate(
                                time: timeRow,
                                channel: rowChannel
                            )
                            let column = coordinate(
                                time: timeColumn,
                                channel: columnChannel
                            )
                            let weighted = scaled(
                                correlationAtLag[rowChannel, columnChannel],
                                by: weight
                            )
                            covariance[row, column] = weighted
                            covariance[column, row] = weighted.conjugate
                        }
                    }
                }
            }
        }

        // LAPACK overwrites covariance with column eigenvectors and returns
        // eigenvalues in ascending order.
        let ascendingEigenValues = try MatrixOperations
            .diagonalizeHermitianInPlace(&covariance)

        let spectralScale = ascendingEigenValues.reduce(0.0) {
            Swift.max($0, Swift.abs($1))
        }
        let automaticNegativeTolerance = 64
            * Double.ulpOfOne
            * Double(dimension)
            * spectralScale
        let allowedNegativeEigenvalue = negativeEigenvalueTolerance
            ?? automaticNegativeTolerance
        let smallestEigenvalue = ascendingEigenValues[0]
        guard smallestEigenvalue >= -allowedNegativeEigenvalue else {
            throw DecompositionError.correlationMatrixNotPositiveSemidefinite(
                minimumEigenvalue: smallestEigenvalue,
                tolerance: allowedNegativeEigenvalue
            )
        }

        let largestEigenvalue = Swift.max(ascendingEigenValues[dimension - 1], 0)
        let retentionThreshold = Swift.max(
            minimumEigenvalue,
            relativeEigenvalueTolerance * largestEigenvalue
        )
        let requestedModeCount = Swift.min(
            maximumModeCount ?? dimension,
            dimension
        )

        var sourceColumns: [Int] = []
        sourceColumns.reserveCapacity(requestedModeCount)
        if requestedModeCount > 0 {
            for sourceColumn in stride(
                from: dimension - 1,
                through: 0,
                by: -1
            ) {
                if ascendingEigenValues[sourceColumn] > retentionThreshold {
                    sourceColumns.append(sourceColumn)
                    if sourceColumns.count == requestedModeCount { break }
                }
            }
        }

        let retainedEigenValues = sourceColumns.map {
            ascendingEigenValues[$0]
        }
        let totalVariance = ascendingEigenValues.reduce(0.0) {
            $0 + Swift.max($1, 0)
        }

        // Divide the Euclidean eigenvectors by sqrt(w[a]) to recover the
        // sampled eigenfunctions normalized in the quadrature inner product.
        let modeCount = sourceColumns.count
        let eigenFunctions = UniqueMatrix<Complex<Double>>(
            rows: dimension,
            columns: modeCount
        ) { buffer in
            for coordinate in 0..<dimension {
                let timeIndex = coordinate / channelCount
                let inverseSquareRootWeight = 1 / squareRootWeights[timeIndex]
                for mode in 0..<modeCount {
                    let value = covariance[coordinate, sourceColumns[mode]]
                    buffer.initializeElement(
                        at: coordinate * modeCount + mode,
                        to: scaled(value, by: inverseSquareRootWeight)
                    )
                }
            }
        }

        return CorrelatedBasis(
            times: times,
            quadratureWeights: quadratureWeights,
            channelCount: channelCount,
            eigenValues: retainedEigenValues,
            eigenFunctions: eigenFunctions,
            totalVariance: totalVariance
        )
    }

    /// Constructs a correlated KL basis using composite trapezoidal weights.
    public static func correlatedBasis(
        times: [Double],
        channelCount: Int,
        maximumModeCount: Int? = nil,
        minimumEigenvalue: Double = 0,
        relativeEigenvalueTolerance: Double = 0,
        negativeEigenvalueTolerance: Double? = nil,
        correlation: (
            _ nonnegativeLag: Double,
            _ values: inout UniqueMatrix<Complex<Double>>
        ) -> Void
    ) throws -> CorrelatedBasis {
        let weights = try trapezoidalWeights(for: times)
        return try correlatedBasis(
            times: times,
            quadratureWeights: weights,
            channelCount: channelCount,
            maximumModeCount: maximumModeCount,
            minimumEigenvalue: minimumEigenvalue,
            relativeEigenvalueTolerance: relativeEigenvalueTolerance,
            negativeEigenvalueTolerance: negativeEigenvalueTolerance,
            correlation: correlation
        )
    }

    /// Composite trapezoidal quadrature weights for a nonuniform grid.
    public static func trapezoidalWeights(
        for times: [Double]
    ) throws -> [Double] {
        try validateTimes(times)
        guard times.count >= 2 else {
            throw DecompositionError
                .trapezoidalRuleRequiresAtLeastTwoTimePoints
        }

        var weights = [Double](repeating: .zero, count: times.count)
        weights[0] = 0.5 * (times[1] - times[0])
        for index in 1..<(times.count - 1) {
            weights[index] = 0.5 * (times[index + 1] - times[index - 1])
        }
        weights[times.count - 1] = 0.5
            * (times[times.count - 1] - times[times.count - 2])
        return weights
    }

    private static func validateTimes(_ times: [Double]) throws {
        guard !times.isEmpty else { throw DecompositionError.emptyTimeGrid }
        for index in times.indices {
            guard times[index].isFinite else {
                throw DecompositionError.nonFiniteTime(index: index)
            }
            if index > 0 && times[index] <= times[index - 1] {
                throw DecompositionError
                    .timeGridNotStrictlyIncreasing(index: index)
            }
        }
    }
}
