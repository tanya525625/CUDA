#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#define N 100
#define num_threads 10

__global__ void addVect(int *a, int *b, int *c)
{
	int i = blockIdx.x * blockDim.x + threadIdx.x;
	c[i] = a[i] + b[i];
}

void add(int *a, int *b, int *c)
{
	int *dev_a;
	int *dev_b;
	int *dev_c;

	cudaMalloc((void**)&dev_c, N * sizeof(int));
	cudaMalloc((void**)&dev_a, N * sizeof(int));
	cudaMalloc((void**)&dev_b, N * sizeof(int));

	cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice);

	int num_blocks = (N + num_threads - 1) / num_threads;
	addVect <<< num_blocks, num_threads >>> (dev_a, dev_b, dev_c);

	cudaDeviceSynchronize();
	cudaMemcpy(c, dev_c, N * sizeof(int), cudaMemcpyDeviceToHost);

}
int main()
{
	int a[N], b[N], c[N];
	for (int i = 0; i < N; i++)
	{
		a[i] = -i;
		b[i] = i * i;
	}

	add(a, b, c);

	// display the results
	for (int i = 0; i < N; i++)
	{
		printf("%d + %d = %d\n", a[i], b[i], c[i]);
	}

	return 0;
}
