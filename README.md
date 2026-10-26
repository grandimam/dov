<p align="center">
  <img src="assets/faz.png" alt="Faz, the fox mascot" width="180" />
</p>

<h1 align="center">Faz</h1>

<p align="center">
  <strong>Small programs. Native executables. Mutation you can see.</strong><br />
  Python-inspired syntax · static types · automatic garbage collection
</p>

<p align="center">
  <a href="https://github.com/grandimam/faz/actions/workflows/ci.yml"><img src="https://github.com/grandimam/faz/actions/workflows/ci.yml/badge.svg" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-B6D7A8" alt="MIT license" /></a>
</p>

<p align="center">
  <a href="#try-it"><strong>Try it</strong></a> &nbsp;·&nbsp;
  <a href="docs/core-language.md">Language guide</a> &nbsp;·&nbsp;
  <a href="examples/README.md">Examples</a> &nbsp;·&nbsp;
  <a href="editors/vscode/README.md">VS Code</a> &nbsp;·&nbsp;
  <a href="#faz-makes-faz">Compiler</a>
</p>

Faz is an **experimental language for small tools and language experiments**. Write readable `.fz` files, check them before execution, and compile them to native programs with LLVM inside the compiler. The resulting executable runs without the Faz compiler; platform libraries are still required.

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

## Try it

**Install Faz once. Run and build immediately.** The package includes LLVM,
LLD, and native link inputs—no separate compiler, linker, SDK, or development
packages for normal use.

| Package | Supported system |
| :--- | :--- |
| macOS ARM64 | Apple Silicon, macOS 26 or newer |
| Linux x86-64 | glibc 2.39 or newer, such as Ubuntu 24.04; not musl/Alpine |

Paste this one command in your terminal:

```sh
curl -fsSL https://github.com/grandimam/faz/releases/download/v0.1.0/install.sh | sh && export PATH="$HOME/.local/bin:$PATH"
```

The installer detects your platform, verifies the archive's pinned SHA-256,
installs without `sudo`, and compiles a smoke test before switching versions.
The final `export` activates Faz in this terminal. Shell profiles and security
settings stay unchanged. See the install guide to inspect the script first or
choose another prefix.
[Manual downloads, checksums, and installation details →](docs/install.md)

Save a first program and run it:

```sh
cat > hello.fz <<'FZ'
fn main():
    print("Hello Faz!")
FZ
faz run hello.fz
# Hello Faz!
faz build hello.fz -o hello
./hello
# Hello Faz!
```

`faz check hello.fz` checks without compiling; `faz emit-llvm hello.fz -o hello.ll`
shows the generated IR. Built programs run without Faz, using the OS libraries.
Python packages do not run in Faz.

The macOS archive is ad-hoc signed, **not Apple-notarized**. A browser download
may trigger Gatekeeper; the installer does not bypass it. See [installation
notes](docs/install.md#macos-security-prompts) before changing any settings.
Building Faz itself is a separate developer workflow: [source build and native
toolchain details](docs/native-toolchain.md#source-development).

<table>
  <tr>
    <td width="33%" valign="top"><strong>Readable by design</strong><br /><br />Indentation, inferred locals, typed functions, lists, and structs. A small syntax for small programs.</td>
    <td width="33%" valign="top"><strong>Intentional changes</strong><br /><br /><code>mut</code> marks mutable bindings and parameters. <code>copy(value)</code> makes independent aggregate data.</td>
    <td width="33%" valign="top"><strong>A real executable</strong><br /><br />Emit LLVM IR, build a native binary, or compile and run in one command. Tracing GC handles heap lifetime.</td>
  </tr>
</table>

> **Early-stage software.** Syntax and APIs can change. The new core rules are the default; the compiler itself and parts of the older example corpus still use an explicit legacy dialect. See [current boundaries](#current-boundaries) before building on Faz.

## Keep the original. Change the copy.

`copy` makes the choice explicit, including for nested lists and structs:

```python
fn main():
    scores = [80, 90]
    mut next = copy(scores)
    next.append(100)
    print(len(scores), len(next))  # 2 3
```

Bindings have fixed types. Ordinary parameters provide read-only access; `mut` parameters request exclusive mutable access. Aggregate ownership transfers, borrow conflicts, and conservative restrictions are explained in the [core-language guide](docs/core-language.md).

## Pick a direction

| You want to… | Start here |
| :--- | :--- |
| Learn the core rules | [Bindings, calls, copies, scope, and equality](docs/core-language.md) |
| Explore working programs | [Examples and their run commands](examples/README.md) |
| Read the implementation | [Compiler walkthrough](src/compiler/README.md) |
| Make `.fz` feel at home | [VS Code highlighting, snippets, and Blackberry theme](editors/vscode/README.md) |
| See what is unfinished | [Implementation status and restrictions](docs/core-implementation-status.md) |

The VS Code extension is installed locally; it is not on the Marketplace and does not yet provide a language server. The example guide identifies programs that require `--legacy-language`.

## Faz makes Faz

The compiler is written in Faz's earlier dialect and emits LLVM IR directly. The checked-in seeds let Clang build the first compiler; that compiler rebuilds successive generations from source.

```text
.fz source → Faz + LLVM (in-process) → object → platform linker → executable
```

From the repository root:

```sh
./faz build-self    # Rebuild the compiler; compare successive LLVM output.
./build/faz verify # Test two compiler generations and check seed freshness.
```

CI runs native verification on **macOS and Linux**, checks the core-value fixture and installed compiler, and tests editor support. [See the actual runs →](https://github.com/grandimam/faz/actions/workflows/ci.yml)

<details>
<summary><strong>Inside the compiler</strong></summary>

| Component | Source |
| :--- | :--- |
| Lexer, parser, type/ownership checks, LLVM emitter, CLI | [`src/compiler/`](src/compiler/README.md) |
| Tracing GC, values, strings, and cooperative tasks | [`src/runtime/`](src/runtime) |
| Text, files, processes, networking, and HTTP | [`src/std/`](src/std) |
| Native platform bindings | [`src/runtime/platform/`](src/runtime/platform) |
| Generated LLVM seeds | [`bootstrap/`](bootstrap) |
| Conformance harness and fixtures | [`tests/`](tests) |

`build-self` and `verify` explicitly select the legacy dialect for compiler and historical harness sources. Normal user programs and installed compilers default to the new core rules. See the [compiler guide](src/compiler/README.md) for runtime embedding and seed maintenance.

</details>

## Current boundaries

Faz is a work in progress, not a finished ownership or resource model. Borrowed aggregate escapes, partial moves, general cyclic value operations, and general resource scopes remain unresolved or conservatively rejected. Pattern matching is currently available only in the explicit legacy dialect.

The compiler/runtime source migration is separate work. A passing bootstrap confirms reproducibility; it does not mean those sources already follow the new core rules. Read the [language guide](docs/core-language.md) and [implementation status](docs/core-implementation-status.md) for the precise supported behavior.

---

<p align="center">
  <strong>Small language. Big ideas. Tiny paws.</strong><br />
  <sub>Meet Faz, our resident fox. Has another side project.</sub><br />
  <sub>Made by <a href="https://x.com/thegrandimam">@thegrandimam</a> · <a href="LICENSE">MIT licensed</a></sub>
</p>
