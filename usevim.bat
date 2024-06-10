@echo off

for /f "delims=" %%a in ('gnutools\Path\which.exe gvim') do @echo set VimPath="%%a"
for /f "delims=" %%a in ('gnutools\Path\which.exe gvim') do @echo setx VimPath "%%a"
for /f "delims=" %%a in ('gnutools\Path\which.exe gvim') do @set VimPath="%%a"
for /f "delims=" %%a in ('gnutools\Path\which.exe gvim') do @setx VimPath "%%a"

:: Fixup powershell:
ftype Microsoft.PowerShellScript.1="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" "%%1"
:: git config --global diff.tool bc
git config --global merge.tool bc
git config --global difftool.bc.path "c:/Program Files/Beyond Compare 4/bcomp.exe"
git config --global mergetool.bc.path "c:/Program Files/Beyond Compare 4/bcomp.exe"
git config --global credential.helper manager
git config --global core.editor gvim
git config --global difftool.prompt false

ftype vim=%VIMPATH% "%%1"
ftype textfile=%VIMPATH% "%%1"
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

