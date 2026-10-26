# Native compilation and installation

Faz parses and checks `.fz`, emits LLVM IR, and uses LLVM's typed C API **inside
the Faz process** to verify, optimize and emit a native object. It then invokes
the platform linker with that object. Normal `build` and `run` never launch
Clang, `cc`, `llc`, or an external optimizer. The generated executable does not
load LLVM or require Faz. It still uses the operating system's libraries.

## Install a staged distribution

A native distribution has `bin/faz`, `lib/faz/llvm/lib`, third-party notices,
platform metadata, and a checksum manifest. Keep the archive together:

```sh
./bin/faz install "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"
faz run hello.fz
faz build hello.fz -o hello
```

The installer copies the backend and its notices along with the compiler.
There is no separate LLVM or Clang installation for this distribution. Archive
staging is implemented and exercised in CI; this repository does not yet
publish versioned binary releases. CI validates staging; binary artifacts are not published.

The archive also carries **LLD and native link inputs**, so normal user builds
need no separate compiler, linker, SDK, or development package. macOS uses a
small libSystem manifest generated from Faz's own runtime declarations, with
symbol availability checked against the packaging host; no Apple SDK files
are copied. Linux includes glibc/GCC startup objects and link-time library inputs;
executables still load the operating system's glibc, not a private runtime.

The Linux binary baseline is Ubuntu 24.04 / glibc 2.39. macOS archives target the
packaging host's architecture and dependency compatibility; the manifest records
that build OS. Native x86-64 and AArch64 are supported by the backend, but each
archive must be built and tested on its intended platform. Cross-compilation,
Windows, and musl are not supported. Faz's existing Linux context-switch runtime
assumes the glibc ABI.

Tests relocate the archive, install it again, delete the original copy, disable
host LLVM/linker fallback, and compile with an empty PATH. macOS additionally
denies reads of Homebrew/Xcode/Command Line Tools and execution of system compiler
and linker drivers in a temporary sandbox. Linux CI runs the packaged compiler
in a minimal Ubuntu container without development packages. This verifies the
current build platforms; it is not a claim of compatibility with every older OS
or a macOS notarization/Gatekeeper installation test.

## Source development

Developers need Clang to turn a checked-in seed into the first Faz compiler,
plus a shared LLVM library for subsequent native builds. Install LLVM 18–22
with its development files and set `FAZ_LLVM_HOME` to its prefix. CI exercises
LLVM 18 on Linux and LLVM 21 on macOS. The platform linker and development files are also required for source
bootstrap (Apple developer tools/SDK, or Linux binutils, libc development
files, and native libgcc development startup objects). No GCC executable is
invoked during normal builds.

```sh
# macOS example (Homebrew llvm@21 already installed):
export FAZ_LLVM_HOME="$(brew --prefix llvm@21)"
clang -x ir -O2 -Wno-override-module bootstrap/seed-darwin.ll -o faz
./faz verify
```

Use `bootstrap/seed-linux.ll` on Linux. After that initial seed compilation,
Faz's self-hosting stages and seed verification use the direct backend too.
Some regression tests deliberately use Clang to compare exported IR at
different optimization levels; Clang remains a **developer test dependency**.
A source-built `faz install` without a bundled payload copies just the compiler
and continues to use the configured development LLVM library.

## Configuration and diagnostics

| Variable | Purpose |
| --- | --- |
| `FAZ_LLVM_LIBRARY` | Exact shared library override; invalid overrides fail explicitly. |
| `FAZ_LLVM_HOME` | Developer LLVM prefix containing `lib/libLLVM.so` or `libLLVM.dylib`. |
| `FAZ_LLVM_BUNDLED_ONLY=1` | Disable host-library fallback; used to verify complete distributions. Clear library/home overrides when using it. |
| `FAZ_TOOLCHAIN_BUNDLED_ONLY=1` | Require bundled linker and link inputs; tests use this to prohibit fallback. |
| `FAZ_LINKER` | Explicit native linker override, never a compiler driver. |
| `FAZ_SDKROOT` / `SDKROOT` | Developer SDK fallback when no bundled link manifest exists; otherwise `/usr/bin/xcrun` locates it. |
| `FAZ_OPT_LEVEL` | Optimization level `0`, `1`, `2` (default), or `3`. |
| `FAZ_CLANG` / `CC` | Developer exported-IR comparison tests only. Ignored by normal build/run. |

Discovery checks explicit overrides, install-relative libraries, then common
developer LLVM locations. Library version and C API symbols are checked when
loading; incompatible binaries produce loader diagnostics. `check` and
`emit-llvm` work without LLVM, a linker, or SDK because loading is lazy.

## Maintainer staging

```sh
python3 tools/stage-distribution.py --compiler build/faz \
  --llvm-home "$FAZ_LLVM_HOME" --lld-home "$FAZ_LLD_HOME" \
  --output build/faz-distribution
FAZ_TEST_ISOLATION=1 python3 tools/test-distribution.py build/faz-distribution
```

Staging requires a new output directory and fails on unresolved dependencies or
missing redistribution notices. On macOS it copies LLVM and non-system dylibs,
includes LLD, rewrites references to `@loader_path`, and ad-hoc signs modified libraries. On
Debian/Ubuntu Linux it uses `ldd`, `dpkg-query`, and `patchelf`, bundles the
non-glibc shared-library closure plus glibc link inputs, and preserves package copyright files and
common license texts. The manifest records component provenance and SHA-256
checksums. Release maintainers must retain those notices and satisfy any source
availability obligations for their selected dependency builds before publishing
a release. No Apple SDK or glibc loader is bundled by this tool. Set `FAZ_LLD_HOME` to the
LLD prefix (Homebrew `lld@21`, or `/usr/lib/llvm-18` on Ubuntu). The staging tool
requires the development packages for LLVM and LLD, plus `patchelf` on Linux.

The bridge lives in `src/runtime/platform/llvm_backend.c`. Its narrow outer ABI
matches Faz's internal runtime convention; LLVM calls use correct typed
signatures. `tools/generate-llvm-bridge.py` uses LLVM 21 to regenerate the checked-in
portable IR. Normal user programs cannot call the private backend service. LLVM
is dynamically loaded only for compilation, and unused bridge code is removed
from ordinary optimized executables. The compiler remains explicitly compiled
in the legacy dialect; this backend change does not alter language semantics.
