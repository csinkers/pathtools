$host.ui.rawui.BackgroundColor = "Black"
Set-PSReadLineKeyHandler Shift+Spacebar -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(" ") 
}
cls
