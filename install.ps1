$outputDir = (Get-Item out\Path).FullName

$oldPath = $env:PATH
# Update powershell dependencies with ngen:
$env:PATH = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
    $path = $_.Location
    if ($path) { 
        $name = Split-Path $path -Leaf
        Write-Host "`r`nRunning ngen.exe on '$name'"
        ngen.exe install $path /nologo
    }
}
$env:PATH = $oldPath

# Add output directory to the path
Function Add-PathDirectory {
    param([string]$pathToAdd)
    [Collections.Generic.List[String]]$pathComponents =
        (Get-ItemProperty `
            -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' `
            -Name Path `
        ).Path -split ';'

    if(!($pathComponents -contains $pathToAdd)) {
        $pathComponents.Add($pathToAdd)
        $newPath = [String]::Join(";", $pathComponents)

        Set-ItemProperty `
            -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' `
            -Name PATH `
            -Value $newPath
    }
}

Add-PathDirectory $outputDir
if (Test-Path "installed\Vim82") { Add-PathDirectory ((Get-Item "installed\Vim82").FullName) }
if (Test-Path "installed\WPT") { Add-PathDirectory ((Get-Item "installed\WPT").FullName) }

# Create backup dir for vim
$backupDir = $Env:USERPROFILE + "\backup"
if (!(Test-Path $backupDir)) { mkdir $backupDir >$null }

# Clear out %USERPROFILE%\vimfiles
$vimfilesPath = $Env:USERPROFILE + "\vimfiles"
if (Test-Path $vimfilesPath) {
    Get-ChildItem -Recurse $vimfilesPath |
    Foreach-Object {
        if (!($_ -is [System.IO.FileInfo])) { return }
        $pathToRemove = $_.Fullname
        if (!($pathToRemove.Contains("plugged"))) {
            Remove-Item $pathToRemove
        }
    }
}

# Copy Home\... to %USERPROFILE%
$outputDefaultsDir = (Get-Item out\UserDefaults).FullName

Get-ChildItem -Recurse $outputDefaultsDir |
Foreach-Object {
    if (!($_ -is [System.IO.FileInfo])) { return }
    $relativePath = $_.FullName -replace [regex]::Escape($outputDefaultsDir + "\")
    $newPath = "$Env:USERPROFILE\$relativePath"

    if (!(Test-Path $newPath)) {
        New-Item -ItemType File -Path $newPath -Force >$null
        Copy-Item -LiteralPath $_.FullName $newPath -Force
    }
}

$outputProfileDir = (Get-Item out\Home).FullName
Copy-Item -Force -Recurse $outputProfileDir\* $Env:USERPROFILE

# Put enhance shortcut in startup
$enhancePath = (Get-Item "out\Path\enhance.ahk").FullName
$startup="$Env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
if (Test-Path $enhancePath) {
    if(!(Test-Path $startup)) { mkdir $startup >$null }
    $WshShell = New-Object -comObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($startup + "\enhance.lnk")
    $shortcut.TargetPath = $enhancePath
    $shortcut.Save()

    $invokerPath = (Get-Item "out\Invoker.exe").FullName
    if (Test-Path $invokerPath) {
        $shortcut = $WshShell.CreateShortcut($startup + "\Invoker.lnk")
        $shortcut.TargetPath = $invokerPath
        $shortcut.Save()
    }
}

# Install vim plugins
$env:path
gvim.exe +PlugClean +PlugInstall +qall

# Install debugger plugins
if (Test-Path "installed\x86") {
    Get-ChildItem -Recurse "debug_plug\x86" |
    Foreach-Object {
        if (!($_ -is [System.IO.FileInfo])) { return }
        Copy-Item -Force -Recurse debug_plug\x86\* installed\x86
    }
}
if (Test-Path "installed\x64") {
    Get-ChildItem -Recurse "debug_plug\x64" |
    Foreach-Object {
        if (!($_ -is [System.IO.FileInfo])) { return }
        Copy-Item -Force -Recurse debug_plug\x64\* installed\x64
    }
}
if (Test-Path "installed\windbg_app\x86") {
    Get-ChildItem -Recurse "debug_plug\x86" |
    Foreach-Object {
        if (!($_ -is [System.IO.FileInfo])) { return }
        Copy-Item -Force -Recurse debug_plug\x86\* installed\windbg_app\x86
    }
}
if (Test-Path "installed\windbg_app\amd64") {
    Get-ChildItem -Recurse "debug_plug\x64" |
    Foreach-Object {
        if (!($_ -is [System.IO.FileInfo])) { return }
        Copy-Item -Force -Recurse debug_plug\x64\* installed\windbg_app\amd64
    }
}

# Set command prompt colour scheme
colemak_win\ColourTool.exe -b colemak_win\csinkers.ini

