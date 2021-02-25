#Get All Windows Servers
 {
    $server=Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address 
    $scount=$server | Measure-Object | Select-Object -ExpandProperty count
    ''
    Write-Host -ForegroundColor Green "Windows Server $env:userdnsdomain" 
   
    Write-Output $server | Sort-Object Operatingsystem | Format-Table Name,Operatingsystem,OperatingSystemVersion,IPv4Address
    ''
    Write-Host 'Total: '$scount"" -ForegroundColor Yellow
    ''
    }




###################################################

Get-ADComputer -Filter {OperatingSystem -LIke "*Server*"} -properties * | select name, lastlogondate| Where-Object {$_.lastlogondate -ge "5/1/2017"} > domaincomputers | Export-Csv -Path C:\temp\all-server2.csv

Get-ADComputer -Filter {OperatingSystem -LIke "Windows Server*"} -properties * | select name, lastlogondate| Where-Object {$_.lastlogondate -ge "5/1/2017"} > domaincomputers | Export-Csv -Path C:\temp\all-server2.csv