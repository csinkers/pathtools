@echo off
powershell -Command {Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted}
powershell -Command {Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted}
::pause

"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" .\build.ps1
::pause
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" .\install.ps1
::pause

.\usevim.bat
::pause

