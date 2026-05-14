//
//  Real+Conjugate.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 14.5.2026.
//

import Numerics

public extension Real {
    @inline(always)
    @_transparent
    @inlinable
    var conjugate: Self { self }
}

public extension AlgebraicField where Self: Real {
    @inline(always)
    @_transparent
    @inlinable
    var conjugate: Self { self }
}
