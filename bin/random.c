#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>

int generate_random()
{
    FILE *urandom;
    unsigned int seed;
    int cpu_idle;
    
    urandom = fopen ("/dev/urandom", "r");
    if (urandom == NULL) {
        fprintf (stderr, "ERROR: Cannot open /dev/urandom!\n");
        exit (1);
    }
    fread (&seed, sizeof (seed), 1, urandom);
    srand (seed);
    
    return ((int) floor (rand() * 100.0 / ((double) RAND_MAX + 1) ) + 1);
}
