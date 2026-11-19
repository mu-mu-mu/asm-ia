[fuzzer-found] [WebAssembly] Crash on `.set` alias of an undefined symbol

For WebAssembly, clang crashes when assembly (inline asm or a `.s` file) makes
an alias of an undefined symbol with `.set`. The same input is accepted for ELF
targets.

### Reproducer

```c
__asm__(".set a, b");
```

```console
$ clang --target=wasm32 -c wasm-set-undefined-alias.c
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
$ clang --target=wasm32 -c wasm-set-undefined-alias.c
clang: /src/llvm-project/llvm/lib/MC/WasmObjectWriter.cpp:1745: uint64_t {anonymous}::WasmObjectWriter::writeOneObject(llvm::MCAssembler&, DwoMode): Assertion `S.isDefined()' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=wasm32 -c wasm-set-undefined-alias.c
1.	<eof> parser at end of file
2.	Code generation
...
```

The full output is at the end.

### Expected behavior

No crash.

clang (assertions trunk): https://godbolt.org/z/W6jToaEfT

### Crash reproducer files

wasm-set-undefined-alias-30c971.c

```c
# 1 "<built-in>"
# 1 "wasm-set-undefined-alias.c"
__asm__(".set a, b");
```

wasm-set-undefined-alias-30c971.sh

```sh
# Crash reproducer for clang version 24.0.0git
# Driver args: "--target=wasm32" "-c" "wasm-set-undefined-alias.c"
# Original command:  "/opt/llvm/bin/clang-24" "-cc1" "-triple" "wasm32" "-emit-obj" "-disable-free" "-clear-ast-before-backend" "-main-file-name" "wasm-set-undefined-alias.c" "-mrelocation-model" "static" "-mframe-pointer=none" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-target-cpu" "generic" "-fvisibility=hidden" "-debugger-tuning=gdb" "-fdebug-compilation-dir=/work" "-fcoverage-compilation-dir=/work" "-resource-dir" "/opt/llvm/lib/clang/24" "-internal-isystem" "/opt/llvm/lib/clang/24/include" "-internal-isystem" "/include" "-ferror-limit" "19" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-o" "wasm-set-undefined-alias.o" "-x" "c" "wasm-set-undefined-alias.c"
 "/opt/llvm/bin/clang-24" "-cc1" "-triple" "wasm32" "-emit-obj" "-disable-free" "-clear-ast-before-backend" "-main-file-name" "wasm-set-undefined-alias.c" "-mrelocation-model" "static" "-mframe-pointer=none" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-target-cpu" "generic" "-fvisibility=hidden" "-debugger-tuning=gdb" "-fdebug-compilation-dir=/work" "-fcoverage-compilation-dir=/work" "-ferror-limit" "19" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-x" "c" "wasm-set-undefined-alias-30c971.c"
```

### Additional information

- A `.s` file containing only `.set a, b` crashes the same way.
- An alias of a defined function (`void g(void) {}` with `.set a, g`) works.

Found by fuzzing.

<details><summary>Full output</summary>

```console
$ clang --target=wasm32 -c wasm-set-undefined-alias.c
clang: /src/llvm-project/llvm/lib/MC/WasmObjectWriter.cpp:1745: uint64_t {anonymous}::WasmObjectWriter::writeOneObject(llvm::MCAssembler&, DwoMode): Assertion `S.isDefined()' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=wasm32 -c wasm-set-undefined-alias.c
1.	<eof> parser at end of file
2.	Code generation
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x0000558f6bff1d11 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 65
1  clang     0x0000558f6bfee59c llvm::sys::RunSignalHandlers() + 76
2  clang     0x0000558f6bfef07d llvm::sys::CleanupOnSignal(unsigned long) + 221
3  clang     0x0000558f6bf21df8
4  libc.so.6 0x00007f376833e330
5  libc.so.6 0x00007f3768397bec pthread_kill + 284
6  libc.so.6 0x00007f376833e27e gsignal + 30
7  libc.so.6 0x00007f37683218ff abort + 223
8  libc.so.6 0x00007f376832181b
9  libc.so.6 0x00007f3768334517
10 clang     0x0000558f6bce8003
11 clang     0x0000558f6bce8207
12 clang     0x0000558f6bc4f9e8 llvm::MCAssembler::Finish() + 40
13 clang     0x0000558f6d2f5920 llvm::AsmPrinter::doFinalization(llvm::Module&) + 7184
14 clang     0x0000558f6b98e5eb llvm::FPPassManager::doFinalization(llvm::Module&) + 107
15 clang     0x0000558f6b999b06
16 clang     0x0000558f6b999ef4 llvm::legacy::PassManagerImpl::run(llvm::Module&) + 196
17 clang     0x0000558f6d2ae12d
18 clang     0x0000558f6d2ae395 llvm::runCodeGenPipeline(llvm::TargetMachine&, llvm::Module&, llvm::raw_pwrite_stream&, llvm::raw_pwrite_stream*, llvm::CodeGenFileType, bool, bool, llvm::ModuleSummaryIndex const*, llvm::IntrusiveRefCntPtr<llvm::vfs::FileSystem>) + 533
19 clang     0x0000558f6c427d87
20 clang     0x0000558f6c428261 clang::emitBackendOutput(clang::CompilerInstance&, clang::CodeGenOptions&, llvm::Module*, clang::BackendAction, llvm::IntrusiveRefCntPtr<llvm::vfs::FileSystem>, std::unique_ptr<llvm::raw_pwrite_stream, std::default_delete<llvm::raw_pwrite_stream>>, clang::BackendConsumer*) + 449
21 clang     0x0000558f6cafae55 clang::BackendConsumer::HandleTranslationUnit(clang::ASTContext&) + 1861
22 clang     0x0000558f6e856c6c clang::ParseAST(clang::Sema&, bool, bool) + 1084
23 clang     0x0000558f6ce79cb1 clang::FrontendAction::Execute() + 65
24 clang     0x0000558f6ce01378 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 2472
25 clang     0x0000558f6cf552d3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 227
26 clang     0x0000558f6989452f cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7583
27 clang     0x0000558f6988a887
28 clang     0x0000558f6988aa66
29 clang     0x0000558f6cb77ccd
30 clang     0x0000558f6bf221fe llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 158
31 clang     0x0000558f6cb78beb
32 clang     0x0000558f6cb34177 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
33 clang     0x0000558f6cb3778c clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 604
34 clang     0x0000558f6cb497d4 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
35 clang     0x0000558f6988ff87 clang_main(int, char**, llvm::ToolContext const&) + 7399
36 clang     0x0000558f69826949 main + 121
37 libc.so.6 0x00007f37683231ca
38 libc.so.6 0x00007f376832328b __libc_start_main + 139
39 clang     0x0000558f69889d05 _start + 37
clang: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git
Target: wasm32
Thread model: posix
InstalledDir: /opt/llvm/bin
Build config: +assertions
clang: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang: note: diagnostic msg: /work/crash-wasm-set-undefined-alias/wasm-set-undefined-alias-30c971.c
clang: note: diagnostic msg: /work/crash-wasm-set-undefined-alias/wasm-set-undefined-alias-30c971.sh
clang: note: diagnostic msg: 

********************
Aborted (core dumped)
```

</details>
