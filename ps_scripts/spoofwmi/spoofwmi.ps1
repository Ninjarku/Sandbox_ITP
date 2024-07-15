function ChangeDirectory {
    # Must be in the same directory as this powershell script
    # as well as the MOF files to work
    $scriptInstalledDirectory = $PSScriptRoot
    Set-Location -Path $scriptInstalledDirectory
}

function Spoof_Bios { 
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "bios.mof") -NoNewWindow -Wait
    $newBios = ([WMIClass]"\\.\root\cimv2:Win32_Bios").CreateInstance()
    $newBios.SMBIOSBIOSVersion = "5FCN95WW"
    $newBios.Manufacturer = "Phoenix Technologies Ltd."
    $newBios.Name = "5FCN95WW"
    $newBios.SerialNumber = "QB06506849OA3OK"
    $newBios.Version = "LENOVO - 6040000"
    $newBios.Put()
}

function Spoof_Processor {
    $processorHashtable = @{}
    $oldProcessorOutput = Get-WmiObject -Class Win32_Processor | Where-Object { $_.DeviceID -eq "CPU0" } | Select-Object -Property *
    
    foreach ($property in $oldProcessorOutput.Properties) {
        $processorHashtable[$property.Name] = $property.Value
    }

    if ($processorHashtable["ProcessorID"] -eq $null) {
        $processorHashtable["ProcessorID"] = "1F8BFBFF000673F4"
    }
    
    if ($processorHashtable["NumberOfCores"] -le 2) {
        $processorHashtable["NumberOfCores"] = 4
        $processorHashtable["NumberOfEnabledCore"] = 4
        $processorHashtable["NumberOfLogicalProcessors"] = 4
    }

    $processorHashtable["DeviceID"] = "CPU0"
    $processorHashtable["VirtualizationFirmwareEnabled"] = "False"
    $processorHashtable["VMMonitorModeExtensions"] = "False"
    $processorHashtable["ThreadCount"] = "4"

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "processor.mof") -NoNewWindow -Wait
    $newProcessorClass = ([WMIClass]"\\.\root\cimv2:Win32_Processor").CreateInstance()

    foreach ($key in $processorHashtable.Keys) {
        $newProcessorClass.$key = $processorHashtable[$key]
    }
    $newProcessorClass.Put()
}

function Spoof_VideoController {
    # Copies all the other values of the original Win32_VideoController
    # Tries to maintain most of the original Win32_Videocontroller
    # output to minimize the risk of the system breaking
    $videoControllerHashtable = @{}
    $videoController = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.DeviceID -eq "VideoController1" }
    
    foreach ($property in $videoController.Properties) {
        $videoControllerHashtable[$property.Name] = $property.Value
    }
    
    # Add or edit if required: These are the keys that will be spoofed
    $videoControllerHashtable["DeviceID"] = "VideoController1"
    $videoControllerHashtable["Name"] = "Nvidia Geforce GTX 1070"
    $videoControllerHashtable["Caption"] = "Nvidia Geforce GTX 1070"
    $videoControllerHashtable["Description"] = "Nvidia GeForce GTX 1070"
    $videoControllerHashtable["VideoProcessor"] = "GeForce GTX 1070"
    $videoControllerHashtable["InfSection"] = "Section058"
    $videoControllerHashtable["AdapterCompatibility"] = "Nvidia"
    $videoControllerHashtable["InstalledDisplayDrivers"] = "nvldumdx.dll,nvldumdx.dll,nvldumdx.dll" 

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "videocontroller.mof") -NoNewWindow -Wait
    $newVideoController = ([WMIClass]"\\.\root\cimv2:Win32_VideoController").CreateInstance()
    
    foreach ($key in $videoControllerHashtable.Keys) {
        $newVideoController.$key = $videoControllerHashtable[$key]
    }
    $newVideoController.Put()
}

function Spoof_ComputerSystem {
    $oldComputerSystem = Get-WmiObject -Class Win32_ComputerSystem 
    $totalPhysicalMemory = $oldComputerSystem.TotalPhysicalMemory
    $primaryOwnerName = $oldComputerSystem.PrimaryOwnerName

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "computersystem.mof") -NoNewWindow -Wait
    $newComputerSystem = ([WMIClass]"\\.\root\cimv2:Win32_ComputerSystem").CreateInstance()
    $newComputerSystem.Domain = "WORKGROUP"
    $newComputerSystem.Manufacturer = "Phoenix Technologies Ltd."
    $newComputerSystem.Model = "5FCN95WW"
    $newComputerSystem.Name = "5FCN95WW"
    $newComputerSystem.PrimaryOwnerName = $primaryOwnerName
    $newComputerSystem.TotalPhysicalMemory = $totalPhysicalMemory
    $newComputerSystem.Put()
}

