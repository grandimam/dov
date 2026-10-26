# Faz vs Python vs Mojo

Machine: Apple M2 Pro; macOS-26.5.2-arm64-arm-64bit-Mach-O

- faz 0.1.0
- CPython 3.13.0
- Mojo 0.26.2.0 (d627decc)

Median of 9 measured runs after two warmups, randomized order.
End-to-end wall time includes process startup and checksum output; compilation is excluded.

| Workload | Input | Faz | Python | Mojo | Python time / Faz time | Faz time / Mojo time |
|---|---:|---:|---:|---:|---:|---:|
| arithmetic | 20,000,000 | 78.96 ms | 939.72 ms | 90.03 ms | 11.90× | 0.88× |
| sieve | 3,000,000 | 112.25 ms | 393.45 ms | 21.72 ms | 3.51× | 5.17× |
| allocation | 100,000 | 432.89 ms | 786.08 ms | 66.36 ms | 1.82× | 6.52× |

Faz and Mojo: native builds at optimization level 3. Python: plain CPython loops,
without NumPy, Numba, or other acceleration. Python integers are arbitrary-precision;
Faz and Mojo use native 64-bit integers here. All results fit within signed 64 bits.
Mojo uses its default host CPU targeting; no explicit CPU override was supplied.
All checksums were verified against independent reference algorithms, including boundary cases.

These are three CPU microbenchmarks, not a universal speed ranking. No GPU, SIMD-specific
implementation, parallelism, memory profiling, or compile-time comparison is included.
The Python result does not represent optimized NumPy or JIT-compiled Python workloads.

Reproduce: `python3 examples/benchmarks/compare_python_mojo.py --runs 9`.
Raw samples: `python-mojo-results.json` beside the generated report.
