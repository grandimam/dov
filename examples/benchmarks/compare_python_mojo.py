#!/usr/bin/env python3
"""Compare native Faz/Mojo with plain CPython using the existing workloads."""
import argparse
import json
import os
import platform
import random
import shutil
import statistics
import subprocess
import sys
import time

from run import BUILD, ROOT, SOURCE, WORKLOADS, reference


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--runs", type=int, default=9)
    args = parser.parse_args()
    if args.runs < 3:
        parser.error("use at least three measured runs")
    BUILD.mkdir(parents=True, exist_ok=True)
    faz = shutil.which("faz") or str(os.path.expanduser("~/.local/bin/faz"))
    mojo = shutil.which("mojo")
    if not mojo:
        parser.error("install the Mojo language compiler and put mojo on PATH")
    build_commands = [
        [faz, "build", str(SOURCE / "workload.fz"), "-o", str(BUILD / "faz")],
        [mojo, "build", "-O3", str(SOURCE / "workload.mojo"), "-o", str(BUILD / "mojo")],
    ]
    for command in build_commands:
        subprocess.run(command, env={**os.environ, "FAZ_OPT_LEVEL": "3"}, cwd=ROOT, check=True)
    commands = {"Faz": [str(BUILD / "faz")],
                "Python": [sys.executable, str(SOURCE / "workload.py")],
                "Mojo": [str(BUILD / "mojo")]}
    versions = {
        "Faz": subprocess.check_output([faz, "--version"], text=True).strip(),
        "Python": platform.python_implementation() + " " + platform.python_version(),
        "Mojo": subprocess.check_output([mojo, "--version"], text=True).strip(),
    }

    def measure(language, mode, n, expected):
        start = time.perf_counter_ns()
        output = subprocess.check_output([*commands[language], mode, str(n)], text=True)
        elapsed = (time.perf_counter_ns() - start) / 1_000_000
        assert output.strip() == str(expected), (language, mode, n, output, expected)
        return elapsed

    for mode in WORKLOADS:
        for n in [0, 1, 2, 10, 127, 1001]:
            expected = reference(mode, n)
            for language in commands:
                measure(language, mode, n, expected)
    rng = random.Random(42)
    results = {}
    for mode, n in WORKLOADS.items():
        expected = reference(mode, n)
        samples = {language: [] for language in commands}
        for _ in range(2):
            for language in commands:
                measure(language, mode, n, expected)
        for _ in range(args.runs):
            order = list(commands)
            rng.shuffle(order)
            for language in order:
                samples[language].append(measure(language, mode, n, expected))
        results[mode] = {"n": n, "checksum": expected, "languages": {
            language: {"median_ms": statistics.median(values), "min_ms": min(values),
                       "max_ms": max(values), "samples_ms": values}
            for language, values in samples.items()}}
    cpu = platform.processor()
    if platform.system() == "Darwin":
        cpu = subprocess.check_output(["sysctl", "-n", "machdep.cpu.brand_string"], text=True).strip()
    report = {"platform": platform.platform(), "cpu": cpu, "versions": versions,
              "build_commands": build_commands, "run_commands": commands,
              "faz_opt_level": 3, "warmups": 2, "runs": args.runs, "results": results}
    (BUILD / "python-mojo-results.json").write_text(json.dumps(report, indent=2) + "\n")
    lines = ["# Faz vs Python vs Mojo", "", f"Machine: {cpu}; {platform.platform()}", "",
             *[f"- {version}" for version in versions.values()], "",
             f"Median of {args.runs} measured runs after two warmups, randomized order.",
             "End-to-end wall time includes process startup and checksum output; compilation is excluded.", "",
             "| Workload | Input | Faz | Python | Mojo | Python time / Faz time | Faz time / Mojo time |",
             "|---|---:|---:|---:|---:|---:|---:|"]
    for mode, data in results.items():
        f, p, m = [data["languages"][language]["median_ms"] for language in commands]
        lines.append(f"| {mode} | {data['n']:,} | {f:.2f} ms | {p:.2f} ms | {m:.2f} ms | {p/f:.2f}× | {f/m:.2f}× |")
    lines += ["", "Faz and Mojo: native builds at optimization level 3. Python: plain CPython loops,",
              "without NumPy, Numba, or other acceleration. Python integers are arbitrary-precision;",
              "Faz and Mojo use native 64-bit integers here. All results fit within signed 64 bits.",
              "Mojo uses its default host CPU targeting; no explicit CPU override was supplied.",
              "All checksums were verified against independent reference algorithms, including boundary cases.", "",
              "These are three CPU microbenchmarks, not a universal speed ranking. No GPU, SIMD-specific",
              "implementation, parallelism, memory profiling, or compile-time comparison is included.",
              "The Python result does not represent optimized NumPy or JIT-compiled Python workloads.", "",
              "Reproduce: `python3 examples/benchmarks/compare_python_mojo.py --runs 9`.",
              "Raw samples: `python-mojo-results.json` beside the generated report.", ""]
    markdown = "\n".join(lines)
    (BUILD / "python-mojo-results.md").write_text(markdown)
    print(markdown)


if __name__ == "__main__":
    main()
