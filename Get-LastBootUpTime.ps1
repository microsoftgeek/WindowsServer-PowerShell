###------------------------------### ### Author : Biswajit Biswas-----######--MCC, MCSA, MCTS, CCNA, SME--###
###Email<bshwjt@gmail.com>-------###
###------------------------------######/////////..........\\\\\\\\\\\###
###///////////.....\\\\\\\\\\\\\\###
Function Get-LastBootUpTime { 
$ComputerName = Get-Content C:\temp\serverlist.txt 
$ErrorActionPreference = 'Stop' 
foreach ($Computer in $ComputerName) {     
    Try 
        { 
Get-CimInstance Win32_OperatingSystem -ComputerName $Computer | 
select  csname,LastBootUpTime | FT -AutoSize 
        } 
     
    Catch 
         { 
    Write-Warning "System is not reachable : $Computer" 
     
         } 
    }#End of Loop 
 
}#End of the Function 
Get-LastBootUpTime > C:\temp\Servers-LastBootUpTime1.txt