@echo off

pushd ..
if exist personal-csinclair goto repofound

git clone https://shortcutssoftware@dev.azure.com/shortcutssoftware/Shortcuts/_git/personal-csinclair
goto repodone

:repofound
pushd personal-csinclair
git stash
git pull
git stash pop
popd

:repodone
popd

powershell -Command {Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted}
powershell -Command {Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted}
::pause

"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" .\build.ps1
::pause
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" .\install.ps1
::pause

.\usevim.bat
::pause

