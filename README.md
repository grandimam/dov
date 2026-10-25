<p align="center">
  <img src="assets/faz.png" alt="Faz, the fox mascot of the Faz language" width="280" />
</p>

<h1 align="center">Faz</h1>

<p align="center"><sub>Meet <strong>Faz</strong>, our resident fox. Has another side project.</sub></p>

<p align="center">
  <strong>For fun. For un-serious programmers.</strong><br />
  Tiny tools. Weird ideas. One more weekend project.
</p>

<p align="center">
  <a href="https://github.com/grandimam/jam/actions/workflows/ci.yml"><img src="https://github.com/grandimam/jam/actions/workflows/ci.yml/badge.svg" alt="CI status" /></a>
  <a href="#faz-makes-faz"><img src="https://img.shields.io/badge/written_in-Faz-82416D?style=flat-square&amp;labelColor=211827" alt="Written in Faz" /></a>
  <a href="#inside-the-compiler"><img src="https://img.shields.io/badge/compiles_to-native-E85A8F?style=flat-square&amp;labelColor=211827" alt="Compiles to native executables" /></a>
  <a href="#a-work-in-progress"><img src="https://img.shields.io/badge/status-experimental-C9A7EB?style=flat-square&amp;labelColor=211827" alt="Experimental" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-B6D7A8?style=flat-square&amp;labelColor=211827" alt="MIT license" /></a>
</p>

<p align="center">
  <a href="#try-it"><strong>Get started</strong></a> &nbsp;·&nbsp;
  <a href="#a-taste-of-faz">The language</a> &nbsp;·&nbsp;
  <a href="examples/README.md">Examples</a> &nbsp;·&nbsp;
  <a href="editors/vscode/README.md">VS Code</a> &nbsp;·&nbsp;
  <a href="#faz-makes-faz">Inside the compiler</a>
</p>

---

Faz is a small, statically typed language with Python-inspired syntax, automatic garbage collection, and native executables. **Its compiler is written in Faz.** Bring an idea, a text editor, and a perfectly unreasonable amount of enthusiasm.

```python
fn main():
    plans = [
        "build a tiny game",
        "automate one annoying thing",
        "start another side project",
    ]
    for i in range(len(plans)):
        print(i + 1, plans[i])
```

<p align="center"><sub>Familiar on the outside. A whole compiler inside.</sub></p>

<table>
  <tr>
    <td width="33%" valign="top"><strong>✦ A little syntax</strong><br /><br />Indentation, inferred locals, typed functions, structs, enums, and pattern matching.</td>
    <td width="33%" valign="top"><strong>↗ A real executable</strong><br /><br />LLVM turns your program into native code. Run the result without installing Faz.</td>
    <td width="33%" valign="top"><strong>♥ Room to play</strong><br /><br />Lists, text, files, cooperating tasks, and a tiny HTTP server for your next experiment.</td>
  </tr>
</table>

## Try it

You need **Git and Clang with LLVM IR support**. On macOS, Clang comes with Apple's command-line tools (`xcode-select --install`). On Linux, install Clang through your package manager.

Clone the project:

```sh
git clone https://github.com/grandimam/jam.git faz
cd faz
```

Build the seed compiler for your platform:

<table>
  <tr><th align="left">macOS · Apple Silicon</th><th align="left">Linux · x86_64 / aarch64</th></tr>
  <tr><td><code>bootstrap/seed-darwin.ll</code></td><td><code>bootstrap/seed-linux.ll</code> · glibc 2.33+</td></tr>
</table>

```sh
# macOS — on Linux, replace seed-darwin.ll with seed-linux.ll.
clang -x ir -O2 -Wno-override-module bootstrap/seed-darwin.ll -o faz

# Let Faz rebuild itself, then run your first program.
./faz build-self
./build/faz run examples/hello.fz
# Hello Faz!
```

Install the CLI and make it available in this shell:

```sh
./build/faz install "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"
faz --version
```

