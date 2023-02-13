#include "include/CStardust.h"
#include <glfw/glfw3.h>
#include <stdint.h>
#include <stdio.h>
#include <signal.h>

#ifndef __RELEASE__
#define COLOR_RED "\033[1;31m"
#define COLOR_RESET "\033[0m"

#define c_assert(value)                                                        \
  if (!(value)) {                                                              \
    cc_assert(#value, __FILE__, __LINE__);                                     \
  }

#define cc_assert(value, file, line)                                           \
  printf(COLOR_RED "assertion failed: " value                                  \
                   " in %s : Line %i\n" COLOR_RESET,                           \
         file, line);                                                          \
  raise(SIGINT);

#else
#define c_assert(value)
#endif
VkInstance csdCreateVkInstance(const char* applicationName){
        VkInstance instance;

        VkApplicationInfo appinfo = {
            .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
            .apiVersion = VK_API_VERSION_1_3,
            .pApplicationName = applicationName,
            .applicationVersion = VK_MAKE_VERSION(1, 0, 0),
            .pEngineName = "Firehill",
            .engineVersion = VK_MAKE_VERSION(1, 0, 0)
        };
        /*! FIXME: Implement check for validation layer support here. */
        /*
        uint32_t layerCount = 0;
        c_assert(vkEnumerateInstanceLayerProperties(&layerCount, NULL) == VK_SUCCESS);

        struct VkLayerProperties layers[layerCount];
        c_assert(vkEnumerateInstanceLayerProperties(&layerCount, layers) == VK_SUCCESS);
        */

        const char *requiredValidationLayers[] = {"VK_LAYER_KHRONOS_validation"};

        uint32_t count;
        const char **extensions = glfwGetRequiredInstanceExtensions(&count);

        VkInstanceCreateInfo instanceInfo = {
            .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
            .pApplicationInfo = &appinfo,
            .enabledExtensionCount = count,
            .ppEnabledExtensionNames = extensions,
            .enabledLayerCount = 1,
            .ppEnabledLayerNames = requiredValidationLayers,
        };

        c_assert(vkCreateInstance(&instanceInfo, 0, &instance) ==VK_SUCCESS);

        c_assert(instance != NULL);
        return instance;
}



VkPhysicalDevice csdPickPhysicalDevice(VkInstance instance){
        VkPhysicalDevice physicalDevice;

        uint32_t deviceCount = 0;
        c_assert(
            vkEnumeratePhysicalDevices(instance, &deviceCount, NULL) == VK_SUCCESS
        );
        
        
        VkPhysicalDevice devices[deviceCount];
        
        c_assert(vkEnumeratePhysicalDevices(instance, &deviceCount,devices) == VK_SUCCESS);

        for (size_t i = 0; i < deviceCount; i++) {
            VkPhysicalDeviceProperties props;
            vkGetPhysicalDeviceProperties(devices[i], &props);
            if (props.deviceType == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU) {
                physicalDevice = devices[i];
                break;
            } else {
                physicalDevice = devices[i];
            }
        }

        c_assert(physicalDevice != VK_NULL_HANDLE);
        return physicalDevice;
}

VkDevice csdCreateDevice(VkPhysicalDevice physicalDevice, VkDeviceQueueCreateInfo  *queuesInfos){
    VkDevice device;
        const char *requiredDeviceExtensions[] = { VK_KHR_SWAPCHAIN_EXTENSION_NAME };
        VkDeviceCreateInfo deviceCreateInfo = {
            .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
            .queueCreateInfoCount = 3,
            .pQueueCreateInfos = queuesInfos,
            .enabledExtensionCount = 1,
            .ppEnabledExtensionNames = requiredDeviceExtensions
        };


        c_assert(vkCreateDevice(physicalDevice, &deviceCreateInfo, NULL, &device) == VK_SUCCESS);
        return device;
}

VkQueue csdGetQueue(VkDevice device, uint32_t familyIndex,uint32_t queueIndex){
    VkQueue queue;
    vkGetDeviceQueue(device, familyIndex, queueIndex, &queue);
    return queue;
}

const char* stringToCString(const char* str){
    return str;
}