### Getting all domain-joined Server by Names
 
$servers=(Get-ADComputer -Filter 'operatingsystem -like "*server*"').Name
 
### Get only DriveType 3 (Local Disks) foreach Server
 
ForEach ($s in $servers)
 
{$Report=Get-WmiObject win32_logicaldisk -ComputerName $s -Filter "Drivetype=3" -ErrorAction SilentlyContinue | Where-Object {($_.freespace/$_.size) -le '0.1'}
$View=($Report.DeviceID -join ",").Replace(":","")
### Send Mail if $Report (<=10%) is true
 
If ($Report)
 
{
 
$EmailTo = "p.gruenauer@domain.xy"
$EmailFrom = "alert@domain.xy"
$user = 'p.gruenauer@domain.xy'
$password = Unprotect-CmsMessage -Path C:\Temp\pw.txt
$Subject = "Alert: PowerShell Storage Report of $s"
$Body = "Server $s storage space has dropped to less than 10 % on $View"
$SMTPServer = "smtp.domain.xy"
$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($user, $password)
$SMTPClient.Send($SMTPMessage)
 
}
 
}