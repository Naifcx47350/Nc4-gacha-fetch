#Requires -Version 7
<#
.SYNOPSIS
    Open a PowerShell session that uses this repo's engine without
    replacing the live profile.
#>
[CmdletBinding()]
param(
    [switch]$Live,
    [switch]$Demo,
    [switch]$Installed
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$root = if ($Installed) {
    Join-Path $HOME '.config\fastfetch-test'
} else {
    Join-Path $repo 'fastfetch'
}
$theme = Join-Path $repo 'powershell\prompt\themes\nc4.omp.json'
$testProfile = Join-Path $repo 'powershell\test\Microsoft.PowerShell_profile.ps1'

if (-not (Test-Path $root)) { Write-Error "Fetch root not found: $root"; exit 1 }
if (-not (Test-Path $testProfile)) { Write-Error "Test profile not found: $testProfile"; exit 1 }

$useDemo = -not $Live
$demoLine = if ($useDemo) { "`$env:NC4_FETCH_DEMO = '1'; " } else { '' }
# Keep test rolls out of a linked install's real pity file.
$sandboxState = Join-Path $root 'gacha-state.json'
$cmd = "$demoLine`$env:NC4_FETCH_FORCE = '1'; `$env:NC4_FETCH_ROOT = '$root'; `$env:NC4_FETCH_STATE = '$sandboxState'; `$env:NC4_THEME = '$theme'; `$env:NC4_START_PATH = '$repo'; . '$testProfile'"

$mode = if ($useDemo) { 'dummy specs' } else { 'live specs' }
Write-Host "Launching test shell  root=$root  ($mode)" -ForegroundColor Cyan
pwsh -NoProfile -NoExit -Command $cmd
