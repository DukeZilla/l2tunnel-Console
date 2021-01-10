echo off
break off
title l2tunnel Console
PUSHD "%CD%"
CD /D "%~dp0"
set back=%cd%
dir cache
if %errorlevel%==0 (
echo.
) ELSE (
md cache
)
cls
goto detect

:detect
dir | findstr l2tunnel.exe
if %errorlevel%==0 (
cls
color 0a
echo.
echo l2tunnel.exe found.
echo.
echo.
echo This is mainly for people who are just getting started with l2tunnel.
echo.
echo.
echo.
echo 	l2tunnel software description:
echo.
echo This is a simple utility to tunnel link-layer traffic from a device accessible through a local network interface
echo to a remote host via UDP to enable a basic VLAN.
echo.
echo The intended use case for this utility is to enable game consoles which support LAN network play (e.g. Xbox^)
echo to play on the Internet by creating a virtual LAN. To the console, it will appear as if other consoles are connected on the LAN.
echo.
echo Instructions will also be provied.
echo Select the help option for help.
echo.
echo.
echo.
pause
goto main
) ELSE (
cls
color 0c
echo 						===ERROR===
echo.
echo.
echo l2tunnel.exe not detected.
echo.
echo Make sure the console and the exe files are in the same directory.
echo Or configured in environment variables.
echo.
echo If you don't have l2tunnel installed, head over too:
echo.
echo https://github.com/mborgerson/l2tunnel
echo.
echo.
pause
exit
)

:main
cd %back%
cls
echo.
echo	     _____   __                         __   ______                       __   
echo	    / /__ \ / /___  ______  ____  ___  / /  / ____/___  ____  _________  / /__ 
echo	   / /__/ // __/ / / / __ \/ __ \/ _ \/ /  / /   / __ \/ __ \/ ___/ __ \/ / _ \
echo	  / // __// /_/ /_/ / / / / / / /  __/ /  / /___/ /_/ / / / (__  ) /_/ / /  __/
echo	 /_//____/\__/\__,_/_/ /_/_/ /_/\___/_/   \____/\____/_/ /_/____/\____/_/\___/                                                                             
echo.
echo. 
echo.
echo - 1. Start Tunnel
echo.
echo - 2. Configure
echo.
echo - 3. Check Configurations
echo.
echo - 4. Command Prompt
echo.
echo - 5. Help
echo.
echo - 6. Exit
echo.
echo.
set /p mchoice=Select Number: 
if %mchoice%==1 goto Start
if %mchoice%==2 goto config
if %mchoice%==3 goto check
if %mchoice%==4 cls & echo When finished, type "goto main" to return to main menu. & echo. & dir & echo. & goto cmd
if %mchoice%==5 start l2tunnel-kai-help-guide/Guide.html & goto main
if %mchoice%==6 exit
goto errorselect

:config
cd %back%
cls
echo.
echo.
echo 						===Config===
echo.
echo.
echo Adapters:
echo.
l2tunnel.exe list
l2tunnel.exe list > cache/l2t-list.txt
echo.
echo.
echo Enter Device number below.
echo.
echo A test will be initiated to check if it's the correct one.
echo.
echo.
set /p number=Number: 
cd cache
type l2t-list.txt | findstr /c:"device %number%" > device.txt
for /f "tokens=1-9 delims= " %%g in ( device.txt ) do ( echo %%i > device.txt )
cls
echo.
type device.txt
echo.
echo Device selected.
echo.
timeout 1 > nul
echo.
echo ------------------------------
echo Performing test...
echo.
echo.
echo If mac addresses show up, that means that you found the right adapter.
echo.
echo If not, then select another device.
echo.
echo Press CTRL+C, then type N when done.
echo.
timeout 3 > nul
echo Discovery process started.
echo.
cd ..
for /f "tokens=* delims= " %%g in ( cache/device.txt ) do ( l2tunnel.exe discover %%g )
cls
echo.
echo.
echo Discover process stopped.
timeout 1 > nul
echo.
echo.
echo ----------------------------
echo Adapter settings correct?
echo.
echo.
echo 1. Yes, continue.
echo.
echo 2. No, reconfigure.
echo.
echo.
set /p mchoice=Select Number: 
if %mchoice%==1 goto mac
if %mchoice%==2 goto config
goto errorselect

