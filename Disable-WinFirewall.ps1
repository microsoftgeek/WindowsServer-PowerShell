foreach($line in Get-Content c:\temp\hosts.txt) {

Invoke-Command -ComputerName $line -ScriptBlock { Set-NetFirewallProfile -Name Domain, Public, Private -Enabled False }

}