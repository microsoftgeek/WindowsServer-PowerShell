$s = New-CimSession -ComputerName WIN8-WS, 2012R2-DC, 2012R2-MS `  –Credential (Get-Credential Contoso\Administrator) 
 
Get-CimInstance CIM_OperatingSystem -CimSession $s 
Get-CimInstance CIM_ComputerSystem -CimSession $s 
Get-CimInstance CIM_DiskDrive -CimSession $s 
 
Remove-CimSession $s 