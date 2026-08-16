// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

/// Step metadata returned by an SDE solver.
public typealias SDEStep = IntegrationStep

/// Mutable storage operations required by allocation-free fixed-step SDE
/// solvers.
///
/// The deterministic operations are shared with ``FixedStepODESolverState``.
/// `NoiseType` is the scalar (for example, `Double` or `Complex<Double>`) used
/// to weight a diffusion vector by one normalized noise sample.
public protocol FixedStepSDESolverState: ~Copyable, FixedStepODESolverState {
    associatedtype NoiseType

    /// Replaces this value with the additive zero without changing storage.
    mutating func zero()

    /// Accumulates `other * noise` in one pass over the existing storage.
    mutating func add(
        _ other: borrowing Self,
        scaledBy noise: borrowing NoiseType
    )
}

public protocol SDERHSFunction: ~Copyable, ~Escapable {
    associatedtype State: ~Copyable, FixedStepSDESolverState

    /// Replaces `dy` with the Stratonovich drift at `(t, y)`.
    ///
    /// Implementations must overwrite every relevant component of `dy`; the
    /// solver reuses buffers containing values from earlier stages.
    mutating func drift(
        t: Double,
        y: borrowing State,
        into dy: inout State
    )

    /// Replaces `dy` with one diffusion vector at `(t, y)`.
    ///
    /// `channel` is an index into the noise span owned by the solver.
    /// Implementations must overwrite every relevant component of `dy`.
    mutating func diffusion(
        t: Double,
        y: borrowing State,
        channel: Int,
        into dy: inout State
    )

    /// Fills the span with dimensionless normalized noise values for one step.
    ///
    /// The solver interprets each value as `xi_i` in
    /// `Delta W_i = sqrt(stepSize) * xi_i`. For independent unit real or
    /// complex Wiener channels, the corresponding conjugated covariance is
    /// `E[xi_i * xi_j^*] = delta_ij`. The diffusion vectors should contain any
    /// physical channel strengths. The explicit `stepSize` permits keyed,
    /// replayable, or nonuniform-step generators; it must not be included in
    /// the sampled amplitude a second time.
    mutating func sampleNormalizedNoises(
        t: Double,
        stepSize: Double,
        into noises: inout MutableSpan<State.NoiseType>
    )
}
