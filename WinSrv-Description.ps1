#
# www.sivarajan.com
# Udpate Computer Description - PowerShell Script
Import-module ActiveDirectory  
Import-CSV "C:\temp\WinServ-DescriptionUpdate.csv" | % { 
$Computer = $_.ComputerName 
$Desc = $_.Description 
Set-ADComputer $Computer -Description $Desc 
}