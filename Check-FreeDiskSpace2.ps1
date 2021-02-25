### Getting Windows Server Disk Space

function getDiskFreeSpace

{

Get-WmiObject Win32_Volume -computername $args -filter “drivetype = 3” |

Select-Object _SERVER, Name, @{Name=”Size(GB)”;Expression={“{0:N1}” -f($.Capacity/1gb)}},@{Name=”FreeSpace(GB)”;Expression={“{0:N1}” -f($_.freespace/1gb)}},@{Name=”FreeSpacePerCent”;Expression={“{0:P0}” -f($_.freespace/$_.capacity)}} |

Where-Object -FilterScript {$_.FreeSpacePerCent -lt 95} |

Sort-Object -property “FreeSpacePerCent” |

Format-Table

}

ForEach($s in Get-Content c:\Temp\serverlist.txt)

{

getDiskFreeSpace $s | Out-file c:\Temp\diskFreeSpaceResults.txt -append

}

Send-MailMessage -to “cduran@company.com” -from “cduran@company.com” -subject “Servers Disk Free Space Report” -Attachment “C:\Temp\diskFreeSpaceResults.txt” -SmtpServer “RelayServer001.company.net”

Clear-Content c:\Temp\diskFreeSpaceResults.txt