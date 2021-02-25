$Properties = "AdsPath","Name","Class","Description"

$Select = $Properties | %{  
  Invoke-Expression "@{n='$_';e={ `$_.GetType().InvokeMember('$_', 'GetProperty', `$Null, `$_, `$Null) }}"  
}
 
#$RunDate  = (get-date).tostring("MM_dd_yyyy")  
#$Time = Get-Date -format 'hh:mm'  
$Results = "C:\temp\Localadmin.csv"  

Get-ADComputer -filter * -SearchBase "OU=NW,OU=MN,OU=Acuo,OU=Computers - Servers,DC=cdirad,DC=net"  | ForEach-Object {

  $ComputerName = $_.Name
  $Group = [ADSI]("WinNT://$ComputerName/Administrators")  
  $Group.PsBase.Invoke("Members") | Select-Object ([Array](@{n='ServerName';e={ $ComputerName }}) + $Select)

} | Export-Csv "C:\temp\Localadmin.csv" -NoTypeInformation