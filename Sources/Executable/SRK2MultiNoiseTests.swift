//
//  SRK2MultiNoiseTests.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 12.10.2025.
//

import PythonKit
import PythonKitUtilities
import SebbuScience

func testMultiNoiseSRK2() {
    testDouble()
    testDoubleArray()
    testComplex()
    testComplexArray()
    testVectorDouble()
    testVectorDoubleArray()
    testVectorComplex()
    testVectorComplexArray()
    testMatrixDouble()
    testMatrixDoubleArray()
    testMatrixComplex()
    testMatrixComplexArray()
}

private func noiseDouble(tSpace: [Double], deviation: Double = 1.0) -> (Double) -> Double {
    var random = NumPyRandom()
    let samples: [Double] = random.nextNormal(count: tSpace.count)
    let spline = NearestNeighbourInterpolator(x: tSpace, y: samples)
    return { t in deviation * spline.sample(t) }
}

private func noiseComplex(tSpace: [Double], deviation: Double = 1.0) -> (Double) -> Complex<Double> {
    var random = NumPyRandom()
    let samples: [Complex<Double>] = random.nextNormal(count: tSpace.count)
    let spline = NearestNeighbourInterpolator(x: tSpace, y: samples)
    return { t in deviation * spline.sample(t) }
}

private func testDouble() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseDouble(tSpace: tSpace)
    let f: (Double, Double) -> Double = { t, currentState in
        -currentState
    }
    let g: (Double, Double) -> Double = { t, currentState in
        0.0175 * (1 - currentState)
    }
    let g2: (Double, Double) -> Double = { t, currentState in
        0.5 * g(t, currentState)
    }
    let w = noise
    var singleNoiseSolver = SRK2FixedStep(initialState: 1.0, t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: 1.0, t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [Double] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [Double] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution, label: "S")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution, label: "M", linestyle: "--")
    plt.legend()
    plt.title("Double")
    plt.show()
    plt.close()
}

private func testDoubleArray() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseDouble(tSpace: tSpace)
    let f: (Double, [Double]) -> [Double] = { t, currentState in
        [-currentState[0], -0.5 * currentState[1]]
    }
    let g: (Double, [Double]) -> [Double] = { t, currentState in
        [0.0175 * (1 - currentState[0]),
         0.03 * (-1 - currentState[1])]
    }
    let g2: (Double, [Double]) -> [Double] = { t, currentState in
        [0.5 * g(t, currentState)[0],
         0.5 * g(t, currentState)[1]]
    }
    let w = noise
    var singleNoiseSolver =          SRK2FixedStep(initialState: [1.0, 1.0], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [1.0, 1.0], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [[Double]] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [[Double]] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0] }, label: "S[0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1] }, label: "S[1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0] }, label: "M[0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1] }, label: "M[1]", linestyle: "--")
    plt.legend()
    plt.title("[Double]")
    plt.show()
    plt.close()
}

private func testComplex() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseComplex(tSpace: tSpace)
    let f: (Double, Complex<Double>) -> Complex<Double> = { t, currentState in
        -currentState
    }
    let g: (Double, Complex<Double>) -> Complex<Double> = { t, currentState in
        0.0175 * (.one - currentState)
    }
    let g2: (Double, Complex<Double>) -> Complex<Double> = { t, currentState in
        0.5 * g(t, currentState)
    }
    let w = noise
    var singleNoiseSolver = SRK2FixedStep(initialState: .one + 2.0 * .i, t0: .zero, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: .one + 2.0 * .i, t0: .zero, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [Complex<Double>] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [Complex<Double>] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.real, label: "Re S")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.imaginary, label: "Im S")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.real, label: "Re M", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.imaginary, label: "Im M", linestyle: "--")
    plt.legend()
    plt.title("Complex<Double>")
    plt.show()
    plt.close()
}

