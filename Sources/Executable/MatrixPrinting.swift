import SebbuScience

func printMatrix(_ A: Matrix<Complex<Double>>) {
    for i in 0..<A.rows {
        for j in 0..<A.columns {
            print("( ", String(format: "%.2f", A[i,j].real), ", ", String(format: "%.2f", A[i, j].imaginary), " )", separator: "", terminator: " ")
        }
        print()
    }
}
func printMatrix(_ A: Matrix<Complex<Float>>) {
    for i in 0..<A.rows {
        for j in 0..<A.columns {
            print("( ", String(format: "%.2f", A[i,j].real), ", ", String(format: "%.2f", A[i, j].imaginary), " )", separator: "", terminator: " ")
        }
        print()
    }
}
func printMatrix(_ A: Matrix<Double>) {
    for i in 0..<A.rows {
        for j in 0..<A.columns {
            print(String(format: "%.2f", A[i,j]), separator: "", terminator: " ")
        }
        print()
    }
}
func printMatrix(_ A: Matrix<Float>) {
    for i in 0..<A.rows {
        for j in 0..<A.columns {
            print(String(format: "%.2f", A[i,j]), separator: "", terminator: " ")
        }
        print()
    }
}