# Taskboard: a native Faz CLI

A multi-module, persistent task manager using the **default core language**, not
`--legacy-language`. Demonstrates typed structs, lists, module imports, explicit
mutable parameters, string parsing, Unicode, file I/O, CLI arguments, and errors.

From the repository root:

```sh
export PATH="$HOME/.local/bin:$PATH"
faz check examples/taskboard/main.fz
faz build examples/taskboard/main.fz -o build/taskboard

./build/taskboard build/my-tasks.tsv add 2 "Write documentation"
./build/taskboard build/my-tasks.tsv add 1 "Ship the native app 🦊"
./build/taskboard build/my-tasks.tsv list
./build/taskboard build/my-tasks.tsv done 2
./build/taskboard build/my-tasks.tsv search "🦊"
./build/taskboard build/my-tasks.tsv list all
./build/taskboard build/my-tasks.tsv stats
./build/taskboard build/my-tasks.tsv reopen 2

python3 examples/taskboard/test.py
```

Run `./build/taskboard` for usage. Priority 1 is highest; listings sort by
priority then ID. The database path is explicit, so separate files act as
separate boards. Its parent directory must already exist.

## Modules

- `main.fz`: command dispatch, filters, priority ordering, summary statistics.
- `store.fz`: task model, strict database parsing, serialization, state changes.
- `text.fz`: validated decimal parsing and delimiter splitting.
- `test.py`: isolated black-box tests of the real executable; Python is only a
  development/test dependency, not needed to run Taskboard.

Database rows are `ID<TAB>priority<TAB>completed<TAB>title`, preceded by a version
header. Titles can contain Unicode but not tabs or newlines. Loading rejects
invalid headers, fields, IDs, ordering, priorities, and completion flags before
any update is written. IDs remain stable when tasks are completed or reopened.

## Boundaries

This is a learning example, not production storage: it rewrites the whole file,
with **no atomic replacement or locking**. Use only one writer, and do not store
important data without backups. A crash during a write can damage the file.
No deletion, scheduling, case-insensitive search, or general resource-management
abstraction is implemented.
