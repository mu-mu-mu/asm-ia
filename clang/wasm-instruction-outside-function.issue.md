[fuzzer-found] [WebAssembly] Assembler crashes on an instruction outside a function

The WebAssembly assembler crashes when an instruction appears outside a function.
For example, the following `.s` file causes a crash.

```asm
i32.add
```

```console
$ clang --target=wasm32 -c wasm-instruction-outside-function.s
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
$ clang --target=wasm32 -c wasm-instruction-outside-function.s
clang: /src/llvm-project/llvm/lib/Target/WebAssembly/AsmParser/WebAssemblyAsmTypeCheck.cpp:142: bool llvm::WebAssemblyAsmTypeCheck::checkTypes(llvm::SMLoc, llvm::ArrayRef<std::variant<llvm::wasm::ValType, Ref, Any, Polymorphic> >, bool): Assertion `!BlockInfoStack.empty()' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=wasm32 -c wasm-instruction-outside-function.s
...
```

The full output is at the end.

### Expected behavior

An error instead of a crash.

clang (assertions trunk, with `-x assembler`): https://godbolt.org/z/j5qWPxxz4

Found by fuzzing.

<details><summary>Full output</summary>

```console
$ clang --target=wasm32 -c wasm-instruction-outside-function.s
clang: /src/llvm-project/llvm/lib/Target/WebAssembly/AsmParser/WebAssemblyAsmTypeCheck.cpp:142: bool llvm::WebAssemblyAsmTypeCheck::checkTypes(llvm::SMLoc, llvm::ArrayRef<std::variant<llvm::wasm::ValType, Ref, Any, Polymorphic> >, bool): Assertion `!BlockInfoStack.empty()' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=wasm32 -c wasm-instruction-outside-function.s
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x000055d51c716d11 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 65
1  clang     0x000055d51c71359c llvm::sys::RunSignalHandlers() + 76
2  clang     0x000055d51c71407d llvm::sys::CleanupOnSignal(unsigned long) + 221
3  clang     0x000055d51c646df8
4  libc.so.6 0x00007ff16b875330
5  libc.so.6 0x00007ff16b8cebec pthread_kill + 284
6  libc.so.6 0x00007ff16b87527e gsignal + 30
7  libc.so.6 0x00007ff16b8588ff abort + 223
8  libc.so.6 0x00007ff16b85881b
9  libc.so.6 0x00007ff16b86b517
10 clang     0x000055d51b4c4b66
11 clang     0x000055d51b4c4ddc
12 clang     0x000055d51b4c53ae
13 clang     0x000055d51b4b68c8
14 clang     0x000055d51c4408fe
15 clang     0x000055d51c4588e0
16 clang     0x000055d51c4570ca
17 clang     0x000055d519fc2771
18 clang     0x000055d519fc4a79 cc1as_main(llvm::ArrayRef<char const*>, char const*, void*) + 4713
19 clang     0x000055d519faf98f
20 clang     0x000055d519fafa66
21 clang     0x000055d51d29cccd
22 clang     0x000055d51c6471fe llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 158
23 clang     0x000055d51d29dbeb
24 clang     0x000055d51d259177 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
25 clang     0x000055d51d25c78c clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 604
26 clang     0x000055d51d26e7d4 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
27 clang     0x000055d519fb4f87 clang_main(int, char**, llvm::ToolContext const&) + 7399
28 clang     0x000055d519f4b949 main + 121
29 libc.so.6 0x00007ff16b85a1ca
30 libc.so.6 0x00007ff16b85a28b __libc_start_main + 139
31 clang     0x000055d519faed05 _start + 37
clang: error: clang integrated assembler command failed due to signal (use -v to see invocation)
clang version 24.0.0git
Target: wasm32
Thread model: posix
InstalledDir: /opt/llvm/bin
Build config: +assertions
clang: note: diagnostic msg: Error generating preprocessed source(s) - no preprocessable inputs.
Aborted (core dumped)
```

</details>
