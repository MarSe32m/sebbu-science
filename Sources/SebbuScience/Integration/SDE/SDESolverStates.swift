//
//  SDESolverStates.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 17.5.2026.
//

public protocol FixedStepSDESolverState: ~Copyable {
    associatedtype NoiseType
    
    mutating func zero()
    mutating func assign(_ other: borrowing Self)
    mutating func add(_ a: borrowing Self, multiplied: Double)
    mutating func add(_ a: borrowing Self)
    mutating func scale(by: NoiseType)
    mutating func assign(_ base: borrowing Self, adding direction: borrowing Self, multipliedBy c: Double)
}

public protocol SDERHSFunction: ~Copyable {
    associatedtype State: FixedStepSDESolverState
    associatedtype NoiseType
    
    /// Must fully overwrite `dy`.
    mutating func drift(
        t: Double,
        y: borrowing State,
        into dy: inout State
    )
    
    /// Must fully overwrite `dy`.
    mutating func diffusion(
        t: Double,
        y: borrowing State,
        channel: Int,
        into dy: inout State
    )
    
    /// Samples normalized noises ξ_i with E[ξ_i ξ_j] = δ_ij.
    /// The solver multiplies them by sqrt(dt).
    mutating func sampleWhiteNoise(
        t: Double,
        noises: inout MutableSpan<NoiseType>
    )
}
