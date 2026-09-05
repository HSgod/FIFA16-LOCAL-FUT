@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title FIFA 16 Local FUT - Add Coins

echo ============================================================
echo  FIFA 16 LOCAL FUT - DODAWANIE MONET (BEZ ADMINA)
echo ============================================================
echo  Zmienia stan monet w Twoim lokalnym zapisie SQLite.
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
    echo Uruchom INSTALL_PREREQUISITES.cmd.
    pause
    exit /b 1
)

set "AMOUNT="
set /p "AMOUNT=Liczba monet do dodania [domyslnie 1000000]: "
if not defined AMOUNT set "AMOUNT=1000000"

if exist "%~dp0localfut16\add_coins.py" (
    %PY% "%~dp0localfut16\add_coins.py" "%AMOUNT%"
) else (
    %PY% "%~dp0add_coins.py" "%AMOUNT%"
)
echo.
pause
endlocal
