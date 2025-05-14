; BEGIN /colemak_win/Path/enhance.ahk
SetTitleMatchMode 2
#m::RunViaInvoker("""C:\Program Files\Mozilla Firefox\firefox.exe""")

::qwfp:: ; Macro to aid tagging code
SendInput CS{Space}
FormatTime, CurrentDate,, dd/MM/yyyy
SendInput %CurrentDate%{Space}
return

^+!/::SendInputU("203d") ;‽

EncodeInteger(p_value, p_size, p_address, p_offset)
{
   loop, %p_size%
      DllCall("RtlFillMemory"
         , "uint", p_address+p_offset+A_Index-1
         , "uint", 1
         , "uchar", (p_value >> (8*(A_Index-1))) & 0xFF)
}

SendInputU(p_text)
{
   StringLen, len, p_text

   INPUT_size = 28
   
   event_count := (len//4)*2
   VarSetCapacity(events, INPUT_size*event_count, 0)

   loop, % event_count//2
   {
      StringMid, code, p_text, (A_Index-1) * 4 + 1, 4
      
      base := ((A_Index-1) * 2) * INPUT_size + 4
         EncodeInteger(1, 4, &events, base-4)
         EncodeInteger("0x" code, 2, &events, base + 2)
         EncodeInteger(4, 4, &events, base + 4) ; KEYEVENTF_UNICODE

      base += INPUT_size
         EncodeInteger(1, 4, &events, base-4)
         EncodeInteger("0x" code, 2, &events, base + 2)
         EncodeInteger(2|4, 4, &events, base + 4) ; KEYEVENTF_KEYUP|KEYEVENTF_UNICODE
   }
   
   result := DllCall("SendInput", "uint", event_count, "uint", &events, "int", INPUT_size)
   if (ErrorLevel or result < event_count)
   {
      MsgBox, [SendInput] failed: EL = %ErrorLevel% ~ %result% of %event_count%
      return, false
   }
   
   return, true
}

!=::NumPadMult

CapsLock::
WinGetClass, TmpClass, A
WinGet, CurStyle, Style, A
WinGet, CurProc, ProcessName, A
if(TmpClass = "TscShellContainerClass" && (CurStyle & 0x00C00000 = 0) || CurProc = "RDCMan.exe") ; 0x00c00000 = WS_CAPTION
{
    return
}
Send {Backspace}
return

#IfWinActive, Microsoft Visual Studio
   ;=============================
   ;Process Go to next member/tag
   ;=============================
   $!S::
   Send, !{Down}
   return
   ;=================================
   ;Process Go to previous member/tag
   ;=================================
   $!T::
   Send, !{Up}
   return
   ;==========================
   ;Process Move Code Down
   ;==========================
   $^+!S::
   Send, ^+!{Down}
   return
   ;==========================
   ;Process Move Code Up
   ;==========================
   $^+!T::
   Send, ^+!{Up}
   return
   ;==========================
   ;Process Go to next usage
   ;==========================
   $+!S::
   Send, ^!{Down}
   return
   ;==========================
   ;Process Go to previous usage
   ;==========================
   $+!T::
   Send, ^!{Up}
   return
   ;==========================
   ;Process Generate Code
   ;==========================
   $!I::
   Send, !{Insert}
   return
#IfWinActive

; Gui, Add, Edit, x10 y10 w200 h600 vDebug
; Gui +AlwaysOnTop
; Gui, Show, x1400 y0 w220 h620, Debug Window
; Return
; 
; DebugAppend(Data)
; {
;     GuiControlGet, Debug
;     GuiControl,, Debug, %Debug%%Data%`r`n
; }
; 
; GuiClose:
;     Gui, Destroy
; Return
;

; END /colemak/Path/enhance.ahk
