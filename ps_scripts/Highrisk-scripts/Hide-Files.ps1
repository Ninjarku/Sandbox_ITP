# Function to hide driver files
function Hide-DriverFile {
    param (
        [string]$FilePath
    )

    if (Test-Path $FilePath) {
        # Set the file attributes to hidden and system
        Set-ItemProperty -Path $FilePath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden + [System.IO.FileAttributes]::System)
        Write-Host "Set hidden and system attributes for $FilePath"
    } else {
        Write-Host "File $FilePath does not exist. Skipping..."
    }
}

# Paths for the driver files
$drivers = @(
    "C:\Windows\System32\drivers\balloon.sys",
    "C:\Windows\System32\drivers\netkvm.sys",
    "C:\Windows\System32\drivers\vioscsi.sys",
    "C:\Windows\System32\drivers\pvpanic.sys",
    "C:\Windows\System32\drivers\viofs.sys",
    "C:\Windows\System32\drivers\viogpudo.sys",
    "C:\Windows\System32\drivers\vioinput.sys",
    "C:\Windows\System32\drivers\viorng.sys",
    "C:\Windows\System32\drivers\vioser.sys",
    "C:\Windows\System32\drivers\viostor.sys",
    "C:\Windows\System32\drivers\vmnet.sys",
    "C:\Windows\System32\drivers\vmmouse.sys",
    "C:\Windows\System32\drivers\vmusb.sys",
    "C:\Windows\System32\drivers\vm3dmp.sys",
    "C:\Windows\System32\drivers\vmci.sys",
    "C:\Windows\System32\drivers\vmhgfs.sys",
    "C:\Windows\System32\drivers\vmmemctl.sys",
    "C:\Windows\System32\drivers\vmx86.sys",
    "C:\Windows\System32\drivers\vmrawdsk.sys",
    "C:\Windows\System32\drivers\vmusbmouse.sys",
    "C:\Windows\System32\drivers\vmkdb.sys",
    "C:\Windows\System32\drivers\vmnetuserif.sys",
    "C:\Windows\System32\drivers\vmnetadapter.sys"
)

# Process each driver
foreach ($driver in $drivers) {
    Hide-DriverFile -FilePath $driver
}

Write-Host "Driver files have been hidden. Please reboot the system."
