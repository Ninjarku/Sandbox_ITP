Run the following in Windows Administrator Powershell

# Run and restart:
powershell -ep bypass
.\MacAddress.ps1
.\Username.ps1
.\spoofwmi.ps1

# Run after the restart:
powershell -ep bypass
.\NtYieldExecution_hook.py
.\Rename-AllKeys.ps1

# To restore WMI configurations
powershell -ep bypass
.\restorewmi.ps1