#if canImport(COpenBLAS) || canImport(_COpenBLASWindows)
public typealias blasint = Int32
public typealias lapack_int = Int32
#elseif canImport(Accelerate)
import Accelerate
public typealias blasint = __LAPACK_int
public typealias lapack_int = __LAPACK_int
#endif