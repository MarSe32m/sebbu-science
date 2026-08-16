// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// Metadata for one accepted integration step.
@frozen
public struct IntegrationStep: Sendable, Equatable {
    public let startTime: Double
    public let endTime: Double
    public let suggestedNextStepSize: Double

    /// The dimensionless embedded error norm for an adaptive step.
    ///
    /// Fixed-step methods set this to `nil`. Adaptive methods accept a step
    /// when this value is finite and no larger than one.
    public let errorNorm: Double?

    /// Number of rejected trial steps preceding this accepted step.
    public let rejectedStepCount: Int

    @inlinable
    public var stepSize: Double { endTime - startTime }

    @inlinable
    public init(
        startTime: Double,
        endTime: Double,
        suggestedNextStepSize: Double,
        errorNorm: Double? = nil,
        rejectedStepCount: Int = 0
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.suggestedNextStepSize = suggestedNextStepSize
        self.errorNorm = errorNorm
        self.rejectedStepCount = rejectedStepCount
    }
}
