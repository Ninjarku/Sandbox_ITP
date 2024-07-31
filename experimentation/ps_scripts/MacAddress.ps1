function addressMacAddress {
    $forbiddenMacAddresses = @(
        "00-05-69"
        "00-0C-29"
        "00-1C-14"
        "00-50-56"
    )
     
    $MACAddress = (Get-NetAdapter -Name "Ethernet0" | Select-Object -ExpandProperty MacAddress).Substring(0,8)
    $NetworkInterfaces = (Get-ChildItem -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" -ErrorAction SilentlyContinue).Name
    $MACAddressInList = $false

    foreach ($originalRegistryPath in $NetworkInterfaces) {
        $index = $originalRegistryPath.Split('\')[-1]
        if (-not ($index.toLower() -eq "configuration")){
            $newPath = $originalRegistryPath.replace("HKEY_LOCAL_MACHINE","HKLM:")
            $driverDescription = (Get-ItemProperty -Path $newPath).DriverDesc
            if ($driverDescription.Contains("Intel")) {
                $correctPath = $newPath
                break;
            }
        }
    }
    
    foreach ($VMMacAddresses in $forbiddenMacAddresses){
        if ($MACAddress.ToUpper() -eq $VMMacAddresses) {
            $MACAddressInList = $true
        }
    }
    if ($MACAddressInList){
        try {
            $newMacAddress = @()
            $MacAddressCharacters = @("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")

            for ($i = 0; $i -lt 6; $i ++){
                $firstRandom = Get-Random -Minimum 0 -Maximum 16
                $secondRandom = Get-Random -Minimum 0 -Maximum 16
                $newMacAddress += $MacAddressCharacters[$firstRandom] + $MacAddressCharacters[$secondRandom]
            }
            $newMacAddress = $newMacAddress -join "-"
            Set-ItemProperty -Path $correctPath -Name "NetworkAddress" -Value $newMacAddress -ErrorAction Stop    
        
            Write-Output "Successfully changed MAC Address to $newMacAddress"
        }
        catch {
            Write-Output "Unable to change MAC Address: $_"
        }
    }
}

addressMacAddress