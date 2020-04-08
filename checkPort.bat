@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set /p port=Enter port name:
for /f "delims=" %%f in ('mode %port%') do (
    set status=%%f
)

set result=Illegal device name - %port%

if "!status!"=="%result%" ( 
    echo %port% invaild 
) else (
    echo %port% vaild
)