private func testComplexArray() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseComplex(tSpace: tSpace)
    let f: (Double, [Complex<Double>]) -> [Complex<Double>] = { t, currentState in
        [-currentState[0], -0.5 * currentState[1]]
    }
    let g: (Double, [Complex<Double>]) -> [Complex<Double>] = { t, currentState in
        [0.0175 * (.one - currentState[0]),
         0.03 * (-.one - currentState[1])]
    }
    let g2: (Double, [Complex<Double>]) -> [Complex<Double>] = { t, currentState in
        [0.5 * g(t, currentState)[0],
         0.5 * g(t, currentState)[1]]
    }
    let w = noise
    var singleNoiseSolver = SRK2FixedStep(initialState: [.one + 2.0 * .i, .one - 2.0 * .i], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [.one + 2.0 * .i, .one - 2.0 * .i], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [[Complex<Double>]] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [[Complex<Double>]] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0].real }, label: "Re S[0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1].real }, label: "Re S[1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0].imaginary }, label: "Im S[0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1].imaginary }, label: "Im S[1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0].real }, label: "Re M[0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1].real }, label: "Re M[1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0].imaginary }, label: "Im M[0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1].imaginary }, label: "Im M[1]", linestyle: "--")
    plt.legend()
    plt.title("[Complex<Double>]")
    plt.show()
    plt.close()
}

private func testVectorDouble() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseDouble(tSpace: tSpace)
    let H: Matrix<Double> = .init(elements: [0.0, -1.0, -1.0, 0.0], rows: 2, columns: 2)
    let S: Matrix<Double> = .init(elements: [0.0, 1.0, 0.0, 0.0], rows: 2, columns: 2)
    let f: (Double, Vector<Double>) -> Vector<Double> = { t, x in
        H.dot(x)
    }
    let g: (Double, Vector<Double>) -> Vector<Double> = { t, x in
        S.dot(x)
    }
    let g2: (Double, Vector<Double>) -> Vector<Double> = { t, x in
        0.5 * g(t, x)
    }
    let w = noise
    
    var singleNoiseSolver = SRK2FixedStep(initialState: [0.5, 0.5], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [0.5, 0.5], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [Vector<Double>] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [Vector<Double>] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0] }, label: "S[0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1] }, label: "S[1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0] }, label: "M[0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1] }, label: "M[1]", linestyle: "--")
    plt.legend()
    plt.title("Vector<Double>")
    plt.show()
    plt.close()
}

private func testVectorDoubleArray() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseDouble(tSpace: tSpace)
    let H: Matrix<Double> = .init(elements: [0.0, -1.0, -1.0, 0.0], rows: 2, columns: 2)
    let S: Matrix<Double> = .init(elements: [0.0, 1.0, 0.0, 0.0], rows: 2, columns: 2)
    let f: (Double, [Vector<Double>]) -> [Vector<Double>] = { t, x in
        [H.dot(x[0]), H.dot(-1.0 * x[1])]
    }
    let g: (Double, [Vector<Double>]) -> [Vector<Double>] = { t, x in
        [S.dot(x[0]), S.transpose.dot(x[1])]
    }
    let g2: (Double, [Vector<Double>]) -> [Vector<Double>] = { t, x in
        [0.5 * g(t, x)[0], 0.5 * g(t, x)[1]]
    }
    let w = noise
    
    var singleNoiseSolver = SRK2FixedStep(initialState: [[0.5, 0.5], [0.5, 0.5]], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [[0.5, 0.5], [0.5, 0.5]], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [[Vector<Double>]] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [[Vector<Double>]] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0] }, label: "S[0][0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1] }, label: "S[0][1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0] }, label: "S[1][0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1] }, label: "S[1][1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0] }, label: "M[0][0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1] }, label: "M[0][1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0] }, label: "M[1][0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1] }, label: "M[1][1]", linestyle: "--")
    plt.legend()
    plt.title("[Vector<Double>]")
    plt.show()
    plt.close()
}

private func testVectorComplex() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseComplex(tSpace: tSpace)
    let H: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .one, .zero], rows: 2, columns: 2)
    let S: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .zero, .zero], rows: 2, columns: 2)
    let f: (Double, Vector<Complex<Double>>) -> Vector<Complex<Double>> = { t, x in
        -.i * H.dot(x)
    }
    let g: (Double, Vector<Complex<Double>>) -> Vector<Complex<Double>> = { t, x in
        S.dot(x)
    }
    let g2: (Double, Vector<Complex<Double>>) -> Vector<Complex<Double>> = { t, x in
        0.5 * g(t, x)
    }
    let w = noise
    
    var singleNoiseSolver = SRK2FixedStep(initialState: [Complex(0.5), Complex(0.5)], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [Complex(0.5), Complex(0.5)], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [Vector<Complex<Double>>] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [Vector<Complex<Double>>] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0].real }, label: "Re S[0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0].imaginary }, label: "Im S[0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1].real }, label: "Re S[1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1].imaginary }, label: "Im S[1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0].real }, label: "Re M[0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0].imaginary }, label: "Im M[0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1].real }, label: "Re M[1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1].imaginary }, label: "Im M[1]", linestyle: "--")
    plt.legend()
    plt.title("Vector<Complex<Double>>")
    plt.show()
    plt.close()
}
    
