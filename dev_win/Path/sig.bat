@echo off
IF NOT EXIST %TOPATH%\utf8_bom GOTO end
@cp %1 sig___%1
IF NOT EXIST sig___%1 GOTO end
@cat %TOPATH%\utf8_bom sig___%1 > %1
IF NOT EXIST %1 GOTO end
@rm sig___%1
:end
