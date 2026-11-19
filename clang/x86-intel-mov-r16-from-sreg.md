# x86-intel-mov-r16-from-sreg

Run in: `docker run -it --rm --user $(id -u):$(id -g) -v "$PWD":/work -v ~/pav/work/llvm-x86-assert-c0005dfe81fe:/opt/a:ro iastudy-mips:clang23.1.3 bash`

```sh
/opt/a/bin/clang -c x86-intel-mov-r16-from-sreg.s && objdump -d -M intel x86-intel-mov-r16-from-sreg.o
```
