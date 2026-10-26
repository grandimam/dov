<p align="center">
  <img src="assets/faz-mascot-hero.png" alt="Meet Faz, our curious fox mascot. Small language. Big ideas. Tiny paws. Readable code, native executables." width="1200" />
</p>

<p align="center">
  <strong>A curious fox. A small language. Your next side project.</strong><br />
  Python-inspired syntax · Static types · Explicit mutation · Automatic garbage collection
</p>

<p align="center">
  <a href="https://github.com/grandimam/faz/releases/latest"><img src="https://img.shields.io/github/v/release/grandimam/faz?style=flat-square&color=D97745&label=download" alt="Latest release" /></a>
  <a href="https://github.com/grandimam/faz/actions/workflows/ci.yml"><img src="https://github.com/grandimam/faz/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-B6D7A8?style=flat-square" alt="MIT license" /></a>
</p>

<p align="center">
  <a href="#try-it"><strong>Get started</strong></a> &nbsp; / &nbsp;
  <a href="https://github.com/grandimam/faz/releases/latest"><strong>Download</strong></a> &nbsp; / &nbsp;
  <a href="docs/core-language.md">Language guide</a> &nbsp; / &nbsp;
  <a href="examples/README.md">Examples</a> &nbsp; / &nbsp;
  <a href="editors/vscode/README.md">VS Code</a>
</p>

---

## Less ceremony. More making.

**Write a small program. Turn it into a real executable.** Faz pairs familiar,
indentation-based syntax with static checking and an LLVM-powered native compiler.
Mutation is explicit. Memory is garbage-collected. The resulting binary runs
without a Faz installation, using your operating system's libraries.

Built for **small tools and language experiments**—not a drop-in replacement for
Python, and not production-stable yet.

### Familiar at first glance. Explicit where it matters.

```python
fn main():
    project = "weekend tool"       # Immutable by default.
    mut steps = ["write"]          # Mutation is explicit.
    steps.append("build")

    print(project)
    print(len(steps), "steps ready")
```

```text
weekend tool
2 steps ready
```

<table>
  <tr>
    <td width="33%" valign="top">
      <h3>01 · Read it</h3>
      Indentation, inferred locals, typed functions, lists, and structs. A small syntax for small programs.
    </td>
    <td width="33%" valign="top">
      <h3>02 · See the changes</h3>
      Immutable bindings by default. <code>mut</code> makes mutation visible. <code>copy</code> keeps the original intact.
    </td>
    <td width="33%" valign="top">
      <h3>03 · Ship a binary</h3>
      Check, run, or compile to a native executable. Tracing GC handles heap lifetime; OS libraries are still required.
    </td>
  </tr>
</table>

