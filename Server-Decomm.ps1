Write-Output "$HR  Server Decomm Script for the OS Team

##########################################################################################
#
#                  *Server Decomm Script for the OS Team* 
#                                                                                
# Created by Cesar Duran (Jedi Master)                                                                                        
# Version:1.2                                                                                                                                        
#                                                                                                                                                                                                                                                              
#  Server Tasks:
# 1) Ping Servers and export Ping Results
# 2) VMGuest Shutdown
# 3) Append Text to Notes field on VM
# 4) VM Rename
# 5) Disable AD Objects
# 6) Shutdown Windows Servers
# 7) Shutsdown VMs on Nutanix/PRISM
# 8) Ping Servers and export Ping Results                                                                                                                                                                                                                                                                                                                                                                                                                                
#                                                                                                                                                                                                          
###########################################################################################

$HR"

# TCF Server Decomm Script for the OS Team

# Line delimiter
$HR = "`n{0}`n" -f ('='*20)


########################################
Write-Output "$HR HELLO OLD SERVERS $HR"
# Ping Servers, Ping Results

$Computers = Get-Content "C:\temp\server-decomms.txt"
foreach ($computer in $computers)
{
    $Destination = "C:\temp\Export\Start\Pingup.log"
    $Destination2 = "C:\temp\Export\Start\PingDown.log"
    if (Test-Connection $computer -Count 1 -ea 0 -Quiet)
    { 
        Write-Host "$computer Is Up" -ForegroundColor Green
        $computer | out-file -Append $Destination -ErrorAction SilentlyContinue 
    } 
    else 
    { 
        Write-Host "$computer Is Down" -ForegroundColor Red
        $computer | out-file -Append $Destination2 -ErrorAction SilentlyContinue  
    }
  
} # end foreach Ping



###########################################
Write-Output "$HR HOLA VMWARE VCENTERS $HR"
# Connect-VIServer

Connect-VIServer MN-VCENTER, MN-VCENTER2, MN-VCENTER-NTX, IL-VCENTER


######################################
Write-Output "$HR 30 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 30
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 30 seconds



###############################################
Write-Output "$HR VMWARE VMs - BYE FELICIA $HR"
# This powers off the VM Guest in VMWARE

foreach($vmName in (Get-Content -Path "C:\temp\server-decomms.txt"))
{

    $vm = Get-VM -Name $vmName

    if($vm.Guest.State -eq "Running"){

        Shutdown-VMGuest -VM $vm -Confirm:$false

    }

    else{

        Stop-VM -VM $vm -Confirm:$false

    }

} # End of each VM ShutDown



######################################
Write-Output "$HR 30 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 30
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 30 seconds



##########################################
Write-Output "$HR KON'NICHIWA NUTANIX $HR"
# Quick Connect to Nutanix Cluster

# loading Nutanix PowerShell SnapIns
Add-PSSnapin NutanixCmdletsPSSnapin

# Cluster IP
$server1 = 'MN-AHV-CL1'
$server2 = 'MN-AHV-CL2'
$server3 = 'MN-CITRIX-CL1'
$server4 = 'MN-ORACLE-CL1'
$server5 = 'MN-ORACLE-CL2'
$server6 = 'MN-VMWARE-CL1'
$server7 = 'DR-AHV-CL1'

# Request & Verify credentials 
$credentials = Get-Credential -Message "**Enter your Nutanix Admin credentials here**"

$username = $credentials.username
$password = ConvertTo-SecureString $($credentials.GetNetworkCredential().password) -AsPlainText -Force

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server1 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server2 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server3 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server4 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server5 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server6 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"

write-host "Connecting to Cluster..."
Connect-NTNXCluster -Server $server7 -UserName $UserName -Password $password -AcceptInvalidSSLCerts -ForcedConnection
write-host "Done!"



######################################
Write-Output "$HR 30 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 30
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 30 seconds



###########################################
Write-Output "$HR SAYONARA NUTANIX VMs $HR"
# This powers off the VM Guest in Nutanix


$csv = "$PSScriptRoot\server-decomms.csv"

Add-PSSnapin NutanixCmdletsPSSnapin


