@echo off 
SETLOCAL ENABLEDELAYEDEXPANSION

:: Organization folder
:: Create folder library Core 
set _pathCurrent=%cd%
set _pathBuildCore=%_pathCurrent%\core
set _pathBuildLib=%_pathCurrent%\libraries
set _pathBuildLibModule=%_pathBuildLib%\lib
set _pathBuildInc=%_pathCurrent%\inc
set _pathBuildOut=%_pathCurrent%\output
set _pathBuildTool=%_pathCurrent%\tools
set _pathBuildEtc=%_pathBuildTool%\etc
set _pathStaticLibraryCore=%_pathBuildCore%\core.a
set _pathStaticLibraryLib=%_pathBuildLib%\lib.a
set _pathStaticLibraryInc=%_pathBuildInc%\inc.a

set _pathIncludeConf=%_pathBuildEtc%\includes.conf
set _pathPathFileConf=%_pathBuildEtc%\path.conf
set _pathHeaderFileConf=%_pathBuildEtc%\header.conf
set _pathArduinoConf=%_pathBuildEtc%\pathArduino.conf
set _pathTempConf=%_pathBuildEtc%\temp.conf

:: create sub-folder 'core, Libraries, inc, Output, src' if not exist
if not exist %_pathBuildCore% ( md %_pathBuildCore% )
if not exist %_pathBuildLib% ( md %_pathBuildLib% )
if not exist %_pathBuildLibModule% ( md %_pathBuildLibModule% )
if not exist %_pathBuildInc% ( md %_pathBuildInc% )
if not exist %_pathBuildOut% ( md %_pathBuildOut% )
if not exist %_pathBuildTool% ( md %_pathBuildTool% )
if not exist %_pathBuildEtc% ( md %_pathBuildEtc% )

::Kiểm tra file path.conf có tồn tại nếu tồn tại thì không cần hỏi đường dẫn arduino
::nếu file ko tồn tại thực hiện hỏi đường dẫn arduino và ghi lại file
if not exist %_pathArduinoConf% (
    ::hỏi đường dẫn Arduino
    set /P _pathArduino=Enter the path Arduino:
    if exist !_pathArduino! (
        echo !_pathArduino!>%_pathArduinoConf%
        goto :DEFINE_PATH
    ) else (
        goto :UNSUCCESS
    )
) else (
    for /F "delims=" %%f in ('Type "%_pathArduinoConf%"') do (
        set _pathArduino=%%f
    )
    goto :DEFINE_PATH
)

:DEFINE_PATH
:: Macro path file
set _pathCore=!_pathArduino!\hardware\arduino\avr\cores\arduino
set _pathTools=!_pathArduino!\hardware\tools\avr\bin
set _pathVariant=!_pathArduino!\hardware\arduino\avr\variants\standard
set _pathLibrary=!_pathArduino!\hardware\arduino\avr\libraries
set _pathConf=!_pathArduino!\hardware\tools\avr/etc/avrdude.conf
set _pathLibraries="C:\Users\admin\Documents\Arduino\libraries"
::ghi dường dẫn vào file conf
if exist %_pathPathFileConf% ( del %_pathPathFileConf% )
echo %_pathLibraries%>>%_pathPathFileConf%
echo %_pathBuildInc%>>%_pathPathFileConf%

:: Macro tools search
set _tools_search=tools\search
:: Macro compiler
set _compiler-gcc=avr-gcc
set _compiler-g++=avr-g++
set _compiler-static-library=avr-gcc-ar
set _compiler-hex=avr-objcopy
set _compiler-upload=avrdude
:: Macro option for compiler
set _opt-mcu=atmega328p
set _opt-frq-16M=16000000L
:: Macro option for upload

cd /d%_pathCurrent%
for %%f in (%_pathCurrent%\*.cpp) do (
    set _pathSourceFile=%%f
    set _pathSourceOut=%_pathBuildOut%\%%~nxf.o
)

if exist %_pathTempConf% ( del %_pathTempConf% )

set toolsSearch=%_tools_search% %_pathSourceFile%
%toolsSearch%


:BUILD_LIB
::kiem tra file header conf
if exist %_pathIncludeConf% if exist %_pathHeaderFileConf% (
    for /F "delims=" %%r in ('Type "%_pathHeaderFileConf%"') do (
        set root=%%r
        for /F "delims=" %%f in ('Type "%_pathIncludeConf%"') do (
            set files=%%f
            set pathFile=!root!\!files!
            if !root! EQU %_pathBuildInc% (
                echo Write File
            ) else (
                ::build Library
                echo build Library
            )
        )
    )
)
::kiem tra file temp.conf
if exist %_pathTempConf% (
    for /F "delims=" %%f in ('Type "%_pathTempConf%"') do (
        set toolsSearch=%_tools_search% %%f
        !toolsSearch!
        echo !toolsSearch!
    )
)

if exist %_pathTempConf% ( del %_pathTempConf% )

