 #########################
 
 $computers = Get-ADComputer -Filter *
 
 $computers | ForEach-Object -Process {Invoke-GPUpdate -Computer $_.name -RandomDelayInMinutes 0 -Force}


 
 
 #########################
 Get-ADComputer -Filter * -SearchBase "OU=Computers - Servers,DC=CDIRAD,DC=NET" | Foreach-Object {Invoke-GPUpdate -Computer $_.name -Force -RandomDelayInMinutes 0}


 Get-ADComputer -Filter * -SearchBase "OU=Computers - Workstations,DC=CDIRAD,DC=NET" | Foreach-Object {Invoke-GPUpdate -Computer $_.name -Force -RandomDelayInMinutes 0}
