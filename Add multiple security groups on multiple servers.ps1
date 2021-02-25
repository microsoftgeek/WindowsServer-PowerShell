# This script will add multiple groups on multiple serevrs
# Make sure you have one server in each row in the servers text file
# you must have administrator access on the server

$ServersList = "D:\ServersList.txt"
$ServerNames = get-content $ServersList
$UserGroupFilePath = "D:\SecurityGroup.txt"
$UserGroupList = get-content $UserGroupFilePath
$DomainName ="Enter your domain name here"

foreach ($name in $ServerNames) 
    {
        $localAdminGroup = [ADSI]("WinNT://$name/Administrators")
        # Add all the groups in text file to the current server
        foreach ($UserGroupName in $UserGroupList)
            {
                $AdminsG = [ADSI] "WinNT://$DomainName/$UserGroupName"
                $localAdminGroup.Add($AdminsG.PSBase.Path)
                Write-Host "Adding" $AdminsG.PSBase.Path "to" $name
            } # End of User Group Loop
    } # End of Server List Loop