function Spoof_LogicalDisk {
    $logicalDiskHashtable = @{}
    $oldLogicalDisk = Get-WmiObject -Class Win32_LogicalDisk | Select-Object -First 1 | Select-Object -Property *
    
    foreach ($property in $oldLogicalDisk.Properties) {
        $logicalDiskHashtable[$property.Name] = $property.Value
    }

    if ($logicalDiskHashtable["Size"] -lt 64424509440) {
        $logicalDiskHashtable["Size"] = 85899345920
    }
        
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "logicaldisk.mof") -NoNewWindow -Wait
    $newLogicalDisk = ([WMIClass]"\\.\root\cimv2:Win32_LogicalDisk").CreateInstance()

    foreach ($key in $logicalDiskHashtable.Keys) {
        $newLogicalDisk.$key = $logicalDiskHashtable[$key]
    }
    
    $newLogicalDisk.Put()
} 

function Spoof_DiskDrive {
    $oldDiskDrive = Get-WmiObject -Class Win32_DiskDrive | where-Object { $_.DeviceID -eq "\\.\PHYSICALDRIVE0" }
    $partitions = $oldDiskDrive.Partitions
    $deviceID = $oldDiskDrive.DeviceID
    if ($oldDiskDrive.Size -ge 64424509440) { #60GB in Bytes
        $size = $oldDiskDrive.Size
    }
    else {
        $size = 85899345920 # 80GB in Bytes
    }

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "diskdrive.mof") -NoNewWindow -Wait
    $newDiskDrive = ([WMIClass]"\\.\root\cimv2:Win32_DiskDrive").CreateInstance()
    $newDiskDrive.Partitions = $partitions
    $newDiskDrive.DeviceID = $deviceID
    $newDiskDrive.Model = "SanDisk SD8SNAT256G1002"
    $newDiskDrive.Size = $size
    $newDiskDrive.Caption = "SanDisk SD8SNAT256G1002"
    $newDiskDrive.Put()
}

function Spoof_ComputerSystemProduct {
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "computersystemproduct.mof") -NoNewWindow -Wait
    $newComputerSystemProduct = ([WMIClass]"\\.\root\cimv2:Win32_ComputerSystemProduct").CreateInstance()
    $newComputerSystemProduct.IdentifyingNumber = "QB06506849OA3OK"
    $newComputerSystemProduct.Name = "5FCN95WW"
    $newComputerSystemProduct.Vendor = "Phoenix Technologies Ltd."
    $newComputerSystemProduct.Version = "1.0"
    $newComputerSystemProduct.Caption = "Computer System Product"
    $newComputerSystemProduct.Put()
}

function Spoof_SystemEnclosure {
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "systemenclosure.mof") -NoNewWindow -Wait
    $newSystemEnclosure = ([WMIClass]"\\.\root\cimv2:Win32_SystemEnclosure").CreateInstance()
    $newSystemEnclosure.Manufacturer = "Phoenix Technologies Ltd."
    $newSystemEnclosure.LockPresent = "True"
    $newSystemEnclosure.SerialNumber = "CSN12345678901234567"
    $newSystemEnclosure.SMBIOSAssetTag = "No Asset Tag"
    $newSystemEnclosure.SecurityStatus = "3"
    $newSystemEnclosure.Put()
}

function Spoof_Fan {
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "fan.mof") -NoNewWindow -Wait
    $newFanClass = ([WMIClass]"\\.\root\cimv2:Win32_Fan").CreateInstance()
    $newFanClass.DeviceID = "root\cimv2 0"
    $newFanClass.ActiveCooling = "True"
    $newFanClass.Availability = "3"
    $newFanClass.Caption = "Cooling Device"
    $newFanClass.CreationClassName = "Win32_Fan"
    $newFanClass.Description = "Cooling Device"
    $newFanClass.Name = "Cooling Device"
    $newFanClass.Status = "OK"
    $newFanClass.StatusInfo = "2"
    $newFanClass.SystemCreationClassName = "Win32_ComputerSystem"
    $newFanClass.SystemName = [System.Environment]::MachineName
    $newFanClass.Put()
}

function main {
    ChangeDirectory
    Spoof_VideoController
    Spoof_Bios
    Spoof_ComputerSystem
    Spoof_DiskDrive
    Spoof_ComputerSystemProduct
    Spoof_SystemEnclosure
    Spoof_Fan
    Spoof_Processor
    Spoof_LogicalDisk
}

main