# ⚡ Parallel Bitonic Sort — CPU vs NVIDIA CUDA

A performance study and implementation of **Bitonic Sort** using both a **serial CPU implementation in C** and a **parallel CUDA implementation on an NVIDIA RTX 3050 Laptop GPU**.

The project compares CPU and GPU execution time, measures CUDA kernel and end-to-end GPU performance, verifies sorting correctness, and analyzes GPU speedup and scalability for different input sizes.

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Objectives](#-objectives)
- [What is Bitonic Sort?](#-what-is-bitonic-sort)
- [Project Architecture](#-project-architecture)
- [Execution Flow](#-execution-flow)
- [Serial CPU Implementation](#-serial-cpu-implementation)
- [CUDA Parallel Implementation](#-cuda-parallel-implementation)
- [CUDA Kernel Strategy](#-cuda-kernel-strategy)
- [Hardware and Software](#-hardware-and-software)
- [CUDA Environment Setup](#-cuda-environment-setup)
- [Project Structure](#-project-structure)
- [Compilation and Execution](#-compilation-and-execution)
- [Correctness Testing](#-correctness-testing)
- [Benchmark Methodology](#-benchmark-methodology)
- [CPU Benchmark Results](#-cpu-benchmark-results)
- [CUDA Benchmark Results](#-cuda-benchmark-results)
- [Performance Comparison](#-performance-comparison)
- [Speedup Analysis](#-speedup-analysis)
- [Observations](#-observations)
- [GPU Overhead](#-gpu-overhead)
- [Challenges and Solutions](#-challenges-and-solutions)
- [Git Workflow](#-git-workflow)
- [Learning Outcomes](#-learning-outcomes)
- [Future Improvements](#-future-improvements)
- [Conclusion](#-conclusion)

---

# 🚀 Project Overview

This project implements **Bitonic Sort** in two different ways:

### 1. Serial CPU

A recursive Bitonic Sort implementation written in C and executed on the CPU.

### 2. Parallel GPU

A CUDA implementation where multiple GPU threads perform compare-and-swap operations in parallel.

The main purpose is to understand how a parallel sorting algorithm behaves on a GPU compared with a traditional CPU implementation.

---

# 🎯 Objectives

The main objectives of this project are:

- Implement Bitonic Sort using C.
- Implement Bitonic Sort using NVIDIA CUDA.
- Execute the CUDA implementation on an NVIDIA GPU.
- Verify that CPU and GPU produce correctly sorted arrays.
- Measure CPU execution time.
- Measure CUDA kernel execution time.
- Measure total GPU execution time including memory transfers.
- Compare CPU and GPU performance.
- Calculate GPU speedup.
- Study GPU overhead and synchronization.
- Analyze scalability with increasing input size.

---

# 🔢 What is Bitonic Sort?

Bitonic Sort is a comparison-based sorting algorithm designed particularly for parallel architectures.

The algorithm works by constructing **bitonic sequences** and repeatedly performing compare-and-swap operations.

A bitonic sequence is a sequence that:

1. First increases and then decreases, or
2. First decreases and then increases.

Bitonic Sort repeatedly:

```text
Create Bitonic Sequence
        ↓
Perform Compare-and-Swap
        ↓
Bitonic Merge
        ↓
Repeat
        ↓
Sorted Array
```

One important requirement is that the input size should be a **power of two**.

Examples:

```text
1024
4096
16384
65536
```

Invalid example:

```text
10245
```

The serial implementation checks this condition.

---

# 🏗️ Project Architecture

The project contains two implementations.

```text
                 BITONIC SORT
                      |
          +-----------+-----------+
          |                       |
       CPU Version             CUDA Version
          |                       |
      Serial C                NVIDIA GPU
          |                       |
      CPU Timing             CUDA Kernel
                                  |
                         Parallel Threads
                                  |
                         Compare-and-Swap
                                  |
                            Sorted Array
```

---

# 🔄 Execution Flow

## CPU Execution

```text
Generate Input
      ↓
Validate Input Size
      ↓
Start CPU Timer
      ↓
Serial Bitonic Sort
      ↓
Stop CPU Timer
      ↓
Check Sorted Array
      ↓
Print CPU Time
```

---

## CUDA Execution

```text
Generate Input on CPU
        ↓
Allocate GPU Memory
        ↓
Copy CPU → GPU
        ↓
Configure CUDA Grid
        ↓
Launch Bitonic Sort Kernels
        ↓
Synchronize Threads
        ↓
Copy GPU → CPU
        ↓
Check Correctness
        ↓
Print Kernel Time
        ↓
Print Total GPU Time
```

---

# 💻 Serial CPU Implementation

The CPU implementation uses the traditional recursive Bitonic Sort approach.

The major functions are:

```c
swap()
bitonicMerge()
bitonicSort()
isPowerOfTwo()
```

The program dynamically allocates memory based on the input size.

Example:

```powershell
serial_bitonic.exe 1024
```

The program generates deterministic random input using:

```c
srand(42);
```

This allows consistent input generation during testing.

---

# ⚡ CUDA Parallel Implementation

The CUDA implementation uses a GPU kernel:

```cuda
__global__ void bitonicSortKernel(
    int *arr,
    int j,
    int k,
    int n
)
```

Each CUDA thread calculates its own array index:

```cuda
int i = blockIdx.x * blockDim.x + threadIdx.x;
```

The partner index is calculated using XOR:

```cuda
int ixj = i ^ j;
```

The compare-and-swap operation is then performed between:

```text
i
```

and

```text
i XOR j
```

This allows many comparisons to happen in parallel.

---

# 🧵 CUDA Kernel Strategy

The implementation uses:

```text
Threads per Block = 256
```

The number of blocks is calculated using:

```c
int blocksPerGrid =
    (n + threadsPerBlock - 1) / threadsPerBlock;
```

For example:

```text
N = 65536

Threads per block = 256

Blocks =
(65536 + 256 - 1) / 256

= 256 blocks
```

The kernel is launched repeatedly for different values of `k` and `j`.

```text
k = 2
    j = 1

k = 4
    j = 2
    j = 1

k = 8
    j = 4
    j = 2
    j = 1

...
```

This continues until:

```text
k = N
```

---

# 🖥️ Hardware and Software

## Hardware

| Component | Specification |
|---|---|
| GPU | NVIDIA GeForce RTX 3050 6GB Laptop GPU |
| Compute Capability | 8.6 |
| GPU Memory | 6 GB |
| Operating System | Windows 11 |

## Software

| Software | Version / Details |
|---|---|
| CUDA Toolkit | 13.4.2 |
| NVCC | 13.4.92 |
| NVIDIA Driver | 610.74 |
| CUDA reported by driver | 13.3 |
| Visual Studio Build Tools | 2026 |
| MSVC | 19.51.36260 |
| Compiler | NVIDIA `nvcc` + MSVC host compiler |

---

# 🛠️ CUDA Environment Setup

The CUDA environment was configured on Windows.

## 1. Verify NVIDIA GPU

```powershell
nvidia-smi
```

This confirmed the NVIDIA RTX 3050 GPU and driver installation.

---

## 2. Verify CUDA Compiler

```powershell
nvcc --version
```

This confirmed:

```text
CUDA Toolkit 13.4.2
NVCC 13.4.92
```

---

## 3. Visual Studio Build Tools

Visual Studio Build Tools was installed with:

```text
Desktop development with C++
```

This provides the Microsoft C/C++ compiler required by CUDA's Windows toolchain.

The MSVC compiler was verified using:

```powershell
cl
```

---

# ⚠️ CUDA Toolchain Compatibility Issue

During the initial CUDA execution, the program produced:

```text
Kernel Launch Error:
the provided PTX was compiled with an unsupported toolchain.
```

The issue was not caused by the Bitonic Sort algorithm.

The RTX 3050 has:

```text
Compute Capability = 8.6
```

Therefore, the CUDA program was compiled specifically for the GPU architecture using:

```powershell
nvcc -arch=sm_86 cuda_bitonic.cu -o cuda_bitonic.exe
```

After compiling specifically for `sm_86`, the CUDA program executed successfully.

---

# 📁 Project Structure

```text
BITONIC-SORT/
│
├── serial_bitonic.c
│
├── cuda_bitonic.cu
│
├── .gitignore
│
└── README.md
```

Generated binaries such as:

```text
*.exe
*.obj
```

are ignored using `.gitignore`.

---

# 🔨 Compilation and Execution

## CPU

Compile:

```powershell
gcc serial_bitonic.c -o serial_bitonic.exe
```

Run:

```powershell
serial_bitonic.exe 1024
```

Example:

```powershell
serial_bitonic.exe 65536
```

---

## CUDA

Compile:

```powershell
nvcc -arch=sm_86 cuda_bitonic.cu -o cuda_bitonic.exe
```

Run:

```powershell
cuda_bitonic.exe 1024
```

Other test sizes:

```powershell
cuda_bitonic.exe 4096
cuda_bitonic.exe 16384
cuda_bitonic.exe 65536
```

---

# ✅ Correctness Testing

Every CUDA benchmark was checked after sorting.

The program verifies whether every element is less than or equal to the next element.

Output:

```text
Sorted Correctly: YES
```

All tested input sizes produced:

```text
Sorted Correctly: YES
```

Therefore, the CUDA implementation successfully produced correctly sorted arrays.

---

# 🧪 Test Cases

Four input sizes were selected:

```text
1024
4096
16384
65536
```

These values are powers of two and allow the scalability of Bitonic Sort to be studied.

## CPU Validation

| Input Size | Result |
|---:|---|
| 1024 | PASS |
| 4096 | PASS |
| 16384 | PASS |
| 65536 | PASS |

## CUDA Validation

| Input Size | Result |
|---:|---|
| 1024 | PASS |
| 4096 | PASS |
| 16384 | PASS |
| 65536 | PASS |

---

# ⏱️ Benchmark Methodology

For each CUDA input size:

- The program was executed **5 times**.
- CUDA kernel time was recorded for each run.
- Total GPU time was recorded for each run.
- The average of the five runs was used for the final table.

The CPU baseline was obtained using the serial implementation.

CPU benchmark results:

```text
1024    → 0.000158 s
4096    → 0.001066 s
16384   → 0.007018 s
65536   → 0.024320 s
```

---

# 📊 CPU Benchmark Results

| Input Size | CPU Time (seconds) |
|---:|---:|
| 1,024 | 0.000158 |
| 4,096 | 0.001066 |
| 16,384 | 0.007018 |
| 65,536 | 0.024320 |

The CPU execution time increases significantly as the input size grows.

---

# ⚡ CUDA Benchmark Results

## CUDA Kernel Time

| Input Size | Average Kernel Time (s) |
|---:|---:|
| 1,024 | 0.000588 |
| 4,096 | 0.000796 |
| 16,384 | 0.001021 |
| 65,536 | 0.001327 |

---

## Total GPU Time

Total GPU time includes:

```text
cudaMalloc
+
Host → Device transfer
+
CUDA kernel execution
+
Device → Host transfer
```

| Input Size | Average Total GPU Time (s) |
|---:|---:|
| 1,024 | 0.001089 |
| 4,096 | 0.001503 |
| 16,384 | 0.001802 |
| 65,536 | 0.001921 |

CUDA initialization was performed before starting the total timer to avoid including one-time CUDA context initialization overhead.

---

# 📈 Performance Comparison

| Input Size | CPU Time | CUDA Kernel | Kernel Speedup | Total GPU | End-to-End Speedup |
|---:|---:|---:|---:|---:|---:|
| 1,024 | 0.000158 | 0.000588 | 0.27× | 0.001089 | 0.15× |
| 4,096 | 0.001066 | 0.000796 | 1.34× | 0.001503 | 0.71× |
| 16,384 | 0.007018 | 0.001021 | 6.87× | 0.001802 | 3.90× |
| 65,536 | 0.024320 | 0.001327 | **18.33×** | 0.001921 | **12.66×** |

---

# 🚀 Speedup Analysis

The speedup is calculated as:

```text
Speedup = CPU Time / GPU Time
```

Two speedups were analyzed.

### Kernel Speedup

```text
CPU Time / CUDA Kernel Time
```

### End-to-End Speedup

```text
CPU Time / Total GPU Time
```

---

## 1024 Elements

```text
Kernel Speedup = 0.27×
Total GPU Speedup = 0.15×
```

For a small input, the CPU performs better.

The GPU cannot fully utilize its parallel processing capability because the workload is too small compared with GPU overhead.

---

## 4096 Elements

```text
Kernel Speedup = 1.34×
Total GPU Speedup = 0.71×
```

The CUDA kernel becomes faster than the CPU, but the total GPU execution is still slower after including memory and GPU overhead.

---

## 16384 Elements

```text
Kernel Speedup = 6.87×
Total GPU Speedup = 3.90×
```

At this size, GPU acceleration becomes clearly beneficial.

---

## 65536 Elements

```text
Kernel Speedup = 18.33×
Total GPU Speedup = 12.66×
```

This was the best-performing test case.

Even after including memory transfer and GPU overhead, the CUDA implementation achieved approximately:

```text
12.66×
```

end-to-end speedup.

---

# 🔍 Observations

## 1. GPU acceleration improves with larger input sizes

The GPU is not automatically faster for every workload.

For small inputs, overhead can dominate the actual computation.

As the input size increases, more parallel work is available for the GPU.

---

## 2. Kernel speedup is higher than end-to-end speedup

For 65,536 elements:

```text
Kernel Speedup = 18.33×
```

while:

```text
End-to-End Speedup = 12.66×
```

The difference comes from GPU memory allocation and data transfers.

---

## 3. Synchronization affects performance

The implementation uses:

```cuda
cudaDeviceSynchronize();
```

after kernel launches.

This ensures that each Bitonic Sort stage finishes before the next stage begins.

Although synchronization is necessary for correctness in this implementation, frequent synchronization introduces overhead.

---

## 4. Memory transfers affect GPU performance

The CPU must transfer data to the GPU:

```text
Host → Device
```

and retrieve the sorted result:

```text
Device → Host
```

These transfers increase total execution time.

---

## 5. Small workloads may not benefit from GPU acceleration

For 1024 elements:

```text
CPU = 0.000158 s
Total GPU = 0.001089 s
```

Therefore, the CPU is faster for this small workload.

---

# ⚙️ GPU Overhead

Several overheads affect the CUDA implementation.

### Kernel Launch Overhead

Every Bitonic Sort stage requires a CUDA kernel launch.

### Synchronization Overhead

The implementation uses:

```cuda
cudaDeviceSynchronize();
```

between stages.

### Memory Transfer Overhead

Data must move between CPU and GPU memory.

### GPU Memory Allocation

The implementation uses:

```cuda
cudaMalloc()
```

and:

```cuda
cudaFree()
```

### CUDA Initialization

CUDA context initialization can create significant one-time overhead.

To avoid including this startup cost in the total timing measurement, the program performs:

```cuda
cudaFree(0);
```

before starting the total timer.

---

# 🧩 Challenges and Solutions

## Challenge 1 — CUDA PTX Toolchain Error

Initial execution produced:

```text
the provided PTX was compiled with an unsupported toolchain
```

### Solution

The RTX 3050 architecture was explicitly specified:

```powershell
nvcc -arch=sm_86 cuda_bitonic.cu -o cuda_bitonic.exe
```

After this, the CUDA program executed successfully.

---

## Challenge 2 — Fixed Input Size

Initially, the CUDA program used:

```c
int n = 8;
```

The program was modified to accept the input size from the command line:

```c
if (argc == 2)
{
    n = atoi(argv[1]);
}
```

This allowed:

```powershell
cuda_bitonic.exe 1024
cuda_bitonic.exe 4096
cuda_bitonic.exe 16384
cuda_bitonic.exe 65536
```

---

## Challenge 3 — Large Array Output

Printing every sorted element produced a very large terminal output.

This was replaced with a correctness check:

```text
Sorted Correctly: YES
```

---

## Challenge 4 — GPU Timing

Initially, only CUDA kernel execution was measured.

CUDA events were added:

```cuda
cudaEventCreate(&start);
cudaEventCreate(&stop);
```

This provided accurate kernel timing.

A separate CPU high-resolution timer using:

```c
QueryPerformanceCounter()
```

was then added to measure total GPU execution.

---

# 🌿 Git Workflow

Git was used throughout the development process.

Repository:

**[BITONIC-SORT](https://github.com/Deepak-035/BITONIC-SORT)**

Basic workflow:

```powershell
git status
```

Stage changes:

```powershell
git add cuda_bitonic.cu
```

Commit:

```powershell
git commit -m "Commit message"
```

Push:

```powershell
git push origin main
```

---

# 📝 Important Git Commits

The project was developed incrementally.

```text
35569cb
Add Serial Bitonic Sort implementation
```

```text
34dcf9c
Add CPU timing and input size validation
```

```text
2ef0a1c
Add CUDA Bitonic Sort implementation
```

```text
fa88359
Update CUDA input handling and correctness check
```

```text
3251d49
Add CUDA kernel timing
```

```text
61de63d
Add configurable CUDA input size
```

```text
a1302c1
Add total GPU timing
```

---

# 🧹 .gitignore

Generated build files are not stored in the repository.

`.gitignore` contains:

```gitignore
*.exe
*.obj
```

This prevents compiled binaries and object files from being accidentally committed.

---

# 📚 Learning Outcomes

Through this project, the following concepts were practiced:

- Serial sorting algorithms
- Parallel algorithms
- Bitonic Sort
- CUDA programming
- CUDA kernels
- CUDA threads
- CUDA blocks
- Grid configuration
- GPU memory allocation
- Host-to-device memory transfer
- Device-to-host memory transfer
- CUDA synchronization
- CUDA events
- GPU performance measurement
- CPU performance measurement
- Speedup calculation
- Scalability analysis
- GPU overhead
- NVIDIA GPU architecture
- CUDA compilation
- `nvcc`
- Git and GitHub

---

# 🔮 Future Improvements

Possible improvements include:

- Using shared memory for Bitonic Sort stages.
- Reducing global memory accesses.
- Reducing synchronization overhead.
- Using asynchronous memory transfers.
- Using CUDA streams.
- Performing multiple benchmark iterations inside a single program execution.
- Testing larger input sizes such as:
  ```text
  262144
  524288
  1048576
  ```
- Comparing different CUDA block sizes.
- Generating CPU/GPU performance graphs automatically.
- Comparing the implementation with other GPU sorting algorithms.

---

# 🏁 Conclusion

This project demonstrates the use of NVIDIA CUDA to parallelize Bitonic Sort and compare its performance against a serial CPU implementation.

For small inputs, the CPU can outperform the GPU because GPU initialization, kernel launches, synchronization, and memory transfers introduce overhead.

As the input size increases, the GPU becomes significantly more effective because the workload provides enough parallelism to utilize the GPU's processing resources.

For the largest tested input:

```text
Input Size = 65,536
```

the CUDA implementation achieved:

```text
Kernel Speedup     = 18.33×
End-to-End Speedup = 12.66×
```

This demonstrates that GPU acceleration becomes increasingly beneficial as the amount of parallel work increases.

---

# ⭐ Final Result

### CPU

```text
Serial Bitonic Sort
        ↓
0.024320 seconds
```

### NVIDIA RTX 3050

```text
CUDA Bitonic Sort
        ↓
0.001327 seconds kernel
        ↓
0.001921 seconds total GPU
```

### 🚀 Maximum Observed Speedup

```text
Kernel Speedup     = 18.33×
End-to-End Speedup = 12.66×
```

---

# 👨‍💻 Author

**Deepak**

Computer Science Engineering

**Parallel Computing — Bitonic Sort using CPU and NVIDIA CUDA**

---

> **Note:** Benchmark results can vary depending on system load, GPU state, background processes, thermal conditions, and other runtime factors. The values documented above represent the measurements obtained during this project.
