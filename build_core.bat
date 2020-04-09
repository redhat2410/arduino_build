@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:: Macro path file
set _pathCore="C:\Program Files (x86)\Arduino\hardware\arduino\avr\cores\arduino"
set _pathTools="C:\Program Files (x86)\Arduino\hardware\tools\avr\bin"
set _pathVariant="C:\Program Files (x86)\Arduino\hardware\arduino\avr\variants\standard"
set _pathLibrary="C:\Program Files (x86)\Arduino\hardware\arduino\avr\libraries"
set _pathLibraries="C:\Users\admin\Documents\Arduino\libraries"
set _pathConf="C:\Program Files (x86)\Arduino\hardware\tools\avr/etc/avrdude.conf"
set _pathCurrent=%cd%
:: Organization folder
:: Create folder library Core 
set _pathBuildCore=%_pathCurrent%\core
set _pathBuildLib=%_pathCurrent%\Libraries
set _pathBuildLibModule=%_pathBuildLib%\Lib
set _pathBuildInc=%_pathCurrent%\inc
set _pathBuildOut=%_pathCurrent%\Output
set _pathBuildScr=%_pathCurrent%\src
set _pathStaticLibraryCore=%_pathBuildCore%\core.a
set _pathStaticLibraryLib=%_pathBuildLib%\lib.a
set _pathStaticLibraryInc=%_pathBuildInc%\inc.a
:: Macro compiler
set _compiler-gcc=avr-gcc
set _compiler-g++=avr-g++
set _compiler-static-library=avr-gcc-ar
set _compiler-hex=avr-objcopy
set _compiler-upload=avrdude
:: Macro option for compiler
set _opt-mcu=atmega328p
set _opt-frq=16000000L
:: Macro option for upload

:: create sub-folder 'core, Libraries, inc, Output, src' if not exist
if not exist %_pathBuildCore% ( md %_pathBuildCore% )
if not exist %_pathBuildLib% ( md %_pathBuildLib% )
if not exist %_pathBuildLibModule% ( md %_pathBuildLibModule% )
if not exist %_pathBuildInc% ( md %_pathBuildInc% )
if not exist %_pathBuildOut% ( md %_pathBuildOut% )
if not exist %_pathBuildScr% ( md %_pathBuildScr% )

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

for /d %%f in (%_pathLibrary%\*) do (
    set pathSource=%%f\src
    set pathHPP=%%f\src\%%~nxf.h
    set pathCPP=%%f\src\%%~nxf.cpp
    set pathout=%_pathBuildLib%\%%~nxf.o
    ::thực hiện build thư viện
    set _exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% -I"!pathSource!" "!pathCPP!" -o "!pathout!"
    !_exec!

    set _execStatic=%_compiler-static-library% rcs "%_pathStaticLibraryLib%" "!pathout!"
    !_execStatic!
    ::thực hiện copy các file header tới workspace
    set _copy=cp -r "!pathHPP!" %_pathBuildLib%
    !_copy!
    echo !_copy!
)

::----------------------------------------------------------------------------------------

::----------------------Build library trong thư mục INC----------------------
::thực hiện build thư viện người dùng tự define trong thư mục inc/
::mục tiêu thực hiên build thư viên ra file .a (static library)
cd /d%_pathCurrent%
for %%f in (%_pathBuildInc%\*cpp) do (
    set pathSource=%%f
    set pathSourceOut=%_pathBuildOut%\%%~nxf.o
    cd /d%_pathTools%
    set exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% "!pathSource!" -o "!pathSourceOut!"
    !exec!
    set exec_sl=%_compiler-static-library% rcs %_pathStaticLibraryInc% "!pathSourceOut!"
    !exec_sl!
    echo !exec_sl!
    cd /d%_pathCurrent%
)
::----------------------------------------------------------------------------------------

::----------------------Build library được đóng góp bởi cộng đồng----------------------
::xử lý build source file .cpp vs .c
cd /d%_pathTools%
for /d %%f in (%_pathLibraries%\*) do (
    set pathsource=%%f
    for %%a in (!pathsource!\*.cpp) do (
        set source=%%a
        set out=%_pathBuildLibModule%\%%~nxa.o
        set static=%_pathBuildLibModule%\%%~nxa.a
        set exec_cpp=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -flto -w -x c++ -E -CC -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathsource!" "!source!" -o "!out!"
        !exec_cpp!
        set exec_ar=%_compiler-static-library% rcs "!static!" "!out!"
        !exec_ar!
        echo !exec_ar!
    )
    for %%b in (!pathsource!\src\*.cpp) do (
        set source=%%b
        set out=%_pathBuildLibModule%\%%~nxb.o
        set static=%_pathBuildLibModule%\%%~nxb.a
        set exec_cpp=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -flto -w -x c++ -E -CC -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathsource!\src" "!source!" -o "!out!"
        !exec_cpp!
        set exec_ar=%_compiler-static-library% rcs "!static!" "!out!"
        !exec_ar!
        echo !exec_ar!
    )
)
::xử lý build source file .c
for /d %%f in (%_pathLibraries%\*) do (
    set pathsource=%%f
    for %%a in (!pathsource!\*.c) do (
        set source=%%a
        set out=%_pathBuildLibModule%\%%~nxa.o
        set static=%_pathBuildLibModule%\%%~nxa.a
        set exec_c=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathsource!" "!source!" -o "!out!"
        !exec_c!
        set exec_ar=%_compiler-static-library% rcs "!static!" "!out!"
        !exec_ar!
        echo !exec_ar!
    )
    for %%b in (!pathsource!\src\*.c) do (
        set source=%%b
        set out=%_pathBuildLibModule%\%%~nxb.o
        set static=%_pathBuildLibModule%\%%~nxb.a
        set exec_c=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!pathsource!\src" "!source!" -o "!out!"
        !exec_c!
        set exec_ar=%_compiler-static-library% rcs "!static!" "!out!"
        !exec_ar!
        echo !exec_ar!
    )
)

for %%f in (%_pathBuildLibModule%\*.a) do (
    set _linkPathStatic="%%f" !_linkPathStatic!
)

::for %%f in (%_pathBuildLibModule%\*.o) do (
::    del %%f
::    echo Removed %%f
::)

::thực hiện copy file .h vào thư mục build
for /d %%f in (%_pathLibraries%\*) do (
    set pathsource=%%f
    for %%a in (!pathsource!\*.h) do (
        set fileHPP=%%a
        set _copy=cp -r "!fileHPP!" %_pathBuildLibModule%
        !_copy!
        echo copy %%~nxa to %_pathBuildLibModule%
    )
    for %%b in (!pathsource!\src\*.h) do (
        set fileHPP=%%b
        set _copy=cp -r "!fileHPP!" %_pathBuildLibModule%
        !_copy!
        echo copy %%~nxb to %_pathBuildLibModule%
    )
)


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

cd /d%_pathTools%
::compile file .cpp to .o (outfile)
set exec_sketch=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I%_pathBuildLibModule% -I%_pathBuildInc% -o "!_pathSourceOut!" "!_pathSourceFile!"
!exec_sketch!

::build file elf to .o
if exist !_pathSourceOut! (
    set buildELF=%_compiler-gcc% -w -Os -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=%_opt-mcu% -o "!_pathSourceELF!" "!_pathSourceOut!" "C:\Users\admin\Desktop\arduino_build\Libraries\Lib\Adafruit_Fingerprint.cpp.o" %_pathStaticLibraryInc% %_pathStaticLibraryLib% %_pathStaticLibraryCore%
    !buildELF!
    echo !buildELF!
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