:mac
for /f "tokens=* delims= " %%g in ( cache/device.txt ) do ( set device=%%g )
cls
echo.
echo.
echo ------------------------
echo ===Mac Configure===
echo.
echo.
echo Enter Mac address of the machine.
echo.
set /p mac=Mac: 
echo %mac%
echo.
echo Mac okay?
echo.
echo.
set /p mchoice=Type (Y/N): 
if %mchoice%==y goto IpPort
if %mchoice%==n goto mac
if %mchoice%==Y goto IpPort
if %mchoice%==N goto mac
goto errorselectmac

:IpPort
echo.
echo.
echo -------------------------
echo ===Rhost LHost Port Config===
echo.
set /p rhost=RHOST: 
echo %rhost%
echo.
set /p rport=PORT: 
echo %rport%
echo.
set /p lhost=LHOST:
echo %lhost%
echo.
set /p lport=PORT:
echo %lport%
echo.
echo.
echo Settings okay?
set /p mchoice=Type (Y/N): 
if %mchoice%==y goto makecfg
if %mchoice%==n goto IpPort
if %mchoice%==Y goto makecfg
if %mchoice%==N goto IpPort
goto errorselectipport

:makecfg
cd %back%
echo.
echo.
echo Saving configuration details to "Settings.cfg".
echo.
( echo set device=%device%
  echo set mac=%mac%
  echo set rhost=%rhost%
  echo set rport=%rport%
  echo set lhost=%lhost%
  echo set lport=%lport% ) > Settings.cfg
echo.
echo Saved.
timeout 1 > nul
goto check

:Check
cls
type Settings.cfg >nul 2>&1
if %errorlevel%==0 (
echo Configuration Settings:
echo.
echo.
for /f "tokens=1-9 delims= " %%g in ( Settings.cfg ) do ( echo %%h %%i %%j %%k )
echo.
pause 
goto main
) ELSE (
color 0e
echo.
echo ERROR
echo.
echo Settings.cfg not found
echo.
timeout 5
cls
color 0a
goto main
)

:Start
cls
type Settings.cfg >nul 2>&1
if %errorlevel%==0 (
cls
echo.
goto command
) ELSE (
color 0e
echo.
echo ERROR
echo.
echo Appears that you haven't configured your settings yet.
echo.
echo Configure and then start tunnel.
echo.
pause
cls
color 0a
goto main
)

:command
echo.
echo.
echo =========================
echo     l2tunnel Tunnel
echo.
echo.
echo Select command operation:
echo.
echo 1. -d Fowards any packets sent from a source to machine.
echo.
echo 2. -s Fowards machine's packets to a destination.
echo.
echo 3. Return to main menu
echo.
echo.
echo (-d recommended^)
echo.
set /p mchoice=Select Number: 
if %mchoice%==1 goto startD
if %mchoice%==2 goto startS
if %mchoice%==3 goto main
goto errorselect

:startD
cls
for /f "delims=" %%a in ( Settings.cfg ) do %%a
echo.
echo Starting...
echo.
echo Press CTRL+C, then type N when done.
echo.
echo l2tunnel.exe tunnel "%device%" -d %mac% %lhost% %lport% %rhost% %rport%
echo.
l2tunnel.exe tunnel "%device%" -d %mac% %lhost% %lport% %rhost% %rport%
echo.
pause
goto main

:startS
cls
for /f "delims=" %%a in ( Settings.cfg ) do %%a
echo.
echo Starting...
echo.
echo Press CTRL+C, then type N when done.
echo.
echo l2tunnel.exe tunnel "%device%" -s %mac% %lhost% %lport% %rhost% %rport%
echo.
l2tunnel.exe tunnel "%device%" -s %mac% %lhost% %lport% %rhost% %rport%
echo.
pause
goto main

::Command prompt
:cmd
set /p cmd="%cd%>"
%cmd%
echo.
GOTO cmd

:errorselectmac
cls
color 0c
echo.
echo.
echo.
echo ------------------------------
echo ERROR.
echo.
echo.
echo Wrong selection.
echo.
timeout 5
cls
color 0a
goto mac

:errorselectipport
cls
color 0c
echo.
echo.
echo.
echo ------------------------------
echo ERROR.
echo.
echo.
echo Wrong selection.
echo.
timeout 5
cls
color 0a
goto IpPort

:errorselect
cls
color 0c
echo.
echo.
echo.
echo ------------------------------
echo ERROR.
echo.
echo.
echo Wrong selection.
echo.
timeout 5
cls
color 0a
goto main



::Jesus is Lord!
::Accept him before it's too late, rapture is near...
::Repent.