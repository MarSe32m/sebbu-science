//
//  TestUniqueSolvers.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 17.5.2026.
//

import SebbuScience
import Numerics
import PythonKitUtilities

func testUniqueRK4FixedStep() {
    let endTime = 100.0
    var solver = UniqueRK4Solver(t0: 0.0, initialState: 1.0, dt: 0.001)
    var tSpace: [Double] = []
    var y: [Double] = []
    while solver.t < endTime {
        solver.step { t, state, result in
            result = -.sin(t)
        } yielding: { t, state in
            tSpace.append(t)
            y.append(state)
        }
    }
    print(tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: tSpace, y: tSpace.map { .exp(-$0) })
    plt.show()
    plt.close()
}

func testUniqueRK4AdaptiveStep() {
    let endTime = 100.0
    var solver = UniqueDOPRISolver(t0: 0.0, initialState: 1.0, dt: 0.1, maxStep: 0.1)
    var tSpace: [Double] = []
    var y: [Double] = []
    let time = ContinuousClock().measure {
        while solver.t < endTime {
            solver.step { t, state, result in
                result = -.sin(t)
            } yielding: { t, state in
                tSpace.append(t)
                y.append(state)
            }
        }
    }
    
    print(time, tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: .linearSpace(0, endTime, 1000), y: .linearSpace(0, endTime, 1000).map { .exp(-$0) })
    plt.show()
    plt.close()
}

func testUniqueSolverWithCustomState() {
    let endTime = 100.0
    var adaptiveSolver = UniqueDOPRISolver(t0: 0.0, initialState: State(state: 1.0), dt: 0.01, maxStep: 0.01)
    var fixedSolver = UniqueRK4Solver(t0: 0.0, initialState: State(state: 1.0), dt: 0.001)
    var adaptiveTSpace: [Double] = []
    var adaptiveY: [Double] = []
    while adaptiveSolver.t < endTime {
        adaptiveSolver.step { t, state, result in
            result.state = -.sin(100 * t)
        } yielding: { t, state in
            adaptiveTSpace.append(t)
            adaptiveY.append(state.state)
        }
    }
    var fixedTSpace: [Double] = []
    var fixedY: [Double] = []
    while fixedSolver.t < endTime {
        fixedSolver.step { t, state, result in
            result.state = -.sin(100 * t)
        } yielding: { t, state in
            fixedTSpace.append(t)
            fixedY.append(state.state)
        }

    }
    print(adaptiveTSpace.count, fixedTSpace.count)
    plt.figure()
    plt.plot(x: fixedTSpace, y: fixedY)
    plt.plot(x: adaptiveTSpace, y: adaptiveY)
    plt.show()
    plt.close()
}

func testUniqueSRK2SolverWithCustomState() {
    let endTime = 100.0
    var solver = UniqueSRK2Solver<State, Double>(t0: 0.0, initialState: State(state: 1.0), diffusionSpace: .allocate(capacity: 1), noiseSpace: .allocate(capacity: 1), dt: 0.001)
    var tSpace: [Double] = []
    var y: [Double] = []
    while solver.t < endTime {
        solver.step { t, state, result in
            result.state = -.sin(t)
        } _: { t, state, result in
            result[0].state = .zero
        } _: { t, result in
            result[0] = .zero
        } yielding: { t, state in
            tSpace.append(t)
            y.append(state.state)
        }
    }
    print(tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: tSpace, y: tSpace.map { .exp(-$0) })
    plt.show()
    plt.close()
}

private struct State {
    @usableFromInline
    var state: Double
    
    @inlinable
    init(state: Double) {
        self.state = state
    }
}

extension State: UniqueODESolverState {
    @inlinable
    var norm: Double {
        state.magnitude
    }
    
    @inlinable
    mutating func assign(_ a: borrowing State) {
        self.state = a.state
    }
    
    @inlinable
    mutating func assign(_ a: borrowing State, multiplied: Double) {
        self.state = a.state * multiplied
    }
    
    @inlinable
    mutating func add(_ a: borrowing State, multiplied: Double) {
        self.state += a.state * multiplied
    }
    
    @inlinable
    mutating func assign(_ base: borrowing State, adding direction: borrowing State, multipliedBy c: Double) {
        self.state = base.state + direction.state * c
    }
    
    @inlinable
    func distance(to: borrowing State) -> Double {
        (self.state - to.state).magnitude
    }
}

extension State: UniqueSDESolverState {
    mutating func scale(by: Double) {
        state *= by
    }
    
    typealias NoiseType = Double
    
    mutating func add(_ a: borrowing State) {
        state += a.state
    }
    
    mutating func add(_ a: borrowing State, multiplied dtSqrt: Double, noise: borrowing Double) {
        state += a.state * dtSqrt * noise
    }
    
    mutating func assign(_ base: borrowing State, adding direction: borrowing State) {
        state = base.state + direction.state
    }
    
    mutating func assign(_ base: borrowing State, adding direction: borrowing State, multipliedBy dtSqrt: Double, noise: borrowing Double) {
        state = base.state + direction.state * dtSqrt * noise
    }
}
