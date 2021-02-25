$computers = get-content C:\computers.txt
ForEach ($computer in $computers)
{
Get-Service SNMP -ComputerName $computer | restart-service -force -passthru
}