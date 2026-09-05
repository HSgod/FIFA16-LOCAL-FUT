@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title FIFA 16 Local FUT Launcher

echo ============================================================
echo  FIFA 16 LOCAL FUT - OFFLINE LAUNCHER
echo ============================================================
echo  Uruchamianie lokalnego serwera + FIFA 16...
echo.

if not exist "%~dp0fifa16.exe" (
    echo ERROR: fifa16.exe nie zostal znaleziony w tym folderze.
    pause
    exit /b 1
)

call "%~dp0STOP_LOCAL_FUT16.cmd" /quiet >nul 2>nul
start "FIFA 16 Local FUT Server" cmd /c ""%~dp0START_LOCAL_FUT16.cmd""

echo Oczekiwanie na uruchomienie lokalnego serwera FUT...
set "READY=0"
for /L %%I in (1,1,30) do (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$f=Join-Path $env:LOCALAPPDATA 'FIFA16LocalFUT\runtime_ports.json'; if(-not (Test-Path $f)){exit 1}; try{$p=[int]((Get-Content $f -Raw | ConvertFrom-Json).fut_port); $c=New-Object Net.Sockets.TcpClient; $a=$c.BeginConnect('127.0.0.1',$p,$null,$null); if(-not $a.AsyncWaitHandle.WaitOne(300)){ $c.Close(); exit 1 }; $c.EndConnect($a); $c.Close(); exit 0}catch{exit 1}" >nul 2>nul
    if not errorlevel 1 (
        set "READY=1"
        goto :launch
    )
    timeout /t 1 /nobreak >nul
)

:launch
if "%READY%"=="0" (
    echo.
    echo ERROR: Serwer Local FUT nie odpowiedzial w wymaganym czasie.
    echo Sprawdz okno konsoli serwera oraz pliki logow w:
    echo %%LOCALAPPDATA%%\FIFA16LocalFUT\logs\
    echo.
    pause
    exit /b 2
)

echo Serwer Local FUT jest gotowy! Uruchamianie FIFA 16...
start "" "%~dp0fifa16.exe"
exit /b 0
