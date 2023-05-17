; BEGIN /chromevim/Path/enhance.ahk
#IfWinActive ahk_class Chrome_WidgetWin_1

LoggedSend(key)
{
    DebugAppend("  Send(" . key . ")")
    SendInput, %key%
}

global ActiveMode := "n"
global PendingOperator := ""

VimDispatch(key)
{
    DebugAppend("Vim(" . key . ", " . ActiveMode . ", " . PendingOperator . ")")

    WinGetTitle, tempTitle, A
;    DebugAppend(tempTitle)
;    DebugAppend(RegExMatch(tempTitle, "^Developer Tools - http"))
    if (RegExMatch(tempTitle, "^Developer Tools - http") = 0)
    {
        LoggedSend(key)
        Return
    }

    if (ActiveMode = "i") 
    {
        if(key = "{Esc}") 
        {
            ActiveMode := "n"
        }
        else 
        {
            LoggedSend(key)
        }
    }
    else if (ActiveMode = "s") ; Search mode
    {
        if(key = "{Esc}") 
        {
            LoggedSend("{Esc}")
            ActiveMode := "n"
        }
        if(key = "{Enter}") 
        {
            LoggedSend("{Esc}")
            ActiveMode := "n"
        }
        else 
        {
            LoggedSend(key)
        }
    }
    else if (ActiveMode = "n") ; Normal mode
    {
        if(key = "{Esc}") 
        {
            ; LoggedSend("{Esc}")
        }
        if(key = "``")
        {
            LoggedSend("{Esc}")
        }
        else if(key = "+g") 
        {
            LoggedSend("^{End}")
        }
        else if(key = "0") 
        {
            LoggedSend("{Home}")
        }
        else if(key = "$") 
        {
            LoggedSend("{End}")
        }
        else if(key = "u") 
        {
            LoggedSend("^z")
        }
        else if(key = "^r") 
        {
            LoggedSend("^+z")
        }
        else if(key = "s") 
        {
            LoggedSend("{Down}")
        }
        else if(key = "+s") 
        {
            LoggedSend("{Down}{Down}{Down}{Down}{Down}")
        }
        else if(key = "t") 
        {
            LoggedSend("{Up}")
        }
        else if(key = "+t") 
        {
            LoggedSend("{Up}{Up}{Up}{Up}{Up}")
        }
        else if(key = "^f") 
        {
            LoggedSend("{PgDn}")
        }
        else if(key = "^b") 
        {
            LoggedSend("{PgUp}")
        }
        else if(key = "{Space}") 
        {
            LoggedSend("{Right}")
        }
        else if(key = "{Backspace}") 
        {
            LoggedSend("{Left}")
        }
        else if(key = "w") 
        {
            LoggedSend("^{Right}")
        }
        else if(key = "b") 
        {
            LoggedSend("^{Left}")
        }
        else if(key = "{Enter}") 
        {
            LoggedSend("{Down}")
        }
        else if(key = "x") 
        {
            LoggedSend("{Delete}")
        }
        else if(key = "+x") 
        {
            LoggedSend("{Backspace}")
        }
        else if(key = "/") 
        {
            LoggedSend("^f")
            ActiveMode := "s"
        }
        else if(key = "n")
        {
            LoggedSend("^f{Enter}{Esc}")
        }
        else if(key = "+n")
        {
            LoggedSend("^f+{Enter}{Esc}")
        }
        else if(key = "a") 
        { 
            LoggedSend("{Right}")
            ActiveMode := "i"
        }
        else if (key = "+a") 
        {
            LoggedSend("{End}")
            ActiveMode := "i"
        }
        else if (key = "i") 
        {
            ActiveMode := "i" 
        }
        else if (key = "o")
        {
            LoggedSend("{End}{Enter}")
            ActiveMode := "i"
        }
        else if (key = "+o")
        {
            LoggedSend("{Home}{Home}{Enter}{Up}")
            ActiveMode := "i"
        }
        else if (key = "+i") 
        { 
            LoggedSend("{Home}")
            ActiveMode := "i"
        }
        else if (key = "p")
        {
            LoggedSend("^v")
        }
        else if (key = "+m")
        {
            WinGetPos, wx, wy, ww, wh, A
            cx := wx + (ww / 2)
            cy := wy + (wh / 2)
            MouseClick, Left, cx, cy
            LoggedSend("{Home}{Home}")
        }
        else if (key = "v" or key = "+v") 
        {
            ActiveMode := "v" 
        }
        else if (key = "g") 
        { 
            ActiveMode := "o"
            PendingOperator := "g"
        }
        else if (key = "c") 
        { 
            ActiveMode := "o"
            PendingOperator := "c"
        }
        else if (key = "d") 
        { 
            ActiveMode := "o"
            PendingOperator := "d"
        }
        else if (key = "z")
        {
            ActiveMode := "o"
            PendingOperator := "z"
        }
        else if (key = ">")
        {
            ActiveMode := "o"
            PendingOperator := ">"
        }
        else if (key = "<")
        {
            ActiveMode := "o"
            PendingOperator := "<"
        }
    }
    else if (ActiveMode = "o")
    {
        if(key = "{Esc}") 
        {
            ActiveMode := "n"
        }
        else if (PendingOperator = "g")
        {
            if(key = "g") 
            {
                LoggedSend("^{Home}")
                ActiveMode := "n"
            }
        }
        else if (PendingOperator = "c")
        {
            if(key = "b")
            {
                LoggedSend("^+{Left}{Backspace}")
                ActiveMode := "i"
            }
            else if(key = "w")
            {
                LoggedSend("^+{Right}{Backspace}")
                ActiveMode := "i"
            }
        }
        else if (PendingOperator = "d")
        {
            if(key = "b")
            {
                LoggedSend("^+{Left}{Backspace}")
            }
            else if(key = "w")
            {
                LoggedSend("^+{Right}{Backspace}")
            }
            else if(key = "d")
            {
                LoggedSend("+{Del}")
            }
            ActiveMode := "n"
        }
        else if (PendingOperator = "z")
        {
            if(key = "t")
            {
                ; Mouse scroll
                MouseGetPos, m_x, m_y
                SendMessage, 0x20A, -1000 << 16, ( m_y << 16 )|m_x,, A
                Sleep, 100
                LoggedSend("{Left}{Right}")
                ActiveMode := "n"
            }
            else if (key = "b")
            {
                ; Mouse scroll
                MouseGetPos, m_x, m_y
                SendMessage, 0x20A, 1000 << 16, ( m_y << 16 )|m_x,, A
                Sleep, 100
                LoggedSend("{Left}{Right}")
                ActiveMode := "n"
            }
            else if (key = "z")
            {
                ; Mouse scroll
                MouseGetPos, m_x, m_y
                SendMessage, 0x20A, -1000 << 16, ( m_y << 16 )|m_x,, A
                LoggedSend("{Left}{Right}")
                SendMessage, 0x20A, 400 << 16, ( m_y << 16 )|m_x,, A
                ActiveMode := "n"
            }
            else
            {
                ActiveMode := "n"
            }
        }
        else if (PendingOperator = "<")
        {
            if (key = "<")
            {
                LoggedSend("+{Tab}")
            }
            ActiveMode := "n"
        }
        else if (PendingOperator = ">")
        {
            if (key = ">")
            {
                LoggedSend("+{Home}{Tab}{Right}")
            }
            ActiveMode := "n"
        }
    }
    else if(ActiveMode = "v")
    {
        ; gg:LoggedSend("^+{Home}")
        if (key = "{Esc}") 
        {
            ActiveMode := "n"
        }
        else if (key = "y")
        {
            LoggedSend("^c{Esc}")
            ActiveMode := "n"
        }
        else if (key = "+g") 
        {
            LoggedSend("^+{End}")
        }
        else if (key = "0") 
        {
            LoggedSend("+{Home}")
        }
        else if (key = "$") 
        {
            LoggedSend("+{End}")
        }
        else if (key = "c") 
        {
            LoggedSend("{Del}")
            ActiveMode := "i"
        }
        else if (key = "d") 
        {
            LoggedSend("{Del}")
            ActiveMode := "n"
        }
        else if (key = "s") 
        {
            LoggedSend("+{Down}")
        }
        else if (key = "+s") 
        {
            LoggedSend("+{Down}+{Down}+{Down}+{Down}+{Down}")
        }
        else if (key = "t") 
        {
            LoggedSend("+{Up}")
        }
        else if (key = "w" or key = "+w")
        {
            LoggedSend("^+{Right}")
        }
        else if (key = "b" or key = "+b")
        {
            LoggedSend("^+{Left}")
        }
        else if (key = "+t") 
        {
            LoggedSend("+{Up}+{Up}+{Up}+{Up}+{Up}")
        }
        else if (key = "^f") 
        {
            LoggedSend("+{PgDn}")
        }
        else if (key = "^b") 
        {
            LoggedSend("+{PgUp}")
        }
        else if (key = "{Space}") 
        {
            LoggedSend("+{Right}")
        }
        else if (key = "{Backspace}") 
        {
            LoggedSend("+{Left}")
        }
        else if (key = "{Enter}") 
        {
            LoggedSend("+{Down}")
        }
    }
}

