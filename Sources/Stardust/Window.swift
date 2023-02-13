import CVulkan
import CGLFW
private var isInitialized = false

class Window{
    let pInstance : OpaquePointer!
    let title : String
    var height, width : UInt32

    init(title: String = "Stardust", height: UInt32 = 600, width: UInt32 = 800){
        self.title = title
        self.height = height
        self.width = width
        if !isInitialized {
            let result = glfwInit();
            if result == GLFW_FALSE{
                print("Failed to initialize GLFW")
                abort()
            }
            isInitialized = true
        }
        glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
        self.pInstance = glfwCreateWindow(Int32(width), Int32(height), title, nil, nil)


        glfwSetWindowCloseCallback(pInstance, {_ in 
            eventsystem.dispath(event: WindowClose())
        })

    }

    func searchEvents(){
        glfwPollEvents()
        
    }
    func createSurface(instance: VkInstance) -> VkSurfaceKHR {
        var surface : VkSurfaceKHR? = nil
        glfwCreateWindowSurface(instance, self.pInstance, nil, withUnsafeMutablePointer(to: &surface){$0})
        return surface!
    }
    func getFrameBufferSize() -> VkExtent2D {
        var width : Int32 = 0
        var height : Int32 = 0
        glfwGetFramebufferSize(self.pInstance, &width, &height)
        print(width, height)
        return VkExtent2D(width: UInt32(width), height: UInt32(height))
    }


    deinit{
        glfwDestroyWindow(self.pInstance)
        glfwTerminate()
    }
}