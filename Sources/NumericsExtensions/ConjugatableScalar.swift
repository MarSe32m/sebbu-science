// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics

public protocol ConjugatableScalar: AlgebraicField {
    var conjugate: Self { get }
    var isApproximatelyZero: Bool { get }
}

extension Double: ConjugatableScalar {
    @inlinable public var conjugate: Double { self }
    
    @inlinable
    public var isApproximatelyZero: Bool {
        self.isApproximatelyEqual(to: .zero)
    }
}

extension Float: ConjugatableScalar {
    @inlinable public var conjugate: Float { self }
    
    @inlinable
    public var isApproximatelyZero: Bool {
        self.isApproximatelyEqual(to: .zero)
    }
}

extension Complex: ConjugatableScalar {
    @inlinable
    public var isApproximatelyZero: Bool {
        self.isApproximatelyEqual(to: .zero)
    }
}
