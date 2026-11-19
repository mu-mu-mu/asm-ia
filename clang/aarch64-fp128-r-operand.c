long double f(long double v)
{
    __asm__ volatile("" : "+r"(v));
    return v;
}
