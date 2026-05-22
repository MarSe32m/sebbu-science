//
//  TestUniqueSolvers.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 17.5.2026.
//

import SebbuScience
import Numerics
import PythonKitUtilities

struct DecayingRHS: ODERHSFunction {
    @inlinable
    func evaluate(t: Double, y: borrowing Double, dy: inout Double) {
        dy = -y
    }
}

extension Double: FixedStepODESolverState {
    @inlinable
    public mutating func add(_ a: borrowing Double, multiplied: Double) {
        self += a * multiplied
    }
    
    @inlinable
    public mutating func assign(_ base: borrowing Double, adding direction: borrowing Double, multipliedBy c: Double) {
        self = base + direction * c
    }
}

extension Double: AdaptiveStepODESolverState {
    public var norm: Double {
        magnitude
    }
    
    public mutating func assign(_ a: borrowing Double) {
        self = Double(a)
    }
    
    public mutating func assign(_ a: borrowing Double, multiplied: Double) {
        self = a * multiplied
    }
    
}

func testUniqueRK4FixedStep() {
    let endTime = 100.0
    var solver = UniqueRK4Solver(t: 0.0, dt: 0.01, rhs: DecayingRHS(), k1: 0.0, k2: 0.0, k3: 0.0, k4: 0.0, temporary: 0.0)
    var currentState = 1.0
    var tSpace: [Double] = [0.0]
    var y: [Double] = [currentState]
    while solver.t < endTime {
        let t = solver.step(y: &currentState)
        tSpace.append(t)
        y.append(currentState)
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
    var solver = UniqueDOPRISolver(t: 0.0, dt: 0.1, maxStep: 0.1, rhs: DecayingRHS(), y4: 0.0, k1: 0.0, k2: 0.0, k3: 0.0, k4: 0.0, k5: 0.0, k6: 0.0, k7: 0.0, temporary: 0.0)
    var currentState = 1.0
    var tSpace: [Double] = [0.0]
    var y: [Double] = [currentState]
    let time = ContinuousClock().measure {
        while solver.t < endTime {
            let t = solver.step(y5: &currentState)
            tSpace.append(t)
            y.append(currentState)
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
    var adaptiveSolver = UniqueDOPRISolver(t: 0.0, dt: 0.01, maxStep: 0.01, rhs: DecayingStateFunc(), y4: .init(state: 0.0), k1: .init(state: 0.0), k2: .init(state: 0.0), k3: .init(state: 0.0), k4: .init(state: 0.0), k5: .init(state: 0.0), k6: .init(state: 0.0), k7: .init(state: 0.0), temporary: .init(state: 0.0))
    var fixedSolver = UniqueRK4Solver(t: 0.0, dt: 0.001, rhs: DecayingStateFunc(), k1: .init(state: 0.0), k2: .init(state: 0.0), k3: .init(state: 0.0), k4: .init(state: 0.0), temporary: .init(state: 0.0))
    var y5: State = .init(state: 1.0)
    var adaptiveTSpace: [Double] = [0.0]
    var adaptiveY: [Double] = [y5.state]
    while adaptiveSolver.t < endTime {
        let t = adaptiveSolver.step(y5: &y5)
        adaptiveTSpace.append(t)
        adaptiveY.append(y5.state)
    }
    var y: State = .init(state: 1.0)
    var fixedTSpace: [Double] = []
    var fixedY: [Double] = []
    while fixedSolver.t < endTime {
        let t = fixedSolver.step(y: &y)
        fixedTSpace.append(t)
        fixedY.append(y.state)
    }
    print(adaptiveTSpace.count, fixedTSpace.count)
    plt.figure()
    plt.plot(x: fixedTSpace, y: fixedY)
    plt.plot(x: adaptiveTSpace, y: adaptiveY, linestyle: "--")
    plt.show()
    plt.close()
}

func testUniqueSRK2SolverWithCustomState() {
    let endTime = 100.0
    var noises: [Double] = []
    let span = noises.mutableSpan
    var solver = UniqueSRK2Solver(t: 0.0, dt: 0.001, rhs: DecayingSDEFunc(), drift0: .init(state: 0.0), drift1: .init(state: 0.0), noise0: .init(state: 0.0), noise1: .init(state: 0.0), temporary: .init(state: 0.0), noises: span)
    var state: State = .init(state: 1.0)
    var tSpace: [Double] = [0.0]
    var y: [Double] = [state.state]
    while solver.t < endTime {
        let t = solver.step(y: &state)
        tSpace.append(t)
        y.append(state.state)
    }
    print(tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: tSpace, y: tSpace.map { .exp(-$0) })
    plt.show()
    plt.close()
}

struct DecayingStateFunc: ODERHSFunction {
    func evaluate(t: Double, y: borrowing State, dy: inout State) {
        dy.state = -.sin(t)
    }
}

struct DecayingSDEFunc: SDERHSFunction {
    typealias NoiseType = Double
    func drift(t: Double, y: borrowing State, into dy: inout State) {
        dy.state = -.sin(t)
    }
    
    func diffusion(t: Double, y: borrowing State, channel: Int, into dy: inout State) {
        dy.state = .zero
    }
    
    func sampleWhiteNoise(t: Double, noises: inout MutableSpan<NoiseType>) {
        for i in noises.indices {
            noises[unchecked: i] = .zero
        }
    }
}

struct State {
    @usableFromInline
    var state: Double
    
    @inlinable
    init(state: Double) {
        self.state = state
    }
}

extension State: AdaptiveStepODESolverState {
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

extension State: FixedStepSDESolverState {
    mutating func zero() {
        state = .zero
    }
    
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
