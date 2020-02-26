echo off
setlocal enabledelayedexpansion
cls
title Windows Virtual Hotspot Setup Script -- Christian Arvin ^| naitsirhc.uriel@gmail.com
set "logd=%tmp%\virtual_net.log.txt
if exist "%logd%" del /f /q "%logd%"
call:banner
::check if hostednetwork is running
(netsh wlan show hostednetwork | findstr /i /r "Not" >nul 2>&1 ) && set "run=0" || set "run=1"
if {%run%} equ {1} (
	echo:A hostednetwork is already running.
	echo: ^>Shutting it down..
	(netsh wlan stop hostednetwork >nul 2>&1) && (echo: ^>Success^^!) || (echo: ^>Failed..&>nul 2>&1 timeout "5"&exit /b)
	echo.
	set /p ".=Do you still want to proceed in setting up a new hotspot? {yes} or {no}:"<nul &set /p "daum="
	if not "!daum!" equ "yes" (echo:exiting...&exit /b)
	call:banner
)
call:ssid ssid %~1
if not "%ssid%" equ "" (call:pass pass %~2) else echo: ^>Failed in creating a hotspot..&exit /b 1
if "%pass%" equ "" echo: ^>Failed in creating a hotspot..&exit /b 1
echo.
set /p ".=Creating wifi hotspot "%ssid%".." <nul &timeout /t "5" >nul &echo.
netsh wlan set hostednetwork mode=allow ssid=%ssid% key=%pass% >> %logd% && (
	echo: ^>virtual host %ssid% has been created^!&echo.
	set /p ".=Starting Virtual Hotspot "%ssid%".." <nul&timeout /t "5" >nul &echo.
	netsh wlan start hostednetwork >>%logd% && (echo: ^>successfully started %ssid%.) || (echo: ^>failed to start %ssid%.&notepad %logd%)
) || (echo: ^>failed in creating virtual host.&notepad %logd%)
>nul 2>&1 timeout /t "5"
echo:Exiting..
timeout  /t "10"
exit /b

:ssid <rtrnvar>
setlocal enabledelayedexpansion
set rtry=5
:rtry_ssid
if "%rtry%" lss "5" call:banner
if "%rtry%" lss "0" echo:Too many retries. &exit /b 1
set /p ".=Name/SSID:"<nul
if "%~2" neq "" (echo:^(Auto Setting^ - %~2^) &set "ssid=%~2" &>nul 2>&1 timeout "1") else (set /p "ssid=")
if "%ssid%" equ "" set /a "rtry-=1"&set /p ".=Empty Field is not allowed. Try Again.. %rtry% Attempt(s) Remaining."<nul&>nul 2>&1 timeout "2"&goto:rtry_ssid
(endlocal
	if "%ssid%" equ "" (set "%~1=") else (set "%~1=%ssid%")
)
exit /b

:pass <rtrnvar>
setlocal
set rtry=5
:rtry_pass
if "%rtry%" lss "5" call:banner
if "%rtry%" lss "0" echo:Too many retries. &exit /b 1
set /p ".=Passd/Key:"<nul
if "%~2" neq "" (echo:^(Auto Setting^ - %~2^) &set "pass=%~2" &>nul 2>&1 timeout "1") else (set /p "pass=")
if "%pass%" equ "" set /a "rtry-=1"&set /p ".=Empty Field is not allowed. Try Again.. %rtry% Attempt(s) Remaining."<nul&>nul 2>&1 timeout "2"&goto:rtry_pass
(endlocal
	if "%pass%" equ "" (set "%~1=") else (set "%~1=%pass%")
)
exit /b

:banner
setlocal
cls
echo:Hotspot Setup Script
echo:By: Christian Arvin
echo.
if not "%ssid%" equ "" echo:Name/SSID:%ssid%
if not "%pass%" equ "" echo:Passd/key:%pass%&echo.
exit /b