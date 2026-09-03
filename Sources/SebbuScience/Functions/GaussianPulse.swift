// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

/// A real Gaussian pulse envelope.
///
/// The pulse is represented canonically by its signed area `area`, center
/// time `centerTime`, and positive standard deviation `standardDeviation`:
///
/// ```
/// eta(t) = area / (sqrt(2 * pi) * standardDeviation)
///          * exp(-0.5 * ((t - centerTime) / standardDeviation)^2)
/// ```
///
/// Consequently, `area` is the integral of the amplitude envelope, not the
/// integral of its square. In laser terminology, the latter is proportional
/// to fluence and is available as `integratedSquaredAmplitude`.
///
/// `fullWidthAtHalfMaximum` is the FWHM of the amplitude returned by
/// ``callAsFunction(_:)``. The generally narrower FWHM of the squared
/// amplitude is available as `intensityFullWidthAtHalfMaximum`.
///
/// All time quantities must use the same unit. The pulse does not include a
/// carrier frequency or phase; it represents only a real envelope.
public struct GaussianPulse: Sendable, Equatable {
    /// The signed integral of the amplitude envelope over all time.
    ///
    /// Its unit is the amplitude unit multiplied by the time unit.
    public let area: Double

    /// The time at which the pulse reaches its central amplitude.
    public let centerTime: Double

    /// The standard deviation of the amplitude envelope.
    public let standardDeviation: Double

    /// Creates a pulse from its area and standard deviation.
    ///
    /// - Parameters:
    ///   - area: The signed integral of the amplitude envelope over all time.
    ///   - standardDeviation: The positive temporal standard deviation of the
    ///     amplitude envelope.
    ///   - centerTime: The center of the pulse. The default is zero.
    @inlinable
    public init(
        area: Double,
        standardDeviation: Double,
        centerTime: Double = .zero
    ) {
        precondition(area.isFinite, "Pulse area must be finite")
        precondition(
            standardDeviation.isFinite && standardDeviation > .zero,
            "Standard deviation must be positive and finite"
        )
        precondition(centerTime.isFinite, "Center time must be finite")

        self.area = area
        self.centerTime = centerTime
        self.standardDeviation = standardDeviation
    }

    /// Creates a pulse from its central (peak) amplitude and standard
    /// deviation.
    ///
    /// The supplied amplitude is `self(centerTime)`. It may be negative to
    /// represent a signed drive envelope.
    ///
    /// - Parameters:
    ///   - peakAmplitude: The amplitude at `centerTime`.
    ///   - standardDeviation: The positive temporal standard deviation of the
    ///     amplitude envelope.
    ///   - centerTime: The center of the pulse. The default is zero.
    @inlinable
    public init(
        peakAmplitude: Double,
        standardDeviation: Double,
        centerTime: Double = .zero
    ) {
        precondition(peakAmplitude.isFinite, "Peak amplitude must be finite")
        precondition(
            standardDeviation.isFinite && standardDeviation > .zero,
            "Standard deviation must be positive and finite"
        )

        self.init(
            area: peakAmplitude
                * standardDeviation
                * (2 * Double.pi).squareRoot(),
            standardDeviation: standardDeviation,
            centerTime: centerTime
        )
    }

    /// Creates a pulse from its area and amplitude FWHM.
    ///
    /// `fullWidthAtHalfMaximum` is the width between the two times at which
    /// the amplitude equals one half of its value at `centerTime`.
    ///
    /// - Parameters:
    ///   - area: The signed integral of the amplitude envelope over all time.
    ///   - fullWidthAtHalfMaximum: The positive FWHM of the amplitude
    ///     envelope.
    ///   - centerTime: The center of the pulse. The default is zero.
    @inlinable
    public init(
        area: Double,
        fullWidthAtHalfMaximum: Double,
        centerTime: Double = .zero
    ) {
        precondition(
            fullWidthAtHalfMaximum.isFinite
                && fullWidthAtHalfMaximum > .zero,
            "Full width at half maximum must be positive and finite"
        )

        self.init(
            area: area,
            standardDeviation: fullWidthAtHalfMaximum
                / (2 * (2 * Double.log(2)).squareRoot()),
            centerTime: centerTime
        )
    }

