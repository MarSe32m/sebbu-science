//
//  ConjugatableScalar.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 23.5.2026.
//
import Numerics

public protocol ConjugatableScalar: AlgebraicField {
    var conjugate: Self { get }
}

extension Double: ConjugatableScalar {
    @inlinable public var conjugate: Double { self }
}

extension Float: ConjugatableScalar {
    @inlinable public var conjugate: Float { self }
}

extension Complex: ConjugatableScalar {}
