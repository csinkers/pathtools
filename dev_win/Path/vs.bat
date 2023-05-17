:: Allow devenv, spyxx etc 
::

if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" goto l9
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 8.1
goto end

:l9
if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" goto l8
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 8.1
goto end

:l8
if not exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" goto l7
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64 8.1
goto end

:l7
if not exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" goto l6
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat"
goto end

:l6
if not exist "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" goto l5
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat"
goto end

:l5
if not exist "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" goto l4
call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
goto end

:l4
if not exist "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" goto l3
call "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
goto end

:l3
if not exist "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" goto l2
call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
goto end

:l2
if not exist "C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\bin\vcvars32.bat" goto l1
call "C:\Program Files\Microsoft Visual Studio .NET 2003\Vc7\bin\vcvars32.bat"
goto end

:l1
if not exist "C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat" goto end
call "C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat" 
goto end

:end
cls

