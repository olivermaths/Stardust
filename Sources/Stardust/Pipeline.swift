import CStardust
import Foundation
import SML
import CVulkan
class Pipeline{
    struct PipelineConfig{
        internal init() {
            self.scissor = VkRect2D(offset: VkOffset2D(), extent: VkExtent2D())
            self.viewPort = VkViewport()
            self.viewPortInfo = VkPipelineViewportStateCreateInfo()
            self.inputAssemblyInfo = VkPipelineInputAssemblyStateCreateInfo()
            self.rasterizationInfo = VkPipelineRasterizationStateCreateInfo()
            self.multisampleInfo = VkPipelineMultisampleStateCreateInfo()
            self.colorBlendAttachment = VkPipelineColorBlendAttachmentState()
            self.colorBlendInfo = VkPipelineColorBlendStateCreateInfo()
            self.depthStencilInfo = VkPipelineDepthStencilStateCreateInfo()
        }

        var scissor : VkRect2D
        var viewPort :VkViewport
        var viewPortInfo : VkPipelineViewportStateCreateInfo
        var inputAssemblyInfo : VkPipelineInputAssemblyStateCreateInfo
        var rasterizationInfo : VkPipelineRasterizationStateCreateInfo 
        var multisampleInfo : VkPipelineMultisampleStateCreateInfo
        var colorBlendAttachment : VkPipelineColorBlendAttachmentState
        var colorBlendInfo : VkPipelineColorBlendStateCreateInfo
        var depthStencilInfo : VkPipelineDepthStencilStateCreateInfo
    }




    let vertexShader : VkShaderModule
    let fragShader : VkShaderModule
    let pipelineLayout : VkPipelineLayout
    let graphicPipeline : VkPipeline?

    init(device: Device, renderer: Renderer,  vertexPath: String, fragmentPath: String, bindings: Array<VkVertexInputBindingDescription>, attributes: Array<VkVertexInputAttributeDescription>){
        let vertexData = try? Data(contentsOf: URL(fileURLWithPath: vertexPath))
        let fragData  = try? Data(contentsOf: URL(fileURLWithPath: fragmentPath))
        vertexShader = Pipeline.createShaderModule(device: device,  data: vertexData!)
        fragShader = Pipeline.createShaderModule(device: device,  data: fragData!)
        pipelineLayout = Pipeline.createPipelineLayout(device: device)
        graphicPipeline = Pipeline.createGraphicPipeline(
            device: device, 
            layout: pipelineLayout, 
            renderPass: renderer.getSwapChainRenderPass(), 
            bindings: bindings, 
            attributes:attributes, 
            vertexShader: vertexShader, 
            fragShader: fragShader, 
            subpass: renderer.swapChainManager.subPass, 
            extent: renderer.getSwapChainExtent()
            )
    }
}


extension Pipeline{
   static func createShaderModule(device: Device, data: Data) -> VkShaderModule {
        let pCode = data.withUnsafeBytes({
            return $0.baseAddress?.assumingMemoryBound(to: UInt32.self)
        })
        var shader : VkShaderModule?;
        var shaderInfo = VkShaderModuleCreateInfo()
        shaderInfo.sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO
        shaderInfo.codeSize = data.count
        shaderInfo.pCode = pCode
        vkCreateShaderModule(device.device, &shaderInfo, nil, &shader)
        return shader!
    }


    static func createPipelineLayout(device: Device) -> VkPipelineLayout {
        var pipelineLayout : VkPipelineLayout?
        var pushInfo = VkPushConstantRange()
        pushInfo.stageFlags = UInt32(VK_SHADER_STAGE_VERTEX_BIT.rawValue | VK_SHADER_STAGE_FRAGMENT_BIT.rawValue)
        pushInfo.offset = 0
        pushInfo.size = 24
        var infos = VkPipelineLayoutCreateInfo()
        infos.sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO
        infos.pSetLayouts = nil
        infos.setLayoutCount = 0
        infos.pushConstantRangeCount = 1
        infos.pPushConstantRanges = withUnsafePointer(to: pushInfo){$0}

        vkCreatePipelineLayout(device.device, &infos, nil, &pipelineLayout)

        return pipelineLayout!
    }


