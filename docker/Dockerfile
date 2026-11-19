# ---------------------------------------------------------------------------
# Clang/LLVM trunk at a fixed commit, LLVM_ENABLE_ASSERTIONS=ON.
# Same revision as tools/build-clang-assert-trunk.sh (REV c0005dfe81fe).
# ---------------------------------------------------------------------------
FROM ubuntu:24.04 AS clang-src
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git build-essential cmake ninja-build python3 zlib1g-dev libzstd-dev && rm -rf /var/lib/apt/lists/*
ARG LLVM_COMMIT=c0005dfe81fedaf852727b81a07d728f94ecfa2d
RUN git init /src/llvm-project && cd /src/llvm-project && git fetch --depth=1 https://github.com/llvm/llvm-project.git ${LLVM_COMMIT} && git checkout FETCH_HEAD

FROM clang-src AS clang-build
RUN cmake -G Ninja -S /src/llvm-project/llvm -B /build \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_ASSERTIONS=ON \
      -DLLVM_APPEND_VC_REV=OFF \
      -DLLVM_ENABLE_PROJECTS="clang;lld" \
      -DCLANG_ENABLE_CIR=OFF \
      -DLLVM_TARGETS_TO_BUILD="X86;AArch64;ARM;RISCV;PowerPC;Mips;SystemZ;WebAssembly;BPF" \
      -DLLVM_PARALLEL_LINK_JOBS=8 \
      -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DCMAKE_INSTALL_PREFIX=/opt/llvm
RUN ninja -C /build clang lld llvm-objdump llvm-readelf llvm-mc
RUN ninja -C /build install-clang install-lld install-llvm-objdump install-llvm-readelf install-llvm-mc

# ---------------------------------------------------------------------------
# GCC trunk at a fixed commit, C only, all-gcc only (cc1 + driver; no libgcc/libc): use -S.
# ---------------------------------------------------------------------------
FROM debian:bookworm AS gcc-src
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git build-essential flex bison libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev && rm -rf /var/lib/apt/lists/*
ARG GCC_COMMIT=4182b22649d4682c9452d8cd408f41fc1245989c
RUN git init /src/gcc && cd /src/gcc && git fetch --depth=1 https://gcc.gnu.org/git/gcc.git ${GCC_COMMIT} && git checkout FETCH_HEAD

FROM gcc-src AS gcc-build
RUN set -e; for t in mips-linux-gnu s390x-linux-gnu; do \
      mkdir /build-$t && cd /build-$t && \
      /src/gcc/configure --target=$t --prefix=/opt/cross --enable-languages=c --without-headers --disable-bootstrap --disable-multilib --disable-nls --disable-werror && \
      make -j"$(nproc)" all-gcc && make install-gcc && \
      cd / && rm -rf /build-$t; \
    done

# ---------------------------------------------------------------------------
# binutils-gdb at a fixed commit: gas (as) only, <triple>-as for every target below in one prefix.
# ---------------------------------------------------------------------------
FROM debian:bookworm AS binutils-build
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git build-essential flex bison texinfo zlib1g-dev && rm -rf /var/lib/apt/lists/*
ARG BINUTILS_COMMIT=155b473af41b1556d285aa2e8326e0f13919d8e7
RUN git init /src/binutils && cd /src/binutils && git fetch --depth=1 https://sourceware.org/git/binutils-gdb.git ${BINUTILS_COMMIT} && git checkout FETCH_HEAD && git rev-parse HEAD > /binutils-commit.txt
RUN set -e; for t in x86_64-linux-gnu aarch64-linux-gnu arm-linux-gnueabihf riscv64-linux-gnu riscv32-unknown-elf bpf-unknown-none powerpc64le-linux-gnu mips-linux-gnu s390x-linux-gnu; do \
      mkdir /build-$t && cd /build-$t && \
      /src/binutils/configure --target=$t --prefix=/opt/binutils --disable-nls --disable-werror --disable-gdb --disable-gdbserver --disable-sim --disable-gprofng && \
      make -j"$(nproc)" all-gas && make install-gas && \
      cd / && rm -rf /build-$t; \
    done
RUN cp /binutils-commit.txt /opt/binutils/COMMIT

# ---------------------------------------------------------------------------
# Final image. Ubuntu 24.04 because the clang build needs its glibc/libstdc++.
# qemu-user: distro version (not necessarily latest).
# ---------------------------------------------------------------------------
FROM ubuntu:24.04 AS all
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates binutils libc6-dev libstdc++-13-dev libgmp10 libmpfr6 libmpc3 zlib1g qemu-user && rm -rf /var/lib/apt/lists/*
COPY --from=clang-build /opt/llvm /opt/llvm
COPY --from=gcc-build /opt/cross /opt/cross
COPY --from=binutils-build /opt/binutils /opt/binutils
ENV PATH="/opt/llvm/bin:/opt/cross/bin:/opt/binutils/bin:${PATH}"
WORKDIR /work
