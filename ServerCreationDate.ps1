Get-ADComputer -filter * -properties created | select-object name, created | sort created | export-csv c:\temp\PCbday.csv

######

Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,lastlogondate | Export-Csv c:\temp\Server-Bday.csv
Get-ADComputer -filter 'operatingsystem -like "*server*"' -properties operatingsystem, managedby | ` select-object name, managedby | export-csv c:\temp\server-owners.csv



###############
Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,created | select-object name, created | sort created | Export-Csv c:\temp\Server-Bday.csv

Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,created | Export-Csv c:\temp\Server-Bday2.csv