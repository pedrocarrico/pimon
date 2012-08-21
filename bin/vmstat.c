#include <stdio.h>
#include <stdlib.h>
#include "random.h"

int main (int argc, char *argv[])
{
    int cpu_idle = generate_random();
    
    printf("procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----\n r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa\n 1  0  10976  50992   4900 113188    1    2   109   244  101  183 11 10 77  1\n 0  0  10976  50992   4900 113188    0    0     0     0 8366  315 10  5 %d  0\n", cpu_idle);
    
    exit (0);
}
