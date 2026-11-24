@echo off
chcp 65001 > nul
title Green Flow - Smart Agriculture Launcher

echo.
echo  ╔════════════════════════════════════════════════════════╗
echo  ║   🌿  GREEN FLOW  -  Smart Agriculture Launcher       ║
echo  ║   Auto-starts Python Bridge + Flutter Web App         ║
echo  ╚════════════════════════════════════════════════════════╝
echo.

set PYTHON=C:\Users\Joo\AppData\Local\Python\bin\python.exe
set FLUTTER=C:\Users\Joo\devolop\flutter\bin\flutter.bat

REM ── Step 1: Start Python Virtual ESP32 Simulator in a new window ──────────
echo [1/2] Starting ESP32 Python Simulator in a new window...
start "🌿 Green Flow - ESP32 Simulator" cmd /k "chcp 65001 > nul && echo. && %PYTHON% hardware_simulation/virtual_esp32.py"

REM Wait 2 seconds for bridge to bind on port 8088
echo     Waiting for bridge to start (2 sec)...
timeout /t 2 /nobreak > nul

REM ── Step 2: Launch Flutter on Chrome ──────────────────────────────────────
echo [2/2] Launching Flutter Web on Chrome...
%FLUTTER% run -d chrome

pause
