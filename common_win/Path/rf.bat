@echo off
if exist shortcuts.exe goto scexists
for /F "usebackq tokens=*" %%i in (`dir /s /b *.exe ^| head -n1`) do "%%i" %*
goto :done
:scexists
runjob shortcuts.exe
:done
