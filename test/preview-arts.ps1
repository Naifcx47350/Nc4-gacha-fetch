<#
.SYNOPSIS
    Show every ASCII art in solid white so alignment is easy to judge.
    Dummy specs. Does not touch pity.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$env:NC4_FETCH_ROOT = Join-Path $repo 'fastfetch'
$rf = Join-Path $env:NC4_FETCH_ROOT 'scripts\randfetch.ps1'
if (-not (Test-Path $rf)) { Write-Error "randfetch not found: $rf"; exit 1 }

$arts = Get-ChildItem -Path (Join-Path $env:NC4_FETCH_ROOT 'Ascii') -Filter '*.txt' -File -Recurse |
    Where-Object { $_.Name -ne 'ascii_current.txt' } |
    Sort-Object Directory.Name, Name
if (-not $arts) { Write-Error 'No art files found.'; exit 1 }

$i = 0
foreach ($art in $arts) {
    $i++
    $cat = $art.Directory.Name
    Write-Host ("preview {0}/{1}  [{2}]  {3}" -f $i, $arts.Count, $cat, $art.Name) -ForegroundColor Cyan
    $env:NC4_FETCH_NOSTATE = '1'
    & $rf -Demo -LogoWhite -Palette Gray -Art $art.Name
    Remove-Item Env:NC4_FETCH_NOSTATE -ErrorAction SilentlyContinue
    if ($i -lt $arts.Count) { Read-Host 'Enter for the next art' }
}
