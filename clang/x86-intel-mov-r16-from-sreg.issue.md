[fuzzer-found] [X86][AsmParser] Intel syntax: `mov ax, ds` is encoded as `mov eax, ds`, clobbering the upper bits of the destination

In Intel syntax, a `mv` from a segment register to a 16-bit register (`mov ax,
ds`) is silently assembled as the 32-bit form `mov eax, ds` (`8c d8`, without
the `66` prefix). AT&T syntax (`movw %ds, %ax`) is correct (`66 8c d8`).

### Reproducer

```asm
.intel_syntax noprefix
mov ax, ds
```

### Actual behavior

Trunk (c0005dfe81fe) with assertions:

```console
$ clang --version
clang version 24.0.0git
Target: x86_64-unknown-linux-gnu
Thread model: posix
Build config: +assertions
$ clang -c x86-intel-mov-r16-from-sreg.s && objdump -d -M intel x86-intel-mov-r16-from-sreg.o
...
0000000000000000 <.text>:
   0:	8c d8                	mov    eax,ds
```

### Expected behavior

`mov ax, ds` is encoded as `66 8c d8`.

clang (trunk): https://godbolt.org/z/sq6bv6W5K

Found by fuzzing.
