[fuzzer-found] [BPF] "invalid fixup kind!" for an immediate defined later with `.set`

The BPF assembler crashes ("invalid fixup kind!") when an instruction's immediate is defined later with `.set`.
For example, the following `.s` file causes a crash.

```asm
r0 = N
.set N, 10
```

```console
$ clang --target=bpf -c bpf-imm-forward-set.s
```

### Actual behavior

Trunk (c0005dfe81fe) with assertions:

```console
$ clang --version
clang version 24.0.0git
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /opt/llvm/bin
Build config: +assertions
$ clang --target=bpf -c bpf-imm-forward-set.s
invalid fixup kind!
UNREACHABLE executed at /src/llvm-project/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp:44!
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=bpf -c bpf-imm-forward-set.s
...
```

The full output is at the end.

### Expected behavior

No crash. With `.set N, 10` first, it assembles.

clang (assertions trunk, with `-x assembler`): https://godbolt.org/z/K7hhWMbMM

### Additional information

- The same code in C inline assembly crashes the same way.
- Related: #235269 (`ld_imm64` with `sym + const`).

Found by fuzzing.

<details><summary>Full output</summary>

```console
$ clang --target=bpf -c bpf-imm-forward-set.s
invalid fixup kind!
UNREACHABLE executed at /src/llvm-project/llvm/lib/Target/BPF/MCTargetDesc/BPFELFObjectWriter.cpp:44!
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=bpf -c bpf-imm-forward-set.s
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x000055ac0ff02d11 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 65
1  clang     0x000055ac0feff59c llvm::sys::RunSignalHandlers() + 76
2  clang     0x000055ac0ff0007d llvm::sys::CleanupOnSignal(unsigned long) + 221
3  clang     0x000055ac0fe32df8
4  libc.so.6 0x00007f6931705330
5  libc.so.6 0x00007f693175ebec pthread_kill + 284
6  libc.so.6 0x00007f693170527e gsignal + 30
7  libc.so.6 0x00007f69316e88ff abort + 223
8  clang     0x000055ac0fe3fe8e
9  clang     0x000055ac0ed4d796
10 clang     0x000055ac0fc13fc5 llvm::ELFObjectWriter::recordRelocation(llvm::MCFragment const&, llvm::MCFixup const&, llvm::MCValue, unsigned long&) + 1205
11 clang     0x000055ac0fb469c9 llvm::MCAsmBackend::maybeAddReloc(llvm::MCFragment const&, llvm::MCFixup const&, llvm::MCValue const&, unsigned long&, bool) + 57
12 clang     0x000055ac0ed4a5ca
13 clang     0x000055ac0fb5902e
14 clang     0x000055ac0fb600e2 llvm::MCAssembler::layout() + 1426
15 clang     0x000055ac0fb609cd llvm::MCAssembler::Finish() + 13
16 clang     0x000055ac0fc43949
17 clang     0x000055ac0d7ae771
18 clang     0x000055ac0d7b0a79 cc1as_main(llvm::ArrayRef<char const*>, char const*, void*) + 4713
19 clang     0x000055ac0d79b98f
20 clang     0x000055ac0d79ba66
21 clang     0x000055ac10a88ccd
22 clang     0x000055ac0fe331fe llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 158
23 clang     0x000055ac10a89beb
24 clang     0x000055ac10a45177 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
25 clang     0x000055ac10a4878c clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 604
26 clang     0x000055ac10a5a7d4 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
27 clang     0x000055ac0d7a0f87 clang_main(int, char**, llvm::ToolContext const&) + 7399
28 clang     0x000055ac0d737949 main + 121
29 libc.so.6 0x00007f69316ea1ca
30 libc.so.6 0x00007f69316ea28b __libc_start_main + 139
31 clang     0x000055ac0d79ad05 _start + 37
clang: error: clang integrated assembler command failed due to signal (use -v to see invocation)
clang version 24.0.0git
Target: bpf
Thread model: posix
InstalledDir: /opt/llvm/bin
Build config: +assertions
clang: note: diagnostic msg: Error generating preprocessed source(s) - no preprocessable inputs.
Aborted (core dumped)
```

</details>
