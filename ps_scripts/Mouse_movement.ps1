# Function to move the mouse with random offsets and sleep duration
function Move_Mouse {
    param (
        [int]$minOffset = -10,
        [int]$maxOffset = 10,
        [int]$minSleep = 1,
        [int]$maxSleep = 5
    )

    $currentCursorPosition = [System.Windows.Forms.Cursor]::Position
    $xOffset = Get-Random -Minimum $minOffset -Maximum $maxOffset
    $yOffset = Get-Random -Minimum $minOffset -Maximum $maxOffset
    $newCursorPosition = New-Object System.Drawing.Point(($currentCursorPosition.X + $xOffset), ($currentCursorPosition.Y + $yOffset))
    [System.Windows.Forms.Cursor]::Position = $newCursorPosition

    $sleepSeconds = Get-Random -Minimum $minSleep -Maximum $maxSleep
    Start-Sleep -Seconds $sleepSeconds
}

# Specify how many times to move the mouse
$numberOfMovements = 10  # Adjust as needed

# Perform mouse movements
for ($i = 0; $i -lt $numberOfMovements; $i++) {
    Move_Mouse
}
