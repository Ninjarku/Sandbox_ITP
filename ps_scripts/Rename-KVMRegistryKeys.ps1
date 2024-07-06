# Function to rename blacklisted registry keys and associated executables if they exist
function Rename-BlacklistedRegistryKeysAndExecutables {
    param (
        [string]$RegKey
    )

    # Check if registry key exists
    try {
        # Rename registry key
        Rename-Item -Path "HKLM:\$RegKey" -NewName "Renamed_$RegKey" -Force

        # Check if executable path exists in registry key
        $key = Get-ItemProperty -Path "HKLM:\$RegKey" -ErrorAction SilentlyContinue
        if ($null -ne $key -and $null -ne $key.ImagePath) {
            $executablePath = $key.ImagePath
            # Check if executable exists and rename it
            if (Test-Path $executablePath -PathType Leaf) {
                $execName = Split-Path $executablePath -Leaf
                Rename-Item -Path $executablePath -NewName "Renamed_$execName" -Force
            }
        }
    }
    catch {
        Write-Host "Registry key '$RegKey' does not exist."
    }
}

# List of blacklisted registry keys
$szKeys = @(
    "SYSTEM\ControlSet001\Services\vioscsi",
    "SYSTEM\ControlSet001\Services\viostor",
    "SYSTEM\ControlSet001\Services\VirtIO-FS Service",
    "SYSTEM\ControlSet001\Services\VirtioSerial",
    "SYSTEM\ControlSet001\Services\BALLOON",
    "SYSTEM\ControlSet001\Services\BalloonService",
    "SYSTEM\ControlSet001\Services\netkvm"
)

# Rename each blacklisted registry key and associated executables if they exist
foreach ($key in $szKeys) {
    Rename-BlacklistedRegistryKeysAndExecutables -RegKey $key
}

Write-Host "Registry keys and associated executables have been renamed where possible."
