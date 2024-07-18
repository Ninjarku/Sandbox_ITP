#include <stdio.h>
#include <intrin.h>
#include <windows.h>

int main() {
    unsigned __int64 start, end;
    start = __rdtsc();
    // Code block to measure
    Sleep(100);  // Sleep for 100 milliseconds
    end = __rdtsc();
    printf("Execution time: %llu\n", end - start);
    return 0;
}