private func testVectorComplexArray() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseComplex(tSpace: tSpace)
    let H: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .one, .zero], rows: 2, columns: 2)
    let S: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .zero, .zero], rows: 2, columns: 2)
    let f: (Double, [Vector<Complex<Double>>]) -> [Vector<Complex<Double>>] = { t, x in
        [-.i * H.dot(x[0]), .i * H.dot(x[1])]
    }
    let g: (Double, [Vector<Complex<Double>>]) -> [Vector<Complex<Double>>] = { t, x in
        [S.dot(x[0]), S.conjugateTranspose.dot(x[1])]
    }
    let g2: (Double, [Vector<Complex<Double>>]) -> [Vector<Complex<Double>>] = { t, x in
        [0.5 * g(t, x)[0], 0.5 * g(t, x)[1]]
    }
    let w = noise
    
    var singleNoiseSolver = SRK2FixedStep(initialState: [[Complex(0.5), Complex(0.5)], [Complex(0.5), Complex(0.5)]], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [[Complex(0.5), Complex(0.5)], [Complex(0.5), Complex(0.5)]], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [[Vector<Complex<Double>>]] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [[Vector<Complex<Double>>]] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0].real }, label: "Re S[0][0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0].imaginary }, label: "Im S[0][0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1].real }, label: "Re S[0][1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1].imaginary }, label: "Im S[0][1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0].real }, label: "Re M[0][0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0].imaginary }, label: "Im M[0][0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1].real }, label: "Re M[0][1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1].imaginary }, label: "Im M[0][1]", linestyle: "--")
    plt.legend()
    plt.title("[Vector<Complex<Double>>][0]")
    plt.show()
    plt.close()
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0].real }, label: "Re S[1][0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0].imaginary }, label: "Im S[1][0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1].real }, label: "Re S[1][1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1].imaginary }, label: "Im S[1][1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0].real }, label: "Re M[1][0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0].imaginary }, label: "Im M[1][0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1].real }, label: "Re M[1][1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1].imaginary }, label: "Im M[1][1]", linestyle: "--")
    plt.legend()
    plt.title("[Vector<Complex<Double>>][1]")
    plt.show()
    plt.close()
}

private func testMatrixDouble() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseDouble(tSpace: tSpace)
    let H: Matrix<Double> = .init(elements: [0.0, -1.0, -1.0, 0.0], rows: 2, columns: 2)
    let S: Matrix<Double> = .init(elements: [0.0, 1.0, 0.0, 0.0], rows: 2, columns: 2)
    let f: (Double, Matrix<Double>) -> Matrix<Double> = { t, x in
        H.dot(x) - x.dot(H)
    }
    let g: (Double, Matrix<Double>) -> Matrix<Double> = { t, x in
        S.dot(x) - x.dot(S)
    }
    let g2: (Double, Matrix<Double>) -> Matrix<Double> = { t, x in
        0.5 * g(t, x)
    }
    let w = noise
    let initialState = Matrix(elements: [0.0, 1.0, 1.0, 0.0], rows: 2, columns: 2)
    var singleNoiseSolver = SRK2FixedStep(initialState: initialState, t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: initialState, t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [Matrix<Double>] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [Matrix<Double>] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0, 0] }, label: "S[0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0, 1] }, label: "S[0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1, 0] }, label: "S[1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1, 1] }, label: "S[1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0, 0] }, label: "M[0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0, 1] }, label: "M[0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1, 0] }, label: "M[1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1, 1] }, label: "M[0, 1]", linestyle: "--")
    plt.legend()
    plt.title("Matrix<Double>")
    plt.show()
    plt.close()
}

