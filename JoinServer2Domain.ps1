get-credential corptcf\a.t281937

Add-Computer -ComputerName MNP-RATA-APP01 -DomainName "CORPTCF" -OUPath "OU=virtual servers,OU=servers,DC=corp,DC=tcf,DC=biz" -Restart

Add-Computer -DomainName "CORPTCF" -OUPath "OU=virtual servers,OU=servers,DC=corp,DC=tcf,DC=biz" -Restart