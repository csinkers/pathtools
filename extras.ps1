$ErrorActionPreference = "stop"
$webclient = New-Object System.Net.WebClient

$pathToolsDir = $PSScriptRoot
if ($pathToolsDir -eq "")  {
    $pathToolsDir = "C:\Depot\bb\pathtools"
}
$pathToolsDir = (Get-Item $pathToolsDir).FullName

if (!(Test-Path "$pathToolsDir\installed")) { mkdir "$pathToolsDir\installed" >$null }
$baseDir = (Get-Item "$pathToolsDir\installed").FullName

Class Product
{
    [String] $Name
    [String] $Url
    [String] $Path
    [Scriptblock] $Args
    Product(
        [String] $name,
        [String] $url,
        [String] $path){
        $this.Name = $name
        $this.Url = $url
        $this.Path = $path
        $this.Args = { param($extractionPath) "-y -o$($extractionPath)" }
    }
    Product(
        [String] $name,
        [String] $url,
        [String] $path,
        [Scriptblock] $args){
        $this.Name = $name
        $this.Url = $url
        $this.Path = $path
        $this.Args = $args
    }
}

$products = @{
    Python     = [Product]::new("Python 3.7.1",        "http://csinkers.com/python-3.7.1-amd64.exe",         "Python")
    AutoHotkey = [Product]::new("AutoHotkey",          "http://csinkers.com/AutoHotkey_1.1.30.01_setup.exe", "AutoHotkey")
    Vim        = [Product]::new("Vim 8.2",             "http://csinkers.com/vim82_x64.exe",                  "vim82")
    Debug32    = [Product]::new("DebugTools (32-bit)", "http://csinkers.com/dbg32.exe",                      "x86")
    Debug64    = [Product]::new("DebugTools (64-bit)", "http://csinkers.com/dbg64.exe",                      "x64")
    PerfTools  = [Product]::new("PerfTools",           "http://csinkers.com/WPT.exe",                        "WPT")
    PerfView   = [Product]::new("PerfView",            "http://csinkers.com/PerfView.exe",                   "..\local\Path")
    WindbgApp  = [Product]::new("Windbg Preview",      "http://csinkers.com/windbg_app.exe",                 "windbg_app")
}
$products.Python.Args = { param($extractionPath) "/Passive InstallAllUsers=1 PrependPath=1 TargetDir=$extractionPath" }
$products.AutoHotkey.Args = { param($extractionPath) "/S /D=$extractionPath" }

function Show-Menu {
    cls
    Write-Host "=========== Install Extras ==========="
    Write-Host "*) Install all"
    Write-Host "1) Vim 8.2"
    Write-Host "2) Python 3.7.1"
    Write-Host "3) AutoHotkey"
    Write-Host "4) DebugTools (32-bit)"
    Write-Host "5) DebugTools (64-bit)"
    Write-Host "6) PerfTools"
    Write-Host "7) PerfView"
    Write-Host "8) Windbg Preview"
    Write-Host "Q) Quit"
}

function Upgrade($product) {
    $extractionPath = "$baseDir\$($product.Path)"
    if ($extractionPath -eq $baseDir) { throw "Invalid product path" } 

    if ((Test-Path $extractionPath)) { Remove-Item -Recurse $extractionPath }
    mkdir $extractionPath >$null

    $fileName = $product.Url.Split('/')[-1]
    $installerPath = "$baseDir\$fileName"
    $installerArgs = &$product.Args $extractionPath
    $webclient.DownloadFile($product.Url, "$baseDir\$fileName")
    Invoke-Expression "& $installerPath $installerArgs | Out-Null"
    Remove-Item "$installerPath"
}

function Install-Python { Upgrade($products.Python) } 
function Install-AutoHotkey { Upgrade($products.AutoHotkey) } 
function Install-DebugTools32 { Upgrade($products.Debug32) } 
function Install-DebugTools64 { Upgrade($products.Debug64) } 
function Install-WindbgPreview { Upgrade($products.WindbgApp) }

