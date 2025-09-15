import SebbuScience
import FFT
import Foundation

import PythonKit
import PythonKitUtilities

typealias Field = Complex<Double>

func _testLinearLeastSquares() {
    let A: Matrix<Complex<Double>> = .init(elements: [
        Complex(-4.20, -3.44), Complex(-3.35, 1.52), Complex(1.73, 8.85), Complex(2.35, 0.34),
        Complex(-5.43, -8.81), Complex(-4.53, -8.47), Complex(5.93, 3.75), Complex(-3.75, -5.66),
        Complex(-5.56,  3.39), Complex(2.90, -9.22), Complex(8.03,  9.37), Complex(5.69, -0.47)
    ], rows: 3, columns: 4)
    let B: Matrix<Complex<Double>> = .init(elements: [
        Complex(-7.02,  4.80), Complex( 3.88, -2.59),
        Complex( 0.62, -2.40), Complex( 1.57,  3.24),
        Complex( 3.10, -2.19), Complex(-6.93, -5.99),
        Complex( 0.00,  0.00), Complex( 0.00,  0.00)
    ], rows: 4, columns: 2)
    let X = try! Optimize.linearLeastSquares(A: A, B)
    printMatrix(X.result)
}

func _testSolve() {
    let A: Matrix<Double> = .init(elements: [
        6.80, -6.05, -0.45,  8.32, -9.67,
        -2.11, -3.30,  2.58,  2.71, -5.14,
        5.66, 5.36, -2.70,  4.35, -7.26,
        5.97, -4.44,  0.27, -7.17, 6.08,
        8.23, 1.08,  9.04,  2.14, -6.87
    ], rows: 5, columns: 5)
    let B: Matrix<Double> = .init(elements: [
        4.02, -1.56, 9.81,
        6.19,  4.00, -4.09,
        -8.22, -8.67, -4.57,
        -7.57,  1.75, -8.61,
        -3.03,  2.86, 8.99
    ], rows: 5, columns: 3)
    let X = try! MatrixOperations.solve(A: A, B: B)
    printMatrix(X)
}

@main
struct Main {
    public static func main() throws {
        _testSolve()
        _testLinearLeastSquares()
#if os(macOS)
PythonLibrary.useLibrary(at: "/Library/Frameworks/Python.framework/Versions/3.12/Python")
#elseif os(Linux)
//PythonLibrary.useLibrary(at: "/usr/lib64/libpython3.11.so.1.0")
PythonLibrary.useLibrary(at: "/usr/lib/x86_64-linux-gnu/libpython3.12.so.1.0")
#elseif os(Windows)
//TODO: Set the library path on Windows machine
#endif
        #if os(Windows)
        let fileName = "bechmark_results_windows.json"
        #elseif os(Linux)
        let fileName = "benchmark_results_linux.json"
        #elseif os(macOS)
        let fileName = "benchmark_results_macOS.json"
        #endif
        let currentDir = FileManager.default.currentDirectoryPath.appending("/\(fileName)")
        let url = URL(filePath: currentDir)
        var results: [BenchmarkResult] = []
        // Load already existing data
        if let data = try? Data(contentsOf: url) {
            results = try JSONDecoder().decode([BenchmarkResult].self, from: data)
            #if !canImport(Musl)
            for result in results {
                plot(result)
            }
            #endif
        } else {
            let doubleTime = ContinuousClock().measure {
                results.append(contentsOf: testDoubleOperations())
            }
            let floatTime = ContinuousClock().measure {
                results.append(contentsOf: testFloatOperations())
            }
            let complexDoubleTime = ContinuousClock().measure {
                results.append(contentsOf: testComplexDoubleOperations())
            }
            let complexFloatTime = ContinuousClock().measure {
                results.append(contentsOf: testComplexFloatOperations())
            }
            print("Double benchmarks took:        ", doubleTime)
            print("Float benchmarks took:         ", floatTime)
            print("Complex Double benchmarks took:", complexDoubleTime)
            print("Complex Float benchmarks took: ", complexFloatTime)
            print("Total benchmark time:          ", doubleTime + floatTime + complexDoubleTime + complexFloatTime)
            let data = try! JSONEncoder().encode(results)
            try! data.write(to: url)
        }

        
        
        //print("Hello world 2")
        //let mat = Matrix<Complex<Double>>(elements: [Complex(1,2), Complex(2,1), Complex(1,2),
        //                                             Complex(1,2), Complex(2,1), Complex(1,2),
        //                                             Complex(1,2), Complex(2,1), Complex(1,3) ], rows: 3, columns: 3)
        //let vec = Vector<Complex<Double>>([.one, -.one, .one])
        //print(mat.dot(vec))
        //let signal = [10.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 90.0, 10.0]
        //print(FFT.ifft(FFT.fft(signal).spectrum))
    }
}
