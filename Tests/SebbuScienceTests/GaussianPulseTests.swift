// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import Testing
@testable import SebbuScience

struct GaussianPulseTests {
    private let tolerance = 2e-14

    @Test("Area and standard deviation define the canonical pulse")
    func canonicalInitializer() {
        let pulse = GaussianPulse(
            area: 7.5,
            standardDeviation: 1.25,
            centerTime: -2
        )

        #expect(pulse.area == 7.5)
        #expect(pulse.standardDeviation == 1.25)
        #expect(pulse.centerTime == -2)
        #expect(pulse.variance == 1.5625)
        #expect(
            abs(
                pulse.peakAmplitude
                    - 7.5 / (1.25 * (2 * Double.pi).squareRoot())
            ) < tolerance
        )
    }

    @Test("The center time defaults to zero")
    func defaultCenterTime() {
        let fromArea = GaussianPulse(area: 1, standardDeviation: 2)
        let fromPeak = GaussianPulse(
            peakAmplitude: 3,
            fullWidthAtHalfMaximum: 4
        )

        #expect(fromArea.centerTime == 0)
        #expect(fromPeak.centerTime == 0)
    }

    @Test("Evaluation has the requested peak, symmetry, and Gaussian decay")
    func evaluation() {
        let pulse = GaussianPulse(
            peakAmplitude: -3.5,
            standardDeviation: 1.2,
            centerTime: 0.7
        )

        #expect(pulse(pulse.centerTime) == pulse.peakAmplitude)
        #expect(abs(pulse.peakAmplitude + 3.5) < tolerance)

        for displacement in [0.1, 0.5, 1.0, 2.5, 6.0] {
            let left = pulse(pulse.centerTime - displacement)
            let right = pulse(pulse.centerTime + displacement)
            #expect(abs(left - right) < tolerance)
        }

        let atOneSigma = pulse(pulse.centerTime + pulse.standardDeviation)
        #expect(
            abs(atOneSigma - pulse.peakAmplitude * Double.exp(-0.5))
                < tolerance
        )
    }

    @Test("Peak amplitude and standard deviation recover the requested area")
    func peakAndStandardDeviationInitializer() {
        let peak = 2.75
        let standardDeviation = 0.8
        let pulse = GaussianPulse(
            peakAmplitude: peak,
            standardDeviation: standardDeviation,
            centerTime: 4
        )
        let expectedArea = peak
            * standardDeviation
            * (2 * Double.pi).squareRoot()

        #expect(abs(pulse.peakAmplitude - peak) < tolerance)
        #expect(abs(pulse.area - expectedArea) < tolerance)
        #expect(pulse.standardDeviation == standardDeviation)
        #expect(pulse.centerTime == 4)
    }

    @Test("Amplitude FWHM is measured at half the central amplitude")
    func amplitudeFWHM() {
        let pulse = GaussianPulse(
            peakAmplitude: 3,
            fullWidthAtHalfMaximum: 2.4,
            centerTime: -0.4
        )
        let halfWidth = pulse.fullWidthAtHalfMaximum / 2

        #expect(abs(pulse.fullWidthAtHalfMaximum - 2.4) < tolerance)
        #expect(
            abs(pulse(pulse.centerTime - halfWidth) - 1.5) < tolerance
        )
        #expect(
            abs(pulse(pulse.centerTime + halfWidth) - 1.5) < tolerance
        )
    }

    @Test("Intensity FWHM is measured at half the squared central amplitude")
    func intensityFWHM() {
        let pulse = GaussianPulse(
            peakAmplitude: -4,
            intensityFullWidthAtHalfMaximum: 1.7,
            centerTime: 2.3
        )
        let halfWidth = pulse.intensityFullWidthAtHalfMaximum / 2
        let centralSquaredAmplitude = pulse.peakAmplitude * pulse.peakAmplitude

        #expect(
            abs(pulse.intensityFullWidthAtHalfMaximum - 1.7) < tolerance
        )
        for time in [
            pulse.centerTime - halfWidth,
            pulse.centerTime + halfWidth,
        ] {
            let amplitude = pulse(time)
            #expect(
                abs(
                    amplitude * amplitude
                        - centralSquaredAmplitude / 2
                ) < tolerance
            )
        }
    }

    @Test("Amplitude and intensity FWHM use distinct conventions")
    func fwhmConventions() {
        let pulse = GaussianPulse(area: 2, standardDeviation: 0.75)

        #expect(
            abs(
                pulse.fullWidthAtHalfMaximum
                    / pulse.intensityFullWidthAtHalfMaximum
                    - Double(2).squareRoot()
            ) < tolerance
        )
    }

    @Test("Every width initializer produces the same canonical pulse")
    func widthInitializerEquivalence() {
        let reference = GaussianPulse(
            peakAmplitude: 1.3,
            standardDeviation: 0.6,
            centerTime: 1.1
        )
        let pulses = [
            GaussianPulse(
                area: reference.area,
                fullWidthAtHalfMaximum:
                    reference.fullWidthAtHalfMaximum,
                centerTime: reference.centerTime
            ),
            GaussianPulse(
                peakAmplitude: reference.peakAmplitude,
                fullWidthAtHalfMaximum:
                    reference.fullWidthAtHalfMaximum,
                centerTime: reference.centerTime
            ),
            GaussianPulse(
                area: reference.area,
                intensityFullWidthAtHalfMaximum:
                    reference.intensityFullWidthAtHalfMaximum,
                centerTime: reference.centerTime
            ),
            GaussianPulse(
                peakAmplitude: reference.peakAmplitude,
                intensityFullWidthAtHalfMaximum:
                    reference.intensityFullWidthAtHalfMaximum,
                centerTime: reference.centerTime
            ),
        ]

        for pulse in pulses {
            #expect(abs(pulse.area - reference.area) < tolerance)
            #expect(
                abs(pulse.standardDeviation - reference.standardDeviation)
                    < tolerance
            )
            #expect(pulse.centerTime == reference.centerTime)

            for time in [-1.0, 0.5, 1.1, 1.8, 4.0] {
                #expect(abs(pulse(time) - reference(time)) < tolerance)
            }
        }
    }

    @Test("Numerical integration recovers the signed pulse area")
    func numericalArea() {
        let pulse = GaussianPulse(
            area: -5.25,
            standardDeviation: 0.7,
            centerTime: 3.2
        )
        let radius = 12 * pulse.standardDeviation
        let result = GaussKronrod21.integrate(
            a: pulse.centerTime - radius,
            b: pulse.centerTime + radius,
            absoluteTolerance: 1e-13,
            relativeTolerance: 1e-13,
            f: pulse.callAsFunction
        )

        #expect(result.converged)
        #expect(abs(result.value - pulse.area) < 2e-13)
    }

    @Test("Numerical integration recovers integrated squared amplitude")
    func numericalIntegratedSquaredAmplitude() {
        let pulse = GaussianPulse(
            peakAmplitude: 2.4,
            standardDeviation: 1.1,
            centerTime: -4.5
        )
        let radius = 12 * pulse.standardDeviation
        let result = GaussKronrod21.integrate(
            a: pulse.centerTime - radius,
            b: pulse.centerTime + radius,
            absoluteTolerance: 1e-13,
            relativeTolerance: 1e-13
        ) { time in
            let amplitude = pulse(time)
            return amplitude * amplitude
        }

        #expect(result.converged)
        #expect(
            abs(result.value - pulse.integratedSquaredAmplitude) < 2e-13
        )
    }

    @Test("A zero-area pulse evaluates to zero")
    func zeroArea() {
        let pulse = GaussianPulse(
            area: 0,
            fullWidthAtHalfMaximum: 2,
            centerTime: 1
        )

        #expect(pulse.peakAmplitude == 0)
        #expect(pulse.integratedSquaredAmplitude == 0)
        #expect(pulse(-100) == 0)
        #expect(pulse(1) == 0)
        #expect(pulse(100) == 0)
    }

    @Test("GaussianPulse is Sendable")
    func sendableConformance() {
        func requireSendable<T: Sendable>(_: T) {}

        requireSendable(
            GaussianPulse(area: 1, standardDeviation: 1)
        )
    }
}
