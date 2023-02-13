#ifndef C_STARDUST
#define C_STARDUST
#include <vulkan/vulkan.h>

VkInstance csdCreateVkInstance(const char* applicationName);
VkPhysicalDevice csdPickPhysicalDevice(VkInstance instance);
VkDevice csdCreateDevice(VkPhysicalDevice physicalDevice, VkDeviceQueueCreateInfo  *queuesInfos);
VkQueue csdGetQueue(VkDevice device, uint32_t familyIndex,uint32_t queueIndex);

const char* stringToCString(const char* str);

#endif