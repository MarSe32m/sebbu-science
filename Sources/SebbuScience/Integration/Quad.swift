//
//  Quad.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 4.5.2025.
//

import CMath
import Numerics

public enum Quad {
    //TODO: Document epsabs and epsrel
    //TODO: Return abserr, neval, ier and document those
    @inlinable
    public static func integrate(a: Double, b: Double, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (Double) -> Double) -> Double {
        if a == b { return 0 }
        if a.isNaN || b.isNaN { return .nan }
        let sign: Double = a < b ? 1.0 : -1.0
        let lowerBound = min(a, b)
        let upperBound = max(a, b)
        var abserr: Double = 0
        var neval: Int32 = 0
        var ier: Int32 = 0
        return sign * withoutActuallyEscaping(f) { escapingF in
            let functionPtr = UnsafeMutablePointer<(Double) -> Double>.allocate(capacity: 1)
            defer {
                functionPtr.deinitialize(count: 1)
                functionPtr.deallocate()
            }
            functionPtr.initialize(to: escapingF)
            let userData = UnsafeMutableRawPointer(functionPtr)
            
            if lowerBound.isFinite && upperBound.isFinite {
                return dqags({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, lowerBound, upperBound, epsabs, epsrel, &abserr, &neval, &ier, userData)
            } else if lowerBound.isFinite && upperBound.isInfinite {
                return dqagi({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, lowerBound, 1, epsabs, epsrel, &abserr, &neval, &ier, userData)
            } else if lowerBound.isInfinite && upperBound.isFinite {
                return dqagi({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, upperBound, -1, epsabs, epsrel, &abserr, &neval, &ier, userData)
            } else if lowerBound.isInfinite && upperBound.isInfinite {
                return dqagi({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, 0, 2, epsabs, epsrel, &abserr, &neval, &ier, userData)
            } else {
                fatalError("unreachable")
            }
        }
    }
    
    @inlinable
    public static func integrate(a: Double, b: Double, points: [Double], epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (Double) -> Double) -> Double {
        precondition(a.isFinite, "Lower bound must be finite when integrating through break points (singularities, discontunities etc.)")
        precondition(b.isFinite, "Upper bound must be finite when integrating through break points (singularities, discontunities etc.)")
        if a == b { return 0 }
        if points.isEmpty {
            return integrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel, f: f)
        }
        if a.isNaN || b.isNaN { return .nan }
        let sign: Double = a < b ? 1.0 : -1.0
        let lowerBound = min(a, b)
        let upperBound = max(a, b)
        var abserr: Double = 0
        var neval: Int32 = 0
        var ier: Int32 = 0
        return sign * withoutActuallyEscaping(f) { escapingF in
            let functionPtr = UnsafeMutablePointer<(Double) -> Double>.allocate(capacity: 1)
            defer {
                functionPtr.deinitialize(count: 1)
                functionPtr.deallocate()
            }
            functionPtr.initialize(to: escapingF)
            let userData = UnsafeMutableRawPointer(functionPtr)
            var points = points
            return dqagp({ t, user_data in
                guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                return function(t)
            }, lowerBound, upperBound, numericCast(points.count), &points, epsabs, epsrel, &abserr, &neval, &ier, userData)
        }
    }
    
    @inlinable
    public static func integrate(a: Double, b: Double, realPoints: [Double], imaginaryPoints: [Double], epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (Double) -> Complex<Double>) -> Complex<Double> {
        let real = integrate(a: a, b: b, points: realPoints, epsabs: epsabs, epsrel: epsrel, f: { f($0).real })
        let imaginary = integrate(a: a, b: b, points: imaginaryPoints, epsabs: epsabs, epsrel: epsrel, f: { f($0).imaginary })
        return Complex(real, imaginary)
    }
    
    //TODO: Document epsabs, epsrel
    //TODO: Return abserr, neval, ier and document those
    public static func integrate(a: Double, b: Double, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (Double) -> Complex<Double>) -> Complex<Double> {
        let realIntegral = integrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel) { f($0).real }
        let imaginaryIntegral = integrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel) { f($0).imaginary }
        return Complex(realIntegral, imaginaryIntegral)
    }
    
    public enum WeightFunction {
        case cos(_ w: Double)
        case sin(_ w: Double)
        case alg(_ alpha: Double, _ beta: Double)
        case algLoga(_ alpha: Double, _ beta: Double)
        case algLogb(_ alpha: Double, _ beta: Double)
        case algLog(_ alpha: Double, _ beta: Double)
        case cauchy(_ c: Double)
    }
    
    @inlinable
    public static func integrate(a: Double, b: Double, weight: WeightFunction, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (Double) -> Double) -> Double {
        if a.isNaN || b.isNaN { return .nan }
        let sign: Double = a < b ? 1.0 : -1.0
        let lowerBound = min(a, b)
        let upperBound = max(a, b)
        var abserr: Double = 0
        var neval: Int32 = 0
        var ier: Int32 = 0
        return sign * withoutActuallyEscaping(f) { escapingF in
            let functionPtr = UnsafeMutablePointer<(Double) -> Double>.allocate(capacity: 1)
            defer {
                functionPtr.deinitialize(count: 1)
                functionPtr.deallocate()
            }
            functionPtr.initialize(to: escapingF)
            let userData = UnsafeMutableRawPointer(functionPtr)
            
            switch weight {
            case .cos(let w):
                precondition(!(a.isInfinite && b.isInfinite), "Only one of the bounds is allowed to be infinite when the weight function is cosine")
                if a.isFinite && b.isFinite {
                    return dqawo({ t, user_data in
                        guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                        return function(t)
                    }, lowerBound, upperBound, w, 1, epsabs, epsrel, &abserr, &neval, &ier, userData)
                } else if a.isFinite && b.isInfinite {
                    return dqawf({ t, user_data in
                        guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                        return function(t)
                    }, a, w, 1, epsabs, &abserr, &neval, &ier, userData)
                } else if a.isInfinite && b.isFinite {
                    return -dqawf({ t, user_data in
                        guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                        return function(-t)
                    }, -b, w, 1, epsabs, &abserr, &neval, &ier, userData)
                } else { fatalError("Unreachable") }
            case .sin(let w):
                precondition(!(a.isInfinite && b.isInfinite), "Only one of the bounds is allowed to be infinite when the weight function is sine")
                if a.isFinite && b.isFinite {
                    return dqawo({ t, user_data in
                        guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                        return function(t)
                    }, lowerBound, upperBound, w, 2, epsabs, epsrel, &abserr, &neval, &ier, userData)
                } else if a.isFinite && b.isInfinite {
                    return dqawf({ t, user_data in
                        guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                        return function(t)
                    }, a, w, 2, epsabs, &abserr, &neval, &ier, userData)
                } else if a.isInfinite && b.isFinite {
                    return -dqawf({ t, user_data in
                        guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                        return function(-t)
                    }, -b, w, 2, epsabs, &abserr, &neval, &ier, userData)
                } else { fatalError("Unreachable") }
            case .alg(let alpha, let beta):
                precondition(a.isFinite && b.isFinite, "Both of the bounds need to finite with alg weight function")
                return dqawse({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, a, b, alpha, beta, 1, epsabs, epsrel, &abserr, &neval, &ier, userData)
            case .algLoga(let alpha, let beta):
                precondition(a.isFinite && b.isFinite, "Both of the bounds need to finite with algLoga weight function")
                return dqawse({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, a, b, alpha, beta, 2, epsabs, epsrel, &abserr, &neval, &ier, userData)
            case .algLogb(let alpha, let beta):
                precondition(a.isFinite && b.isFinite, "Both of the bounds need to finite with algLogb weight function")
                return dqawse({  t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, a, b, alpha, beta, 3, epsabs, epsrel, &abserr, &neval, &ier, userData)
            case .algLog(let alpha, let beta):
                precondition(a.isFinite && b.isFinite, "Both of the bounds need to finite with algLog weight function")
                return dqawse({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, a, b, alpha, beta, 4, epsabs, epsrel, &abserr, &neval, &ier, userData)
            case .cauchy(let c):
                precondition(a.isFinite && b.isFinite, "Both of the bounds need to finite with cauchy weight function")
                return dqawce({ t, user_data in
                    guard let function = user_data?.assumingMemoryBound(to: ((Double) -> Double).self).pointee else { fatalError("Failed to retrieve function") }
                    return function(t)
                }, a, b, c, epsabs, epsrel, &abserr, &neval, &ier, userData)
            }
        }
    }
    
    @inlinable
    public static func integrate(a: Double, b: Double, realWeight: WeightFunction, imaginaryWeight: WeightFunction, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (Double) -> Complex<Double>) -> Complex<Double> {
        let real = integrate(a: a, b: b, weight: realWeight) { f($0).real }
        let imaginary = integrate(a: a, b: b, weight: imaginaryWeight) { f($0).imaginary }
        return Complex(real, imaginary)
    }
    
    @inlinable
    public static func doubleIntegrate(a: Double, b: Double, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (_ y: Double, _ x: Double) -> Double, g: (_ x: Double) -> Double, h: (_ x: Double) -> Double) -> Double {
        integrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel) { x in
            integrate(a: g(x), b: h(x), epsabs: epsabs, epsrel: epsrel) { y in
                f(y, x)
            }
        }
    }
    
    @inlinable
    public static func doubleIntegrate(a: Double, b: Double, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (_ y: Double, _ x: Double) -> Complex<Double>, g: (Double) -> Double, h: (Double) -> Double) -> Complex<Double> {
        let real = doubleIntegrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel, f: { f($0, $1).real }, g: g, h: h)
        let imaginary = doubleIntegrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel, f: { f($0, $1).imaginary }, g: g, h: h)
        return Complex(real, imaginary)
    }
    
    @inlinable
    public static func tripleIntegral(a: Double, b: Double, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (_ z: Double, _ y: Double, _ x: Double) -> Double, g: (_ x: Double) -> Double, h: (_ x: Double) -> Double, q: (_ y: Double, _ x: Double) -> Double, r: (_ y: Double, _ x: Double) -> Double) -> Double {
        integrate(a: a, b: b, epsabs: epsabs, epsrel: epsrel) { x in
            integrate(a: g(x), b: h(x), epsabs: epsabs, epsrel: epsrel) { y in
                integrate(a: q(y, x), b: r(y, x), epsabs: epsabs, epsrel: epsrel) { z in
                    f(z, y, x)
                }
            }
        }
    }
    
    @inlinable
    public static func tripleIntegral(a: Double, b: Double, epsabs: Double = 1.49e-8, epsrel: Double = 1.49e-8, f: (_ z: Double, _ y: Double, _ x: Double) -> Complex<Double>, g: (_ x: Double) -> Double, h: (_ x: Double) -> Double, q: (_ y: Double, _ x: Double) -> Double, r: (_ y: Double, _ x: Double) -> Double) -> Complex<Double> {
        let real = tripleIntegral(a: a, b: b, epsabs: epsabs, epsrel: epsrel, f: { f($0, $1, $2).real }, g: g, h: h, q: q, r: r)
        let imaginary = tripleIntegral(a: a, b: b, epsabs: epsabs, epsrel: epsrel, f: { f($0, $1, $2).imaginary }, g: g, h: h, q: q, r: r)
        return Complex(real, imaginary)
    }
}
