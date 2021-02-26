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


###########################################
Write-Output "$HR NUTANIX VM - BE GONE $HR"
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

} # end foreach VM Shutdown