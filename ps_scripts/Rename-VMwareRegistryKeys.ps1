# Function to rename VMware registry keys and values
function Rename-VMwareRegistryKeys {
    param (
        [string]$OldValue,
        [string]$NewValue
    )

    # List of registry paths to search for VMware-related keys and values
    $regPaths = @(
        "HKLM:\SOFTWARE\VMware, Inc.",
        "HKLM:\SYSTEM\CurrentControlSet\Services",
        "HKCU:\Software\VMware, Inc."
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

# List of VMware identifiers to rename
$vmwareIDs = @(
    @{OldValue = "VMware"; NewValue = "GenericSoftware"},
    # @{OldValue = "vmci"; NewValue = "GenericDevice"},
    # @{OldValue = "vmhgfs"; NewValue = "GenericDevice"},
    # @{OldValue = "vmx86"; NewValue = "GenericDevice"},
    # @{OldValue = "vmusbmouse"; NewValue = "GenericDevice"},
    # @{OldValue = "vmvss"; NewValue = "GenericDevice"},
    @{OldValue = "VMTools"; NewValue = "GenericService"},
    @{OldValue = "VMnetAdapter"; NewValue = "GenericAdapter"},
    @{OldValue = "VMnetBridge"; NewValue = "GenericBridge"},
    @{OldValue = "VMnetDHCP"; NewValue = "GenericDHCP"},
    @{OldValue = "VMnetNat"; NewValue = "GenericNAT"}
)

# Rename each identifier
foreach ($vmwareID in $vmwareIDs) {
    Rename-VMwareRegistryKeys -OldValue $vmwareID.OldValue -NewValue $vmwareID.NewValue
}

Write-Host "VMware identifiers have been renamed."
