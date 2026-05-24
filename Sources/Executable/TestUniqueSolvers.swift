//
//  TestUniqueSolvers.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 17.5.2026.
//

import SebbuScience
import Numerics
import PythonKitUtilities


@usableFromInline
struct DecayingRHS: ODERHSFunction {
    @inlinable
    init() {}
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
    
    @inlinable
    public var norm: Double {
        magnitude
    }
    
    @inlinable
    public mutating func assign(_ a: borrowing Double) {
        self = Double(a)
    }
    
    @inlinable
    public mutating func assign(_ a: borrowing Double, multiplied: Double) {
        self = a * multiplied
    }
    
}

@inlinable
func testUniqueRK4FixedStep() {
    let endTime = 100.0
    let dt = 0.01
    var solver = UniqueRK4Solver(t: 0.0, dt: dt, rhs: DecayingRHS(), k1: 0.0, k2: 0.0, k3: 0.0, k4: 0.0, temporary: 0.0)
    var currentState = 1.0
    let samples = Int(endTime / dt) + 1
    var tSpace: [Double] = [0.0]
    var y: [Double] = [currentState]
    tSpace.append(addingCapacity: samples) { tSpan in
        y.append(addingCapacity: samples) { ySpan in
            while solver.t < endTime {
                let t = solver.step(y: &currentState)
                tSpan.append(t)
                ySpan.append(currentState)
            }
        }
    }
    
    if y.last == 0.1 { print("Failed?") }
    print(tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: tSpace, y: tSpace.map { .exp(-$0) })
    plt.show()
    plt.close()
}

@inlinable
func testUniqueRK4AdaptiveStep() {
    let endTime = 100.0
    let dt = 0.001
    var solver = UniqueDOPRISolver(t: 0.0, dt: dt, maxStep: 0.1, rhs: DecayingRHS(), y4: 0.0, k1: 0.0, k2: 0.0, k3: 0.0, k4: 0.0, k5: 0.0, k6: 0.0, k7: 0.0, temporary: 0.0)
    var currentState = 1.0
    let samples = Int(endTime / dt) + 1
    var tSpace: [Double] = [0.0]
    var y: [Double] = [currentState]
    tSpace.append(addingCapacity: samples) { tSpan in
        y.append(addingCapacity: samples) { ySpan in
            while solver.t < endTime {
                let t = solver.step(y: &currentState)
                tSpan.append(t)
                ySpan.append(currentState)
            }
        }
    }
    
    if y.last == 0.1 { print("Failed?") }
    print(tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: .linearSpace(0, endTime, 1000), y: .linearSpace(0, endTime, 1000).map { .exp(-$0) })
    plt.show()
    plt.close()
}

@inlinable
func testUniqueSolverWithCustomState() {
    let endTime = 100.0
    var adaptiveSolver = UniqueDOPRISolver(t: 0.0, dt: 0.01, maxStep: 0.01, rhs: DecayingStateFunc(), y4: .init(state: 0.0), k1: .init(state: 0.0), k2: .init(state: 0.0), k3: .init(state: 0.0), k4: .init(state: 0.0), k5: .init(state: 0.0), k6: .init(state: 0.0), k7: .init(state: 0.0), temporary: .init(state: 0.0))
    var fixedSolver = UniqueRK4Solver(t: 0.0, dt: 0.01, rhs: DecayingStateFunc(), k1: .init(state: 0.0), k2: .init(state: 0.0), k3: .init(state: 0.0), k4: .init(state: 0.0), temporary: .init(state: 0.0))
    var y5: State = .init(state: 1.0)
    var adaptiveTSpace: [Double] = [0.0]
    var adaptiveY: [Double] = [y5.state]
    while adaptiveSolver.t < endTime {
        let t = adaptiveSolver.step(y: &y5)
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
    if adaptiveY.last == 0.1 { print("Failed?") }
    if fixedY.last == 0.1 { print("Failed?") }
    print(adaptiveTSpace.count, fixedTSpace.count)
    plt.figure()
    plt.plot(x: fixedTSpace, y: fixedY)
    plt.plot(x: adaptiveTSpace, y: adaptiveY, linestyle: "--")
    plt.show()
    plt.close()
}

@inlinable
func testUniqueSRK2SolverWithCustomState() {
    let endTime = 100.0
    let dt = 0.01
    var noises: [Double] = []
    let span = noises.mutableSpan
    var solver = UniqueSRK2Solver(t: 0.0, dt: dt, rhs: DecayingSDEFunc(), drift0: .init(state: 0.0), drift1: .init(state: 0.0), noise0: .init(state: 0.0), noise1: .init(state: 0.0), temporary: .init(state: 0.0), noises: span)
    var state: State = .init(state: 1.0)
    let samples = Int(endTime / dt) + 1
    var tSpace: [Double] = [0.0]
    var y: [Double] = [state.state]
    tSpace.append(addingCapacity: samples) { tSpan in
        y.append(addingCapacity: samples) { ySpan in
            while solver.t < endTime {
                let t = solver.step(y: &state)
                tSpan.append(t)
                ySpan.append(state.state)
            }
        }
    }
    if y.last == 0.1 { print("Failed?") }
    print(tSpace.count)
    plt.figure()
    plt.plot(x: tSpace, y: y)
    //plt.plot(x: tSpace, y: tSpace.map { .exp(-$0) })
    plt.show()
    plt.close()
}

@usableFromInline
struct DecayingStateFunc: ODERHSFunction {
    @inlinable
    init() {}
    @inlinable
    func evaluate(t: Double, y: borrowing State, dy: inout State) {
        dy.state = -.sin(t)
    }
}

@usableFromInline
struct DecayingSDEFunc: SDERHSFunction {
    @inlinable
    init() {}
    
    @usableFromInline
    typealias NoiseType = Double
    @inlinable
    func drift(t: Double, y: borrowing State, into dy: inout State) {
        dy.state = -.sin(t)
    }
    
    @inlinable
    func diffusion(t: Double, y: borrowing State, channel: Int, into dy: inout State) {
        dy.state = .zero
    }
    
    @inlinable
    func sampleWhiteNoise(t: Double, noises: inout MutableSpan<NoiseType>) {
        for i in noises.indices {
            noises[unchecked: i] = .zero
        }
    }
}

@usableFromInline
struct State: ~Copyable {
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
    @inlinable
    mutating func zero() {
        state = .zero
    }
    
    @inlinable
    mutating func scale(by: Double) {
        state *= by
    }
    
    @usableFromInline
    typealias NoiseType = Double
    
    @inlinable
    mutating func add(_ a: borrowing State) {
        state += a.state
    }
    
    @inlinable
    mutating func add(_ a: borrowing State, multiplied dtSqrt: Double, noise: borrowing Double) {
        state += a.state * dtSqrt * noise
    }
    
    @inlinable
    mutating func assign(_ base: borrowing State, adding direction: borrowing State) {
        state = base.state + direction.state
    }
    
    @inlinable
    mutating func assign(_ base: borrowing State, adding direction: borrowing State, multipliedBy dtSqrt: Double, noise: borrowing Double) {
        state = base.state + direction.state * dtSqrt * noise
    }
}
