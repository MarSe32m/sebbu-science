//
//  Trapezoid.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import Dispatch
import Numerics
import SebbuCollections
@preconcurrency import Algorithms


public enum Trapezoid {
    //MARK: Double integration
    @inlinable
    public static func integrate(y: [Double], x: [Double]) -> Double {
        if y.count <= 1 { return .zero }
        precondition(x.count == y.count, "The x-axis must match with the y-axis")
        var result: Double = 0
        for i in 1..<y.count {
            let dx = x[i] - x[i - 1]
            let halfDx = Relaxed.product(0.5, dx)
            // result += (y[i - 1] + y[i]) * 0.5 * dx
            result = Relaxed.multiplyAdd(y[i - 1], halfDx, result)
            result = Relaxed.multiplyAdd(y[i], halfDx, result)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: (Double) -> Double, x: [Double]) -> Double {
        if x.count <= 1 { return .zero }
        var result: Double = .zero
        var lastY = y(x[0])
        for i in 1..<x.count {
            let xi = x[i]
            let xi1 = x[i - 1]
            let halfDx = Relaxed.product(0.5, Relaxed.sum(xi, -xi1))
            let yi = y(xi)
            // result += 0.5 * dx * (lastY + yi)
            result = Relaxed.multiplyAdd(lastY, halfDx, result)
            result = Relaxed.multiplyAdd(yi, halfDx, result)
            lastY = yi
        }
        return result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Double], x: [Double]) -> [Double] {
        if y.count <= 1 { return [.zero] }
        precondition(y.count == x.count, "The x-axis must match with the y-axis")
        var result: [Double] = [Double](repeating: .zero, count: y.count)
        for i in 1..<y.count {
            let dx = Relaxed.product(0.5, Relaxed.sum(x[i], -x[i - 1]))
            result[i] = Relaxed.multiplyAdd(dx, y[i - 1], result[i - 1])
            result[i] = Relaxed.multiplyAdd(dx, y[i], result[i])
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: [Double], dx: Double) -> Double {
        if y.count <= 1 || dx == .zero { return 0 }
        if y.count == 2 { return dx * (y.first! + y.last!) / 2 }
        var result: Double = (y.first! + y.last!) / 2
        for i in 1..<y.count - 1 {
            result = Relaxed.sum(result, y[i])
        }
        return result * dx
    }
    
    @inlinable
    public static func integrateCumulative(y: [Double], dx: Double) -> [Double] {
        if y.count <= 1 { return [.zero] }
        var result: [Double] = [Double](repeating: .zero, count: y.count)
        let dx = 0.5 * dx
        for i in 1..<y.count {
            result[i] = Relaxed.multiplyAdd(y[i - 1], dx, result[i - 1])
            result[i] = Relaxed.multiplyAdd(y[i], dx, result[i])
        }
        return result
    }
    
    @inlinable
    public static func movingAverage(y: [Double], dx: Double, halfWindowSize: Int) -> [Double] {
        if halfWindowSize == 0 || y.count <= 1 { return y }
        var result: [Double] = .init(repeating: .zero, count: y.count)
        for i in 0..<y.count {
            let start = max(i - halfWindowSize, 0)
            let end = min(i + halfWindowSize, y.count - 1)
            
            var trapezoidSum = 0.0
            for j in start...end {
                let weight = (j == start || j == end) ? 0.5 : 1.0
                trapezoidSum = Relaxed.multiplyAdd(weight, y[j], trapezoidSum)
            }
            
            let average = trapezoidSum / Double(end - start)
            result[i] = average
        }
        
        return result
    }
    
    //MARK: Complex<Double> integration
    @inlinable
    public static func integrate(y: [Complex<Double>], x: [Double]) -> Complex<Double> {
        if y.count <= 1 { return .zero }
        precondition(x.count == y.count, "The x-axis must match with the y-axis")
        var result: Complex<Double> = .zero
        for i in 1..<y.count {
            let dx = Relaxed.product(0.5, Relaxed.sum(x[i], -x[i - 1]))
            result = Relaxed.multiplyAdd(dx, y[i - 1], result)
            result = Relaxed.multiplyAdd(dx, y[i], result)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: (Double) -> Complex<Double>, x: [Double]) -> Complex<Double> {
        if x.count <= 1 { return .zero }
        var result: Complex<Double> = .zero
        var lastY = y(x[0])
        for i in 1..<x.count {
            let xi = x[i]
            let xi1 = x[i - 1]
            let dx = Relaxed.product(0.5, Relaxed.sum(xi, -xi1))
            let yi = y(xi)
            result = Relaxed.multiplyAdd(dx, lastY, result)
            result = Relaxed.multiplyAdd(dx, yi, result)
            lastY = yi
        }
        return result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Complex<Double>], x: [Double]) -> [Complex<Double>] {
        if y.count <= 1 { return [.zero] }
        precondition(y.count == x.count, "The x-axis must match with the y-axis")
        var result: [Complex<Double>] = [Complex<Double>](repeating: .zero, count: y.count)
        for i in 1..<y.count {
            let dx = Relaxed.product(0.5, Relaxed.sum(x[i], -x[i - 1]))
            result[i] = Relaxed.multiplyAdd(dx, y[i - 1], result[i - 1])
            result[i] = Relaxed.multiplyAdd(dx, y[i], result[i])
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: [Complex<Double>], dx: Double) -> Complex<Double> {
        if y.count <= 1 { return .zero }
        if y.count == 2 { return 0.5 * dx * (y.first! + y.last!)}
        var result: Complex<Double> = 0.5 * (y.first! + y.last!)
        for i in 1..<y.count - 1 {
            result = Relaxed.sum(result, y[i])
        }
        return dx * result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Complex<Double>], dx: Double) -> [Complex<Double>] {
        if y.count <= 1 { return [.zero] }
        var result: [Complex<Double>] = [Complex<Double>](repeating: .zero, count: y.count)
        let dx = Relaxed.product(0.5, dx)
        for i in 1..<y.count {
            result[i] = Relaxed.multiplyAdd(dx, y[i - 1], result[i - 1])
            result[i] = Relaxed.multiplyAdd(dx, y[i], result[i])
        }
        return result
    }
    
    @inlinable
    public static func movingAverage(y: [Complex<Double>], dx: Double, halfWindowSize: Int) -> [Complex<Double>] {
        if halfWindowSize == 0 || y.count <= 1 { return y }
        var result: [Complex<Double>] = .init(repeating: .zero, count: y.count)
        for i in 0..<y.count {
            let start = max(i - halfWindowSize, 0)
            let end = min(i + halfWindowSize, y.count - 1)
            
            var trapezoidSum: Complex<Double> = .zero
            for j in start...end {
                let weight = (j == start || j == end) ? 0.5 : 1.0
                trapezoidSum = Relaxed.multiplyAdd(weight, y[j], trapezoidSum)
            }
            
            let average = trapezoidSum / Double(end - start)
            result[i] = average
        }
        
        return result
    }
    
    //MARK: Vector<Double> integration
    @inlinable
    public static func integrate(y: [Vector<Double>], x: [Double]) -> Vector<Double> {
        if y.isEmpty { return Vector([]) }
        if y.count == 1 { return .zero(y[0].components.count) }
        precondition(x.count == y.count, "The x-axis must match with the y-axis")
        var result: Vector<Double> = Vector(.init(repeating: .zero, count: y[0].components.count))
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result.add(y[i - 1], scaling: dx)
            result.add(y[i], scaling: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: (Double) -> Vector<Double>, x: [Double]) -> Vector<Double> {
        if x.isEmpty { return .zero(0) }
        var lastY = y(x[0])
        var result: Vector<Double> = .zero(lastY.components.count)
        for i in 1..<x.count {
            let xi = x[i]
            let xi1 = x[i - 1]
            let dx = 0.5 * (xi - xi1)
            let yi = y(xi)
            result.add(lastY, scaling: dx)
            result.add(yi, scaling: dx)
            lastY = yi
        }
        return result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Vector<Double>], x: [Double]) -> [Vector<Double>] {
        if y.isEmpty { return [] }
        if y.count == 1 { return [.zero(y[0].components.count)] }
        precondition(y.count == x.count, "The x-axis must match with the y-axis")
        var result: [Vector<Double>] = [Vector<Double>](repeating: .zero(y[0].components.count), count: y.count)
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result[i].add(result[i - 1])
            result[i].add(y[i - 1], scaling: dx)
            result[i].add(y[i], scaling: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: [Vector<Double>], dx: Double) -> Vector<Double> {
        if y.isEmpty { return Vector([]) }
        if y.count == 1 { return .zero(y[0].components.count) }
        if y.count == 2 { return 0.5 * dx * (y.first! + y.last!)}
        var result: Vector<Double> = 0.5 * (y.first! + y.last!)
        for i in 1..<y.count - 1 {
            result += y[i]
        }
        return dx * result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Vector<Double>], dx: Double) -> [Vector<Double>] {
        if y.isEmpty { return [Vector([])] }
        if y.count <= 1 { return [.zero(y[0].components.count)] }
        var result: [Vector<Double>] = [Vector<Double>](repeating: .zero(y[0].components.count), count: y.count)
        for i in 1..<y.count {
            let dx = 0.5 * dx
            result[i].add(result[i - 1])
            result[i].add(y[i - 1], scaling: dx)
            result[i].add(y[i], scaling: dx)
        }
        return result
    }
    
    @inlinable
    public static func movingAverage(y: [Vector<Double>], dx: Double, halfWindowSize: Int) -> [Vector<Double>] {
        if halfWindowSize == 0 || y.count <= 1 { return y }
        var result: [Vector<Double>] = []
        let resultByComponents: [[Double]] = .init(unsafeUninitializedCapacity: y[0].components.count) { buffer, initializedCount in
            nonisolated(unsafe) let buffer = buffer
            DispatchQueue.concurrentPerform(iterations: y[0].components.count) { i in
                let ithComponents = y.map { $0[i] }
                let movingAverage = Trapezoid.movingAverage(y: ithComponents, dx: dx, halfWindowSize: halfWindowSize)
                buffer.initializeElement(at: i, to: movingAverage)
            }
            initializedCount = y[0].components.count
        }
        for i in 0..<y.count {
            var resultVector = Vector<Double>([])
            for j in 0..<y[i].components.count {
                resultVector.components.append(resultByComponents[j][i])
            }
            result.append(resultVector)
        }
        return result
    }
    
    //MARK: Vector<Complex<Double>> integration
    @inlinable
    public static func integrate(y: [Vector<Complex<Double>>], x: [Double]) -> Vector<Complex<Double>> {
        if y.isEmpty { return Vector([]) }
        if y.count == 1 { return .zero(y[0].components.count) }
        precondition(x.count == y.count, "The x-axis must match with the y-axis")
        var result: Vector<Complex<Double>> = Vector(.init(repeating: .zero, count: y[0].components.count))
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result.add(y[i - 1], scaling: dx)
            result.add(y[i], scaling: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: (Double) -> Vector<Complex<Double>>, x: [Double]) -> Vector<Complex<Double>> {
        if x.isEmpty { return .zero(0) }
        var lastY = y(x[0])
        var result: Vector<Complex<Double>> = .zero(lastY.components.count)
        for i in 1..<x.count {
            let xi = x[i]
            let xi1 = x[i - 1]
            let dx = 0.5 * (xi - xi1)
            let yi = y(xi)
            result.add(lastY, scaling: dx)
            result.add(yi, scaling: dx)
            lastY = yi
        }
        return result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Vector<Complex<Double>>], x: [Double]) -> [Vector<Complex<Double>>] {
        if y.isEmpty { return [] }
        if y.count == 1 { return [.zero(y[0].components.count)] }
        precondition(y.count == x.count, "The x-axis must match with the y-axis")
        var result: [Vector<Complex<Double>>] = [Vector<Complex<Double>>](repeating: .zero(y[0].components.count), count: y.count)
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result[i].add(result[i - 1])
            result[i].add(y[i - 1], scaling: dx)
            result[i].add(y[i], scaling: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: [Vector<Complex<Double>>], dx: Double) -> Vector<Complex<Double>> {
        if y.isEmpty { return Vector([]) }
        if y.count == 1 { return .zero(y[0].components.count) }
        if y.count == 2 { return 0.5 * dx * (y.first! + y.last!)}
        var result: Vector<Complex<Double>> = 0.5 * (y.first! + y.last!)
        for i in 1..<y.count - 1 {
            result += y[i]
        }
        return dx * result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Vector<Complex<Double>>], dx: Double) -> [Vector<Complex<Double>>] {
        if y.isEmpty { return [Vector([])] }
        if y.count <= 1 { return [.zero(y[0].components.count)] }
        var result: [Vector<Complex<Double>>] = [Vector<Complex<Double>>](repeating: .zero(y[0].components.count), count: y.count)
        for i in 1..<y.count {
            let dx = 0.5 * dx
            result[i].add(result[i - 1])
            result[i].add(y[i - 1], scaling: dx)
            result[i].add(y[i], scaling: dx)
        }
        return result
    }
    
    @inlinable
    public static func movingAverage(y: [Vector<Complex<Double>>], dx: Double, halfWindowSize: Int) -> [Vector<Complex<Double>>] {
        if halfWindowSize == 0 || y.count <= 1 { return y }
        var result: [Vector<Complex<Double>>] = []
        let resultByComponents: [[Complex<Double>]] = .init(unsafeUninitializedCapacity: y[0].components.count) { buffer, initializedCount in
            nonisolated(unsafe) let buffer = buffer
            DispatchQueue.concurrentPerform(iterations: y[0].components.count) { i in
                let ithComponents = y.map { $0[i] }
                let movingAverage = Trapezoid.movingAverage(y: ithComponents, dx: dx, halfWindowSize: halfWindowSize)
                buffer.initializeElement(at: i, to: movingAverage)
            }
            initializedCount = y[0].components.count
        }
        for i in 0..<y.count {
            var resultVector = Vector<Complex<Double>>([])
            for j in 0..<y[i].components.count {
                resultVector.components.append(resultByComponents[j][i])
            }
            result.append(resultVector)
        }
        return result
    }
    
    //MARK: Matrix<Double> integration
    @inlinable
    public static func integrate(y: [Matrix<Double>], x: [Double]) -> Matrix<Double> {
        if y.isEmpty { return Matrix(elements: [], rows: 0, columns: 0) }
        if y.count == 1 { return .zeros(rows: y[0].rows, columns: y[0].columns) }
        precondition(x.count == y.count, "The x-axis must match with the y-axis")
        var result: Matrix<Double> = .zeros(rows: y[0].rows, columns: y[0].columns)
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result.add(y[i], multiplied: dx)
            result.add(y[i - 1], multiplied: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: (Double) -> Matrix<Double>, x: [Double]) -> Matrix<Double> {
        if x.isEmpty { return .zeros(rows: 0, columns: 0) }
        var lastY = y(x[0])
        var result: Matrix<Double> = .zeros(rows: lastY.rows, columns: lastY.columns)
        for i in 1..<x.count {
            let xi = x[i]
            let xi1 = x[i - 1]
            let dx = 0.5 * (xi - xi1)
            let yi = y(xi)
            result.add(lastY, multiplied: dx)
            result.add(yi, multiplied: dx)
            lastY = yi
        }
        return result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Matrix<Double>], x: [Double]) -> [Matrix<Double>] {
        if y.isEmpty { return [] }
        if y.count == 1 { return [.zeros(rows: y[0].rows, columns: y[0].columns)] }
        precondition(y.count == x.count, "The x-axis must match with the y-axis")
        var result: [Matrix<Double>] = [Matrix<Double>](repeating: .zeros(rows: y[0].rows, columns: y[0].columns), count: y.count)
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result[i] += result[i - 1]
            result[i].add(y[i], multiplied: dx)
            result[i].add(y[i - 1], multiplied: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: [Matrix<Double>], dx: Double) -> Matrix<Double> {
        if y.isEmpty { return Matrix(elements: [], rows: 0, columns: 0) }
        if y.count == 1 { return .zeros(rows: y[0].rows, columns: y[0].columns) }
        if y.count == 2 { return 0.5 * dx * (y.first! + y.last!)}
        var result: Matrix<Double> = 0.5 * (y.first! + y.last!)
        for i in 1..<y.count - 1 {
            result += y[i]
        }
        return dx * result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Matrix<Double>], dx: Double) -> [Matrix<Double>] {
        if y.isEmpty { return [Matrix(elements: [], rows: 0, columns: 0)] }
        if y.count <= 1 { return [.zeros(rows: y[0].rows, columns: y[0].columns)] }
        var result: [Matrix<Double>] = [Matrix<Double>](repeating: .zeros(rows: y[0].rows, columns: y[0].columns), count: y.count)
        let dx = 0.5 * dx
        for i in 1..<y.count {
            result[i].add(result[i - 1])
            result[i].add(y[i - 1], multiplied: dx)
            result[i].add(y[i], multiplied: dx)
        }
        return result
    }
    
    @inlinable
    public static func movingAverage(y: [Matrix<Double>], dx: Double, halfWindowSize: Int) -> [Matrix<Double>] {
        if halfWindowSize == 0 || y.count <= 1 { return y }
        var result: [Matrix<Double>] = .init(repeating: .zeros(rows: y[0].rows, columns: y[0].columns), count: y.count)
        product(0..<y[0].rows, 0..<y[0].columns).parallelMap { (i, j) in
            let elements = y.betterMap { $0[i, j] }
            let movingAverage = movingAverage(y: elements, dx: dx, halfWindowSize: halfWindowSize)
            return (i ,j, movingAverage)
        }.forEach { (i, j, elements) in
            for index in 0..<elements.count {
                result[index][i, j] = elements[index]
            }
        }
        return result
    }
    
    //MARK: Matrix<Complex<Double>> integration
    @inlinable
    public static func integrate(y: [Matrix<Complex<Double>>], x: [Double]) -> Matrix<Complex<Double>> {
        if y.isEmpty { return Matrix(elements: [], rows: 0, columns: 0) }
        if y.count == 1 { return .zeros(rows: y[0].rows, columns: y[0].columns) }
        precondition(x.count == y.count, "The x-axis must match with the y-axis")
        var result: Matrix<Complex<Double>> = .zeros(rows: y[0].rows, columns: y[0].columns)
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result.add(y[i], multiplied: dx)
            result.add(y[i - 1], multiplied: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: (Double) -> Matrix<Complex<Double>>, x: [Double]) -> Matrix<Complex<Double>> {
        if x.isEmpty { return .zeros(rows: 0, columns: 0) }
        var lastY = y(x[0])
        var result: Matrix<Complex<Double>> = .zeros(rows: lastY.rows, columns: lastY.columns)
        for i in 1..<x.count {
            let xi = x[i]
            let xi1 = x[i - 1]
            let dx = 0.5 * (xi - xi1)
            let yi = y(xi)
            result.add(lastY, multiplied: dx)
            result.add(yi, multiplied: dx)
            lastY = yi
        }
        return result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Matrix<Complex<Double>>], x: [Double]) -> [Matrix<Complex<Double>>] {
        if y.isEmpty { return [] }
        if y.count == 1 { return [.zeros(rows: y[0].rows, columns: y[0].columns)] }
        precondition(y.count == x.count, "The x-axis must match with the y-axis")
        var result: [Matrix<Complex<Double>>] = [Matrix<Complex<Double>>](repeating: .zeros(rows: y[0].rows, columns: y[0].columns), count: y.count)
        for i in 1..<y.count {
            let dx = 0.5 * (x[i] - x[i - 1])
            result[i].add(result[i - 1])
            result[i].add(y[i], multiplied: dx)
            result[i].add(y[i - 1], multiplied: dx)
        }
        return result
    }
    
    @inlinable
    public static func integrate(y: [Matrix<Complex<Double>>], dx: Double) -> Matrix<Complex<Double>> {
        if y.isEmpty { return Matrix(elements: [], rows: 0, columns: 0) }
        if y.count == 1 { return .zeros(rows: y[0].rows, columns: y[0].columns) }
        if y.count == 2 { return 0.5 * dx * (y.first! + y.last!)}
        var result: Matrix<Complex<Double>> = 0.5 * (y.first! + y.last!)
        for i in 1..<y.count - 1 {
            result += y[i]
        }
        return dx * result
    }
    
    @inlinable
    public static func integrateCumulative(y: [Matrix<Complex<Double>>], dx: Double) -> [Matrix<Complex<Double>>] {
        if y.isEmpty { return [Matrix(elements: [], rows: 0, columns: 0)] }
        if y.count <= 1 { return [.zeros(rows: y[0].rows, columns: y[0].columns)] }
        var result: [Matrix<Complex<Double>>] = [Matrix<Complex<Double>>](repeating: .zeros(rows: y[0].rows, columns: y[0].columns), count: y.count)
        let dx = 0.5 * dx
        for i in 1..<y.count {
            result[i].add(result[i - 1])
            result[i].add(y[i], multiplied: dx)
            result[i].add(y[i - 1], multiplied: dx)
        }
        return result
    }
    
    @inlinable
    public static func movingAverage(y: [Matrix<Complex<Double>>], dx: Double, halfWindowSize: Int) -> [Matrix<Complex<Double>>] {
        if halfWindowSize == 0 || y.count <= 1 { return y }
        var result: [Matrix<Complex<Double>>] = .init(repeating: .zeros(rows: y[0].rows, columns: y[0].columns), count: y.count)
        product(0..<y[0].rows, 0..<y[0].columns).parallelMap { (i, j) in
            let elements = y.betterMap { $0[i, j] }
            let movingAverage = movingAverage(y: elements, dx: dx, halfWindowSize: halfWindowSize)
            return (i ,j, movingAverage)
        }.forEach { (i, j, elements) in
            for index in 0..<elements.count {
                result[index][i, j] = elements[index]
            }
        }
        return result
    }
}
