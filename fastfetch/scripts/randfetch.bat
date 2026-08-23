@echo off
:: nc4-gacha-fetch :: launch the gacha fetch (PowerShell 7 required)
:: Usage: scripts\randfetch.bat [args passed through to randfetch.ps1]

setlocal
set "PS="
where pwsh.exe >nul 2>&1 && set "PS=pwsh.exe"
if not defined PS if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" set "PS=%ProgramFiles%\PowerShell\7\pwsh.exe"
if not defined PS if exist "%LocalAppData%\Microsoft\WindowsApps\pwsh.exe" set "PS=%LocalAppData%\Microsoft\WindowsApps\pwsh.exe"

if not defined PS (
    echo PowerShell 7 was not found. Install it with:  winget install Microsoft.PowerShell
    echo Windows PowerShell 5.1 cannot run this script - it writes files with a byte-order
    echo mark that fastfetch will not read.
    exit /b 1
)

"%PS%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0randfetch.ps1" %*
endlocal
