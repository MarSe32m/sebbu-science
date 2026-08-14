// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import Numerics
import NumericsExtensions

public extension LinearAlgebraAlgorithms {
    /// Orthogonalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameter vectors: Linearly independent vectors to be orthogonalized
    /// - Returns: Orthogonalized vectors
    @inlinable
    static func gramSchmidtOrthogonalize<T: Real>(vectors: [Vector<T>]) -> [Vector<T>] {
        var result: [Vector<T>] = []
        for i in 0..<vectors.count {
            if i == 0 {
                result.append(vectors[i])
                continue
            }
            let vi = vectors[i]
            var u = vi
            for j in 0..<i {
                u.subtract(projection(of: u, on: result[j]))
            }
            result.append(u)
        }
        return result
    }
    
    /// Orthonormalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameter vectors: Linearly independent vectors to be orthonormalized
    /// - Returns: Orthonormalized vectors
    @inlinable
    static func gramSchmidtOrthonormalize<T: Real>(vectors: [Vector<T>]) -> [Vector<T>] {
        var orthogonalized = gramSchmidtOrthogonalize(vectors: vectors)
        for i in orthogonalized.indices { orthogonalized[i].divide(by: orthogonalized[i].inner(orthogonalized[i])) }
        return orthogonalized
    }
    
    /// Orthogonalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameter vectors: Linearly independent vectors to be orthogonalized
    /// - Returns: Orthogonalized vectors
    @inlinable
    static func gramSchmidtOrthogonalize(vectors: [Vector<Complex<Double>>]) -> [Vector<Complex<Double>>] {
        var result: [Vector<Complex<Double>>] = []
        for i in 0..<vectors.count {
            if i == 0 {
                result.append(vectors[i])
                continue
            }
            let vi = vectors[i]
            var u = vi
            for j in 0..<i {
                u.subtract(projection(of: u, on: result[j]))
            }
            //u.divide(by: u.inner(u))
            result.append(u)
        }
        return result
    }
    
    /// Orthonormalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameter vectors: Linearly independent vectors to be orthonormalized
    /// - Returns: Orthonormalized vectors
    @inlinable
    static func gramSchmidtOrthonormalize(vectors: [Vector<Complex<Double>>]) -> [Vector<Complex<Double>>] {
        var orthogonalized = gramSchmidtOrthogonalize(vectors: vectors)
        for i in orthogonalized.indices { orthogonalized[i].divide(by: orthogonalized[i].inner(orthogonalized[i])) }
        return orthogonalized
    }
    
    /// Orthogonalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameter vectors: Linearly independent vectors to be orthogonalized
    /// - Returns: Orthogonalized vectors
    @inlinable
    static func gramSchmidtOrthogonalize(vectors: [Vector<Complex<Float>>]) -> [Vector<Complex<Float>>] {
        var result: [Vector<Complex<Float>>] = []
        for i in 0..<vectors.count {
            if i == 0 {
                result.append(vectors[i])
                continue
            }
            let vi = vectors[i]
            var u = vi
            for j in 0..<i {
                u.subtract(projection(of: u, on: result[j]))
            }
            //u.divide(by: u.inner(u))
            result.append(u)
        }
        return result
    }
    
    /// Orthonormalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameter vectors: Linearly independent vectors to be orthonormalized
    /// - Returns: Orthonormalized vectors
    @inlinable
    static func gramSchmidtOrthonormalize(vectors: [Vector<Complex<Float>>]) -> [Vector<Complex<Float>>] {
        var orthogonalized = gramSchmidtOrthogonalize(vectors: vectors)
        for i in orthogonalized.indices { orthogonalized[i].divide(by: orthogonalized[i].inner(orthogonalized[i])) }
        return orthogonalized
    }
    
    
    /// Orthogonalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameters:
    ///   - vectors: Linearly independent vectors to be orthogonalized
    ///   - into: Storage for the orthogonalized vectors
    @inlinable
    static func gramSchmidtOrthogonalize<T: ConjugatableScalar>(vectors: borrowing Span<UniqueVector<T>>, into: inout MutableSpan<UniqueVector<T>>) {
        precondition(vectors.count == into.count, "The number of vectors and the number of storage locations don't match.")
        for i in vectors.indices {
            let viCount = vectors[i].count
            let intoCount = into[i].count
            precondition(viCount == intoCount, "The vectors must have the same size. Index \(i): \(viCount) != \(intoCount)")
        }
        for i in 0..<vectors.count {
            into[i].copyComponents(from: vectors[i])
            if i == 0 { continue }
            for j in 0..<i {
                into[i].subtract(projection(of: into[i], on: into[j]))
            }
        }
    }
    
    /// Orthonormalize a set of linearly independent vectors by the modified Gram-Schmidt process
    /// - Parameters:
    ///   - vectors: Linearly independent vectors to be orthonormalized
    ///   - into: Storage for the orthonormalized vectors
    @inlinable
    static func gramSchmidtOrthonormalize<T: ConjugatableScalar>(vector: borrowing Span<UniqueVector<T>>, into: inout MutableSpan<UniqueVector<T>>)  {
        gramSchmidtOrthogonalize(vectors: vector, into: &into)
        for i in into.indices { into[i].normalize() }
    }
}
