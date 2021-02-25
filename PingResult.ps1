$names = Get-content "C:\scripts\PingTest\Servers.txt"
$output = "C:\scripts\PingTest\PingResults.csv"

foreach ($name in $names){
  if (Test-Connection -ComputerName $name -Count 1 -ErrorAction SilentlyContinue){
    Add-Content $output "$name,up"
  }
  else{
    Add-Content $output "$name,down"
  }
}