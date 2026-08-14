// Copyright (c) 2026 Sebastian Toivonen
// SPDX-License-Identifier: Apache-2.0

import NumericsExtensions

/// A square or rectangular linear operator that can be applied without
/// explicitly materializing a dense matrix.
///
/// Iterative methods such as GMRES only need matrix-vector products. Custom
/// matrix-free operators can conform to this protocol in addition to the
/// built-in dense and CSR matrix types.
public protocol LinearOperator: ~Copyable {
    associatedtype Scalar: ConjugatableScalar

    var rows: Int { get }
    var columns: Int { get }

    /// Computes `result = self * vector`.
    func apply(
        _ vector: borrowing UniqueVector<Scalar>,
        into result: inout UniqueVector<Scalar>
    )
}

extension Matrix: LinearOperator where T: ConjugatableScalar {
    @inlinable
    public func apply(
        _ vector: borrowing UniqueVector<T>,
        into result: inout UniqueVector<T>
    ) {
        precondition(vector.count == columns && result.count == rows, "Vector dimensions do not match")
        dot(vector.components, into: result.components)
    }
}

extension UniqueMatrix: LinearOperator where T: ConjugatableScalar {
    @inlinable
    public func apply(
        _ vector: borrowing UniqueVector<T>,
        into result: inout UniqueVector<T>
    ) {
        dot(vector, into: &result)
    }
}

extension CSRMatrix: LinearOperator where T: ConjugatableScalar {
    @inlinable
    public func apply(
        _ vector: borrowing UniqueVector<T>,
        into result: inout UniqueVector<T>
    ) {
        precondition(vector.count == columns && result.count == rows, "Vector dimensions do not match")
        dot(vector.components, into: result.components)
    }
}

extension UniqueCSRMatrix: LinearOperator where T: ConjugatableScalar {
    @inlinable
    public func apply(
        _ vector: borrowing UniqueVector<T>,
        into result: inout UniqueVector<T>
    ) {
        precondition(vector.count == columns && result.count == rows, "Vector dimensions do not match")
        dot(vector.components, into: result.components)
    }
}
