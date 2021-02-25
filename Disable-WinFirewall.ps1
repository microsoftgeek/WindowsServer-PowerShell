$computerName = 'mnpwdproapp01, mnpwdproapp02, mnpwdproweb01, mnpwdproweb02, mnpwdprots01, mnpwdprots02, mnpwdprots03, mnpwdprots04, mnpwdprots05, mnpwdprots06'
 Invoke-Command -Computername $computerName -ScriptBlock {
 Set-NetFirewallProfile -Name Domain, Public, Private -Enabled False
}