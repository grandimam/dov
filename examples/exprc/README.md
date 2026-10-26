# An expression compiler written in Faz

A small end-to-end compiler example: the scanner, AST, parser, and LLVM emitter are Faz programs split across local modules. This is **not the full Faz compiler** and does not compile itself.

Supported input: decimal integers, `+`, `-`, `*`, unary `-`, parentheses, whitespace, and `#` comments. Arithmetic is signed 64-bit. Literal magnitudes stop at `9223372036854775807`; overflow while scanning fails with a Faz diagnostic, and generated-program arithmetic overflow exits with code 2.

This educational compiler still uses the earlier Faz dialect. Its build command
opts into `--legacy-language`; its generated executables are unchanged.

From the repository root:

```sh
faz build examples/exprc/main.fz --legacy-language -o build/exprc
./build/exprc examples/exprc/example.expr build/expression.ll
clang -x ir -O2 build/expression.ll -o build/expression
./build/expression
# 42
```

`exprc` writes LLVM IR directly. LLVM's signed overflow intrinsics preserve checked arithmetic under optimization. It does not invoke a compiler itself. Once built, `exprc` needs neither its `.fz` sources nor the Faz compiler to execute. Its generated executable uses only the platform's standard output and process-exit functions, without the Faz runtime.

| Module | Responsibility |
| --- | --- |
| `syntax.fz` | Token records and recursive tagged AST |
| `scanner.fz` | Text → typed tokens with source offsets |
| `parser.fz` | Precedence-aware recursive-descent parsing |
| `emitter.fz` | AST → self-contained LLVM IR program |
| `main.fz` | Arguments and input/output files |

Integration tests compile the generated LLVM IR, execute the result, and check malformed input, signed boundaries, overflow, and standalone execution. The full Faz compiler lives in [`src/compiler`](../../src/compiler) and is itself written in Faz.
