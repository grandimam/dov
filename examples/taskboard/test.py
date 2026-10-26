#!/usr/bin/env python3
"""Black-box tests against the compiled native program; isolated temporary data."""
from pathlib import Path
import subprocess
import sys
import tempfile

binary = Path(sys.argv[1] if len(sys.argv) > 1 else "build/taskboard").resolve()
with tempfile.TemporaryDirectory(prefix="faz-taskboard-") as directory:
    db = Path(directory) / "tasks.tsv"

    def run(*args, ok=True):
        result = subprocess.run([str(binary), str(db), *args], capture_output=True, text=True)
        assert (result.returncode == 0) == ok, (args, result.stdout, result.stderr)
        return result.stdout if ok else result.stderr

    assert "Total: 0" in run("stats")
    assert not db.exists(), "read-only commands must not create a database"
    assert "Added #1" in run("add", "3", "Write documentation")
    assert "Added #2" in run("add", "1", "Ship native Faz app 🦊")
    assert "Added #3" in run("add", "2", "Run benchmarks")
    output = run("list")
    assert output.index("#2") < output.index("#3") < output.index("#1")
    run("done", "2")
    assert "#2" not in run("list")
    assert "[x] #2" in run("list", "done")
    assert "3 task(s)" in run("list", "all")
    assert "#2" in run("search", "🦊")
    assert "0 task(s)" in run("search", "missing")
    assert "Completion: 33 %" in run("stats")
    run("reopen", "2")
    assert "[ ] #2" in run("list")
    before = db.read_bytes()
    for args in [("add", "0", "Bad"), ("add", "4", "Bad"),
                 ("add", "x", "Bad"), ("add", "1", ""),
                 ("add", "1", "   "), ("add", "1", "bad\trow"),
                 ("add", "1", "bad\nrow"), ("done", "999"),
                 ("done", "-1"), ("done", "1000000000"),
                 ("list", "unknown"), ("unknown",), ("add",)]:
        run(*args, ok=False)
        assert db.read_bytes() == before, args
    for content in ["bad header\n", "faz-taskboard-v1\n1\t1\t9\tBad\n",
                    "faz-taskboard-v1\n1\t1\t0\tFirst\n1\t2\t0\tDuplicate\n",
                    "faz-taskboard-v1\nmalformed\n"]:
        db.write_text(content)
        run("add", "1", "Do not overwrite", ok=False)
        assert db.read_text() == content
print("Taskboard: persistence, ordering, Unicode, filters, state changes, validation, and corruption tests passed.")
