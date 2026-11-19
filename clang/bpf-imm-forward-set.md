# bpf-imm-forward-set

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang --target=bpf -c bpf-imm-forward-set.s    # "invalid fixup kind!"
```
