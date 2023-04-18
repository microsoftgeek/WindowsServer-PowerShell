get-credential corp\username

Add-Computer -ComputerName MNP-RATA-APP01 -DomainName "CORP" -OUPath "OU=virtual servers,OU=servers,DC=corp,DC=company,DC=biz" -Restart

Add-Computer -DomainName "CORP" -OUPath "OU=virtual servers,OU=servers,DC=corp,DC=company,DC=biz" -Restart
