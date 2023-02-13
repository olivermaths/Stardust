import CVulkan
struct MemoryManager{}


extension MemoryManager{

    static func allocateDeviceMemory(device: Device, buffer: VkBuffer, propertiesRequired: UInt32) -> VkDeviceMemory{
        var requirements = VkMemoryRequirements()
        vkGetBufferMemoryRequirements(device.device, buffer, &requirements);
        var memory : VkDeviceMemory?
        var info = VkMemoryAllocateInfo()
        info.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO
        info.allocationSize = requirements.size
        info.memoryTypeIndex = MemoryManager.findMemoryType(device: device, typeFilter: requirements.memoryTypeBits, flags: propertiesRequired)!
        vkAllocateMemory(device.device, &info, nil, &memory)
        vkBindBufferMemory(device.device, buffer, memory, 0)
        return memory!
    }

    static func findMemoryType(device: Device, typeFilter: UInt32, flags: VkMemoryPropertyFlags) -> UInt32? {
        var properties = VkPhysicalDeviceMemoryProperties();
        vkGetPhysicalDeviceMemoryProperties(device.physicalDevice, &properties);
        var memoryTypes: [VkMemoryType] {
          return [VkMemoryType](UnsafeBufferPointer(start: withUnsafePointer(to: properties.memoryTypes.0){$0}, count: MemoryLayout.size(ofValue: properties.memoryTypes)))
        }
        for idx in 0...properties.memoryTypeCount{
            let size = (typeFilter & (1 << idx))
            let filter = memoryTypes[Int(idx)].propertyFlags & flags
            if size != 0 && filter != 0{
                return idx
            }
        }
        return nil
    }


}



