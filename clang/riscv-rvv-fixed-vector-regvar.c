typedef int V32 __attribute__((vector_size(32)));

V32 f(V32 v)
{
    register V32 x __asm__("v2") = v;
    __asm__ volatile("" : "+vr"(x));
    return x;
}
