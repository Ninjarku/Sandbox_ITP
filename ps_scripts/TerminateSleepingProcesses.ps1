# Define the script block
$scriptBlock = {
    # Function to terminate processes that are in a sleep state
    function TerminateSleepingProcesses {
        $sleepingProcesses = Get-Process | Where-Object { $_.Name -match 'sleep|delay|ntdelayexecution' }
        foreach ($process in $sleepingProcesses) {
            try {
                Stop-Process -Id $process.Id -Force
                Write-Host "Terminated sleeping process: $($process.Name)"
            } catch {
                Write-Host "Failed to terminate process: $($process.Name)"
            }
        }
    }

    # Periodically check for sleeping processes
    while ($true) {
        TerminateSleepingProcesses
        Start-Sleep -Seconds 5
    }
}

# Start the script block as a background job
$job = Start-Job -ScriptBlock $scriptBlock

# Output the job details
Write-Host "Started job with ID: $($job.Id)"

# Check job status
# Get-Job

# Receive Job Output:
# Receive-Job -Id $job.Id

# Stop the Job:
# Stop-Job -Id $job.Id
