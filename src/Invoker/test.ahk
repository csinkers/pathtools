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

RunViaInvoker("notepad")
