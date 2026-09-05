@echo off
setlocal EnableExtensions
title FIFA 16 Local FUT - Port Diagnostics

echo ============================================================
echo  FIFA 16 LOCAL FUT - PORT DIAGNOSTICS
echo ============================================================
echo.
echo Checking required ports (42230, 10051, 17502, 42232, 8199, 8099, 3216)...
echo.
for %%P in (42230 10051 17502 42232 8199 8099 3216) do (
    netstat -ano | findstr /R /C:":%%P " >nul
    if not errorlevel 1 (
        echo   Port %%P is OCCUPIED
    ) else (
        echo   Port %%P is FREE
    )
)
echo.
pause
endlocal
