[fuzzer-found] [RISCV] Crash with a fixed-length vector register variable in a vector register

On RISC-V with V, a 32-byte GNU vector register variable in `v2` and used as a
`"+vr"` operand crashes clang with assertions (in instruction selection,
"Request for a fixed element count on a scalable object").

### Reproducer

```c
typedef int V32 __attribute__((vector_size(32)));

V32 f(V32 v)
{
    register V32 x __asm__("v2") = v;
    __asm__ volatile("" : "+vr"(x));
    return x;
}
```

```console
$ clang --target=riscv64 -march=rv64gcv -c riscv-rvv-fixed-vector-regvar.c
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
$ clang --target=riscv64 -march=rv64gcv -c riscv-rvv-fixed-vector-regvar.c
clang: /src/llvm-project/llvm/include/llvm/Support/TypeSize.h:202: constexpr llvm::details::FixedOrScalableQuantity<LeafTy, ValueTy>::ScalarTy llvm::details::FixedOrScalableQuantity<LeafTy, ValueTy>::getFixedValue() const [with LeafTy = llvm::TypeSize; ValueTy = long unsigned int; ScalarTy = long unsigned int]: Assertion `(!isScalable() || isZero()) && "Request for a fixed element count on a scalable object"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=riscv64 -marchclang --target=riscv64 -march=rv64gcv -c riscv-rvv-fixed-vector-regvar.c=rv64gcv -c riscv-rvv-fixed-vector-regvar.c
1.	<eof> parser at end of file
2.	Code generation
3.	Running pass 'Function Pass Manager' on module 'riscv-rvv-fixed-vector-regvar.c'.
4.	Running pass 'RISC-V DAG->DAG Pattern Instruction Selection' on function '@f'
...
```

The full output is at the end.

### Expected behavior

No crash (or an error if this register variable is not supported).

clang (assertions trunk): https://godbolt.org/z/eTWr3449f

### Crash reproducer files

riscv-rvv-fixed-vector-regvar-6adebb.c

```c
# 1 "<built-in>"
# 1 "riscv-rvv-fixed-vector-regvar.c"
typedef int V32 __attribute__((vector_size(32)));

