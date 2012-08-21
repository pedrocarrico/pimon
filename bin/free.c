#include <stdio.h>
#include <stdlib.h>

int main (int argc, char *argv[])
{
    int mem_used = generate_random();
    int swap_used = generate_random();
    
    printf("             total       used       free     shared    buffers     cached\nMem:           215        %d         %d          0          4        110\nSwap:          100        %d         %d\n", mem_used, 215 - mem_used, swap_used, 100 - swap_used);
    
    exit (0);
}
