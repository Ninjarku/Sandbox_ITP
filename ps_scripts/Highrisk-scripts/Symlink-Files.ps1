# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\balloon.sys" -Target "C:\Windows\System32\drivers\balloon_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\netkvm.sys" -Target "C:\Windows\System32\drivers\netkvm_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\vioscsi.sys" -Target "C:\Windows\System32\drivers\vioscsi_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\pvpanic.sys" -Target "C:\Windows\System32\drivers\pvpanic_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\viofs.sys" -Target "C:\Windows\System32\drivers\viofs_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\viogpudo.sys" -Target "C:\Windows\System32\drivers\viogpudo_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\vioinput.sys" -Target "C:\Windows\System32\drivers\vioinput_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\viorng.sys" -Target "C:\Windows\System32\drivers\viorng_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\vioser.sys" -Target "C:\Windows\System32\drivers\vioser_renamed.sys"
# New-Item -ItemType SymbolicLink -Path "C:\Windows\System32\drivers\viostor.sys" -Target "C:\Windows\System32\drivers\viostor_renamed.sys"

# Function to rename and create symbolic links for driver files
function Create-Symlink {
    param (
        [string]$OriginalPath,
        [string]$NewPath
    )

    if (Test-Path $OriginalPath) {
        # Rename the original file
        Rename-Item -Path $OriginalPath -NewName $NewPath -Force

        # Create a symbolic link
        New-Item -ItemType SymbolicLink -Path $OriginalPath -Target $NewPath
        Write-Host "Symbolic link created for $OriginalPath to $NewPath"
    } else {
        Write-Host "File $OriginalPath does not exist. Skipping..."
    }
}


# Paths for the driver files
$drivers = @(
    # For QEMU
    @{ OriginalPath = "C:\Windows\System32\drivers\balloon.sys"; NewPath = "C:\Windows\System32\drivers\balloon_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\netkvm.sys"; NewPath = "C:\Windows\System32\drivers\netkvm_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\vioscsi.sys"; NewPath = "C:\Windows\System32\drivers\vioscsi_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\pvpanic.sys"; NewPath = "C:\Windows\System32\drivers\pvpanic_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\viofs.sys"; NewPath = "C:\Windows\System32\drivers\viofs_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\viogpudo.sys"; NewPath = "C:\Windows\System32\drivers\viogpudo_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\vioinput.sys"; NewPath = "C:\Windows\System32\drivers\vioinput_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\viorng.sys"; NewPath = "C:\Windows\System32\drivers\viorng_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\vioser.sys"; NewPath = "C:\Windows\System32\drivers\vioser_renamed.sys"},
    @{ OriginalPath = "C:\Windows\System32\drivers\viostor.sys"; NewPath = "C:\Windows\System32\drivers\viostor_renamed.sys"}
    # For VMware
    @{ OriginalPath = "C:\Windows\System32\drivers\vmnet.sys"; NewPath = "C:\Windows\System32\drivers\vmnet_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmmouse.sys"; NewPath = "C:\Windows\System32\drivers\vmmouse_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmusb.sys"; NewPath = "C:\Windows\System32\drivers\vmusb_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vm3dmp.sys"; NewPath = "C:\Windows\System32\drivers\vm3dmp_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmci.sys"; NewPath = "C:\Windows\System32\drivers\vmci_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmhgfs.sys"; NewPath = "C:\Windows\System32\drivers\vmhgfs_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmmemctl.sys"; NewPath = "C:\Windows\System32\drivers\vmmemctl_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmx86.sys"; NewPath = "C:\Windows\System32\drivers\vmx86_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmrawdsk.sys"; NewPath = "C:\Windows\System32\drivers\vmrawdsk_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmusbmouse.sys"; NewPath = "C:\Windows\System32\drivers\vmusbmouse_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmkdb.sys"; NewPath = "C:\Windows\System32\drivers\vmkdb_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmnetuserif.sys"; NewPath = "C:\Windows\System32\drivers\vmnetuserif_renamed.sys"}
    @{ OriginalPath = "C:\Windows\System32\drivers\vmnetadapter.sys"; NewPath = "C:\Windows\System32\drivers\vmnetadapter_renamed.sys"}
    )

# Process each driver
foreach ($driver in $drivers) {
    Create-Symlink -OriginalPath $driver.OriginalPath -NewPath $driver.NewPath
}

Write-Host "Driver files have been renamed and symbolic links created. Please reboot the system."
