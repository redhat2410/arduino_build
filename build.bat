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
set _pathStaticConf=%_pathBuildEtc%\pathStaticLib.conf

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
:: echo %_pathLibraries%>>%_pathPathFileConf%
echo %_pathBuildInc%>>%_pathPathFileConf%

:: Macro tools search
set _tools_search=tools\search
set _tools_duplicate=tools\find_duplicate
:: Macro compiler
set _compiler-gcc=avr-gcc
set _compiler-g++=avr-g++
set _compiler-static-library=avr-gcc-ar
set _compiler-hex=avr-objcopy
set _compiler-upload=avrdude
:: Macro option for compiler
set _opt-mcu-328=atmega328p
set _opt-frq-16M=16000000L
set _opt-frq-8M=8000000L
set _opt-baud_115200=115200
set _opt-baud_57600=57600
:: Macro option for upload

echo Please choose Arduino
echo 1. ARDUINO UNO
echo 2. ARDUINO PRO MINI
echo 3. ARDUINO NANO

set /p choose=Enter number: 

if %choose% == 1 (
    echo You choose board Arduino Uno.
    set _opt-mcu=%_opt-mcu-328%
    set _opt-frq=%_opt-frq-16M%
    set _opt-baud=%_opt-baud_115200%
) else if %choose% == 2 (
    echo You choose board Arduino Pro Mini.
    set _opt-mcu=%_opt-mcu-328%
    set _opt-frq=%_opt-frq-8M%
    set _opt-baud=%_opt-baud_57600%
) else if %choose% == 3 (
    echo You choose board Arduino Nano
    set _opt-mcu=%_opt-mcu-328%
    set _opt-frq=%_opt-frq-16M%
    set _opt-baud=%_opt-baud_57600%
) else (
    echo No board.
    goto :UNSUCCESS
)



cd /d%_pathTools%
::---------------------- Define thư viện CORE----------------------
:: Compile file asm to object file (.o)
for %%f in (%_pathCore%\*".s") do (
    set pathFile_asm=%%f
    set pathOut_asm=%_pathBuildCore%\%%~nxf.o
    set exec_asm=%_compiler-gcc% -c -g -x assembler-with-cpp -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% "!pathFile_asm!" -o "!pathOut_asm!"
    !exec_asm!
    set exec_ar_asm=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_asm!"
    !exec_ar_asm!
    echo !exec_ar_asm!
)

:: Compile file .c to object file (.o)
for %%f in (%_pathCore%\*".c") do (
    set pathFile_gcc=%%f
    set pathOut_gcc=%_pathBuildCore%\%%~nxf.o
    set exec_gcc=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% "!pathFile_gcc!" -o "!pathOut_gcc!"
    !exec_gcc!
    set exec_ar_gcc=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_gcc!"
    !exec_ar_gcc!
    echo !exec_ar_gcc!
)

:: Compile file .cpp to object file (.o)
for %%f in (%_pathCore%\*".cpp") do (
    set pathFile_g++=%%f
    set pathOut_g++=%_pathBuildCore%\%%~nxf.o
    set exec_g++=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% "!pathFile_g++!" -o "!pathOut_g++!"
    !exec_g++!
    set exec_ar_g++=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_g++!"
    !exec_ar_g++!
    echo !exec_ar_g++!
)
::----------------------------------------------------------------------------------------

::----------------------check Libraries anh incluce folder----------------------

::những việc cần làm thực hiện liên kết thư viện trong arduino bao gồm
::  thư viện giao tiếp vd "Wire", "SPI", "SoftwareSerial", "~/Arduino\hardware\arduino\avr\libraries"
::  thư viện ngoại vi được include từ Libraries manager "C:\Users\ducvu\OneDrive\Documents\Arduino\libraries"
::  thư viện ngoài được nhà phát triển thêm vào ở thư mục \inc\
::  đối với thư viện do nhà phát triển thực hiện thì phải đóng gói thành file static library "*.a"

cd /d%_pathTools%
for /d %%f in (%_pathLibrary%\*) do (
    set _pathRoot=%%f
    ::compile file .cpp
    for %%r in ("!_pathRoot!"\src\*.cpp) do (
        set pathSource=%%r
        set pathSourceOut=%_pathBuildLib%\%%~nxr.o
        set _exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% -I"!_pathRoot!\src" "!pathSource!" -o "!pathSourceOut!"
        !_exec!
        set _static=%_compiler-static-library% rcs %_pathStaticLibraryLib% "!pathSourceOut!"
        !_static!
        echo !_static!
    )
    ::compile file .h
    for %%r in ("!_pathRoot!"\src\*.h) do (
        set _copy=cp -r "%%r" %_pathBuildLib%
        !_copy!
        echo copy %%~nxr %_pathBuildLib%
    )
    
    for /d %%r in ("!_pathRoot!"\src\*) do (
        set _pathDir=%%r
        for %%d in ("!_pathDir!"\*.c) do (
            set pathSource=%%d
            set pathSourceOut=%_pathBuildLib%\%%~nxd.o
            set _exec=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% "!pathSource!" -o "!pathSourceOut!" 
            !_exec!
            set _static=%_compiler-static-library% rcs %_pathStaticLibraryLib% "!pathSourceOut!"
            !_static!
            echo !_static!
        )
    )
)

::----------------------------------------------------------------------------------------

::----------------------Build library trong thư mục INC----------------------
::thực hiện build thư viện người dùng tự define trong thư mục inc/
::mục tiêu thực hiên build thư viên ra file .a (static library)

for %%f in (%_pathBuildOut%\*) do (
    del %%f
)

if exist %_pathBackupIncConf% ( del %_pathBackupIncConf% )
if exist %_pathBackupLibConf% ( del %_pathBackupLibConf% )
if exist %_pathStaticConf% ( del %_pathStaticConf% )

