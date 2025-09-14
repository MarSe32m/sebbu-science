@_spi(TestUtilities) import SebbuScience

public func testComplexDoubleOperations() -> [BenchmarkResult] {
    var results: [BenchmarkResult] = []
    //MARK: Vector-Vector operations
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.add(_: Vector<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.add(_: Vector<Complex<Double>>, multiplied: Complex<Double>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y, multiplied: alpha)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.add(_: Vector<Complex<Double>>, multiplied: Double)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y, multiplied: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y, multiplied: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.multiply(by: Complex<Double>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._multiplyBLAS(by: alpha)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.multiply(by: Double)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._multiply(by: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._multiplyBLAS(by: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dot(_:Vector<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            let d = x._dot(y)
            blackHole(d)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            let d = x._dotBLAS(y)
            blackHole(d)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.inner(_:Vector<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            let d = x._inner(y)
            blackHole(d)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            let d = x._innerBLAS(y)
            blackHole(d)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.copyComponents(from: Vector<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponents(from: y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponentsBLAS(from: y)
        })
    )

    //MARK: Matrix-Vector operations
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Vector<Complex<Double>>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Vector<Complex<Double>>, multiplied: Complex<Double>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Vector<Complex<Double>>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Vector<Complex<Double>>, multiplied: Complex<Double>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )
    
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.hermitianDot(_: Vector<Complex<Double>>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.hermitianDot(_: Vector<Complex<Double>>, multiplied: Complex<Double>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.hermitianDot(_: Vector<Complex<Double>>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.hermitianDot(_: Vector<Complex<Double>>, multiplied: Complex<Double>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )

    //MARK: Vector-Matrix operations
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dot(_: Matrix<Complex<Double>>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dot(_: Matrix<Complex<Double>>, multiplied: Complex<Double>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dot(_: Matrix<Complex<Double>>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dot(_: Matrix<Complex<Double>>, multiplied: Complex<Double>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )
    
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dotHermitian(_: Matrix<Complex<Double>>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dotHermitian(_: Matrix<Complex<Double>>, multiplied: Complex<Double>, into: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dotHermitian(_: Matrix<Complex<Double>>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Vector<Complex<Double>>.dotHermitian(_: Matrix<Complex<Double>>, multiplied: Complex<Double>, addingInto: Vector<Complex<Double>>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )

    //MARK: Matrix-Matrix operations
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.add(_: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.add(_: Matrix<Complex<Double>>, multiplied: Complex<Double>)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B, multiplied: alpha)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.add(_: Matrix<Complex<Double>>, multiplied: Double)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B, multiplied: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B, multiplied: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.multiply(by: Complex<Double>)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._multiplyBLAS(by: alpha)
        })
    )

    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.multiply(by: Double)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._multiply(by: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._multiplyBLAS(by: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.copyElements(from: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElements(from: B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElementsBLAS(from: B)
        })
    )


    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Matrix<Complex<Double>>, into: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: .one, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Matrix<Complex<Double>>, multiplied: Complex<Double>, into: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Matrix<Complex<Double>>, addingInto: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: .one, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(_: Matrix<Complex<Double>>, multiplied: Complex<Double>, addingInto: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, addingInto: &C)
        })
    )
    
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Double>>, into: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in
            A._dotBLAS(hermitianSide: .left, B, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Double>>, multiplied: Complex<Double>, into: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(hermitianSide: .left, B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Double>>, addingInto: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(hermitianSide: .left, B, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationComplexDouble(name: "Matrix<Complex<Double>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Double>>, multiplied: Complex<Double>, addingInto: Matrix<Complex<Double>>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(hermitianSide: .left, B, multiplied: alpha, addingInto: &C)
        })
    )
    return results
}