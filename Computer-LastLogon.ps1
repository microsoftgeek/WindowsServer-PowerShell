Get-CimInstance -ClassName win32_operatingsystem -ComputerName MN-SHAWAPPPRD | select csname, lastbootuptime

Get-CimInstance -ClassName CIM_OperatingSystem | Select-Object CSName, LastBootUpTime, ` @{name='UpTimeInHours';expression={(New-TimeSpan -Start $_.LastBootUpTime `   -End (Get-Date)).TotalHours}} 

Get-CimInstance -ClassName CIM_OperatingSystem -ComputerName MN-SHAWAPPPRD | Select-Object CSName, LastBootUpTime, ` @{name='UpTimeInHours';expression={(New-TimeSpan -Start $_.LastBootUpTime `   -End (Get-Date)).TotalHours}} 
