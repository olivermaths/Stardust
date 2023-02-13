import CVulkan
import CStardust

class Device{
    struct QueueFamilyIndices{
        let presentQueueIndex : Optional<UInt32>
        let computeQueueIndex : Optional<UInt32>
        let transferQueueIndex : Optional<UInt32>
        var count : UInt32 {
            get {
                    let values = [presentQueueIndex, computeQueueIndex, transferQueueIndex].compactMap { $0 }
                    return UInt32(values.count)
            }
        }
    }

    struct SwapChainSupportDetails{
        var capabilities : VkSurfaceCapabilitiesKHR
        var formats : Array<VkSurfaceFormatKHR>
        var presentModes : Array<VkPresentModeKHR>
    }


    let instance : VkInstance
    let device : VkDevice
    let physicalDevice : VkPhysicalDevice
    let presentQueue, computeQueue, transferQueue : VkQueue
    let indices : QueueFamilyIndices
    let surface                : VkSurfaceKHR
   init(window: Window){
        self.instance = csdCreateVkInstance("Triangle")
        self.physicalDevice = csdPickPhysicalDevice(instance)
        self.indices = Device.pickQueueFamilyIndices(physicalDevice: physicalDevice)
        var queueInfos = Device.createDevice(physicalDevice: physicalDevice, indices: indices)
        self.device =       csdCreateDevice(physicalDevice, queueInfos.withUnsafeMutableBufferPointer({$0.baseAddress}))
        self.presentQueue = csdGetQueue(device, indices.presentQueueIndex!, 0)
        self.computeQueue = csdGetQueue(device, indices.computeQueueIndex!, 0)
        self.transferQueue = csdGetQueue(device, indices.transferQueueIndex!, 0)
        self.surface = window.createSurface(instance: instance)
   }


}

extension Device{
   static func createDevice(physicalDevice: VkPhysicalDevice, indices: QueueFamilyIndices) -> [VkDeviceQueueCreateInfo] {
        var queueInfos = [VkDeviceQueueCreateInfo]()
        var priority : Float = 1.0
        let pointer = withUnsafePointer(to: priority){$0}
        if let presentQueueIndex = indices.presentQueueIndex {
            var presentQueueInfo = VkDeviceQueueCreateInfo()
            presentQueueInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
            presentQueueInfo.queueFamilyIndex = presentQueueIndex
            presentQueueInfo.queueCount = 1
            presentQueueInfo.pQueuePriorities = pointer 
            queueInfos.append(presentQueueInfo)
        }
        priority = 1.0
        if let computeQueueIndex = indices.computeQueueIndex {
            var computeQueueInfo = VkDeviceQueueCreateInfo()
            computeQueueInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
            computeQueueInfo.queueFamilyIndex = computeQueueIndex
            computeQueueInfo.queueCount = 1
            computeQueueInfo.pQueuePriorities = pointer
            queueInfos.append(computeQueueInfo)
        }
          priority = 1.0
        if let transferQueueIndex = indices.transferQueueIndex {
            var transferQueueInfo = VkDeviceQueueCreateInfo()
            transferQueueInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO
            transferQueueInfo.queueFamilyIndex = transferQueueIndex
            transferQueueInfo.queueCount = 1
            transferQueueInfo.pQueuePriorities = pointer
            queueInfos.append(transferQueueInfo)
        }
        return queueInfos;
   }


}




extension Device {
    static func pickQueueFamilyIndices(physicalDevice: VkPhysicalDevice) -> Device.QueueFamilyIndices {
        var queueFamilyCount : UInt32 = 0
        var presetQueueIndex : Optional<UInt32> = nil
        var computeQueueIndex : Optional<UInt32> = nil
        var transferQueueIndex : Optional<UInt32> = nil
        vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, nil)

        var queueFamilies = Array(repeating: VkQueueFamilyProperties(), count: Int(queueFamilyCount))

        queueFamilies.withUnsafeMutableBufferPointer({
            vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, $0.baseAddress)
        })
        for (index, queueFamily) in queueFamilies.enumerated(){
            if Int(queueFamily.queueFlags & UInt32(VK_QUEUE_GRAPHICS_BIT.rawValue)) != 0 {
                    presetQueueIndex = UInt32(index)
            } 
            if Int(Int(queueFamily.queueFlags)  & Int(VK_QUEUE_COMPUTE_BIT.rawValue)) != 0 && queueFamily.queueCount > 1
            {
                computeQueueIndex = UInt32(index)
            }
            if  Int(Int(queueFamily.queueFlags)  & Int(VK_QUEUE_TRANSFER_BIT.rawValue)) != 0,
                Int(Int(queueFamily.queueFlags)  & Int(VK_QUEUE_GRAPHICS_BIT.rawValue)) == 0,
                Int(Int(queueFamily.queueFlags)  & Int(VK_QUEUE_COMPUTE_BIT.rawValue)) == 0
            {
                         transferQueueIndex  = UInt32(index)
            }
        }
        return Device.QueueFamilyIndices(presentQueueIndex: presetQueueIndex,  computeQueueIndex: computeQueueIndex, transferQueueIndex: transferQueueIndex)
    }

    func querySwapChainSupport() -> Device.SwapChainSupportDetails {
        var supportDetails = Device.SwapChainSupportDetails(capabilities: VkSurfaceCapabilitiesKHR(), formats: [], presentModes: [])

        vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface,  withUnsafeMutablePointer(to: &supportDetails.capabilities){$0})
        var count : UInt32 = 0 
        vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &count, nil)
        supportDetails.formats = Array(repeating: VkSurfaceFormatKHR(), count: Int(count))
        vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &count, supportDetails.formats.withUnsafeMutableBufferPointer({$0.baseAddress}))
        count = 0
        vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &count, nil)
        supportDetails.presentModes = Array(repeating: VkPresentModeKHR(0), count: Int(count))

        vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &count, supportDetails.presentModes.withUnsafeMutableBufferPointer({$0.baseAddress}))
        return supportDetails;
    }

    func copyBuffer(srcBuffer: VkBuffer, dstBuffer: VkBuffer, size: UInt64, commandPool: VkCommandPool){
            var allocInfo = VkCommandBufferAllocateInfo ()
            allocInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO
            allocInfo.level = VK_COMMAND_BUFFER_LEVEL_PRIMARY
            allocInfo.commandPool = commandPool
            allocInfo.commandBufferCount = 1
    
            var commandBuffer : VkCommandBuffer?
            vkAllocateCommandBuffers(device, &allocInfo, &commandBuffer);

            var beginInfo = VkCommandBufferBeginInfo ()
            beginInfo.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO
            beginInfo.flags = UInt32(VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT.rawValue)
            vkBeginCommandBuffer(commandBuffer, &beginInfo);

            var copyRegion = VkBufferCopy()
            copyRegion.srcOffset = 0
            copyRegion.dstOffset = 0
            copyRegion.size = size
            vkCmdCopyBuffer(commandBuffer, srcBuffer, dstBuffer, 1,  &copyRegion)
            vkEndCommandBuffer(commandBuffer)

            var submitInfo = VkSubmitInfo()
            submitInfo.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO
            submitInfo.commandBufferCount = 1
            submitInfo.pCommandBuffers = withUnsafePointer(to: commandBuffer){$0}

            vkQueueSubmit(transferQueue, 1, &submitInfo, nil);
            vkQueueWaitIdle(transferQueue);

            vkFreeCommandBuffers(device, commandPool, 1, &commandBuffer)
    }


    


}