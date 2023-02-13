public struct Matrix2D <T : FloatingPoint>{
    private var c1 : Vector2D<T>
    private var c2 : Vector2D<T>

    public init(_ diagonal: T){
        (c1, c2) = (Vector2D(1, 0), Vector2D(0, 1))
    }
}

extension Matrix2D {
   public subscript(index: Int) -> Vector2D<T> {
        get {
            switch index {
            case 0: return c1
            case 1: return c2
            default: 
                assert(index < 4, "Error: Trying to access a matrix 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
            return Vector2D()
        }
        set {
            switch index {
            case 0: c1 = newValue
            case 1: c2 = newValue
            default: 
                assert(index < 4, "Error: Trying to access a matrix 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
        }
    }

   public subscript(col: Int, row: Int) -> T {
        get {
            return self[col][row]
        }
        set {
            return self[col][row] = newValue
        }
    }
}


extension Matrix2D{

    
    public static func * (left: Matrix2D<T>, right: Matrix2D<T>) -> Matrix2D<T> {
        var r = Matrix2D(1)
        r[0][0] = (left[0][0] * right[0][0]) + (left[1][0] * right[0][1])
      
        r[0][1] = (left[0][1] * right[0][0]) + (left[1][1] * right[0][1]) 
       
        r[1][0] = (left[0][0] * right[1][0]) + (left[1][0] * right[1][1])
        
        r[1][1] = (left[0][1] * right[1][0]) + (left[1][1] * right[1][1])

        return r
    }

}