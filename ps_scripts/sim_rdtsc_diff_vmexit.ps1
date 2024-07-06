# Function to simulate RDTSC difference for VM exit detection
function CounterRdtscDiffVmexit {
    # Initialize variables
    $tsc1 = 0
    $tsc2 = 0
    $avg = 0
    $cpuInfo = New-Object int[] 4

    # Try 10 times to account for fluctuations
    for ($i = 0; $i -lt 10; $i++) {
        # Simulate RDTSC and CPUID
        $tsc1 = [System.Diagnostics.Stopwatch]::GetTimestamp()
        [System.Runtime.Intrinsics.X86.X86Base]::Cpuid([ref]$cpuInfo, 0)
        $tsc2 = [System.Diagnostics.Stopwatch]::GetTimestamp()

        # Calculate delta of RDTSC
        $avg += ($tsc2 - $tsc1)
    }

    # Calculate average delta
    $avg = $avg / 10

    # Return result based on average delta condition
    return ($avg -lt 1000 -and $avg -gt 0) -eq $true
}

# Example usage:
$vmExitDetected = CounterRdtscDiffVmexit

if ($vmExitDetected) {
    Write-Host "VM exit detected (RDTSC difference), potential sandbox or virtualized environment."
} else {
    Write-Host "No VM exit detected (RDTSC difference), likely running on physical hardware."
}
