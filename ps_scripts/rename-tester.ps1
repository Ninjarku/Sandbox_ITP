# Define the string to be replaced and the replacement string
$searchString = "vmware"
$replacementString = "windows"

# Function to recursively process registry keys
# Function to process registry keys
function Process-RegistryKey {
    param (
        [string]$keyPath
    )

    try {
        # Get the registry key
        $key = Get-Item -Path $keyPath -ErrorAction Stop

        # Process each value in the key
        foreach ($value in $key.Property) {
            $currentValue = (Get-ItemProperty -Path $keyPath -Name $value).$value
            if ($currentValue -is [string]) {
                if ($currentValue -match "(?i)$searchString") {
                    $newValue = $currentValue -replace "(?i)$searchString", $replacementString
                    Set-ItemProperty -Path $keyPath -Name $value -Value $newValue
                    Write-Output "Updated value in $keyPath : $value"
                }
            }
        }

        # Recursively process subkeys
        foreach ($subKey in $key.GetSubKeyNames()) {
            $subKeyPath = "$keyPath\$subKey"
            Start-Job -ScriptBlock {
                param($subKeyPath, $searchString, $replacementString)
                Process-RegistryKey -keyPath $subKeyPath -searchString $searchString -replacementString $replacementString
            } -ArgumentList $subKeyPath, $searchString, $replacementString | Out-Null
        }
    } catch {
        Write-Output "Error accessing $keyPath : $_"
    }
}

# List of root keys to start with
$rootKeys = @(
    # "HKLM:\",
    # "HKCU:\"
    "HKLM:\SOFTWARE",
    "HKCU:\SOFTWARE",
    "HKLM:\SYSTEM",
    "HKCU:\SYSTEM",
    "HKLM:\HARDWARE"

)

# Start the replacement process for each root key
foreach ($rootKey in $rootKeys) {
    Start-Job -ScriptBlock {
        param($rootKey, $searchString, $replacementString)
        Process-RegistryKey -keyPath $rootKey -searchString $searchString -replacementString $replacementString
    } -ArgumentList $rootKey, $searchString, $replacementString | Out-Null
}

# Wait for all jobs to complete
Get-Job | Wait-Job