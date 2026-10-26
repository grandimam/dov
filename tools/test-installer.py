#!/usr/bin/env python3
"""Test the real pinned installer with a local transport double, never a bypass.
The archive must still pass the installer's production SHA-256 and smoke test.
"""
import argparse
import os
from pathlib import Path
import subprocess
import tempfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('archive', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
archive = args.archive.resolve()
with tempfile.TemporaryDirectory(prefix='faz installer tests ') as temporary:
    work = Path(temporary)
    stubs = work / 'transport'; stubs.mkdir()
    curl = stubs / 'curl'
    curl.write_text('''#!/bin/sh
set -eu
if [ "${FAZ_TEST_DOWNLOAD_FAIL:-}" = 1 ]; then exit 22; fi
output=
while [ "$#" -gt 0 ]; do
  if [ "$1" = --output ]; then output=$2; shift 2; else shift; fi
done
printf 'download\\n' >> "$FAZ_TEST_LOG"
if [ "${FAZ_TEST_BAD_HASH:-}" = 1 ]; then printf corrupt > "$output"
else cp "$FAZ_TEST_ARCHIVE" "$output"; fi
''')
    curl.chmod(0o755)
    env = {k: v for k, v in os.environ.items() if not k.startswith(('FAZ_', 'LD_', 'DYLD_'))}
    env.update(PATH=str(stubs) + ':/usr/bin:/bin', HOME=str(work / 'home'),
               FAZ_TEST_ARCHIVE=str(archive), FAZ_TEST_LOG=str(work / 'downloads'))
    Path(env['HOME']).mkdir()
    profile = Path(env['HOME']) / '.profile'; profile.write_text('leave me alone\n')
    prefix = work / 'prefix with spaces'

    def install(destination, additions=None, succeeds=True):
        result = subprocess.run(['/bin/sh', str(root / 'install.sh'), '--prefix', str(destination)],
                                env={**env, **(additions or {})}, text=True,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=180)
        assert (result.returncode == 0) == succeeds, (result.returncode, result.stdout, result.stderr)
        return result

    install(prefix)
    active = prefix / 'bin/faz'
    target = active.readlink()
    assert subprocess.check_output([active, '--version'], text=True).strip() == 'faz 0.1.0'
    hello = work / 'hello.fz'; hello.write_text('fn main():\n    print("installer works")\n')
    assert subprocess.check_output([active, 'run', hello], env=env, text=True) == 'installer works\n'
    subprocess.run([active, 'build', hello, '-o', work / 'hello'], env=env, check=True)
    assert subprocess.check_output([work / 'hello'], text=True) == 'installer works\n'
    downloads = (work / 'downloads').read_text()
    install(prefix)
    assert active.readlink() == target and (work / 'downloads').read_text() == downloads
    assert profile.read_text() == 'leave me alone\n'
    assert not (prefix / 'lib/faz/versions/.install-lock').exists()
    unmanaged = work / 'unmanaged'; (unmanaged / 'bin').mkdir(parents=True)
    (unmanaged / 'bin/faz').write_text('preserve existing user file')
    assert 'preserving existing file' in install(unmanaged, succeeds=False).stderr
    assert (unmanaged / 'bin/faz').read_text() == 'preserve existing user file'
    previous = work / 'previous'
    old_binary = previous / 'lib/faz/versions/old/bin/faz'; old_binary.parent.mkdir(parents=True)
    old_binary.write_text('previous version'); (previous / 'bin').mkdir()
    old_link = previous / 'bin/faz'; old_link.symlink_to(old_binary)
    for failure in [{'FAZ_TEST_BAD_HASH': '1'}, {'FAZ_TEST_DOWNLOAD_FAIL': '1'}, {'FAZ_OPT_LEVEL': 'invalid'}]:
        install(previous, failure, succeeds=False)
        assert old_link.readlink() == old_binary and old_binary.read_text() == 'previous version'
        assert not (previous / 'lib/faz/versions/.install-lock').exists()
    # A local modification is preserved, never silently replaced on rerun.
    active.resolve().write_bytes(active.resolve().read_bytes() + b'local modification')
    assert 'installed files were modified' in install(prefix, succeeds=False).stderr
    assert active.readlink() == target
    uname = stubs / 'uname'; uname.write_text('#!/bin/sh\nprintf "unsupported\\n"\n'); uname.chmod(0o755)
    unsupported = work / 'unsupported'
    assert 'supported packages' in install(unsupported, succeeds=False).stderr
    assert not unsupported.exists()
print('Installer passed: pinned hash, first run/build, spaces, idempotence, unmanaged files,')
print('download/hash/smoke failure preservation, modified files, unsupported platform, unchanged profile.')
