// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

public protocol FixedStepODESolverState: ~Copyable {
    mutating func add(_ a: borrowing Self, multiplied: Double)
    mutating func assign(_ base: borrowing Self, adding direction: borrowing Self, multipliedBy c: Double)
}

public protocol AdaptiveStepODESolverState: ~Copyable, FixedStepODESolverState {
    var norm: Double { get }
    
    mutating func assign(_ a: borrowing Self)
    mutating func assign(_ a: borrowing Self, multiplied: Double)
    func distance(to: borrowing Self) -> Double
}

public protocol ODERHSFunction: ~Copyable, ~Escapable {
    associatedtype State: ~Copyable
    
    mutating func evaluate(
        t: Double,
        y: borrowing State,
        dy: inout State
    )
}
