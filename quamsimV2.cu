/**
 * Copyright 1993-2015 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */

/**
 * Vector addition: C = A + B.
 *
 * This sample is a very basic sample that implements element by element
 * vector addition. It is the same as the sample illustrating Chapter 2
 * of the programming guide with some additions like error checking.
 */

#include <stdio.h>
#include <iostream>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <iterator>
#include <iomanip>
// For the CUDA runtime routines (prefixed with "cuda_")
#include <cuda_runtime.h>
using namespace std;


/**
 * CiiUDA Kernel Device code
 *
 * Computes the vector addition of A and B into C. The 3 vectors have the same
 * number of elements numElements.
 */
__global__ void
vectorQuantumComputing(float *qbit_input_quantum_state, float *qbit_quantum_gate, float *qbit_output_quantum_state,int qbit_value,  int numElements)
{
    
    int i = blockDim.x * blockIdx.x + threadIdx.x;

        if(i < numElements && i % int (__powf(2,(qbit_value+1)))<int (__powf(2,(qbit_value))))
        {
            qbit_output_quantum_state[i] = (qbit_quantum_gate[0] * qbit_input_quantum_state[i] + qbit_quantum_gate[1] * qbit_input_quantum_state[i | (1 << qbit_value)]);
            qbit_output_quantum_state[i | (1 << qbit_value)] = (qbit_quantum_gate[2] * qbit_input_quantum_state[i] + qbit_quantum_gate[3] * qbit_input_quantum_state[i | (1 << qbit_value)]);

        }
    
}

/**
 * Host main routine
 */
int
main(void)
{





    FILE * FP;
    FP=fopen("input.txt","r");
    int number_of_lines;
    char element;
    float qbit_quantum_gate_temp[2][2];


    if(FP==NULL){
        cout<<"File not found"<<endl;
        return 0;
    }

    while (EOF != (element=getc(FP))) {
        if ('\n' == element)
            number_of_lines=number_of_lines+1;
    }
    int numElements = number_of_lines-4;


      float* qbit_input_quantum_state = new float [(number_of_lines-3)];
    float* qbit_output_quantum_state = new float [(number_of_lines-4)];

    cudaMallocManaged(&qbit_input_quantum_state, number_of_lines-3*sizeof(float));
    cudaMallocManaged(&qbit_output_quantum_state, numElements*sizeof(float));


    FP=fopen("input.txt","r");

    int i=0;
    while(fscanf(FP, "%f %f", &qbit_quantum_gate_temp[i][0], &qbit_quantum_gate_temp[i][1]) != EOF)
    {
        i++;
        if (i>1)
        {
            i = 0;
            while (fscanf(FP, "%f ", &qbit_input_quantum_state[i]) != EOF)
            {
                i++;
            }
            break;
        }
    }

    int qbit_value=qbit_input_quantum_state[numElements];



    float* qbit_quantum_gate=new float [4];
    cudaMallocManaged(&qbit_quantum_gate, 4*sizeof(float));
    qbit_quantum_gate[0]=qbit_quantum_gate_temp[0][0];
    qbit_quantum_gate[1]=qbit_quantum_gate_temp[0][1];
    qbit_quantum_gate[2]=qbit_quantum_gate_temp[1][0];
    qbit_quantum_gate[3]=qbit_quantum_gate_temp[1][1];






    // Error code to check return values for CUDA calls
    cudaError_t err = cudaSuccess;

    // Print the vector length to be used, and compute its size







    // Verify that allocations succeeded
    if (qbit_input_quantum_state == NULL || qbit_quantum_gate == NULL || qbit_output_quantum_state == NULL)
    {
        fprintf(stderr, "Failed to allocate host vectors!\n");
        exit(EXIT_FAILURE);
    }

   // cudaMallocManaged(&qbit_input_quantum_state, number_of_lines-3*sizeof(float));
    //cudaMallocManaged(&qbit_output_quantum_state, numElements*sizeof(float));
   // cudaMallocManaged(&qbit_quantum_gate, 4*sizeof(float));

    int threadsPerBlock = 256;
    int blocksPerGrid =(numElements + threadsPerBlock - 1) / threadsPerBlock;
    vectorQuantumComputing<<<blocksPerGrid, threadsPerBlock>>>(qbit_input_quantum_state, qbit_quantum_gate, qbit_output_quantum_state,qbit_value, numElements);
    cudaDeviceSynchronize();
    err = cudaGetLastError();

    if (err != cudaSuccess)
    {
        fprintf(stderr, "Failed to launch vectorAdd kernel (error code %s)!\n", cudaGetErrorString(err));
        exit(EXIT_FAILURE);
    }


    for(int k=0;k<number_of_lines-4;k++)
    {
        cout<<fixed<<setprecision(3)<<qbit_output_quantum_state[k]<<endl;
    }

    // Free host memory
  //  free(qbit_input_quantum_state);
   // free(qbit_quantum_gate);
  //  free(qbit_output_quantum_state);


    // Reset the device and exit
    // cudaDeviceReset causes the driver to clean up all state. While
    // not mandatory in normal operation, it is good practice.  It is also
    // needed to ensure correct operation when the application is being
    // profiled. Calling cudaDeviceReset causes all profile data to be
    // flushed before the application exits
 //   err = cudaDeviceReset();

   // if (err != cudaSuccess)
   // {
     //   fprintf(stderr, "Failed to deinitialize the device! error=%s\n", cudaGetErrorString(err));
       // exit(EXIT_FAILURE);
   // }

    return 0;
}