<# Built via:
Run VS 64-bit tools, git clone the repo then navigate there.
git clone https://github.com/vim/vim
cd vim\src
open Make_mvc.mak, find "install.exe:", add $(DEBUGINFO) after the CFLAGS_INST assignment above it.
nmake -f Make_mvc.mak GUI=yes PYTHON3=C:\Depot\bb\pathtools\installed\Python DYNAMIC_PYTHON3=yes PYTHON3_VER=37
cd ..
mkdir vim82
xcopy /E /Y runtime vim82
copy /Y src\*.exe vim82
copy /Y src\*.pdb vim82
copy /Y src\tee\tee.exe vim82 
copy /Y src\xxd\xxd.exe vim82
mkdir vim82\GvimExt64
copy /Y src\GvimExt\gvimext.dll vim82\GvimExt64
# Run VS 32-bit tools...
cd vim\src
nmake -f Make_mvc.mak GUI=yes PYTHON3=C:\Depot\bb\pathtools\installed\Python DYNAMIC_PYTHON3=yes PYTHON3_VER=37
cd ..
mkdir vim82\GvimExt32
copy /Y src\GvimExt\gvimext.dll vim82\GvimExt32
# Download and add libintl & libiconv from gettext
# Select all in vim82 and add to 7-zip SFX as vim82_x64.exe
# Upload
#>

function Install-Vim {
# Download and install
    $extractionPath = "$baseDir\$($products.Vim.Path)"
    Upgrade($products.Vim)
    Invoke-Expression "$extractionPath\install.exe -install-popup -install-openwith -create-directories"

# Add context menu entry
    $vimPath = (Get-Item $extractionPath\gvim.exe).FullName
    if (!(Test-Path 'Registry::HKEY_CLASSES_ROOT\`*\Shell\Vim')) {
        New-Item -Path 'Registry::HKEY_CLASSES_ROOT\*\Shell\Vim' -Force | Out-Null
        New-Item -Path 'Registry::HKEY_CLASSES_ROOT\*\Shell\Vim\command' -Force | Out-Null
    }
    Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\`*\Shell\Vim' -Name '(Default)' -Value "Edit with &Vim"
    Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\`*\Shell\Vim' -Name 'Icon' -Value "`"$vimPath`""
    Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\`*\Shell\Vim\command' -Name '(Default)' -Value "`"$vimPath`" `"%1`""
}

function Install-PerfTools {
    Upgrade($products.PerfTools)
    $wpa = (Get-Item ($PSScriptRoot + "\installed\WPT\wpa.exe")).FullName
    cmd /c assoc .etl=wpa.etl_file
    cmd /c ftype wpa.etl_file="$wpa" "%1"
}

function Install-PerfView {
    $product = $products.PerfView
    $extractionPath = "$baseDir\$product.Path"
    if (!(Test-Path $extractionPath)) { mkdir $extractionPath >$null }
    $webclient.DownloadFile($product.Url, "$baseDir\$fileName")
}

function Install-All {
    if (!(Test-Path ".\installed\Vim")) { Install-Vim }
    if (!(Test-Path ".\installed\Python")) { Install-Python }
    if (!(Test-Path ".\installed\AutoHotkey")) { Install-AutoHotkey }
    if (!(Test-Path ".\installed\x86")) { Install-DebugTools32 }
    if (!(Test-Path ".\installed\x64")) { Install-DebugTools64 }
    if (!(Test-Path ".\installed\WPT")) { Install-PerfTools }
    if (!(Test-Path ".\local\Path\PerfView.exe")) { Install-PerfView }
    if (!(Test-Path ".\installed\windbg_app")) { Install-WindbgPreview }
}

do {
    Show-Menu
    $input = Read-Host "Select an option"
    switch($input) {
        '*'{ Install-All }
        '1'{ Install-Vim }
        '2'{ Install-Python }
        '3'{ Install-AutoHotkey }
        '4'{ Install-DebugTools32 }
        '5'{ Install-DebugTools64 }
        '6'{ Install-PerfTools }
        '7'{ Install-PerfView }
        '8'{ Install-WindbgPreview }
        'q'{ return }
    }
} until ($input -eq 'q')
