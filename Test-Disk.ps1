<# 
 .Synopsis
  Script to test disk IO performance

 .Description
  This script tests disk IO performance by creating random files on the target disk and measuring IO performance
  It leaves 2 files in the WorkFolder:
    A log file that lists script progress, and
    a CSV file that has a record for each testing cycle

 .Parameter WorkFolder
  This is where the test and log files will be created. 
  Must be on a local drive. UNC paths are not supported.
  The script will create the folder if it does not exist
  The script will fail if it's run in a security context that cannot create files and folders in the WorkFolder
  Example: c:\support 
  
 .Parameter MaxSpaceToUseOnDisk
  Maximum Space To Use On Disk (in Bytes)
  Example: 10GB, or 115MB or 1234567890

 .Parameter Threads
  This is the maximum number of concurrent copy processes the script will spawn. 
  Maximum is 16. Default is 1. 

 .Parameter Cycles
  The script generates random files in a subfolder under the WorkFolder. 
  When the total WorkSubFolder size reaches 90% of MaxSpaceToUseOnDisk, the script deletes all test files and starts over.
  This is a cycle. Each cycle stats are recorded in the CVS and log files
  Default value is 3.

 .Parameter SmallestFile
  Order of magnitude of the smallest file.
  The script uses the following 9 orders of magnitude: (10KB,100KB,1MB,10MB,100MB,1GB,10GB,100GB,1TB) referred to as 0..8
  For example, SmallestFile value of 4 tells the script to use smallest file size of 100MB 
  The script uses a variable: LargestFile, it's selected to be one order of magnitude below MaxSpaceToUseOnDisk
  To see higher IOPS select a high SmallestFile value
  Default value is 4 (100MB). If the SmallestFile is too high, the script adjusts it to be one order of magnitude LargestFile

 .Example
   .\Test-Disk.ps1 "i:\support" 3GB
   This example tests the i: drive, generates files under i:\support, uses a maximum of 3GB disk space on i: drive.
   It runs a single thread, runs for 3 cycles, uses largest file = 100MB (1 order of magnitude below 3GB entered), smallest file = 10MB (1 order of magnitude below largest file)

 .Example
   .\Test-Disk.ps1 "i:\support" 11GB 8 5 4
   This example tests the i: drive, generates files under i:\support, uses a maximum of 11GB disk space on i: drive, uses a maximum of 8 threads, runs for 5 cycles, and uses SamllestFile 100MB.

 .Link
  https://superwidgets.wordpress.com/category/powershell/

 .Notes
  v1.0 - 07/23/2014 - Script leaves log file and CSV file in the WorkFolder

#>

