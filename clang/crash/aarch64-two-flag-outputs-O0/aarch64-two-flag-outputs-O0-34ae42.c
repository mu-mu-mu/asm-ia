# 1 "<built-in>"
# 1 "aarch64-two-flag-outputs-O0.c"
int f(long a, long b)
{
    int z, c;
    __asm__("cmp %2, %3" : "=@cceq"(z), "=@cccs"(c) : "r"(a), "r"(b));
    return z + c;
}
