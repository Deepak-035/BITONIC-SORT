#include <stdio.h>
#include <cuda_runtime.h>

__global__ void testKernel()
{
    printf("Hello from GPU! Thread ID = %d\n", threadIdx.x);
}

int main()
{
    int deviceCount;

    cudaGetDeviceCount(&deviceCount);

    printf("CUDA devices found: %d\n", deviceCount);

    if (deviceCount == 0)
    {
        printf("No CUDA GPU found!\n");
        return 1;
    }

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, 0);

    printf("GPU: %s\n", prop.name);
    printf("Compute Capability: %d.%d\n",
           prop.major, prop.minor);

    testKernel<<<1, 5>>>();

    cudaError_t error = cudaDeviceSynchronize();

    if (error != cudaSuccess)
    {
        printf("CUDA Error: %s\n", cudaGetErrorString(error));
        return 1;
    }

    printf("CUDA kernel executed successfully!\n");

    return 0;
}