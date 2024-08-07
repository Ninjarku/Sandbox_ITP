# Ref https://learn.microsoft.com/en-gb/archive/blogs/jamesone/managing-windows-update-with-powershell
# From https://gist.github.com/mikebranstein/7e9169000a6555c195043e1755fbee7e
# set the Windows Update service to "disabled"
sc.exe config wuauserv start=disabled

# display the status of the service
sc.exe query wuauserv

# stop the service, in case it is running
sc.exe stop wuauserv

# display the status again, because we're paranoid
sc.exe query wuauserv

# double check it's REALLY disabled - Start value should be 0x4
REG.exe QUERY HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv /v Start


# Setting it to 1 means disabled (To disable autoupdate)
$AUSettings = (New-Object -com "Microsoft.Update.AutoUpdate").Settings
$AUSettings.NotificationLevel = 1
$AUSettings.Save