    static func createGraphicPipelineConfig(extent: VkExtent2D) -> Pipeline.PipelineConfig {
        var config : PipelineConfig = PipelineConfig()
        config.inputAssemblyInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO
        config.inputAssemblyInfo.topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST
        config.inputAssemblyInfo.primitiveRestartEnable = 0

        config.viewPort.height =  Float(extent.height)
        config.viewPort.width =  Float(extent.width)
        config.viewPort.x = 0.0
        config.viewPort.y = 0.0
        config.viewPort.minDepth = 0.0
        config.viewPort.maxDepth  = 1.0

        config.scissor.extent = extent
        config.scissor.offset = VkOffset2D(x: 0, y: 0)

        config.rasterizationInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO
        config.rasterizationInfo.depthClampEnable = 0
        config.rasterizationInfo.rasterizerDiscardEnable = 0
        config.rasterizationInfo.polygonMode = VK_POLYGON_MODE_FILL
        config.rasterizationInfo.cullMode = 0
        config.rasterizationInfo.frontFace = VK_FRONT_FACE_CLOCKWISE
        config.rasterizationInfo.depthBiasEnable = 0
        config.rasterizationInfo.depthBiasConstantFactor = 0.0
        config.rasterizationInfo.depthBiasClamp = 0.0
        config.rasterizationInfo.depthBiasSlopeFactor = 0.0
        config.rasterizationInfo.lineWidth = 1.0
  
        config.multisampleInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO
        config.multisampleInfo.sampleShadingEnable = 0
        config.multisampleInfo.rasterizationSamples = VK_SAMPLE_COUNT_1_BIT
        config.multisampleInfo.minSampleShading = 1.0
        config.multisampleInfo.pSampleMask = nil
        config.multisampleInfo.alphaToCoverageEnable = 0
        config.multisampleInfo.alphaToOneEnable = 0

        
        config.colorBlendAttachment.colorWriteMask = UInt32(VK_COLOR_COMPONENT_R_BIT.rawValue | VK_COLOR_COMPONENT_G_BIT.rawValue | VK_COLOR_COMPONENT_B_BIT.rawValue | VK_COLOR_COMPONENT_A_BIT.rawValue)
        config.colorBlendAttachment.blendEnable = 0
        config.colorBlendAttachment.srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA   // Optional
        config.colorBlendAttachment.dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA  // Optional
        config.colorBlendAttachment.colorBlendOp = VK_BLEND_OP_ADD              // Optional
        config.colorBlendAttachment.srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE   // Optional
        config.colorBlendAttachment.dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO  // Optional
        config.colorBlendAttachment.alphaBlendOp = VK_BLEND_OP_ADD  
        
        
        config.colorBlendInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO
        config.colorBlendInfo.logicOpEnable = 0
        config.colorBlendInfo.logicOp = VK_LOGIC_OP_COPY
        config.colorBlendInfo.attachmentCount = 1
        config.colorBlendInfo.pAttachments = nil
        config.colorBlendInfo.blendConstants = (0.0, 0.0, 0.0, 0.0)

        
        config.depthStencilInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO
        config.depthStencilInfo.depthTestEnable = 1
        config.depthStencilInfo.depthWriteEnable = 1
        config.depthStencilInfo.depthCompareOp = VK_COMPARE_OP_LESS
        config.depthStencilInfo.depthBoundsTestEnable = 0
        config.depthStencilInfo.minDepthBounds = 0.0  // Optional
        config.depthStencilInfo.maxDepthBounds = 1.0  // Optional
        config.depthStencilInfo.stencilTestEnable = 0
        config.depthStencilInfo.front = VkStencilOpState()  // Optional
        config.depthStencilInfo.back = VkStencilOpState()



        config.viewPortInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO
        config.viewPortInfo.viewportCount = 1
        config.viewPortInfo.pViewports = nil
        config.viewPortInfo.scissorCount = 1

        return config
    }


