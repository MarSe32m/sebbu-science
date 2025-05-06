//
//  PythonKitUtilities.swift
//  sebbu-science
//
//  Created by Sebastian Toivonen on 6.5.2025.
//

@_exported import PythonKit

public let _plt =  {
    let __plt = Python.import("matplotlib.pyplot")
    PythonUtils.registerSIGINT()
    return __plt
}()

public let _wdg = {
    let __wdg = Python.import("matplotlib.widgets")
    return __wdg
}()

public enum PythonUtils {
    //To make cmd+C interrupts work when showing a matplotlib plot
    public static func registerSIGINT() {
        let signal = Python.import("signal")
        signal.signal(signal.SIGINT, signal.SIG_DFL)
    }
}

public enum plt {
    @discardableResult
    public static func figure() -> PythonObject {
        _plt.figure()
    }

    public static func subplots(nrows: Int = 1, ncols: Int = 1) -> (fig: PythonObject, ax: PythonObject) {
        let obj = _plt.subplots(nrows: nrows, ncols: ncols)
        return (obj[0], obj[1])
    }
    
    public static func plot(x: [Double], y: [Double], label: String? = nil, linestyle: String? = nil, linewidth: Double? = nil) {
        switch (label, linestyle, linewidth) {
        case (.some(let label), .none, .none):
            _plt.plot(x, y, label: label)
        case (.some(let label), .some(let linestyle), .none):
            _plt.plot(x, y, label: label, linestyle: linestyle)
        case (.some(let label), .none, .some(let linewidth)):
            _plt.plot(x, y, label: label, linewidth: linewidth)
        case (.some(let label), .some(let linestyle), .some(let linewidth)):
            _plt.plot(x, y, label: label, linestyle: linestyle, linewidth: linewidth)
        case (.none, .some(let linestyle), .none):
            _plt.plot(x, y, linestyle: linestyle)
        case (.none, .some(let linestyle), .some(let linewidth)):
            _plt.plot(x, y, linestyle: linestyle, linewidth: linewidth)
        case (.none, .none, .some(let linewidth)):
            _plt.plot(x, y, linewidth: linewidth)
        case (.none, .none, .none):
            _plt.plot(x, y)
        }
    }
    
    public static func show() {
        _plt.show()
    }
    
    public static func close() {
        _plt.close()
    }
    
    public static func xlabel(_ label: String) {
        _plt.xlabel(label)
    }
    
    public static func ylabel(_ label: String) {
        _plt.ylabel(label)
    }
    
    public static func legend() {
        _plt.legend()
    }
    
    public static func title(_ _title: String) {
        _plt.title(_title)
    }
}
