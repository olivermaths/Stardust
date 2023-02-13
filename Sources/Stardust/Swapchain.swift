import CVulkan

internal enum PresentModesKHR : UInt32 {
    case MODE_IMMEDIATE_KHR       = 0
    case MODE_MAILBOR_KHR         = 1
    case MODE_FIFO_KHR            = 2
    case MODE_FIFO_RELAXED_KHR    = 3
}
internal enum Formats : UInt32 {
    case B8G8R8A8_SRGB = 50
}


class SwapChainManager {
    internal init(device: Device, window: Window) {
        (swapChain, swapChainImageFormat, swapChainExtent) = SwapChainManager.createSwapChain(device: device, window: window)
        self.renderPass = SwapChainManager.createRenderpass(swapChainFormat: swapChainImageFormat, device: device)
        swapChainFrameBuffers = []
        swapChainImages = []
        swapChainImageViews = []
        imageAvailableSemaphores = Array(repeating: SwapChainManager.createSemaphore(device: device), count: 3)
        renderFinishedSemaphores = Array(repeating: SwapChainManager.createSemaphore(device: device), count: 3)
        inFlightFences           = Array(repeating: SwapChainManager.createFence(device: device), count: 3)
        var count : UInt32 = 0
        vkGetSwapchainImagesKHR(device.device, swapChain, &count, nil);

        swapChainImages = Array(repeating: nil, count: Int(count))
        swapChainImageViews = Array(repeating: nil, count: Int(count))
        swapChainFrameBuffers = Array(repeating: nil, count: Int(count))
        
        swapChainImages.withUnsafeMutableBufferPointer({pointer in
                vkGetSwapchainImagesKHR(device.device, swapChain, &count, pointer.baseAddress);
                return ()
        })


        for (index, image) in swapChainImages.enumerated(){
            var imageViewInfo = VkImageViewCreateInfo(
                sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, 
                pNext: nil, 
                flags:  0, 
                image: image, 
                viewType: VK_IMAGE_VIEW_TYPE_2D, 
                format: swapChainImageFormat, 
                components: VkComponentMapping(r: VK_COMPONENT_SWIZZLE_IDENTITY, g: VK_COMPONENT_SWIZZLE_IDENTITY, b: VK_COMPONENT_SWIZZLE_IDENTITY, a: VK_COMPONENT_SWIZZLE_IDENTITY), 
                subresourceRange: VkImageSubresourceRange(
                    aspectMask: UInt32(VK_IMAGE_ASPECT_COLOR_BIT.rawValue), 
                    baseMipLevel: 0, 
                    levelCount: 1, 
                    baseArrayLayer: 0, 
                    layerCount: 1
                    )
                )
                vkCreateImageView(device.device, &imageViewInfo, nil, &swapChainImageViews[index])
                var  framebufferInfo = VkFramebufferCreateInfo()
                    framebufferInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
                    framebufferInfo.renderPass = renderPass
                    framebufferInfo.attachmentCount = 1
                    framebufferInfo.pAttachments = withUnsafePointer(to: swapChainImageViews[index]){$0}
                    framebufferInfo.width = swapChainExtent.width
                    framebufferInfo.height =  swapChainExtent.height
                    framebufferInfo.layers = 1
                vkCreateFramebuffer(device.device, &framebufferInfo, nil, &swapChainFrameBuffers[index])
        }

    }



    // SwapChain Specifics
    var swapChain              : VkSwapchainKHR
    var swapChainImageFormat   : VkFormat
    var swapChainExtent        : VkExtent2D
    var swapChainFrameBuffers  : Array<VkFramebuffer?>
    var swapChainImages        : Array<VkImage?>
    var swapChainImageViews    : Array<VkImageView?>
    
    
    var renderPass             : VkRenderPass?
    
    // var depthImages            : Array<VkImage>?
    // var depthImagesMemorys     : Array<VkDeviceMemory>?
    // var depthImageViews        : Array<VkImageView>?

    // var windowExtent           : VkExtent2D?

    var imageAvailableSemaphores : Array<VkSemaphore>
    var renderFinishedSemaphores : Array<VkSemaphore>
    var inFlightFences           : Array<VkFence?>
    
    // var imagesInFlight           : Array<VkFence>?

    var currentFrame             : Int = 0
    var imageIndex               : UInt32 = 0
    var isFrameStarted           : Bool = false
    
    var subPass                  : UInt32 = 0
}




extension SwapChainManager {
    func cleanUpSwapChain(device: Device){
        for frameBuffer in swapChainFrameBuffers{
            vkDestroyFramebuffer(device.device, frameBuffer, nil)
        }
        for imageView in swapChainImageViews {
            vkDestroyImageView(device.device, imageView, nil)
        }
        vkDestroySwapchainKHR(device.device, self.swapChain, nil)
    }


