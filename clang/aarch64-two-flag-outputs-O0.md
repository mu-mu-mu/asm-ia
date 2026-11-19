# aarch64-two-flag-outputs-O0

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang --target=aarch64-linux-gnu -O0 -c aarch64-two-flag-outputs-O0.c    # "Invalid NZCV copy"
```
