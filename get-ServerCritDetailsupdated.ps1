Function get-ServerCritDetails

{
<#
.Synopsis
This function is used to create GUI  application to get server last reboot time,Last patch installed date and C drive free space for a single computer or multiple computers
.Description
This function is used to create GUI  application to get server last reboot time,Last patch installed date and C drive free space for a single computer or multiple computers
.Inputs
This Script creates a GUI application to get server last reboot time,Last patch installed date and C drive free space
.Example
get-ServerCritDetails
.Inputs
Kindly provide textfile path of server list.
.OUTPUTS
GridView

#>
#Requires -version 2.0
#Requires -runasadministrator
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms").location | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.drawing") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms.filedialog")
Add-Type -AssemblyName "System.windows.forms" | Out-Null


function Import-ServerFile 
    {
 
         $inputbox = New-Object System.Windows.Forms.OpenFileDialog
         $inputbox.ShowDialog()
         $inputbox.OpenFile()
         $forms.controls.add($Listbox)
         $serverlist = Get-Content -Path $inputbox.FileName
         foreach ($server in $serverlist)
                {
                 $Listbox.Items.Add($server)
                }
          $gsv.Enabled = $true
          $Listbox.Refresh()
          $Clear.Enabled = $true
          $ImportFile.Enabled = $false

    }
function Get-serverInfo
    {
         
         param($Serverlist)
         $Serverlist = $Listbox.SelectedItems
         $table = New-Object System.Data.DataTable "ServerUptime"
         $table.Columns.add("Servername")
         $table.Columns.add("Status")
         $table.Columns.add("Lastrestart")
         $table.Columns.add("CfreespaceinGB")
         $table.Columns.add("LastinstalledUpdate")
       
          $count=1    
         foreach ($server in $Serverlist)
                 {
                 Write-Progress -Activity "Gathering" -Status "In Progress: $count server" -PercentComplete ($count/$Serverlist.count*100)
                 try 
                 {
                 $row = $table.NewRow()
                 $cimsession = New-CimSession -ComputerName $server -ErrorAction Stop 
                 $serverdetails1 = Get-CimInstance -ClassName win32_operatingsystem -CimSession $cimsession  | Select-Object CSName,LastBootUpTime
                 $serverdetails2 = Get-CimInstance -ClassName win32_logicaldisk -CimSession $cimsession | Where {$_.drivetype -eq "3" -and $_.deviceid -like "C:" } | Select-Object @{l="Freespace";e={[math]::round($_.freespace/1GB)}}
                 $serverdetails3 = Get-CimInstance -ClassName Win32_QuickFixEngineering -CimSession $cimsession  | where {$_.installedon -gt ((get-date).addmonths(-4))} | Sort-Object Installedon -Descending | Select-Object -First 1
                 $row.servername = $serverdetails1.CSname
                 $row.Status = "Connected"
                 $row.Lastrestart = $serverdetails1.LastBootUpTime
                 $row.CfreespaceinGB = $serverdetails2.freespace
                 $row.LastinstalledUpdate = $serverdetails3.InstalledOn
                 
                 }
                 catch
                 {
                 $row = $table.NewRow()
                 $row.servername = $server
                 $row.Status = "NotConnected"
                 $row.Lastrestart = $null
                 $row.CfreespaceinGB = $null
                 $row.LastinstalledUpdate = $null
                 }
                 Finally
                 {
                 
                 $table.rows.Add($row)
                 $count++
                 }
                 }
         
         
         
         $table | Out-GridView
         $forms.controls.add($label)

      }
      

function Clear-listbox 
    {
    
    $messageboxtitle="Clear List box"
    $messageboxtitle="Are you sure to clear listbox Items"
    $result = [System.Windows.MessageBox]::Show($messageboxtitle,$messageboxtitle,"YesNO")
    if ($result -eq "Yes")
    {$itemcount = $Listbox.Items.Count
    if ($itemcount -gt 0) {$Listbox.Items.Clear()}
    $ImportFile.Enabled=$true
    $gsv.Enabled = $false
    $Clear.Enabled = $false
    }
    else
    {
    return 
    }
    }

    $ImportFile = New-Object System.Windows.Forms.Button
    $ImportFile.Location = New-Object System.Drawing.size(380,50)
    $ImportFile.Size = New-Object System.Drawing.size(80,20)
    $ImportFile.Text = "ImportFile"
    $ImportFile.add_click({Import-ServerFile})

    $GSV = New-Object System.Windows.Forms.Button
    $GSV.Location = New-Object System.Drawing.size(380,80)
    $GSV.Size = New-Object System.Drawing.size(80,20)
    $GSV.Text = "GetDeails"
    $GSV.add_click({Get-serverInfo})
    $gsv.Enabled = $false

    $Clear = New-Object System.Windows.Forms.Button
    $clear.Location = New-Object System.Drawing.size(380,110)
    $clear.Size = New-Object System.Drawing.size(80,20)
    $clear.Text = "Clear"
    $clear.add_click({Clear-listbox})
    $clear.Enabled = $false

    $global:Listbox = New-Object System.Windows.Forms.Listbox
    $Listbox.Location = New-Object System.Drawing.Size(90,100)
    $Listbox.size = New-Object System.Drawing.size(150,150)
    $Listbox.AutoSize = $true
    $Listbox.SelectionMode = "multiextended"
    $Listbox.ScrollAlwaysVisible = $true

    $Label = New-Object System.Windows.Forms.Label
    $Label.Location = New-Object System.Drawing.Size(5,5)
    $Label.Size = New-Object System.Drawing.size(375,90)
    $Label.Font = New-Object System.Drawing.Font("Times New Roman",15,[System.Drawing.FontStyle]::Italic)
    $Label.Text = "Servers from imported files will appear below in List box, you can select single,multiple or all servers from list box"


    $forms = New-Object System.Windows.Forms.Form
    $forms.Width = 500
    $forms.Height = 400
    $forms.Text = "Get-ServerCritDetails"
    $forms.AutoScale = $true

$forms.Controls.Add($Label)

$forms.Controls.Add($ImportFile)
 
$forms.Controls.Add($GSV)

$forms.Controls.Add($clear)

$forms.ShowDialog()


}

get-ServerCritDetails