# Function to simulate VM exit detection based on timing differences
function DetectVmExit {
    $tsc1 = 0
    $tsc2 = 0
    $avg = 0
    $iterations = 10

    for ($i = 0; $i -lt $iterations; $i++) {
        $tsc1 = Get-Rdtsc
        $null = cpuid
        $tsc2 = Get-Rdtsc

        $avg += ($tsc2 - $tsc1)
    }

    $avg = $avg / $iterations

    # Return true if average delta is less than 1000 and greater than 0
    return ($avg -lt 1000 -and $avg -gt 0)
}

# Helper function to simulate RDTSC (read timestamp counter)
function Get-Rdtsc {
    return [System.Diagnostics.Stopwatch]::GetTimestamp()
}

# Helper function to simulate CPUID instruction
function cpuid {
    # Perform some non-functional operation
    [System.Math]::Sqrt(2)
}

# Example usage:
$vmExitDetected = DetectVmExit

if ($vmExitDetected) {
    Write-Host "VM exit detected (RDTSC difference), potential sandbox or virtualized environment."
} else {
    Write-Host "No VM exit detected (RDTSC difference), likely running on physical hardware."
}
