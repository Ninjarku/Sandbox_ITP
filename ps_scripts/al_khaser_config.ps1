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
        # Get all subkeys recursively
        $subKeys = Get-ChildItem -Path $regPath -Recurse -ErrorAction SilentlyContinue

        foreach ($subKey in $subKeys) {
            try {
                # Get the property values
                $values = Get-ItemProperty -Path $subKey.PSPath -ErrorAction SilentlyContinue

                foreach ($value in $values.PSObject.Properties) {
                    if ($value.Value -is [string] -and $value.Value -match [regex]::Escape($OldValue)) {
                        # Replace old value with new value
                        $newValue = $value.Value -replace [regex]::Escape($OldValue), $NewValue
                        Set-ItemProperty -Path $subKey.PSPath -Name $value.Name -Value $newValue -ErrorAction SilentlyContinue
                        Write-Host "Renamed $OldValue to $NewValue in $($subKey.PSPath)"
                    }
                }
            } catch {
                Write-Host "Failed to access $($subKey.PSPath): $_"
            }
        }
    }
}


# List of VMware identifiers to rename
$vmwareIDs = @(
    @{OldValue = "VMware"; NewValue = "GenericSoftware"},
    @{OldValue = "vmci"; NewValue = "GenericDevice"},
    @{OldValue = "vmhgfs"; NewValue = "GenericDevice"},
    @{OldValue = "vmx86"; NewValue = "GenericDevice"},
    @{OldValue = "vmusbmouse"; NewValue = "GenericDevice"},
    @{OldValue = "vmvss"; NewValue = "GenericDevice"},
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


# List of virtual machine identifiers to rename
# $vmIDs = @('vbox','vmware','qemu','virtual')
# $NewID = "GenericDisk"


# Rename each identifier
# foreach ($vmID in $vmIDs) {
#     Rename-HardwareIDs -OldID $vmID.OldID -NewID $NewID
# }

# Write-Host "Virtual machine identifiers have been renamed."



# Function to mask the presence of virtual machine services
function Mask-VirtualMachineServices {
    $servicesToMask = @(
        "VBoxService",
        "VBoxSF",
        "VBoxVideo",
        "vmicheartbeat",
        "vmicvss",
        "vmicshutdown",
        "vmicexchange",
        "vmicguestinterface"
    )

    foreach ($service in $servicesToMask) {
        try {
            Stop-Service -Name $service -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "Stopped and disabled service $service"
        } catch {
            Write-Host "Failed to modify service $service: $_"
        }
    }
}

# Mask-VirtualMachineServices

# Write-Host "Virtual machine services have been masked."