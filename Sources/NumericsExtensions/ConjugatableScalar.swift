// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

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