    static func createGraphicPipeline(
        device: Device,
        layout: VkPipelineLayout,
        renderPass: VkRenderPass,
        bindings: Array<VkVertexInputBindingDescription>,
        attributes: Array<VkVertexInputAttributeDescription>,
        vertexShader: VkShaderModule, 
        fragShader: VkShaderModule,
        subpass: UInt32,
        extent: VkExtent2D
        )-> VkPipeline {
        var graphicPipeline : VkPipeline?
        var config = Pipeline.createGraphicPipelineConfig(extent: extent)

        config.colorBlendInfo.pAttachments = withUnsafePointer(to: &config.colorBlendAttachment){$0}
        config.viewPortInfo.pViewports = withUnsafePointer(to: &config.viewPort){$0}
        config.viewPortInfo.pScissors = withUnsafePointer(to: &config.scissor){$0}

        var shadesStages = [VkPipelineShaderStageCreateInfo(), VkPipelineShaderStageCreateInfo()]

        shadesStages[0].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
        shadesStages[0].stage = VK_SHADER_STAGE_VERTEX_BIT
        shadesStages[0].module = vertexShader
        shadesStages[0].pName = stringToCString("main")
        shadesStages[0].flags = 0
        shadesStages[0].pNext = nil

        shadesStages[1].sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO
        shadesStages[1].stage = VK_SHADER_STAGE_FRAGMENT_BIT
        shadesStages[1].module = fragShader
        shadesStages[1].pName = stringToCString("main")
        shadesStages[1].flags = 0
        shadesStages[1].pNext = nil


        let dynamicStates = [VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR]

        var dynamicStateInfo = VkPipelineDynamicStateCreateInfo()
        dynamicStateInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO
        dynamicStateInfo.dynamicStateCount = 2
        dynamicStateInfo.pDynamicStates = dynamicStates.withUnsafeBufferPointer({$0.baseAddress})

        var vertexInputInfo = VkPipelineVertexInputStateCreateInfo()
        vertexInputInfo.sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO
        vertexInputInfo.vertexAttributeDescriptionCount = UInt32(attributes.count)
        vertexInputInfo.pVertexAttributeDescriptions = attributes.withUnsafeBufferPointer({$0.baseAddress})
        vertexInputInfo.vertexBindingDescriptionCount = 1
        vertexInputInfo.pVertexBindingDescriptions = bindings.withUnsafeBufferPointer({$0.baseAddress})
        vertexInputInfo.pNext = nil
        vertexInputInfo.flags = 0

        var graphicPipelineInfo = VkGraphicsPipelineCreateInfo()
	    graphicPipelineInfo.sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO
	    graphicPipelineInfo.pNext = nil
        graphicPipelineInfo.stageCount = 2
        graphicPipelineInfo.pStages = shadesStages.withUnsafeBufferPointer({$0.baseAddress})
        graphicPipelineInfo.pVertexInputState =   withUnsafePointer(to: vertexInputInfo){$0}
        graphicPipelineInfo.pInputAssemblyState = withUnsafePointer(to: config.inputAssemblyInfo){$0}
        graphicPipelineInfo.pViewportState = withUnsafePointer(to: &config.viewPortInfo){$0}
        graphicPipelineInfo.pRasterizationState = withUnsafePointer(to: &config.rasterizationInfo){$0}
        graphicPipelineInfo.pMultisampleState = withUnsafePointer(to: &config.multisampleInfo){$0}
        graphicPipelineInfo.pColorBlendState = withUnsafePointer(to: &config.colorBlendInfo){$0}
        graphicPipelineInfo.layout = layout
        graphicPipelineInfo.renderPass = renderPass
        graphicPipelineInfo.subpass = subpass
        graphicPipelineInfo.pDynamicState = withUnsafePointer(to: &dynamicStateInfo){$0}
        graphicPipelineInfo.basePipelineHandle = nil
        graphicPipelineInfo.pTessellationState = nil

        let result = vkCreateGraphicsPipelines(device.device, nil, 1, &graphicPipelineInfo, nil, &graphicPipeline)
        return graphicPipeline!
    }

}