Add that `export` line to your shell configuration to keep it available in future sessions. You can also use `./build/faz` directly from the checkout.

> **Clang does the native code generation.** Keep it installed to use `faz build` and `faz run`. `faz check` and `faz emit-llvm` work without it. Set `FAZ_CLANG` to a Clang executable path if needed; LLVM is not bundled with this repository.

## A taste of Faz

Programs start in `fn main()`. Indentation defines blocks, local types are inferred, and function parameters and non-void returns carry type annotations.

### Small functions, big plans

```python
fn square(value: int) -> int:
    return value * value

fn main():
    answer = square(5)
    if answer > 20:
        print("A big square:", answer)
    else:
        print("A small square:", answer)
```

Try it: `faz run examples/functions.fz` → `A big square: 25`.

### A list of perfectly reasonable ideas

```python
fn main():
    plans = ["learn Faz", "make something silly"]
    plans.append("take a break")

    for plan in plans:
        print("-", plan)

    print("Plans:", len(plans))
    print("First:", plans[0])
```

Try it: `faz run examples/lists.fz`. Lists hold elements of one type; indexing starts at zero.

<details>
<summary><strong>✦ Explore enums and pattern matching</strong></summary>

An enum describes the shapes a value can take. A `match` must cover every variant.

```python
enum Reply:
    Found(message: str)
    Missing

fn show(reply: Reply):
    match reply:
        case Reply.Found(message):
            print(message)
        case Reply.Missing():
            print("Nothing here yet")

fn main():
    show(Reply.Found("Found a tiny treasure"))
    show(Reply.Missing())
```

Try it: `faz run examples/matching.fz`.

</details>

<details>
<summary><strong>↗ Make a tiny corner of the internet</strong></summary>

```python
fn hello(path: str) -> str:
    return "you found the tiny internet\n"

fn main():
    http.serve("127.0.0.1", 8080, hello)
```

Save this as `server.fz`, run `faz run server.fz`, and visit `http://127.0.0.1:8080`. Stop it with Ctrl+C. The built-in `http` namespace needs no import.

This is a basic HTTP GET server for local experiments. The [included server](examples/server.fz) also demonstrates a handler that sleeps while other requests can progress.

</details>

<details>
<summary><strong>♥ Give two tasks something to do</strong></summary>

```python
fn worker(name: str, delay: int):
    print(name, "started")
    task.sleep(delay)
    print(name, "finished")

fn main():
    with task.group() as group:
        group.spawn(worker, "first", 30)
        group.spawn(worker, "second", 10)
        print("Both tasks scheduled")
    print("All tasks finished")
```

Try it: `faz run examples/tasks.fz`. The group waits for its workers before leaving the block. `task.sleep` takes milliseconds. Tasks cooperate on one OS thread; they do not provide CPU parallelism.

</details>

### Pick your next experiment

| In the mood for… | Start here | What you'll try |
| :--- | :--- | :--- |
| A useful little script | [Arguments](examples/arguments.fz) · [Files](examples/files.fz) | Read CLI arguments, write and read text |
| Giving ideas a shape | [Structs](examples/structs.fz) · [Matching](examples/matching.fz) | Records, mutable fields, and enum variants |
| More than one file | [Modules](examples/modules/main.fz) | File-relative imports and qualified names |
| A bit of coordination | [Tasks](examples/tasks.fz) · [HTTP](examples/server.fz) | Task groups, timers, and requests |
| Building a language inside a language | [Expression compiler](examples/exprc/README.md) | Scan, parse, and emit LLVM IR in Faz |

**[Follow the examples walkthrough →](examples/README.md)** Commands, expected output, and small things to change along the way.

## Your everyday commands

Save the opening example as `plans.fz`, then:

```sh
faz run plans.fz                    # Compile and run
faz check plans.fz                  # Check syntax and types
faz build plans.fz -o build/plans   # Keep a native executable
./build/plans                        # Run it directly
faz emit-llvm plans.fz -o plans.ll  # Peek at the LLVM IR
```

