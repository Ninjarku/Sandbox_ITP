# Get the current directory
$currentDirectory = Get-Location

# Define the destination directory
$destinationDirectory = "C:\Windows\System32"

# Get all .dll files in the current directory
$dllFiles = Get-ChildItem -Path $currentDirectory -Filter *.dll

# Copy each .dll file to the destination directory
foreach ($file in $dllFiles) {
    Copy-Item -Path $file.FullName -Destination $destinationDirectory -Force
    Write-Output "Copied $($file.Name) to $destinationDirectory"
}

Write-Output "All .dll files have been copied to $destinationDirectory."
