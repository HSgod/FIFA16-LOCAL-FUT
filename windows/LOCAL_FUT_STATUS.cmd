@echo off
setlocal EnableExtensions
title FIFA 16 Local FUT Status

echo ============================================================
echo  FIFA 16 LOCAL FUT - SERVICE STATUS
echo ============================================================
echo.

set "F=%LOCALAPPDATA%\FIFA16LocalFUT\runtime_ports.json"
if exist "%F%" (
    echo Runtime ports found:
    type "%F%"
    echo.
) else (
    echo Runtime ports file not found (server may not be running).
)

echo.
echo Active localhost listening ports for Local FUT:
netstat -ano | findstr /R "127.0.0.1:42230 127.0.0.1:10051 127.0.0.1:17502 127.0.0.1:42232 127.0.0.1:8199 127.0.0.1:8099"

echo.
pause
endlocal
