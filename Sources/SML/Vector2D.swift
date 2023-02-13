public struct Vector2D<T: FloatingPoint>{
    public var x, y : T
    public init(x: T, y: T){
        (self.x, self.y) = (x, y)
    }

    public init(_ x: T,_ y: T){
        (self.x, self.y) = (x, y)
    }

    public init(){
        self.x = 0
        self.y = 0
    }


}

extension Vector2D{
   
    static func + (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: Vector2D, right: Vector2D) -> Vector2D {
        return Vector2D(x: left.x - right.x, y: left.y - right.y)
    }

    static func += (left: inout Vector2D, right: Vector2D){
        left = left + right
    }

    static func -= (left: inout Vector2D, right: Vector2D){
        left = left - right
    }

    
    static func * (left: Vector2D, right: Vector2D) -> T {
        return (left.x * right.x) + (left.y + right.y)
    }

    static func * (left: T, right: Vector2D) -> Vector2D {
        Vector2D(x: right.x * left, y: right.y * left)
    }


    static func * (left: Vector2D, right: T) -> Vector2D {
        Vector2D(x: left.x * right, y: left.y * right)
    }


    static func *= (left: inout Vector2D, right: T){
        left = right * left
    }

    public func mod() -> T {
        let inside = (self.x * self.x) + (self.y * self.y)
        return inside.squareRoot()
    }
}




extension Vector2D{
   public subscript(index: Int) -> T {
        get {
            switch index {
            case 0: return x
            case 1: return y
            default: assert(index < 4, "Error: Trying to access a vector 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
            return 0
        }
        set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            default: assert(index < 4, "Error: Trying to access a vector 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
        }
    }
}