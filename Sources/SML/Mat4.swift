public struct Matrix4D <T : FloatingPoint>{
    private var c1 : Vector4D<T>
    private var c2 : Vector4D<T>
    private var c3 : Vector4D<T>
    private var c4 : Vector4D<T>

   public init(_ diagonal: T){
        (c1, c2, c3, c4) = (Vector4D(1, 0, 0, 0), Vector4D(0, 1, 0, 0), Vector4D(0, 0, 1, 0), Vector4D(0, 0, 0, 1))
    }
}


extension Matrix4D {
    subscript(index: Int) -> Vector4D<T> {
        get {
            switch index {
            case 0: return c1
            case 1: return c2
            case 2: return c3
            case 3: return c4
            default: 
                assert(index < 4, "Error: Trying to access a matrix 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
            return Vector4D()
        }
        set {
            switch index {
            case 0: c1 = newValue
            case 1: c2 = newValue
            case 2: c3 = newValue
            case 3: c4 = newValue
            default: 
                assert(index < 4, "Error: Trying to access a matrix 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
        }
    }

    subscript(col: Int, row: Int) -> T {
        get {
            return self[col][row]
        }
        set {
            return self[col][row] = newValue
        }
    }
}