private func testMatrixDoubleArray() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseDouble(tSpace: tSpace)
    let H: Matrix<Double> = .init(elements: [0.0, -1.0, -1.0, 0.0], rows: 2, columns: 2)
    let S: Matrix<Double> = .init(elements: [0.0, 1.0, 0.0, 0.0], rows: 2, columns: 2)
    let f: (Double, [Matrix<Double>]) -> [Matrix<Double>] = { t, x in
        [H.dot(x[0]) - x[0].dot(H),
         H.dot(x[1]) - x[1].dot(H)]
    }
    let g: (Double, [Matrix<Double>]) -> [Matrix<Double>] = { t, x in
        [S.dot(x[0]) - x[0].dot(S),
         x[1].dot(S) - S.dot(x[1])]
    }
    let g2: (Double, [Matrix<Double>]) -> [Matrix<Double>] = { t, x in
        [0.5 * g(t, x)[0],
         0.5 * g(t, x)[1]]
    }
    let w = noise
    let initialState = Matrix(elements: [0.0, 1.0, 1.0, 0.0], rows: 2, columns: 2)
    var singleNoiseSolver = SRK2FixedStep(initialState: [initialState, initialState], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [initialState, initialState], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [[Matrix<Double>]] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [[Matrix<Double>]] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0, 0] }, label: "S[0][0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0, 1] }, label: "S[0][0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1, 0] }, label: "S[0][1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1, 1] }, label: "S[0][1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0, 0] }, label: "M[0][0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0, 1] }, label: "M[0][0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1, 0] }, label: "M[0][1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1, 1] }, label: "M[0][0, 1]", linestyle: "--")
    plt.legend()
    plt.title("[Matrix<Double>][0]")
    plt.show()
    plt.close()
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0, 0] }, label: "S[1][0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0, 1] }, label: "S[1][0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1, 0] }, label: "S[1][1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1, 1] }, label: "S[1][1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0, 0] }, label: "M[1][0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0, 1] }, label: "M[1][0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1, 0] }, label: "M[1][1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1, 1] }, label: "M[1][0, 1]", linestyle: "--")
    plt.legend()
    plt.title("[Matrix<Double>][1]")
    plt.show()
    plt.close()
}

private func testMatrixComplex() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseComplex(tSpace: tSpace)
    let H: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .one, .zero], rows: 2, columns: 2)
    let S: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .zero, .zero], rows: 2, columns: 2)
    let f: (Double, Matrix<Complex<Double>>) -> Matrix<Complex<Double>> = { t, x in
        -.i * (H.dot(x) - x.dot(H))
    }
    let g: (Double, Matrix<Complex<Double>>) -> Matrix<Complex<Double>> = { t, x in
        S.dot(x.dot(S.conjugateTranspose))
    }
    let g2: (Double, Matrix<Complex<Double>>) -> Matrix<Complex<Double>> = { t, x in
        0.5 * g(t, x)
    }
    let w = noise
    let initialState = Matrix(elements: [Complex(0.5), .zero, .zero, Complex(0.5)], rows: 2, columns: 2)
    var singleNoiseSolver = SRK2FixedStep(initialState: initialState, t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: initialState, t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [Matrix<Complex<Double>>] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [Matrix<Complex<Double>>] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0, 0].real }, label: "Re S[0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0, 1].real }, label: "Re S[0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1, 0].real }, label: "Re S[1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1, 1].real }, label: "Re S[1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0, 0].real }, label: "Re M[0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0, 1].real }, label: "Re M[0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1, 0].real }, label: "Re M[1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1, 1].real }, label: "Re M[0, 1]", linestyle: "--")
    plt.legend()
    plt.title("Matrix<Complex<Double>>")
    plt.show()
    plt.close()
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0, 0].imaginary }, label: "Im S[0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0, 1].imaginary }, label: "Im S[0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1, 0].imaginary }, label: "Im S[1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1, 1].imaginary }, label: "Im S[1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0, 0].imaginary }, label: "Im M[0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0, 1].imaginary }, label: "Im M[0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1, 0].imaginary }, label: "Im M[1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1, 1].imaginary }, label: "Im M[0, 1]", linestyle: "--")
    plt.legend()
    plt.title("Matrix<Complex<Double>>")
    plt.show()
    plt.close()
}

