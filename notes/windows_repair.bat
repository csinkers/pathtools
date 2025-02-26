dism.exe /online /Cleanup-Image /CheckHealth
dism.exe /online /Cleanup-Image /ScanHealth
dism.exe /online /Cleanup-Image /RestoreHealth
sfc /scannow
dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
dism.exe /Online /Cleanup-Image /StartComponentCleanup
chkdsk /f /r

