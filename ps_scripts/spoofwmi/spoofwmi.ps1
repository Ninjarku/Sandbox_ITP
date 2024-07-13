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

function main {
    Spoof_VideoController
    Spoof_Bios
    Spoof_ComputerSystem
}

main