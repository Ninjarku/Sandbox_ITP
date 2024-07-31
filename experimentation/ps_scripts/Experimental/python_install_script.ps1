# https://www.python.org/ftp/python/3.7.8/python-3.7.8-amd64.exe

# Chocolatey way
#@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
#choco install -y python3


# Install from python site
$url = "https://www.python.org/ftp/python/3.7.8/python-3.7.8-amd64.exe"
$output = "C:/Users/Public/Downloads/python-3.7.8-amd64.exe"

if (Test-Path $output) {
    Write-Host "Script exists - skipping installation"
    return;
}

New-Item -ItemType Directory -Force -Path C:/tmp

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $output

& $output /passive InstallAllUsers=1 PrependPath=1 Include_test=0 