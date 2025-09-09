@_spi(TestUtilities) import SebbuScience

public func testComplexFloatOperations() -> [BenchmarkResult] {
    var results: [BenchmarkResult] = []
    //MARK: Vector-Vector operations
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.add(_: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.add(_: Vector<Complex<Float>>, multiplied: Complex<Float>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y, multiplied: alpha)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.add(_: Vector<Complex<Float>>, multiplied: Float)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y, multiplied: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y, multiplied: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.multiply(by: Complex<Float>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._multiplyBLAS(by: alpha)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.multiply(by: Float)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._multiply(by: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._multiplyBLAS(by: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dot(_:Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
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
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.inner(_:Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
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
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.copyComponents(from: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponents(from: y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponentsBLAS(from: y)
        })
    )

    //MARK: Matrix-Vector operations
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Vector<Complex<Float>>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Vector<Complex<Float>>, multiplied: Complex<Float>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Vector<Complex<Float>>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Vector<Complex<Float>>, multiplied: Complex<Float>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )
    
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.hermitianDot(_: Vector<Complex<Float>>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.hermitianDot(_: Vector<Complex<Float>>, multiplied: Complex<Float>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.hermitianDot(_: Vector<Complex<Float>>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.hermitianDot(_: Vector<Complex<Float>>, multiplied: Complex<Float>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._hermitianDotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )

    //MARK: Vector-Matrix operations
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dot(_: Matrix<Complex<Float>>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dot(_: Matrix<Complex<Float>>, multiplied: Complex<Float>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dot(_: Matrix<Complex<Float>>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dot(_: Matrix<Complex<Float>>, multiplied: Complex<Float>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )
    
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dotHermitian(_: Matrix<Complex<Float>>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dotHermitian(_: Matrix<Complex<Float>>, multiplied: Complex<Float>, into: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dotHermitian(_: Matrix<Complex<Float>>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Vector<Complex<Float>>.dotHermitian(_: Matrix<Complex<Float>>, multiplied: Complex<Float>, addingInto: Vector<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotHermitianBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )

    //MARK: Matrix-Matrix operations
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.add(_: Matrix<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.add(_: Matrix<Complex<Float>>, multiplied: Complex<Float>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B, multiplied: alpha)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.add(_: Matrix<Complex<Float>>, multiplied: Float)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B, multiplied: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B, multiplied: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.multiply(by: Complex<Float>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._multiplyBLAS(by: alpha)
        })
    )

    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.multiply(by: Float)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._multiply(by: alpha.real)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._multiplyBLAS(by: alpha.real)
        })
    )

    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.copyElements(from: Matrix<Complex<Float>>)", runs: 10, iterations: 100_000, maxDimension: 30, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElements(from: B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElementsBLAS(from: B)
        })
    )


    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Matrix<Complex<Float>>, into: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: .one, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Matrix<Complex<Float>>, multiplied: Complex<Float>, into: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Matrix<Complex<Float>>, addingInto: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: .one, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(_: Matrix<Complex<Float>>, multiplied: Complex<Float>, addingInto: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, addingInto: &C)
        })
    )
    
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Float>>, into: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in
            A._dotBLAS(hermitianSide: .left, B, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Float>>, multiplied: Complex<Float>, into: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(hermitianSide: .left, B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Float>>, addingInto: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(hermitianSide: .left, B, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationComplexFloat(name: "Matrix<Complex<Float>>.dot(hermitianSide: HermitianSide, _: Matrix<Complex<Float>>, multiplied: Complex<Float>, addingInto: Matrix<Complex<Float>>)", runs: 10, iterations: 10_000, maxDimension: 20, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(hermitianSide: .left, B, multiplied: alpha, addingInto: &C)
        })
    )
    return results
}