# aarch64-fp128-r-operand

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang --target=aarch64 -O2 -S aarch64-fp128-r-operand.c -o -
```
