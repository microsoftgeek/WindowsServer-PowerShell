###All Windows Servers with data
Get-ADComputer -Filter {OperatingSystem -LIke "Windows Server*"} -properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address | select name,lastlogondate,lastlogon | Where-Object {$_.lastlogondate -ge "06/15/2019"} > WinServers.csv
Get-ADComputer -Filter {OperatingSystem -LIke "Windows Server*"} -properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address | select name,lastlogondate,lastlogon > WinServers.csv




###All Windows Servers
Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,lastlogondate > WinServers3.csv
Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,lastlogondate | format-list > WinServers4.csv
Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,lastlogondate | format-table > WinServers5.csv
Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,lastlogondate | Export-Csv c:\temp\WinServers6.csv


###Windows clients
Get-ADComputer -Filter {operatingsystem -notlike '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,lastlogondate | Export-Csv c:\temp\WinClients.csv


###All Computers
Get-ADComputer -Filter * -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address
