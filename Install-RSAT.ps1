######################################################################
###Install RSAT and Enable Active Directory Module for Importation ###
######################################################################

$RSATCheck= Get-WindowsFeature RSAT-AD-Powershell

if (($RSATCheck.InstallState -eq "Available") -or ($RSATCheck.InstallState -eq "Removed"))
{
    write-host "Need to Install RSAT" -ForegroundColor Yellow
    Import-Module ServerManager
    Add-WindowsFeature RSAT-AD-PowerShell
    Import-module ActiveDirectory
    write-host ""
}

Else
    {
     write-host "RSAT has previously been installed" -ForegroundColor Yellow
     write-host ""
    }