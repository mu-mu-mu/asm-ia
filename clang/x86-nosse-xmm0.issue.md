[fuzzer-found] [X86] Crash in X86 FP Stackifier with an xmm0 register variable and -mno-sse

With `-mno-sse`, clang accepts a local register variable bound to `xmm0`, and
then crashes in the X86 FP Stackifier (assertion "Expected FP register!").

### Reproducer

```c
int f(int v)
{
    register int x __asm__("xmm0") = v;
    __asm__ volatile("" : "+r"(x));
    return x;
}
```

```console
$ clang -mno-sse -c x86-nosse-xmm0.c
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
$ clang -mno-sse -c x86-nosse-xmm0.c
clang: /src/llvm-project/llvm/lib/Target/X86/X86FloatingPoint.cpp:326: unsigned int getFPReg(const llvm::MachineOperand&): Assertion `Reg >= X86::FP0 && Reg <= X86::FP6 && "Expected FP register!"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang -mno-sse -c x86-nosse-xmm0.c
1.	<eof> parser at end of file
2.	Code generation
3.	Running pass 'Function Pass Manager' on module 'x86-nosse-xmm0.c'.
4.	Running pass 'X86 FP Stackifier' on function '@f'
...
```

The full output is at the end.

### Expected behavior

An error, since `xmm0` is not available with `-mno-sse`.

clang (assertions trunk): https://godbolt.org/z/3eP3GTWjW

### Crash reproducer files

x86-nosse-xmm0-b2c596.c

```c
# 1 "<built-in>"
# 1 "x86-nosse-xmm0.c"
int f(int v)
{
    register int x __asm__("xmm0") = v;
    __asm__ volatile("" : "+r"(x));
    return x;
}
```

x86-nosse-xmm0-b2c596.sh

```sh
# Crash reproducer for clang version 24.0.0git
# Driver args: "-mno-sse" "-c" "x86-nosse-xmm0.c"
# Original command:  "/opt/llvm/bin/clang-24" "-cc1" "-triple" "x86_64-unknown-linux-gnu" "-emit-obj" "-disable-free" "-clear-ast-before-backend" "-main-file-name" "x86-nosse-xmm0.c" "-mrelocation-model" "pic" "-pic-level" "2" "-pic-is-pie" "-mframe-pointer=all" "-fmath-errno" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-funwind-tables=2" "-target-cpu" "x86-64" "-target-feature" "-sse" "-tune-cpu" "generic" "-debugger-tuning=gdb" "-fdebug-compilation-dir=/work" "-fcoverage-compilation-dir=/work" "-resource-dir" "/opt/llvm/lib/clang/24" "-internal-isystem" "/opt/llvm/lib/clang/24/include" "-internal-isystem" "/usr/local/include" "-internal-isystem" "/usr/lib/gcc/x86_64-linux-gnu/13/../../../../x86_64-linux-gnu/include" "-internal-externc-isystem" "/usr/include/x86_64-linux-gnu" "-internal-externc-isystem" "/include" "-internal-externc-isystem" "/usr/include" "-ferror-limit" "19" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-faddrsig" "-fdwarf2-cfi-asm" "-o" "x86-nosse-xmm0.o" "-x" "c" "x86-nosse-xmm0.c"
 "/opt/llvm/bin/clang-24" "-cc1" "-triple" "x86_64-unknown-linux-gnu" "-emit-obj" "-disable-free" "-clear-ast-before-backend" "-main-file-name" "x86-nosse-xmm0.c" "-mrelocation-model" "pic" "-pic-level" "2" "-pic-is-pie" "-mframe-pointer=all" "-fmath-errno" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-funwind-tables=2" "-target-cpu" "x86-64" "-target-feature" "-sse" "-tune-cpu" "generic" "-debugger-tuning=gdb" "-fdebug-compilation-dir=/work" "-fcoverage-compilation-dir=/work" "-ferror-limit" "19" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-faddrsig" "-fdwarf2-cfi-asm" "-x" "c" "x86-nosse-xmm0-b2c596.c"
