#include <stdio.h>
#include <cuda_runtime.h>

__global__ void bitonicSortKernel(int *arr, int j, int k, int n)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i >= n)
    {
        return;
    }

    int ixj = i ^ j;

    if (ixj > i)
    {
        if ((i & k) == 0)
        {
            if (arr[i] > arr[ixj])
            {
                int temp = arr[i];
                arr[i] = arr[ixj];
                arr[ixj] = temp;
            }
        }
        else
        {
            if (arr[i] < arr[ixj])
            {
                int temp = arr[i];
                arr[i] = arr[ixj];
                arr[ixj] = temp;
            }
        }
    }
}

int main()
{
    int n = 1024;

    int *h_arr = (int *)malloc(n * sizeof(int));

    srand(42);

    for (int i = 0; i < n; i++)
    {
        h_arr[i] = rand() % 100000;
    }

    int *d_arr;
    cudaError_t error;

    // Allocate memory on GPU
    error = cudaMalloc((void **)&d_arr, n * sizeof(int));

    if (error != cudaSuccess)
    {
        printf("cudaMalloc Error: %s\n",
               cudaGetErrorString(error));
        return 1;
    }

    // Copy array from CPU to GPU
    error = cudaMemcpy(
        d_arr,
        h_arr,
        n * sizeof(int),
        cudaMemcpyHostToDevice
    );

    if (error != cudaSuccess)
    {
        printf("Host to Device Copy Error: %s\n",
               cudaGetErrorString(error));

        cudaFree(d_arr);
        return 1;
    }

    // CUDA configuration
    int threadsPerBlock = 256;
    int blocksPerGrid =
        (n + threadsPerBlock - 1) / threadsPerBlock;

    // Bitonic Sort
   /* for (int k = 2; k <= n; k *= 2)
    {
        for (int j = k / 2; j > 0; j /= 2)
        {
            bitonicSortKernel<<<blocksPerGrid, threadsPerBlock>>>(
                d_arr,
                j,
                k,
                n
            );

            error = cudaDeviceSynchronize();

            if (error != cudaSuccess)
            {
                printf("CUDA Kernel Error: %s\n",
                       cudaGetErrorString(error));

                cudaFree(d_arr);
                return 1;
            }
        }
    }*/
   for (int k = 2; k <= n; k *= 2)
{
    for (int j = k / 2; j > 0; j /= 2)
    {
        bitonicSortKernel<<<blocksPerGrid, threadsPerBlock>>>(
            d_arr,
            j,
            k,
            n
        );

        error = cudaGetLastError();

        if (error != cudaSuccess)
        {
            printf("Kernel Launch Error: %s\n",
                   cudaGetErrorString(error));

            cudaFree(d_arr);
            return 1;
        }

        error = cudaDeviceSynchronize();

        if (error != cudaSuccess)
        {
            printf("Kernel Execution Error: %s\n",
                   cudaGetErrorString(error));

            cudaFree(d_arr);
            return 1;
        }
    }
}

    // Copy sorted array from GPU to CPU
    error = cudaMemcpy(
        h_arr,
        d_arr,
        n * sizeof(int),
        cudaMemcpyDeviceToHost
    );

    if (error != cudaSuccess)
    {
        printf("Device to Host Copy Error: %s\n",
               cudaGetErrorString(error));

        cudaFree(d_arr);
        return 1;
    }

    // Print result
    int sorted = 1;

    for (int i = 1; i < n; i++)
    {
        if (h_arr[i - 1] > h_arr[i])
        {
            sorted = 0;
            break;
        }
    }

    printf("Array Size: %d\n", n);
    printf("Sorted Correctly: %s\n", sorted ? "YES" : "NO");

    // Free GPU memory
    cudaFree(d_arr);

    return 0;
}