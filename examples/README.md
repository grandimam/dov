# Learn Faz by running it

> Core-language transition: `hello.fz`, `fibonacci.fz`, `functions.fz`, `lists.fz`, and `structs.fz` use the new default rules. The commands below mark older examples that require `--legacy-language` after the source path. In particular, pattern matching and the educational compiler have not been migrated. See [the transition notes](../docs/core-language.md).


Start with the [installation instructions](../README.md#try-it). Run the commands below from the repository root. If you haven't installed the CLI on your `PATH`, replace `faz` with `./build/faz`.

## Your first program

[`hello.fz`](hello.fz):

```python
fn main():
    print("Hello Faz!")
```

```sh
faz run examples/hello.fz
# Hello Faz!
```

`main` is the entry point. Use four spaces to indent its body. `print` adds a newline, and `#` starts a comment.

Check a program without running it, or keep a native executable:

```sh
faz check examples/hello.fz
faz build examples/hello.fz -o build/hello
./build/hello
```

## Functions and decisions

Open [`functions.fz`](functions.fz). `fn square(value: int) -> int` takes an integer and returns an integer. `answer = square(5)` infers the local variable's type. An `if` / `else` chooses what to print.

```sh
faz run examples/functions.fz
# A big square: 25
```

Try changing `square(5)` to `square(3)`. For recursion, run [`fibonacci.fz`](fibonacci.fz) with `faz run examples/fibonacci.fz`; it prints the first twelve Fibonacci numbers alongside their indexes.

## Lists and loops

[`lists.fz`](lists.fz) creates a list of strings, appends another item, and visits each item with `for`. Indexes start at zero; `len` counts items. A list's elements share one type.

```sh
faz run examples/lists.fz
# - learn Faz
# - make something silly
# - take a break
# Plans: 3
# First: learn Faz
```

Try adding another plan or using `for i in range(len(plans))` to print numbered items.

## Structs

[`structs.fz`](structs.fz) defines a `Project` with a string name and a boolean flag. `Project("tiny game", False)` constructs a value; `project.finished = True` updates a field.

```sh
faz run examples/structs.fz
# tiny game False
# tiny game True
```

## Enums and matching

[`matching.fz`](matching.fz) defines a reply that can be `Reply.Found(message)` or `Reply.Missing()`. `match` handles each variant and extracts its data. Faz checks that every variant is covered.

```sh
faz run examples/matching.fz --legacy-language
# Found a tiny treasure
# Nothing here yet
```

For a recursive enum, try [`ast.fz`](ast.fz):

```sh
faz run examples/ast.fz --legacy-language
# answer: 42 column: 3
# 0
# 1
# 2
```

## Command-line arguments

[`arguments.fz`](arguments.fz):

```python
fn main():
    args = sys.args()
    name = "world"
    if len(args) > 0:
        name = args[0]
    print("Hello, " + name + "!")
```

```sh
faz run examples/arguments.fz --legacy-language
# Hello, world!
faz run examples/arguments.fz --legacy-language -- "tiny internet"
# Hello, tiny internet!
```

The `--` separates Faz's options from your program's arguments. `sys.args()` excludes the executable name. After building an executable, pass arguments directly:

```sh
faz build examples/arguments.fz --legacy-language -o build/greet
./build/greet "tiny internet"
# Hello, tiny internet!
```

## Text files

[`files.fz`](files.fz) writes a note, reads it back, and removes its temporary directory:

```python
fn main():
    directory = fs.temp_dir()
    path = directory + "/note.txt"
    fs.write_text(path, "Hello from a file!")
    print(fs.read_text(path))
    fs.remove_temp(directory)
```

```sh
faz run examples/files.fz
# Hello from a file!
```

`fs.write_text` creates or overwrites a UTF-8 text file. Relative paths use the program's working directory. `fs` and `sys` are built-in namespaces; no import is needed.

## Two files, one program

[`modules/greetings.fz`](modules/greetings.fz):

```python
fn hello(name: str) -> str:
    return "Hello, " + name + "!"
```

[`modules/main.fz`](modules/main.fz):

```python
import greetings

fn main():
    print(greetings.hello("Faz"))
```

```sh
faz run examples/modules/main.fz
# Hello, Faz!
```

Imports resolve relative to the importing file. `greetings.fz` sits beside `main.fz`; its functions are accessed through `greetings`.

## Tasks and a tiny server

[`tasks.fz`](tasks.fz) starts two workers in a task group. The group waits for both workers before the final message:

```sh
faz run examples/tasks.fz
# Both tasks scheduled
# first started
# second started
# second finished
# first finished
# All tasks finished
```

`task.sleep` takes milliseconds and lets other tasks run while waiting. Tasks cooperate on one OS thread; they don't run CPU work in parallel.

Start [`server.fz`](server.fz):

```sh
faz run examples/server.fz
```

In another terminal:

```sh
curl http://127.0.0.1:8080/hello
# Hello from Faz!
```

Visit `/slow` to try a handler that sleeps while other requests can progress. Stop the server with Ctrl+C.

## Build something bigger

[`lexer.fz`](lexer.fz) demonstrates scanning source text. The [expression compiler](exprc/README.md) combines multiple modules, a syntax tree, parsing, and LLVM output into a working tool written in Faz.
