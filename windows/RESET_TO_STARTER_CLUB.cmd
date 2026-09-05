@echo off
setlocal EnableExtensions
cd /d "%~dp0"
call "%~dp0STOP_LOCAL_FUT16.cmd" /quiet >nul 2>nul

echo ============================================================
echo  RESET FIFA 16 LOCAL FUT TO STARTER CLUB
echo ============================================================
echo  WARNING: This deletes your LOCAL FUT club/save database.
echo  It does not touch normal FIFA 16 Career Mode / Settings saves.
echo.
set /p "OK=Type RESET to continue: "
if /I not "%OK%"=="RESET" exit /b 0

set "ROOTSTATE=%LOCALAPPDATA%\FIFA16LocalFUT"
for %%F in (
    "%ROOTSTATE%\fut16-local.sqlite3"
    "%ROOTSTATE%\fut16-local.sqlite3-wal"
    "%ROOTSTATE%\fut16-local.sqlite3-shm"
) do if exist "%%~F" del /f /q "%%~F"

echo.
echo Reset complete. The next Local FUT launch will generate a fresh
echo starter club with 0 coins and bronze players.
echo.
pause
