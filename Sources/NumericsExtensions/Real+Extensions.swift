//
//  Real+Extensions.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 9.6.2026.
//

import Numerics

public extension Real {
    
    /// 1 - exp(-x), computed in such a way as to maintain accuracy for small x.
    @inlinable
    static func oneMinusExpMinus(_ x: Self) -> Self {
        guard x.isFinite else {
            if x == .infinity { return 1 }
            if x == -.infinity { return -.infinity }
            return .nan
        }
        return -.expMinusOne(-x)
    }
    
    /// (1 - exp(-x)) / x, computed in such a way as to maintain accuracy for small x.
    @inlinable
    static func phiOneMinusExpMinus(_ x: Self) -> Self {
        // phi(x) = (1 - exp(-x)) / x
        //
        // Around x = 0 this has the removable singularity
        //
        //     phi(0) = 1
        //
        // and the Taylor expansion
        //
        //     phi(x) = 1 - x/2 + x^2/6 - x^3/24
        //              + x^4/120 - x^5/720 + ...

        guard x.isFinite else {
            if x == .infinity { return .zero }
            if x == -.infinity { return .infinity }
            return .nan
        }

        let thershold = Self(1) / Self(10000)
        if x.magnitude < thershold {
            let x2 = x * x
            let x3 = x2 * x
            let x4 = x2 * x2
            let x5 = x4 * x
            let x6 = x3 * x3
            var result: Self = 1
            result -= x / 2
            result += x2 / 6
            result -= x3 / 24
            result += x4 / 120
            result -= x5 / 720
            result += x6 / 5040
            return result
        }

        return oneMinusExpMinus(x) / x
    }
}
