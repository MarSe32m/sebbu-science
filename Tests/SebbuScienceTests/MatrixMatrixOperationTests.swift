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

struct SolveTests {
    @Test("Double matrix solve")
    func matrixSolveDouble() throws {
        let A: Matrix<Double> = .init(elements: [
            6.80, -6.05, -0.45,  8.32, -9.67,
           -2.11, -3.30,  2.58,  2.71, -5.14,
            5.66, 5.36, -2.70,  4.35, -7.26,
            5.97, -4.44,  0.27, -7.17, 6.08,
            8.23, 1.08,  9.04,  2.14, -6.87
        ], rows: 5, columns: 5)
        let B: Matrix<Double> = .init(elements: [
            4.02, -1.56, 9.81,
            6.19,  4.00, -4.09,
           -8.22, -8.67, -4.57,
           -7.57,  1.75, -8.61,
           -3.03,  2.86, 8.99
        ], rows: 5, columns: 3)
        let solution: Matrix<Double> = .init(elements: [
             -0.8007140257202479, -0.38962139301919557, 0.9554649124194898,
             -0.695243384440311, -0.554427127353211, 0.22065962698171063,
             0.593914994899136, 0.842227385604611, 1.9006367315589723,
              1.321725609087391, -0.10380185380746244, 5.357661487175355,
              0.5657561965738035, 0.1057109514742745, 4.040602658253423
        ], rows: 5, columns: 3)
        let X = try MatrixOperations.solve(A: A, B: B)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-11))
    }
    
    @Test("Float matrix solve")
    func matrixSolveFloat() throws {
        let A: Matrix<Float> = .init(elements: [
            6.80, -6.05, -0.45,  8.32, -9.67,
           -2.11, -3.30,  2.58,  2.71, -5.14,
            5.66, 5.36, -2.70,  4.35, -7.26,
            5.97, -4.44,  0.27, -7.17, 6.08,
            8.23, 1.08,  9.04,  2.14, -6.87
        ], rows: 5, columns: 5)
        let B: Matrix<Float> = .init(elements: [
            4.02, -1.56, 9.81,
            6.19,  4.00, -4.09,
           -8.22, -8.67, -4.57,
           -7.57,  1.75, -8.61,
           -3.03,  2.86, 8.99
        ], rows: 5, columns: 3)
        let solution: Matrix<Float> = .init(elements: [
             -0.8007141, -0.38962144, 0.95546454,
             -0.6952434, -0.55442715, 0.22065961,
              0.593915, 0.84222746, 1.9006369,
              1.3217258, -0.10380168, 5.357662,
              0.56575626, 0.105711095, 4.0406027
        ], rows: 5, columns: 3)
        let X = try MatrixOperations.solve(A: A, B: B)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-7))
    }
    
    @Test("Complex<Double> matrix solve")
    func matrixSolveComplexDouble() throws {
        let A: Matrix<Complex<Double>> = .init(elements: [
            Complex( 1.23, -5.50), Complex( 7.91, -5.38), Complex(-9.80, -4.86), Complex(-7.32,  7.57),
            Complex(-2.14, -1.12), Complex(-9.92, -0.79), Complex(-9.18, -1.12), Complex( 1.37,  0.43),
            Complex(-4.30, -7.10), Complex(-6.47,  2.52), Complex(-6.51, -2.67), Complex(-5.86,  7.38),
            Complex( 1.27,  7.29), Complex( 8.90,  6.92), Complex(-8.82,  1.25), Complex( 5.41,  5.37)
        ], rows: 4, columns: 4)
        let B: Matrix<Complex<Double>> = .init(elements: [
            Complex( 8.33, -7.32), Complex(-6.11, -3.81),
            Complex(-6.18, -4.80), Complex( 0.14, -7.71),
            Complex(-5.71, -2.80), Complex( 1.41,  3.40),
            Complex(-1.60,  3.08), Complex( 8.54, -4.05)
        ], rows: 4, columns: 2)
        let solution: Matrix<Complex<Double>> = .init(elements: [
            Complex(-1.088161720323708, -0.1826101102139031), Complex(1.2822348620788953, 1.2051551793768274),
            Complex(0.9663577698039507, 0.5207030705963318), Complex(-0.22224471481082717, -0.9682584564852249),
            Complex(-0.20249026025978667, 0.18667413386161746), Complex(0.5337983964219706, 1.3580324841871447),
            Complex(-0.5856393754003832, 0.9182297260009338), Complex(2.2224777016355075, -0.9975438587678024)
        ], rows: 4, columns: 2)
        let X = try MatrixOperations.solve(A: A, B: B)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-11))
    }
    
    @Test("Complex<Float> matrix solve")
    func matrixSolveComplexFloat() throws {
        let A: Matrix<Complex<Float>> = .init(elements: [
            Complex( 1.23, -5.50), Complex( 7.91, -5.38), Complex(-9.80, -4.86), Complex(-7.32,  7.57),
            Complex(-2.14, -1.12), Complex(-9.92, -0.79), Complex(-9.18, -1.12), Complex( 1.37,  0.43),
            Complex(-4.30, -7.10), Complex(-6.47,  2.52), Complex(-6.51, -2.67), Complex(-5.86,  7.38),
            Complex( 1.27,  7.29), Complex( 8.90,  6.92), Complex(-8.82,  1.25), Complex( 5.41,  5.37)
        ], rows: 4, columns: 4)
        let B: Matrix<Complex<Float>> = .init(elements: [
            Complex( 8.33, -7.32), Complex(-6.11, -3.81),
            Complex(-6.18, -4.80), Complex( 0.14, -7.71),
            Complex(-5.71, -2.80), Complex( 1.41,  3.40),
            Complex(-1.60,  3.08), Complex( 8.54, -4.05)
        ], rows: 4, columns: 2)
        let solution: Matrix<Complex<Float>> = .init(elements: [
            Complex(-1.0881617, -0.18261006), Complex(1.2822347, 1.2051553),
            Complex(0.9663577, 0.520703), Complex(-0.22224456, -0.9682584),
            Complex(-0.2024903, 0.1866742), Complex(0.53379834, 1.3580325),
            Complex(-0.58563924, 0.91822976), Complex(2.2224777, -0.9975437)
        ], rows: 4, columns: 2)
        let X = try MatrixOperations.solve(A: A, B: B)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-7))
    }
}

