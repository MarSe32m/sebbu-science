//
//  UniqueODESolverState.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 17.5.2026.
//

public protocol UniqueODESolverState: ~Copyable {
    var norm: Double { get }
    
    mutating func assign(_ a: borrowing Self)
    mutating func assign(_ a: borrowing Self, multiplied: Double)
    mutating func add(_ a: borrowing Self, multiplied: Double)
    mutating func assign(_ base: borrowing Self, adding direction: borrowing Self, multipliedBy c: Double)
    func distance(to: borrowing Self) -> Double
}
