@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set _pathPathFileConf="C:\Users\admin\Desktop\arduino_build\path.conf"


if not exist %_pathPathFileConf% (
    ::hỏi đường dẫn Arduino
    set /P _pathArduino=Enter the path Arduino:
    if exist %_pathArduino% (
        echo %_pathArduino%>%_pathPathFileConf%
        goto :DEFINE_PATH
    ) else (
        goto :UNSUCCESS
    )
) else (
    for /F "delims=" %%f in ('Type "%_pathPathFileConf%"') do (
        set _pathArduino=%%f
    )
)

:DEFINE_PATH
:: Macro path file
set _pathCore=!_pathArduino!\hardware\arduino\avr\cores\arduino
set _pathTools=!_pathArduino!\hardware\tools\avr\bin
set _pathVariant=!_pathArduino!\hardware\arduino\avr\variants\standard
set _pathLibrary=!_pathArduino!\hardware\arduino\avr\libraries
set _pathConf=!_pathArduino!\hardware\tools\avr/etc/avrdude.conf

if exist !_pathCore! ( echo !_pathCore! is exist ) else ( echo !_pathCore! is not exist )
if exist !_pathTools! ( echo !_pathTools! is exist ) else ( echo !_pathTools! is not exist )
if exist !_pathVariant! ( echo !_pathVariant! is exist ) else ( echo !_pathVariant! is not exist )
if exist !_pathLibrary! ( echo !_pathLibrary! is exist ) else ( echo !_pathLibrary! is not exist )
if exist !_pathConf! ( echo !_pathConf! is exist ) else ( echo !_pathConf! is not exist )

goto :eof

:UNSUCCESS
echo Build UnSuccessfull
goto :eof