@echo off
wevtutil im C:\Windows\Microsoft.NET\Framework\v4.0.30319\CLR-ETW.man
echo Press a key when ready to start...
pause
echo .
echo ...Capturing...
echo .

"%~dp0\..\..\installed\WPT\xperf.exe" -on PROC_THREAD+LOADER+PROFILE -stackwalk Profile -buffersize 1024 -MaxFile 2048 -FileMode Circular -f Kernel.etl
"%~dp0\..\..\installed\WPT\xperf.exe" -start ClrSession -on Microsoft-Windows-DotNETRuntime:0x8118:0x5:'stack'+763FD754-7086-4DFE-95EB-C01A46FAF4CA:0x4:0x5+Microsoft-Windows-DotNETRuntimePrivate:0xffffffff:0x5:'stack' -f clr.etl -buffersize 1024

echo Press a key when you want to stop...
pause
pause
echo .
echo ...Stopping...
echo .

"%~dp0\..\..\installed\WPT\xperf.exe" -start ClrRundownSession -on Microsoft-Windows-DotNETRuntime:0x8118:0x5:'stack'+Microsoft-Windows-DotNETRuntimeRundown:0x118:0x5:'stack' -f clr_DCend.etl -buffersize 1024 

timeout /t 15

set XPERF_CreateNGenPdbs=1

"%~dp0\..\..\installed\WPT\xperf.exe" -stop ClrSession ClrRundownSession 
"%~dp0\..\..\installed\WPT\xperf.exe" -stop
"%~dp0\..\..\installed\WPT\xperf.exe" -merge kernel.etl clr.etl clr_DCend.etl Result.etl -compress
del kernel.etl
del clr.etl
del clr_DCend.etl
