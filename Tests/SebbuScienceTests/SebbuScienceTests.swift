import Testing
@testable import SebbuScience

struct SebbuScienceTests {
    @Test("BLAS loading")
    func testBLASLoading() {
        #if os(Windows) || os(Linux)
        #expect(BLAS.sgemm != nil)
        #expect(BLAS.saxpy != nil)
        #expect(BLAS.sscal != nil)
        #expect(BLAS.sgemv != nil)

        #expect(BLAS.sdot != nil)
        #expect(BLAS.dgemm != nil)
        #expect(BLAS.daxpy != nil)
        #expect(BLAS.dscal != nil)
        #expect(BLAS.dgemv != nil)
        #expect(BLAS.ddot != nil)

        #expect(BLAS.cgemm != nil)
        #expect(BLAS.caxpy != nil)
        #expect(BLAS.cscal != nil)
        #expect(BLAS.csscal != nil)
        #expect(BLAS.cgemv != nil)
        #expect(BLAS.cdotu_sub != nil)
        #expect(BLAS.cdotc_sub != nil)

        #expect(BLAS.zgemm != nil)
        #expect(BLAS.zaxpy != nil)
        #expect(BLAS.zscal != nil)
        #expect(BLAS.zdscal != nil)
        #expect(BLAS.zgemv != nil)
        #expect(BLAS.zdotu_sub != nil)
        #expect(BLAS.zdotc_sub != nil)
        #endif
    }

    @Test("LAPACKE loading")
    func testLAPACKELoading() {
        #if os(Windows) || os(Linux)
        #expect(LAPACKE.ssyevd != nil)
        #expect(LAPACKE.sgeev != nil)
        #expect(LAPACKE.sgesv != nil)
        #expect(LAPACKE.sgetri != nil)
        #expect(LAPACKE.sgetrf != nil)
        #expect(LAPACKE.dsyevd != nil)
        #expect(LAPACKE.dgeev != nil)
        #expect(LAPACKE.dgesv != nil)
        #expect(LAPACKE.dgetri != nil)
        #expect(LAPACKE.dgetrf != nil)
        #expect(LAPACKE.cheevd != nil)
        #expect(LAPACKE.cgeev != nil)
        #expect(LAPACKE.cgesv != nil)
        #expect(LAPACKE.cgetri != nil)
        #expect(LAPACKE.cgetrf != nil)
        #expect(LAPACKE.zheevd != nil)
        #expect(LAPACKE.zgeev != nil)
        #expect(LAPACKE.zgesv != nil)
        #expect(LAPACKE.zgetri != nil)
        #expect(LAPACKE.zgetrf != nil)
        #endif
    }
}
