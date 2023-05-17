/*
Build with:
    cl attach_windbg.cpp shlwapi.lib

*/

#include <windows.h> 
#include <stdio.h> 
#include <tchar.h> 
#include <shlwapi.h>
#include <strsafe.h>

DWORD GetPidFromCommandLine()
{
    TCHAR *pCmdLine = ::GetCommandLine(); 
    // skip the executable 
    if (*pCmdLine++ == L'"')
    {
    	while (*pCmdLine++ != L'"'); 
    }
    else 
    {
    	while (*pCmdLine != NULL && *pCmdLine != L' ') 
    		++pCmdLine; 
    }

    while (*pCmdLine == L' ')
    	pCmdLine++; 

    DWORD pid = (DWORD)_tstoi(pCmdLine);
    if (errno != 0)
    {
        _tprintf("Error parsing process id: %d\n", errno);
        return 0;
    }

    return pid;
}

bool GetWindbgPath(bool isWow64, TCHAR *szWindbgDir)
{
    TCHAR szCurDir[260];
    GetCurrentDirectory(sizeof(szCurDir) / sizeof(*szCurDir), szCurDir);

    const TCHAR *szRelative = isWow64
        ? _T("..\\..\\installed\\x86\\windbg.exe")
        : _T("..\\..\\installed\\x64\\windbg.exe");

    if (PathCombine(szWindbgDir, szCurDir, szRelative) == NULL)
    {
        _tprintf("Could not build windbg path\n");
        return false;
    }
    return true;
}

int _tmain() 
{ 
    DWORD pid = GetPidFromCommandLine();
    if (pid == 0)
        return -1;

    HANDLE hProcess = ::OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (hProcess == NULL)
    {
        _tprintf("Error opening process id %d: %d\n", pid, GetLastError());
        return -1;
    }

    BOOL isWow64;
    ::IsWow64Process(hProcess, &isWow64);
    CloseHandle(hProcess);

    TCHAR szCommand[512];
    if (!GetWindbgPath(isWow64, szCommand))
        return -1;

    StringCchCat(szCommand, sizeof(szCommand)/sizeof(*szCommand), _T(" -p "));
    TCHAR pidChars[10];
    _itot(pid, pidChars, 10);
    StringCchCat(szCommand, sizeof(szCommand)/sizeof(*szCommand), pidChars);

    _tprintf("%s\n", szCommand);

    STARTUPINFO si; 
    ZeroMemory( &si, sizeof(si) ); 
    si.cb = sizeof(si); 
    PROCESS_INFORMATION pi; 
    ZeroMemory( &pi, sizeof(pi) ); 

    // Start the child process. 
    BOOL result = CreateProcess 
    ( 
        NULL, // No module name (use command line) 
        szCommand, // Command line 
        NULL, // Process handle not inheritable 
        NULL, // Thread handle not inheritable 
        FALSE, // Set bInheritHandles to FALSE 
        DETACHED_PROCESS, // Detach process 
        NULL, // Use parent's environment block 
        NULL, // Use parent's starting directory 
        &si, // Pointer to STARTUPINFO structure 
        &pi // Pointer to PROCESS_INFORMATION structure (returned) 
    ); 
    if (result)
        return 0; 

    char msg[2048]; 
    FormatMessage 
    ( 
        FORMAT_MESSAGE_FROM_SYSTEM, 
        NULL, 
        ::GetLastError(), 
        MAKELANGID(LANG_NEUTRAL, SUBLANG_SYS_DEFAULT), 
        msg, sizeof(msg), 
        NULL 
    ); 
    fputs(msg, stderr); 
    _flushall(); 

    return -1; 
}
