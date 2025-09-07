public func testVectorAddingDouble() {
    let result = benchmarkVectorOperationDouble(name: "_add(_:,multiplied:) (Double)", runs: 10, iterations: 1_000, maxDimension: 5000, 
    naiveFunc: { multiplier, x, y in 
        x._add(y)
    }, blasFunc: { multiplier, x, y in
        x._addBLAS(y)
    })
    plot(result)
}

public func testVectorAddingFloat() {
    let result = benchmarkVectorOperationFloat(name: "_add(_:,multiplied:) (Double)", runs: 10, iterations: 1_000, maxDimension: 5000, 
    naiveFunc: { multiplier, x, y in 
        x._add(y)
    }, blasFunc: { multiplier, x, y in
        x._addBLAS(y)
    })
    plot(result)
}