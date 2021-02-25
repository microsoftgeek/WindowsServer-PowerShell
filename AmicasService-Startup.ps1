Write-Output "$HR Amicas Service Automatic Start-Up Script

##########################################################################################
#
#                  *Amicas Service Automatic Start-Up Script* 
#                                                                                
# Created by Cesar Duran (Jedi Master)                                                                                        
# Version:1.0                                                                                                                                        
#Set the Amicas Service to start Automatic(Delayed)
#Set the AmicasMessenger service to Automatic
#Set the AmicasWatch Service to Automatic
#Set the AmicasWeb service to automatic
#
#Run gpupdate /force with elevated privileges.
#
#Create a new folder on the root of C called \Old DICOM script
#Move the existing PAX service restart script from C:\Users\Public\Desktop\ to C:\Old DICOM Script\
#Put a new batch file that I have onto C:\Users\Public\Desktop\                                                                                                                                                                                                                                                                                                                                                                                                                           
#                                                                                                                                                                                                          
###########################################################################################

$HR"

# Amicas Service Automatic Start-Up Script

# Line delimiter
$HR = "`n{0}`n" -f ('='*20)


########################################################################
Write-Output "$HR REGISTRY EDIT DELAYED-AUTOSTART $HR"
# Amices Services DelayedAutostart


Install-Module ActiveDirectory -Verbose -Force
Import-Module ActiveDirectory -Verbose -Force

$Computers = Get-Content "C:\temp\Amicasservers.txt"
$UserCredential = Get-Credential

Invoke-Command -ComputerName $Computers -Credential $UserCredential -ScriptBlock { 
Write-Verbose "Checking Computer $Computer"
Write-Verbose "Enabling AutoStartDelay for AmicasServiceJ Service on $Computer"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\AmicasServiceJ" -Name "DelayedAutostart" -Value 1 -Type DWord
Write-Host "AutoStartDelay for AmicasServiceJ Service Successfully Enabled on $Computer"

}
# End of RegEdit entry


##############################################
Write-Output "$HR 5 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 5
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 5 seconds


#########################################################
Write-Output "$HR AMICAS SERVICES DELAYED-AUTOSTART $HR"
# Amices Services Delayed


$Computers = Get-Content "C:\temp\Amicasservers.txt"
$service = "AmicasServiceJ"
$command = “sc.exe \\$Computers config $service start= delayed-auto”
$output = invoke-expression -command $command
write-host $Computers ”Successfully changed $Service service to delayed start” $output

# End of Startup Autimatic Delayed


##############################################
Write-Output "$HR 3 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 3
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 3 seconds


#################################################
Write-Output "$HR AMICAS SERVICES AUTOMATIC $HR"
# Amices Services Start-Up

$YourFile = Get-Content 'C:\temp\Amicasservers.txt'

foreach ($computer in $YourFile)
{

 Set-Service -Name AmicasMessaging -Computer $computer -StartupType Automatic
 Set-Service -Name AmicasWatchServiceJ -Computer $computer -StartupType Automatic
 Set-Service -Name AmicasWebServiceJ -Computer $computer -StartupType Automatic

} 
# end for each Service Startup



##############################################
Write-Output "$HR 3 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 3
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 3 seconds


##############################################
Write-Output "$HR GROUP POLICY UPDATE $HR"
# GPO Update

$YourFile = Get-Content 'C:\temp\Amicasservers.txt'

foreach ($computer in $YourFile)
{

Invoke-GPUpdate -Verbose -Force

} 
# end for Group Policy Updates


####################################################
Write-Output "$HR MOVING BATCH FILE $HR"
# Moving files

$Computers = Get-Content "C:\temp\Amicasservers.txt"
$Source = "\\dc1-cifs-1\SYSTEMENGINEERS\Grant\MergeScripts"
$Destination = "\\$Computers\C$\Users\Public\Desktop"

Invoke-Command -ComputerName $Computers -ScriptBlock { 

New-Item -Path "C:\" -Name "Old_DICOM_Script" -ItemType "Directory"
Move-Item -Path C:\Users\Public\Desktop\PAX-18207_startamicas.bat -Destination C:\Old_DICOM_Script\PAX-18207_startamicas.bat

}
# end of moving files


####################################################
Write-Output "$HR COPYING BATCH FILE $HR"
# Copying files

$Source = "\\dc1-cifs-1\SYSTEMENGINEERS\Grant\MergeScripts"
$Destination = "\\$Computers\C$\Users\Public\Desktop"
$YourFile = Get-Content 'C:\temp\Amicasservers.txt'

foreach ($computer in $YourFile)
{

Copy-Item -Path $Source\*.* -Destination $Destination -Force

}
# end of copying files

###################################################
Write-Output "$HR THE END, HAVE A NICE DAY!!!

##########################################################################################
#
#              *POWERFUL YOU HAVE BECOME, THE DARK SIDE I SENSE IN YOU - YODA*
#
#                                                                                                                                                                                                                                                                                                   
###########################################################################################

$HR"