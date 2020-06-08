::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAnk
::fBw5plQjdG8=
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF+5
::cxAkpRVqdFKZSDk=
::cBs/ulQjdF+5
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFBpQQQ2MAE+/Fb4I5/jH7viDt0QTW909bYbX3oiMNekf7gjhZoZj02Jf+A==
::YB416Ek+ZG8=
::
::
::978f952a14a936cc963da21a135fa983
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
set _pathTempSourceConf=%_pathBuildEtc%\_temp.conf
set _pathBackupIncConf=%_pathBuildEtc%\backupInc.conf
set _pathBackupLibConf=%_pathBuildEtc%\backupLib.conf
set _pathStaticConf=%_pathBuildEtc%\pathStaticLib.conf

:: Macro tools search
set _tools_search=tools\search
set _tools_duplicate=tools\find_duplicate
set _tools_configure=tools\configure_esp
set _tools_search_path=tools\search_path
set _tools_listPort=tools\listPort
set _tools_getTime=tools\getTime

::Chay tools getTime de kiem tra thoi gian chay tools
set _default_time=13-5-2020
set _getTime=%_tools_getTime% %_default_time%
for /f "delims=" %%f in ('%_getTime%') do (
    set result=%%f
)
if %result%==False (
    echo Tools is locked.
    goto :UNSUCCESS
)

:: create sub-folder 'core, Libraries, inc, Output, src' if not exist
if not exist %_pathBuildCore% ( md %_pathBuildCore% )
if not exist %_pathBuildLib% ( md %_pathBuildLib% )
if not exist %_pathBuildLibModule% ( md %_pathBuildLibModule% )
if not exist %_pathBuildInc% ( md %_pathBuildInc% )
if not exist %_pathBuildOut% ( md %_pathBuildOut% )
if not exist %_pathBuildTool% ( md %_pathBuildTool% )
if not exist %_pathBuildEtc% ( md %_pathBuildEtc% )

for %%f in (%cd%) do ( set sourceName=%%~nxf.cpp )
for %%f in (%_pathTempSourceConf%) do ( set sourceTemp=%%~nxf )