#==============================================================================
# Script Name:    	Test-Disk.ps1
# DATE:           	07/23/2014
# Version:        	1.0
# COMMENT:			Script to test disk IO performance
#==============================================================================
#    
[CmdletBinding()]
param(
    [Parameter (Mandatory=$true,Position=1,HelpMessage="WorkFolder to run this test in, like c:\support: ")][String]$WorkFolder,
    [Parameter (Mandatory=$true,Position=2,HelpMessage="Maximum amount of disk space to use for this test: ")][Int64]$MaxSpaceToUseOnDisk,
    [Parameter (Mandatory=$false,Position=3)][Int32]$Threads = 1,
    [Parameter (Mandatory=$false,Position=4)][Int32]$Cycles = 3,
    [Parameter (Mandatory=$false,Position=5)][Int32]$SmallestFile = 4
)
#
# Log function
function Log {
    [CmdletBinding()]
    param(
        [Parameter (Mandatory=$true,Position=1,HelpMessage="String to be saved to log file and displayed to screen: ")][String]$String,
        [Parameter (Mandatory=$false,Position=2)][String]$Color = "White",
        [Parameter (Mandatory=$false,Position=3)][String]$Logfile = $myinvocation.mycommand.Name.Split(".")[0] + "_" + (Get-Date -format yyyyMMdd_hhmmsstt) + ".txt"
    )
    write-host $String -foregroundcolor $Color  
    ((Get-Date -format "yyyy.MM.dd hh:mm:ss tt") + ": " + $String) | out-file -Filepath $Logfile -append
}
#
function MakeSeed($SeedSize) { # Make Seed function
    $ValidSize = $false
    for ($i=0; $i -lt $Acceptable.Count; $i++) {if ($SeedSize -eq $Acceptable[$i]) {$ValidSize = $true; $Seed = $i}}
    if ($ValidSize) {
        $SeedName = "Seed" + $Strings[$Seed] + ".txt"
        if ($Acceptable[$Seed] -eq 10KB) { # Smallest seed starts from scratch
            $Duration = Measure-Command {
                do {Get-Random -Minimum 100000000 -Maximum 999999999 | out-file -Filepath $SeedName -append} while ((Get-Item $SeedName).length -lt $Acceptable[$Seed])
            }
        } else { # Each subsequent seed depends on the prior one
            $PriorSeed = "Seed" + $Strings[$Seed-1] + ".txt"
            if (!(Test-Path $PriorSeed)) {MakeSeed $Acceptable[$Seed-1]} # Recursive function :)
            $Duration = Measure-Command {
                $command = @'
                cmd.exe /C copy $PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed+$PriorSeed $SeedName /y
'@
                Invoke-Expression -Command:$command
                Get-Random -Minimum 100000000 -Maximum 999999999 | out-file -Filepath $SeedName -append
            }
        }
        log ("Created " + $Strings[$Seed] + " seed $SeedName file in " + $Duration.TotalSeconds + " seconds") Cyan $Logfile
    } else {
        log "Error: Seed value '$SeedSize' outside the acceptable values '$Strings'.. stopping" Yellow $Logfile; break
    }
}
#
$Acceptable = @(10KB,100KB,1MB,10MB,100MB,1GB,10GB,100GB,1TB)
$Strings = @("10KB","100KB","1MB","10MB","100MB","1GB","10GB","100GB","1TB")
$BlockSize = (Get-WmiObject -Class Win32_Volume | Where-Object {$_.DriveLetter -eq ($WorkFolder[0]+":")}).BlockSize
$logfile = (Get-Location).path + "\Busy_" + $env:COMPUTERNAME + (Get-Date -format yyyyMMdd_hhmmsstt) + ".txt"
if (!(Test-Path $WorkFolder)) {New-Item -ItemType directory -Path $WorkFolder | Out-Null}
if (!(Test-Path $WorkFolder)) {log "Error: WorkFolder $WorkFolder does not exist and unable to create it.. stopping" Magenta $logfile; break}
Set-Location $WorkFolder 
$logfile = $WorkFolder + "\Busy_" + $env:COMPUTERNAME + (Get-Date -format yyyyMMdd_hhmmsstt) + ".txt"
$WorkSubFolder = $WorkFolder + "\" + [string](Get-Random -Minimum 100000000 -Maximum 999999999) # Random name for work session subfolder
$CSV = "$WorkFolder \Busy_" + $env:COMPUTERNAME + (Get-Date -format yyyyMMdd_hhmmsstt) + ".csv"
if ( -not (Test-Path $CSV)) {
    write-output ("Cycle #,Duration (sec),Files (GB),# of Files,Avg. File (MB),Throughput (MB/s),IOPS (K) (" + '{0:N0}' -f ($BlockSize/1KB) + "KB blocks),Machine Name,Start Time,End Time") | 
        out-file -Filepath $CSV -append -encoding ASCII
}
#
# $LargestFile should be just below $MaxSpaceToUseOnDisk 
if ($MaxSpaceToUseOnDisk -lt $Acceptable[0]) {
    log "Error: MaxSpaceToUseOnDisk $MaxSpaceToUseOnDisk is less than the minimum seed size of 10KB. MaxSpaceToUseOnDisk must be more than 10KB" Yellow $logfile; break
} else {
    $LargestFile = '{0:N0}' -f ([Math]::Log10($MaxSpaceToUseOnDisk/10KB) - 1) # 1 order of magnitude below $MaxSpaceToUseOnDisk
}
if ($SmallestFile -gt $LargestFile-1) { $SmallestFile = $LargestFile-1 }
log ("WorkFolder = $WorkFolder, MaxSpaceToUseOnDisk = " + '{0:N0}' -f ($MaxSpaceToUseOnDisk/1GB) + "GB, Threads = $Threads, Cycles = $Cycles, SmallestFile = " + $Strings[$SmallestFile] + ", LargestFile = " + $Strings[$LargestFile]) Green $logfile
MakeSeed $Acceptable[$LargestFile] # Make seed files 
#
Get-Job | Remove-Job -Force # Remove any old jobs
Get-ChildItem -Path $WorkFolder -Directory | Remove-Item -Force -Recurse -Confirm:$false # Delete any old subfolders
New-Item -ItemType directory -Path $WorkSubFolder | Out-Null
$StartTime = Get-Date
$Cycle=0 # Cycle number
do {
    # Delete all test files when you reach 90% capacity in $WorkSubFolder
    $WorkFolderData = Get-ChildItem $WorkSubFolder | Measure-Object -property length -sum
    $FolderFiles = "{0:N0}" -f $WorkFolderData.Count
#    Write-Verbose ("WorkSubfolder $WorkSubFolder size " + '{0:N0}' -f ($WorkFolderData.Sum/1GB) + " GB, number of files = $FolderFiles")
    if ($WorkFolderData.Sum -gt $MaxSpaceToUseOnDisk*0.9) {
        $EndTime = Get-Date 
        do { # Wait for all jobs to finish before attempting to delete test files
            Get-Job -State Completed | Remove-Job # Remove completed jobs
            Start-Sleep 1
        } while ((Get-Job).Count -gt 0)
        Remove-Item $WorkSubFolder\* -Force 
        $CycleDuration = ($EndTime - $StartTime).TotalSeconds
        $Cycle++
        $CycleThru = ($WorkFolderData.Sum/$CycleDuration)/1MB # MB/s
        $IOPS = ($WorkFolderData.Sum/$CycleDuration)/$BlockSize
        log "Cycle #$Cycle stats:" Green $logfile
        log ("      Duration          " + "{0:N2}" -f $CycleDuration + " seconds") Green $logfile
        log ("      Files copied      " + "{0:N2}" -f ($WorkFolderData.Sum/1GB) + " GB") Green $Logfile
        log ("      Number of files   $FolderFiles") Green $Logfile
        log ("      Average file size " + "{0:N2}" -f (($WorkFolderData.Sum/1MB)/$FolderFiles) + " MB") Green $Logfile
        log ("      Throughput        " + "{0:N2}" -f $CycleThru + " MB/s") Yellow $Logfile
        log ("      IOPS              " + "{0:N2}" -f ($IOPS/1000) + , "k (" + "{0:N0}" -f ($BlockSize/1KB) + "KB block size)") Yellow $Logfile
        $CSVString = "$Cycle," + ("{0:N2}" -f $CycleDuration).replace(',','')  + "," + ("{0:N2}" -f ($WorkFolderData.Sum/1GB)).replace(',','')
        $CSVString += "," + $FolderFiles.replace(',','') + "," + ("{0:N2}" -f (($WorkFolderData.Sum/1MB)/$FolderFiles)).replace(',','')  + ","
        $CSVString += ("{0:N2}" -f $CycleThru).replace(',','') + "," + ("{0:N2}" -f ($IOPS/1000)).replace(',','')  + ","
        $CSVString += $env:COMPUTERNAME + "," + $StartTime + "," + $EndTime
        Write-Output $CSVString | out-file -Filepath $CSV -append -encoding ASCII
        $StartTime = Get-Date # Resetting $StartTime for next cycle
    } 
    if ((Get-Job).Count -lt $Threads+1) {
        Start-Job -ScriptBlock { param ($LargestFile,$WorkSubFolder,$Strings,$WorkFolder,$SmallestFile)
            $Seed2Copy = "Seed" + $Strings[(Get-Random -Minimum $SmallestFile -Maximum $LargestFile)] + ".txt" # Get a random seed
            $File2Copy =  $WorkSubFolder + "\" + [string](Get-Random -Minimum 100000000 -Maximum 999999999) + ".txt" # Get a random file name
            $Repeat = $Seed2Copy
            Set-Location $WorkFolder # Scriptblock runs at %HomeDrive%\%HomePath\Documents folder by default (like c:\users\samb\documents)
            for ($i=0; $i -lt (Get-Random -Minimum 0 -Maximum 9); $i++) {$Repeat += "+$Repeat"}
            $command = @'
            cmd.exe /C copy $Repeat $File2Copy /y
'@ 
            Invoke-Expression -Command:$command | Out-Null
            Get-Random -Minimum 100000000 -Maximum 999999999 | out-file -Filepath $File2Copy -append # Make all the files slightly different than each other
        } -ArgumentList $LargestFile,$WorkSubFolder,$Strings,$WorkFolder,$SmallestFile | Out-Null 
        Get-Job -State Completed | Remove-Job # Remove completed jobs
        Write-Verbose ("Current job count = " + (Get-Job).count) 
    }
    Get-Job -State Completed | Remove-Job # Remove completed jobs
    Write-Verbose ("Current Cycle = $Cycle, Cycles = $Cycles" )
} while ($Cycle -lt $Cycles)
log ("Testing completed successfully.") Green $logfile
If ($Error.Count -gt 0) {log "Errors occured: $Error" Magenta $logfile}