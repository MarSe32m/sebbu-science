// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

@_spi(TestUtilities)
@_optimize(none)
@inline(never)
public func blackHole<T>(_ arg: T) {
    _ = arg
}
