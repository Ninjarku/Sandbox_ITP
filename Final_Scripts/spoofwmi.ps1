function ChangeDirectory {
    # Must be in the same directory as this powershell script
    # as well as the MOF files to work
    $scriptInstalledDirectory = $PSScriptRoot
    Set-Location -Path $scriptInstalledDirectory
}

function Spoof_Bios { 
    Remove-WmiObject Win32_Bios
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

    Remove-WmiObject Win32_Processor
    Remove-WmiObject CIM_Processor

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "processor.mof") -NoNewWindow -Wait
    $newProcessor = ([WMIClass]"\\.\root\cimv2:Win32_Processor").CreateInstance()

    foreach ($key in $processorHashtable.Keys) {
        $newProcessor.$key = $processorHashtable[$key]
    }
    $newProcessor.Put()
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

    Remove-WmiObject Win32_VideoController
    Remove-WmiObject CIM_VideoController

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "videocontroller.mof") -NoNewWindow -Wait
    $newVideoController = ([WMIClass]"\\.\root\cimv2:Win32_VideoController").CreateInstance()

    foreach ($key in $videoControllerHashtable.Keys) {
        $newVideoController.$key = $videoControllerHashtable[$key]
    }
    $newVideoController.Put()
}

function Spoof_ComputerSystem {
    $computerSystemHashtable = @{}
    $oldComputerSystem = Get-WmiObject -Class Win32_ComputerSystem 
    $totalPhysicalMemory = $oldComputerSystem.TotalPhysicalMemory
    $primaryOwnerName = $oldComputerSystem.PrimaryOwnerName

    Remove-WmiObject Win32_ComputerSystem
    Remove-WmiObject CIM_ComputerSystem

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "computersystem.mof") -NoNewWindow -Wait
    $newComputerSystem = ([WMIClass]"\\.\root\cimv2:Win32_ComputerSystem").CreateInstance()

    $computerSystemHashtable["Domain"] = "WORKGROUP"
    $computerSystemHashtable["Manufacturer"] = "Phoenix Technologies Ltd."
    $computerSystemHashtable["Model"] = "5FCN95WW"
    $computerSystemHashtable["Name"] = "5FCN95WW"
    $computerSystemHashtable["PrimaryOwnerName"] = $primaryOwnerName
    $computerSystemHashtable["TotalPhysicalMemory"] = $totalPhysicalMemory

    foreach ($key in $computerSystemHashtable.Keys) {
        $newComputerSystem.$key = $computerSystemHashtable[$key]
    }

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
    
    Remove-WmiObject Win32_LogicalDisk
    Remove-WmiObject CIM_LogicalDisk

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "logicaldisk.mof") -NoNewWindow -Wait
    $newLogicalDisk = ([WMIClass]"\\.\root\cimv2:Win32_LogicalDisk").CreateInstance()
    
    foreach ($key in $logicalDiskHashtable.Keys) {
        $newLogicalDisk.$key = $logicalDiskHashtable[$key]
    }
    
    $newLogicalDisk.Put()
} 

function Spoof_DiskDrive {
    $diskDriveHashtable = @{}
    $oldDiskDrive = Get-WmiObject -Class Win32_DiskDrive | where-Object { $_.DeviceID -eq "\\.\PHYSICALDRIVE0" }
    $partitions = $oldDiskDrive.Partitions
    $deviceID = $oldDiskDrive.DeviceID
    if ($oldDiskDrive.Size -ge 64424509440) { #60GB in Bytes
        $size = $oldDiskDrive.Size
    }
    else {
        $size = 85899345920 # 80GB in Bytes
    }
    
    Remove-WmiObject Win32_DiskDrive
    Remove-WmiObject CIM_DiskDrive

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "diskdrive.mof") -NoNewWindow -Wait
    $newDiskDrive = ([WMIClass]"\\.\root\cimv2:Win32_DiskDrive").CreateInstance()
    
    $diskDriveHashtable["Partitions"] = $partitions
    $diskDriveHashtable["DeviceID"] = $deviceID
    $diskDriveHashtable["Model"] = "SanDisk SD8SNAT256G1002"
    $diskDriveHashtable["Size"] = $size
    $diskDriveHashtable["Caption"] = "SanDisk SD8SNAT256G1002"
    
    foreach ($key in $diskDriveHashtable.keys) {
        $newDiskDrive.$key = $diskDriveHashtable[$key]
    }

    $newDiskDrive.Put()
}

