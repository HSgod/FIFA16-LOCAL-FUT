@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title FIFA 16 Local FUT Server

echo ============================================================
echo  FIFA 16 LOCAL FUT SERVER - OFFLINE ULTIMATE TEAM
echo ============================================================
echo.

set "PY="
where py.exe >nul 2>nul
if not errorlevel 1 set "PY=py -3"

if not defined PY (
    where python.exe >nul 2>nul
    if not errorlevel 1 set "PY=python"
)

if not defined PY (
    for %%V in (Python313 Python312 Python311 Python310) do (
        if exist "%LOCALAPPDATA%\Programs\Python\%%V\python.exe" (
            set "PY=%LOCALAPPDATA%\Programs\Python\%%V\python.exe"
            goto :py_ready
        )
    )
)

:py_ready
if not defined PY (
    echo ERROR: Python 3 nie zostal znaleziony.
    echo Uruchom INSTALL_PREREQUISITES.cmd, aby zainstalowac Pythona bez uprawnien admina.
    echo.
    pause
    exit /b 1
)

call "%~dp0STOP_LOCAL_FUT16.cmd" /quiet >nul 2>nul

echo Sprawdzanie biblioteki cryptography...
%PY% -c "import cryptography" >nul 2>nul
if errorlevel 1 (
    echo Instalowanie cryptography w profilu uzytkownika...
    %PY% -m pip install --user --disable-pip-version-check cryptography
    if errorlevel 1 (
        echo ERROR: Nie udalo sie zainstalowac pakietu cryptography.
        pause
        exit /b 3
    )
)

echo Uruchamianie lokalnego serwera FUT (127.0.0.1)...
%PY% "%~dp0localfut16\server.py"
set "RC=%ERRORLEVEL%"
echo.
echo Serwer Local FUT zakonczyl dzialanie z kodem: %RC%.
echo.
pause
exit /b %RC%
