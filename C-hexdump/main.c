#include <stdio.h>
#include <stdlib.h>

int main() {
    int c;
    int mem_i = 0;

    while((c = getchar()) != EOF) {
        if (mem_i % 0x10 == 0x0) {
            printf("\n%08x ", mem_i);
        }
        printf("%02x ", c);
        mem_i++;
    }
    printf("\n");
}
