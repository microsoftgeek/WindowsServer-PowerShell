Write-Output "$HR CDI Server Creation Date Script

##########################################################################################
#
#                  *CDI Server Creation Date Script* 
#                                                                                
# Created by Cesar Duran (Jedi Master)                                                                                        
# Version:1.0                                                                                                                                        
#                                                                                                                                                                                                                                                                                                                                                                                                                      
#                                                                                                                                                                                                          
###########################################################################################

$HR"

# CDI Server Creation Date Script

# Line delimiter
$HR = "`n{0}`n" -f ('='*20)


#############################################
Write-Output "$HR PWSHELL FETCH ME DATA $HR"
# Gettng server names and creation date

$servers = Get-ADComputer -Filter {operatingsystem -like '*server*'} -Properties Name,Operatingsystem,OperatingSystemVersion,IPv4Address,created | Export-Csv C:\temp\ServerCreationDateReport\CDIservers.csv


######################################
Write-Output "$HR 30 SECOND PAUSE $HR"
# 90sec Pause

$Timeout = 30
$timer = [Diagnostics.Stopwatch]::StartNew()
while (($timer.Elapsed.TotalSeconds -lt $Timeout)) {
Start-Sleep -Seconds 1
    Write-Verbose -Message "Still waiting for action to complete after [$totalSecs] seconds..."
}
$timer.Stop()
# End of 30 seconds



########################################
Write-Output "$HR SEND EMAIL TO MARTY $HR"
# Send email report

Send-MailMessage -to “cduran@cdirad.com” -from “SystemEngineers@cdirad.com” -subject “Monthly Server Creation Date Report” -Attachment “C:\temp\ServerCreationDateReport\CDIservers.csv” -SmtpServer “mail.cdirad.com”


###################################################
Write-Output "$HR THE END, HAVE A NICE DAY!!!

##########################################################################################
#
#              *POWERFUL YOU HAVE BECOME, THE DARK SIDE I SENSE IN YOU - YODA*
#
#                                                                                                                                                                                                                                                                                                                                                                                                                              
#                                                                                                                                                                                                          
###########################################################################################

$HR"