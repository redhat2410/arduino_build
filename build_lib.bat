@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

::file build_lib thực hiện link các thư viện module ngoài cho compiler
::đầu vào cần vị trí của bộ thư viện Example: C:\Users\admin\Documents\Arduino
set _pathStatic="C:\Users\admin\Desktop\build_arduino\Libraries\Lib"

for %%f in (%_pathStatic%/*.a) do (
    set result="%%f" !result!
)

echo !result!
