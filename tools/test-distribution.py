#!/usr/bin/env python3
"""Exercise a relocated distribution, with host LLVM discovery disabled.

No host LLVM or linker may satisfy dependencies. Optional macOS sandbox testing
denies access to Homebrew, Apple developer tools, SDKs, and compiler drivers.
"""
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import tempfile

source = Path(sys.argv[1]).resolve()
manifest = json.loads((source / 'manifest.json').read_text())
for name, digest in manifest['sha256'].items():
    assert hashlib.sha256((source / name).read_bytes()).hexdigest() == digest, name
env = {key: value for key, value in os.environ.items()
       if not key.startswith(('FAZ_', 'DYLD_', 'LD_')) and key not in ('CC', 'SDKROOT')}
env.update(PATH='', CC='/missing/cc', FAZ_CLANG='/missing/clang', FAZ_LLVM_BUNDLED_ONLY='1',
           FAZ_TOOLCHAIN_BUNDLED_ONLY='1', DEVELOPER_DIR='/missing/developer-tools',
           SDKROOT='/missing/sdk')
system = platform.system().lower()


def command(*args, ok=True):
    child_env = dict(env)
    if str(args[0]) == '/usr/bin/otool':
        # Inspection is a maintainer tool; only Faz must survive poisoned SDK discovery.
        child_env.pop('DEVELOPER_DIR', None)
        child_env.pop('SDKROOT', None)
    result = subprocess.run([str(arg) for arg in args], env=child_env, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=180)
    assert (result.returncode == 0) == ok, (args, result.returncode, result.stdout, result.stderr)
    return result


with tempfile.TemporaryDirectory(prefix='faz distribution ') as temporary:
    work = Path(temporary)
    dist = work / 'relocated archive'
    shutil.copytree(source, dist)
    library = dist / 'lib/faz/llvm/lib'
    for file in list(library.iterdir()) + list((library.parent / 'bin').iterdir()):
        if system == 'darwin':
            deps = command('/usr/bin/otool', '-L', file).stdout.splitlines()[1:]
            for line in deps:
                name = line.strip().split(' (')[0]
                assert name.startswith(('/usr/lib/', '/System/Library/', '@loader_path/')), name
                if name.startswith('@loader_path/'):
                    assert (file.parent / name[len('@loader_path/'):]).exists(), name
        else:
            deps = command('/usr/bin/ldd', file).stdout
            assert 'not found' not in deps, deps
            for line in deps.splitlines():
                if ' => /' not in line:
                    continue
                name, target = line.strip().split(' => ')
                # Every non-glibc dependency must resolve inside this archive.
                import re
                if not re.fullmatch(r'lib(c|m|dl|pthread|rt|resolv|util)\.so\.\d+', name):
                    assert Path(target.split(' (')[0]).parent.resolve() == library.resolve(), line
    compiler = dist / 'bin/faz'
    program = work / 'hello.fz'
    program.write_text('fn main():\n    mut items = [1]\n    items.append(2)\n    print(len(items))\n')
    assert command(compiler, 'run', program).stdout == '2\n'
    installed = work / 'installed copy'
    command(compiler, 'install', installed)
    # Remove the entire original payload to expose accidental absolute paths.
    shutil.rmtree(dist)
    compiler = installed / 'bin/faz'
    assert command(compiler, 'run', program).stdout == '2\n'
    if system == 'darwin' and os.environ.get('FAZ_TEST_ISOLATION') == '1':
        profile = '(version 1)(allow default)'
        for path in ['/opt/homebrew', '/usr/local', '/Applications/Xcode.app', '/Library/Developer']:
            profile += '(deny file-read* (subpath "' + path + '"))'
        for path in ['/usr/bin/xcrun', '/usr/bin/clang', '/usr/bin/cc', '/usr/bin/ld']:
            profile += '(deny process-exec (literal "' + path + '"))'
        assert command('/usr/bin/sandbox-exec', '-p', profile, compiler, 'run', program).stdout == '2\n'
        fixtures = Path(__file__).resolve().parents[1] / 'tests/fixtures'
        core = work / 'core.fz'
        shutil.copy2(fixtures / 'core_values.fz', core)
        env['FAZ_GC_STRESS'] = '1'
        assert command('/usr/bin/sandbox-exec', '-p', profile, compiler, 'run', core).stdout == 'core values passed\n'
        env.pop('FAZ_GC_STRESS')
        tasks = work / 'tasks.fz'
        shutil.copy2(fixtures / 'concurrency_nested_groups_join_before_return_break_and_continue_0.fz', tasks)
        assert command('/usr/bin/sandbox-exec', '-p', profile, compiler, 'run', tasks, '--legacy-language').stdout.endswith('finished\n')
        print('macOS sandbox: native compilation, GC and tasks pass with developer tools, SDKs and Homebrew denied.')
    output = work / 'native program'
    command(compiler, 'build', program, '-o', output)
    assert command(output).stdout == '2\n'
    if system == 'darwin':
        assert 'LLVM' not in command('/usr/bin/otool', '-L', output).stdout
    else:
        assert 'LLVM' not in command('/usr/bin/ldd', output).stdout
    metadata = installed / 'lib/faz/llvm/platform.txt'
    expected = metadata.read_text()
    metadata.write_text('wrong-platform\n')
    assert 'platform does not match' in command(compiler, 'run', program, ok=False).stderr
    assert 'different platform' in command(compiler, 'install', work / 'wrong-install', ok=False).stderr
    metadata.write_text(expected)
    linker = installed / 'lib/faz/llvm/bin' / ('ld64.lld' if system == 'darwin' else 'ld.lld')
    linker.rename(linker.with_suffix('.hidden'))
    assert 'bundled linker missing' in command(compiler, 'run', program, ok=False).stderr
    linker.with_suffix('.hidden').rename(linker)
    bundled = installed / 'lib/faz/llvm/lib' / ('libLLVM.dylib' if system == 'darwin' else 'libLLVM.so')
    bundled.rename(bundled.with_suffix('.hidden'))
    assert 'bundled LLVM library missing' in command(compiler, 'run', program, ok=False).stderr
    command(compiler, 'check', program)
    command(compiler, 'emit-llvm', program, '-o', work / 'hello.ll')
print('Distribution checks passed: checksums, dependency closure, relocation, install,')
print('no Clang/PATH/host LLVM, native execution, wrong platform and missing backend.')
print('Bundled LLD and link inputs used; no host linker or SDK discovery.')
