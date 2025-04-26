//
//  MatrixMatrixOperations.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 20.4.2025.
//

import Testing
@testable import SebbuScience

struct MatrixMatrixOperationTests {
    @Test("Matrix<Double>.dot()")
    func matrixDoubleDot() async throws {
        let a = Matrix<Double>(elements: [1.0, 2.0, -1.0, 3.0], rows: 2, columns: 2)
        let b = Matrix<Double>(elements: [0.0, 1.0, 2.0, 3.0], rows: 2, columns: 2)
        let c = a.dot(b)
        let d = b.dot(a)
        #expect(c.elements == [4.0, 7.0, 6.0, 8.0])
        #expect(d.elements == [-1.0, 3.0, -1.0, 13.0])
    }
    
    @Test("Matrix<Float>.dot()")
    func matrixFloatDot() async throws {
        let a = Matrix<Float>(elements: [1.0, 2.0, -1.0, 3.0], rows: 2, columns: 2)
        let b = Matrix<Float>(elements: [0.0, 1.0, 2.0, 3.0], rows: 2, columns: 2)
        let c = a.dot(b)
        let d = b.dot(a)
        #expect(c.elements == [4.0, 7.0, 6.0, 8.0])
        #expect(d.elements == [-1.0, 3.0, -1.0, 13.0])
    }
}

struct ZGEEVTest {
    
    @Test("Diagonalize hermitian matrix")
    func testDiagonalizeHermitianMatrix() throws {
        let A: Matrix<Complex<Double>> = .init(elements: [Complex(1.0), Complex(0, 1),
                                                          Complex(0, -1), Complex(1) ], rows: 2, columns: 2)
        let (eigenValues, eigenVectors) = try MatrixOperations.diagonalizeHermitian(A)
        for i in 0..<eigenValues.count {
            print(eigenValues[i], "(\(eigenVectors[i][0]),\(eigenVectors[i][1]))")
            var vector1 = eigenValues[i] * eigenVectors[i]
            var vector2 = A.dot(eigenVectors[i])
            print(vector1)
            print(vector2)
            print()
        }
        print(A)
        print(eigenValues[1] * eigenVectors[1].conjugate.outer(eigenVectors[1]))
    }
    
    @Test("Herimitan dot")
    func testHermitianDot() {
        let A = Matrix<Complex<Double>>(elements: [Complex(1), Complex(1, 2), Complex(1, -2), Complex(4)], rows: 2, columns: 2)
        let vec = Vector<Complex<Double>>([Complex(4), Complex(2, 3)])
        #expect(A.dot(vec).isApproximatelyEqual(to: A.hermitianDot(vec)))
        #expect(vec.dot(A).isApproximatelyEqual(to: vec.dotHermitian(A)))
    }
}

struct InverseTest {
    @Test("Double matrix inverse")
    func matrixDoubleInverse() async throws {
        let a: Matrix<Double> = .init(elements: [1.0, 2.0, 3.0, 4.0], rows: 2, columns: 2)
        let identity: Matrix<Double> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-10))
    }
    
    @Test("Float matrix inverse")
    func matrixFloatInverse() async throws {
        let a: Matrix<Float> = .init(elements: [1.0, 2.0, 3.0, 4.0], rows: 2, columns: 2)
        let identity: Matrix<Float> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-06))
    }
    
    @Test("Complex<Double> matrix inverse")
    func matrixComplexDoubleInverse() async throws {
        let a: Matrix<Complex<Double>> = .init(elements: [Complex(1.0), Complex(2.0, 1.0), Complex(3.0), Complex(4.0)], rows: 2, columns: 2)
        let identity: Matrix<Complex<Double>> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-10))
    }
    
    @Test("Complex<Float> matrix inverse")
    func matrixComplexFloatInverse() async throws {
        let a: Matrix<Complex<Float>> = .init(elements: [Complex(1.0), Complex(2.0, 1.0), Complex(3.0), Complex(4.0)], rows: 2, columns: 2)
        let identity: Matrix<Complex<Float>> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-06))
    }
}
