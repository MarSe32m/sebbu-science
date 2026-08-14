// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import NumericsExtensions

public extension LinearAlgebraAlgorithms {
    /// Computes the orthogonal projections of vector `v` on vector `u`
    /// - Parameters:
    ///   - v: The vector that will be projected
    ///   - u: The vector that will be projected onto
    /// - Returns: The vector `proj_u(v) = (v, u)/|u|^2 * u`
    @inlinable
    static func projection<T: Real>(of v: Vector<T>, on u: Vector<T>) -> Vector<T> {
        precondition(v.count == u.count, "Vector dimensions must match.")
        if u == .zero(u.count) { return .zero(v.count) }
        let vDotu = v.inner(u)
        let uDotu = u.inner(u)
        return vDotu / uDotu * u
    }
    
    /// Computes the orthogonal projections of vector `v` on vector `u`
    /// - Parameters:
    ///   - v: The vector that will be projected
    ///   - u: The vector that will be projected onto
    /// - Returns: The vector `proj_u(v) = (v, u)/|u|^2 * u`
    @inlinable
    static func projection(of v: Vector<Complex<Double>>, on u: Vector<Complex<Double>>) -> Vector<Complex<Double>> {
        precondition(v.count == u.count, "Vector dimensions must match.")
        if u == .zero(u.count) { return .zero(v.count) }
        let vDotu = v.inner(u)
        let uDotu = u.inner(u)
        return vDotu / uDotu * u
    }
    
    /// Computes the orthogonal projections of vector `v` on vector `u`
    /// - Parameters:
    ///   - v: The vector that will be projected
    ///   - u: The vector that will be projected onto
    /// - Returns: The vector `proj_u(v) = (v, u)/|u|^2 * u`
    @inlinable
    static func projection(of v: Vector<Complex<Float>>, on u: Vector<Complex<Float>>) -> Vector<Complex<Float>> {
        precondition(v.count == u.count, "Vector dimensions must match.")
        if u == .zero(u.count) { return .zero(v.count) }
        let vDotu = v.inner(u)
        let uDotu = u.inner(u)
        return vDotu / uDotu * u
    }
    
    /// Computes the orthogonal projections of vector `v` on vector `u`
    /// - Parameters:
    ///   - v: The vector that will be projected
    ///   - u: The vector that will be projected onto
    /// - Returns: The vector `proj_u(v) = (v, u)/|u|^2 * u`
    @inlinable
    static func projection<T: ConjugatableScalar>(of v: borrowing UniqueVector<T>, on u: borrowing UniqueVector<T>) -> UniqueVector<T> {
        precondition(v.count == u.count, "Vector dimensions must match.")
        let uComponentSpan = u.span
        var hasNonZero = false
        for i in uComponentSpan.indices {
            hasNonZero = hasNonZero || (u[i] != .zero)
        }
        if !hasNonZero { return .zero(v.count) }
        let vDotu = v.inner(u)
        let uDotu = u.inner(u)
        return vDotu / uDotu * u
    }
}
