#!/bin/sh
set -eu
cd "$(dirname "$0")"
HERE=$(pwd)
PAV=${PAV:-$HOME/pav/docker}
GCC_SHORT=4182b22
BINUTILS_SHORT=155b473
CLANG_SHORT=c0005dfe81fe

TAG=iastudy-all:$CLANG_SHORT-$GCC_SHORT-$BINUTILS_SHORT
TAR=iastudy-all-$CLANG_SHORT-$GCC_SHORT-$BINUTILS_SHORT
mkdir -p "$PAV/all"
cp "$HERE/Dockerfile" "$PAV/all/Dockerfile"

echo "== build $TAG (log: $PAV/all/build.log)"
docker build -f "$HERE/Dockerfile" -t "$TAG" "$HERE" > "$PAV/all/build.log" 2>&1 \
  || { echo "FAILED: $TAG (see $PAV/all/build.log)"; exit 1; }

docker run --rm "$TAG" sh -c '
  clang --version | head -1 && ld.lld --version && llvm-objdump --version | head -2
  for t in mips-linux-gnu s390x-linux-gnu; do $t-gcc --version | head -1; printf "int f(int x){return x+1;}\n" | $t-gcc -O2 -S -x c - -o - >/dev/null && echo "$t-gcc -S ok"; done
  ls /opt/binutils/bin/*-as | wc -l && s390x-linux-gnu-as --version | head -1
  qemu-s390x --version | head -1 && qemu-mips --version | head -1
' > "$PAV/all/smoke.txt" 2>&1 \
  || { echo "SMOKE FAILED: $TAG (see $PAV/all/smoke.txt)"; cat "$PAV/all/smoke.txt"; exit 1; }
echo "smoke ok: $TAG"

docker save "$TAG" -o "$PAV/$TAR.tar"
(cd "$PAV" && sha256sum "$TAR.tar" > "$TAR.tar.sha256")
ls -l "$PAV/$TAR.tar"
