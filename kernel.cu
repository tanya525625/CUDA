#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#define N 10

__global__ void addVect(int *a, int *b, int *c)
{
	//int i = threadIdx.x;
	int i = blockIdx.x;
	c[i] = a[i] + b[i];
}

void add(int *a, int *b, int *c)
{
	int *dev_a;
	int *dev_b;
	int *dev_c;

	cudaMalloc((void**)&dev_a, N * sizeof(int));
	cudaMalloc((void**)&dev_b, N * sizeof(int));

	cudaMemcpy(dev_a, a, N * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(dev_b, b, N * sizeof(int), cudaMemcpyHostToDevice);

	//addVect <<<1, N >>> (dev_a, dev_b, dev_c);
	//addVect <<<1, 1>>> (dev_a, dev_b, dev_c);
	addVect << <N, 1 >> > (dev_a, dev_b, dev_c);

	cudaDeviceSynchronize();
	cudaMemcpy(c, dev_c, N * sizeof(int), cudaMemcpyDeviceToHost);

}

//void add(int *a, int *b, int *c) {
//      int tid = 0;    // this is CPU zero, so we start at zero
//      while (tid < N) {
//              c[tid] = a[tid] + b[tid];
//              tid += 1;   // we have one CPU, so we increment by one
//      }
//}

int main(void)
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