V32 f(V32 v)
{
    register V32 x __asm__("v2") = v;
    __asm__ volatile("" : "+vr"(x));
    return x;
}
```

riscv-rvv-fixed-vector-regvar-6adebb.sh

```sh
# Crash reproducer for clang version 24.0.0git
# Driver args: "--target=riscv64" "-march=rv64gcv" "-c" "riscv-rvv-fixed-vector-regvar.c"
# Original command:  "/opt/llvm/bin/clang-24" "-cc1" "-triple" "riscv64-unknown-unknown" "-emit-obj" "-disable-free" "-clear-ast-before-backend" "-main-file-name" "riscv-rvv-fixed-vector-regvar.c" "-mrelocation-model" "static" "-mframe-pointer=all" "-fmath-errno" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-nostdsysteminc" "-target-cpu" "generic-rv64" "-target-feature" "+i" "-target-feature" "+m" "-target-feature" "+a" "-target-feature" "+f" "-target-feature" "+d" "-target-feature" "+c" "-target-feature" "+v" "-target-feature" "+zicsr" "-target-feature" "+zifencei" "-target-feature" "+zmmul" "-target-feature" "+zaamo" "-target-feature" "+zalrsc" "-target-feature" "+zca" "-target-feature" "+zcd" "-target-feature" "+zve32f" "-target-feature" "+zve32x" "-target-feature" "+zve64d" "-target-feature" "+zve64f" "-target-feature" "+zve64x" "-target-feature" "+zvl128b" "-target-feature" "+zvl32b" "-target-feature" "+zvl64b" "-target-feature" "-b" "-target-feature" "-e" "-target-feature" "-h" "-target-feature" "-q" "-target-feature" "-sdext" "-target-feature" "-sdtrig" "-target-feature" "-sha" "-target-feature" "-shcounterenw" "-target-feature" "-shgatpa" "-target-feature" "-shlcofideleg" "-target-feature" "-shtvala" "-target-feature" "-shvsatpa" "-target-feature" "-shvstvala" "-target-feature" "-shvstvecd" "-target-feature" "-smaia" "-target-feature" "-smcdeleg" "-target-feature" "-smcntrpmf" "-target-feature" "-smcsrind" "-target-feature" "-smctr" "-target-feature" "-smdbltrp" "-target-feature" "-smepmp" "-target-feature" "-smmpm" "-target-feature" "-smnpm" "-target-feature" "-smpmpdeleg" "-target-feature" "-smrnmi" "-target-feature" "-smstateen" "-target-feature" "-ssaia" "-target-feature" "-ssccfg" "-target-feature" "-ssccptr" "-target-feature" "-sscofpmf" "-target-feature" "-sscounterenw" "-target-feature" "-sscsrind" "-target-feature" "-ssctr" "-target-feature" "-ssdbltrp" "-target-feature" "-ssnpm" "-target-feature" "-sspm" "-target-feature" "-sspmp" "-target-feature" "-sspmpen" "-target-feature" "-ssqosid" "-target-feature" "-ssstateen" "-target-feature" "-ssstrict" "-target-feature" "-sstc" "-target-feature" "-sstvala" "-target-feature" "-sstvecd" "-target-feature" "-ssu64xl" "-target-feature" "-supm" "-target-feature" "-svade" "-target-feature" "-svadu" "-target-feature" "-svbare" "-target-feature" "-svinval" "-target-feature" "-svnapot" "-target-feature" "-svpbmt" "-target-feature" "-svrsw60t59b" "-target-feature" "-svvptc" "-target-feature" "-xaifet" "-target-feature" "-xandesbfhcvt" "-target-feature" "-xandesperf" "-target-feature" "-xandesvbfhcvt" "-target-feature" "-xandesvdot" "-target-feature" "-xandesvpackfph" "-target-feature" "-xandesvsinth" "-target-feature" "-xandesvsintload" "-target-feature" "-xcheriot" "-target-feature" "-xcvalu" "-target-feature" "-xcvbi" "-target-feature" "-xcvbitmanip" "-target-feature" "-xcvelw" "-target-feature" "-xcvmac" "-target-feature" "-xcvmem" "-target-feature" "-xcvsimd" "-target-feature" "-xmipscbop" "-target-feature" "-xmipscmov" "-target-feature" "-xmipsexectl" "-target-feature" "-xmipslsp" "-target-feature" "-xqccmp" "-target-feature" "-xqci" "-target-feature" "-xqcia" "-target-feature" "-xqciac" "-target-feature" "-xqcibi" "-target-feature" "-xqcibm" "-target-feature" "-xqcicli" "-target-feature" "-xqcicm" "-target-feature" "-xqcics" "-target-feature" "-xqcicsr" "-target-feature" "-xqciint" "-target-feature" "-xqciio" "-target-feature" "-xqcilb" "-target-feature" "-xqcili" "-target-feature" "-xqcilia" "-target-feature" "-xqcilo" "-target-feature" "-xqcilsm" "-target-feature" "-xqcisim" "-target-feature" "-xqcisls" "-target-feature" "-xqcisync" "-target-feature" "-xsfcease" "-target-feature" "-xsfmm128t" "-target-feature" "-xsfmm16t" "-target-feature" "-xsfmm32a" "-target-feature" "-xsfmm32a16f" "-target-feature" "-xsfmm32a32f" "-target-feature" "-xsfmm32a8f" "-target-feature" "-xsfmm32a8i" "-target-feature" "-xsfmm32t" "-target-feature" "-xsfmm64a64f" "-target-feature" "-xsfmm64t" "-target-feature" "-xsfmmbase" "-target-feature" "-xsfvcp" "-target-feature" "-xsfvfbfexp16e" "-target-feature" "-xsfvfexp16e" "-target-feature" "-xsfvfexp32e" "-target-feature" "-xsfvfexpa" "-target-feature" "-xsfvfexpa64e" "-target-feature" "-xsfvfnrclipxfqf" "-target-feature" "-xsfvfwmaccqqq" "-target-feature" "-xsfvqmaccdod" "-target-feature" "-xsfvqmaccqoq" "-target-feature" "-xsifivecdiscarddlone" "-target-feature" "-xsifivecflushdlone" "-target-feature" "-xsmtvdot" "-target-feature" "-xsmtvdotii" "-target-feature" "-xtheadba" "-target-feature" "-xtheadbb" "-target-feature" "-xtheadbs" "-target-feature" "-xtheadcmo" "-target-feature" "-xtheadcondmov" "-target-feature" "-xtheadfmemidx" "-target-feature" "-xtheadmac" "-target-feature" "-xtheadmemidx" "-target-feature" "-xtheadmempair" "-target-feature" "-xtheadsync" "-target-feature" "-xtheadvdot" "-target-feature" "-xwchc" "-target-feature" "-za128rs" "-target-feature" "-za64rs" "-target-feature" "-zabha" "-target-feature" "-zacas" "-target-feature" "-zalasr" "-target-feature" "-zama16b" "-target-feature" "-zawrs" "-target-feature" "-zba" "-target-feature" "-zbb" "-target-feature" "-zbc" "-target-feature" "-zbkb" "-target-feature" "-zbkc" "-target-feature" "-zbkx" "-target-feature" "-zbs" "-target-feature" "-zcb" "-target-feature" "-zce" "-target-feature" "-zcf" "-target-feature" "-zclsd" "-target-feature" "-zcmop" "-target-feature" "-zcmp" "-target-feature" "-zcmt" "-target-feature" "-zdinx" "-target-feature" "-zfa" "-target-feature" "-zfbfmin" "-target-feature" "-zfh" "-target-feature" "-zfhmin" "-target-feature" "-zfinx" "-target-feature" "-zhinx" "-target-feature" "-zhinxmin" "-target-feature" "-zic64b" "-target-feature" "-zicbom" "-target-feature" "-zicbop" "-target-feature" "-zicboz" "-target-feature" "-ziccamoa" "-target-feature" "-ziccamoc" "-target-feature" "-ziccid" "-target-feature" "-ziccif" "-target-feature" "-zicclsm" "-target-feature" "-ziccrse" "-target-feature" "-zicfiss" "-target-feature" "-zicntr" "-target-feature" "-zicond" "-target-feature" "-zihintntl" "-target-feature" "-zihintpause" "-target-feature" "-zihpm" "-target-feature" "-zilsd" "-target-feature" "-zimop" "-target-feature" "-zk" "-target-feature" "-zkn" "-target-feature" "-zknd" "-target-feature" "-zkne" "-target-feature" "-zknh" "-target-feature" "-zkr" "-target-feature" "-zks" "-target-feature" "-zksed" "-target-feature" "-zksh" "-target-feature" "-zkt" "-target-feature" "-ztso" "-target-feature" "-zvbb" "-target-feature" "-zvbc" "-target-feature" "-zvfbfmin" "-target-feature" "-zvfbfwma" "-target-feature" "-zvfh" "-target-feature" "-zvfhmin" "-target-feature" "-zvkb" "-target-feature" "-zvkg" "-target-feature" "-zvkn" "-target-feature" "-zvknc" "-target-feature" "-zvkned" "-target-feature" "-zvkng" "-target-feature" "-zvknha" "-target-feature" "-zvknhb" "-target-feature" "-zvks" "-target-feature" "-zvksc" "-target-feature" "-zvksed" "-target-feature" "-zvksg" "-target-feature" "-zvksh" "-target-feature" "-zvkt" "-target-feature" "-zvl1024b" "-target-feature" "-zvl16384b" "-target-feature" "-zvl2048b" "-target-feature" "-zvl256b" "-target-feature" "-zvl32768b" "-target-feature" "-zvl4096b" "-target-feature" "-zvl512b" "-target-feature" "-zvl65536b" "-target-feature" "-zvl8192b" "-target-feature" "-experimental-p" "-target-feature" "-experimental-smcsps" "-target-feature" "-experimental-smehv" "-target-feature" "-experimental-smidctrl" "-target-feature" "-experimental-smijt" "-target-feature" "-experimental-smip" "-target-feature" "-experimental-smnip" "-target-feature" "-experimental-smpmpmt" "-target-feature" "-experimental-sscsps" "-target-feature" "-experimental-ssehv" "-target-feature" "-experimental-ssidctrl" "-target-feature" "-experimental-ssijt" "-target-feature" "-experimental-ssip" "-target-feature" "-experimental-ssnip" "-target-feature" "-experimental-svukte" "-target-feature" "-experimental-xqccmi" "-target-feature" "-experimental-xqccmt" "-target-feature" "-experimental-xsfmclic" "-target-feature" "-experimental-xsfsclic" "-target-feature" "-experimental-y" "-target-feature" "-experimental-zibi" "-target-feature" "-experimental-zicfilp" "-target-feature" "-experimental-zilx" "-target-feature" "-experimental-zvabd" "-target-feature" "-experimental-zvbc32e" "-target-feature" "-experimental-zvdot4a8i" "-target-feature" "-experimental-zvfbdota32f" "-target-feature" "-experimental-zvfbfa" "-target-feature" "-experimental-zvfofp8min" "-target-feature" "-experimental-zvfqwbdota8f" "-target-feature" "-experimental-zvfqwdota8f" "-target-feature" "-experimental-zvfwbdota16bf" "-target-feature" "-experimental-zvfwdota16bf" "-target-feature" "-experimental-zvkgs" "-target-feature" "-experimental-zvqwbdota16i" "-target-feature" "-experimental-zvqwbdota8i" "-target-feature" "-experimental-zvqwdota16i" "-target-feature" "-experimental-zvqwdota8i" "-target-feature" "-experimental-zvvfmm" "-target-feature" "-experimental-zvvmm" "-target-feature" "-experimental-zvvmtls" "-target-feature" "-experimental-zvvmttls" "-target-feature" "-experimental-zvzip" "-target-feature" "-experimental-zyhybrid" "-target-feature" "+relax" "-target-abi" "lp64d" "-debugger-tuning=gdb" "-fdebug-compilation-dir=/work" "-fcoverage-compilation-dir=/work" "-resource-dir" "/opt/llvm/lib/clang/24" "-internal-isystem" "/opt/llvm/lib/clang/24/include" "-internal-isystem" "/opt/llvm/bin/../lib/clang-runtimes/riscv64/include" "-ferror-limit" "19" "-fno-signed-char" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-faddrsig" "-o" "riscv-rvv-fixed-vector-regvar.o" "-x" "c" "riscv-rvv-fixed-vector-regvar.c"
 "/opt/llvm/bin/clang-24" "-cc1" "-triple" "riscv64-unknown-unknown" "-emit-obj" "-disable-free" "-clear-ast-before-backend" "-main-file-name" "riscv-rvv-fixed-vector-regvar.c" "-mrelocation-model" "static" "-mframe-pointer=all" "-fmath-errno" "-ffp-contract=on" "-fno-rounding-math" "-mconstructor-aliases" "-nostdsysteminc" "-target-cpu" "generic-rv64" "-target-feature" "+i" "-target-feature" "+m" "-target-feature" "+a" "-target-feature" "+f" "-target-feature" "+d" "-target-feature" "+c" "-target-feature" "+v" "-target-feature" "+zicsr" "-target-feature" "+zifencei" "-target-feature" "+zmmul" "-target-feature" "+zaamo" "-target-feature" "+zalrsc" "-target-feature" "+zca" "-target-feature" "+zcd" "-target-feature" "+zve32f" "-target-feature" "+zve32x" "-target-feature" "+zve64d" "-target-feature" "+zve64f" "-target-feature" "+zve64x" "-target-feature" "+zvl128b" "-target-feature" "+zvl32b" "-target-feature" "+zvl64b" "-target-feature" "-b" "-target-feature" "-e" "-target-feature" "-h" "-target-feature" "-q" "-target-feature" "-sdext" "-target-feature" "-sdtrig" "-target-feature" "-sha" "-target-feature" "-shcounterenw" "-target-feature" "-shgatpa" "-target-feature" "-shlcofideleg" "-target-feature" "-shtvala" "-target-feature" "-shvsatpa" "-target-feature" "-shvstvala" "-target-feature" "-shvstvecd" "-target-feature" "-smaia" "-target-feature" "-smcdeleg" "-target-feature" "-smcntrpmf" "-target-feature" "-smcsrind" "-target-feature" "-smctr" "-target-feature" "-smdbltrp" "-target-feature" "-smepmp" "-target-feature" "-smmpm" "-target-feature" "-smnpm" "-target-feature" "-smpmpdeleg" "-target-feature" "-smrnmi" "-target-feature" "-smstateen" "-target-feature" "-ssaia" "-target-feature" "-ssccfg" "-target-feature" "-ssccptr" "-target-feature" "-sscofpmf" "-target-feature" "-sscounterenw" "-target-feature" "-sscsrind" "-target-feature" "-ssctr" "-target-feature" "-ssdbltrp" "-target-feature" "-ssnpm" "-target-feature" "-sspm" "-target-feature" "-sspmp" "-target-feature" "-sspmpen" "-target-feature" "-ssqosid" "-target-feature" "-ssstateen" "-target-feature" "-ssstrict" "-target-feature" "-sstc" "-target-feature" "-sstvala" "-target-feature" "-sstvecd" "-target-feature" "-ssu64xl" "-target-feature" "-supm" "-target-feature" "-svade" "-target-feature" "-svadu" "-target-feature" "-svbare" "-target-feature" "-svinval" "-target-feature" "-svnapot" "-target-feature" "-svpbmt" "-target-feature" "-svrsw60t59b" "-target-feature" "-svvptc" "-target-feature" "-xaifet" "-target-feature" "-xandesbfhcvt" "-target-feature" "-xandesperf" "-target-feature" "-xandesvbfhcvt" "-target-feature" "-xandesvdot" "-target-feature" "-xandesvpackfph" "-target-feature" "-xandesvsinth" "-target-feature" "-xandesvsintload" "-target-feature" "-xcheriot" "-target-feature" "-xcvalu" "-target-feature" "-xcvbi" "-target-feature" "-xcvbitmanip" "-target-feature" "-xcvelw" "-target-feature" "-xcvmac" "-target-feature" "-xcvmem" "-target-feature" "-xcvsimd" "-target-feature" "-xmipscbop" "-target-feature" "-xmipscmov" "-target-feature" "-xmipsexectl" "-target-feature" "-xmipslsp" "-target-feature" "-xqccmp" "-target-feature" "-xqci" "-target-feature" "-xqcia" "-target-feature" "-xqciac" "-target-feature" "-xqcibi" "-target-feature" "-xqcibm" "-target-feature" "-xqcicli" "-target-feature" "-xqcicm" "-target-feature" "-xqcics" "-target-feature" "-xqcicsr" "-target-feature" "-xqciint" "-target-feature" "-xqciio" "-target-feature" "-xqcilb" "-target-feature" "-xqcili" "-target-feature" "-xqcilia" "-target-feature" "-xqcilo" "-target-feature" "-xqcilsm" "-target-feature" "-xqcisim" "-target-feature" "-xqcisls" "-target-feature" "-xqcisync" "-target-feature" "-xsfcease" "-target-feature" "-xsfmm128t" "-target-feature" "-xsfmm16t" "-target-feature" "-xsfmm32a" "-target-feature" "-xsfmm32a16f" "-target-feature" "-xsfmm32a32f" "-target-feature" "-xsfmm32a8f" "-target-feature" "-xsfmm32a8i" "-target-feature" "-xsfmm32t" "-target-feature" "-xsfmm64a64f" "-target-feature" "-xsfmm64t" "-target-feature" "-xsfmmbase" "-target-feature" "-xsfvcp" "-target-feature" "-xsfvfbfexp16e" "-target-feature" "-xsfvfexp16e" "-target-feature" "-xsfvfexp32e" "-target-feature" "-xsfvfexpa" "-target-feature" "-xsfvfexpa64e" "-target-feature" "-xsfvfnrclipxfqf" "-target-feature" "-xsfvfwmaccqqq" "-target-feature" "-xsfvqmaccdod" "-target-feature" "-xsfvqmaccqoq" "-target-feature" "-xsifivecdiscarddlone" "-target-feature" "-xsifivecflushdlone" "-target-feature" "-xsmtvdot" "-target-feature" "-xsmtvdotii" "-target-feature" "-xtheadba" "-target-feature" "-xtheadbb" "-target-feature" "-xtheadbs" "-target-feature" "-xtheadcmo" "-target-feature" "-xtheadcondmov" "-target-feature" "-xtheadfmemidx" "-target-feature" "-xtheadmac" "-target-feature" "-xtheadmemidx" "-target-feature" "-xtheadmempair" "-target-feature" "-xtheadsync" "-target-feature" "-xtheadvdot" "-target-feature" "-xwchc" "-target-feature" "-za128rs" "-target-feature" "-za64rs" "-target-feature" "-zabha" "-target-feature" "-zacas" "-target-feature" "-zalasr" "-target-feature" "-zama16b" "-target-feature" "-zawrs" "-target-feature" "-zba" "-target-feature" "-zbb" "-target-feature" "-zbc" "-target-feature" "-zbkb" "-target-feature" "-zbkc" "-target-feature" "-zbkx" "-target-feature" "-zbs" "-target-feature" "-zcb" "-target-feature" "-zce" "-target-feature" "-zcf" "-target-feature" "-zclsd" "-target-feature" "-zcmop" "-target-feature" "-zcmp" "-target-feature" "-zcmt" "-target-feature" "-zdinx" "-target-feature" "-zfa" "-target-feature" "-zfbfmin" "-target-feature" "-zfh" "-target-feature" "-zfhmin" "-target-feature" "-zfinx" "-target-feature" "-zhinx" "-target-feature" "-zhinxmin" "-target-feature" "-zic64b" "-target-feature" "-zicbom" "-target-feature" "-zicbop" "-target-feature" "-zicboz" "-target-feature" "-ziccamoa" "-target-feature" "-ziccamoc" "-target-feature" "-ziccid" "-target-feature" "-ziccif" "-target-feature" "-zicclsm" "-target-feature" "-ziccrse" "-target-feature" "-zicfiss" "-target-feature" "-zicntr" "-target-feature" "-zicond" "-target-feature" "-zihintntl" "-target-feature" "-zihintpause" "-target-feature" "-zihpm" "-target-feature" "-zilsd" "-target-feature" "-zimop" "-target-feature" "-zk" "-target-feature" "-zkn" "-target-feature" "-zknd" "-target-feature" "-zkne" "-target-feature" "-zknh" "-target-feature" "-zkr" "-target-feature" "-zks" "-target-feature" "-zksed" "-target-feature" "-zksh" "-target-feature" "-zkt" "-target-feature" "-ztso" "-target-feature" "-zvbb" "-target-feature" "-zvbc" "-target-feature" "-zvfbfmin" "-target-feature" "-zvfbfwma" "-target-feature" "-zvfh" "-target-feature" "-zvfhmin" "-target-feature" "-zvkb" "-target-feature" "-zvkg" "-target-feature" "-zvkn" "-target-feature" "-zvknc" "-target-feature" "-zvkned" "-target-feature" "-zvkng" "-target-feature" "-zvknha" "-target-feature" "-zvknhb" "-target-feature" "-zvks" "-target-feature" "-zvksc" "-target-feature" "-zvksed" "-target-feature" "-zvksg" "-target-feature" "-zvksh" "-target-feature" "-zvkt" "-target-feature" "-zvl1024b" "-target-feature" "-zvl16384b" "-target-feature" "-zvl2048b" "-target-feature" "-zvl256b" "-target-feature" "-zvl32768b" "-target-feature" "-zvl4096b" "-target-feature" "-zvl512b" "-target-feature" "-zvl65536b" "-target-feature" "-zvl8192b" "-target-feature" "-experimental-p" "-target-feature" "-experimental-smcsps" "-target-feature" "-experimental-smehv" "-target-feature" "-experimental-smidctrl" "-target-feature" "-experimental-smijt" "-target-feature" "-experimental-smip" "-target-feature" "-experimental-smnip" "-target-feature" "-experimental-smpmpmt" "-target-feature" "-experimental-sscsps" "-target-feature" "-experimental-ssehv" "-target-feature" "-experimental-ssidctrl" "-target-feature" "-experimental-ssijt" "-target-feature" "-experimental-ssip" "-target-feature" "-experimental-ssnip" "-target-feature" "-experimental-svukte" "-target-feature" "-experimental-xqccmi" "-target-feature" "-experimental-xqccmt" "-target-feature" "-experimental-xsfmclic" "-target-feature" "-experimental-xsfsclic" "-target-feature" "-experimental-y" "-target-feature" "-experimental-zibi" "-target-feature" "-experimental-zicfilp" "-target-feature" "-experimental-zilx" "-target-feature" "-experimental-zvabd" "-target-feature" "-experimental-zvbc32e" "-target-feature" "-experimental-zvdot4a8i" "-target-feature" "-experimental-zvfbdota32f" "-target-feature" "-experimental-zvfbfa" "-target-feature" "-experimental-zvfofp8min" "-target-feature" "-experimental-zvfqwbdota8f" "-target-feature" "-experimental-zvfqwdota8f" "-target-feature" "-experimental-zvfwbdota16bf" "-target-feature" "-experimental-zvfwdota16bf" "-target-feature" "-experimental-zvkgs" "-target-feature" "-experimental-zvqwbdota16i" "-target-feature" "-experimental-zvqwbdota8i" "-target-feature" "-experimental-zvqwdota16i" "-target-feature" "-experimental-zvqwdota8i" "-target-feature" "-experimental-zvvfmm" "-target-feature" "-experimental-zvvmm" "-target-feature" "-experimental-zvvmtls" "-target-feature" "-experimental-zvvmttls" "-target-feature" "-experimental-zvzip" "-target-feature" "-experimental-zyhybrid" "-target-feature" "+relax" "-target-abi" "lp64d" "-debugger-tuning=gdb" "-fdebug-compilation-dir=/work" "-fcoverage-compilation-dir=/work" "-ferror-limit" "19" "-fno-signed-char" "-fgnuc-version=4.2.1" "-fskip-odr-check-in-gmf" "-faddrsig" "-x" "c" "riscv-rvv-fixed-vector-regvar-6adebb.c"
