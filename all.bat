@echo off
powershell -Command {Set-ExecutionPolicy -ExecutionPolicy Unrestricted}
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" .\build.ps1
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" .\install.ps1
.\usevim.bat
