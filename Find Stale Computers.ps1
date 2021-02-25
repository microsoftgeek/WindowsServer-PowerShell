# The 60 is the number of days from today since the last logon.
$then = (Get-Date).AddDays(-60)
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $then} -SearchBase 'OU=Corp_Workstations,DC=company,DC=org' | Select-Object Name | 
foreach {
if(Test-Connection $_.name -Count 1 -ErrorAction SilentlyContinue){
  Write-Output "Keep $($_.name)" 
}else{
  Write-Output "Remove $($_.name)" 
}
}