```

Found by automated testing.

<details><summary>Full output</summary>

```console
$ clang -mno-sse -c x86-nosse-xmm0.c
clang: /src/llvm-project/llvm/lib/Target/X86/X86FloatingPoint.cpp:326: unsigned int getFPReg(const llvm::MachineOperand&): Assertion `Reg >= X86::FP0 && Reg <= X86::FP6 && "Expected FP register!"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang -mno-sse -c x86-nosse-xmm0.c
1.	<eof> parser at end of file
2.	Code generation
3.	Running pass 'Function Pass Manager' on module 'x86-nosse-xmm0.c'.
4.	Running pass 'X86 FP Stackifier' on function '@f'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x00005609be457d11 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 65
1  clang     0x00005609be45459c llvm::sys::RunSignalHandlers() + 76
2  clang     0x00005609be45507d llvm::sys::CleanupOnSignal(unsigned long) + 221
3  clang     0x00005609be387df8
4  libc.so.6 0x00007f632c417330
5  libc.so.6 0x00007f632c470bec pthread_kill + 284
6  libc.so.6 0x00007f632c41727e gsignal + 30
7  libc.so.6 0x00007f632c3fa8ff abort + 223
8  libc.so.6 0x00007f632c3fa81b
9  libc.so.6 0x00007f632c40d517
10 clang     0x00005609bbe116e3
11 clang     0x00005609bbe12525
12 clang     0x00005609bbe13bb7
13 clang     0x00005609bbe149d2
14 clang     0x00005609bd750cbb
15 clang     0x00005609bddfe869 llvm::FPPassManager::runOnFunction(llvm::Function&) + 1785
16 clang     0x00005609bddfec61 llvm::FPPassManager::runOnModule(llvm::Module&) + 49
17 clang     0x00005609bddff650
18 clang     0x00005609bddffef4 llvm::legacy::PassManagerImpl::run(llvm::Module&) + 196
19 clang     0x00005609bf71412d
20 clang     0x00005609bf714395 llvm::runCodeGenPipeline(llvm::TargetMachine&, llvm::Module&, llvm::raw_pwrite_stream&, llvm::raw_pwrite_stream*, llvm::CodeGenFileType, bool, bool, llvm::ModuleSummaryIndex const*, llvm::IntrusiveRefCntPtr<llvm::vfs::FileSystem>) + 533
21 clang     0x00005609be88dd87
22 clang     0x00005609be88e261 clang::emitBackendOutput(clang::CompilerInstance&, clang::CodeGenOptions&, llvm::Module*, clang::BackendAction, llvm::IntrusiveRefCntPtr<llvm::vfs::FileSystem>, std::unique_ptr<llvm::raw_pwrite_stream, std::default_delete<llvm::raw_pwrite_stream>>, clang::BackendConsumer*) + 449
23 clang     0x00005609bef60e55 clang::BackendConsumer::HandleTranslationUnit(clang::ASTContext&) + 1861
24 clang     0x00005609c0cbcc6c clang::ParseAST(clang::Sema&, bool, bool) + 1084
25 clang     0x00005609bf2dfcb1 clang::FrontendAction::Execute() + 65
26 clang     0x00005609bf267378 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 2472
27 clang     0x00005609bf3bb2d3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 227
28 clang     0x00005609bbcfa52f cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7583
29 clang     0x00005609bbcf0887
30 clang     0x00005609bbcf0a66
31 clang     0x00005609befddccd
32 clang     0x00005609be3881fe llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 158
33 clang     0x00005609befdebeb
34 clang     0x00005609bef9a177 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
35 clang     0x00005609bef9d78c clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 604
36 clang     0x00005609befaf7d4 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
37 clang     0x00005609bbcf5f87 clang_main(int, char**, llvm::ToolContext const&) + 7399
38 clang     0x00005609bbc8c949 main + 121
39 libc.so.6 0x00007f632c3fc1ca
40 libc.so.6 0x00007f632c3fc28b __libc_start_main + 139
41 clang     0x00005609bbcefd05 _start + 37
clang: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git
Target: x86_64-unknown-linux-gnu
Thread model: posix
InstalledDir: /opt/llvm/bin
Build config: +assertions
clang: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang: note: diagnostic msg: /work/crash-x86-nosse-xmm0/x86-nosse-xmm0-b2c596.c
clang: note: diagnostic msg: /work/crash-x86-nosse-xmm0/x86-nosse-xmm0-b2c596.sh
clang: note: diagnostic msg: 

********************
Aborted (core dumped)
```

</details>
