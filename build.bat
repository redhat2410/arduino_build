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
set _pathBackupIncConf=%_pathBuildEtc%\backupInc.conf
set _pathBackupLibConf=%_pathBuildEtc%\backupLib.conf
set _pathStaticConf=%_pathBuildEtc%\pathStaticLib.conf
set _pathTempSourceConf=%_pathBuildEtc%\_temp.conf

:: create sub-folder 'core, Libraries, inc, Output, src' if not exist
if not exist %_pathBuildCore% ( md %_pathBuildCore% )
if not exist %_pathBuildLib% ( md %_pathBuildLib% )
if not exist %_pathBuildLibModule% ( md %_pathBuildLibModule% )
if not exist %_pathBuildInc% ( md %_pathBuildInc% )
if not exist %_pathBuildOut% ( md %_pathBuildOut% )
if not exist %_pathBuildTool% ( md %_pathBuildTool% )
if not exist %_pathBuildEtc% ( md %_pathBuildEtc% )

for %%f in (%_pathCurrent%) do ( set sourceName=%%~nxf.cpp )
for %%f in (%_pathTempSourceConf%) do ( set sourceTemp=%%~nxf )

if not exist %cd%\!sourceName! (
    if exist %_pathTempSourceConf% (
        set copyFile=xcopy %_pathTempSourceConf% %cd%
        !copyFile!
        echo !copyFile!
        set tpath=%cd%\!sourceTemp!
        if exist !tpath! (
            set rename=ren !sourceTemp! !sourceName!
            !rename!
            echo Create !sourceName!
        )
    )
)

for %%f in (%_pathBuildOut%\*) do (
    del %%f
)
for %%f in (%_pathBuildCore%\*) do (
    del %%f
)
for %%f in (%_pathBuildLib%\*) do (
    del %%f
)

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
echo %_pathBuildInc%>>%_pathPathFileConf%

:: Macro tools search
set _tools_search=tools\search
set _tools_duplicate=tools\find_duplicate
set _tools_configure=tools\configure
set _tools_lisPort=tools\listPort
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
    echo Compile !pathFile_asm!
)

:: Compile file .c to object file (.o)
for %%f in (%_pathCore%\*".c") do (
    set pathFile_gcc=%%f
    set pathOut_gcc=%_pathBuildCore%\%%~nxf.o
    set exec_gcc=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% "!pathFile_gcc!" -o "!pathOut_gcc!"
    !exec_gcc!
    set exec_ar_gcc=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_gcc!"
    !exec_ar_gcc!
    echo Compile !pathFile_gcc!
)

:: Compile file .cpp to object file (.o)
for %%f in (%_pathCore%\*".cpp") do (
    set pathFile_g++=%%f
    set pathOut_g++=%_pathBuildCore%\%%~nxf.o
    set exec_g++=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -I%_pathCore% -I%_pathVariant% "!pathFile_g++!" -o "!pathOut_g++!"
    !exec_g++!
    set exec_ar_g++=%_compiler-static-library% rcs "%_pathStaticLibraryCore%" "!pathOut_g++!"
    !exec_ar_g++!
    echo Compile !pathFile_g++!
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
        echo Compile !pathSource!
    )
    ::compile file .h
    for %%r in ("!_pathRoot!"\src\*.h) do (
        set _copy=copy -r "%%r" %_pathBuildLib%
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
            echo Compile !pathSource!
        )
    )
)

::----------------------------------------------------------------------------------------

::----------------------Build library trong thư mục INC----------------------
::thực hiện build thư viện người dùng tự define trong thư mục inc/
::mục tiêu thực hiên build thư viên ra file .a (static library)

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

::thực hiện search header trong file .cpp

set toolsConf=%_tools_configure% !_pathSourceFile!
echo configure !_pathSourceFile!
!toolsConf!
::thực hiện phân loại các các thư viện trong file thư mục /inc và thư mục /lib
::Phân loại các thư viện trong /lib để build trước
::thực hiện duyệt tất cả các file .h và .c/.cpp được include 

if exist %_pathBackupLibConf% (
    for /F "delims=" %%r in ('Type "%_pathBackupLibConf%"') do (
        set root=%%r
        set pathLib=-I"%%~fr" !pathLib!
        for %%f in (!root!\*.cpp) do (
            set sourceLib=%%f
            set outputLib=%_pathBuildOut%\%%~nxf.o
            echo !outputLib!>>%_pathStaticConf%
            cd /d %_pathTools%
            set build=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!sourceLib!" -o "!outputLib!"
            !build!
            cd /d %_pathCurrent%
            echo build !sourceLib!
        )
        for %%f in (!root!\*.c) do (
            set sourceLib=%%f
            set outputLib=%_pathBuildOut%\%%~nxf.o
            echo !outputLib!>>%_pathStaticConf%
            cd /d %_pathTools%
            set build=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!sourceLib!" -o "!outputLib!"
            !build!
            cd /d %_pathCurrent%
            echo build !sourceLib!
        )
    )
)

if exist %_pathBackupIncConf% (
    for /F "delims=" %%f in ('Type "%_pathBackupIncConf%"') do (
        set sourceInc=%%f
        set outputInc=%_pathBuildOut%\%%~nxf.o
        set staticInc=%_pathBuildInc%\%%~nxf.a
        set extension=%%~xf
        set root=%%~df%%~pf
        echo !staticInc!>>%_pathStaticConf%
        if !extension! ==.cpp (
            cd /d %_pathTools%
            set build=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root:~0,-1!" !pathLib! "!sourceInc!" -o "!outputInc!" 
            !build!
            echo build !sourceInc!
            set slibrary=%_compiler-static-library% rcs "!staticInc!" "!outputInc!"
            !slibrary!
            echo build static library !outputInc!
            cd /d %_pathCurrent%

        )
        if !extension! ==.c (
            cd /d %_pathTools%
            set build=%_compiler-gcc% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root:~0,-1!" !pathLib! "!sourceInc!" -o "!outputInc!" 
            !build!
            echo build !sourceInc!
            set slibrary=%_compiler-static-library% rcs "!staticInc!" "!outputInc!"
            !slibrary!
            echo build static library !outputInc!
            cd /d %_pathCurrent%
        )        
    )
)

if exist %_pathIncludeConf% (
    for /F "delims=" %%f in ('Type "%_pathIncludeConf%"') do (
        set pathInc=-I"%%f" !pathInc!
    )
)


cd /d %_pathTools%
set compile=%_compiler-g++% -c -g -Os -w -std=gnu11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% !pathLib! !pathInc! "!_pathSourceFile!" -o "!_pathSourceOut!"
!compile!
echo build %_pathSourceFile%

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
::Show list port
echo List COM port.
cd /d %_pathCurrent%
%_tools_lisPort%
::Nhập tên cổng COM
set /p port=Enter port name:
for /f "delims=" %%f in ('mode %port%') do (
    set status=%%f
)
set result=Illegal device name - %port%
::kiểm tra cổng COM vaild?
cd /d %_pathTools%
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



