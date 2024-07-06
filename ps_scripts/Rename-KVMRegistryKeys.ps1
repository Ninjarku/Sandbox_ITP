# Array of blacklisted registry keys
$szKeys = @(
    "SYSTEM\ControlSet001\Services\vioscsi",
    "SYSTEM\ControlSet001\Services\viostor",
    "SYSTEM\ControlSet001\Services\VirtIO-FS Service",
    "SYSTEM\ControlSet001\Services\VirtioSerial",
    "SYSTEM\ControlSet001\Services\BALLOON",
    "SYSTEM\ControlSet001\Services\BalloonService",
    "SYSTEM\ControlSet001\Services\netkvm"
)

# Function to rename registry keys and their associated executables
function Rename-RegKeysAndExecutables {
    param (
        [string]$RegKey,
        [string]$NewName
    )

    # Rename registry key
    Rename-Item -Path "HKLM:\$RegKey" -NewName $NewName -Force

    # Get executable path from registry key if it exists
    $executablePath = Get-ExecutablePathFromRegistry -RegKey $RegKey

    if ($executablePath -ne $null -and $executablePath -ne "") {
        # Rename executable
        Rename-Item -Path $executablePath -NewName "$NewName.exe" -Force
    }
}

# Function to get executable path from registry key
function Get-ExecutablePathFromRegistry {
    param (
        [string]$RegKey
    )

    $key = Get-ItemProperty -Path "HKLM:\$RegKey" -ErrorAction SilentlyContinue
    if ($key -ne $null -and $key.ImagePath -ne $null) {
        return $key.ImagePath
    }
    return $null
}

# Rename each blacklisted registry key and associated executables
foreach ($key in $szKeys) {
    Rename-RegKeysAndExecutables -RegKey $key -NewName "Renamed_$key"
}

Write-Host "Registry keys and associated executables have been renamed."
