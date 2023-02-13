struct Vector4D <T: FloatingPoint>{
    var x, y, z, w : T

    init(){
        self.x = 0
        self.y = 0
        self.z = 0
        self.w = 0
    }

    init(_ x: T,_  y: T,_  z: T,_  w: T){
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }

  init(x: T = 0.0, y: T = 0.0, z: T = 0.0, w: T = 0.0){
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }


}


extension Vector4D {

    


}



extension Vector4D{
    subscript(index: Int) -> T {
        get {
            switch index {
            case 0: return x
            case 1: return y
            case 2: return z
            case 3: return w
            default: assert(index < 4, "Error: Trying to access a vector 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
            return 0
        }
        set {
            switch index {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            case 3: w = newValue
            default: assert(index < 4, "Error: Trying to access a vector 4D out of bounds. Index: \(index), File: \(#file), Line: \(#line)")
            }
        }
    }
}
