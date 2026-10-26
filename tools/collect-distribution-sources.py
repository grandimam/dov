#!/usr/bin/env python3
"""Retain exact Debian/Ubuntu corresponding sources beside release binaries.

Run in the clean release builder with authenticated deb-src indexes enabled.
Fail rather than substitute a different source version or omit a component.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--distribution', type=Path, required=True)
parser.add_argument('--faz-source', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
manifest = json.loads((args.distribution / 'manifest.json').read_text())
if args.output.exists():
    raise SystemExit('Source output must not already exist')
args.output.mkdir(parents=True)
shutil.copy2(args.faz_source, args.output / 'faz-source.tar')
shutil.copy2(args.distribution / 'manifest.json', args.output / 'binary-manifest.json')
shutil.copytree(args.distribution / 'lib/faz/llvm/notices', args.output / 'notices')
records = {}
for package, version in sorted(manifest['source_packages'].items()):
    if not re.fullmatch(r'[a-z0-9][a-z0-9+.-]*', package):
        raise RuntimeError('Invalid source package name')
    directory = args.output / package
    directory.mkdir()
    subprocess.run(['apt-get', 'source', '--download-only', '--only-source',
                    package + '=' + version], cwd=directory, check=True)
    descriptors = list(directory.glob('*.dsc'))
    if len(descriptors) != 1:
        raise RuntimeError(f'Expected one source descriptor for {package}')
    text = descriptors[0].read_text()
    for key, expected in [('Source', package), ('Version', version)]:
        match = re.search(r'^' + key + r': (.+)$', text, re.M)
        if not match or match.group(1).strip() != expected:
            raise RuntimeError(f'Source provenance mismatch: {package} {key}')
    checksums = re.search(r'^Checksums-Sha256:\n((?: .+\n)+)', text, re.M)
    if not checksums:
        raise RuntimeError(f'No SHA-256 source checksums: {package}')
    for row in checksums.group(1).splitlines():
        digest, size, filename = row.split()
        if Path(filename).name != filename:
            raise RuntimeError('Invalid source archive filename')
        archive = directory / filename
        if archive.stat().st_size != int(size) or hashlib.sha256(archive.read_bytes()).hexdigest() != digest:
            raise RuntimeError(f'Source checksum mismatch: {archive}')
    records[package] = {'version': version, 'descriptor': str(descriptors[0].relative_to(args.output))}
(args.output / 'sources.json').write_text(json.dumps(records, indent=2) + '\n')
(args.output / 'REBUILD.md').write_text('''# Corresponding sources and relinking

This archive accompanies the matching Faz Linux binary archive. `sources.json`
records every redistributed Debian/Ubuntu component's exact source version;
each directory contains its .dsc, upstream source archives and Debian patches/
build rules, verified against the .dsc SHA-256 fields. `notices/` retains the
component licenses, including LGPL/GPL and GCC Runtime Library Exception texts.
`binary-manifest.json` records component provenance and installed-file hashes.

Extract a component with `dpkg-source -x package/file.dsc`. On Ubuntu 24.04,
install its build dependencies (`apt-get build-dep package=version` with matching
deb-src indexes enabled), then use its included Debian build rules, normally
`dpkg-buildpackage -b -uc -us`. The original distribution compiler/build flags
are in those source packages' debian/ directories. No upstream source changes
were made to the copied libraries; Faz staging changes ELF library RPATH to
$ORIGIN (or $ORIGIN/../lib for LLD) using patchelf. Those exact staging commands
are in tools/stage-distribution.py in faz-source.tar.

Faz's complete source, checked-in LLVM seeds, bridge source/generated IR and
build/install scripts are in faz-source.tar. Extract it and follow
docs/native-toolchain.md; tools/build-linux-release.sh records the release build.
The compiler is MIT licensed. Source and LLVM IR are provided so it can be
rebuilt/relinked with modified runtime libraries and startup objects.

Bundled shared libraries and link inputs are ordinary replaceable files under
lib/faz/llvm/lib and lib/faz/llvm/link. Rebuild a compatible library, replace its
corresponding files in an extracted distribution, then use bin/faz directly.
Use FAZ_LLVM_LIBRARY for an alternative compatible LLVM library. To relink Faz
itself with modified startup objects/libc, replace the link inputs and run
bin/faz build src/compiler/main.fz --legacy-language -o faz-relinked from the
Faz source checkout. Keep the rebuilt compiler beside the same backend layout
when installing it. No signature verification or installer lock prevents local
modification; the optional installer checksums protect downloaded originals.
There is no restriction on reverse engineering to debug library modifications.

Publish this source archive alongside the binaries, without a charge or login
requirement beyond the binary download's terms, and retain it for as long as
the binary release is offered. This describes the supplied materials; component
license texts remain authoritative.
''')
hashes = {str(path.relative_to(args.output)): hashlib.sha256(path.read_bytes()).hexdigest()
          for path in sorted(args.output.rglob('*')) if path.is_file()}
(args.output / 'SHA256SUMS').write_text(''.join(value + '  ' + key + '\n' for key, value in hashes.items()))
print(f'Retained and verified {len(records)} matching source packages')
