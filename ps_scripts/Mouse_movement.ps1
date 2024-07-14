# Constants for mouse events
$MOUSE_EVENT = 0x0001

# Function to move the mouse with random offsets and sleep duration
function Move_Mouse {
    param (
        [int]$minOffset = -10,
        [int]$maxOffset = 10,
        [int]$minSleep = 1,
        [int]$maxSleep = 5
    )

    $xOffset = Get-Random -Minimum $minOffset -Maximum $maxOffset
    $yOffset = Get-Random -Minimum $minOffset -Maximum $maxOffset

    [UserInput]::mouse_event($MOUSE_EVENT, $xOffset, $yOffset, 0, 0)

    $sleepSeconds = Get-Random -Minimum $minSleep -Maximum $maxSleep
    Start-Sleep -Seconds $sleepSeconds
}

# Specify how many times to move the mouse
$numberOfMovements = 1000  # Adjust as needed

# Perform mouse movements
for ($i = 0; $i -lt $numberOfMovements; $i++) {
    Move_Mouse
}
