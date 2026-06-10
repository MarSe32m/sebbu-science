//
//  UniqueSRK2Solver.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 18.5.2026.
//

import Numerics
import NumericsExtensions
import DequeModule

@frozen
public struct UniqueSRK2Solver<
    State: ~Copyable & FixedStepSDESolverState,
    RHS: ~Copyable & ~Escapable & SDERHSFunction
>: ~Copyable, ~Escapable
where RHS.State == State, RHS.NoiseType == State.NoiseType {

    public var t: Double
    public var dt: Double

    @usableFromInline
    internal var rhs: RHS

    @usableFromInline
    internal var drift0: State

    @usableFromInline
    internal var drift1: State

    @usableFromInline
    internal var noise0: State

    @usableFromInline
    internal var noise1: State

    @usableFromInline
    internal var temporary: State

    @usableFromInline
    internal var noises: MutableSpan<State.NoiseType>

    @_lifetime(copy rhs, copy noises)
    @inlinable
    public init(
        t: Double,
        dt: Double,
        rhs: consuming RHS,
        drift0: consuming State,
        drift1: consuming State,
        noise0: consuming State,
        noise1: consuming State,
        temporary: consuming State,
        noises: consuming MutableSpan<State.NoiseType>
    ) {
        precondition(dt > .zero, "Time-step must be positive")

        self.t = t
        self.dt = dt
        self.rhs = rhs
        self.drift0 = drift0
        self.drift1 = drift1
        self.noise0 = noise0
        self.noise1 = noise1
        self.temporary = temporary
        self.noises = noises
    }

    @inlinable
    public mutating func step(y: inout State) -> Double {
        let t0 = t
        let h = dt
        let t1 = t0 + h
        let sqrtH = h.squareRoot()

        rhs.sampleWhiteNoise(t: t0, noises: &noises)

        rhs.drift(t: t0, y: y, into: &drift0)

        noise0.zero()
        for i in noises.indices {
            rhs.diffusion(
                t: t0,
                y: y,
                channel: i,
                into: &temporary
            )

            temporary.scale(by: noises[unchecked: i])
            noise0.add(temporary)
        }

        // temporary = predictor
        //           = y_n + h * drift0 + sqrt(h) * noise0
        temporary.assign(y, adding: drift0, multipliedBy: h)
        temporary.add(noise0, multiplied: sqrtH)

        y.add(drift0, multiplied: 0.5 * h)
        y.add(noise0, multiplied: 0.5 * sqrtH)

        rhs.drift(t: t1, y: temporary, into: &drift1)

        noise1.zero()

        for i in noises.indices {
            rhs.diffusion(
                t: t1,
                y: temporary,
                channel: i,
                into: &noise0 // reuse noise0 as scratch
            )

            noise0.scale(by: noises[unchecked: i])
            noise1.add(noise0)
        }

        // Second half of corrector
        y.add(drift1, multiplied: 0.5 * h)
        y.add(noise1, multiplied: 0.5 * sqrtH)

        t = t1
        return t
    }
}
