@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set tools=tools\search_path.py
set _pathPathFileConf=tools\etc\path.conf

for /F "delims=" %%f in ('Type %_pathPathFileConf%') do (
    echo %%f
)