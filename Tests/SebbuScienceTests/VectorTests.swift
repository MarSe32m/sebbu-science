//
//  VectorTests.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 21.4.2025.
//

import Testing
@testable import SebbuScience

struct VectorArithmeticOperationsTests {
    @Test("Vector<Float> arithmetic tests", arguments:
            [-1.0, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1.0],
            [-1.0, -0.75, -0.5, -0.25, 0.25, 0.5, 0.75, 1.0])
    func vectorDoubleArithmeticTests(scaling: Float, divisor: Float) throws {
        let a: Vector<Float> = [1.95439285, 2.289542]
        let b: Vector<Float> = [3.23984293, 4.171278]
        
        // Addition
        var c = a + b
        var d = a
        var e = a
        d += b
        e._add(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Subtraction
        c = a - b
        d = a; d -= b
        e = a; e._subtract(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Scaling
        c = scaling * a
        d = a; d *= scaling
        e = a; e._multiply(by: scaling)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Division
        c = a / divisor
        d = a; d /= divisor
        e = a; e._divide(by: divisor)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
    }
    
    @Test("Vector<Double> arithmetic tests", arguments:
            [-1.0, -0.75, -0.5, -0.25, 0, 0.25, 0.5, 0.75, 1.0],
            [-1.0, -0.75, -0.5, -0.25, 0.25, 0.5, 0.75, 1.0])
    func vectorDoubleArithmeticTests(scaling: Double, divisor: Double) throws {
        let a: Vector<Double> = [1.95439285, 2.289542985479254879]
        let b: Vector<Double> = [3.2398429384289348293482, 4.17127831846137592]
        
        // Addition
        var c = a + b
        var d = a
        var e = a
        d += b
        e._add(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Subtraction
        c = a - b
        d = a; d -= b
        e = a; e._subtract(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Scaling
        c = scaling * a
        d = a; d *= scaling
        e = a; e._multiply(by: scaling)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Division
        c = a / divisor
        d = a; d /= divisor
        e = a; e._divide(by: divisor)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
    }
    
    @Test("Vector<Complex<Float>> arithmetic tests", arguments:
            [Complex(-1.0), Complex(-0.75, 0.75), Complex(-0.5, -0.25), 0, Complex(0.25, 0.5), Complex(0.75, -0.75), Complex(1.0)],
          [Complex(-1.0), Complex(-0.75, 0.75), Complex(-0.5, -0.25), Complex(0.25, 0.5), Complex(0.75, -0.75), Complex(1.0)])
    func vectorComplexFloatArithmeticTests(scaling: Complex<Float>, divisor: Complex<Float>) throws {
        let a: Vector<Complex<Float>> = [Complex(1.95439285, -8.237419), Complex(-2.289542, 0.00123123)]
        let b: Vector<Complex<Float>> = [Complex(3.23984293, 22), Complex(4.171278)]
        
        // Addition
        var c = a + b
        var d = a
        var e = a
        d += b
        e._add(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Subtraction
        c = a - b
        d = a; d -= b
        e = a; e._subtract(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Scaling
        c = scaling * a
        d = a; d *= scaling
        e = a; e._multiply(by: scaling)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Division
        c = a / divisor
        d = a; d /= divisor
        e = a; e._divide(by: divisor)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
    }
    
    @Test("Vector<Complex<Double>> arithmetic tests", arguments:
            [Complex(-1.0), Complex(-0.75, 0.75), Complex(-0.5, -0.25), 0, Complex(0.25, 0.5), Complex(0.75, -0.75), Complex(1.0)],
          [Complex(-1.0), Complex(-0.75, 0.75), Complex(-0.5, -0.25), Complex(0.25, 0.5), Complex(0.75, -0.75), Complex(1.0)])
    func vectorComplexDoubleArithmeticTests(scaling: Complex<Double>, divisor: Complex<Double>) throws {
        let a: Vector<Complex<Double>> = [Complex(1.95439285, -8.237419), Complex(-2.289542, 0.00123123)]
        let b: Vector<Complex<Double>> = [Complex(3.23984293, 22), Complex(4.171278)]
        
        // Addition
        var c = a + b
        var d = a
        var e = a
        d += b
        e._add(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Subtraction
        c = a - b
        d = a; d -= b
        e = a; e._subtract(b)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Scaling
        c = scaling * a
        d = a; d *= scaling
        e = a; e._multiply(by: scaling)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
        
        // Division
        c = a / divisor
        d = a; d /= divisor
        e = a; e._divide(by: divisor)
        #expect(c.isApproximatelyEqual(to: d))
        #expect(c.isApproximatelyEqual(to: e))
    }
}