function Spoof_ComputerSystemProduct {
    Remove-WmiObject Win32_ComputerSystemProduct
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
    Remove-WmiObject Win32_SystemEnclosure
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
    Remove-WmiObject Win32_Fan
    Remove-WmiObject CIM_Fan
    $fanHashTable = @{}

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "fan.mof") -NoNewWindow -Wait
    $newFanClass = ([WMIClass]"\\.\root\cimv2:Win32_Fan").CreateInstance()

    $fanHashTable["DeviceID"] = "root\cimv2 0"
    $fanHashTable["ActiveCooling"] = "True"
    $fanHashTable["Availability"] = "3"
    $fanHashTable["Caption"] = "Cooling Device"
    $fanHashTable["CreationClassName"] = "Win32_Fan"
    $fanHashTable["Description"] = "Cooling Device"
    $fanHashTable["Name"] = "Cooling Device"
    $fanHashTable["Status"] = "OK"
    $fanHashTable["StatusInfo"] = "2"
    $fanHashTable["SystemCreationClassName"] = "Win32_ComputerSystem"
    $fanHashTable["SystemName"] = [System.Environment]::MachineName

    foreach ($key in $fanHashtable.keys) {
        $newFanClass.$key = $fanHashtable[$key]
    }

    $newFanClass.Put()
}

function Spoof_SlotsHierarchy {
    $classesToRemove = @(
        "Win32_SystemSlot"
        "CIM_Slot"
        "CIM_PhysicalConnector"
        "CIM_PhysicalElement"
        "CIM_ManagedSystemElement"
    )

    foreach ($class in $classesToRemove) {
        try {
            Remove-WmiObject $class -ErrorAction Stop
        }
        catch {
            Write-Host "IGNORE: $class not found. Skipping"
        }
    }

    $slotsHierarchyHashtable = @{}
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "slotshierarchy.mof") -NoNewWindow -Wait
    $newSlotsClass = ([WMIClass]"\\.\root\cimv2:Win32_SystemSlot").CreateInstance()

    $slotsHierarchyHashtable["Tag"] = "System Slot 0"
    $slotsHierarchyHashtable["Status"] = "OK"
    $slotsHierarchyHashtable["Caption"] = "System Slot"
    $slotsHierarchyHashtable["Description"] = "System Slot"
    $slotsHierarchyHashtable["Name"] = "System Slot"
    $slotsHierarchyHashtable["SupportsHotPlug"] = "False"
    $slotsHierarchyHashtable["MaxDataWidth"] = "10"

    foreach ($key in $slotsHierarchyHashtable.keys) {
        $newSlotsClass.$key = $slotsHierarchyHashtable[$key]
    }

    $newSlotsClass.Put()
}

function Spoof_SensorHierarchy {
    $classesToRemove = @(
        "Win32_VoltageProbe"
        "CIM_VoltageSensor"
        "CIM_TemperatureSensor"
        "CIM_NumericSensor"
        "CIM_Sensor"
    )

    foreach ($class in $classesToRemove) {
        try {
            Remove-WmiObject $class -ErrorAction Stop
        }
        catch {
            Write-Host "IGNORE: $class not found. Skipping"
        }
    }

    $sensorHierarchyHashtable = @{}
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "sensorhierarchy.mof") -NoNewWindow -Wait
    $newVoltageClass = ([WMIClass]"\\.\root\cimv2:Win32_VoltageProbe").CreateInstance()

    $sensorHierarchyHashtable["DeviceID"] = "root\cimv2 0"
    $sensorHierarchyHashtable["Status"] = "OK"
    $sensorHierarchyHashtable["Name"] = "Numeric Sensor"
    $sensorHierarchyHashtable["Accuracy"] = "32768"
    $sensorHierarchyHashtable["Caption"] = "Numeric Sensor"
    $sensorHierarchyHashtable["Description"] = "LM78A"
    $sensorHierarchyHashtable["MaxReadable"] = "32768"
    $sensorHierarchyHashtable["MinReadable"] = "32768"
    $sensorHierarchyHashtable["Resolution"] = "32768"
    $sensorHierarchyHashtable["SystemCreationClassName"] = "Win32_ComputerSystem"
    $sensorHierarchyHashtable["SystemName"] = [System.Environment]::MachineName
    $sensorHierarchyHashtable["Tolerance"] = "32768"

    foreach ($key in $sensorHierarchyHashtable.keys) {
        $newVoltageClass.$key = $sensorHierarchyHashtable[$key]
    }

    $newVoltageClass.Put()
}

function Spoof_PortConnector {
    try {
        Remove-WmiObject Win32_PortConnector -ErrorAction Stop
    }
    catch {
        Write-Host "IGNORE: Win32_PortConnector not found. Skipping"
    }

    $portConnectorHashtable = @{}
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "portconnector.mof") -NoNewWindow -Wait
    $newPortConnector = ([WMIClass]"\\.\root\cimv2:Win32_PortConnector").CreateInstance()

    $portConnectorHashtable["Tag"] = "Port Connector 0"
    $portConnectorHashtable["Name"] = "Port Connector"
    $portConnectorHashtable["ExternalReferenceDesignator"] = "PS2Mouse"
    $portConnectorHashtable["Caption"] = "Port Connector"
    $portConnectorHashtable["CreationClassName"] = "Win32_PortConnector"
    $portConnectorHashtable["Description"] = "Port Connector"
    $portConnectorHashtable["InternalReferenceDesignator"] = "J1A1"
    $portConnectorHashtable["PortType"] = "14"
    
    foreach ($key in $portConnectorHashtable.keys) {
        $newPortConnector.$key = $portConnectorHashtable[$key]
    }

    $newPortConnector.Put()
}

