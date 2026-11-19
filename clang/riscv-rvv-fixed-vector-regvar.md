# riscv-rvv-fixed-vector-regvar

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang --target=riscv64 -march=rv64gcv -c riscv-rvv-fixed-vector-regvar.c    # assertion in RISC-V ISel
```
