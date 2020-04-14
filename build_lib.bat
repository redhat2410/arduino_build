@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set _pathCurrent=%cd%
set _pathBuildCore=%_pathCurrent%\core
set _pathBuildLib=%_pathCurrent%\Libraries
set _pathBuildLibModule=%_pathBuildLib%\Lib
set _pathBuildInc=%_pathCurrent%\inc
set _pathBuildOut=%_pathCurrent%\Output
set _pathBuildScr=%_pathCurrent%\src
set _pathBuildTool=%_pathCurrent%\tools
set _pathBuildEtc=%_pathBuildTool%\etc
set _pathPathFileConf=%_pathBuildEtc%\path.conf
set _pathHeaderFileConf=%_pathBuildEtc%\header.conf
set _pathArduinoConf=%_pathBuildEtc%\pathArduino.conf
set _pathStaticLibraryCore=%_pathBuildCore%\core.a
set _pathStaticLibraryLib=%_pathBuildLib%\lib.a
set _pathStaticLibraryInc=%_pathBuildInc%\inc.a

set _pathLibrary="C:\Program Files (x86)\Arduino\hardware\arduino\avr\libraries"

set _tools_search=tools\search
set _compiler-gcc=avr-gcc
set _compiler-g++=avr-g++

for /d %%f in (%_pathLibrary%\*) do (
    set _pathRoot=%%f
    ::compile file .cpp
    for %%r in ("!_pathRoot!"\src\*.cpp) do (
        set pathSource=%%r
        set pathSourceOut=%_pathBuildLib%\%%~nxr.o
        set _exec=%_compiler-g++% -c -g -Os -w -std=gnu++11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% "!pathSource!" -o "!pathSourceOut!"
        ::!_exec!
        echo !_exec!
        set _static=%_compiler-static-library% rcs %_pathStaticLibraryLib% "!pathSourceOut!"
        ::!_static!
        echo !_static!
    )
    ::compile file .h
    for %%r in ("!_pathRoot!"\src\*.h) do (
        set _copy=cp -r %%r %_pathBuildLib%
        ::!_copy!
        echo !_copy!
    )
    
    for /d %%r in ("!_pathRoot!"\src\*) do (
        set _pathDir=%%r
        for %%d in ("!_pathDir!"\*.c) do (
            set pathSource=%%d
            set pathSourceOut=%_pathBuildLib%\%%~nxd.o
            set _exec=%_compiler-gcc% -c -g -Os -w -std=gnu11 -mmcu=%_opt-mcu% -DF_CPU=%_opt-frq-16M% -I%_pathCore% -I%_pathVariant% "!pathSource!" -o "!pathSourceOut!" 
            ::!_exec!
            echo !_exec!
            set _static=%_compiler-static-library% rcs %_pathStaticLibraryLib% "!pathSourceOut!"
            ::!_static!
            echo !_static!
        )
    )
)