    /// Creates a pulse from its central (peak) amplitude and amplitude FWHM.
    ///
    /// This overload is appropriate when a source reports the FWHM of the
    /// drive or field-amplitude envelope itself. If it instead reports the
    /// customary laser intensity FWHM, use
    /// ``init(peakAmplitude:intensityFullWidthAtHalfMaximum:centerTime:)``.
    ///
    /// - Parameters:
    ///   - peakAmplitude: The amplitude at `centerTime`.
    ///   - fullWidthAtHalfMaximum: The positive FWHM of the amplitude
    ///     envelope.
    ///   - centerTime: The center of the pulse. The default is zero.
    @inlinable
    public init(
        peakAmplitude: Double,
        fullWidthAtHalfMaximum: Double,
        centerTime: Double = .zero
    ) {
        precondition(
            fullWidthAtHalfMaximum.isFinite
                && fullWidthAtHalfMaximum > .zero,
            "Full width at half maximum must be positive and finite"
        )

        self.init(
            peakAmplitude: peakAmplitude,
            standardDeviation: fullWidthAtHalfMaximum
                / (2 * (2 * Double.log(2)).squareRoot()),
            centerTime: centerTime
        )
    }

    /// Creates a pulse from its area and squared-amplitude (intensity) FWHM.
    ///
    /// `intensityFullWidthAtHalfMaximum` is the width between the two times
    /// at which the squared amplitude equals one half of its central value.
    /// This is the convention most commonly used for experimental laser
    /// pulse durations.
    ///
    /// - Parameters:
    ///   - area: The signed integral of the amplitude envelope over all time.
    ///   - intensityFullWidthAtHalfMaximum: The positive FWHM of the squared
    ///     amplitude.
    ///   - centerTime: The center of the pulse. The default is zero.
    @inlinable
    public init(
        area: Double,
        intensityFullWidthAtHalfMaximum: Double,
        centerTime: Double = .zero
    ) {
        precondition(
            intensityFullWidthAtHalfMaximum.isFinite
                && intensityFullWidthAtHalfMaximum > .zero,
            "Intensity full width at half maximum must be positive and finite"
        )

        self.init(
            area: area,
            standardDeviation: intensityFullWidthAtHalfMaximum
                / (2 * Double.log(2).squareRoot()),
            centerTime: centerTime
        )
    }

    /// Creates a pulse from its central (peak) amplitude and
    /// squared-amplitude (intensity) FWHM.
    ///
    /// This overload is appropriate when an experimental source reports a
    /// laser pulse duration as an intensity FWHM.
    ///
    /// - Parameters:
    ///   - peakAmplitude: The amplitude at `centerTime`, rather than the
    ///     squared amplitude at the center.
    ///   - intensityFullWidthAtHalfMaximum: The positive FWHM of the squared
    ///     amplitude.
    ///   - centerTime: The center of the pulse. The default is zero.
    @inlinable
    public init(
        peakAmplitude: Double,
        intensityFullWidthAtHalfMaximum: Double,
        centerTime: Double = .zero
    ) {
        precondition(
            intensityFullWidthAtHalfMaximum.isFinite
                && intensityFullWidthAtHalfMaximum > .zero,
            "Intensity full width at half maximum must be positive and finite"
        )

        self.init(
            peakAmplitude: peakAmplitude,
            standardDeviation: intensityFullWidthAtHalfMaximum
                / (2 * Double.log(2).squareRoot()),
            centerTime: centerTime
        )
    }

    /// The variance of the amplitude envelope.
    @inlinable
    public var variance: Double {
        standardDeviation * standardDeviation
    }

    /// The signed amplitude at `centerTime`.
    @inlinable
    public var peakAmplitude: Double {
        area / (standardDeviation * (2 * Double.pi).squareRoot())
    }

    /// The FWHM of the amplitude envelope.
    ///
    /// At `centerTime +/- fullWidthAtHalfMaximum / 2`, the pulse amplitude is
    /// one half of `peakAmplitude`.
    @inlinable
    public var fullWidthAtHalfMaximum: Double {
        standardDeviation * 2 * (2 * Double.log(2)).squareRoot()
    }

    /// The FWHM of the squared-amplitude envelope.
    ///
    /// At `centerTime +/- intensityFullWidthAtHalfMaximum / 2`, the square of
    /// the pulse amplitude is one half of its value at `centerTime`.
    @inlinable
    public var intensityFullWidthAtHalfMaximum: Double {
        standardDeviation * 2 * Double.log(2).squareRoot()
    }

    /// The integral of the squared amplitude over all time.
    ///
    /// For a field or Rabi-frequency envelope this quantity is proportional
    /// to, but is not by itself, the physical laser fluence.
    @inlinable
    public var integratedSquaredAmplitude: Double {
        area * area / (2 * Double.pi.squareRoot() * standardDeviation)
    }

    /// Evaluates the Gaussian amplitude envelope at `time`.
    @inlinable
    public func callAsFunction(_ time: Double) -> Double {
        let displacement = (time - centerTime) / standardDeviation
        return peakAmplitude * Double.exp(-0.5 * displacement * displacement)
    }
}
