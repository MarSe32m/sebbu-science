@_spi(TestUtilities) import SebbuScience

public func testFloatOperations() -> [BenchmarkResult] {
    var results: [BenchmarkResult] = []
    //MARK: Vector-Vector operations
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.add(_: Vector<Float>)", runs: 10, iterations: 10000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.add(_: Vector<Float>, multiplied: Float)", runs: 10, iterations: 10000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._add(y, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._addBLAS(y, multiplied: alpha)
        })
    )

    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.multiply(by: Float)", runs: 10, iterations: 10000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._multiplyBLAS(by: alpha)
        })
    )

    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dot(_:Vector<Float>)", runs: 10, iterations: 10000, maxDimension: 1000, 
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
        benchmarkOperationFloat(name: "Vector<Float>.copyComponents(from: Vector<Float>)", runs: 10, iterations: 10000, maxDimension: 1000, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponents(from: y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._copyComponentsBLAS(from: y)
        })
    )

    //MARK: Matrix-Vector operations
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Vector<Float>, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Vector<Float>, multiplied: Float, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Vector<Float>, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Vector<Float>, multiplied: Float, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )
    
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.symmetricDot(_: Vector<Float>, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.symmetricDot(_: Vector<Float>, multiplied: Float, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, multiplied: alpha, into: &y.components)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.symmetricDot(_: Vector<Float>, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, addingInto: &y.components)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.symmetricDot(_: Vector<Float>, multiplied: Float, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(x, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._symmetricDotBLAS(x.components, multiplied: alpha, addingInto: &y.components)
        })
    )

    //MARK: Vector-Matrix operations
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dot(_: Matrix<Float>, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dot(_: Matrix<Float>, multiplied: Float, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dot(_: Matrix<Float>, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dot(_: Matrix<Float>, multiplied: Float, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )
    
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dotSymmetric(_: Matrix<Float>, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, into: &y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dotSymmetric(_: Matrix<Float>, multiplied: Float, into: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, into: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, multiplied: alpha, into: &y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dotSymmetric(_: Matrix<Float>, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, addingInto: &y)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Vector<Float>.dotSymmetric(_: Matrix<Float>, multiplied: Float, addingInto: Vector<Float>)", runs: 20, iterations: 10000, maxDimension: 50, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            x._dot(A, multiplied: alpha, addingInto: &y)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            x._dotSymmetricBLAS(A, multiplied: alpha, addingInto: &y)
        })
    )

    //MARK: Matrix-Matrix operations
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.add(_: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 100, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.add(_: Matrix<Float>, multiplied: Float)", runs: 20, iterations: 10000, maxDimension: 100, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._add(B, multiplied: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._addBLAS(B, multiplied: alpha)
        })
    )

    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.multiply(by: Float)", runs: 20, iterations: 10000, maxDimension: 100, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._multiply(by: alpha)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._multiplyBLAS(by: alpha)
        })
    )

    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.copyElements(from: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 100, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElements(from: B)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._copyElementsBLAS(from: B)
        })
    )


    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Matrix<Float>, into: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: 1.0, into: &C)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Matrix<Float>, multiplied: Float, into: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Matrix<Float>, addingInto: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: 1.0, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(_: Matrix<Float>, multiplied: Float, addingInto: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(B, multiplied: alpha, addingInto: &C)
        })
    )
    
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(symmetricSide: SymmetricSide, _: Matrix<Float>, into: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in
            A._dotBLAS(symmetricSide: .left, B, into: &C)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(symmetricSide: SymmetricSide, _: Matrix<Float>, multiplied: Float, into: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, into: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(symmetricSide: .left, B, multiplied: alpha, into: &C)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(symmetricSide: SymmetricSide, _: Matrix<Float>, addingInto: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(symmetricSide: .left, B, addingInto: &C)
        })
    )
    results.append(
        benchmarkOperationFloat(name: "Matrix<Float>.dot(symmetricSide: SymmetricSide, _: Matrix<Float>, multiplied: Float, addingInto: Matrix<Float>)", runs: 20, iterations: 10000, maxDimension: 40, 
        naiveFunc: { alpha, beta, x, y, A, B, C in 
            A._dot(B, multiplied: alpha, addingInto: &C)
        }, 
        blasFunc: { alpha, beta, x, y, A, B, C in 
            A._dotBLAS(symmetricSide: .left, B, multiplied: alpha, addingInto: &C)
        })
    )
    return results
}