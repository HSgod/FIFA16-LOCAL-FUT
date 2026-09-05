@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { ($_.Name -eq 'python.exe' -or $_.Name -eq 'pythonw.exe') -and $_.CommandLine -like '*localfut16*server.py*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" >nul 2>nul
del /q "%LOCALAPPDATA%\FIFA16LocalFUT\runtime_ports.json" >nul 2>nul
if /i not "%~1"=="/quiet" (
  echo FIFA 16 Local FUT server stopped.
  pause
)
endlocal
