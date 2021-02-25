# Set the OU to use to store the disabled objects.
$DisabledObjectsOU = "OU=Disabled Computer Objects"

$Domain = Get-ADDomain

# Set how many days a machine should be inactive for before being disabled
# i.e. if you want the machine to be inactive for 90 days, set this to 90
$NumberOfDaysForDisable = 90

# Set the number of days a disabled object should be left before being deleted
# i.e. if you want the machine to be disabled for 90 days before deletion, set this to 90
$NumberOfDaysForDeletion = 90

# Get the date .
$DisableDate = (Get-Date).AddDays(0 - $NumberOfDaysForDisable)
$Today = Get-Date
[string]$StrToday = Get-Date -Format yyyyMMdd

# Set the log file location and name
$LogFile = "$env:USERPROFILE\Desktop\DisabledComputers$StrToday.txt"

# Add the log file headers for disabled objects
Add-Content $LogFile -Value "Moved and disabled objects not logged on since $DisableDate"
Add-Content $LogFile -Value "=================================================================="
Add-Content $LogFile -Value "Last logon date `t`tComputer Object"

# Filer out certain Operating Systems. Copy and paste new ones if required using the same format between the curly braces ({})
    Get-ADComputer -Filter {(OperatingSystem -NotLike "*Server*") -and (OperatingSystem -NotLike "OnTap") -and (OperatingSystem -NotLike "*Embedded*")} -Properties * -SearchBase $Domain | 
        Where-Object { $_.DistinguishedName -notlike "*$DisabledObjectsOU*" } |
        ForEach { 
            # Check the last logon date, if previous to the required number of days, update the description with the disabled date (reverse format)
            # Disable the object, move to the disabled computers OU and log the change.
            If( $_.LastLogonDate -lt $DisableDate ) { 
            
                $LastLogon = $_.LastLogonDate
                $Desc =  $_.Description
                $NewDesc = "$StrToday $Desc"
                Set-ADComputer $_ -Description $NewDesc -WhatIf
                Disable-ADAccount $_ -WhatIf
                Move-ADObject -Identity $_ -TargetPath "$DisabledObjectsOU,$Domain" -WhatIf
                Add-Content $LogFile -Value "$LastLogon `t$_"
            }
        }

# Add some spaces and headers for the deleted objects
Add-Content $LogFile -Value ""
Add-Content $LogFile -Value ""
Add-Content $LogFile -Value "Deleted Objects"
Add-Content $LogFile -Value "======================================="
Add-Content $LogFile -Value "Disabled Date`t`t`tComputer Object"

# Find all computers in the disabled computers OU
Get-ADComputer -Filter * -Properties * -SearchBase "$DisabledObjectsOU,$Domain" |
    ForEach {
        
        # Read the disabled date from the description and parse into a date format variable
        $DisabledDate = [datetime]::ParseExact($_.Description.Substring(0,8),'yyyyMMdd',$null)

        # Add the required number of days to the disabled date for deletion
        $DeleteDate = $DisabledDate.AddDays($NumberOfDaysForDeletion)

        # Check if todays date is greater than the deletion date.
        If($Today -ge $DeleteDate) {
            
            # If it is past the deletion date, delete the object and add to the log.
            Add-Content $LogFile -Value "$DisabledDate `t$_"
            Remove-ADObject -Identity $_.DistinguishedName -WhatIf
        } 
    }