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
    
    @Test("Matrix<Double>.partialTrace")
    func matrixDoublePartialTrace() {
        let dimension1 = Int.random(in: 5...10)
        let dimension2 = Int.random(in: 5...15)
        let dimension3 = Int.random(in: 15...30)
        let A1: Matrix<Double> = .init(elements: Double.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        let A2: Matrix<Double> = .init(elements: Double.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        var B: Matrix<Double> = .init(elements: Double.random(count: dimension2 * dimension2, in: -1...1), rows: dimension2, columns: dimension2)
        B[0, 0] += (1.0 - B.trace)
        var C: Matrix<Double> = .init(elements: Double.random(count: dimension3 * dimension3, in: -1...1), rows: dimension3, columns: dimension3)
        C[1, 1] += (1.0 - C.trace)
        var total = A1.kronecker(B.kronecker(.identity(rows: dimension3)))
        total.divide(by: Double(dimension3))
        total.add(A2.kronecker(B.kronecker(C)))
        
        let _rho1 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0])
        let _rho2 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1])
        let _rho3 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [2])
        let _rho4 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1])
        let _rho5 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1, 2])
        let _rho6 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1, 2])
        let _rho7 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 2])
        #expect(_rho1.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho2.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho3.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho4.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho5.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho6.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho7.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
    }
    
    @Test("Matrix<Float>.partialTrace")
    func matrixFloatPartialTrace() {
        let dimension1 = Int.random(in: 5...10)
        let dimension2 = Int.random(in: 5...15)
        let dimension3 = Int.random(in: 15...30)
        let A1: Matrix<Float> = .init(elements: Float.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        let A2: Matrix<Float> = .init(elements: Float.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        var B: Matrix<Float> = .init(elements: Float.random(count: dimension2 * dimension2, in: -1...1), rows: dimension2, columns: dimension2)
        B[0, 0] += (1.0 - B.trace)
        var C: Matrix<Float> = .init(elements: Float.random(count: dimension3 * dimension3, in: -1...1), rows: dimension3, columns: dimension3)
        C[1, 1] += (1.0 - C.trace)
        var total = A1.kronecker(B.kronecker(.identity(rows: dimension3)))
        total.divide(by: Float(dimension3))
        total.add(A2.kronecker(B.kronecker(C)))
        
        let _rho1 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0])
        let _rho2 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1])
        let _rho3 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [2])
        let _rho4 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1])
        let _rho5 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1, 2])
        let _rho6 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1, 2])
        let _rho7 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 2])
        #expect(_rho1.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho2.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho3.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho4.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho5.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho6.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho7.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
    }
    
    @Test("Matrix<Complex<Double>>.partialTrace")
    func matrixComplexDoublePartialTrace() {
        let dimension1 = Int.random(in: 5...10)
        let dimension2 = Int.random(in: 5...15)
        let dimension3 = Int.random(in: 15...30)
        let A1: Matrix<Complex<Double>> = .init(elements: Complex<Double>.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        let A2: Matrix<Complex<Double>> = .init(elements: Complex<Double>.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        var B: Matrix<Complex<Double>> = .init(elements: Complex<Double>.random(count: dimension2 * dimension2, in: -1...1), rows: dimension2, columns: dimension2)
        B[0, 0] += (1.0 - B.trace)
        var C: Matrix<Complex<Double>> = .init(elements: Complex<Double>.random(count: dimension3 * dimension3, in: -1...1), rows: dimension3, columns: dimension3)
        C[1, 1] += (1.0 - C.trace)
        var total = A1.kronecker(B.kronecker(.identity(rows: dimension3)))
        total.divide(by: Double(dimension3))
        total.add(A2.kronecker(B.kronecker(C)))
        
        let _rho1 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0])
        let _rho2 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1])
        let _rho3 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [2])
        let _rho4 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1])
        let _rho5 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1, 2])
        let _rho6 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1, 2])
        let _rho7 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 2])
        #expect(_rho1.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho2.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho3.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho4.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho5.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho6.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
        #expect(_rho7.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-9))
    }
    
    @Test("Matrix<Complex<Float>>.partialTrace")
    func matrixComplexFloatPartialTrace() {
        let dimension1 = Int.random(in: 5...10)
        let dimension2 = Int.random(in: 5...15)
        let dimension3 = Int.random(in: 15...30)
        let A1: Matrix<Complex<Float>> = .init(elements: Complex<Float>.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        let A2: Matrix<Complex<Float>> = .init(elements: Complex<Float>.random(count: dimension1 * dimension1, in: -1...1), rows: dimension1, columns: dimension1)
        var B: Matrix<Complex<Float>> = .init(elements: Complex<Float>.random(count: dimension2 * dimension2, in: -1...1), rows: dimension2, columns: dimension2)
        B[0, 0] += (1.0 - B.trace)
        var C: Matrix<Complex<Float>> = .init(elements: Complex<Float>.random(count: dimension3 * dimension3, in: -1...1), rows: dimension3, columns: dimension3)
        C[1, 1] += (1.0 - C.trace)
        var total = A1.kronecker(B.kronecker(.identity(rows: dimension3)))
        total.divide(by: Float(dimension3))
        total.add(A2.kronecker(B.kronecker(C)))
        
        let _rho1 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0])
        let _rho2 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1])
        let _rho3 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [2])
        let _rho4 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1])
        let _rho5 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 1, 2])
        let _rho6 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [1, 2])
        let _rho7 = MatrixOperations.partialTrace(total, dimensions: [dimension1, dimension2, dimension3], keep: [0, 2])
        #expect(_rho1.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho2.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho3.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho4.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho5.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho6.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
        #expect(_rho7.trace.isApproximatelyEqual(to: A1.trace + A2.trace, absoluteTolerance: 1e-4))
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
            let vector1 = eigenValues[i] * eigenVectors[i]
            let vector2 = A.dot(eigenVectors[i])
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
    func matrixDoubleInverse() throws {
        let a: Matrix<Double> = .init(elements: [1.0, 2.0, 3.0, 4.0], rows: 2, columns: 2)
        let identity: Matrix<Double> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-10))
    }
    
    @Test("Float matrix inverse")
    func matrixFloatInverse() throws {
        let a: Matrix<Float> = .init(elements: [1.0, 2.0, 3.0, 4.0], rows: 2, columns: 2)
        let identity: Matrix<Float> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-06))
    }
    
    @Test("Complex<Double> matrix inverse")
    func matrixComplexDoubleInverse() throws {
        let a: Matrix<Complex<Double>> = .init(elements: [Complex(1.0), Complex(2.0, 1.0), Complex(3.0), Complex(4.0)], rows: 2, columns: 2)
        let identity: Matrix<Complex<Double>> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-10))
    }
    
    @Test("Complex<Float> matrix inverse")
    func matrixComplexFloatInverse() throws {
        let a: Matrix<Complex<Float>> = .init(elements: [Complex(1.0), Complex(2.0, 1.0), Complex(3.0), Complex(4.0)], rows: 2, columns: 2)
        let identity: Matrix<Complex<Float>> = .identity(rows: 2)
        let b = a.inverse
        #expect(b != nil)
        #expect(identity.isApproximatelyEqual(to: a.dot(b!), absoluteTolerance: 1e-06))
    }
}
