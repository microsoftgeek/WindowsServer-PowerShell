@echo off
cls
echo.
echo.
echo *************************************************************************
echo Verifying that all services with StartType "Automatic" are started 
echo *************************************************************************
echo.
echo.
c:\windows\system32\windowspowershell\v1.0\powershell.exe -command "&{gwmi win32_service | where {$_.startmode -eq 'auto' -and $_.state -eq 'stopped'}} | start-service"
echo.
echo.
echo.
echo.
choice /C Y /N /M "Service Startup complete. exiting in 15 seconds..." /T 15 /D Y
