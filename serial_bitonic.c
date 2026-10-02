#include <stdio.h>

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

int main()
{
    //int arr[] = {8, 7, 6, 5, 4, 3, 2, 1};
    //int arr[] = {10, 3, 7, 1, 9, 2, 8, 4};
    int arr[] = {5, 1, 8, 3, 2, 7, 4, 6};
    int n = 8;

    printf("Original array:\n");
    printArray(arr, n);

    bitonicSort(arr, 0, n, 1);

    printf("\nSorted array:\n");
    printArray(arr, n);

    return 0;
}