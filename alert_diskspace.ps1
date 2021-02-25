$Action=New-ScheduledTaskAction -Execute "powershell" -Argument "C:\PowerShell\alert_diskspace.ps1"
$Trigger=New-ScheduledTaskTrigger -Daily -At 08am
$Set=New-ScheduledTaskSettingsSet
$Principal=New-ScheduledTaskPrincipal -UserId "sid-500\patrick" -LogonType S4U
$Task=New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Set -Principal $Principal -Description "Checks free disk space on all Servers. Sends an E-Mail notification if storage drops below 10%"
Register-ScheduledTask -TaskName "Free Disk Space Check" -InputObject $Task -User "sid-500\patrick" -Password (Read-Host 'Enter Password') -Force
