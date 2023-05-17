@echo off
set BatPath=%~dp0
:loop
set CurVar=%2
set FirstTwo=%CurVar:~0,2%
if x%2==x goto jump_out
if %FirstTwo% == -U set sql_user=%3
if %FirstTwo% == -P set sql_pass=%2
if %FirstTwo% == -S set sql_server=%3
if %FirstTwo% == -d set sql_db=%3
if %FirstTwo% == -i set sql_infile=%3
shift
goto loop

:jump_out
cp -f %BatPath%\ucs2le_bom c:\tmp\tmp_sql_in
attrib -R C:\tmp\tmp_sql_in
iconv --binary -f UTF-8 -t UCS-2LE %sql_infile% >>c:\tmp\tmp_sql_in
osql -w 65535 -r -b -n -U %sql_user% %sql_pass% -S %sql_server% -d %sql_db% -i c:\tmp\tmp_sql_in -o c:\tmp\tmp_sql_out 2>&1
iconv --binary -f UCS-2LE -t UTF-8 c:\tmp\tmp_sql_out >c:\tmp\tmp_sql_out2
FormatSqlResult.exe c:\tmp\tmp_sql_out2 c:\tmp\tmp_sql_out3
tail -c+4 c:\tmp\tmp_sql_out3
rm c:\tmp\tmp_sql_in c:\tmp\tmp_sql_out c:\tmp\tmp_sql_out2 c:\tmp\tmp_sql_out3 >NUL 2>NUL

