import SebbuScience
import FFT


@main
struct Main {
    public static func main() {
        print("Hello world 2")
        let mat = Matrix<Complex<Double>>(elements: [Complex(1,2), Complex(2,1), Complex(1,2),
                                                     Complex(1,2), Complex(2,1), Complex(1,2),
                                                     Complex(1,2), Complex(2,1), Complex(1,3) ], rows: 3, columns: 3)
        let vec = Vector<Complex<Double>>([.one, -.one, .one])
        print(mat.dot(vec))

        let signal = [10.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 90.0, 10.0]
        print(FFT.ifft(FFT.fft(signal).spectrum))
    }
}
