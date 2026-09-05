@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title FIFA 16 Local FUT - Prerequisites (No Admin Required)

echo ============================================================
echo  FIFA 16 LOCAL FUT - PREREQUISITES (NON-ADMIN INSTALLER)
echo ============================================================
echo  Ten instalator nie wymaga uprawnien Administratora!
echo  Zainstaluje potrzebne pakiety lokalnie na profilu uzytkownika.
echo.
echo  Sprawdzanie:
echo    [1/3] Python 3.10+ (wersja uzytkownika)
echo    [2/3] Pakiet Python cryptography (pip --user)
echo    [3/3] Biblioteki Visual C++ Runtime
echo.

set "PY="

rem Sprawdzanie py launcher i python w PATH
where py.exe >nul 2>nul
if not errorlevel 1 (
    py -3 -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
    if not errorlevel 1 set "PY=py -3"
)

if not defined PY (
    where python.exe >nul 2>nul
    if not errorlevel 1 (
        python -c "import sys; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
        if not errorlevel 1 set "PY=python"
    )
)

rem Sprawdzanie standardowych katalogow instalacji uzytkownika (bez admina)
if not defined PY (
    for %%V in (Python313 Python312 Python311 Python310) do (
        if exist "%LOCALAPPDATA%\Programs\Python\%%V\python.exe" (
            set "PY=%LOCALAPPDATA%\Programs\Python\%%V\python.exe"
            goto :found_py
        )
    )
)

:found_py
if not defined PY (
    echo [1/3] Python 3.10+ nie zostal wykryty. Rozpoczynanie instalacji bez uprawnien admina...
    
    where winget.exe >nul 2>nul
    if not errorlevel 1 (
        echo Proba instalacji przez winget (scope: user)...
        winget install --id Python.Python.3.12 --scope user -e --source winget --silent --accept-package-agreements --accept-source-agreements
        if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
            set "PY=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
        )
    )
    
    if not defined PY (
        echo Pobieranie instalatora Python 3.12 ze strony python.org...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$url='https://www.python.org/ftp/python/3.12.4/python-3.12.4-amd64.exe'; $out=Join-Path $env:TEMP 'python-installer.exe'; Write-Host 'Pobieranie...' -ForegroundColor Cyan; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile($url, $out); Write-Host 'Instalacja dla biezacego uzytkownika (bez uprawnien admina)...' -ForegroundColor Cyan; Start-Process -FilePath $out -ArgumentList '/passive InstallAllUsers=0 PrependPath=1 Include_pip=1' -Wait"
        if exist "%LOCALAPPDATA%\Programs\Python\Python312\python.exe" (
            set "PY=%LOCALAPPDATA%\Programs\Python\Python312\python.exe"
        )
    )
    
    if not defined PY (
        where py.exe >nul 2>nul
        if not errorlevel 1 set "PY=py -3"
    )
    if not defined PY (
        where python.exe >nul 2>nul
        if not errorlevel 1 set "PY=python"
    )
    
    if not defined PY (
        echo.
        echo UWAGA: Instalacja Pythona zostala uruchomiona.
        echo Jesli instalacja wlasnie sie zakonczyla, uruchom ten skrypt ponownie,
        echo aby odswiezyc sciezki PATH w systemie.
        pause
        exit /b 2
    )
)

echo [1/3] Python gotowy: %PY%

echo.
echo [2/3] Sprawdzanie pakietu Python: cryptography...
%PY% -c "import cryptography" >nul 2>nul
if errorlevel 1 (
    echo Instalowanie pakietu cryptography w profilu uzytkownika (pip --user)...
    %PY% -m pip install --user --disable-pip-version-check cryptography
    if errorlevel 1 (
        echo Proba instalacji pip/ensurepip...
        %PY% -m ensurepip --default-pip >nul 2>nul
        %PY% -m pip install --user --disable-pip-version-check cryptography
    )
)

%PY% -c "import cryptography" >nul 2>nul
if errorlevel 1 (
    echo ERROR: Nie udalo sie zainstalowac pakietu cryptography.
    pause
    exit /b 3
)
echo [2/3] Pakiet cryptography zainstalowany i gotowy.

echo.
echo [3/3] Sprawdzanie bibliotek Visual C++...
set "VC_FOUND=0"
if exist "%WINDIR%\System32\vcruntime140.dll" set "VC_FOUND=1"
if exist "%WINDIR%\System32\msvcr110.dll" set "VC_FOUND=1"
if "%VC_FOUND%"=="1" (
    echo [3/3] Biblioteki Visual C++ znalezione w systemie.
) else (
    echo Informacja: Nie wykryto vcruntime w System32.
    echo Jesli gra uruchamia sie normalnie, oznacza to ze gra ma te biblioteki w swoim folderze.
)

echo.
echo ============================================================
echo  SUKCES: Wszystkie wymagania spelnione BEZ uprawnien admina!
echo  Mozesz teraz uruchomic PLAY_LOCAL_FUT16.cmd
echo ============================================================
echo.
pause
exit /b 0