    func recreateSwapChain(device: Device, window: Window){
        vkDeviceWaitIdle(device.device)
        cleanUpSwapChain(device: device)
        (swapChain, swapChainImageFormat, swapChainExtent) = SwapChainManager.createSwapChain(device: device, window: window)
        var count : UInt32 = 0
        vkGetSwapchainImagesKHR(device.device, swapChain, &count, nil);
        swapChainImages.withUnsafeMutableBufferPointer({pointer in
                vkGetSwapchainImagesKHR(device.device, swapChain, &count, pointer.baseAddress);
                return ()
        })
        
        for (index, image) in swapChainImages.enumerated(){
            var imageViewInfo = VkImageViewCreateInfo(
                sType: VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, 
                pNext: nil, 
                flags:  0, 
                image: image, 
                viewType: VK_IMAGE_VIEW_TYPE_2D, 
                format: swapChainImageFormat, 
                components: VkComponentMapping(r: VK_COMPONENT_SWIZZLE_IDENTITY, g: VK_COMPONENT_SWIZZLE_IDENTITY, b: VK_COMPONENT_SWIZZLE_IDENTITY, a: VK_COMPONENT_SWIZZLE_IDENTITY), 
                subresourceRange: VkImageSubresourceRange(
                    aspectMask: UInt32(VK_IMAGE_ASPECT_COLOR_BIT.rawValue), 
                    baseMipLevel: 0, 
                    levelCount: 1, 
                    baseArrayLayer: 0, 
                    layerCount: 1
                    )
                )
                vkCreateImageView(device.device, &imageViewInfo, nil, &swapChainImageViews[index])
                var  framebufferInfo = VkFramebufferCreateInfo()
                    framebufferInfo.sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO
                    framebufferInfo.renderPass = renderPass
                    framebufferInfo.attachmentCount = 1
                    framebufferInfo.pAttachments = withUnsafePointer(to: swapChainImageViews[index]){$0}
                    framebufferInfo.width = swapChainExtent.width
                    framebufferInfo.height =  swapChainExtent.height
                    framebufferInfo.layers = 1
                vkCreateFramebuffer(device.device, &framebufferInfo, nil, &swapChainFrameBuffers[index])
        }


    }


    func acquireNextImage(device: Device) -> VkResult {
        vkWaitForFences(device.device, 1, &self.inFlightFences[self.currentFrame], 1, UInt64.max)
        let result = vkAcquireNextImageKHR(device.device, self.swapChain, UInt64.max, self.imageAvailableSemaphores[self.currentFrame] , nil, &self.imageIndex)
        vkResetFences(device.device, 1, &self.inFlightFences[self.currentFrame])
        return result
    }

    func submitCommandBuffers(commandBuffer: VkCommandBuffer, device: Device, pipeline: Pipeline) throws -> Bool{
        var waitStages = [UInt32(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue)]
        
        var submitInfo = VkSubmitInfo()
        submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
        submitInfo.waitSemaphoreCount = 1
        submitInfo.pWaitSemaphores = withUnsafePointer(to: self.imageAvailableSemaphores[self.currentFrame]){$0}
        submitInfo.pWaitDstStageMask = waitStages.withUnsafeBufferPointer({$0.baseAddress})
        submitInfo.commandBufferCount = 1
        submitInfo.pCommandBuffers = withUnsafePointer(to: commandBuffer){$0}
        submitInfo.signalSemaphoreCount = 1
        submitInfo.pSignalSemaphores =  withUnsafePointer(to: self.renderFinishedSemaphores[self.currentFrame]){$0}

        vkQueueSubmit(device.presentQueue, 1, &submitInfo, self.inFlightFences[self.currentFrame])

        var presentInfo = VkPresentInfoKHR()
        presentInfo.sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR
        presentInfo.waitSemaphoreCount = 1
        presentInfo.pWaitSemaphores = withUnsafePointer(to: self.renderFinishedSemaphores[self.currentFrame]){$0}
        presentInfo.swapchainCount = 1
        presentInfo.pSwapchains = withUnsafePointer(to: self.swapChain){$0}
        presentInfo.pImageIndices = withUnsafePointer(to: self.imageIndex){$0}
        presentInfo.pResults = nil
        let result = vkQueuePresentKHR(device.presentQueue, &presentInfo)
        self.currentFrame = (self.currentFrame + 1) % 3
        if result.rawValue ==  -1000001004 || result.rawValue == 1000001003{
            return false
        }
        if result.rawValue != 0 {
            throw DrawError.errorOnPresentation;
        }
        return true
    }
}

enum DrawError : Error{
    case SwapChainInvalid
    case errorOnPresentation
}







