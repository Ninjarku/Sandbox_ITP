function DetectVmExit {
    $iterations = 10
    $deltaThreshold = 1000  # Adjust this threshold as needed

    # Measure execution time of a simple operation
    $start = Get-Date
    for ($i = 0; $i -lt $iterations; $i++) {
        $null = cpuid
    }
    $end = Get-Date

    # Calculate average execution time
    $avgTicks = ($end - $start).Ticks / $iterations

    # Check if average execution time is below threshold
    return ($avgTicks -lt $deltaThreshold)
}

# Helper function to simulate a non-functional CPUID-like operation
function cpuid {
    # Perform a simple non-functional operation to simulate CPUID
    [System.Math]::Sqrt(2)
}

# Example usage:
$vmExitDetected = DetectVmExit

if ($vmExitDetected) {
    Write-Host "VM exit detected (timing difference), potential sandbox or virtualized environment."
} else {
    Write-Host "No VM exit detected (timing difference), likely running on physical hardware."
}
