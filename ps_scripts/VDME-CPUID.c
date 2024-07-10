#include <stdio.h>
#include <intrin.h>

int main() {
    int cpuInfo[4] = {0, 0, 0, 0};
    __cpuid(cpuInfo, 1);
    if (cpuInfo[2] & (1 << 31)) {
        printf("Hypervisor present\n");
    } else {
        printf("Hypervisor not present\n");
    }
    return 0;
}