> [!NOTE]
> **Small, curious, and still growing.** Faz is early-stage software: syntax and APIs can change. User programs use the new core rules; the compiler itself and some older examples still use an explicit legacy dialect. [Know the boundaries →](#current-boundaries)

## Try it

### One install. No toolchain scavenger hunt.

The package includes **LLVM, LLD, and native link inputs**. Normal use needs no
separate compiler, linker, SDK, or development packages.

```sh
curl -fsSL https://github.com/grandimam/faz/releases/download/v0.1.0/install.sh | sh && export PATH="$HOME/.local/bin:$PATH"
```

The installer detects your platform, verifies the archive's pinned SHA-256,
and compiles a smoke test **before switching versions**. No `sudo`. No shell-profile
edits. No security-setting changes. The `export` activates Faz in this terminal.

| Pick your platform | What you need | Direct download |
| :--- | :--- | :--- |
| **macOS · ARM64** | Apple Silicon · macOS 26+ | [Download archive ↗](https://github.com/grandimam/faz/releases/download/v0.1.0/faz-v0.1.0-darwin-arm64.tar.gz) |
| **Linux · x86-64** | glibc 2.39+ · e.g. Ubuntu 24.04 | [Download archive ↗](https://github.com/grandimam/faz/releases/download/v0.1.0/faz-v0.1.0-linux-x86_64.tar.gz) |

<sub>No Windows, Intel Mac, Linux ARM64, or musl/Alpine binary package in v0.1.0.</sub>

**[Installation guide](docs/install.md)** · [Checksums](https://github.com/grandimam/faz/releases/download/v0.1.0/SHA256SUMS) · [All release assets](https://github.com/grandimam/faz/releases/tag/v0.1.0)

<details>
<summary><strong>Before installing: script inspection, custom paths, and macOS security</strong></summary>

The [installation guide](docs/install.md) shows how to inspect the script first,
choose another prefix, verify a manual download, and keep Faz available in future
shells.

The macOS archive is ad-hoc signed, **not Apple-notarized**. Browser downloads may
trigger Gatekeeper; the installer does not bypass it. Read the
[macOS security notes](docs/install.md#macos-security-prompts) before changing any settings.

Building Faz itself is a separate developer workflow. See the
[source-build and native-toolchain guide](docs/native-toolchain.md#source-development).

</details>

### Your first native program

**1. Write something small.** Save this as `hello.fz`:

```python
fn main():
    print("Hello Faz!")
```

**2. Run it.**

```sh
faz run hello.fz
# Hello Faz!
```

**3. Keep the executable.**

```sh
faz build hello.fz -o hello
./hello
# Hello Faz!
```

The executable runs **without Faz**, using the operating system's libraries.
Python-inspired does not mean Python-compatible: Python packages do not run in Faz.

| While you're working… | Command |
| :--- | :--- |
| Check without compiling | `faz check hello.fz` |
| Compile and run | `faz run hello.fz` |
| Build a native executable | `faz build hello.fz -o hello` |
| Look at the generated LLVM IR | `faz emit-llvm hello.fz -o hello.ll` |

## Keep the original. Change the copy.

A small keyword should make a big intention obvious.

```python
fn main():
    scores = [80, 90]
    mut next = copy(scores)
    next.append(100)
    print(len(scores), len(next))  # 2 3
```

- **`scores` stays put.** Bindings are immutable by default and have fixed types.
- **`mut next` invites change.** Mutation is visible at the binding.
- **`copy(scores)` makes it independent.** That includes nested lists and structs.

Ordinary parameters provide read-only access; `mut` parameters request exclusive
mutable access. Ownership transfers and borrow restrictions are part of the
language—not something to infer from this tiny example.

**[Explore bindings, copies, and ownership →](docs/core-language.md)**

## Where will you take it?

| Your next step | The trail |
| :--- | :--- |
| **Learn by doing** | [Run the examples](examples/README.md) — functions, lists, structs, and more |
| **Learn the rules** | [Read the language guide](docs/core-language.md) — bindings, calls, scope, and equality |
| **Set up your editor** | [Add VS Code support](editors/vscode/README.md) — highlighting, snippets, and the Blackberry theme |
| **Look under the hood** | [Walk through the compiler](src/compiler/README.md) — from tokens to LLVM IR |
| **Find the edges** | [Check implementation status](docs/core-implementation-status.md) — supported behavior and open work |

<sub>The VS Code extension installs locally; it is not on the Marketplace and has no language server yet. Older examples that need <code>--legacy-language</code> are marked in the example guide.</sub>

## Benchmarks: Faz, Python, and Mojo

**Measured runs, not estimates.** Matching algorithms and inputs, with every
output checked against an independent reference. Lower times are better.

| Workload | Faz | Python | Mojo |
| :--- | ---: | ---: | ---: |
| Modular Fibonacci · 20 million steps | 78.96 ms | 939.72 ms | 90.03 ms |
| Prime sieve · through 3 million | 112.25 ms | 393.45 ms | 21.72 ms |
| Collection allocation · 100,000 × 128 integers | 432.89 ms | 786.08 ms | 66.36 ms |

Apple M2 Pro · macOS 26.5.2 · Faz 0.1.0 · CPython 3.13.0 · Mojo 0.26.2.0.
Median of nine measured runs after two warmups, with randomized language order.
Times include process startup and checksum output; compilation is excluded.
Faz and Mojo use native builds at optimization level 3. Python uses ordinary
loops without NumPy or a JIT. Python integers are arbitrary-precision; Faz and
Mojo use native 64-bit integers here. All results fit within signed 64 bits.

**The takeaway:** Faz was about **1.8–12× faster than plain Python** in these tests.
It slightly beat Mojo on number calculations, while Mojo was about **5–6.5× faster**
on the collection-heavy workloads. Faz is stronger at scalar calculation than
at managing lists today.

These are three local microbenchmarks—not a general language ranking. They do
not measure accelerated Python libraries, GPU workloads, parallelism, networking,
or memory use.

Reproduce from the repository root with Faz, Python 3, and Mojo installed:

```sh
python3 examples/benchmarks/compare_python_mojo.py --runs 9
```

**[Methodology and source →](examples/benchmarks/README.md#python-and-mojo-comparison)** ·
[Full results](examples/benchmarks/python-mojo-results.md) ·
[Raw measurements](examples/benchmarks/python-mojo-results.json)

## Faz makes Faz

**The compiler is written in Faz.** It uses the language's earlier dialect and
emits LLVM IR directly. Checked-in seeds let Clang build the first compiler;
that compiler rebuilds successive generations from source.

```text
                         inside Faz
                   ┌─────────────────────┐
  your program.fz ──► LLVM IR ──► object ──┼──► linker ──► native executable
                   └─────────────────────┘
```

From the repository root, with the [development toolchain](docs/native-toolchain.md#source-development) installed:

```sh
./faz build-self     # Rebuild; compare successive LLVM output.
./build/faz verify   # Test two generations and check seed freshness.
```

CI runs native verification on **macOS and Linux**, checks the core-value fixture
and installed compiler, and tests editor support.
[See the actual runs →](https://github.com/grandimam/faz/actions/workflows/ci.yml)

<details>
<summary><strong>Open the hood — compiler, runtime, and repository map</strong></summary>

| Component | Source |
| :--- | :--- |
| Lexer, parser, type/ownership checks, LLVM emitter, CLI | [`src/compiler/`](src/compiler/README.md) |
| Tracing GC, values, strings, and cooperative tasks | [`src/runtime/`](src/runtime) |
| Text, files, processes, networking, and HTTP | [`src/std/`](src/std) |
| Native platform bindings | [`src/runtime/platform/`](src/runtime/platform) |
| Generated LLVM seeds | [`bootstrap/`](bootstrap) |
| Conformance harness and fixtures | [`tests/`](tests) |

`build-self` and `verify` explicitly select the legacy dialect for compiler and
historical harness sources. Normal user programs and installed compilers default
to the new core rules. See the [compiler guide](src/compiler/README.md) for runtime
embedding and seed maintenance.

</details>

## Current boundaries

Faz is a work in progress, **not a finished ownership or resource model**.
Borrowed aggregate escapes, partial moves, general cyclic value operations, and
general resource scopes remain unresolved or conservatively rejected. Pattern
matching is currently available only in the explicit legacy dialect.

The compiler/runtime source migration is separate work. A passing bootstrap
confirms reproducibility; it does not mean those sources already follow the new
core rules. The [language guide](docs/core-language.md) and
[implementation status](docs/core-implementation-status.md) describe the precise
supported behavior.

---

<p align="center">
  <img src="assets/faz.png" alt="Faz, our resident fox mascot" width="140" /><br />
  <strong>Small language. Big ideas. Tiny paws.</strong><br />
  Make something small. See where it goes.<br /><br />
  <a href="#try-it">Try Faz</a> &nbsp;·&nbsp;
  <a href="examples/README.md">Find an example</a> &nbsp;·&nbsp;
  <a href="https://github.com/grandimam/faz/issues">Share a bug or an idea</a><br /><br />
  <sub>Meet Faz, our resident fox. Has another side project.</sub><br />
  <sub>Made by <a href="https://x.com/thegrandimam">@thegrandimam</a> · <a href="LICENSE">MIT licensed</a></sub>
</p>
