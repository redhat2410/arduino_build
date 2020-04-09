@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
set pathsource="C:\Users\admin\Desktop\arduino_build\header.conf"
set file=header.conf

for /f "delims=" %%x in (%file%) do (
    echo Line: %%x
)