extension SwapChainManager {
    static func createSwapChain(device: Device, window: Window) -> (VkSwapchainKHR, VkFormat, VkExtent2D) {
        var swapChain : VkSwapchainKHR?
        let support = device.querySwapChainSupport()
        var imageCount = support.capabilities.minImageCount
        if  imageCount == 1,
            (imageCount + 2) < support.capabilities.maxImageCount
        {
            imageCount = 3
        }
        let format = SwapChainManager.chooseSwapSurfaceFormat(formatsAvailable: support.formats)
        let presentMode = SwapChainManager.chooseSwapSurfacePresentMode(presentModesAvailable: support.presentModes)
        let extent = SwapChainManager.chooseSwapExtent(capabilities: support.capabilities, window: window)
        
        
        var swapInfo = VkSwapchainCreateInfoKHR()
        swapInfo.sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR
        swapInfo.surface = device.surface
        swapInfo.minImageCount = imageCount
        swapInfo.clipped = 1
        swapInfo.imageFormat = format.format
        swapInfo.imageColorSpace = format.colorSpace
        swapInfo.imageExtent = extent
        swapInfo.imageArrayLayers = 1
        swapInfo.imageUsage = UInt32(VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT.rawValue)
        swapInfo.presentMode = VkPresentModeKHR(Int32(presentMode))
        swapInfo.preTransform = support.capabilities.currentTransform
        swapInfo.compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR

        swapInfo.imageSharingMode = VK_SHARING_MODE_CONCURRENT
        swapInfo.queueFamilyIndexCount = 2
        swapInfo.pQueueFamilyIndices = [device.indices.presentQueueIndex!, device.indices.transferQueueIndex!].withUnsafeBufferPointer({$0.baseAddress})
        
        vkCreateSwapchainKHR(device.device, &swapInfo, nil, &swapChain)

        return (swapChain!, format.format, extent)
    }
    


    static func createRenderpass(swapChainFormat: VkFormat, device: Device) -> VkRenderPass {
        var renderPass : VkRenderPass?

        var colorAttachment = VkAttachmentDescription()
        colorAttachment.format = swapChainFormat
        colorAttachment.samples = VK_SAMPLE_COUNT_1_BIT
        colorAttachment.loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR
        colorAttachment.storeOp = VK_ATTACHMENT_STORE_OP_STORE
        colorAttachment.initialLayout = VK_IMAGE_LAYOUT_UNDEFINED
        colorAttachment.finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR
        

        var colorAttachmentRef = VkAttachmentReference()
        colorAttachmentRef.attachment = 0
        colorAttachmentRef.layout = VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL

        var dependency = VkSubpassDependency()
        dependency.srcSubpass = VK_SUBPASS_EXTERNAL
        dependency.dstSubpass = 0
        dependency.srcStageMask = UInt32(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue)
        dependency.srcAccessMask = 0
        dependency.dstStageMask = UInt32(VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT.rawValue)
        dependency.dstAccessMask = UInt32(VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT.rawValue)

        var subpass = VkSubpassDescription()
        subpass.pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS
        subpass.colorAttachmentCount = 1
        subpass.pColorAttachments = withUnsafePointer(to: &colorAttachmentRef){$0}
        

        var renderPassInfo = VkRenderPassCreateInfo()
        renderPassInfo.sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO
        renderPassInfo.attachmentCount = 1
        renderPassInfo.pAttachments = withUnsafePointer(to: &colorAttachment){$0}
        renderPassInfo.subpassCount = 1
        renderPassInfo.pSubpasses = withUnsafePointer(to: &subpass){$0}
        renderPassInfo.dependencyCount = 1
        renderPassInfo.pDependencies = withUnsafePointer(to: &dependency){$0}

        
        
        vkCreateRenderPass(device.device, &renderPassInfo, nil, &renderPass)

        return renderPass!
    }




    static func chooseSwapSurfacePresentMode(presentModesAvailable: Array<VkPresentModeKHR>)-> UInt32{
        for presentMode in presentModesAvailable {
            if presentMode.rawValue == 1 {
                return PresentModesKHR.MODE_MAILBOR_KHR.rawValue
            }
        }
        return PresentModesKHR.MODE_FIFO_KHR.rawValue
    }


    static func chooseSwapExtent(capabilities: VkSurfaceCapabilitiesKHR, window: Window) -> VkExtent2D {
        return window.getFrameBufferSize()
    }

    static func chooseSwapSurfaceFormat(formatsAvailable: Array<VkSurfaceFormatKHR>) -> VkSurfaceFormatKHR {
        
        for format in formatsAvailable{
            if  format.format.rawValue == Formats.B8G8R8A8_SRGB.rawValue, 
                format.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR
            {
                return format
            }
        }
        return formatsAvailable.first!
    }

    static func createFence(device: Device) -> VkFence {
        var fence : VkFence?
        var info = VkFenceCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO
        info.flags = UInt32(VK_FENCE_CREATE_SIGNALED_BIT.rawValue)
        vkCreateFence(device.device, &info, nil, &fence)
        return fence!
    }

    static func createSemaphore(device: Device) -> VkSemaphore {
        var semaphore : VkSemaphore?
        var info   = VkSemaphoreCreateInfo()
        info.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO
        vkCreateSemaphore(device.device, &info, nil, &semaphore)
        return semaphore!
    }
}