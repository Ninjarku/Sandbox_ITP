function ChangeWorkingDirectory {
    # Change working directory to the same directory as the script
    # Ensures that the script is able to find all the required files
    $currentWorkingDirectory = $PWD
    $scriptInstalledDirectory = $PSScriptRoot

    if ($currentWorkingDirectory -ne $scriptInstalledDirectory) {
        Set-Location -Path $scriptInstalledDirectory
    }
}

function Remove-WmiClass {
    # Remove the original class as well as its children before overwriting
    param (
        [string[]]$ClassesToRemove
    )
    foreach ($class in $ClassesToRemove) {
        try {
            Remove-WmiObject $class -ErrorAction Stop
        }
        catch {}
    }
}

function Compile-MOF {
    # Compile the necessary MOF file and create a new instance of the class
    param (
        [string]$mofFileName,
        [string]$classname
    )

    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath $mofFileName) -NoNewWindow -Wait
    $newClass = ([WMIClass]"\\.\root\cimv2:$classname").CreateInstance()

    return $newClass
}

function main {
    changeWorkingDirectory
    $jsonFileContents = Get-Content -Path (Join-Path -Path (Get-Location) -ChildPath "Properties.json") -Raw | ConvertFrom-Json
    $classnameList = $jsonFileContents | Select-Object -ExpandProperty Classname -Unique

    foreach ($classname in $classnameList) {
        $classProperties = $jsonFileContents | Where-Object { $_.Classname -eq $classname }
        $classHashtable = @{}
        $relatedClassArray = $classProperties.RelatedClasses
        $mofFile = $classProperties.MOF_File
        
        foreach ($property in $classProperties.Properties.PSObject.Properties) {
            $classHashtable[$property.Name] = $property.Value
        }
        
        try {
            $initialClass = Get-WmiObject $classname 2>$null| Select-Object -First 1 -Property * -ErrorAction SilentlyContinue

            foreach ($property in $initialClass.Properties) {
                if (-not ($classHashtable.ContainsKey($property.Name))) { 
                    $classHashtable[$property.Name] = $property.Value
                }
            }
        }
        catch {}
        
        Remove-WmiClass -ClassesToRemove $relatedClassArray
        $newClass = Compile-MOF -mofFileName $mofFile -classname $classname

        foreach ($key in $classHashtable.Keys) {
            $newClass.$key = $classHashtable[$key]
        }

        $newClass.Put()
        
    } 
}

main