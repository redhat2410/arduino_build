@echo off 
SETLOCAL ENABLEDELAYEDEXPANSION

set _pathBackupLibConf="C:\Users\admin\Desktop\arduino_build\tools\etc\backupLib.conf"

if exist %_pathBackupLibConf% (
    for /F "delims=" %%r in ('Type "%_pathBackupLibConf%"') do (
        set root=%%r
        set pathLib=-I"%%~fr" !pathLib!

        for %%f in (!root!\*.cpp) do (
            set sourceLib=%%f
            set outputLib=%_pathBuildOut%\%%~nxf.o
            set build=%_compiler-g++% -c -g -Os -w -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq% -DARDUINO=10810 -I%_pathCore% -I%_pathVariant% -I%_pathBuildLib% -I"!root!" "!sourceLib!" -o "!outputLib!"
            echo !build!
        )

        for %%f in (!root!\*.c) do (
            echo %%f
        )
    )
)
