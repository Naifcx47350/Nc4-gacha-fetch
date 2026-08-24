<#
.SYNOPSIS
    Show every palette with a random art. Dummy specs. Does not touch pity.

.DESCRIPTION
    Press Enter to step to the next one. Each preview is tagged with what you
    are looking at: nothing for a normal palette, [shiny] for its refoiled form,
    [exclusive] for the two that override the roll instead of refoiling it.

.PARAMETER Shiny
    Show the shiny form of each palette instead of the normal one.

.PARAMETER Both
    Show each palette and then its shiny form back to back, which is the easiest
    way to see what refoiling actually does to a given set of colours.
#>
[CmdletBinding()]
param(
    [switch]$Shiny,
    [switch]$Both
)

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

# The exclusives replace the rolled palette rather than refoiling it, so they
# have no separate shiny form to show.
$exBlock = [regex]::Match($src, '\$shinyPalettes\s*=\s*@\((.+?)^\)', 'Singleline,Multiline').Groups[1].Value
$exclusives = @(
    [regex]::Matches($exBlock, "Name\s*=\s*'([^']+)'") |
        ForEach-Object { $_.Groups[1].Value }
)

$arts = @(Get-ChildItem -Path (Join-Path $env:NC4_FETCH_ROOT 'Ascii') -Filter '*.txt' -File -Recurse |
    Where-Object { $_.Name -ne 'ascii_current.txt' })
if (-not $arts) { Write-Error 'No art files found.'; exit 1 }

$showPlain = $Both -or -not $Shiny
$showFoil = $Both -or $Shiny

$queue = [System.Collections.Generic.List[object]]::new()
foreach ($name in $names) {
    if ($exclusives -contains $name) {
        $queue.Add([pscustomobject]@{ Name = $name; Foil = $false; Tag = '[exclusive]' })
        continue
    }
    if ($showPlain) { $queue.Add([pscustomobject]@{ Name = $name; Foil = $false; Tag = '' }) }
    if ($showFoil) { $queue.Add([pscustomobject]@{ Name = $name; Foil = $true; Tag = '[shiny]' }) }
}

$i = 0
foreach ($item in $queue) {
    $i++
    $artPick = $arts[(Get-Random -Minimum 0 -Maximum $arts.Count)]
    $label = ('{0} {1}' -f $item.Name, $item.Tag).Trim()
    Write-Host ("preview {0}/{1}  {2}  +  {3}" -f $i, $queue.Count, $label, $artPick.Name) -ForegroundColor Cyan
    $env:NC4_FETCH_NOSTATE = '1'
    if ($item.Foil) { & $rf -Demo -Palette $item.Name -Art $artPick.Name -Shiny }
    else { & $rf -Demo -Palette $item.Name -Art $artPick.Name }
    Remove-Item Env:NC4_FETCH_NOSTATE -ErrorAction SilentlyContinue
    if ($i -lt $queue.Count) { Read-Host 'Enter for the next palette' }
}
