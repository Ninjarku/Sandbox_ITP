# Define the string to be replaced and the replacement string
$searchString = "vmware"
$replacementString = "windows"

# Function to recursively process registry keys
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
        $subKeys = $key.GetSubKeyNames() | ForEach-Object { "$keyPath\$_" }
        $subKeys | ForEach-Object -Parallel {
            param ($subKey)
            Process-RegistryKey -keyPath $subKey
        } -ThrottleLimit 10
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
$rootKeys | ForEach-Object -Parallel {
    param ($rootKey)
    Process-RegistryKey -keyPath $rootKey
} -ThrottleLimit 10