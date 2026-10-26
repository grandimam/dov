# Faz core language, v0.1

This document tracks the implementation of the draft core-language design.
The draft remains the design source; restrictions below are conservative
implementation boundaries, not silently added language features. See the
`tests/core_checks.fz` default-mode conformance cases. The older corpus runs
separately in explicit compatibility mode.

## Bindings and values

Bindings are immutable by default. `mut` grants mutation authority without
changing a binding's fixed inferred or annotated type:

```python
fn main():
    name = "Faz"
    mut count = 0
    count += 1
    mut values: list[int] = [1, 2]
    values.append(3)
    values[0] *= 2
```

Immutability is recursive through owned struct fields and nested collections.
A mutable outer binding is not permission to mutate an independently shared
immutable value. Mutation without ownership is rejected; it never triggers an
implicit deep copy. Arithmetic compound assignment supports `+=`, `-=`, `*=`,
`//=`, and `%=` and must evaluate its receiver/index only once.

## Calls and access

Ordinary parameters are temporary read-only access. A `mut` parameter requests
temporary exclusive mutable access, including a scalar's caller-owned storage:

```python
fn increment(mut count: int):
    count += 1

fn main():
    mut count = 0
    increment(count)
    print(count)  # 1
```

The caller does not write `mut` at the call site. The same owner cannot be
passed for two conflicting accesses in one call. Distinct owned struct fields
can be distinguished; ambiguous overlapping storage must be rejected rather
than assumed disjoint. When a call returns, its temporary access ends.

## Transfers, copies, and returns

Immutable values can share backing storage. Assignment of a mutable aggregate
transfers ownership and invalidates its previous binding. Moving into an
immutable binding freezes the result. `copy(value)` is the explicit way to
obtain independent data, recursively through nested owned aggregates:

```python
fn main():
    mut original = [[1, 2]]
    mut independent = copy(original)
    independent[0].append(3)
    print(original, independent)
```

Returning an exclusively owned local transfers it to the caller. Returning
borrowed aggregate storage, extracting an alias from a mutable owner, and
partial moves are unresolved in the draft. The current implementation must
reject such escapes unless the user explicitly copies the value. It must not
silently clone, retain an unsafe alias, or freeze a caller's borrowed storage.
The current implementation conservatively rejects mixed-permission aggregate
graphs: inserting an independently shared aggregate into a mutable owner
requires `copy`, even if other fields could theoretically be mutated safely.

Small scalar assignments copy their values; strings remain immutable and can
share storage. A named immutable aggregate returned from a function remains
shared: explicitly `copy` it before assigning mutable ownership.

## Lexical scope and loops

A new binding is visible only in its lexical block. Assignment to an existing
visible name is reassignment, not shadowing. It succeeds only for a mutable
binding. Declaring `mut` again does not bypass that rule.

Declare a mutable result outside a conditional when its branches must assign
it. Loop bindings are read-only. Mutating an owner while iterating over its
borrowed elements is rejected; an independent index range permits updates:

```python
fn main():
    mut values = [1, 2, 3]
    for index in range(len(values)):
        values[index] *= 2
    print(values)
```

Moves through control flow must not make a possibly moved owner usable after a
branch or loop. Moving an outer owner inside a loop is conservatively rejected.
Reinitializing a moved owner only inside a possibly-zero-trip loop does not
restore it after the loop; unconditional reinitialization does. An unreachable
path does not justify unsound aliasing on other paths.

## Equality and memory

`==` and `!=` compare values. Lists compare ordered elements; structs compare
their corresponding fields recursively. Strings compare content. Faz does not
introduce allocation identity or an `is` operator. No unrestricted guarantee is
made for structural equality on arbitrary user-created cyclic graphs.

Tracing garbage collection remains responsible for ordinary heap lifetime.
Ownership and exclusive access govern mutation authority, not object disposal.
Compiler/runtime objects and legacy programs may still require GC cycle
handling even when new safe-language code cannot construct those graphs.

## Deliberately incomplete design areas

- Borrowed aggregate return values and escaping mutable references.
- Partial moves and restoration of partially moved owners.
- General alias proofs for dynamic indices and shared subobjects.
- User-created cyclic structures and equality on unrestricted graphs.
- Pattern-matching ownership and callback functions with mutable parameters.
  Pattern matching is outside this fundamental-semantics draft; use the
  explicit legacy dialect for older matching examples.
- Deterministic resource scopes beyond the existing task-group construct.

The supplied resource-management section ended at `content = file.read`.
This change does not invent a general `with fs.open(...)` API, lifetime model,
or file/socket cleanup behavior from that incomplete example.

## Bootstrap compatibility is explicit

The compiler and historical examples/tests were written in the earlier Faz
semantics. Their migration is separate work. To compile those sources during
this transition, pass `--legacy-language` after the input path:

```sh
build/faz build src/compiler/main.fz --legacy-language -o build/faz-next
build/faz check old-program.fz --legacy-language
```

This flag is not enabled by path, environment, or installation. Normal compiler
commands use the new rules. `build-self`, `verify`, and the old test harness opt
in explicitly for their legacy sources; the new core tests do not. Installation
copies the compiler without changing its default language mode. A passing old
regression suite is not evidence that the compiler's source is already migrated
to the new ownership discipline.
