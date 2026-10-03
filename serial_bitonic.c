#include <stdio.h>
#include<time.h>
#include<stdlib.h>
#include <windows.h>

void swap(int *a, int *b)
{
    int temp = *a;
    *a = *b;
    *b = temp;
}

void bitonicMerge(int arr[], int low, int count, int direction)
{
    if (count > 1)
    {
        int k = count / 2;

        for (int i = low; i < low + k; i++)
        {
            if (direction == 1)
            {
                if (arr[i] > arr[i + k])
                {
                    swap(&arr[i], &arr[i + k]);
                }
            }
            else
            {
                if (arr[i] < arr[i + k])
                {
                    swap(&arr[i], &arr[i + k]);
                }
            }
        }

        bitonicMerge(arr, low, k, direction);
        bitonicMerge(arr, low + k, k, direction);
    }
}

void bitonicSort(int arr[], int low, int count, int direction)
{
    if (count > 1)
    {
        int k = count / 2;

        bitonicSort(arr, low, k, 1);

        bitonicSort(arr, low + k, k, 0);

        bitonicMerge(arr, low, count, direction);
    }
}

void printArray(int arr[], int n)
{
    for (int i = 0; i < n; i++)
    {
        printf("%d ", arr[i]);
    }

    printf("\n");
}

int isPowerOfTwo(int n)
{
    return n > 0 && (n & (n - 1)) == 0;
}

int main(int argc, char *argv[])
{
    

    int i;
    if (argc != 2)
    {
        printf("Usage: serial_bitonic.exe <array_size>\n");
        return 1;
    }

    int n = atoi(argv[1]);
    
    if (!isPowerOfTwo(n))
    {
        printf("Array size must be a power of 2.\n");
        return 1;
    }

    if (n <= 0)
    {
        printf("Array size must be positive.\n");
        return 1;
    }

    int *arr = malloc(n * sizeof(int));

    if (arr == NULL)
    {
        printf("Memory allocation failed.\n");
        return 1;
    }

    srand(42);

    for (i = 0; i < n; i++)
    {
        arr[i] = rand() % 100000;
    }

    LARGE_INTEGER frequency;
    LARGE_INTEGER start;
    LARGE_INTEGER end;

    QueryPerformanceFrequency(&frequency);
    QueryPerformanceCounter(&start);

    bitonicSort(arr, 0, n, 1);

    QueryPerformanceCounter(&end);

    double cpuTime =(double)(end.QuadPart - start.QuadPart) /frequency.QuadPart;
    
    int sorted = 1;

    for (i = 1; i < n; i++)
    {
        if (arr[i - 1] > arr[i])
        {
            sorted = 0;
            break;
        }
    }

    printf("Array Size: %d\n", n);
    printf("Sorted Correctly: %s\n", sorted ? "YES" : "NO");
    printf("CPU Bitonic Sort Time: %.6f seconds\n", cpuTime);

    free(arr);

    return 0;
}