; BEGIN /dev_win/Path/enhance.ahk
#v::
    if FileExist("C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe")
        Run "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
    else if FileExist("C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe")
        Run "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"
    else if FileExist("C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe")
        Run "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\IDE\devenv.exe"
    else if FileExist("C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe")
        Run "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe"
    else if FileExist("C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe")
        Run "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"
    else if FileExist("C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe")
        Run "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
    Return

#8::
    Run "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv.exe"
    Return

#w::
    if FileExist("C:\Program Files\Beyond Compare 4\BCompare.exe")
        RunViaInvoker("""C:\Program Files\Beyond Compare 4\BCompare.exe""")
    else if FileExist("C:\Program Files (x86)\Beyond Compare 3\BCompare.exe")
        RunViaInvoker("""C:\Program Files (x86)\Beyond Compare 3\BCompare.exe""")
    Return
::select 8::select *
::s8::select * from 

^K::
    WinGetClass, tempClass, A
    if InStr(tempClass, "WinDbg") or InStr(tempClass, "DbgX.Shell")
        Send "{Home}.shell -ci "{End} findstr /i{Space}
    else Send ^K
    return

#-::Run %A_ScriptDir%\..\..\installed\x86\windbg.exe
#+-::Run %A_ScriptDir%\..\..\installed\x86\windbg.exe -remote tcp:port=9191
#=::Run %A_ScriptDir%\..\..\installed\x64\windbg.exe
#+=::Run %A_ScriptDir%\..\..\installed\x64\windbg.exe -remote tcp:port=9191
#Backspace::Run %A_ScriptDir%\..\..\installed\windbg_app\DbgX.Shell
#0::Run PerfView.exe
; END /dev_win/Path/enhance.ahk
