function RestoreWMI {
    Set-Location -Path "C:\Windows\system32\wbem"
    Start-Process -FilePath "mofcomp.exe" -ArgumentList (Join-Path -Path (Get-Location) -ChildPath "cimwin32.mof") -NoNewWindow -Wait
}

RestoreWMI