```

Found by automated testing.

<details><summary>Full output</summary>

```console
$ clang --target=riscv64 -march=rv64gcv -c riscv-rvv-fixed-vector-regvar.c
clang: /src/llvm-project/llvm/include/llvm/Support/TypeSize.h:202: constexpr llvm::details::FixedOrScalableQuantity<LeafTy, ValueTy>::ScalarTy llvm::details::FixedOrScalableQuantity<LeafTy, ValueTy>::getFixedValue() const [with LeafTy = llvm::TypeSize; ValueTy = long unsigned int; ScalarTy = long unsigned int]: Assertion `(!isScalable() || isZero()) && "Request for a fixed element count on a scalable object"' failed.
PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace and dumped files.
Stack dump:
0.	Program arguments: clang --target=riscv64 -march=rv64gcv -c riscv-rvv-fixed-vector-regvar.c
1.	<eof> parser at end of file
2.	Code generation
3.	Running pass 'Function Pass Manager' on module 'riscv-rvv-fixed-vector-regvar.c'.
4.	Running pass 'RISC-V DAG->DAG Pattern Instruction Selection' on function '@f'
Stack dump without symbol names (ensure you have llvm-symbolizer in your PATH or set the environment var `LLVM_SYMBOLIZER_PATH` to point to it):
0  clang     0x00005575c6f23d11 llvm::sys::PrintStackTrace(llvm::raw_ostream&, int) + 65
1  clang     0x00005575c6f2059c llvm::sys::RunSignalHandlers() + 76
2  clang     0x00005575c6f2107d llvm::sys::CleanupOnSignal(unsigned long) + 221
3  clang     0x00005575c6e53df8
4  libc.so.6 0x00007ff5cf4ea330
5  libc.so.6 0x00007ff5cf543bec pthread_kill + 284
6  libc.so.6 0x00007ff5cf4ea27e gsignal + 30
7  libc.so.6 0x00007ff5cf4cd8ff abort + 223
8  libc.so.6 0x00007ff5cf4cd81b
9  libc.so.6 0x00007ff5cf4e0517
10 clang     0x00005575c859a44f
11 clang     0x00005575c85a2754
12 clang     0x00005575c85a8a88 llvm::RegsForValue::getCopyToRegs(llvm::SDValue, llvm::SelectionDAG&, llvm::SDLoc const&, llvm::SDValue&, llvm::SDValue*, llvm::Value const*, llvm::ISD::NodeType) const + 472
13 clang     0x00005575c85bf651
14 clang     0x00005575c85d36cb llvm::SelectionDAGBuilder::visitInlineAsm(llvm::CallBase const&, llvm::BasicBlock const*) + 7371
15 clang     0x00005575c8604c70 llvm::SelectionDAGBuilder::visit(llvm::Instruction const&) + 144
16 clang     0x00005575c86a5eda llvm::SelectionDAGISel::SelectBasicBlock(llvm::ilist_iterator_w_bits<llvm::ilist_detail::node_options<llvm::Instruction, true, false, void, true, llvm::BasicBlock>, false, true>, llvm::ilist_iterator_w_bits<llvm::ilist_detail::node_options<llvm::Instruction, true, false, void, true, llvm::BasicBlock>, false, true>, bool&) + 346
17 clang     0x00005575c86a6d62 llvm::SelectionDAGISel::SelectAllBasicBlocks(llvm::Function const&) + 2706
18 clang     0x00005575c86a8587 llvm::SelectionDAGISel::runOnMachineFunction(llvm::MachineFunction&) + 247
19 clang     0x00005575c868fea7 llvm::SelectionDAGISelLegacy::runOnMachineFunction(llvm::MachineFunction&) + 167
20 clang     0x00005575c621ccbb
21 clang     0x00005575c68ca869 llvm::FPPassManager::runOnFunction(llvm::Function&) + 1785
22 clang     0x00005575c68cac61 llvm::FPPassManager::runOnModule(llvm::Module&) + 49
23 clang     0x00005575c68cb650
24 clang     0x00005575c68cbef4 llvm::legacy::PassManagerImpl::run(llvm::Module&) + 196
25 clang     0x00005575c81e012d
26 clang     0x00005575c81e0395 llvm::runCodeGenPipeline(llvm::TargetMachine&, llvm::Module&, llvm::raw_pwrite_stream&, llvm::raw_pwrite_stream*, llvm::CodeGenFileType, bool, bool, llvm::ModuleSummaryIndex const*, llvm::IntrusiveRefCntPtr<llvm::vfs::FileSystem>) + 533
27 clang     0x00005575c7359d87
28 clang     0x00005575c735a261 clang::emitBackendOutput(clang::CompilerInstance&, clang::CodeGenOptions&, llvm::Module*, clang::BackendAction, llvm::IntrusiveRefCntPtr<llvm::vfs::FileSystem>, std::unique_ptr<llvm::raw_pwrite_stream, std::default_delete<llvm::raw_pwrite_stream>>, clang::BackendConsumer*) + 449
29 clang     0x00005575c7a2ce55 clang::BackendConsumer::HandleTranslationUnit(clang::ASTContext&) + 1861
30 clang     0x00005575c9788c6c clang::ParseAST(clang::Sema&, bool, bool) + 1084
31 clang     0x00005575c7dabcb1 clang::FrontendAction::Execute() + 65
32 clang     0x00005575c7d33378 clang::CompilerInstance::ExecuteAction(clang::FrontendAction&) + 2472
33 clang     0x00005575c7e872d3 clang::ExecuteCompilerInvocation(clang::CompilerInstance*) + 227
34 clang     0x00005575c47c652f cc1_main(llvm::ArrayRef<char const*>, char const*, void*) + 7583
35 clang     0x00005575c47bc887
36 clang     0x00005575c47bca66
37 clang     0x00005575c7aa9ccd
38 clang     0x00005575c6e541fe llvm::CrashRecoveryContext::RunSafely(llvm::function_ref<void ()>) + 158
39 clang     0x00005575c7aaabeb
40 clang     0x00005575c7a66177 clang::driver::Compilation::ExecuteCommand(clang::driver::Command const&, clang::driver::Command const*&, bool) const + 167
41 clang     0x00005575c7a6978c clang::driver::Compilation::ExecuteJobs(clang::driver::JobList const&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&, bool) const + 604
42 clang     0x00005575c7a7b7d4 clang::driver::Driver::ExecuteCompilation(clang::driver::Compilation&, llvm::SmallVectorImpl<std::pair<int, clang::driver::Command const*>>&) + 404
43 clang     0x00005575c47c1f87 clang_main(int, char**, llvm::ToolContext const&) + 7399
44 clang     0x00005575c4758949 main + 121
45 libc.so.6 0x00007ff5cf4cf1ca
46 libc.so.6 0x00007ff5cf4cf28b __libc_start_main + 139
47 clang     0x00005575c47bbd05 _start + 37
clang: error: clang frontend command failed due to signal (use -v to see invocation)
clang version 24.0.0git
Target: riscv64-unknown-unknown
Thread model: posix
InstalledDir: /opt/llvm/bin
Build config: +assertions
clang: note: diagnostic msg: 
********************

PLEASE ATTACH THE FOLLOWING CRASH REPRODUCER FILES TO THE BUG REPORT:
clang: note: diagnostic msg: /work/crash-riscv-rvv-fixed-vector-regvar/riscv-rvv-fixed-vector-regvar-6adebb.c
clang: note: diagnostic msg: /work/crash-riscv-rvv-fixed-vector-regvar/riscv-rvv-fixed-vector-regvar-6adebb.sh
clang: note: diagnostic msg: 

********************
Aborted (core dumped)
```

</details>
