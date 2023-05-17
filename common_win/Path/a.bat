@echo off
doskey .=start . 
doskey .z=start . ^& exit
doskey d=dir /s /b $* 
doskey z=exit 
doskey v=gvim $*

SET PT=%~dp0..\..
:: Navigate to explorer window path
if %1x==x goto noparams
pushd "%1 %2 %3 %4 %5 %6 %7 %8 %9"
:noparams

