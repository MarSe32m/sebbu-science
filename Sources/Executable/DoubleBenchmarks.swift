@_spi(TestUtilities) import SebbuScience

public func testDoubleOperations() -> [BenchmarkResult] {
    var results: [BenchmarkResult] = []
    //MARK: Vector-Vector operations
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.add(_: Vector<Double>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.add(_: Vector<Double>, multiplied: Double)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y, multiplied: alpha)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.multiply(by: Double)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._multiplyBLAS(by: alpha)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dot(_:Vector<Double>)", runs: 20, iterations: 1000, maxDimension: 1000, 
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
        benchmarkOperationDouble(name: "Vector<Double>.copyComponents(from: Vector<Double>)", runs: 20, iterations: 1000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponents(from: y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponentsBLAS(from: y)
        })
    )

    //MARK: Matrix-Vector operations
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Vector<Double>, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Vector<Double>, multiplied: Double, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Vector<Double>, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Vector<Double>, multiplied: Double, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )
    
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.symmetricDot(_: Vector<Double>, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.symmetricDot(_: Vector<Double>, multiplied: Double, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.symmetricDot(_: Vector<Double>, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.symmetricDot(_: Vector<Double>, multiplied: Double, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )

    //MARK: Vector-Matrix operations
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dot(_: Matrix<Double>, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dot(_: Matrix<Double>, multiplied: Double, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dot(_: Matrix<Double>, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dot(_: Matrix<Double>, multiplied: Double, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )
    
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dotSymmetric(_: Matrix<Double>, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dotSymmetric(_: Matrix<Double>, multiplied: Double, into: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dotSymmetric(_: Matrix<Double>, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Vector<Double>.dotSymmetric(_: Matrix<Double>, multiplied: Double, addingInto: Vector<Double>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )

    //MARK: Matrix-Matrix operations
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.add(_: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.add(_: Matrix<Double>, multiplied: Double)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B, multiplied: alpha)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.multiply(by: Double)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._multiplyBLAS(by: alpha)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.copyElements(from: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElements(from: B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElementsBLAS(from: B)
        })
    )

    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Matrix<Double>, into: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: 1.0, into: &C)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Matrix<Double>, multiplied: Double, into: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Matrix<Double>, addingInto: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: 1.0, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(_: Matrix<Double>, multiplied: Double, addingInto: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, addingInto: &C)
        })
    )
    
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(symmetricSide: SymmetricSide, _: Matrix<Double>, into: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in
            A._dotBLAS(symmetricSide: .left, B, into: &C)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(symmetricSide: SymmetricSide, _: Matrix<Double>, multiplied: Double, into: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(symmetricSide: .left, B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(symmetricSide: SymmetricSide, _: Matrix<Double>, addingInto: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(symmetricSide: .left, B, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationDouble(name: "Matrix<Double>.dot(symmetricSide: SymmetricSide, _: Matrix<Double>, multiplied: Double, addingInto: Matrix<Double>)", runs: 20, iterations: 1000, maxDimension: 35, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(symmetricSide: .left, B, multiplied: alpha, addingInto: &C)
        })
    )
    return results
}