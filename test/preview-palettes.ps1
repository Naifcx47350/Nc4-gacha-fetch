<#
.SYNOPSIS
    Show every palette with a random art. Dummy specs. Does not touch pity.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$env:NC4_FETCH_ROOT = Join-Path $repo 'fastfetch'
$rf = Join-Path $env:NC4_FETCH_ROOT 'scripts\randfetch.ps1'
if (-not (Test-Path $rf)) { Write-Error "randfetch not found: $rf"; exit 1 }

# -List uses Write-Host, so it cannot be captured. Read names from the engine.
$src = Get-Content -Path $rf -Raw -Encoding UTF8
$names = @(
    [regex]::Matches($src, "Name\s*=\s*'([^']+)'") |
        ForEach-Object { $_.Groups[1].Value }
)
if (-not $names) { Write-Error 'No palettes to preview.'; exit 1 }

$arts = @(Get-ChildItem -Path (Join-Path $env:NC4_FETCH_ROOT 'Ascii') -Filter '*.txt' -File -Recurse |
    Where-Object { $_.Name -ne 'ascii_current.txt' })
if (-not $arts) { Write-Error 'No art files found.'; exit 1 }

$i = 0
foreach ($name in $names) {
    $i++
    $artPick = $arts[(Get-Random -Minimum 0 -Maximum $arts.Count)]
    Write-Host ("preview {0}/{1}  {2}  +  {3}" -f $i, $names.Count, $name, $artPick.Name) -ForegroundColor Cyan
    $env:NC4_FETCH_NOSTATE = '1'
    & $rf -Demo -Palette $name -Art $artPick.Name
    Remove-Item Env:NC4_FETCH_NOSTATE -ErrorAction SilentlyContinue
    if ($i -lt $names.Count) { Read-Host 'Enter for the next palette' }
}
