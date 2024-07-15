# Function to rename QEMU registry keys and values
function Rename-QEMURegistryKeys {
    param (
        [string]$OldValue,
        [string]$NewValue,
        [string]$regPaths
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

function RenameQEMUKeys{
    # List of QEMU identifiers to rename
    $qemuIDs = @(
        @{OldValue = "QEMU"; NewValue = "GenericSoftware"},
        @{OldValue = "QEMUSystem"; NewValue = "GenericSystem"},
        @{OldValue = "QEMUService"; NewValue = "GenericService"}
    )

    # List of registry paths to search for QEMU-related keys and values
    $regPaths = @(
        "HKLM:\SOFTWARE\QEMU",
        "HKLM:\SOFTWARE\RedHat",
        "HKLM:\SYSTEM\ControlSet001\Services",
        "HKLM:\SYSTEM\ControlSet001\Control\SystemInformation",
        "HKCU:\Software\QEMU"
    )

    # Rename each identifier
    foreach ($qemuID in $qemuIDs) {
        Rename-QEMURegistryKeys -OldValue $qemuID.OldValue -NewValue $qemuID.NewValue -regPaths $regPaths
    }

    Write-Host "QEMU identifiers have been renamed."
}



# Restart the computer for it to affect the RTDSC trick that causes vm exit
# shutdown /r /t 0
