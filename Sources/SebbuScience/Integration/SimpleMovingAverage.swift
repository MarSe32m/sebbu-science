//
//  SimpleMovingAverage.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import DequeModule
import Numerics

public struct SimpleMovingAverage<T> {
    @usableFromInline
    internal var window: Deque<T> = Deque()
    
    public private(set) var movingAverage: T
    public let windowSize: Int
}

public extension SimpleMovingAverage<Double> {
    init(windowSize: Int) {
        self.windowSize = windowSize
        self.movingAverage = .zero
    }
    
    mutating func update(_ value: Double) {
        if window.count < windowSize {
            // Cumulative average
            movingAverage = (value + Double(window.count) * movingAverage) / Double(window.count + 1)
        } else {
            // Moving average
            let removedValue = window.removeFirst()
            movingAverage = movingAverage + (value - removedValue) / Double(windowSize)
        }
        window.append(value)
    }
}

public extension SimpleMovingAverage<Complex<Double>> {
    init(windowSize: Int) {
        self.windowSize = windowSize
        self.movingAverage = .zero
    }
    
    mutating func update(_ value: Complex<Double>) {
        if window.count < windowSize {
            // Cumulative average
            movingAverage = (value + Double(window.count) * movingAverage) / Double(window.count + 1)
        } else {
            // Moving average
            let removedValue = window.removeFirst()
            movingAverage = movingAverage + (value - removedValue) / Double(windowSize)
        }
        window.append(value)
    }
}

public extension SimpleMovingAverage<Vector<Double>> {
    init(windowSize: Int, componentCount: Int) {
        self.windowSize = windowSize
        self.movingAverage = .zero(componentCount)
    }
    
    mutating func update(_ value: Vector<Double>) {
        if window.count < windowSize {
            // Cumulative average
            movingAverage = (value + Double(window.count) * movingAverage) / Double(window.count + 1)
        } else {
            // Moving average
            let removedValue = window.removeFirst()
            movingAverage = movingAverage + (value - removedValue) / Double(windowSize)
        }
        window.append(value)
    }
}

public extension SimpleMovingAverage<Vector<Complex<Double>>> {
    init(windowSize: Int, componentCount: Int) {
        self.windowSize = windowSize
        self.movingAverage = .zero(componentCount)
    }
    
    mutating func update(_ value: Vector<Complex<Double>>) {
        if window.count < windowSize {
            // Cumulative average
            movingAverage = (value + Double(window.count) * movingAverage) / Double(window.count + 1)
        } else {
            // Moving average
            let removedValue = window.removeFirst()
            movingAverage = movingAverage + (value - removedValue) / Double(windowSize)
        }
        window.append(value)
    }
}

public extension SimpleMovingAverage<Matrix<Double>> {
    init(windowSize: Int, rows: Int, columns: Int) {
        self.windowSize = windowSize
        self.movingAverage = .zeros(rows: rows, columns: columns)
    }
    
    mutating func update(_ value: Matrix<Double>) {
        if window.count < windowSize {
            // Cumulative average
            movingAverage = (value + Double(window.count) * movingAverage) / Double(window.count + 1)
        } else {
            // Moving average
            let removedValue = window.removeFirst()
            movingAverage = movingAverage + (value - removedValue) / Double(windowSize)
        }
        window.append(value)
    }
}

public extension SimpleMovingAverage<Matrix<Complex<Double>>> {
    init(windowSize: Int, rows: Int, columns: Int) {
        self.windowSize = windowSize
        self.movingAverage = .zeros(rows: rows, columns: columns)
    }
    
    mutating func update(_ value: Matrix<Complex<Double>>) {
        if window.count < windowSize {
            // Cumulative average
            movingAverage = (value + Double(window.count) * movingAverage) / Double(window.count + 1)
        } else {
            // Moving average
            let removedValue = window.removeFirst()
            movingAverage = movingAverage + (value - removedValue) / Double(windowSize)
        }
        window.append(value)
    }
}
