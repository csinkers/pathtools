; BEGIN /common_win/Path/enhance.ahk
; -- Enhance.ahk --
; AutoHotKey script mostly written by Cam Sinclair (c) 2008
; Requires AutoHotKey to be installed
; A large section was adapted from the NiftyWindows script (http://www.enovatic.org)
; and hence this script is also under the GNU GPL

; Hotkey legend: #=windows key, !=Alt, ^=Ctrl, +=Shift

#SingleInstance force ; Don't want two running and conflicting
SetWorkingDir %A_ScriptDir%
if not A_IsAdmin
Run *RunAs "%A_ScriptFullPath%"

Process, Priority, , HIGH ; Make sure our scripts are responsive
SetBatchLines, -1

SetKeyDelay, 0, 0
SetMouseDelay, 0
SetDefaultMouseSpeed, 0
SetWinDelay, 0
SetControlDelay, 0

;global ActiveMode := "n"
;global PendingOperator := ""
;

DebugAppend(Data)
{
    Return
}

;Gui, Add, Edit, x10 y10 w200 h600 vDebug
;Gui +AlwaysOnTop
;Gui, Show, x2300 y0 w220 h620, Debug Window
;Return
;
;DebugAppend(Data)
;{
;    GuiControlGet, Debug
;    GuiControl,, Debug, %Data%`r`n%Debug%
;}

GuiClose:
    Gui, Destroy
    Return

!Insert::Reload
!Backspace::Suspend

RunViaInvoker(command)
{
    invokerId := 0
    DetectHiddenWindows, On
    WinGet, handleList, list, ahk_exe Invoker.exe ; get all hwnds

    Loop, %handleList%
    {
        curHandle := handleList%A_Index%
        WinGetTitle, tmpTitle, ahk_id %curHandle%
        If (tmpTitle = "Invoker")
            invokerId := curHandle
    }

    If (invokerId = 0)
    {
        Run, %command%
        return
    }

    static WM_COPYDATA := 0x4A
    VarSetCapacity(CopyData, 3 * A_PtrSize, 0)

    cbData := (StrLen(command) + 1) * (A_IsUnicode ? 2 : 1)
    NumPut(A_IsUnicode ? 2 : 1, CopyData, 0, UPtr)
    NumPut(cbData,              CopyData, A_PtrSize, UInt)
    NumPut(&command,            CopyData, 2 * A_PtrSize, Ptr)

    SendMessage, WM_COPYDATA, 0, &CopyData,, ahk_id %invokerId%
}

#\::
    MouseGetPos, , , tempWin, tempControl
    WinGet, tempPid, Pid, ahk_id %tempWin%
    WinGet, tempProcName, ProcessName, ahk_id %tempWin%
    WinGetClass, tempClass, ahk_id %tempWin%
    WinGetTitle, tempTitle, ahk_id %tempWin%

    MsgBox, 4, %tempProcName%, PID: %tempPid%`nTitle: %tempTitle%`nClass: %tempClass%`nControl: %tempControl%`n`nAttach windbg?
    IfMsgBox, Yes
        Run %A_ScriptDir%\attach_windbg %tempPid%

    Return

; Set up some constants for handling window management on two monitors
SysGet, Mon1, Monitor, 1
SysGet, Mon2, Monitor, 2
Mon2W = % Mon2Right-Mon2Left
Mon2H = % Mon2Bottom-Mon2Top
SysGet, VirtW, 78
SysGet, VirtH, 79
Return

#IfWinNotActive, ahk_class "VMUIView" ahk_class "VMUIFrame"

ShouldIgnoreWindow(wclass, procName)
{

    if (wclass = "Progman")
        return 1
    if (wclass = "OpWindow")
        return 1
    if (wclass = "Calculator")
        return 1
    if (wclass = "ATL:ExplorerFrame")
        return 1
    if (wclass = "VMUIView")
        return 1
    if (wclass = "VMUIFrame")
        return 1
    if (wclass = "MKSEmbedded")
        return 1
    if (wclass = "TSSHELLWND")
        return 1
    if (wclass = "OPContainerClass")
        return 1
    if (wclass = "TscShellContainerClass")
        return 1
    if (wclass = "UIContainerClass")
        return 1
    if (wclass = "ATL:ScrapFrame")
        return 1
    if (wclass = "SDL_app" and procName != "Repos.exe")
        return 1
    if (procName = "RDCMan.exe")
        return 1
    return 0
}

; Big wodge of code to get RMB drag to be useful. Resizes/moves windows. (Adapted from NiftyWindows)
; ---------------- BEGIN CODE ADAPTED FROM NiftyWindows ----------------
RButton::
    Critical
    DebugAppend("Begin Down")
    NWD_ResizeGrids = 5
    CoordMode, Mouse, Screen

    MouseGetPos, NWD_LastMouseX, NWD_LastMouseY, NWD_WinID
    If (NWD_Dragging != 1)
    {
        NWD_MouseStartX := NWD_LastMouseX
        NWD_MouseStartY := NWD_LastMouseY
        DebugAppend("MouseStart: " . NWD_MouseStartX . ", " . NWD_MouseStartY)
    }

    If (!NWD_WinID)
    {
        DebugAppend("End Down: No window")
        Return
    }

    WinGetPos, NWD_WinStartX, NWD_WinStartY, NWD_WinStartW, NWD_WinStartH, ahk_id %NWD_WinID%
    WinGet, NWD_WinMinMax, MinMax, ahk_id %NWD_WinID%
    WinGet, NWD_WinStyle, Style, ahk_id %NWD_WinID%
    WinGet, NWD_Proc, ProcessName, ahk_id %NWD_WinID%
    WinGetClass, NWD_WinClass, ahk_id %NWD_WinID%

    NWD_IgnoreWindow := ShouldIgnoreWindow(NWD_WinClass, NWD_Proc)
    NWD_Dragging := (NWD_IgnoreWindow != 1) and (NWD_WinMinMax != 1)
    DebugAppend("Dragging := " . NWD_Dragging)

    If (NWD_WinStyle & 0x40000) ; window has a sizing border (WS_THICKFRAME)
    {
        NWD_GridLength := NWD_WinStartW / NWD_ResizeGrids
        NWD_PastFirstGrid := NWD_LastMouseX >= (NWD_WinStartX + NWD_GridLength)
        NWD_BeforeLastGrid := NWD_LastMouseX <= (NWD_WinStartX + (NWD_ResizeGrids - 1) * NWD_GridLength)

        If (NWD_PastFirstGrid and NWD_BeforeLastGrid)
            NWD_ResizeX = 0
        Else
            If (NWD_LastMouseX > NWD_WinStartX + NWD_WinStartW / 2)
                NWD_ResizeX := 1
            Else
                NWD_ResizeX := -1

        NWD_GridLength := NWD_WinStartH / NWD_ResizeGrids
        NWD_PastFirstGrid := NWD_LastMouseY >= (NWD_WinStartY + NWD_GridLength)
        NWD_BeforeLastGrid := NWD_LastMouseY <= (NWD_WinStartY + (NWD_ResizeGrids - 1) * NWD_GridLength)

        If (NWD_PastFirstGrid and NWD_BeforeLastGrid)
            NWD_ResizeY = 0
        Else
            If (NWD_LastMouseY > NWD_WinStartY + NWD_WinStartH / 2)
                NWD_ResizeY := 1
            Else
                NWD_ResizeY := -1
    }
    Else
    {
        NWD_ResizeX = 0
        NWD_ResizeY = 0
    }

    ; TODO : this is a workaround (checks for popup window) for the activation
    ; bug of AutoHotkey -> can be removed as soon as the known bug is fixed
    If (!((NWD_WinStyle & 0x80000000) and !(NWD_WinStyle & 0x4C0000)))
        IfWinNotActive, ahk_id %NWD_WinID%
            WinActivate, ahk_id %NWD_WinID%

    If (NWD_IgnoreWindow)
        MouseClick, RIGHT, %NWD_MouseStartX%, %NWD_MouseStartY%, , , D
    Else
        SetTimer, NWD_WindowHandler, 10

    DebugAppend("End Down")
    Return

RButton Up::
    Critical
    DebugAppend("Begin Up")
    CoordMode, Mouse, Screen
    SetTimer, NWD_WindowHandler, Off
    MouseGetPos, NWD_MouseX, NWD_MouseY

    DebugAppend("RButton Up @ " . NWD_MouseX . ", " . NWD_MouseY)
    If (NWD_IgnoreWindow)
        MouseClick, RIGHT, %NWD_MouseX%, %NWD_MouseY%, , , U
    Else If (!NWD_Dragging or ((NWD_MouseStartX = NWD_MouseX) and (NWD_MouseStartY = NWD_MouseY)))
        MouseClick, Right

    NWD_Dragging = 0
    DebugAppend("End Up")
    return

NWD_WindowHandler:
    SetWinDelay, -1
    CoordMode, Mouse, Screen
    MouseGetPos, NWD_MouseX, NWD_MouseY
    WinGetPos, NWD_WinX, NWD_WinY, NWD_WinW, NWD_WinH, ahk_id %NWD_WinID%

    If (!GetKeyState("RButton", "P"))
    {
        SetTimer, NWD_WindowHandler, Off
        Return
    }

    NWD_MouseDeltaX := NWD_MouseX - NWD_LastMouseX
    NWD_MouseDeltaY := NWD_MouseY - NWD_LastMouseY

    If ((NWD_MouseDeltaX or NWD_MouseDeltaY) and NWD_Dragging)
    {
        If (!NWD_ResizeX and !NWD_ResizeY) ; Move
        {
            NWD_WinNewX := NWD_WinStartX + NWD_MouseDeltaX
            NWD_WinNewY := NWD_WinStartY + NWD_MouseDeltaY
            NWD_WinNewW := NWD_WinStartW
            NWD_WinNewH := NWD_WinStartH
        }
        Else
        {
            NWD_WinDeltaW = 0
            NWD_WinDeltaH = 0
            If (NWD_ResizeX)
                NWD_WinDeltaW := NWD_ResizeX * NWD_MouseDeltaX
            If (NWD_ResizeY)
                NWD_WinDeltaH := NWD_ResizeY * NWD_MouseDeltaY

            NWD_WinNewW := NWD_WinStartW + NWD_WinDeltaW
            NWD_WinNewH := NWD_WinStartH + NWD_WinDeltaH

            If (NWD_WinNewW < 0)
                NWD_WinNewW := 0
            If (NWD_WinNewH < 0)
                NWD_WinNewH := 0

            NWD_WinDeltaX = 0
            NWD_WinDeltaY = 0
            If (NWD_ResizeX = -1)
                NWD_WinDeltaX := NWD_WinStartW - NWD_WinNewW
            If (NWD_ResizeY = -1)
                NWD_WinDeltaY := NWD_WinStartH - NWD_WinNewH
            NWD_WinNewX := NWD_WinStartX + NWD_WinDeltaX
            NWD_WinNewY := NWD_WinStartY + NWD_WinDeltaY
        }

        Transform, NWD_WinNewX, Round, %NWD_WinNewX%, 0
        Transform, NWD_WinNewY, Round, %NWD_WinNewY%, 0
        Transform, NWD_WinNewW, Round, %NWD_WinNewW%, 0
        Transform, NWD_WinNewH, Round, %NWD_WinNewH%, 0

        If ((NWD_WinNewX != NWD_WinX) or (NWD_WinNewY != NWD_WinY) or (NWD_WinNewW != NWD_WinW) or (NWD_WinNewH != NWD_WinH))
            WinMove, ahk_id %NWD_WinID%, , %NWD_WinNewX%, %NWD_WinNewY%, %NWD_WinNewW%, %NWD_WinNewH%
    }
    Return
;
; ---------------- END CODE ADAPTED FROM NiftyWindows ----------------

; Toggle the title bar of a window
; #Space: WinSet, Style, ^0xC00000, A

; Hotkeys for a bunch of commonly used programs
#s::RunViaInvoker("ssms") ; SQL Server Management Studio
#g::Run super_rename.exe
#q::Run regedit
#x::Run services.msc
#SC029::Run procexp

; ::colquery::select CAST(TABLE_NAME as VARCHAR(30)) as [Table], CAST(COLUMN_NAME as varchar(40)) as [Column], CAST(DATA_TYPE as VARCHAR(20)) as [DataType], CHARACTER_MAXIMUM_LENGTH from information_schema.columns

MinimiseClick() ; Override left side button. Navigate back in vis studio and beyond compare. Otherwise minimize prog
{
    MouseGetPos, , , tempWin
    WinGetClass, tempClass, ahk_id %tempWin%
    WinGetTitle, tempTitle, ahk_id %tempWin%
    WinGet, tempProc, ProcessName, ahk_id %tempWin%

    DebugAppend(tempClass)
    DebugAppend(GetKeyState("LWin", "P"))
    DebugAppend(tempProc)

    if(ShouldIgnoreWindow(tempClass, tempProc) and !GetKeyState("LWin", "P"))
    {
        Click X1
        return
    }

    if(tempClass == "TViewForm.UnicodeClass") ; Beyond Compare
    {
        Click X1
        return
    }

    IfInString, tempTitle, VMWare ; VMWare
    {
        Click X1
        return
    }

    if(tempClass == "TSSHELLWND") ; mstsc / rdp client
    {
        Click X1
        return
    }

    WinMinimize, ahk_id %tempWin%
    return
}

CloseClick() ; Override right side button. Navigate forward in vis studio and beyond compare. Close program clicked otherwise
{
    MouseGetPos, , , tempWin
    WinGetClass, tempClass, ahk_id %tempWin%
    WinGetTitle, tempTitle, ahk_id %tempWin%
    WinGet, tempProc, ProcessName, ahk_id %tempWin%

    DebugAppend(tempClass)
    DebugAppend(GetKeyState("LWin", "P"))

    if(ShouldIgnoreWindow(tempClass, tempProc) and !GetKeyState("LWin", "P"))
    {
        Click X2
        return
    }

    if(tempClass == "wndclass_desked_gsk")
    {
        IfInString, tempTitle, Visual
        {
            Send ^i ; Must have Ctrl-I set to navigate forward in visual studio
            return
        }
    }

    if(tempClass == "TViewForm.UnicodeClass") ; Beyond Compare
    {
        Click X2
        return
    }

    IfInString, tempTitle, VMWare
    {
        Click X2
        return
    }

    if(tempClass == "TSSHELLWND") ; mstsc / rdp client
    {
        Click X2
        return
    }

    WinClose, ahk_id %tempWin%
    return
}

$XButton1::
    DebugAppend("$XButton1")
    MinimiseClick()
return

!XButton1::
    DebugAppend("!XButton1")
    MinimiseClick() ; Don't let lingering alt state from alt-tabbing mess with the side buttons
return

+XButton1:: ; Force-minimise
    DebugAppend("+XButton1")
    MouseGetPos, , , tempWin
    WinMinimize, ahk_id %tempWin%
return

$XButton2::
    DebugAppend("$XButton2")
    CloseClick()
    return
!XButton2::
    DebugAppend("!XButton2")
    CloseClick() ; Don't let lingering alt state from alt-tabbing mess with the side buttons
    return
+XButton2:: ; Force-close
    DebugAppend("+XButton2")
    MouseGetPos, , , tempWin
    WinClose, ahk_id %tempWin%
return

#a:: ; Run gvim
    Sleep 200
    RunViaInvoker("gvim.exe")
    ;WinSet, Style, ^0xC00000, A
    ;WinMove, A, , 0, 0, A_ScreenWidth/2, A_ScreenHeight
return

#f::WinSet, AlwaysOnTop, Toggle, A

#d::
IfWinExist Calculator
    WinActivate Calculator
else
    RunViaInvoker("C:\Windows\System32\calc")
return

; For setting windows to left/right half of widescreen monitor
#,::WinMove, A, , 0, 0, A_ScreenWidth/2, A_ScreenHeight
#.::WinMove, A, , A_ScreenWidth/2, 0, A_ScreenWidth/2, A_ScreenHeight
#/::WinMove, A, , %Mon2Left%, %Mon2Top%, %Mon2W%, %Mon2H%
#'::WinMove, A, , %Mon1Left%, %Mon1Top%, %VirtW%, %VirtH%
return

#c::MouseMove, 0, 0 ; Gets mouse cursor to top left corner of focused window, handy for moving it out of the way when using keyboard only

; Powershell overrides for console hotkeys that need old-style readline.
#IfWinActive ahk_exe powershell.exe
    ^W::SendInput ^{Backspace}
    ^X::SendInput {Home}^{Right}^{Backspace}

ShouldHandleCmd()
{
    WinGetTitle, TmpTitle, A
    IfInString, TmpTitle, cmd.exe
    {
        return 1
    }
    return 0
}

; Windows Terminal
#IfWinActive ahk_class CASCADIA_HOSTING_WINDOW_CLASS
    ^D::
        SendInput +{Home}{Backspace}exit{Enter}
        return
    ^W::
        SendInput ^+{Left}{Backspace}
        return
    ^U::
        SendInput +{Home}{Backspace}
        return
    ^Z::
        SendInput {Esc}cd ..{Enter}
        return
#IfWinActive

; A whole bunch of hotkeys that make the windows command shell a lot nicer
#IfWinActive ahk_class ConsoleWindowClass
    ; Scroll a page up/down
    +PgUp::
        if(ShouldHandleCmd())
        {
            SendInput !{Space}el{PgUp}{Esc}
        }
        return
    +PgDn::
        if(ShouldHandleCmd())
        {
            SendInput !{Space}el{PgDn}{Esc}
        }
        return
    ^B::
        if(ShouldHandleCmd())
        {
            SendInput !{Space}el{PgUp}{Esc}
        }
        return
    ^F::
        if(ShouldHandleCmd())
        {
            SendInput !{Space}el{PgDn}{Esc}
        }
        return

    ^A::
        if(ShouldHandleCmd())
        {
            SendInput {Home}
        }
        return
    ; Open the output of something on the cmdline with gvim
    ^D::
        if(ShouldHandleCmd())
        {
            SendInput z{Enter}
        }
        return
    ^E::
        if(ShouldHandleCmd())
        {
            SendInput {End}
        }
        return
    ; find something in the cmdline buffer
    ^/::
        if(ShouldHandleCmd())
        {
            SendInput !{Space}ef
        }
        return
    ; build a fe "whatever" @grep -isHI
    ^K::
        if(ShouldHandleCmd())
        {
            SendInput | findstr /rinf:/{Space}
        }
        return
    ; Clear screen
    ^L::
        if(ShouldHandleCmd())
        {
            SendInput {Esc}cls{Enter}
        }
        return
    ; xargs substitute
    ^N::
        if(ShouldHandleCmd())
        {
            SendInput {End} | putclip && fe getclip @
        }
        return
    ; Back a word
    ^Q::
        if(ShouldHandleCmd())
        {
            SendInput ^{Left}
        }
        return
    ^R::
        if(ShouldHandleCmd())
        {
            SendInput {End}
        }
        return
    ; Clear until character (like dt in vim)
    ;^S::SendInput +{F4}
    ; Grab some text from the buffer
    ; ^T::SendInput !{Space}ek
    ; Clear line
    ^U::
        if(ShouldHandleCmd())
        {
            Send, ^{End}^{Home}
        }
        return
    ; Paste from the clipboard
    ^V::
        if(ShouldHandleCmd())
        {
            SendInput !{Space}ep
        }
        return
    ; Delete a the word before the cursor
    ^W::
        if(ShouldHandleCmd())
        {
            SendInput ^{Left}+{F4}{Space}{Delete}
        }
        return
    ; Delete the first word on the current cmdline
    ^X::
        if(ShouldHandleCmd())
        {
            SendInput {Home}+{F4}{Space}
        }
        return
    ^Z::
        if(ShouldHandleCmd())
        {
            SendInput {Esc}cd ..{Enter}
        }
        return
    !B::
        if(ShouldHandleCmd())
        {
            SendInput ^{Left}
        }
        return
    !F::
        if(ShouldHandleCmd())
        {
            SendInput ^{Right}
        }
        return
    ::cs ~::cd %USERPROFILE%
#IfWinActive

#IfWinActive ahk_class PuTTY
    ^Z::SendInput ^ucd ..{Enter}
#IfWinActive

GetActiveExplorerTab(hwnd:="") {
    static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"

    activeTab := 0, hwnd := hwnd ? hwnd : WinExist("A")
    try
        ControlGet, activeTab, Hwnd,, ShellTabWindowClass1, ahk_id %hwnd%   ; File Explorer (Windows 11)
    catch
    try
        ControlGet, activeTab, Hwnd,, TabWindowClass1, ahk_id %hwnd%    ; IE
    for w in ComObjCreate("Shell.Application").Windows {
        if (w.hwnd != hwnd)
            continue
        if (activeTab) { ; The window has tabs, so make sure this is the right one.
            shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
            DllCall(NumGet(NumGet(shellBrowser+0), 3*A_PtrSize), "UPtr",shellBrowser, "UIntP",thisTab:=0)
            if (thisTab != activeTab)
                continue
        }
        return w
    }
}

GetActiveExplorerPath() {
    WinGetClass, TmpClass, A
    TmpPath = "C:\"
    if(TmpClass = "CabinetWClass")
    {
        tab := GetActiveExplorerTab()
        switch ComObjType(tab.Document, "Class")
        {
            case "ShellFolderView":
                TmpPath := tab.Document.Folder.Self.Path
            default: ;case "HTMLDocument":
                TmpPath := % tab.LocationURL
        }
    }
    return TmpPath
}

#Return::
    WinGetClass, TmpClass, A
    TmpPath := GetActiveExplorerPath()
    Run powershell -NoExit -Command "& {Set-Location %TmpPath%}"
return

#z:: ; Open command prompt. If an explorer window has focus, open in same dir.
    Sleep 200
    TmpPath := GetActiveExplorerPath()
    Run cmd /k a.bat "%TmpPath%"
return

#+z:: ; Open admin command prompt
    Sleep 200
    TmpPath := GetActiveExplorerPath()
    Run *RunAs "cmd.exe" /k a.bat "%TmpPath%"
return

#1::Run C:\ ; Open some common directories
#2::Run D:\ ; Open some common directories

#IfWinActive ahk_class CabinetWClass ; Windows Explorer
    ^U::Send !{Up}
    ^L::Send !{Right}
    ^H::Send !{Left}
    ^F::Send {PgDn}
    ^B::Send {PgUp}
    ^R::Send {F5}
    +Space::
        ControlFocus, DirectUIHWND3, A
        SendInput, {Space}
        return
#IfWinActive

#IfWinActive ahk_class AcrobatSDIWindow ; Acrobat Reader
    s::Send {Down}
    t::Send {Up}
    +s::Send {Down 10}
    +t::Send {Up 10}
    ^f::Send {PgDn}
    ^b::Send {PgUp}
    /::Send ^f
#IfWinActive

#IfWinActive ahk_class MozillaWindowClass ; firefox
    ^F::Send, {Space}
    ^B::Send, +{Space}
#IfWinActive

#Insert::
    Send ^{Insert}
    Run TestResultDiff.exe
    Return

!Pause::Suspend
; END /common_win/Path/enhance.ahk