function Spoof_MemoryDevice {
    try {
        Remove-WmiObject Win32_MemoryDevice -ErrorAction Stop
    }
    catch {
        Write-Host "IGNORE: Win32_MemoryDevice not found. Skipping"
    }

    $memoryDeviceHashtable = @{}
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "memorydevice.mof") -NoNewWindow -Wait
    $newMemoryDevice = ([WMIClass]"\\.\root\cimv2:Win32_MemoryDevice").CreateInstance()

    $memoryDeviceHashtable["DeviceID"] = "Memory Device 0"
    $memoryDeviceHashtable["Caption"] = "Memory Device"
    $memoryDeviceHashtable["CreationClassName"] = "Win32_MemoryDevice"
    $memoryDeviceHashtable["Description"] = "Memory Device"
    $memoryDeviceHashtable["EndingAddress"] = "16777215"
    $memoryDeviceHashtable["Name"] = "Memory Device"
    $memoryDeviceHashtable["StartingAddress"] = "0"
    $memoryDeviceHashtable["SystemCreationClassName"] = "Win32_ComputerSystem"

    foreach ($key in $memoryDeviceHashtable.keys) {
        $newMemoryDevice.$key = $memoryDeviceHashtable[$key]
    }

    $newMemoryDevice.Put()
}

function Spoof_MemoryHierarchy {
    $classesToRemove = @(
        "CIM_Memory"
        "CIM_CacheMemory"
        "Win32_CacheMemory"
    )

    foreach ($class in $classesToRemove) {
        try {
            Remove-WmiObject $class -ErrorAction Stop
        }
        catch {
            Write-Host "IGNORE: $class not found. Skipping"
        }
    }

    $cacheMemoryHashtable = @{}
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "memoryhierarchy.mof") -NoNewWindow -Wait
    $newCacheMemory = ([WMIClass]"\\.\root\cimv2:Win32_CacheMemory").CreateInstance()

    $cacheMemoryHashtable["DeviceID"] = "Cache Memory 0"
    $cacheMemoryHashtable["ErrorCorrectType"] = "4"
    $cacheMemoryHashtable["Availability"] = "3"
    $cacheMemoryHashtable["Status"] = "OK"
    $cacheMemoryHashtable["StatusInfo"] = "3"
    $cacheMemoryHashtable["BlockSize"] = "1024"
    $cacheMemoryHashtable["CacheType"] = "5"
    $cacheMemoryHashtable["InstalledSize"] = "256"
    $cacheMemoryHashtable["Level"] = "3"
    $cacheMemoryHashtable["MaxCacheSize"] = "256"
    $cacheMemoryHashtable["NumberOfBlocks"] = "256"
    $cacheMemoryHashtable["WritePolicy"] = "3"
    $cacheMemoryHashtable["Associativity"] = "7"
    $cacheMemoryHashtable["Caption"] = "Cache Memory"
    $cacheMemoryHashtable["CreationClassName"] = "Win32_CacheMemory"
    $cacheMemoryHashtable["Description"] = "Cache Memory"
    $cacheMemoryHashtable["Name"] = "Cache Memory"
    $cacheMemoryHashtable["Location"] = "0"
    $cacheMemoryHashtable["Purpose"] = "L1 Cache"
    $cacheMemoryHashtable["SystemCreationClassName"] = "Win32_ComputerSystem"

    foreach ($key in $cacheMemoryHashtable.keys) {
        $newCacheMemory.$key = $cacheMemoryHashtable[$key]
    }

    $newCacheMemory.Put()
}

function Spoof_ThermalZoneInformation {
    try {
        Remove-WmiObject Win32_Perf -ErrorAction Stop
    }
    catch {
        Write-Host "IGNORE: Win32_Perf not found. Skipping"
    }

    $thermalZoneInformationHashtable = @{}
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "thermalzoneinformation.mof") -NoNewWindow -Wait
    $newThermalZone = ([WMIClass]"\\.\root\cimv2:Win32_PerfFormattedData_Counters_ThermalZoneInformation").CreateInstance()

    $thermalZoneInformationHashtable["Name"] = "\_TZ.THRM"
    $thermalZoneInformationHashtable["HighPrecisionTemperature"] = "3272"
    $thermalZoneInformationHashtable["PercentPassiveLimit"] = "100"
    $thermalZoneInformationHashtable["Temperature"] = "327"
    $thermalZoneInformationHashtable["ThrottleReasons"] = "0"

    foreach ($key in $thermalZoneInformationHashtable.keys) {
        $newThermalZone.$key = $thermalZoneInformationHashtable[$key]
    }

    $newThermalZone.Put()

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
    Spoof_SlotsHierarchy
    Spoof_SensorHierarchy
    Spoof_PortConnector
    Spoof_MemoryDevice
    Spoof_MemoryHierarchy
    Spoof_ThermalZoneInformation
}

main