if not exist %cd%\!sourceName! (
    if exist %_pathTempSourceConf% (
        xcopy %_pathTempSourceConf% %cd%
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
set toolsPath=%_tools_search_path%
!toolsPath!

if exist %_pathArduinoConf% (
    for /F "delims=" %%f in ('Type %_pathArduinoConf%') do (
        set tempPath=%%f
    )
    set _pathArduino=!tempPath!\packages\esp8266

    echo Location esp: !_pathArduino!
) else (
    goto :UNSUCCESS
)

set _pathRoot=!_pathArduino!\hardware\esp8266\2.4.0
:: Macro path file
set _pathCore=!_pathArduino!\hardware\esp8266\2.4.0\cores\esp8266
set _pathTools=!_pathArduino!\tools\xtensa-lx106-elf-gcc\1.20.0-26-gb404fb9-2\bin
set _pathVariant=!_pathArduino!\hardware\esp8266\2.4.0\variants\generic
set _pathLibrary=!_pathArduino!\hardware\esp8266\2.4.0\libraries
set _pathConf=!_pathArduino!\hardware\esp8266\2.4.0/bootloaders/eboot/eboot.elf

:: Macro path file SDK
set _pathSDKInc=!_pathArduino!\hardware\esp8266\2.4.0/tools/sdk/include
set _pathSDKlwip2=!_pathArduino!\hardware\esp8266\2.4.0/tools/sdk/lwip2/include
set _pathSDKlibc=!_pathArduino!\hardware\esp8266\2.4.0/tools/sdk/libc/xtensa-lx106-elf/include
:: For compile elf
set _pathSDKlib=!_pathArduino!\hardware\esp8266\2.4.0\tools\sdk\lib
set _pathSDKld=!_pathArduino!\hardware\esp8266\2.4.0\tools\sdk\ld
set _pathSDKelflib=!_pathArduino!\hardware\esp8266\2.4.0\tools\sdk\libc\xtensa-lx106-elf\lib
::ghi dường dẫn vào file conf
if exist %_pathPathFileConf% ( del %_pathPathFileConf% )
echo %_pathBuildInc%>>%_pathPathFileConf%
echo %_pathLibrary%>>%_pathPathFileConf%

:: Macro compiler
set _compiler-gcc=xtensa-lx106-elf-gcc
set _compiler-g++=xtensa-lx106-elf-g++
set _compiler-static-library=xtensa-lx106-elf-ar
set _compiler-hex=xtensa-lx106-elf-objcopy
set _compiler-upload=%_pathArduino%\tools\esptool\0.4.12\esptool

if not exist %_pathRoot% (
    echo Please install library esp8266 version 2.4.0
    goto :UNSUCCESS
)

cd /d %_pathTools%
for %%f in (%_pathCore%\*.s) do (
    set source=%%f
    set output=%_pathBuildCore%\%%~nxf.o
    set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -g -x assembler-with-cpp -MMD -mlongcalls -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DF_CRYSTAL=40000000 -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
    !build!
    set static=%_compiler-static-library% cru %_pathStaticLibraryCore% "!output!"
    !static!
    echo compile static library !output!
)

for %%f in (%_pathCore%\*.c) do (
    set source=%%f
    set output=%_pathBuildCore%\%%~nxf.o
    set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
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
        set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
        !build!
        set static=%_compiler-static-library% cru "%_pathStaticLibraryCore%" "!output!"
        !static!
        echo compile static library !output!
    )
    for %%f in (!root!\*.cpp) do (
        set source=%%f
        set output=!dir!\%%~nxf.o
        set build=%_compiler-g++% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -mlongcalls -mtext-section-literals -fno-exceptions -fno-rtti -falign-functions=4 -std=c++11 -MMD -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
        !build!
        set static=%_compiler-static-library% cru "%_pathStaticLibraryCore%" "!output!"
        !static!
        echo compile static library !output!
    )
)

for %%f in (%_pathCore%\*.cpp) do (
    set source=%%f
    set output=%_pathBuildCore%\%%~nxf.o
    set build=%_compiler-g++% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -mlongcalls -mtext-section-literals -fno-exceptions -fno-rtti -falign-functions=4 -std=c++11 -MMD -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% "!source!" -o "!output!"
    !build!
    set static=%_compiler-static-library% cru %_pathStaticLibraryCore% "!output!"
    !static!
    echo compile static library !output!
)



if exist %_pathBackupIncConf% ( del %_pathBackupIncConf% )
if exist %_pathBackupLibConf% ( del %_pathBackupLibConf% )
if exist %_pathStaticConf% ( del %_pathStaticConf% )

cd /d %_pathCurrent%
for %%f in (%_pathCurrent%\*.cpp) do (
    set _pathSourceFile=%%f
    set _pathSourceOut=%_pathBuildOut%\%%~nf.o
    set _pathSourceELF=%_pathBuildOut%\%%~nf.elf
    set _pathSourceBIN=%_pathBuildOut%\%%~nf.bin
)

::thực hiện search header trong file .cpp
set toolsConf=%_tools_configure% !_pathSourceFile!
echo configure !_pathSourceFile!
!toolsConf!

if exist %_pathTempConf% (
    for /F "delims=" %%r in ('Type "%_pathTempConf%"') do (
        set pathlibraries=-I"%%~fr" !pathlibraries!
    )
)

if exist %_pathBackupLibConf% (
    for /F "delims=" %%r in ('Type "%_pathBackupLibConf%"') do (
        set root=%%r
        set pathLib=-I"%%~fr" !pathLib!
        for %%f in (!root!\*.cpp) do (
            set sourceLib=%%f
            set outputLib=%_pathBuildOut%\%%~nxf.o
            echo !outputLib!>>%_pathStaticConf%
            cd /d %_pathTools%
            set build=%_compiler-g++% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -mlongcalls -mtext-section-literals -fno-exceptions -fno-rtti -falign-functions=4 -std=c++11 -MMD -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% !pathlibraries! -I"!root!" "!sourceLib!" -o "!outputLib!"
            !build!
            echo build !sourceLib!
            cd /d %_pathCurrent%
        )
        for %%f in (!root!\*.c) do (
            set sourceLib=%%f
            set outputLib=%_pathBuildOut%\%%~nxf.o
            echo !outputLib!>>%_pathStaticConf%
            cd /d %_pathTools%
            set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% !pathlibraries! -I"!root!" "!sourceLib!" -o "!outputLib!"
            !build!
            echo build !sourceLib!
            cd /d %_pathCurrent%
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
        if !extension! == .cpp (
            cd /d %_pathTools%
            set build=%_compiler-g++% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -mlongcalls -mtext-section-literals -fno-exceptions -fno-rtti -falign-functions=4 -std=c++11 -MMD -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% !pathLib! -I"!root:~0,-1!" "!sourceInc!" -o "!outputInc!"
            !build!
            echo build !sourceInc!
            set slibrary=%_compiler-static-library% cru "!staticInc!" "!outputInc!"
            !slibrary!
            echo build static library !outputInc!
            cd /d %_pathCurrent%
        )
        if !extension! == .c (
            cd /d %_pathTools%
            set build=%_compiler-gcc% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -Wpointer-arith -Wno-implicit-function-declaration -Wl,-EL -fno-inline-functions -nostdlib -mlongcalls -mtext-section-literals -falign-functions=4 -MMD -std=gnu99 -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% !pathLib! -I"!root:~0,-1!" "!sourceInc!" -o "!outputInc!"
            !build!
            echo build !sourceInc!
            set slibrary=%_compiler-static-library% cru "!staticInc!" "!outputInc!"
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
set compile=%_compiler-g++% -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__ -I%_pathSDKInc% -I%_pathSDKlwip2% -I%_pathSDKlibc% -c -w -Os -g -mlongcalls -mtext-section-literals -fno-exceptions -fno-rtti -falign-functions=4 -std=c++11 -MMD -ffunction-sections -fdata-sections -DF_CPU=80000000L -DLWIP_OPEN_SRC -DTCP_MSS=536 -DARDUINO=10810 -DARDUINO_ESP8266_GENERIC -DARDUINO_ARCH_ESP8266 "-DARDUINO_BOARD=\"ESP8266_GENERIC\"" -DESP8266 -I%_pathCore% -I%_pathVariant% !pathLib! !pathInc! "!_pathSourceFile!" -o "!_pathSourceOut!"
!compile!
echo build !_pathSourceFile!

if exist %_pathHeaderFileConf% (
    for /F "delims=" %%f in ('Type "%_pathHeaderFileConf%"') do (
        echo %%f>>%_pathStaticConf%
    )
)

if exist %_pathStaticConf% (
    for /F "delims= tokens=1*" %%f in ('Type "%_pathStaticConf%"') do (
        set staticLink="%%f" !staticLink!
    )
)

if exist !_pathSourceOut! (
    set buildELF=%_compiler-gcc% -g -w -Os -nostdlib -Wl,--no-check-sections -u call_user_start -u _printf_float -u _scanf_float -Wl,-static -L%_pathSDKlib% -L%_pathSDKld% -L%_pathSDKelflib% -Teagle.flash.1m64.ld -Wl,--gc-sections -Wl,-wrap,system_restart_local -Wl,-wrap,spi_flash_read -o "!_pathSourceELF!" -Wl,--start-group "!_pathSourceOut!" !staticLink!%_pathStaticLibraryCore% -lhal -lphy -lpp -lnet80211 -llwip2 -lwpa -lcrypto -lmain -lwps -laxtls -lespnow -lsmartconfig -lairkiss -lmesh -lwpa2 -lstdc++ -lm -lc -lgcc -Wl,--end-group
    !buildELF!
    echo compile !_pathSourceELF!
) else (
    goto :UNSUCCESS
)

if not exist !_pathSourceELF! ( goto :UNSUCCESS )

::cd /d %_pathArduino%
set buildBin=%_compiler-upload% -eo %_pathConf% -bo "!_pathSourceBIN!" -bm dout -bf 40 -bz 1M -bs .text -bp 4096 -ec -eo "!_pathSourceELF!" -bs .irom0.text -bs .text -bs .data -bs .rodata -bc -ec
%buildBin%
echo compile binary !_pathSourceELF!

if exist !_pathSourceBIN! (
    goto :UPLOAD
) else (
    goto :UNSUCCESS
)

:UPLOAD
set /p ask=Do you want to upload (Y/N):
if %ask%==Y (
    goto :YES
) else (
    goto :NO
)

:YES
::Show list Port
echo List COM port.
cd /d %_pathCurrent%
%_tools_listPort%

::enter the name port com
set /p port=Enter port name:
for /f "delims=" %%f in ('mode %port%') do (
    set status=%%f
)
set result=Illegal device name - %port%
::kiểm tra cổng COM valid ?
if "!status!" == "%reuslt%" (
    echo %port% invaild
    goto :UNSUCCESS
)
::cd /d %_pathArduino%
set upload=%_compiler-upload% -vv -cd ck -cb 115200 -cp %port% -ca 0x00000 -cf "%_pathSourceBIN%"
%upload%
echo Upload done !!!
pause
goto :eof

:NO
echo Build successfull !!!
pause
goto :eof

:UNSUCCESS
echo Build Unsuccessfull !!!
pause
goto :eof