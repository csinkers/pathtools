@echo off
:: Fixup powershell:
C:\Windows\SysWow64\cmd.exe /c powershell Set-ExecutionPolicy RemoteSigned
C:\Windows\System32\cmd.exe /c powershell Set-ExecutionPolicy RemoteSigned
ftype Microsoft.PowerShellScript.1="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "%%1"
git config --global merge.tool bc3
git config --global diff.tool bc3
git config --global difftool.bc3.trustexitcode true
git config --global mergetool.bc3.trustexitcode true
git config --global credential.helper manager
git config --global core.editor gvim

ftype vim="%PT%\installed\Vim\gvim.exe" "%%1"
ftype textfile="%PT%\installed\Vim\gvim.exe" "%%1"
assoc .ascx=vim
assoc .asm=vim
assoc .aspx=vim
assoc .c=vim
assoc .config=vim
assoc .cpp=vim
assoc .cs=vim
assoc .cshtml=vim
assoc .csproj=vim
assoc .css=vim
assoc .csv=vim
assoc .fs=vim
assoc .fsproj=vim
assoc .gradle=vim
assoc .h=vim
assoc .idl=vim
assoc .ini=vim
assoc .java=vim
assoc .js=vim
assoc .json=vim
assoc .log=vim
assoc .md=vim
assoc .py=vim
assoc .sql=vim
assoc .ts=vim
assoc .txt=textfile
assoc .vcproj=vim
assoc .vim=vim
assoc .xml=vim
assoc .yaml=vim
assoc .yml=vim