cd /d%_pathCurrent%
for %%f in (%_pathCurrent%\*.cpp) do (
    set _pathSourceFile=%%f
    set _pathSourceOut=%_pathBuildOut%\%%~nxf.o
    set _pathSourceELF=%_pathBuildOut%\%%~nxf.elf
    set _pathSourceHEX=%_pathBuildOut%\%%~nxf.hex
)

if exist %_pathTempConf% ( del %_pathTempConf% )

::thực hiện search header trong file .cpp

set toolsSearch=%_tools_search% !_pathSourceFile!
echo search !_pathSourceFile!
!toolsSearch!
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
                    set writeConf=%_tools_duplicate% %_pathTempConf% !pathFile!
                    !writeConf!
                    set writeConf=%_tools_duplicate% %_pathBackupIncConf% !pathFile!
                    !writeConf!
                    set writeConf=%_tools_duplicate% %_pathStaticConf% %_pathBuildOut%\%%~nf.o
                    !writeConf!
                ) else (
                    ::build lib
                    for %%d in (!root!\*.cpp) do (
                        set source=%%d
                        set output=%_pathBuildOut%\%%~nxd.o
                        if not exist !output! (
                            echo !root!>>%_pathBackupLibConf%                        
                            set compile=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!source!" -o "!output!"
                            cd /d %_pathTools%
                            !compile!
                            echo build !source!
                            echo !output!>>%_pathStaticConf%
                            cd /d %_pathCurrent%
                        )
                    )
                    for %%d in (!root!\*.c) do (
                        set source=%%d
                        set output=%_pathBuildOut%\%%~nxd.o
                        if not exist !output! (        
                            echo !root!>>%_pathBackupLibConf%                 
                            set compile=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!source!" -o "!output!"
                            cd /d %_pathTools%
                            !compile!
                            echo build !source!
                            echo !output!>>%_pathStaticConf%
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
        echo search %%f
        if exist %_pathHeaderFileConf% ( goto :LOOP )
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
        set pathLib=-I"%%~ff" !pathLib!
    )
)
if exist %_pathBackupIncConf% (
    for /F "delims=" %%f in ('Type "%_pathBackupIncConf%"') do (
        set root=%%~df%%~pf
        set source_cpp=%%~df%%~pf%%~nf.cpp
        set source_c=%%~df%%~pf%%~nf.c
        set output=%_pathBuildOut%\%%~nf.o
        set Lstatic=%_pathBuildInc%\%%~nf.a
        if exist !source_cpp! (
            if not exist !output! (
                cd /d %_pathTools%
                set fullpath= !pathLib!-I"!root:~0,-1!"
                set compile=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I"%_pathBuildLib%" -I"!root:~0,-1!" !pathLib!"!source_cpp!" -o "!output!" 
                !compile!
                echo build !source_cpp!
                set static_lib=%_compiler-static-library% rcs "!Lstatic!" "!output!"
                !static_lib!
                cd /d %_pathCurrent%
            )
        )
        if exist !source_c! (
            if not exist !output! (
                cd /d %_pathTools%
                set fullpath= !pathLib! -I"!root:~0,-1!"
                set compile=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I"%_pathBuildLib%" -I"!root:~0,-1!" !pathLib!"!source_c!" -o "!output!"
                !compile!
                echo build !source_c!
                set static_lib=%_compiler-static-library% rcs "!Lstatic!" "!output!"
                !static_lib!
                cd /d %_pathCurrent%
            )
        )
    )
)
cd /d %_pathTools%
set compile=%_compiler-g++% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% !fullpath! "!_pathSourceFile!" -o "!_pathSourceOut!"
!compile!
echo build !_pathSourceFile!

if exist %_pathStaticConf% (
    for /F "delims= tokens=1*" %%f in ('Type "%_pathStaticConf%"') do (
        set staticLink="%%f" !staticLink!
    )
)

if exist %_pathSourceOut% (
    set buildELF=%_compiler-gcc% -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=%_opt-mcu% -o "!_pathSourceELF!" "!_pathSourceOut!" !staticLink!%_pathStaticLibraryLib% %_pathStaticLibraryCore%
    !buildELF!
    ::echo !buildELF!
    echo compile !_pathSourceOut!
) else (
    goto :UNSUCCESS
)
::Convert file hex to file .elf
if exist !_pathSourceELF! (
    set buildHEX=%_compiler-hex% -j .text -j .data -O ihex "!_pathSourceELF!" "!_pathSourceHEX!"
    !buildHEX!
    echo !buildHEX!
) else (
    goto :UNSUCCESS
)

if exist !_pathSourceHEX! (
    goto :UPLOAD
)
else ( 
    goto :UNSUCCESS
)
::thực hiện upload file hex 
:UPLOAD
set /p ask=Do you want to upload (Y/N):
if %ask%==Y (
    ::call file checkPort để nhập com port
    goto :YES
) else (
    goto :NO
)
goto :eof

:YES

::Nhập tên cổng COM
set /p port=Enter port name:
for /f "delims=" %%f in ('mode %port%') do (
    set status=%%f
)
set result=Illegal device name - %port%
::kiểm tra cổng COM vaild?
if "!status!"=="%result%" ( 
    echo %port% invaild
    goto :UNSUCCESS
) else (
    ::nếu cổng COM vaild thực hiện upload
    set upload=%_compiler-upload% -C%_pathConf% -v -p%_opt-mcu% -carduino -P%port% -b%_opt-baud% -D -Uflash:w:"!_pathSourceHEX!":i
    !upload!
    echo Upload done !!!
)

goto :eof

:NO
echo Build successfull !!!
goto :eof

:UNSUCCESS
echo Build Unsuccessfull !!!
goto :eof



