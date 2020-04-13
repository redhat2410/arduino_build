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

set _tools_search=tools\search

for %%f in (%_pathBuildScr%\*.cpp) do (
    set pathSource=%%f
    set pathSourceOut=%_pathBuildOut%\%%~nxf.o
    set toolsSearch=%_tools_search% !pathSource!
    %toolsSearch%
    echo %toolsSearch%
    ::sau khi chạy tools search
    if exist %_pathHeaderFileConf% (
        for /F "delims=" %%d in ('Type "%_pathHeaderFileConf%"') do (
            set pathRoot=%%d
            set pathLibModule=-I!pathRoot! !pathLibModule!
            for %%r in (!pathRoot!\*.cpp) do (
                echo %%r
            )
            for %%r in (!pathRoot!\*.c) do (
                echo %%r
            )
            for %%r in (!pathRoot!\*.h) do (
                echo %%r
            )
        )
    )
    echo !pathLibModule!
)