struct SVDTests {
    @Test("Double matrix svd")
    func matrixSVDDouble() throws {
        let A: Matrix<Double> = .init(elements: [
            8.79,  9.93,  9.83, 5.45,  3.16,
            6.11,  6.91,  5.04, -0.27,  7.98,
           -9.15, -7.93,  4.86, 4.85,  3.01,
            9.57,  1.64,  8.83, 0.74,  5.80,
           -3.49,  4.02,  9.80, 10.00,  4.27,
            9.84,  0.15, -8.99, -6.02, -5.31
        ], rows: 6, columns: 5)
        let (U, S, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let solutionU: Matrix<Double> = .init(elements: [
             -0.5911423764124367, 0.2631678147140563, 0.35543017386282705, 0.3142643627269274, 0.2299383153647478, 0.5507531798028814,
             -0.3975667942024256, 0.24379902792633013, -0.222390000685446, -0.7534661509534579, -0.36358968669749664, 0.18203479013503573,
             -0.03347896906244677, -0.6002725806935826, -0.45083926892230786, 0.23344965724471442, -0.3054757327479322, 0.5361732698764646,
             -0.4297069031370183, 0.23616680628112535, -0.6858628638738119, 0.3318600182003095, 0.1649276348845104, -0.38966287036061276,
             -0.4697479215666586, -0.3508913988837026, 0.3874446030996732, 0.15873555958215632, -0.5182574373535349, -0.46077222860548533,
              0.29335875846440346, 0.5762621191338906, -0.020852917980871164, 0.3790776670601604, -0.6525516005923975, 0.10910680820072886
        ], rows: 6, columns: 6)
        let solutionS: [Double] = [27.46873241822184, 22.6431850097747, 8.558388228482574, 5.985723201512137, 2.0148996587157564]
        let solutionVT: Matrix<Double> = .init(elements: [
            -0.25138279272049696, -0.39684555177692954, -0.6921510074703635, -0.36617044477223054, -0.4076352386533526,
             0.8148366860863392, 0.3586615001880022, -0.24888801115928483, -0.3685935379446176, -0.09796256926688694,
             -0.2606185055842208, 0.7007682094072527, -0.2208114467204375, 0.3859384831885421, -0.49325014285102353,
             0.39672377713059687, -0.4507112412166432, 0.2513211496937533, 0.4342486014366714, -0.6226840720358041,
             -0.21802776368654556, 0.14020994987112065, 0.5891194492399429, -0.626528250364817, -0.43955169234233304
        ], rows: 5, columns: 5)
        #expect(U.isApproximatelyEqual(to: solutionU, absoluteTolerance: 1e-11))
        #expect(zip(S, solutionS).allSatisfy { $0.0.isApproximatelyEqual(to: $0.1, absoluteTolerance: 1e-11) } )
        #expect(VT.isApproximatelyEqual(to: solutionVT, absoluteTolerance: 1e-11))
        var sigma: Matrix<Double> = .zeros(rows: U.columns, columns: VT.rows)
        for i in 0..<S.count { sigma[i, i] = .init(S[i]) }
        #expect(U.dot(sigma).dot(VT).isApproximatelyEqual(to: A, absoluteTolerance: 1e-11))
    }
    
    @Test("Float matrix svd")
    func matrixSVDFloat() throws {
        let A: Matrix<Float> = .init(elements: [
            8.79,  9.93,  9.83, 5.45,  3.16,
            6.11,  6.91,  5.04, -0.27,  7.98,
           -9.15, -7.93,  4.86, 4.85,  3.01,
            9.57,  1.64,  8.83, 0.74,  5.80,
           -3.49,  4.02,  9.80, 10.00,  4.27,
            9.84,  0.15, -8.99, -6.02, -5.31
        ], rows: 6, columns: 5)
        let (U, S, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let solutionU: Matrix<Float> = .init(elements: [
            -0.5911425, 0.26316765, 0.35543042, 0.31426415, 0.22993852, 0.55075324,
             -0.39756685, 0.24379891, -0.22239041, -0.753466, -0.3635896, 0.1820348,
             -0.0334788, -0.60027266, -0.450839, 0.23344986, -0.30547565, 0.53617334,
             -0.42970702, 0.23616658, -0.6858627, 0.33186042, 0.16492744, -0.38966286,
             -0.46974775, -0.3508915, 0.38744467, 0.1587352, -0.5182576, -0.4607722,
             0.29335847, 0.5762621, -0.020852672, 0.37907752, -0.65255165, 0.109107025
        ], rows: 6, columns: 6)
        let solutionS: [Float] = [27.468735, 22.643179, 8.558389, 5.9857216, 2.0149007]
        let solutionVT: Matrix<Float> = .init(elements: [
            -0.25138307, -0.3968457, -0.6921509, -0.36617035, -0.40763527,
             0.8148366, 0.35866144, -0.24888818, -0.36859363, -0.09796271,
             -0.2606184, 0.7007681, -0.22081146, 0.38593873, -0.49325028,
             0.39672384, -0.45071137, 0.25132135, 0.43424845, -0.62268394,
             -0.21802785, 0.14021002, 0.58911943, -0.6265283, -0.4395516
        ], rows: 5, columns: 5)
        #expect(U.isApproximatelyEqual(to: solutionU, absoluteTolerance: 1e-7))
        #expect(zip(S, solutionS).allSatisfy { $0.0.isApproximatelyEqual(to: $0.1, absoluteTolerance: 1e-7) } )
        #expect(VT.isApproximatelyEqual(to: solutionVT, absoluteTolerance: 1e-7))
        var sigma: Matrix<Float> = .zeros(rows: U.columns, columns: VT.rows)
        for i in 0..<S.count { sigma[i, i] = .init(S[i]) }
        #expect(U.dot(sigma).dot(VT).isApproximatelyEqual(to: A, absoluteTolerance: 1e-2))
    }
    
    @Test("Complex<Double> matrix svd")
    func matrixSVDComplexDouble() throws {
        let A: Matrix<Complex<Double>> = .init(elements: [
            Complex( 5.91, -5.69), Complex( 7.09,  2.72), Complex(7.78, -4.06), Complex(-0.79, -7.21),
            Complex(-3.15, -4.08), Complex(-1.89,  3.27), Complex(4.57, -2.07), Complex(-3.88, -3.30),
            Complex(-4.89,  4.20), Complex( 4.10, -6.70), Complex(3.28, -3.84), Complex( 3.84,  1.19)
        ], rows: 3, columns: 4)
        let (U, S, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let solutionU: Matrix<Complex<Double>> = .init(elements: [
            Complex(-0.8567519102348327), Complex(0.40169740961685513), Complex(0.3234429708867917),
            Complex(-0.35054713697315865, 0.12848536699843277), Complex(-0.24033104987380832, -0.21020102698539983), Complex(-0.6300695559577527, 0.6013959466135732),
            Complex(0.15049130902203478, 0.32239222299087705), Complex(0.6074132024425253, 0.6064197451653933), Complex(-0.3557430640536166, 0.10083048652880117)
        ], rows: 3, columns: 3)
        let solutionS: [Double] = [17.62536292919132, 11.610180169432544, 6.782853237952551]
        let solutionVT: Matrix<Complex<Double>> = .init(elements: [
            Complex(-0.2193007761292906, 0.5060004210000613), Complex(-0.370755675097419, -0.31567672661135066), Complex(-0.5263931112934799, 0.11242515072234302), Complex(0.1460672652128148, 0.384310303136579),
            Complex(0.3070931721780081, 0.30570474704804496), Complex(0.0897733525577063, -0.5724747449633932), Complex(0.18308695699042465, -0.3871008815037035), Complex(0.3757834107155148, -0.38970592083472855),
            Complex(0.5315820786881745, 0.23937282275405583), Complex(0.48895294222998725, 0.28397331311011015), Complex(-0.4661677577500859, -0.2538731897080274), Complex(-0.15355216221960954, 0.18725138645583767),
            Complex(-0.15490184749754704, -0.3797837513071779), Complex(-0.10357983419871584, 0.3108974764804632), Complex(-0.280822158137883, -0.407771863015807), Complex(0.6911732564070941, 0.03904164199100487)
        ], rows: 4, columns: 4)
        #expect(U.isApproximatelyEqual(to: solutionU, absoluteTolerance: 1e-11))
        #expect(zip(S, solutionS).allSatisfy { $0.0.isApproximatelyEqual(to: $0.1, absoluteTolerance: 1e-11) } )
        #expect(VT.isApproximatelyEqual(to: solutionVT, absoluteTolerance: 1e-11))
        var sigma: Matrix<Complex<Double>> = .zeros(rows: U.columns, columns: VT.rows)
        for i in 0..<S.count { sigma[i, i] = .init(S[i]) }
        #expect(U.dot(sigma).dot(VT).isApproximatelyEqual(to: A, absoluteTolerance: 1e-11))
    }
    
    @Test("Complex<Float> matrix svd")
    func matrixSVDComplexFloat() throws {
        let A: Matrix<Complex<Float>> = .init(elements: [
            Complex( 5.91, -5.69), Complex( 7.09,  2.72), Complex(7.78, -4.06), Complex(-0.79, -7.21),
            Complex(-3.15, -4.08), Complex(-1.89,  3.27), Complex(4.57, -2.07), Complex(-3.88, -3.30),
            Complex(-4.89,  4.20), Complex( 4.10, -6.70), Complex(3.28, -3.84), Complex( 3.84,  1.19)
        ], rows: 3, columns: 4)
        let (U, S, VT) = try MatrixOperations.singularValueDecomposition(A: A)
        let solutionU: Matrix<Complex<Float>> = .init(elements: [
            Complex(-0.85675186), Complex(0.40169728), Complex(0.323443),
            Complex(-0.35054702, 0.12848538), Complex(-0.24033095, -0.21020098), Complex(-0.6300696, 0.6013961),
            Complex(0.15049121, 0.3223921), Complex(0.6074132, 0.6064198), Complex(-0.35574296, 0.10083037)
        ], rows: 3, columns: 3)
        let solutionS: [Float] = [17.625364, 11.610177, 6.782853]
        let solutionVT: Matrix<Complex<Float>> = .init(elements: [
            Complex(-0.21930082, 0.50600034), Complex(-0.37075567, -0.3156766), Complex(-0.5263931, 0.11242519), Complex(0.1460672, 0.3843104),
            Complex(0.3070931, 0.30570477), Complex(0.08977315, -0.5724746), Complex(0.18308681, -0.38710088), Complex(0.37578332, -0.38970584),
            Complex(0.53158194, 0.23937275), Complex(0.48895302, 0.28397334), Complex(-0.4661677, -0.25387308), Complex(-0.15355213, 0.1872515),
            Complex(-0.15490186, -0.37978378), Complex(-0.10357984, 0.31089744), Complex(-0.28082213, -0.40777183), Complex(0.69117326, 0.03904165)
        ], rows: 4, columns: 4)
        #expect(U.isApproximatelyEqual(to: solutionU, absoluteTolerance: 1e-7))
        #expect(zip(S, solutionS).allSatisfy { $0.0.isApproximatelyEqual(to: $0.1, absoluteTolerance: 1e-7) } )
        #expect(VT.isApproximatelyEqual(to: solutionVT, absoluteTolerance: 1e-7))
        var sigma: Matrix<Complex<Float>> = .zeros(rows: U.columns, columns: VT.rows)
        for i in 0..<S.count { sigma[i, i] = .init(S[i]) }
        #expect(U.dot(sigma).dot(VT).isApproximatelyEqual(to: A, absoluteTolerance: 1e-2))
    }
}

struct LeastSquaresTests {
    @Test("Double linear least squares")
    func linearLeastSquaresDouble() throws {
        let A: Matrix<Double> = .init(elements: [
            1.44, -7.84, -4.39,  4.53,
           -9.96, -0.28, -3.24,  3.83,
           -7.55, 3.24, 6.27, -6.64,
            8.34, 8.09, 5.28,  2.06,
            7.08, 2.52, 0.74, -2.47,
           -5.45, -5.70, -1.19,  4.70
        ], rows: 6, columns: 4)
        let B: Matrix<Double> = .init(elements: [
            8.58, 9.35,
            8.26, -4.43,
            8.48, -0.70,
           -5.28, -0.26,
            5.72, -7.36,
            8.93, -2.52
        ], rows: 6, columns: 2)
        let (X, _) = try Optimize.linearLeastSquares(A: A, B)
        let solution: Matrix<Double> = .init(elements: [
            -0.45063713541953393, 0.24974799792600108,
             -0.8491502147139957, -0.9020192606489694,
             0.7066121624093955, 0.6323430335981739,
             0.1288857521557785, 0.1351236350329721
        ], rows: 4, columns: 2)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-11))
    }
    
    @Test("Float linear least squares")
    func linearLeastSquaresFloat() throws {
        let A: Matrix<Float> = .init(elements: [
            1.44, -7.84, -4.39,  4.53,
           -9.96, -0.28, -3.24,  3.83,
           -7.55, 3.24, 6.27, -6.64,
            8.34, 8.09, 5.28,  2.06,
            7.08, 2.52, 0.74, -2.47,
           -5.45, -5.70, -1.19,  4.70
        ], rows: 6, columns: 4)
        let B: Matrix<Float> = .init(elements: [
            8.58, 9.35,
            8.26, -4.43,
            8.48, -0.70,
           -5.28, -0.26,
            5.72, -7.36,
            8.93, -2.52
        ], rows: 6, columns: 2)
        let (X, _) = try Optimize.linearLeastSquares(A: A, B)
        let solution: Matrix<Float> = .init(elements: [
            -0.45063713, 0.24974799,
             -0.8491501, -0.90201944,
             0.7066121, 0.6323433,
             0.1288859, 0.13512371
        ], rows: 4, columns: 2)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-7))
    }
    
    @Test("Complex<Double> linear least squares")
    func linearLeastSquaresComplexDouble() throws {
        let A: Matrix<Complex<Double>> = .init(elements: [
            Complex(-4.20, -3.44), Complex(-3.35,  1.52), Complex(1.73, 8.85), Complex( 2.35,  0.34),
            Complex(-5.43, -8.81), Complex(-4.53, -8.47), Complex(5.93, 3.75), Complex(-3.75, -5.66),
            Complex(-5.56,  3.39), Complex( 2.90, -9.22), Complex(8.03, 9.37), Complex( 5.69, -0.47)
        ], rows: 3, columns: 4)
        let B: Matrix<Complex<Double>> = .init(elements: [
            Complex(-7.02,  4.80), Complex( 3.88, -2.59),
            Complex( 0.62, -2.40), Complex( 1.57,  3.24),
            Complex( 3.10, -2.19), Complex(-6.93, -5.99)
        ], rows: 3, columns: 2)
        let (X, _) = try Optimize.linearLeastSquares(A: A, B)
        let solution: Matrix<Complex<Double>> = .init(elements: [
            Complex(-0.24964719719828954, -0.0437146841815137), Complex(-0.20800729067345097, 0.41952048301891176),
            Complex(0.9887361866832274, 0.27120932444568147), Complex(-0.2134967812546669, -0.42799074509965873),
            Complex(0.24785073006523817, 0.43261088872121), Complex(-0.24361576064615406, -0.1270070860133276),
            Complex(-0.31751531913971753, 0.14014621751170547), Complex(-0.22723841361626718, -0.08503410155870482)
        ], rows: 4, columns: 2)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-11))
    }
    
    @Test("Complex<Float> linear least squares")
    func linearLeastSquaresComplexFloat() throws {
        let A: Matrix<Complex<Float>> = .init(elements: [
            Complex(-4.20, -3.44), Complex(-3.35,  1.52), Complex(1.73, 8.85), Complex( 2.35,  0.34),
            Complex(-5.43, -8.81), Complex(-4.53, -8.47), Complex(5.93, 3.75), Complex(-3.75, -5.66),
            Complex(-5.56,  3.39), Complex( 2.90, -9.22), Complex(8.03, 9.37), Complex( 5.69, -0.47)
        ], rows: 3, columns: 4)
        let B: Matrix<Complex<Float>> = .init(elements: [
            Complex(-7.02,  4.80), Complex( 3.88, -2.59),
            Complex( 0.62, -2.40), Complex( 1.57,  3.24),
            Complex( 3.10, -2.19), Complex(-6.93, -5.99)
        ], rows: 3, columns: 2)
        let (X, _) = try Optimize.linearLeastSquares(A: A, B)
        print(X)
        let solution: Matrix<Complex<Float>> = .init(elements: [
            Complex(-0.24964717, -0.043714672), Complex(-0.20800719, 0.41952044),
            Complex(0.9887361, 0.27120933), Complex(-0.21349677, -0.4279907),
            Complex(0.24785082, 0.43261093), Complex(-0.24361572, -0.12700704),
            Complex(-0.31751525, 0.1401463), Complex(-0.22723842, -0.08503409)
        ], rows: 4, columns: 2)
        #expect(X.isApproximatelyEqual(to: solution, absoluteTolerance: 1e-7))
    }
}
