###############################################################
# Get_Computer Last_Logon_v1.1.ps1
# Version 1.0
# Changelog : n/a
# MALEK Ahmed - 29 / 06 / 2017
###################

##################
#--------Config
##################

$domain = "cdirad.net"

##################
#--------Main
##################

import-module activedirectory
cls
"The domain is " + $domain
$computername = Read-Host 'What is the computer name?'
"Processing the checks ..."
$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
$domaincontrollers = $myforest.Sites | % { $_.Servers } | Select Name
$RealComputerLastLogon = $null
$LastusedDC = $null
$domainsuffix = "*."+$domain
foreach ($DomainController in $DomainControllers) 
{
	if ($DomainController.Name -like $domainsuffix)
	{
		$ComputerLastlogon = Get-ADComputer -Identity $computername -Properties LastLogon -Server $DomainController.Name
		if ($RealComputerLastLogon -le [DateTime]::FromFileTime($ComputerLastlogon.LastLogon))
		{
			$RealComputerLastLogon = [DateTime]::FromFileTime($ComputerLastlogon.LastLogon)
			$LastusedDC =  $DomainController.Name
		}
	}
}
"The last logon occured the " + $RealComputerLastLogon + ""
"It was done against " + $LastusedDC + ""
$message = "............."
$exit = Read-Host $message