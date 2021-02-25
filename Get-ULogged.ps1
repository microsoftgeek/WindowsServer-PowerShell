<#
.Synopsis
   Get the details of who logged in to the server on certain days.
.DESCRIPTION
   The script provides the details of the users logged into the server at certain time interval and also queries remote servers to gather the details.
   The Script accepts 3 parameters -After -Before and -ComputerName
   
   About Parameters:
   -After, the date from which it starts to search. This Parameter is Mandatory.
   -Before, the date to which it searches, If you need to get today's logged in report then the next date should be entered.This Parameter is Mandatory.
   -ComputerName parameter is optional used for remote query.
.EXAMPLE
Get-ULogged -After 10/01/2016 -Before 10/22/2016 

User                                LoggedInAt            
----                                ----------            
User: RunServer01\Administrator 10/21/2016 12:35:18 PM
User: RunServer01\rdpadm        10/21/2016 12:35:09 PM
User: RunServer01\Administrator 10/21/2016 12:34:25 PM
User: RunServer01\Administrator 10/21/2016 12:23:46 PM
User: RunServer01\Administrator 10/21/2016 11:31:56 AM
User: RunServer01\Administrator 10/20/2016 11:56:06 AM
User: RunServer01\Administrator 10/19/2016 1:51:17 PM 
User: RunServer01\Administrator 10/18/2016 2:34:50 PM 
User: RunServer01\Administrator 10/18/2016 2:27:33 PM 
User: RunServer01\Administrator 10/18/2016 2:24:34 PM 

*********************LOCAL QUERY **********************

.EXAMPLE
Get-ULogged -After 10/01/2016 -Before 10/22/2016 -ComputerName 192.168.1.13

User                                LoggedInAt            
----                                ----------            
User: WIN-PKC8EGQFO9B\Administrator 10/21/2016 6:08:59 PM 
User: WIN-PKC8EGQFO9B\Administrator 10/21/2016 12:28:49 PM
User: WIN-PKC8EGQFO9B\Administrator 10/21/2016 12:19:41 PM

*********************REMOTE QUERY **********************

#>
function Get-ULogged
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$Before,

        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$After,

        # Param2 help description
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$ComputerName 
    )

    Begin
    {
        if($ComputerName -eq '')
        {
            $ComputerName = $env:COMPUTERNAME
        }
        $BeforeLog = (get-Date $Before)
        $AfterLog = (get-Date $After)

    }
    Process
    {
        try
        {
            $EventDataCollector = get-winevent -logname Microsoft-Windows-TerminalServices-LocalSessionManager/Operational -ComputerName $ComputerName  | where {$_.TimeCreated -gt $AfterLog -and $_.TimeCreated -lt $BeforeLog -and $_.Id -eq "21"}
            foreach($DataCollected in $EventDataCollector)
            {
            
                $UserLogged = $DataCollected.Message.Split([environment]::NewLine)
                $UserLogged = $UserLogged | select -First 5 |select -last 1

                $Props = @{'LoggedInAt' = $DataCollected.TimeCreated
                           'User' = $UserLogged}

                $Obj = New-Object -TypeName PSObject -Property $Props
                Write-Output $Obj        
        
            }
        }
        catch
        {
            Write-Output 'An Error had occured during the script execution. Please refer help section!
                To see the examples, type: "get-help Get-ULogged -examples".
                For more information, type: "get-help Get-ULogged -detailed".
                For technical information, type: "get-help Get-ULogged -full'

        }
    }
    End
    {

        #End

    }
}

#Get-ULogged
