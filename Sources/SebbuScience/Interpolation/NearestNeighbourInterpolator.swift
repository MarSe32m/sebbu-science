//
//  NearestNeighbourInterpolator.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

import Numerics

public struct NearestNeighbourInterpolator<Element> {
    public let x: [Double]
    public let y: [Element]
    
    public init(x: [Double], y: [Element]) {
        precondition(
            {
                for i in 1..<x.count {
                    if x[i - 1] >= x[i] { return false }
                }
                return true
            }(),
            "The x-values must be in ascending order."
        )
        self.x = x
        self.y = y
    }
    
    @_transparent
    @usableFromInline
    internal func _t(t: Double, k: Int) -> Double {
        (t - x[k]) / (x[k + 1] - x[k])
    }
    
    @inlinable
    public func callAsFunction(_ t: Double) -> Element {
        if t <= x[0] { return y[0] }
        if t >= x.last! { return y.last! }
        let k = x.intervalIndex(t)
        let t_ = _t(t: t, k: k)
        return t_ <= 0.5 ? y[k] : y[k + 1]
    }
    
    @inlinable
    public func sample(_ t: Double) -> Element {
        self(t)
    }
}

extension NearestNeighbourInterpolator: Sendable where Element: Sendable {}
