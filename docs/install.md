# Install Faz v0.1.0

One package supplies Faz, LLVM, LLD, and native link inputs. Normal `run` and
`build` need no separate Clang, LLVM, linker, SDK, or development packages.
Ordinary operating-system runtime libraries are still required.

| Archive | Minimum supported system |
| --- | --- |
| `faz-v0.1.0-darwin-arm64.tar.gz` | Apple Silicon, macOS 26+ |
| `faz-v0.1.0-linux-x86_64.tar.gz` | x86-64 glibc Linux, glibc 2.39+ (Ubuntu 24.04+) |

Intel Macs, Linux ARM64, Windows, and musl/Alpine have no v0.1.0 binary package.
The backend supports additional native architectures, but those are not tested
release targets. Do not substitute an archive for another platform.

## Recommended installer

```sh
curl -fsSL https://github.com/grandimam/faz/releases/download/v0.1.0/install.sh | sh && export PATH="$HOME/.local/bin:$PATH"
faz --version
```

This one-line command activates Faz in the current terminal. To inspect the
short POSIX installer first, download it with `curl -fsSLo install-faz.sh
https://github.com/grandimam/faz/releases/download/v0.1.0/install.sh`, read it,
then run `sh install-faz.sh`.
It uses standard system tools (`curl`, `tar`, `mktemp`, and `sha256sum` or
`shasum`), verifies a hard-coded SHA-256 for the selected v0.1.0 archive, checks
its file hashes, and compiles/runs a first program before activating it.
The release's `SHA256SUMS` also covers the installer and both archives.

No root access is needed. The default prefix is `$HOME/.local`; choose another:

```sh
sh install-faz.sh --prefix "$HOME/Tools/Faz"
export PATH="$HOME/Tools/Faz/bin:$PATH"
```

Add the appropriate PATH line to your shell configuration yourself if you want
it in future shells. The installer does not edit shell profiles, install system
packages, or change security settings.

Versions live under `<prefix>/lib/faz/versions/`; `<prefix>/bin/faz` points to the
active version. An existing managed installation remains active until the new
archive is verified and its smoke test passes. Previous versions are retained.
Rerunning the same installer verifies and reuses the installed files. It refuses
to overwrite an unmanaged `bin/faz` or locally modified managed files; choose a
different prefix or explicitly move your old installation first. A concurrent
installer is rejected with a lock message. An interrupted process may leave
`.install-lock`; remove it only after confirming no installer is still running.

## Manual download

Download your archive and `SHA256SUMS` from the
[v0.1.0 release](https://github.com/grandimam/faz/releases/tag/v0.1.0).
Check the selected archive before extraction. For Linux:

```sh
grep '  faz-v0.1.0-linux-x86_64.tar.gz$' SHA256SUMS | sha256sum -c -
tar -xzf faz-v0.1.0-linux-x86_64.tar.gz
./faz-v0.1.0-linux-x86_64/bin/faz --version
```

For macOS:

```sh
grep '  faz-v0.1.0-darwin-arm64.tar.gz$' SHA256SUMS | shasum -a 256 -c -
tar -xzf faz-v0.1.0-darwin-arm64.tar.gz
./faz-v0.1.0-darwin-arm64/bin/faz --version
```

Keep the extracted directory together: moving only `bin/faz` loses its backend.
You may run that binary directly, add its `bin` directory to PATH, or use
`./bin/faz install "$HOME/.local"` from inside a freshly extracted archive.
The native copy installer is a manual alternative; the shell installer above
provides versioned activation and rollback preservation.

## First program

Save `hello.fz`:

```python
fn main():
    print("Hello Faz!")
```

```sh
faz run hello.fz
faz build hello.fz -o hello
./hello
```

Both executions print `Hello Faz!`. `faz check hello.fz` and
`faz emit-llvm hello.fz -o hello.ll` are also available.

## macOS security prompts

The package uses ad-hoc signatures for its modified library paths. It is not
signed with an Apple Developer ID and is not notarized. Gatekeeper may block
an archive obtained through a browser. If macOS blocks it, review the source,
release origin and checksums before deciding whether to allow it through the
system's normal per-application security UI. The installer does not remove
quarantine attributes or disable Gatekeeper. We have tested command-line
downloads and SDK/tool isolation, not every browser/quarantine configuration.

## Licenses and replacement libraries

Faz is MIT licensed. Bundled components have their own licenses in
`lib/faz/llvm/notices`. The release includes
`faz-v0.1.0-linux-x86_64-sources.tar.gz` with the matching Ubuntu source packages,
Debian patches/build rules, full Faz sources, provenance, hashes, and rebuilding/
relinking instructions. Keep that source archive available alongside any
redistribution of these binary packages. Libraries and link inputs can be
replaced locally; see its `REBUILD.md` and [toolchain configuration](native-toolchain.md).

For developer builds and future release preparation, see
[native-toolchain.md](native-toolchain.md).
