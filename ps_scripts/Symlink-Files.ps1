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

    # Rename the original file
    Rename-Item -Path $OriginalPath -NewName $NewPath

    # Create a symbolic link
    New-Item -ItemType SymbolicLink -Path $OriginalPath -Target $NewPath
}

# Paths for the driver files
$drivers = @(
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
)

# Process each driver
foreach ($driver in $drivers) {
    Create-Symlink -OriginalPath $driver.OriginalPath -NewPath $driver.NewPath
}

Write-Host "Driver files have been renamed and symbolic links created. Please reboot the system."
