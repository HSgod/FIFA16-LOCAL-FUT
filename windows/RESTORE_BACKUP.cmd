@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title FIFA 16 Local FUT - Restore Backup

echo ============================================================
echo  RESTORE ORIGINAL FIFA 16 FILES
echo ============================================================
echo.

set "BACKUP=%LOCALAPPDATA%\FIFA16LocalFUT\install-backup"
if not exist "%BACKUP%" (
    echo ERROR: No backup found at %BACKUP%.
    pause
    exit /b 1
)

set /p "GAME=Enter folder containing fifa16.exe: "
if not exist "%GAME%\fifa16.exe" (
    echo ERROR: fifa16.exe not found in %GAME%.
    pause
    exit /b 2
)

echo Restoring original files from backup...
for %%F in (dinput8.dll CardsDLLzf.dll ItsAMe_Origin.dll EA-MITM.ini cl.ini) do (
    if exist "%BACKUP%\%%F" (
        copy /y "%BACKUP%\%%F" "%GAME%\%%F" >nul
        echo Restored: %%F
    ) else (
        if exist "%GAME%\%%F" (
            del /f /q "%GAME%\%%F" >nul
            echo Removed Local FUT file: %%F
        )
    )
)

if exist "%BACKUP%\dlc_CardsDLL\CardsDLLzf.dll" (
    copy /y "%BACKUP%\dlc_CardsDLL\CardsDLLzf.dll" "%GAME%\dlc\dlc_CardsDLL\dlc\CardsDLLzf.dll" >nul
    echo Restored: dlc_CardsDLL\CardsDLLzf.dll
)

echo.
echo Backup restored successfully!
pause
endlocal
