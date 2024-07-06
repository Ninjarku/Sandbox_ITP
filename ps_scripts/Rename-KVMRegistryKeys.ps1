# Function to rename blacklisted registry keys and associated executables if they exist
function Rename-BlacklistedRegistryKeysAndExecutables {
    param (
        [string]$OldValue,
        [string]$NewValue
    )

    # List of registry paths to search for QEMU-related keys and values
    $regPaths = @(
        "HKLM:\SOFTWARE\kvm",
        "HKLM:\SYSTEM\CurrentControlSet\Services",
        "HKCU:\Software\kvm"
    )

    foreach ($regPath in $regPaths) {
        # Get all subkeys non-recursively
        $subKeys = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue

        foreach ($subKey in $subKeys) {
            # Process each subkey without recursion
            ProcessRegistryKey $subKey.PSPath $OldValue $NewValue

            # Get and process subkeys one level deep
            $childSubKeys = Get-ChildItem -Path $subKey.PSPath -ErrorAction SilentlyContinue
            foreach ($childSubKey in $childSubKeys) {
                ProcessRegistryKey $childSubKey.PSPath $OldValue $NewValue
            }
        }
    }
}

# Function to process a single registry key
function ProcessRegistryKey {
    param (
        [string]$keyPath,
        [string]$OldValue,
        [string]$NewValue
    )

    try {
        # Get the property values
        $values = Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue

        foreach ($value in $values.PSObject.Properties) {
            if ($value.Value -is [string] -and $value.Value -match [regex]::Escape($OldValue)) {
                # Replace old value with new value
                $newValue = $value.Value -replace [regex]::Escape($OldValue), $NewValue
                Set-ItemProperty -Path $keyPath -Name $value.Name -Value $newValue -ErrorAction SilentlyContinue
                Write-Host "Renamed $OldValue to $NewValue in $($keyPath)"
            }
        }
    } catch {
        Write-Host "Failed to access $($keyPath): $_"
    }
}

# List of blacklisted registry keys
$kvmIDs = @(
    "SYSTEM\ControlSet001\Services\vioscsi",
    "SYSTEM\ControlSet001\Services\viostor",
    "SYSTEM\ControlSet001\Services\VirtIO-FS Service",
    "SYSTEM\ControlSet001\Services\VirtioSerial",
    "SYSTEM\ControlSet001\Services\BALLOON",
    "SYSTEM\ControlSet001\Services\BalloonService",
    "SYSTEM\ControlSet001\Services\netkvm"
)

$szKeys = @(
    @{OldValue = "vioscsi"; NewValue = "GenericSoftware"},
    @{OldValue = "viostor"; NewValue = "GenericSystem"},
    @{OldValue = "VirtIO-FS Service"; NewValue = "GenericService"},
    @{OldValue = "VirtioSerial"; NewValue = "GenericSoftware"},
    @{OldValue = "BALLOON"; NewValue = "GenericSoftware"},
    @{OldValue = "BalloonService"; NewValue = "GenericSoftware"},
    @{OldValue = "netkvm"; NewValue = "GenericSoftware"}
)


# Rename each blacklisted registry key and associated executables if they exist
foreach ($key in $szKeys) {
    Rename-BlacklistedRegistryKeysAndExecutables -OldValue $key.OldValue -NewValue $key.NewValue
}

Write-Host "Registry keys and associated executables have been renamed where possible."
