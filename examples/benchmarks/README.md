# Faz vs Rust vs Go: a reproducible local showcase

See **[measured results](RESULTS.md)** and **[raw samples](results.json)** from an
Apple M2 Pro. These are actual native executable timings, not estimates.

## Python and Mojo comparison

A separate measured run compares Faz with **plain CPython 3.13.0** and
**native Mojo 0.26.2.0**, using the same workloads and inputs:

**[Results →](python-mojo-results.md)** · [Raw samples](python-mojo-results.json)

```sh
python3 examples/benchmarks/compare_python_mojo.py --runs 9
```

Requires the Mojo language compiler in addition to Faz and Python. Faz and Mojo
use optimization level 3; Python uses ordinary loops without NumPy or a JIT.
Python integers have arbitrary precision, unlike the native 64-bit integers
used here by Faz and Mojo. Checksums match and fit within signed 64 bits.
This runner reuses the independent reference algorithms from `run.py` and
writes fresh reports to `build/benchmarks/python-mojo-results.*`.

## What Faz can do today

The accompanying [Taskboard](../taskboard/README.md) is a working multi-module
CLI with persistent storage, validated input, Unicode titles, search, priorities,
and completion statistics. It builds without the legacy dialect and runs without
Faz installed (OS libraries are still needed).

| Area | Faz 0.1.0 | Rust | Go |
|---|---|---|---|
| Syntax | Python-inspired indentation | Braces, explicit types/inference | Braces, explicit types/inference |
| Native executable | LLVM and bundled linker | LLVM-backed native toolchain | Native Go toolchain |
| Mutation | Immutable by default; explicit `mut` | Immutable bindings by default; `mut` | Mutable variables by default |
| Heap lifetime | Tracing garbage collector | Ownership/RAII; no mandatory tracing GC | Garbage collector |
| Access rules | Early ownership/access model; incomplete | Mature ownership and borrow checking | No Rust-style borrow checker |
| Concurrency | Cooperative tasks on one OS thread | Threads and async ecosystem | Goroutines with parallel scheduling |
| Ecosystem | Small, experimental; no Python package compatibility | Mature package ecosystem | Mature modules and standard library |

Similar syntax or keywords do not imply equivalent guarantees. Faz explicitly
has unresolved ownership/resource cases; see [the language guide](../../docs/core-language.md).
This demo establishes small-tool capability, not production readiness or parity
with Rust/Go's networking, concurrency, tooling, or libraries.

## Reproduce

Requires Faz, Rust, Go, and Python 3. From the repository root:

```sh
export PATH="$HOME/.local/bin:$PATH"
python3 examples/benchmarks/run.py --runs 9
```

The runner builds all three executables, verifies results against independent
Python reference implementations, tests boundary inputs, performs two warmups,
and runs nine measured samples per workload/language in randomized order.
New results go to `build/benchmarks/results.md` and `results.json`; the snapshots
beside this README are the original measured run.

- Faz: `FAZ_OPT_LEVEL=3 faz build ...`
- Rust: `rustc -C opt-level=3 ...`
- Go: `go build ...` (normal optimized compiler)

Compiler versions are recorded. The installed Go here is 1.22.3, **not a claim
about the latest Go release**. Builds use each toolchain's default target,
without extra native-CPU flags or manual stripping. Compilation is outside the
timed region; no compile-speed claims are made.

## Workloads

All implementations use signed 64-bit integers, matching inputs and algorithms,
and print a checked checksum so the computation remains observable.

1. **Arithmetic**: 20 million iterative Fibonacci steps modulo 1,000,000,007.
   Tests a scalar dependency chain and modular arithmetic. No overflowing sum.
2. **Sieve**: count primes through 3 million using an integer list/vector/slice.
   Each begins empty and grows by appending zeros, then marks composites and
   counts primes. This includes growth, indexing, and initialization costs.
3. **Allocation**: 100,000 temporary collections, each grown to 128 integers;
   accumulate every element. Exercises collection growth and lifetime handling.

These intentionally use the same straightforward implementations, **not each
language's best specialized implementation**. No bit-packed sieve, reservation,
custom allocator, forced collection, or GC tuning. Different optimizers may
transform matching source algorithms differently. Only controlled nonnegative
benchmark arguments are supported by these small workload executables.

## Interpretation

On this machine, Faz's scalar arithmetic was within about 18% of Rust/Go.
Its sieve took about 5–6.5 times as long, and its allocation workload about
9.5–12.4 times as long. This makes scalar native code a promising area and
collection-heavy code an obvious area to investigate.

The Faz source emits runtime list operations (`src/compiler/llvm_emitter.fz`);
`src/runtime/values.fz` implements list growth, indexing, and GC-root handling.
These are plausible profiling targets, **not measured proof of where the time
went**. No profiler or allocation counter was used, so the gap cannot be
attributed exclusively to garbage collection.

Faz's compiler-output executable is smaller in this test, but runtime features,
linking, and symbol defaults differ. Binary size is not RAM usage or total SDK
size. Timings include startup and one output line, are subject to local machine
noise, and say nothing about parallel throughput, HTTP servers, or large apps.
