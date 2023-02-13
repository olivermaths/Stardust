import CVulkan
class Renderer{
    let swapChainManager : SwapChainManager
    let commandPools : Array<VkCommandPool>
    var commandBuffers : Array<VkCommandBuffer?>
    var transferCommandBuffer : Array<VkCommandBuffer?>
    init(device: Device, window: Window){
        swapChainManager = SwapChainManager(device: device, window: window)
        commandPools = [Renderer.createCommandPool(device: device, familyIndex: device.indices.presentQueueIndex!), Renderer.createCommandPool(device: device, familyIndex: device.indices.transferQueueIndex!)]
       
        transferCommandBuffer = [nil]
        commandBuffers = Array(repeating: nil, count: 3)


        commandBuffers.withUnsafeMutableBufferPointer({
            var allocInfo = VkCommandBufferAllocateInfo()
            allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
            allocInfo.commandPool = commandPools[0]
            allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
            allocInfo.commandBufferCount = 3
            vkAllocateCommandBuffers(device.device, &allocInfo, $0.baseAddress)
        })
    


    }

    func getSwapChainRenderPass () -> VkRenderPass {
        return swapChainManager.renderPass!
    }

    func getSwapChainExtent () -> VkExtent2D {
        return swapChainManager.swapChainExtent
    }

    func beginRenderpass(pipeline: Pipeline, device: Device, _ x: Float = 0 , _ y : Float = 0 , _ z : Float = 0 ) {
        var clearValues = VkClearValue(color: VkClearColorValue(float32: (x, y, z, 0.0)))
        var renderPassInfo = VkRenderPassBeginInfo()
        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO
        renderPassInfo.framebuffer = self.swapChainManager.swapChainFrameBuffers[Int(self.swapChainManager.imageIndex)]
        renderPassInfo.renderPass = swapChainManager.renderPass
        renderPassInfo.renderArea = VkRect2D(offset: VkOffset2D(x: 0, y: 0), extent: swapChainManager.swapChainExtent)
        renderPassInfo.clearValueCount = 1
        renderPassInfo.pClearValues = withUnsafePointer(to: clearValues){$0}

        vkCmdBeginRenderPass(commandBuffers[swapChainManager.currentFrame],  &renderPassInfo, VK_SUBPASS_CONTENTS_INLINE)
        vkCmdBindPipeline(commandBuffers[swapChainManager.currentFrame], VK_PIPELINE_BIND_POINT_GRAPHICS, pipeline.graphicPipeline)

        var viewport = VkViewport()
        viewport.x = 0.0
        viewport.y = 0.0
        viewport.width = Float(swapChainManager.swapChainExtent.width)
        viewport.height = Float(swapChainManager.swapChainExtent.height)
        viewport.minDepth = 0.0
        viewport.maxDepth = 1.0
        vkCmdSetViewport(commandBuffers[self.swapChainManager.currentFrame], 0, 1,  &viewport)

        var scissor = VkRect2D(offset: VkOffset2D(x: 0, y: 0), extent: swapChainManager.swapChainExtent)
        vkCmdSetScissor(commandBuffers[self.swapChainManager.currentFrame], 0, 1, &scissor);
    }   
    func endRenderPass(){
        vkCmdEndRenderPass(commandBuffers[self.swapChainManager.currentFrame])
    }

    func beginFrame(device: Device){
       let result = swapChainManager.acquireNextImage(device: device)
                
        vkResetCommandBuffer(commandBuffers[swapChainManager.currentFrame], 0)
        var beginInfo = VkCommandBufferBeginInfo()
        beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
        vkBeginCommandBuffer(commandBuffers[self.swapChainManager.currentFrame], &beginInfo)
    }

    func endFrame(){
        vkEndCommandBuffer(commandBuffers[self.swapChainManager.currentFrame]);
    }

 

    func draw(){
        
    }

}

extension Renderer{
    static func createCommandPool(device: Device, familyIndex: UInt32) -> VkCommandPool {
        var commandpool : VkCommandPool?
        var infos = VkCommandPoolCreateInfo()
        infos.sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO
        infos.flags = UInt32(VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT.rawValue)
        infos.queueFamilyIndex = familyIndex
        vkCreateCommandPool(device.device, &infos, nil, &commandpool)
        return commandpool!
    }
}