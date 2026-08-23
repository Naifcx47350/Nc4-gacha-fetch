@echo off
:: nc4-gacha-fetch :: launch the gacha fetch (via PowerShell 7 if available)
:: Usage: scripts\randfetch.bat [args passed through to randfetch.ps1]

setlocal
set PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe
if exist "%ProgramFiles%\PowerShell\7\pwsh.exe" set PS="%ProgramFiles%\PowerShell\7\pwsh.exe"

%PS% -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0randfetch.ps1" %*
endlocal
