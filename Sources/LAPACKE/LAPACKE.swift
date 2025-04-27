//
//  LAPACKE.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 24.4.2025.
//

import CLAPACK

#if os(Windows) || os(Linux)
public typealias lapack_int = Int32
#elseif os(macOS)
public typealias lapack_int = __LAPACK_int
#endif

public enum LAPACKE {

}