private func testMatrixComplexArray() {
    let dt = 0.001
    let tMax = 10.0
    let tSpace = [Double].linearSpace(0, tMax, dt)
    let noise = noiseComplex(tSpace: tSpace)
    let H: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .one, .zero], rows: 2, columns: 2)
    let S: Matrix<Complex<Double>> = .init(elements: [.zero, .one, .zero, .zero], rows: 2, columns: 2)
    let f: (Double, [Matrix<Complex<Double>>]) -> [Matrix<Complex<Double>>] = { t, x in
        [-.i * (H.dot(x[0]) - x[0].dot(H)),
          -.i * (H.dot(x[1]) - x[1].dot(H))]
    }
    let g: (Double, [Matrix<Complex<Double>>]) -> [Matrix<Complex<Double>>] = { t, x in
        [S.dot(x[0].dot(S.conjugateTranspose)),
         S.conjugateTranspose.dot(x[1].dot(S))]
    }
    let g2: (Double, [Matrix<Complex<Double>>]) -> [Matrix<Complex<Double>>] = { t, x in
        [0.5 * g(t, x)[0],
         0.5 * g(t, x)[1]]
    }
    let w = noise
    let initialState = Matrix(elements: [Complex(0.5), .zero, .zero, Complex(0.5)], rows: 2, columns: 2)
    var singleNoiseSolver = SRK2FixedStep(initialState: [initialState, initialState], t0: 0.0, dt: dt, f: f, g: g, w: w)
    var multiNoiseSolver = SRK2FixedStepMultiNoise(initialState: [initialState, initialState], t0: 0.0, dt: dt, f: f, g: [g2, g2], w: [w, w])
    
    var singleNoiseTSpace: [Double] = []
    var singleNoiseSolution: [[Matrix<Complex<Double>>]] = []
    while singleNoiseSolver.t <= tMax {
        let (t, state) = singleNoiseSolver.step()
        singleNoiseTSpace.append(t)
        singleNoiseSolution.append(state)
    }
    
    var multiNoiseTSpace: [Double] = []
    var multiNoiseSolution: [[Matrix<Complex<Double>>]] = []
    while multiNoiseSolver.t <= tMax {
        let (t, state) = multiNoiseSolver.step()
        multiNoiseTSpace.append(t)
        multiNoiseSolution.append(state)
    }
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0, 0].real }, label: "Re S[0][0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0, 1].real }, label: "Re S[0][0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1, 0].real }, label: "Re S[0][1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1, 1].real }, label: "Re S[0][1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0, 0].real }, label: "Re M[0][0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0, 1].real }, label: "Re M[0][0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1, 0].real }, label: "Re M[0][1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1, 1].real }, label: "Re M[0][0, 1]", linestyle: "--")
    plt.legend()
    plt.title("[Matrix<Complex<Double>>]")
    plt.show()
    plt.close()
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0, 0].imaginary }, label: "Im S[0][0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][0, 1].imaginary }, label: "Im S[0][0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1, 0].imaginary }, label: "Im S[0][1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[0][1, 1].imaginary }, label: "Im S[0][1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0, 0].imaginary }, label: "Im M[0][0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][0, 1].imaginary }, label: "Im M[0][0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1, 0].imaginary }, label: "Im M[0][1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[0][1, 1].imaginary }, label: "Im M[0][0, 1]", linestyle: "--")
    plt.legend()
    plt.title("[Matrix<Complex<Double>>]")
    plt.show()
    plt.close()
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0, 0].real }, label: "Re S[1][0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0, 1].real }, label: "Re S[1][0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1, 0].real }, label: "Re S[1][1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1, 1].real }, label: "Re S[1][1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0, 0].real }, label: "Re M[1][0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0, 1].real }, label: "Re M[1][0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1, 0].real }, label: "Re M[1][1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1, 1].real }, label: "Re M[1][0, 1]", linestyle: "--")
    plt.legend()
    plt.title("[Matrix<Complex<Double>>]")
    plt.show()
    plt.close()
    
    plt.figure()
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0, 0].imaginary }, label: "Im S[1][0, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][0, 1].imaginary }, label: "Im S[1][0, 1]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1, 0].imaginary }, label: "Im S[1][1, 0]")
    plt.plot(x: singleNoiseTSpace, y: singleNoiseSolution.map { $0[1][1, 1].imaginary }, label: "Im S[1][1, 1]")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0, 0].imaginary }, label: "Im M[1][0, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][0, 1].imaginary }, label: "Im M[1][0, 1]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1, 0].imaginary }, label: "Im M[1][1, 0]", linestyle: "--")
    plt.plot(x: multiNoiseTSpace, y: multiNoiseSolution.map { $0[1][1, 1].imaginary }, label: "Im M[1][0, 1]", linestyle: "--")
    plt.legend()
    plt.title("[Matrix<Complex<Double>>]")
    plt.show()
    plt.close()
}
