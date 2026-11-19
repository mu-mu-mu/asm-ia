int f(int v)
{
    register int x __asm__("xmm0") = v;
    __asm__ volatile("" : "+r"(x));
    return x;
}
