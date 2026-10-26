# Core-language implementation status

Implementation based on draft v0.1, 26 October 2026. This is an implementation
of the defined public core rules, not a claim that every open language-design
question or the self-hosted source migration is finished.

## Verified

- Full native conformance: **721 checks, zero failures**, independently on each
  of two self-hosted compiler generations.
- Compiler generations emit identical LLVM IR (bootstrap fixed point).
- Linux and Darwin LLVM seeds regenerated. Refreshed Linux seed reproduces the
  verified compiler. Darwin seed additionally compiles to an arm64 Mach-O
  object; macOS execution was not available in this environment.
- Core value/ABI fixture passes natively and at LLVM O3 with GC stress:
  3,176 bytes allocated, 3,176 reclaimed, zero live bytes at shutdown.
- Editor tests: **7 passed**.
- Installed compiler runs hello and rejects immutable reassignment by default.
- Safe task-group example runs under default core semantics.

The conformance suite separates historical compatibility tests from the new
core tests. Default build, run, check, LLVM emission, and positional emission
are tested against accidental legacy-mode bypass. Historical expectations for
aggregate equality and print diagnostics changed deliberately to match the new
value semantics. A bounded adversarial review found and fixed ownership bugs;
testing is not a formal soundness proof.

## Implemented public behavior

Immutable/deeply immutable bindings; explicit mutation and fixed types;
read-only versus exclusive mutable parameters with ordinary call syntax;
scalar caller mutation and field/index writeback; conflicting-borrow checks;
independent struct-field access; aggregate move/freeze and explicit deep copy;
owned local returns; lexical scope without implicit shadowing; read-only loop
bindings; indexed mutation; structural equality; and existing tracing GC.

## Boundaries and deferred decisions

- Returning borrowed aggregates or extracting owned nested aggregates requires
  explicit copying; no implicit copies, partial moves, or lifetime annotations.
- Dynamic list indices are conservatively considered overlapping.
- Shared immutable subobjects must be copied before storing under a mutable
  aggregate; mixed per-field permission graphs are not yet modeled.
- Moving an outer aggregate owner inside a loop is conservatively rejected.
  Control-flow moves may be rejected even on paths a stronger analysis could
  prove safe. Whole-owner reinitialization outside such ambiguity is supported.
- General cyclic user graphs, cyclic structural operations, and general
  resource scopes remain unresolved. The supplied resource section was cut
  off; no `fs.open`/general `with` contract was invented.
- Pattern matching remains available in explicit legacy mode, outside this
  fundamentals draft. No new enum/generic design was introduced.
- The compiler, runtime, and historical harness are still written in the
  previous dialect and bootstrap with explicit `--legacy-language`. Their AST
  aliases, borrowed helper returns, and shared mutable builder records require
  a deliberate source redesign/copying migration, not simply inserting `mut`.
  Normal user programs and installed compilers do not inherit legacy mode.

See [core-language.md](core-language.md) for syntax and restrictions.
