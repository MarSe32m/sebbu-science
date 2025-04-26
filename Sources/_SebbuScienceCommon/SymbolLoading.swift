//
//  SymbolLoading.swift
//  swift-science
//
//  Created by Sebastian Toivonen on 19.4.2025.
//

#if canImport(WinSDK)
import WinSDK
#elseif canImport(Glibc)
import Glibc
// Musl doesn't support dynamic library loading
#elseif canImport(Darwin)
import Darwin
#endif

#if os(Windows)
@inlinable
public func loadLibrary(name: String) -> HMODULE? {
    if let handle = LoadLibraryA(name) {
        return handle
    }
    return nil
}

@inlinable
public func loadSymbol<T>(name: String, handle: HMODULE?, as type: T.Type = T.self) -> T? {
    guard let handle else { return nil }
    if let symbol = GetProcAddress(handle, name) {
        return unsafeBitCast(symbol, to: type)
    }
    return nil
}

#elseif os(Linux)
@inlinable
public func loadLibrary(name: String) -> UnsafeMutableRawPointer? {
    if let handle = dlopen(name, RTLD_NOW | RTLD_LOCAL) {
        return handle
    }
    return nil
}

@inlinable
public func loadSymbol<T>(name: String, handle: UnsafeMutableRawPointer?, as type: T.Type = T.self) -> T? {
    guard let handle else { return nil }
    if let symbol = dlsym(handle, name) {
        return unsafeBitCast(symbol, to: type)
    }
    return nil
}

@inlinable
public func getDLErrorMessage() -> String {
    return String(cString: dlerror())
}
#elseif os(macOS)
@inlinable
public func loadLibrary(name: String) -> UnsafeMutableRawPointer? {
    if let handle = dlopen(name, RTLD_NOW | RTLD_LOCAL) {
        return handle
    }
    return nil
}

@inlinable
public func loadSymbol<T>(name: String, handle: UnsafeMutableRawPointer?, as type: T.Type = T.self) -> T? {
    guard let handle else { return nil }
    if let symbol = dlsym(handle, name) {
        return unsafeBitCast(symbol, to: type)
    }
    return nil
}

@inlinable
public func getDLErrorMessage() -> String {
    return String(cString: dlerror())
}
#endif
