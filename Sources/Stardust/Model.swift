import CVulkan
import SML

struct Model{
    struct Vertex<T: FloatingPoint>{
        var position: Vector2D<T>
        var color : Vector3D<T>
        init(position: Vector2D<T> = Vector2D<T>(), color: Vector3D<T>){
            self.position = position
            self.color = color
        }
    }

    struct PushConstant<T: FloatingPoint>{
        var transform   : Matrix2D<T>
        var offset      : Vector2D<T>
        init(vec: Vector2D<T> = Vector2D<T>(), rotation: Matrix2D<T> = Matrix2D<T>(1)){
            self.offset = vec
            self.transform = rotation
        }
    }
    
    var vertexBuffer : VkBuffer
    var vertexBufferMemory : VkDeviceMemory
    var vertexCount : UInt32
    var pushConstants : PushConstant<Float>

    init<T: FloatingPoint>(device: Device, renderer: Renderer, vertices: Array<Vertex<T>>, pushConstants : PushConstant<Float> = PushConstant()){
        vertexCount = UInt32(vertices.count)
        self.pushConstants = pushConstants
        assert(vertexCount >= 3, "Vertex count must be at least 3")
        
        let bufferSize : UInt64 = UInt64(MemoryLayout.size(ofValue: vertices[0])) * UInt64(vertexCount)
        let verterxBufferMemoryFlags : UInt32 = UInt32(VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT.rawValue)
        
        vertexBuffer = Model.createVertexBuffer(device: device, size:UInt64(bufferSize), usage: UInt32(VK_BUFFER_USAGE_TRANSFER_DST_BIT.rawValue | VK_BUFFER_USAGE_VERTEX_BUFFER_BIT.rawValue))
        
        vertexBufferMemory = MemoryManager.allocateDeviceMemory(device: device, buffer: vertexBuffer, propertiesRequired: verterxBufferMemoryFlags)



        let stagingBuffer = Model.createVertexBuffer(device: device, size:UInt64(bufferSize), usage: UInt32(VK_BUFFER_USAGE_TRANSFER_SRC_BIT.rawValue))
        let stagingBufferFlags : UInt32 = UInt32(VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT.rawValue | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT.rawValue)
        let stagingBufferMemory = MemoryManager.allocateDeviceMemory(device: device, buffer: stagingBuffer, propertiesRequired: stagingBufferFlags)

        var data : UnsafeMutableRawPointer?
        
        vkMapMemory(device.device, stagingBufferMemory, 0, UInt64(bufferSize), 0, withUnsafeMutablePointer(to: &data){$0})
        
        vertices.withUnsafeBufferPointer({
            memcpy(data, $0.baseAddress, Int(bufferSize))
            return ()
        })
        vkUnmapMemory(device.device, stagingBufferMemory)

        device.copyBuffer(srcBuffer: stagingBuffer, dstBuffer: vertexBuffer, size: bufferSize, commandPool: renderer.commandPools[1])
    }

}


extension Model {
    static func createVertexBuffer(device: Device, size: UInt64, usage: UInt32)-> VkBuffer{
        var buffer : VkBuffer?
        var createInfo = VkBufferCreateInfo()
        createInfo.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO
        createInfo.size = size
        createInfo.usage = usage
        createInfo.sharingMode = VK_SHARING_MODE_EXCLUSIVE
        vkCreateBuffer(device.device, &createInfo, nil, &buffer)
        return buffer!
    }
}

extension Model {
        static func getBindingDescription() -> Array<VkVertexInputBindingDescription>{
            var bindingsDescriptions = [VkVertexInputBindingDescription()]
            bindingsDescriptions[0].binding = 0 
            bindingsDescriptions[0].stride = 20
            bindingsDescriptions[0].inputRate = VK_VERTEX_INPUT_RATE_VERTEX
            return bindingsDescriptions
        }
        static func getAttributeDescription() -> Array<VkVertexInputAttributeDescription>{
            var attributeDescriptions = [VkVertexInputAttributeDescription(), VkVertexInputAttributeDescription()]
            attributeDescriptions[0].binding = 0 
            attributeDescriptions[0].location = 0
            attributeDescriptions[0].format  = VK_FORMAT_R32G32_SFLOAT 
            attributeDescriptions[0].offset  = 0

            attributeDescriptions[1].binding  = 0 
            attributeDescriptions[1].location = 1
            attributeDescriptions[1].format   = VK_FORMAT_R32G32B32_SFLOAT
            attributeDescriptions[1].offset   = 8
            return attributeDescriptions
        }
}


extension Model {
    func bind(commandBuffer: VkCommandBuffer){
        var buffers : [VkBuffer?] = [ vertexBuffer ]
        var offsets: [UInt64] = [0]
        let pbuffers = buffers.withUnsafeBufferPointer({ $0.baseAddress});
        let pOffesets = offsets.withUnsafeBufferPointer({$0.baseAddress});
        vkCmdBindVertexBuffers(commandBuffer, 0, 1, pbuffers, pOffesets)
    }
    
    func draw(commandBuffer: VkCommandBuffer){
        vkCmdDraw(commandBuffer, vertexCount, 1, 0, 0)
    }
}

extension Model {}