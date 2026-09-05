@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"
title FIFA 16 Local FUT Installer & Launcher

echo ============================================================
echo  FIFA 16 LOCAL FUT - OFFLINE ULTIMATE TEAM RESTORATION
echo ============================================================
echo.

set "PY="
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
if not defined PY (
    for %%V in (Python313 Python312 Python311 Python310) do (
        if exist "%LOCALAPPDATA%\Programs\Python\%%V\python.exe" (
            set "PY=%LOCALAPPDATA%\Programs\Python\%%V\python.exe"
            goto :py_ready
        )
    )
)

:py_ready
if not defined PY goto :prereq_missing
%PY% -c "import sys,cryptography; raise SystemExit(0 if sys.version_info >= (3,10) else 1)" >nul 2>nul
if errorlevel 1 goto :prereq_missing

set "SRC=%~dp0payload"
if not exist "%SRC%\localfut16\server.py" set "SRC=%~dp0..\payload"
if not exist "%SRC%\localfut16\server.py" (
    echo ERROR: Folder payload jest niekompletny.
    pause
    exit /b 2
)

set "GAME="
for /f "usebackq delims=" %%G in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$c=@(); $reg=@('HKLM:\SOFTWARE\EA Games\FIFA 16','HKLM:\SOFTWARE\WOW6432Node\EA Games\FIFA 16','HKCU:\SOFTWARE\EA Games\FIFA 16'); foreach($r in $reg){try{$p=Get-ItemProperty $r -ErrorAction Stop; foreach($n in 'Install Dir','InstallDir','InstallLocation'){if($p.PSObject.Properties.Name -contains $n){$v=$p.$n; if($v){$c+=$v}}}}catch{}}; $c += @('C:\Games\FIFA 16','D:\Games\FIFA 16','E:\Games\FIFA 16','C:\Program Files\EA Games\FIFA 16\Game','C:\Program Files\EA Games\FIFA 16','C:\Program Files (x86)\Origin Games\FIFA 16','C:\Program Files\Origin Games\FIFA 16'); foreach($x in $c){if(Test-Path (Join-Path $x 'fifa16.exe')){Write-Output $x; break}; if(Test-Path (Join-Path $x 'Game\fifa16.exe')){Write-Output (Join-Path $x 'Game'); break}}"`) do if not defined GAME set "GAME=%%G"

if not defined GAME (
    echo Nie wykryto automatycznie folderu gry FIFA 16.
    set /p "GAME=Wpisz sciezke do folderu z plikiem fifa16.exe: "
)
if defined GAME if "!GAME:~-1!"=="\" set "GAME=!GAME:~0,-1!"
if not exist "%GAME%\fifa16.exe" (
    echo.
    echo ERROR: Nie znaleziono fifa16.exe w folderze: "%GAME%"
    pause
    exit /b 3
)

rem Sprawdzenie uprawnien zapisu do folderu gry bez wymuszania admina
copy /y nul "%GAME%\.write_test" >nul 2>nul
if errorlevel 1 (
    echo Folder gry wymaga uprawnien administratora do zapisu (np. C:\Program Files^).
    echo Proba uruchomienia w trybie podwyzszonych uprawnien...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
) else (
    del /f /q "%GAME%\.write_test" >nul 2>nul
)

echo.
echo Wykryto FIFA 16 w: %GAME%
echo Skanowanie offsetow fifa16.exe...
%PY% "%~dp0find_fifa16_offsets.py" --exe "%GAME%\fifa16.exe" --output-dir "%SRC%"

set "BACKUP=%LOCALAPPDATA%\FIFA16LocalFUT\install-backup"
if not exist "%BACKUP%" mkdir "%BACKUP%" >nul 2>nul

if exist "%GAME%\STOP_LOCAL_FUT16.cmd" call "%GAME%\STOP_LOCAL_FUT16.cmd" /quiet >nul 2>nul
taskkill /IM fifa16.exe /F >nul 2>nul

for %%F in (dinput8.dll CardsDLLzf.dll ItsAMe_Origin.dll EA-MITM.ini cl.ini) do (
    if exist "%GAME%\%%F" if not exist "%BACKUP%\%%F" copy /y "%GAME%\%%F" "%BACKUP%\%%F" >nul
)

echo Kopiowanie plikow Local FUT do folderu gry...
xcopy "%SRC%\*" "%GAME%\" /E /I /H /Y >nul
if errorlevel 1 (
    echo ERROR: Nie udalo sie skopiowac plikow.
    pause
    exit /b 4
)

set "CARDS_DLC=%GAME%\dlc\dlc_CardsDLL\dlc\CardsDLLzf.dll"
if exist "%CARDS_DLC%" (
    if not exist "%BACKUP%\dlc_CardsDLL" mkdir "%BACKUP%\dlc_CardsDLL" >nul 2>nul
    if not exist "%BACKUP%\dlc_CardsDLL\CardsDLLzf.dll" copy /y "%CARDS_DLC%" "%BACKUP%\dlc_CardsDLL\CardsDLLzf.dll" >nul
    copy /y "%SRC%\CardsDLLzf.dll" "%CARDS_DLC%" >nul
)

if not exist "%LOCALAPPDATA%\FIFA16LocalFUT" mkdir "%LOCALAPPDATA%\FIFA16LocalFUT" >nul 2>nul
echo v1.0.0-fifa16-release>"%LOCALAPPDATA%\FIFA16LocalFUT\installed-version.txt"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$game='%GAME%'; $desktop=[Environment]::GetFolderPath('Desktop'); $lnk=Join-Path $desktop 'FIFA 16 Local FUT.lnk'; $w=New-Object -ComObject WScript.Shell; $s=$w.CreateShortcut($lnk); $s.TargetPath=Join-Path $game 'PLAY_LOCAL_FUT16.cmd'; $s.WorkingDirectory=$game; $s.IconLocation=(Join-Path $game 'fifa16.exe')+',0'; $s.Description='FIFA 16 Local FUT Offline'; $s.Save()" >nul 2>nul

echo.
echo Instalacja pomyslna!
echo Uruchamianie FIFA 16 Local FUT...
start "" "%GAME%\PLAY_LOCAL_FUT16.cmd"
exit /b 0

:prereq_missing
echo Wymagane pakiety nie sa zainstalowane (Python 3.10+ lub cryptography).
echo Uruchamianie instalatora zaleznosci bez uprawnien admina (INSTALL_PREREQUISITES.cmd)...
call "%~dp0INSTALL_PREREQUISITES.cmd"
echo.
pause
exit /b 1