SC029:VimDispatch("``")
$:VimDispatch("$")
/:VimDispatch("/")
0:VimDispatch("0")
Backspace:VimDispatch("{Backspace}")
Enter:VimDispatch("{Enter}")
Esc:VimDispatch("{Esc}")
Space:VimDispatch("{Space}")
^b:VimDispatch("^b")
^f:VimDispatch("^f")
^r:VimDispatch("^r")
a:VimDispatch("a")
b:VimDispatch("b")
c:VimDispatch("c")
d:VimDispatch("d")
g:VimDispatch("g")
i:VimDispatch("i")
n:VimDispatch("n")
o:VimDispatch("o")
p:VimDispatch("p")
s:VimDispatch("s")
t:VimDispatch("t")
u:VimDispatch("u")
v:VimDispatch("v")
w:VimDispatch("w")
x:VimDispatch("x")
y:VimDispatch("y")
z:VimDispatch("z")
>:VimDispatch(">")
<:VimDispatch("<")
+a:VimDispatch("+a")
+b:VimDispatch("+b")
+g:VimDispatch("+g")
+i:VimDispatch("+i")
+m:VimDispatch("+m")
+n:VimDispatch("+n")
+o:VimDispatch("+o")
+s:VimDispatch("+s")
+t:VimDispatch("+t")
+v:VimDispatch("+v")
+w:VimDispatch("+w")
+x:VimDispatch("+x")

#IfWinActive
; END /chromevim/Path/enhance.ahk
