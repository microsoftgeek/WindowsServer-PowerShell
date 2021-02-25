<#
Date:  January 23, 2017

Summary:  

This script can be used to do the following three things.

1.  Change the hostname of a computer.
2.  Join the computer to the domain.
3.  Put the computer account into the specified domain organizational unit (OU).

To run this script, open PowerShell ISE with an administrator account on the computer being renamed and joined to the domain, 
and edit the following variables:

1.  For the $NewHostName variable, specify the new name for the computer.

2.  For the $DomainToJoin variable, specify the domain to join.

3.  For the $OU variable, specify the domain OU where to put the computer account in AD.  Specify the OU by using
the distinguished name.

The script will prompt for the credentials of an account that has permissions to join computers to the domain, and then
the computer will be renamed, joined to the domain, and it will then be automatically restarted without prompting.

#> 

# Define the variables

# 1.  Specify the new computer name.
$NewHostName = "Server3"

# 2.  Specify the domain to join.
$DomainToJoin = "contoso.com"

# 3.  Specify the OU where to put the computer account in the domain.  Use the OU's distinguished name.
$OU = "OU=TestOU,DC=contoso,DC=com"


# Join the computer to the domain, rename it, and restart it.
Add-Computer -DomainName $DomainToJoin -OUPath $OU -NewName $NewHostName -Restart
 

