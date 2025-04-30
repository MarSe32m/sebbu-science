extension Array where Element: FloatingPoint {
    /// Finds the start index of the interval in the given array in which the value t belongs in.
    /// Uses binary search, i.e., complexity O(log n)
    /// If the value is less than the minimum value of the array or larger than the maximum value
    /// of the array then the first or last index, respectively, will be returned
    /// - Parameters:
    ///   - t: The value we are looking for
    ///   - array: A monotonically increasing array of floating point values
    /// - Returns: The start index for the interval in the given array
    @inlinable
    @inline(__always)
    internal func intervalIndex(_ t: Element) -> Int {
        if t < self[1] || count <= 1 { return 0 }
        if t >= self[count - 2] { return count - 2}
        var min = 0
        var max = count - 1
        var index = (min + max) >> 1
        while min != max - 1 {
            if self[index] == t {
                return index
            } else if self[index] > t {
                max = index
            } else {
                min = index
            }
            index = (min + max) >> 1
        }
        return min
    }
}