foreach($vmLine in (Import-Csv -Path $csv -UseCulture))
{

    $vmname = $vmline.VMName
      
    Write-Verbose "Shutting Down $VMname" -Verbose
    $vminfo = Get-NTNXVM | where {$_.vmName -eq $VMName}
    $vmId = ($vminfo.vmid.split(":"))[2]
    Set-NTNXVMPowerOff -Vmid $VMid
    
    Start-Sleep -s 3

} # end of each VM Shutdown



#####################################
Write-Output "$HR 2 MINUTE PAUSE $HR"
# 90sec Pause

$Timeout = 120
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 2 minutes



###################################################
Write-Output "$HR ALMOST THERE, HANG ON!!!

##########################################################################################
#
#              *PATIENCE YOU MUST HAVE, MY YOUNG PADAWAN - YODA*
#
#                                                                                                                                                                                                                                                                                                                                                                                                                              
#                                                                                                                                                                                                          
###########################################################################################

$HR"




##############################################
Write-Output "$HR NIGHT NIGHT OLD SERVERS $HR"
# Shut Down Remote Servers

$YourFile = Get-Content 'C:\temp\server-decomms.txt'

foreach ($computer in $YourFile)
{

Stop-Computer -ComputerName $computer -force

} 
# end for each erver shutdown



######################################
Write-Output "$HR 90 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 90
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 90 seconds


######################################
Write-Output "$HR DISABLE AD CRAP $HR"
# Disable AD Computer Objects

$Computers = Get-Content c:\temp\server-decomms.txt

foreach ($Computer in $Computers) {
    $ADComputer = $null
    $ADComputer = Get-ADComputer $Computer -Properties Description

    if ($ADComputer) {
        Add-Content C:\temp\export\server-decomm.log -Value "Found $Computer, disabling"
        Set-ADComputer $ADComputer -Description "Server Decommissioned - Computer Disabled on $(Get-Date)" -Enabled $false
    } else {
        Add-Content C:\temp\export\server-decomm.log -Value "$Computer not in Active Directory"
    }
} # end for each AD disable




####################################
Write-Output "$HR VM EDIT NOTES $HR"
# This appends "Server Decommissioned" to the notes field

Import-Csv "c:\temp\notes.csv" | % { 

Get-VM $_.VMName | Set-VM  -Notes $_.Note -Confirm:$false

} # end for each note append



#######################################
Write-Output "$HR VMWARE VM RENAME $HR"
# VMware Server Decommission - Add "-Decomm" to name

$vms = Import-Csv C:\temp\import-vm.csv -UseCulture


foreach($vm in $vms){
  Get-VM $($vm.oldname) | 
  Set-vm -name $($vm.newname) -confirm:$false

} # end foreach VM rename



#################################################################################
Write-Output "$HR INFOBLOX DNS RECORDS ARE SCAVENGED EVERY 12TH OF THE MONTH $HR"
# Delete DNS Records from InfoBlox



###################################################
Write-Output "$HR HELLO DARKNESS MY OLD FRIEND $HR"
# Ping Servers, Ping Results

$Computers = Get-Content "C:\temp\server-decomms.txt"
foreach ($computer in $computers)
{
    $Destination = "C:\temp\Export\End\Pingup.log"
    $Destination2 = "C:\temp\Export\End\PingDown.log"
    if (Test-Connection $computer -Count 1 -ea 0 -Quiet)
    { 
        Write-Host "$computer Is Up" -ForegroundColor Green
        $computer | out-file -Append $Destination -ErrorAction SilentlyContinue 
    } 
    else 
    { 
        Write-Host "$computer Is Down" -ForegroundColor Red
        $computer | out-file -Append $Destination2 -ErrorAction SilentlyContinue  
    }
  
} # end foreach Ping



###################################################
Write-Output "$HR THE END, HAVE A NICE DAY!!!

##########################################################################################
#
#              *POWERFUL YOU HAVE BECOME, THE DARK SIDE I SENSE IN YOU - YODA*
#
#                                                                                                                                                                                                                                                                                                                                                                                                                              
#                                                                                                                                                                                                          
###########################################################################################

$HR"