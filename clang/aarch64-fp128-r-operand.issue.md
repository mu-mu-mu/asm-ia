[fuzzer-found] [AArch64] Inline asm "+r" operand of type long double loses the high 64 bits

On AArch64, a `"+r"` operand of type `long double` (fp128) changes the value at -O2.
Only the low 64 bits are properly handled,
but the high 64 bits come from an uninitialized stack slot.

### Reproducer

```c
long double f(long double v)
{
    __asm__ volatile("" : "+r"(v));
    return v;
}
```

```console
$ clang --target=aarch64 -O2 -S aarch64-fp128-r-operand.c -o -
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
$ clang --target=aarch64 -O2 -S aarch64-fp128-r-operand.c -o -
f:                                      // @f
        .cfi_startproc
// %bb.0:                               // %entry
        sub     sp, sp, #32
        .cfi_def_cfa_offset 32
        str     q0, [sp, #16]
        ldp     w8, w9, [sp, #16]
        //APP
        //NO_APP
        mov     w8, w8
        orr     x8, x8, x9, lsl #32
        str     x8, [sp]
        ldr     q0, [sp], #32
        .cfi_def_cfa_offset 0
        ret
```

`[sp, #8]` is never written before `ldr q0, [sp], #32`, so the high 64 bits of the result are corrupted.

### Expected behavior

All the bits are passed to and from the inline assembly.

clang (trunk): https://godbolt.org/z/Evsnr89hT

### Additional information

#238926 reports the same operand problem for `__int128`. The fix in #239127 seems to cover only integer types.

Found by automated testing.
