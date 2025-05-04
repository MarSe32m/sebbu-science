//
//  Polynomial.swift.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

import Numerics

public struct Polynomial<T: AlgebraicField> {
    public var coefficients: [T]

    public var degree: Int { coefficients.count - 1 }
    
    public init(_ coefficients: [T]) {
        if let lastIndex = coefficients.lastIndex(where: {$0 != .zero} ) {
            self.coefficients = Array(coefficients[0...lastIndex])
        } else {
            self.coefficients = []
        }
    }
}

public extension Polynomial {
    @inlinable
    func callAsFunction(_ x: T) -> T {
        if coefficients.isEmpty { return .zero }
        var result = coefficients[0]
        var multiplier = x
        for coefficient in coefficients.dropFirst() {
            result += multiplier * coefficient
            multiplier *= x
        }
        return result
    }

    func companionMatrix() -> Matrix<T> {
        guard let lastCoefficient = coefficients.last else { return Matrix(elements: [], rows: 0, columns: 0) }
        let monicCoefficients = (0..<coefficients.count - 1).map { i in
            coefficients[i] / lastCoefficient
        }
        let N = monicCoefficients.count
        var companionMatrix = [T](repeating: .zero, count: N * N)
        for row in 0..<N {
            if row > 0 { companionMatrix[N * row + row - 1] = T(exactly: 1)! }
            companionMatrix[N * row + N - 1] = -monicCoefficients[row]
        }
        return Matrix(elements: companionMatrix, rows: N, columns: N)
    }
}

public extension Polynomial {
    @inlinable
    static func +(lhs: Self, rhs: Self) -> Self {
        var newCoefficients: [T] = [T](repeating: .zero, count: max(lhs.coefficients.count, rhs.coefficients.count))
        for i in 0..<newCoefficients.count {
            if i < lhs.coefficients.count {
                newCoefficients[i] += lhs.coefficients[i]
            }
            if i < rhs.coefficients.count {
                newCoefficients[i] += rhs.coefficients[i]
            }
        }
        return Polynomial(newCoefficients)
    }
    
    @inlinable
    static func -(lhs: Self, rhs: Self) -> Self {
        var newCoefficients: [T] = [T](repeating: .zero, count: max(lhs.coefficients.count, rhs.coefficients.count))
        for i in 0..<newCoefficients.count {
            if i < lhs.coefficients.count {
                newCoefficients[i] -= lhs.coefficients[i]
            }
            if i < rhs.coefficients.count {
                newCoefficients[i] -= rhs.coefficients[i]
            }
        }
        return Polynomial(newCoefficients)
    }
    
    @inlinable
    static func *(lhs: Self, rhs: Self) -> Self {
        var newCoefficients: [T] = [T](repeating: .zero, count: lhs.coefficients.count + rhs.coefficients.count)
        for i in 0..<lhs.coefficients.count {
            for j in 0..<rhs.coefficients.count {
                newCoefficients[i + j] += lhs.coefficients[i] * rhs.coefficients[j]
            }
        }
        return Polynomial(newCoefficients)
    }
}

public extension Polynomial<Double> {
    func roots() -> [Complex<Double>] {
        let companionMatrix = companionMatrix()
        if companionMatrix.elements.isEmpty { return [] }
        let rotated: Matrix<Double> = .init(elements: companionMatrix.elements.reversed(), rows: companionMatrix.rows, columns: companionMatrix.columns)
        return try! MatrixOperations.eigenValues(rotated)
    }
}

public extension Polynomial<Float> {
    func roots() -> [Complex<Float>] {
        let companionMatrix = companionMatrix()
        if companionMatrix.elements.isEmpty { return [] }
        let rotated: Matrix<Float> = .init(elements: companionMatrix.elements.reversed(), rows: companionMatrix.rows, columns: companionMatrix.columns)
        return try! MatrixOperations.eigenValues(rotated)
    }
}

public extension Polynomial<Complex<Double>> {
    func roots() -> [Complex<Double>] {
        let companionMatrix = companionMatrix()
        if companionMatrix.elements.isEmpty { return [] }
        let rotated: Matrix<Complex<Double>> = .init(elements: companionMatrix.elements.reversed(), rows: companionMatrix.rows, columns: companionMatrix.columns)
        return try! MatrixOperations.eigenValues(rotated)
    }
    
    @inline(__always)
    func callAsFunction(_ x: Double) -> Complex<Double> {
        let _x = Complex(x)
        return self(_x)
    }
}

public extension Polynomial<Complex<Float>> {
    func roots() -> [Complex<Float>] {
        let companionMatrix = companionMatrix()
        if companionMatrix.elements.isEmpty { return [] }
        let rotated: Matrix<Complex<Float>> = .init(elements: companionMatrix.elements.reversed(), rows: companionMatrix.rows, columns: companionMatrix.columns)
        return try! MatrixOperations.eigenValues(rotated)
    }
    
    @inline(__always)
    func callAsFunction(_ x: Float) -> Complex<Float> {
        let _x = Complex(x)
        return self(_x)
    }
}

extension Polynomial: Sendable where T: Sendable {}

extension Polynomial: CustomStringConvertible {
    public var description: String {
        var output = ""
        var containsFirst = false
        for exponent in 0..<coefficients.count {
            let c = coefficients[exponent]
            if c == .zero { continue }
            if exponent == 0 {
                containsFirst = true
                output += "\(c)"
            } else {
                if containsFirst {
                    output += " + \(c)x^\(exponent)"
                } else {
                    output += "\(c)x^\(exponent)"
                }
            }
        }
        return output
    }
}
