#!/usr/bin/env python3
"""Maintainer tool: stage a relocatable native Faz + LLVM distribution.

Requires Python and platform development tools; installed users need neither
Python nor a separate LLVM installation. Never copies a proprietary SDK.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import subprocess


def run(*args):
    return subprocess.check_output([str(a) for a in args], text=True).strip()


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--compiler', required=True, type=Path)
parser.add_argument('--llvm-home', required=True, type=Path)
parser.add_argument('--lld-home', type=Path, help='LLD prefix (defaults to LLVM prefix)')
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
system = platform.system().lower()
arch = {'arm64': 'aarch64', 'x86_64': 'x86_64', 'aarch64': 'aarch64'}.get(platform.machine())
if system not in ('darwin', 'linux') or not arch:
    raise SystemExit('Supported packaging hosts: macOS or glibc Linux, arm64/x86_64')
version = run(args.llvm_home / 'bin/llvm-config', '--version')
if not 18 <= int(version.split('.')[0]) <= 22:
    raise SystemExit('LLVM 18 through 22 required')
if args.output.exists():
    raise SystemExit('Output must not exist; staging never replaces an installation')
out = args.output.resolve()
lib = out / 'lib/faz/llvm/lib'
notices = out / 'lib/faz/llvm/notices'
lib.mkdir(parents=True)
notices.mkdir()
link = out / 'lib/faz/llvm/link'
link.mkdir()
bin_dir = out / 'lib/faz/llvm/bin'
bin_dir.mkdir()
(out / 'bin').mkdir()
shutil.copy2(args.compiler, out / 'bin/faz')
shutil.copy2(root / 'LICENSE', out / 'LICENSE')
shutil.copy2(root / 'LICENSE', notices / 'FAZ-LICENSE')
shutil.copy2(root / 'docs/native-toolchain.md', out / 'TOOLCHAIN.md')
name = 'libLLVM.dylib' if system == 'darwin' else 'libLLVM.so'
copied = {}
licenses = set()


def license_for(source):
    if system == 'darwin':
        # Homebrew formulae keep upstream license files beside lib/.
        prefix = source.resolve().parent.parent
        key = prefix.parent.name + '-' + prefix.name
        if prefix in licenses:
            return
        files = [p for p in prefix.iterdir()
                 if p.is_file() and re.match(r'^(LICENSE|COPYING|NOTICE)', p.name, re.I)]
        if not files:
            raise RuntimeError(f'No redistribution notices found for {source}')
        for p in files:
            shutil.copy2(p, notices / (key + '-' + p.name))
        licenses.add(prefix)
    else:
        # Debian copyright files include the package's component attribution.
        candidates = [source, source.resolve()]
        if str(source).startswith('/usr/lib/'):
            candidates.append(Path(str(source)[4:]))  # merged-/usr package database
        owners = ''
        for candidate in candidates:
            result = subprocess.run(['dpkg-query', '-S', str(candidate)], text=True,
                                    stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
            if result.returncode == 0:
                owners = result.stdout.splitlines()[0].rsplit(': ', 1)[0]
                break
        if not owners:
            raise RuntimeError(f'Cannot identify package license for {source}')
        package = owners.split(':')[0]
        if package in licenses:
            return
        copyright = Path('/usr/share/doc') / package / 'copyright'
        if not copyright.is_file():
            raise RuntimeError(f'Missing copyright file: {copyright}')
        shutil.copy2(copyright, notices / (package + '-copyright'))
        licenses.add(package)


def dependencies(source):
    if system == 'darwin':
        return [line.strip().split(' (')[0] for line in run('/usr/bin/otool', '-L', source).splitlines()[1:]]
    lines = run('ldd', source).splitlines()
    if any('not found' in line for line in lines):
        raise RuntimeError(f'Unresolved dependencies: {source}\n' + '\n'.join(lines))
    return [line.strip().split(' => ')[1].split(' (')[0]
            for line in lines if ' => /' in line]


def is_system(path):
    if system == 'darwin':
        return path.startswith(('/usr/lib/', '/System/Library/'))
    # The host glibc ABI is a prerequisite; never redistribute its loader here.
    return bool(re.fullmatch(r'lib(c|m|dl|pthread|rt|resolv|util)\.so\.\d+', Path(path).name))


def copy_library(source, destination_name=None, executable=False):
    source = Path(source)
    resolved = source.resolve()
    destination_name = destination_name or source.name
    destination = (bin_dir if executable else lib) / destination_name
    if destination_name in copied:
        if copied[destination_name] != resolved:
            raise RuntimeError(f'Conflicting library basename: {destination_name}')
        return
    copied[destination_name] = resolved
    shutil.copy2(resolved, destination)
    license_for(source)
    for dependency in dependencies(source):
        if is_system(dependency):
            continue
        original = dependency
        if dependency.startswith('@loader_path/'):
            dependency = str(source.parent / dependency[len('@loader_path/'):])
        elif dependency.startswith('@rpath/'):
            tail = dependency[len('@rpath/'):]
            candidates = [source.parent / tail, source.parent.parent / 'lib' / tail,
                          args.llvm_home / 'lib' / tail]
            dependency = str(next((p for p in candidates if p.is_file()), Path('/unresolved') / tail))
        if Path(dependency).resolve() == resolved:
            continue
        if not dependency.startswith('/') or not Path(dependency).is_file():
            raise RuntimeError(f'Unresolved library reference {original} in {source}')
        copy_library(Path(dependency))
        if system == 'darwin':
            relative = '@loader_path/' + ('../lib/' if executable else '') + Path(dependency).name
            subprocess.run(['/usr/bin/install_name_tool', '-change', original,
                            relative, str(destination)], check=True)
    if system == 'darwin':
        if not executable:
            subprocess.run(['/usr/bin/install_name_tool', '-id', '@loader_path/' + destination_name,
                            str(destination)], check=True)
        subprocess.run(['/usr/bin/codesign', '--force', '--sign', '-', str(destination)], check=True)
    else:
        subprocess.run(['patchelf', '--set-rpath', '$ORIGIN/../lib' if executable else '$ORIGIN', str(destination)], check=True)


copy_library(args.llvm_home / 'lib' / name, name)
lld_home = args.lld_home or args.llvm_home
linker_name = 'ld64.lld' if system == 'darwin' else 'ld.lld'
copy_library(lld_home / 'bin' / linker_name, linker_name, executable=True)
if system == 'darwin':
    # Original manifest derived solely from Faz's declarations, not an Apple SDK.
    # Check every public name against the host system library before packaging.
    import ctypes
    ir = (root / 'bootstrap/seed-darwin.ll').read_text()
    symbols = set(re.findall(r'^declare .*?@([A-Za-z_][A-Za-z_0-9.$]*)\(', ir, re.M))
    symbols = {symbol for symbol in symbols if not symbol.startswith('llvm.')}
    symbols.update(['memcpy', 'memmove', 'memset', 'bzero', '__stack_chk_fail', '__stack_chk_guard'])
    system_library = ctypes.CDLL('/usr/lib/libSystem.B.dylib')
    for symbol in symbols:
        if not hasattr(system_library, symbol):
            raise RuntimeError(f'Missing system export for Faz: {symbol}')
    exports = ['_' + symbol for symbol in sorted(symbols)] + ['dyld_stub_binder']
    (link / 'libSystem.tbd').write_text(
        '--- !tapi-tbd\ntbd-version: 4\ntargets: [ arm64-macos, x86_64-macos ]\n'
        'install-name: /usr/lib/libSystem.B.dylib\nexports:\n'
        '  - targets: [ arm64-macos, x86_64-macos ]\n'
        '    symbols: [ ' + ', '.join(exports) + ' ]\n...\n')
else:
    triple = 'x86_64-linux-gnu' if arch == 'x86_64' else 'aarch64-linux-gnu'
    for filename in ['Scrt1.o', 'crti.o', 'crtn.o', 'libc.so.6', 'libm.so.6', 'libdl.so.2']:
        candidates = [Path(prefix) / triple / filename for prefix in ['/usr/lib', '/lib']]
        original = next((path for path in candidates if path.is_file()), None)
        if original is None:
            raise RuntimeError(f'Missing glibc link input: {filename}')
        shutil.copy2(original.resolve(), link / filename)
        license_for(original)

if system == 'linux':
    for file in Path('/usr/share/common-licenses').iterdir():
        if file.is_file():
            shutil.copy2(file, notices / ('debian-common-' + file.name))
(out / 'lib/faz/llvm/platform.txt').write_text(system + '-' + arch + '\n')
(notices / 'FAZ-BUNDLING.txt').write_text(
    'Faz bundles LLVM ' + version + ' and the libraries listed in manifest.json.\n'
    'Library load paths were modified for relocation; macOS copies are ad-hoc signed.\n'
    'Upstream copyright and license notices accompany each bundled component.\n'
    'No Apple SDK is included. Linux glibc copies are link inputs only; executables use host glibc.\n')
manifest = {'platform': system + '-' + arch, 'llvm_version': version, 'build_os': platform.platform(), 'lld_version': run(lld_home / 'bin' / linker_name, '--version'),
            'libraries': {name: str(path) for name, path in sorted(copied.items())},
            'sha256': {str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest()
                       for p in sorted(out.rglob('*')) if p.is_file()}}
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(out)
