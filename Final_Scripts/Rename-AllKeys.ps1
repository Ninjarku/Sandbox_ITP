# Function to rename QEMU registry keys and values
function Rename-RegistryKeys {
    param (
        [string]$OldValue,
        [string]$NewValue,
        [string[]]$regPaths
    )

    foreach ($regPath in $regPaths) {
        ProcessRegistryKey $regPath $OldValue $NewValue
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
        # Get the specific properties of interest 
        $propertiesOfInterest = @("SystemManufacturer", 
        "SystemProductName", 
        "SystemBiosVersion", 
        "0", 
        "Identifier")
        $keyProps = Get-ItemProperty -Path $keyPath -ErrorAction SilentlyContinue
        
        foreach ($prop in $propertiesOfInterest) {
            if ($keyProps.$prop -is [string] -and $keyProps.$prop -match [regex]::Escape($OldValue)) {
                # Replace old data with new data
                $newData = $keyProps.$prop -replace [regex]::Escape($OldValue), $NewValue
                Set-ItemProperty -Path $keyPath -Name $prop -Value $newData -ErrorAction SilentlyContinue
                Write-Host "Renamed data in $prop from $OldValue to $NewValue in $($keyPath)"
            }
        }
    } catch {
        Write-Host "Failed to access data in $($keyPath) : $_"
    }
}

# Function to rename the QEMU keys 

function RenameQEMUKeys{
    # List of QEMU identifiers to rename
    $qemuIDs = @(
        @{OldValue = "QEMU"; NewValue = "Windows"},
        @{OldValue = "QEMUSystem"; NewValue = "GenericSystem"},
        @{OldValue = "QEMUService"; NewValue = "GenericService"}
    )

    # List of registry paths to search for QEMU-related keys and values
    $regPaths = @(
        "HKLM:\HARDWARE\Description\System",
        "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0"
        "HKLM:\SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters"
    )

    # Rename each identifier
    foreach ($qemuID in $qemuIDs) {
        Rename-RegistryKeys -OldValue $qemuID.OldValue -NewValue $qemuID.NewValue -regPaths $regPaths
    }

    Write-Host "QEMU identifiers have been renamed."
}


# Function to rename the KVM keys 
function RenameKVMKeys{
    # List of blacklisted registry keys
    $szKeys = @(
        @{OldValue = "vioscsi"; NewValue = "GenericSoftware"},
        @{OldValue = "viostor"; NewValue = "GenericSystem"},
        @{OldValue = "VirtIO-FS Service"; NewValue = "GenericService"},
        @{OldValue = "VirtioSerial"; NewValue = "GenericSoftware"},
        @{OldValue = "BALLOON"; NewValue = "GenericSoftware"},
        @{OldValue = "BalloonService"; NewValue = "GenericSoftware"},
        @{OldValue = "netkvm"; NewValue = "GenericSoftware"}
    )

    # List of registry paths to search for QEMU-related keys and values
    $regPaths = @(
        "HKLM:\SYSTEM\ControlSet001\Services",
        "HKLM:\SYSTEM\ControlSet001\Services\vioscsi",
        "HKLM:\SYSTEM\ControlSet001\Services\viostor",
        "HKLM:\SYSTEM\ControlSet001\Services\VirtIO-FS Service",
        "HKLM:\SYSTEM\ControlSet001\Services\VirtioSerial",
        "HKLM:\SYSTEM\ControlSet001\Services\BALLOON",
        "HKLM:\SYSTEM\ControlSet001\Services\BalloonService",
        "HKLM:\SYSTEM\ControlSet001\Services\netkvm"
    )

    # Rename each blacklisted registry key and associated executables if they exist
    foreach ($key in $szKeys) {
        Rename-RegistryKeys -OldValue $key.OldValue -NewValue $key.NewValue -regPaths $regPaths
    }

    Write-Host "Registry keys and associated executables have been renamed where possible."
}


# Function to rename the VMware keys 
function RenameVMwareKeys{
    # List of VMware identifiers to rename
    $vmwareIDs = @(
        @{OldValue = "VMware"; NewValue = "GenericSoftware"},
        @{OldValue = "VMTools"; NewValue = "GenericService"},
        @{OldValue = "VMnetAdapter"; NewValue = "GenericAdapter"},
        @{OldValue = "VMnetBridge"; NewValue = "GenericBridge"},
        @{OldValue = "VMnetDHCP"; NewValue = "GenericDHCP"},
        @{OldValue = "VMnetNat"; NewValue = "GenericNAT"}
    )
    
    # List of registry paths to search for VMware-related keys and values
    $regPaths = @(
        "HKLM:\SOFTWARE\VMware, Inc.",
        "HKLM:\SYSTEM\CurrentControlSet\Services",
        "HKLM:\SYSTEM\ControlSet001\Services",
        "HKLM:\SYSTEM\ControlSet001\Control\SystemInformation",
        "HKCU:\Software\VMware"
    )

    # Rename each identifier
    foreach ($vmwareID in $vmwareIDs) {
        Rename-RegistryKeys -OldValue $vmwareID.OldValue -NewValue $vmwareID.NewValue -regPaths $regPaths
    }

    Write-Host "VMware identifiers have been renamed."
}


function RenameGenericKeys{
     # List of Generic identifiers to rename
     $GenericIDs = @(
        @{OldValue = "qemu"; NewValue = "Generic"},
        @{OldValue = "virtio"; NewValue = "Generic"},
        @{OldValue = "vmware"; NewValue = "Generic"},
        @{OldValue = "vbox"; NewValue = "Generic"},
        @{OldValue = "xen"; NewValue = "Generic"},
        @{OldValue = "VMW"; NewValue = "Generic"},
        @{OldValue = "Virtual"; NewValue = "Generic"}
    )
    
    # List of registry paths to search for VMware-related keys and values
    $regPaths = @(
        "HKLM:\SYSTEM\CurrentControlSet\Enum\IDE",
        "HKLM:\SYSTEM\CurrentControlSet\Services\Disk\Enum",
        "HKLM:\SYSTEM\CurrentControlSet\Enum\SCSI"
    )

    # Rename each identifier
    foreach ($GenericID in $GenericIDs) {
        Rename-RegistryKeys -OldValue $GenericID.OldValue -NewValue $GenericID.NewValue -regPaths $regPaths
    }

    Write-Host "Generic identifiers have been renamed."
}

function Rename-AllKeys{
    RenameVMwareKeys;
    RenameQEMUKeys;
    RenameKVMKeys;
    RenameGenericKeys;
}

# Call the rename
Rename-AllKeys;