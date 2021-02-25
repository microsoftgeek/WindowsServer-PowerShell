<#
Date:  January 11, 2017

Summary:  

This script can be used to return the membership of a local group on a remote server.

For example, it can return the membership of the "Administrators" group or "Power Users"
group on a remote server.

To run this script, open it in PowerShell and edit the following variables:

1.  For the $Computer variable, define the remote computer to query.
2.  For the $Group variable, define the local group on the remote server for which to 
    return the group membership.
3.  Run the script as a user account that has administrator rights on the remote server.

The output will be displayed in the PowerShell console.
#> 

# Define the variables

# 1.  Server to query.
$Computer = "C:\temp\JDK-servers2.txt"

# 2.  Group on the server to display the members of. 
$Group = "Administrators"

# If localhost is being used as the remote server, then change it to the actual hostname.
If ($Computer -eq "localhost")
{
  $Computer = "$env:COMPUTERNAME"
}
Else
{
  $Computer = "$Computer"
}

# Connect to the server and get the group.
$GetGroupUser = Get-CimInstance -Class Win32_GroupUser -Filter "GroupComponent=""Win32_Group.Domain='$Computer',Name='$Group'""" -ComputerName $Computer

# Get the group membership.
$GetGroupUserPartComponent = $GetGroupUser.PartComponent

# Display the name of the server and group.
Write-Host "Server:  $Computer"
Write-Host "Group:  $Group"
Write-Host "Members:"

# Iterate through the group membership, and return the members. 
If ($GetGroupUserPartComponent -eq $Null)
{
  Write-Host "There are no members."
}
  Else
{
  Foreach ($Member in $GetGroupUserPartComponent)
  {
    $MemberDomain = $Member.Domain
    $MemberName = $Member.Name
    Write-Host "$MemberDomain\$MemberName"
  }
}