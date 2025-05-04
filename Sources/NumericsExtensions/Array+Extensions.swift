//
//  Array+Extensions.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 3.5.2025.
//

import Numerics

public extension Array<Complex<Double>> {
    @inlinable
    var real: [Double] { map { $0.real } }
    @inlinable
    var imaginary: [Double] { map { $0.imaginary } }
    @inlinable
    var conjugate: [Complex<Double>] { map { $0.conjugate }}
}

public extension Array<Complex<Float>> {
    @inlinable
    var real: [Float] { map { $0.real } }
    @inlinable
    var imaginary: [Float] { map { $0.imaginary } }
    @inlinable
    var conjugate: [Complex<Float>] { map { $0.conjugate }}
}

public extension Array<Double> {
    static func linearSpace(_ from: Double, _ to: Double, _ count: Int) -> Self {
        (0..<count).map { i in
            let t = Double(i) / Double(count)
            return from * (1 - t) + to * t
        }
    }
    
    static func linearSpace(_ from: Double, _ to: Double, _ by: Double) -> Self {
        var result: [Double] = []
        result.reserveCapacity(Int((to - from) / by))
        var current = from
        while current <= to {
            result.append(current)
            current += by
        }
        return result
    }
    
    static func range(_ from: Int, _ to: Int) -> Self {
        (from...to).map { Double($0) }
    }
}

package extension Array where Element: FloatingPoint {
    /// Finds the start index of the interval in the array in which the element belongs in.
    /// Uses binary search, i.e. complexity O(log n) and the array is assumed to be sorted monotonically.
    /// If the value is less than the minimum value of the array or larger than the maximum value
    /// of the array then the first or last index, respectively, will be returned.
    /// - Parameters:
    ///     - element: The value we are looking for
    /// - Returns: The start index for the interval in the array
    @inlinable
    func intervalIndex(_ element: Element) -> Int {
        if count <= 1 || element < self[1] { return 0 }
        if element >= self[count - 2] { return count - 2 }
        var min = 0
        var max = count - 1
        var index = (min + max) >> 1
        while min != max - 1 {
            let currentElement = self[index]
            if currentElement == element {
                return index
            } else if currentElement > element {
                max = index
            } else {
                min = index
            }
            index = (min + max) >> 1
        }
        return min
    }
}
