# elf-weakref-comm

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang -c elf-weakref-comm.s    # assertion in MCSymbol::getOffset
```
