//
//  TestUtilities.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 19.4.2025.
//
@_spi(TestUtilities)
@_optimize(none)
@inline(never)
public func blackHole<T>(_ arg: T) {
    _ = arg
}