Without `-o`, `faz build plans.fz` writes `build/plans`. Pass program arguments after `--`, as in `faz run examples/arguments.fz -- "tiny internet"`. Use `faz --help` for the command list.

### Dress up your editor

The [VS Code extension](editors/vscode/README.md) brings syntax highlighting, snippets, and the **Faz Blackberry** theme: dark plum, raspberry, cream, and a little sage.

It is installed locally from the repository; it is not published to the Marketplace yet. Compiler diagnostics come from `faz check`; the extension does not include a language server.

## Faz makes Faz

```text
                         ┌────────────────────┐
  your idea ──► .fz ───► │ compiler, in Faz   │ ──► LLVM IR ──► Clang ──► executable
                         └────────────────────┘
                                   ▲
                                   │
                         its own source works too
```

The compiler emits LLVM IR directly. Clang supplies optimization and machine-code generation. The runtime is embedded in the compiler, so an installed Faz compiler can build programs without this checkout. Built programs include the Faz runtime and use platform libraries; they need neither the Faz CLI nor an interpreter to run.

### Inside the compiler

| Ingredient | Where it lives |
| :--- | :--- |
| Lexer, parser, modules, type checking, LLVM emitter, and CLI | [`src/compiler/`](src/compiler/README.md) |
| Tracing garbage collection, values, strings, startup, and tasks | [`src/runtime/`](src/runtime) |
| Files, processes, networking, HTTP, I/O, and text operations | [`src/std/`](src/std) |
| Native platform bindings in LLVM IR | [`src/runtime/platform/`](src/runtime/platform) |
| Generated compiler seeds for the first build | [`bootstrap/`](bootstrap) |
| Test runner and conformance fixtures, written in Faz | [`tests/`](tests) |

The collector reclaims unreachable objects, including cycles. Facilities such as `fs`, `sys`, `net`, and `http` are built-in namespaces backed by `src/std/`; they do not require source imports.

<details>
<summary><strong>How does a language compile itself?</strong></summary>

The repository ships generated LLVM IR snapshots in `bootstrap/`. Clang turns the appropriate seed into the first compiler on a machine without Faz. That compiler rebuilds Faz from `src/`.

`faz build-self` rebuilds successive generations and checks that they emit identical LLVM IR. `faz verify` additionally runs the conformance suite with two compiler generations and checks both platform seeds against freshly generated output.

To try compiling the compiler directly:

```sh
./build/faz build src/compiler/main.fz -o build/faz-next
./build/faz-next run examples/hello.fz
```

Edit the Faz sources, then regenerate the embedded runtime and seeds with `faz refresh-seed`. Keep the generated seeds in `bootstrap/`; they are build inputs. This build uses LLVM directly, with no C backend or Rust toolchain.

</details>

## Tinker with it

Run these from the repository root:

| Command | What it does |
| :--- | :--- |
| `./build/faz test` | Build and run the native Faz conformance suite |
| `./build/faz build-self` | Rebuild the compiler and compare successive generations |
| `./build/faz verify` | Check self-hosting, conformance, and seed freshness |
| `./build/faz refresh-seed` | Regenerate the embedded runtime and platform seeds, with verification |

CI runs bootstrap verification on macOS and Linux and tests the VS Code extension separately. Compiler internals are documented in the [compiler guide](src/compiler/README.md).

### A work in progress

Faz is experimental: syntax and APIs can change, and Python packages do not run in Faz. It's a place to learn, make small things, and see how far a weird idea goes.

---

<p align="center">
  <strong>Small language. Big ideas. Tiny paws.</strong><br />
  <sub>Made by <a href="https://x.com/thegrandimam">@thegrandimam</a> · <a href="LICENSE">MIT licensed</a> · Mascot: Faz, a little fox with big ideas.</sub>
</p>
