<#

Choose a method for populating the "$List" of Servers 

-- Comma separated manually entered list.
$CommaList = ("Server01,Server02")
$List = $CommaList.Split(",")

-- List OU members 
$List = Get-ADComputer -Filter * -SearchBase "OU=IT,DC=contoso,DC=com"

-- List from TXT file
$List = Get-Content -Path "c:\scripts\PC-List.txt"

#>

<#~~~~~~~~~~          Variables              ~~~~~~~~~~#>

$When = "25/12/2025 19:00" # Use remote server's regional date format
$CommaList = ("Server01,Server02,Server03")
$List = $CommaList.Split(",") 
$User = "Domain\Admin.User" # Use an account with rights on the remote Server
$Pass = "P@s5_-_W0rD!" # If using a password in clear text is not acceptable, change line 28 to $Credential = (get-credential -Message "User credentials with Admin rights on the remote computer")

<#~~~~~~~~~~         Do not Edit             ~~~~~~~~~~#>

$PWord = ConvertTo-SecureString -String "$Pass" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
$ArgList = @{
RT = $When
}
Foreach ($Server in $List) 
{
icm -Cn $Server -Credential $Credential -ScriptBlock {
 param($ArgList)
 register-ScheduledJob -ScriptBlock {Restart-Computer -Force} -Name "Scheduled Restart" -Trigger (New-JobTrigger -Once -At $ArgList.RT) -ScheduledJobOption (New-ScheduledJobOption -RunElevated) } -ArgumentList $ArgList
}