@echo off 
SETLOCAL ENABLEDELAYEDEXPANSION

set _opt-mcu-328=atmega328p
set _opt-frq-16M=16000000L
set _opt-frq-8M=8000000L
set _opt-baud_115200=115200
set _opt-baud_57600=57600

echo Please choose Arduino
echo 1. ARDUINO UNO
echo 2. ARDUINO PRO MINI

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
) else (
    echo No board.
)


echo %_opt-mcu%
echo %_opt-frq%
echo %_opt-baud%