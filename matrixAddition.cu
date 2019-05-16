#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <iostream>

using namespace std;

#define N 10 // rows
#define M 10 // columns
#define Num_threads_x 2
#define Num_threads_y 4
#define Num_elements 100

__global__ void addMatrixCUDA(const int *a, const int *b, int *c)
{
        int x = blockIdx.x * blockDim.x + threadIdx.x;
        int y = blockIdx.y * blockDim.y + threadIdx.y;
        int i = y * N + x;
        if (i < Num_elements)
                c[i] = a[i] + b[i];

}

void addMatrix(int *a, int *b, int *c)
{
        int *dev_a;
        int *dev_b;
        int *dev_c;

        dim3 blocks(Num_elements/Num_threads_x, Num_elements/Num_threads_y);
        dim3 threads(Num_threads_x, Num_threads_y);

        cudaMalloc((void**)&dev_c, Num_elements * sizeof(int));
        cudaMalloc((void**)&dev_a, Num_elements * sizeof(int));
        cudaMalloc((void**)&dev_b, Num_elements * sizeof(int));

        cudaMemcpy(dev_a, a, Num_elements * sizeof(int), cudaMemcpyHostToDevice);
        cudaMemcpy(dev_b, b, Num_elements * sizeof(int), cudaMemcpyHostToDevice);

        addMatrixCUDA << <blocks, threads >> > (dev_a, dev_b, dev_c);

        cudaDeviceSynchronize();

        cudaMemcpy(c, dev_c, Num_elements * sizeof(int), cudaMemcpyDeviceToHost);
}

int main()
{
        int a[Num_elements], b[Num_elements], c[Num_elements];
        for (int i = 0; i < Num_elements; i++)
        {
                a[i] = -i;
                b[i] = i * i;
        }
        addMatrix(a, b, c);
        for (int i = 0; i < N; i++)
        {
                for (int j = 0; j < M; j++)
                {
                        int idx = i * N + j;
                        cout << c[idx] << '\t';
                }
                cout << endl;
        }

    return 0;
}

