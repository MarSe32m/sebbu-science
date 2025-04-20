#if os(Windows)
import WinSDK
#elseif os(Linux)
import Glibc
// Musl doesn't support dynamic library loading
#endif

#if os(Windows)
@inlinable
@inline(__always)
func loadLibrary(name: String) -> HMODULE? {
    if let handle = LoadLibraryA(name) {
        return handle
    }
    return nil
}

@inlinable
@inline(__always)
func loadSymbol<T>(name: String, handle: HMODULE?, as type: T.Type = T.self) -> T? {
    guard let handle else { return nil }
    if let symbol = GetProcAddress(handle, name) {
        return unsafeBitCast(symbol, to: type)
    }
    return nil
}
#elseif os(Linux)
@inlinable
@inline(__always)
func loadLibrary(name: String) -> UnsafeMutableRawPointer? {
    if let handle = dlopen(name, RTLD_NOW | RTLD_LOCAL) {
        return handle
    }
    return nil
}

@inlinable
@inline(__always)
func loadSymbol<T>(name: String, handle: UnsafeMutableRawPointer?, as type: T.Type = T.self) -> T? {
    guard let handle else { return nil }
    if let symbol = dlsym(handle, name) {
        return unsafeBitCast(symbol, to: type)
    }
    print("Failed to load symbol \(name): \(getDLErrorMessage())")
    return nil
}

@inlinable
func getDLErrorMessage() -> String {
    return String(cString: dlerror())
}
#endif