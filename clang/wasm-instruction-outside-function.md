# wasm-instruction-outside-function

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work iastudy-all:c0005dfe81fe-4182b22-155b473 bash`

```sh
clang --target=wasm32 -c wasm-instruction-outside-function.s    # assertion in WebAssemblyAsmTypeCheck
```
