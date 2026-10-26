#!/usr/bin/env python3
"""Build, verify, warm up, and benchmark the three native implementations."""
import argparse
import json
import os
from pathlib import Path
import platform
import random
import shutil
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "examples/benchmarks"
BUILD = ROOT / "build/benchmarks"
LANGUAGES = ["faz", "rust", "go"]
WORKLOADS = {"arithmetic": 20_000_000, "sieve": 3_000_000, "allocation": 100_000}


def fib(n):
    if n == 0:
        return 0, 1
    a, b = fib(n // 2)
    c = a * (2 * b - a) % 1_000_000_007
    d = (a * a + b * b) % 1_000_000_007
    return (d, (c + d) % 1_000_000_007) if n % 2 else (c, d)


def reference(mode, n):
    if mode == "arithmetic":
        return fib(n)[0]
    if mode == "allocation":
        return sum((batch + index) % 1000 for batch in range(n) for index in range(128))
    composite = bytearray(n + 1)
    for p in range(2, int(n**0.5) + 1):
        if not composite[p]:
            composite[p*p:n+1:p] = b"\1" * ((n - p*p) // p + 1)
    return sum(not composite[i] for i in range(2, n + 1))


def run(language, mode, n, expected):
    start = time.perf_counter_ns()
    result = subprocess.run([str(BUILD / language), mode, str(n)],
                            capture_output=True, text=True, check=True)
    elapsed = (time.perf_counter_ns() - start) / 1_000_000
    assert result.stdout.strip() == str(expected), (language, mode, n, result.stdout, expected)
    return elapsed


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=int, default=9)
    args = parser.parse_args()
    if args.runs < 3:
        parser.error("use at least three measured runs")
    BUILD.mkdir(parents=True, exist_ok=True)
    faz = shutil.which("faz") or str(Path.home() / ".local/bin/faz")
    commands = {
        "faz": [faz, "build", str(SOURCE / "workload.fz"), "-o", str(BUILD / "faz")],
        "rust": ["rustc", "-C", "opt-level=3", str(SOURCE / "workload.rs"), "-o", str(BUILD / "rust")],
        "go": ["go", "build", "-o", str(BUILD / "go"), str(SOURCE / "workload.go")],
    }
    env = {**os.environ, "FAZ_OPT_LEVEL": "3"}
    for command in commands.values():
        subprocess.run(command, env=env, cwd=ROOT, check=True)
    versions = {}
    for language, command in {"faz": [faz, "--version"], "rust": ["rustc", "--version"],
                              "go": ["go", "version"]}.items():
        versions[language] = subprocess.check_output(command, text=True).strip()
    # Independent Python oracle, including boundary cases, not just cross-language agreement.
    for mode in WORKLOADS:
        for n in [0, 1, 2, 10, 127, 1001]:
            expected = reference(mode, n)
            for language in LANGUAGES:
                run(language, mode, n, expected)
    results = {}
    rng = random.Random(42)
    for mode, n in WORKLOADS.items():
        expected = reference(mode, n)
        samples = {language: [] for language in LANGUAGES}
        for _ in range(2):
            for language in LANGUAGES:
                run(language, mode, n, expected)
        for _ in range(args.runs):
            order = LANGUAGES.copy()
            rng.shuffle(order)
            for language in order:
                samples[language].append(run(language, mode, n, expected))
        results[mode] = {"n": n, "checksum": expected, "languages": {
            language: {"median_ms": statistics.median(values), "min_ms": min(values),
                       "max_ms": max(values), "samples_ms": values}
            for language, values in samples.items()}}
    cpu = platform.processor()
    if platform.system() == "Darwin":
        cpu = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"], text=True).strip()
    report = {"platform": platform.platform(), "cpu": cpu, "versions": versions,
              "commands": commands, "faz_opt_level": 3, "warmups": 2, "runs": args.runs,
              "binary_bytes": {language: (BUILD / language).stat().st_size for language in LANGUAGES},
              "results": results}
    (BUILD / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    lines = ["# Local benchmark results", "", f"Machine: {cpu}; {platform.platform()}", "",
             *[f"- {version}" for version in versions.values()], "",
             f"Two warmups and {args.runs} measured runs per workload/language, randomized order.",
             "Median end-to-end wall time, including process startup and one checksum print.", "",
             "| Workload | Input | Faz | Rust | Go | Faz / Rust | Faz / Go |",
             "|---|---:|---:|---:|---:|---:|---:|"]
    for mode, data in results.items():
        f, r, g = [data["languages"][language]["median_ms"] for language in LANGUAGES]
        lines.append(f"| {mode} | {data['n']:,} | {f:.2f} ms | {r:.2f} ms | {g:.2f} ms | {f/r:.2f}× | {f/g:.2f}× |")
    lines += ["", "Ratios above 1 mean Faz took longer.", "",
              "| Native executable | Compiler-output size (not manually stripped) |", "|---|---:|"]
    for language, size in report["binary_bytes"].items():
        lines.append(f"| {language} | {size / 1024:.1f} KiB |")
    lines += ["", "Faz: FAZ_OPT_LEVEL=3; Rust: -C opt-level=3; Go: default optimized build.",
              "All outputs checked against independent Python reference implementations.",
              "Raw samples and commands: `build/benchmarks/results.json`.", "",
              "These are three microbenchmarks, not a general language ranking. They exclude compilation,",
              "networking, parallelism, and application-scale behavior. Memory use is not measured.",
              "Sizes reflect different runtime/linker/symbol defaults, not equivalent deployment packages.", ""]
    markdown = "\n".join(lines)
    (BUILD / "results.md").write_text(markdown)
    print(markdown)


if __name__ == "__main__":
    main()
