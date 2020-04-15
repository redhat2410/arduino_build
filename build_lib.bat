@echo off 
SETLOCAL ENABLEDELAYEDEXPANSION

:: Organization folder
:: Create folder library Core 
set _pathCurrent=%cd%
set _pathBuildCore=%_pathCurrent%\core
set _pathBuildLib=%_pathCurrent%\libraries
set _pathBuildInc=%_pathCurrent%\inc
set _pathBuildLibModule=%_pathBuildInc%\lib
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
set _pathBackupIncConf=%_pathBuildEtc%\backupInc.conf
set _pathBackupLibConf=%_pathBuildEtc%\backupLib.conf

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

for %%f in (%_pathBuildOut%\*) do (
    del %%f
)

del %_pathBackupIncConf%
del %_pathBackupLibConf%

cd /d%_pathCurrent%
for %%f in (%_pathCurrent%\*.cpp) do (
    set _pathSourceFile=%%f
    set _pathSourceOut=%_pathBuildOut%\%%~nxf.o
)

if exist %_pathTempConf% ( del %_pathTempConf% )

::thực hiện search header trong file .cpp

set toolsSearch=%_tools_search% %_pathSourceFile%
%toolsSearch%
::thực hiện phân loại các các thư viện trong file thư mục /inc và thư mục /lib
::Phân loại các thư viện trong /lib để build trước
::thực hiện duyệt tất cả các file .h và .c/.cpp được include 

:LOOP

if exist %_pathHeaderFileConf% if exist %_pathIncludeConf% (
    for /F "delims=" %%r in ('Type "%_pathHeaderFileConf%"') do (
        set root=%%r
        for /F "delims=" %%f in ('Type "%_pathIncludeConf%"') do (
            set files=%%f
            set pathFile=!root!\!files!
            if exist !pathFile! (
                if !root! == %_pathBuildInc% (
                    echo !pathFile!>>%_pathTempConf%
                    echo !pathFile!>>%_pathBackupIncConf%
                ) else (
                    ::build lib
                    for %%d in (!root!\*.cpp) do (
                        set source=%%d
                        set output=%_pathBuildOut%\%%~nxd.o
                        if not exist !output! (
                            echo "!root!">>%_pathBackupLibConf%                        
                            set compile=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!source!" -o "!output!"
                            cd /d %_pathTools%
                            !compile!
                            echo !compile!
                            cd /d %_pathCurrent%
                        )
                    )
                    for %%d in (!root!\*.c) do (
                        set source=%%d
                        set output=%_pathBuildOut%\%%~nxd.o
                        if not exist !output! (        
                            echo "!root!">>%_pathBackupLibConf%                 
                            set compile=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!source!" -o "!output!"
                            cd /d %_pathTools%
                            !compile!
                            echo !compile!
                            cd /d %_pathCurrent%
                        )
                    )
                )
            )
        )
    )
)
::Cần file search file .h và file .c/.cpp
if exist %_pathTempConf% (
    for /F "delims=" %%f in ('Type "%_pathTempConf%"') do (
        set toolsSearch=%_tools_search% %%f
        !toolsSearch!
        echo !toolsSearch!
    )
) else (
    goto :EXT_LOOP
)
del %_pathTempConf%

if exist %_pathHeaderFileConf% (
    ::khi header.conf có tồn tại tức tìm thấy các file include khác khi đó sẽ quay lại :LOOP để kiểm tra và build
    goto :LOOP
)

:EXT_LOOP
if exist %_pathBackupLibConf% (
    for /F "delims=" %%f in ('Type "%_pathBackupLibConf%"') do (
        set pathLib=-I%%f !pathLib!
    )
)


if exist %_pathBackupIncConf% (
    for /F "delims=" %%f in ('Type "%_pathBackupIncConf%"') do (
        set root=%%~df%%~pf
        set source_cpp=%%~df%%~pf%%~nf.cpp
        set source_c=%%~df%%~pf%%~nf.c
        set output=%_pathBuildOut%\%%~nf.o
        if exist !source_cpp! (
            if not exist !output! (
                cd /d %_pathTools%
                set compile=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!pathLib!" "!source_cpp!" -o "!output!"
                !compile!
                echo !compile!
                cd /d %_pathCurrent%
            )
        )
        if exist !source_c! (
            if not exist !output! (
                cd /d %_pathTools%
                set compile=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!pathLib!" "!source_c!" -o "!output!"
                !compile!
                echo !compile!
                cd /d %_pathCurrent%
            )
        )
    )
)