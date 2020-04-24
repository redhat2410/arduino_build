@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set _pathBackupLibConf="C:\Users\admin\Desktop\arduino_build\tools\etc\backupLib.conf"
set _pathTempSourceConf= "C:\Users\admin\Desktop\arduino_build\tools\etc\_temp.conf"

for %%f in (%cd%) do ( set sourceName=%%~nxf.cpp )
for %%f in (%_pathTempSourceConf%) do ( set sourceTemp=%%~nxf )


if not exist %cd%\!sourceName! (
    if exist %_pathTempSourceConf% (
        copy %_pathTempSourceConf% %cd%
        set tpath=%cd%\!sourceTemp!
        if exist !tpath! (
            set rename=ren !sourceTemp! !sourceName!
            !rename!
            echo rename !sourceTemp!
        )
    )
)