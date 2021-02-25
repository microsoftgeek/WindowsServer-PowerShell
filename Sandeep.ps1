#########################################

# This file contains the list of servers you want to copy files/folders to
$computers = gc "C:\temp\servers.txt"
 
# This is the file/folder(s) you want to copy to the servers in the $computer variable
$source = "C:\temp\bin\Collection.cmd"
 
# The destination location you want the file/folder(s) to be copied to
$destination = "C$\temp\"
 
#The command below pulls all the variables above and performs the file copy
foreach ($computer in $computers) {Copy-Item $source -Destination "\\$computers\$destination" -Recurse}


#########################################


# Point the script to the text file
$Computers = "C:\temp\servers.txt"

# sets the varible for the file location ei c:\temp\ThisFile.exe
$Source = "C:\temp\bin\Collection.cmd"

# sets the varible for the file destination
$Destination = "C$\temp\"


# displays the computer names on screen
Get-Content $Computers | foreach {Copy-Item $Source -Destination \\$computer\c$\$Destination}



########################################


## Unzip a file on a remote server ##

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "\\mn-hypentdev\c$\Users\a.t281937\Downloads\Oracle_Collection_Tool.zip" "\\mn-hypentdev\c$\Users\a.t281937\Downloads\Oracle_Collection_Tool"

######################################

$source='\\mnd-dist-app21\c$\temp\Oracle_Collection_Tool'
$destination='\\mn-essbasedev3\c$\temp'
Copy-Item -Recurse -Filter *.* -path $source -destination $destination -Force


###################################

Start-Transcript -path 'C:\Temp\scriptlog.txt'
$ServerList         = import-csv 'C:\temp\servers.csv'
$SourceFileLocation = 'C:\temp\Oracle_Collection_Tool'
$Destination        = 'C$\temp\Oracle_Collection_Tool'
 
foreach ($_ in $ServerList.computer){
    remove-item "\\$_\$Destination" -Recurse -Force -Verbose
    Copy-Item $SourceFileLocation -Destination "\\$_\$Destination" -Recurse -Verbose
}
Stop-Transcript