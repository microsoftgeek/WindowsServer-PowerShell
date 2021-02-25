function Create-BootableUSBStick {
 
# .SYNOPSIS 
# Create-BootableUSBStick is an advanced PowerShell function to create a bootable USB stick for the installation of Windows OS.
 
# .DESCRIPTION 
# The main idea is to avoid the use of 3rd party tools or tools like the Windows 7 USB tool.
 
# .PARAMETER 
# USBDriveLetter
# Mandatory. Provide the drive letter where your usb is connected
 
# .PARAMETER 
# ImageFiles
# Mandatory. Enter the drive letter of your mounted ISO (OS Files)
 
# .EXAMPLE 
# Create-BootableUSBStick -USBDriveLetter F: -ImageFiles D:
 
# .NOTES 
# Author:Patrick Gruenauer 
# Web:https://sid-500.com 
 
[CmdletBinding()]
 
param
 
(
 
[Parameter()]
$USBDriveLetter,

[Parameter()]
$ImageFiles
 
)

$USBDriveLetterTrim=$USBDriveLetter.Trim(':')

Format-Volume -FileSystem NTFS -DriveLetter $USBDriveLetterTrim -Force

bootsect.exe /NT60 $USBDriveLetter

xcopy ($ImageFiles +'\') ($USBDriveLetter + '\') /e

Invoke-Item $USBDriveLetter

}