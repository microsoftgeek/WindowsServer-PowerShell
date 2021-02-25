Import-Module ActiveDirectory

# Create Data Table Structure
$DataTable = New-Object System.Data.DataTable
$DataTable.Columns.Add("ServerName","string") | Out-Null
$DataTable.Columns.Add("OperatingSystem","string") | Out-Null

# Get AD Server List
$Servers = Get-Content -Path C:\temp\JavaServers1.txt

# Set Progress Counters
[Int]$ServerCount = $Servers.Count
[Int]$ServerProgressCount = '0'

foreach ($Server in $Servers)
{
    # Write Progress
    $ServerProgressCount++
    Write-Progress -Activity "Inventorying Server" -Id 1 -Status "$($ServerProgressCount) / $($ServerCount)" -CurrentOperation "$($Server.DNSHostName)" -PercentComplete (($ServerProgressCount / $ServerCount) * 100)

    # Test Connection To Server
    Write-Host "Testing Connection to $($Server.DNSHostName)" -ForegroundColor White
    $TestConnection = Test-Connection -Count 2 -ComputerName $Server.DNSHostName -ErrorAction SilentlyContinue
    if (!($TestConnection))
    {
        Write-Host "Cannot contact $($Server.DNSHostName)" -ForegroundColor Red
        Continue
    }
    Write-Host "Successfully connected to $($Server.DNSHostName)" -ForegroundColor Green

    # Gather Installed Features from Server
    Write-Host "Gathering Installed Feature Data from $($Server.DNSHostName) Please wait.." -ForegroundColor White
    $Features = (Get-WindowsFeature -ComputerName $Server.DNSHostName | Where-Object Installed).Name

    # Check to see if the Data Table contains the feature and add a Column if needed
    foreach ($Feature in $Features)
    {
        if ($DataTable.Columns.ColumnName -notcontains $Feature)
        {
            $DataTable.Columns.Add("$Feature","string") | Out-Null
        }
    }

    # Create New Data Row
    $NewRow = $DataTable.NewRow()

    # Add Server Name & OS to Table Row
    $NewRow.ServerName = $($Server.DNSHostName)
    $NewRow.OperatingSystem = $($Server.OperatingSystem)

    # Loop through each role & feature and mark it with an X if present
    foreach ($Feature in $Features)
    {
        $ColumnName = ($DataTable.Columns | Where-Object ColumnName -eq $Feature).ColumnName
        $NewRow.$ColumnName = "X"
    }

    $DataTable.Rows.Add($NewRow)
}

# Export the results to CSV file
$CSVFileName = 'ServersListWithInstalledFeatures ' + $(Get-Date -f yyyy-MM-dd) + '.csv'
$DataTable | Export-Csv "$env:USERPROFILE\Documents\$CSVFileName" -NoTypeInformation