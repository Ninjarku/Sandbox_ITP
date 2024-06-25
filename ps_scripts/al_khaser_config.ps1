# Counter setupdi_diskdrive via renaming hardware IDs in the registry.
# Function to rename hardware IDs in the registry
function Rename-HardwareIDs {
    param (
        [string]$OldID,
        [string]$NewID
    )

    # Path to the disk drive hardware IDs in the registry
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Enum"

    # Get all subkeys
    $subKeys = Get-ChildItem -Path $regPath -Recurse

    foreach ($subKey in $subKeys) {
        # Get the value names
        $values = Get-ItemProperty -Path $subKey.PSPath

        foreach ($value in $values.PSObject.Properties) {
            if ($value.Name -eq "HardwareID" -and $value.Value -contains $OldID) {
                # Replace old ID with new ID
                $newValue = $value.Value -replace [regex]::Escape($OldID), $NewID
                Set-ItemProperty -Path $subKey.PSPath -Name $value.Name -Value $newValue
                Write-Host "Renamed $OldID to $NewID in $($subKey.PSPath)"
            }
        }
    }
}


# List of virtual machine identifiers to rename
$vmIDs = @('vbox','vmware','qemu','virtual')
$NewID = "GenericDisk"


# Rename each identifier
foreach ($vmID in $vmIDs) {
    Rename-HardwareIDs -OldID $vmID.OldID -NewID $NewID
}

Write-Host "Virtual machine identifiers have been renamed."