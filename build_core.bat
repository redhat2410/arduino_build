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



cd /d%_pathTools%
::---------------------- Define thư viện CORE----------------------
:: Compile file asm to object file (.o)
for %%f in (%_pathCore%\*".s") do (
    set pathFile_asm=%%f
    set pathOut_asm=%_pathBuildCore%\%%~nxf.o
    set exec_asm=%_compiler-gcc% -c -g -x assembler-with-cpp -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% "!pathFile_asm!" -o "!pathOut_asm!"
    !exec_asm!
    set exec_ar_asm=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_asm!"
    !exec_ar_asm!
    echo !exec_ar_asm!
)

:: Compile file .c to object file (.o)
for %%f in (%_pathCore%\*".c") do (
    set pathFile_gcc=%%f
    set pathOut_gcc=%_pathBuildCore%\%%~nxf.o
    set exec_gcc=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% "!pathFile_gcc!" -o "!pathOut_gcc!"
    !exec_gcc!
    set exec_ar_gcc=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_gcc!"
    !exec_ar_gcc!
    echo !exec_ar_gcc!
)

:: Compile file .cpp to object file (.o)
for %%f in (%_pathCore%\*".cpp") do (
    set pathFile_g++=%%f
    set pathOut_g++=%_pathBuildCore%\%%~nxf.o
    set exec_g++=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% "!pathFile_g++!" -o "!pathOut_g++!"
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
        set _exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% -I"!_pathRoot!\src" "!pathSource!" -o "!pathSourceOut!"
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
            set _exec=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% "!pathSource!" -o "!pathSourceOut!" 
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
cd /d%_pathCurrent%
for %%f in (%_pathBuildSrc%\*.cpp) do (
    set tpathSource=%%f
    set tpathSourceOut=%_pathBuildOut%\%%~nxf.o
    echo !tpathSource!
    set toolsSearch=%_tools_search% !tpathSource!
    !toolsSearch!
    echo !toolsSearch!
    ::sau khi chạy tools search
    cd /d%_pathTools%
    if exist %_pathHeaderFileConf% (
        for /F "delims=" %%d in ('Type "%_pathHeaderFileConf%"') do (
            set pathRoot=%%d
            ::compile file .cpp
            for %%r in (!pathRoot!\*.cpp) do (
                set pathSource=%%r
                set pathSourceOut=%_pathBuildLibModule%/%%~nxr.o
                set pathSourceStatic=%_pathBuildLibModule%/%%~nxr.a
                set exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathRoot!" "!pathSource!" -o "!pathSourceOut!"
                !exec!
                echo !exec!
                set static=%_compiler-static-library% rcs "!pathSourceStatic!" "!pathSourceOut!"
                !static!
                echo !pathSourceStatic!>>%_pathStaticConf%
            )
            ::compile file .c
            for %%r in (!pathRoot!\*.c) do (
                set pathSource=%%r
                set pathSourceOut=%_pathBuildLibModule%/%%~nxr.o
                set pathSourceStatic=%_pathBuildLibModule%/%%~nxr.a
                set exec=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathRoot!" "!pathSource!" -o "!pathSourceOut!"
                !exec!
                echo !exec!
                set static=%_compiler-static-library% rcs "!pathSourceStatic!" "!pathSourceOut!"
                !static!
                echo !pathSourceStatic!>>%_pathStaticConf%
            )
            ::copy header file to build library
            for %%r in (!pathRoot!\*.h) do (
                set _copy=cp -r %%r %_pathBuildLibModule%
                !_copy!
                echo copy %%r to %_pathBuildLibModule%
            )
        )
    )

    set exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I%_pathBuildLibModule% -I%_pathBuildInc% "!tpathSource!" -o "!tpathSourceOut!"
    !exec!
    echo !exec!
    set exec_sl=%_compiler-static-library% rcs %_pathStaticLibraryInc% "!tpathSourceOut!"
    !exec_sl!
    echo !exec_sl!
    cd /d%_pathCurrent%
)
::----------------------------------------------------------------------------------------

::----------------------Build library được đóng góp bởi cộng đồng-------------------------

::----------------------------------------------------------------------------------------

cd /d%_pathCurrent%
for %%f in (%_pathCurrent%\*.cpp) do (
    set _pathSourceFile=%%f
    set _pathSourceOut=%_pathBuildOut%\%%~nxf.o
    set _pathSourceELF=%_pathBuildOut%\%%~nxf.elf
    set _pathSourceHEX=%_pathBuildOut%\%%~nxf.hex
)

if exist %_pathSourceOut% ( 
    del %_pathSourceOut% 
    echo Removed %_pathSourceOut%
)
if exist %_pathSourceELF% ( 
    del %_pathSourceELF%
    echo Removed %_pathSourceELF%
)
if exist %_pathSourceHEX% ( 
    del %_pathSourceHEX%
    echo Removed %_pathSourceHEX%
)

set toolsSearch=%_tools_search% %_pathSourceFile%
%toolsSearch%
echo %toolsSearch%
cd /d%_pathTools%
if exist %_pathHeaderFileConf% (
    for /F "delims=" %%f in (%_pathHeaderFileConf%) do (
        set pathRoot=%%f
        for %%r in (!pathRoot!\*.cpp) do (
            set pathSource=%%r
            set pathSourceOut=%_pathBuildLibModule%/%%~nxr.o
            set pathSourceStatic=%_pathBuildLibModule%/%%~nxr.a
            set exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathRoot!" "!pathSource!" -o "!pathSourceOut!"
            !exec!
            echo !exec!
            set static=%_compiler-static-library% rcs "!pathSourceStatic!" "!pathSourceOut!"
            !static!
            echo !pathSourceStatic!>>%_pathStaticConf%
        )
        for %%r in (!pathRoot!\*.c) do (
            set pathSource=%%r
            set pathSourceOut=%_pathBuildLibModule%/%%~nxr.o
            set pathSourceStatic=%_pathBuildLibModule%/%%~nxr.a
            set exec=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathRoot!" "!pathSource!" -o "!pathSourceOut!"
            !exec!
            set static=%_compiler-static-library% rcs "!pathSourceStatic!" "!pathSourceOut!"
            !static!
            echo !pathSourceStatic!>>%_pathStaticConf%
        )
        for %%r in (!pathRoot!\*.h) do (
            set _copy=cp -r %%r %_pathBuildLibModule%
            !_copy!
            echo copy %%r to %_pathBuildLibModule%
        )        
    )
)


::compile file .cpp to .o (outfile)
set exec_sketch=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I%_pathBuildLibModule% -I%_pathBuildInc% "!_pathSourceFile!" -o "!_pathSourceOut!"
!exec_sketch!
echo !exec_sketch!
::build file elf to .o
if exist !_pathSourceOut! (
    if exist !_pathStaticLibraryInc! (
        set buildELF=%_compiler-gcc% -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=%_opt-mcu% -o "!_pathSourceELF!" "!_pathSourceOut!" %_pathStaticLibraryInc% "C:\Users\admin\Desktop\arduino_build\Libraries\Lib\RTClib.cpp.a" %_pathStaticLibraryLib% %_pathStaticLibraryCore%
        !buildELF!
        echo !buildELF!
    ) else (
        set buildELF=%_compiler-gcc% -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=%_opt-mcu% -o "!_pathSourceELF!" "!_pathSourceOut!" "C:\Users\admin\Desktop\arduino_build\Libraries\Lib\RTClib.cpp.a" %_pathStaticLibraryLib% %_pathStaticLibraryCore% 
        !buildELF!
        echo !buildELF!
    )
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
    set upload=%_compiler-upload% -C%_pathConf% -v -p%_opt-mcu% -carduino -P%port% -b115200 -D -Uflash:w:"!_pathSourceHEX!":i
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



