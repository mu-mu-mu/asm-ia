# x86-nosse-xmm0

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang -mno-sse -c x86-nosse-xmm0.c    # assertion in X86 FP Stackifier
```
