import Testing
@testable import SebbuScience


struct MatrixOperationTests {
    @Test("Matrix<Double>.solve(A:,B:)")
    func matrixDoubleSolve() {
        let dim = 50
        let A = Matrix<Double>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let B = Matrix<Double>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let X = try! MatrixOperations.solve(A: A, B: B)
        #expect(A.dot(X).isApproximatelyEqual(to: B, absoluteTolerance: 1e-10))
    }

    @Test("Matrix<Float>.solve(A:,B:)")
    func matrixFloatSolve() {
        let dim = 10
        let A = Matrix<Float>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let B = Matrix<Float>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let X = try! MatrixOperations.solve(A: A, B: B)
        #expect(A.dot(X).isApproximatelyEqual(to: B, absoluteTolerance: 1e-4))
    }

    @Test("Matrix<Complex<Double>>.solve(A:,B:)")
    func matrixComplexDoubleSolve() {
        let dim = 50
        let A = Matrix<Complex<Double>>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let B = Matrix<Complex<Double>>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let X = try! MatrixOperations.solve(A: A, B: B)
        #expect(A.dot(X).isApproximatelyEqual(to: B, absoluteTolerance: 1e-10))
    }

    @Test("Matrix<Complex<Float>>.solve(A:,B:)")
    func matrixComplexFloatSolve() {
        let dim = 10
        let A = Matrix<Complex<Float>>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let B = Matrix<Complex<Float>>(elements: (0..<dim*dim).map { _ in .random(in: -1...1)}, rows: dim, columns: dim)
        let X = try! MatrixOperations.solve(A: A, B: B)
        #expect(A.dot(X).isApproximatelyEqual(to: B, absoluteTolerance: 1e-4))
    }

    @Test("Matrix<Double>.singularValueDecomposition(A:)")
    func matrixDoubleSingularValueDecomposition() throws {
        let dim = 10
        let A = Matrix<Double>(elements: (0..<dim*dim).map { _ in .random(in: -1...1) }, rows: dim, columns: dim)
        let (U, singularValues, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let sigma = Matrix<Double>.diagonal(from: singularValues.map { .init($0) })
        #expect(A.isApproximatelyEqual(to: U.dot(sigma).dot(VT), absoluteTolerance: 1e-10))
    }

    @Test("Matrix<Float>.singularValueDecomposition(A:)")
    func matrixFloatSingularValueDecomposition() throws {
        let dim = 10
        let A = Matrix<Float>(elements: (0..<dim*dim).map { _ in .random(in: -1...1) }, rows: dim, columns: dim)
        let (U, singularValues, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let sigma = Matrix<Float>.diagonal(from: singularValues.map { .init($0) })
        #expect(A.isApproximatelyEqual(to: U.dot(sigma).dot(VT), absoluteTolerance: 1e-4))
    }

    @Test("Matrix<Complex<Double>>.singularValueDecomposition(A:)")
    func matrixComplexDoubleSingularValueDecomposition() throws {
        let dim = 10
        let A = Matrix<Complex<Double>>(elements: (0..<dim*dim).map { _ in .random(in: -1...1) }, rows: dim, columns: dim)
        let (U, singularValues, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let sigma = Matrix<Complex<Double>>.diagonal(from: singularValues.map { .init($0) })
        #expect(A.isApproximatelyEqual(to: U.dot(sigma).dot(VT), absoluteTolerance: 1e-10))
    }

    @Test("Matrix<Complex<Float>>.singularValueDecomposition(A:)")
    func matrixComplexFloatSingularValueDecomposition() throws {
        let dim = 10
        let A = Matrix<Complex<Float>>(elements: (0..<dim*dim).map { _ in .random(in: -1...1) }, rows: dim, columns: dim)
        let (U, singularValues, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let sigma = Matrix<Complex<Float>>.diagonal(from: singularValues.map { .init($0) })
        #expect(A.isApproximatelyEqual(to: U.dot(sigma).dot(VT), absoluteTolerance: 1e-4))
    }
}
