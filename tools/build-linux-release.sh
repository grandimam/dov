#!/bin/sh
# Run only inside the fresh Ubuntu 24.04 release-builder container.
set -eu
export DEBIAN_FRONTEND=noninteractive
sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
apt-get update
# Base-image libraries may predate the source indexes. Upgrade before staging
# so every copied binary has an available exact source version.
apt-get upgrade -y
apt-get install -y --no-install-recommends ca-certificates git clang-18 llvm-18-dev lld-18 patchelf python3 binutils libc6-dev libgcc-13-dev dpkg-dev xz-utils
mkdir -p /work /out
git -c safe.directory=/source -C /source archive HEAD > /work/faz-source.tar
mkdir /work/repo
tar -xf /work/faz-source.tar -C /work/repo
cd /work/repo
export FAZ_LLVM_HOME=/usr/lib/llvm-18
clang-18 -x ir -O2 -Wno-override-module bootstrap/seed-linux.ll -o faz
./faz build-self
python3 tools/stage-distribution.py --compiler build/faz --llvm-home "$FAZ_LLVM_HOME" --output /work/faz-v0.1.0-linux-x86_64
python3 tools/test-distribution.py /work/faz-v0.1.0-linux-x86_64
python3 tools/collect-distribution-sources.py --distribution /work/faz-v0.1.0-linux-x86_64 --faz-source /work/faz-source.tar --output /work/faz-v0.1.0-linux-x86_64-sources
tar -czf /out/faz-v0.1.0-linux-x86_64.tar.gz -C /work faz-v0.1.0-linux-x86_64
tar -czf /out/faz-v0.1.0-linux-x86_64-sources.tar.gz -C /work faz-v0.1.0-linux-x86_64-sources
cd /out
sha256sum faz-v0.1.0-linux-x86_64*.tar.gz > SHA256SUMS-linux
