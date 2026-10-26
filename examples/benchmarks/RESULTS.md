# Local benchmark results

Machine: Apple M2 Pro; macOS-26.5.2-arm64-arm-64bit-Mach-O

- faz 0.1.0
- rustc 1.92.0 (ded5c06cf 2025-12-08)
- go version go1.22.3 darwin/arm64

Two warmups and 9 measured runs per workload/language, randomized order.
Median end-to-end wall time, including process startup and one checksum print.

| Workload | Input | Faz | Rust | Go | Faz / Rust | Faz / Go |
|---|---:|---:|---:|---:|---:|---:|
| arithmetic | 20,000,000 | 78.47 ms | 66.41 ms | 67.18 ms | 1.18× | 1.17× |
| sieve | 3,000,000 | 112.68 ms | 17.27 ms | 22.70 ms | 6.52× | 4.96× |
| allocation | 100,000 | 431.52 ms | 34.79 ms | 45.50 ms | 12.40× | 9.48× |

Ratios above 1 mean Faz took longer.

| Native executable | Compiler-output size (not manually stripped) |
|---|---:|
| faz | 111.5 KiB |
| rust | 451.7 KiB |
| go | 1999.0 KiB |

Faz: FAZ_OPT_LEVEL=3; Rust: -C opt-level=3; Go: default optimized build.
All outputs checked against independent Python reference implementations.
Raw samples and commands: `build/benchmarks/results.json`.

These are three microbenchmarks, not a general language ranking. They exclude compilation,
networking, parallelism, and application-scale behavior. Memory use is not measured.
Sizes reflect different runtime/linker/symbol defaults, not equivalent deployment packages.
