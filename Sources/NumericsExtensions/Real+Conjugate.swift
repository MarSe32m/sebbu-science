// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

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
