@echo off
chcp 65001 > nul
title Green Flow - Smart Agriculture Launcher

echo.
echo  ╔════════════════════════════════════════════════════╗
echo  ║   🌿  GREEN FLOW - Smart Agriculture Launcher     ║
echo  ║   يبدأ المحاكي + التطبيق تلقائياً               ║
echo  ╚════════════════════════════════════════════════════╝
echo.

REM ── Step 1: Start Python Virtual ESP32 Simulator in a new window ──────────
echo [1/2] بدء محاكي ESP32 Python في نافذة جديدة...

REM Try different python commands (handles both Store alias and real install)
where python >nul 2>&1
if %ERRORLEVEL% == 0 (
    start "🌿 Green Flow - ESP32 Simulator" cmd /k "chcp 65001 > nul && echo. && python hardware_simulation/virtual_esp32.py"
    goto :flutter_start
)

where python3 >nul 2>&1
if %ERRORLEVEL% == 0 (
    start "🌿 Green Flow - ESP32 Simulator" cmd /k "chcp 65001 > nul && echo. && python3 hardware_simulation/virtual_esp32.py"
    goto :flutter_start
)

REM Try py launcher
where py >nul 2>&1
if %ERRORLEVEL% == 0 (
    start "🌿 Green Flow - ESP32 Simulator" cmd /k "chcp 65001 > nul && echo. && py hardware_simulation/virtual_esp32.py"
    goto :flutter_start
)

echo [تحذير] Python غير موجود في PATH.
echo         شغّل المحاكي يدوياً: python hardware_simulation\virtual_esp32.py
echo.

:flutter_start
REM ── Step 2: Wait 2 seconds for bridge to start, then launch Flutter ────────
echo [2/2] انتظر لحظة ثم بدء Flutter على Chrome...
timeout /t 2 /nobreak > nul

set FLUTTER="C:\Users\Joo\devolop\flutter\bin\flutter.bat"

if exist %FLUTTER% (
    echo تشغيل Flutter Web...
    %FLUTTER% run -d chrome --web-port 60895
) else (
    echo [خطأ] Flutter غير موجود في: C:\Users\Joo\devolop\flutter\bin\flutter.bat
    echo       تحقق من المسار أو شغّل Flutter يدوياً: flutter run -d chrome
    pause
)
