# Function to modify ACPI table strings



function Modify-ACPIStrings {
    $acpiTables = Get-ACPI

    foreach ($table in $acpiTables) {
        if ($table.Content -match "BOCHS|BXPC") {
            $table.Content = $table.Content -replace "BOCHS", "MODIFIED"
            $table.Content = $table.Content -replace "BXPC", "MODIFIED"
        }
    }

    # Apply modified tables
    Set-ACPI -Tables $acpiTables # Custom function to set ACPI tables, you'll need to implement this part
}

# Execute the modification
Modify-ACPIStrings
