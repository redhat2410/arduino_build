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


set _pathStaticLibraryCore=%_pathBuildCore%\arduino.ar
set _pathStaticLibraryLib=%_pathBuildLib%\lib.ar
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

for %%f in (%_pathBuildOut%\*) do (
    del %%f
)
for %%f in (%_pathBuildCore%\*) do (
    del %%f
)
::Kiểm tra file path.conf có tồn tại nếu tồn tại thì không cần hỏi đường dẫn arduino
::nếu file ko tồn tại thực hiện hỏi đường dẫn arduino và ghi lại file

set _pathArduino="C:\Users\admin\AppData\Local\Arduino15\packages\esp8266"

:DEFINE_PATH
:: Macro path file
set _pathCore=!_pathArduino!\hardware\esp8266\2.4.0\cores\esp8266
set _pathTools=!_pathArduino!\tools\xtensa-lx106-elf-gcc\1.20.0-26-gb404fb9-2\bin
set _pathVariant=!_pathArduino!\hardware\esp8266\2.4.0\variants\generic
set _pathLibrary=!_pathArduino!\hardware\esp8266\2.4.0\libraries
set _pathConf=!_pathArduino!\hardware\tools\avr/etc/avrdude.conf
:: Macro path file SDK
set _pathSDKInc=!_pathArduino!\hardware\esp8266\2.4.0/tools/sdk/include
set _pathSDKlwip2=!_pathArduino!\hardware\esp8266\2.4.0/tools/sdk/lwip2/include
set _pathSDKlibc=!_pathArduino!\hardware\esp8266\2.4.0/tools/sdk/libc/xtensa-lx106-elf/include
::ghi dường dẫn vào file conf
if exist %_pathPathFileConf% ( del %_pathPathFileConf% )
echo %_pathBuildInc%>>%_pathPathFileConf%

:: Macro tools search
set _tools_search=tools\search
set _tools_duplicate=tools\find_duplicate
set _tools_configure=tools\configure
:: Macro compiler
set _compiler-gcc=xtensa-lx106-elf-gcc
set _compiler-g++=xtensa-lx106-elf-g++
set _compiler-static-library=xtensa-lx106-elf-ar
set _compiler-hex=xtensa-lx106-elf-objcopy
set _compiler-upload=avrdude

cd /d %_pathTools%
for %%f in (%_pathCore%\*.s) do (
    set source=%%f
    set output=%_pathBuildCore%\%%~nxf.o
    set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -g -x assembler-with-cpp -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DF_CRYSTAL=40000000 -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
    !build!
    set static=%_compiler-static-library% cru %_pathStaticLibraryCore% "!output!"
    !static!
    echo compile static library !output!
)

for %%f in (%_pathCore%\*.c) do (
    set source=%%f
    set output=%_pathBuildCore%\%%~nxf.o
    set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -std=gnu11 -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DF_CRYSTAL=40000000 -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
    !build!
    set static=%_compiler-static-library% cru %_pathStaticLibraryCore% "!output!"
    !static!
    echo compile static library !output!
)

for %%f in (%_pathCore%\*.cpp) do (
    set source=%%f
    set output=%_pathBuildCore%\%%~nxf.o
    set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -std=gnu++11 -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DF_CRYSTAL=40000000 -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
    !build!
    set static=%_compiler-static-library% cru %_pathStaticLibraryCore% "!output!"
    !static!
    echo compile static library !output!
)

for /D %%d in (%_pathCore%\*) do (
    set root=%%d
    set dir=%_pathBuildCore%\%%~nd

    if not exist !dir! ( md !dir! )
    for %%f in (!root!\*.c) do (
        set source=%%f
        set output=!dir!\%%~nxf.o
        set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -std=gnu11 -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DF_CRYSTAL=40000000 -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
        !build!
    )
    for %%f in (!root!\*.cpp) do (
        set source=%%f
        set output=!dir!\%%~nxf.o
        set build=%_compiler-g++% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -std=gnu++11 -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DF_CRYSTAL=40000000 -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
        !build!
    )
)
::----------------------check Libraries anh incluce folder----------------------

::------------------------------------------------------------------------------