import SML
import CVulkan
public class Stardust{
    let window : Window
    let device : Device
    let renderer : Renderer
    let pipeline : Pipeline
    var isRunning = true

    


    public init(){
        window = Window()
        device = Device(window: window)
     
        renderer = Renderer(device: device, window: window)
        pipeline = Pipeline(device: device, renderer: renderer, vertexPath: "Shaders/vertex.spv", fragmentPath: "Shaders/frag.spv", bindings: Model.getBindingDescription(), attributes: Model.getAttributeDescription())
        eventsystem.register(callback: self.callback)
    }
    public  func run(){
        var models : [Model] = []
        

        var colors = [
            Vector3D<Float>(x: 1, y: 0.7, z: 0.73), 
            Vector3D<Float>(x: 1.0, y: 0.87, z: 0.73), 
            Vector3D<Float>(x: 1.0, y: 1.0, z: 0.73), 
            Vector3D<Float>(x: 0.73, y: 1.0, z: 0.8),
            Vector3D<Float>(x: 0.73, y: 0.88, z: 1.0)
        ]
        for  index  in  colors.indices {
            colors[index].x =  powf(colors[index].x, 2.2)
            colors[index].y =  powf(colors[index].y, 2.2)
            colors[index].z =  powf(colors[index].z, 2.2)
        }

        for it in 0...40{

           
            let coordX = Model.Vertex(position: Vector2D<Float>(x: 0.0, y: -0.5), color: colors[it % colors.count])
            let coordY = Model.Vertex(position: Vector2D<Float>(x: 0.5, y: 0.5), color: colors[it % colors.count])        
            let coordZ = Model.Vertex(position: Vector2D<Float>(x: -0.5, y: 0.5), color: colors[it % colors.count])
           
            let vertices = [coordX, coordY, coordZ]

            var model = Model(device: device, renderer: renderer, vertices: vertices)
           
            models.append(model)
        }




        while isRunning {
            window.searchEvents()
            renderer.beginFrame(device: device)
            renderer.beginRenderpass(pipeline: pipeline, device: device)
            for (idx, _) in models.enumerated(){
                let flags = UInt32(VK_SHADER_STAGE_VERTEX_BIT.rawValue | VK_SHADER_STAGE_FRAGMENT_BIT.rawValue)
                vkCmdPushConstants(renderer.commandBuffers[renderer.swapChainManager.currentFrame]!, pipeline.pipelineLayout, flags, 0, UInt32(24), withUnsafePointer(to: models[idx].pushConstants){$0})
                models[idx].bind(commandBuffer: renderer.commandBuffers[renderer.swapChainManager.currentFrame]!)
                models[idx].draw(commandBuffer: renderer.commandBuffers[renderer.swapChainManager.currentFrame]!)

            }
            renderer.endRenderPass()
            renderer.endFrame() 
            

            if let result : Bool =  try? renderer.swapChainManager.submitCommandBuffers(commandBuffer: renderer.commandBuffers[renderer.swapChainManager.currentFrame]!, device: device, pipeline: pipeline){
                if result == false {
                    renderer.swapChainManager.recreateSwapChain(device: device, window: window)
                }
            }

        
        }
    }

    func callback(event : EventType){
        switch(event){
            case is WindowClose: isRunning = false;
            default: break;
        }
    }


}



