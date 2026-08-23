# nc4-gacha-fetch — prompt only (no gacha fetch)

# Set $Nc4StartPath to a folder if you want every new shell to start there.

$Nc4Theme = if ($env:NC4_THEME) {
    $env:NC4_THEME
} elseif (Test-Path (Join-Path $PSScriptRoot 'themes\nc4.omp.json')) {
    Join-Path $PSScriptRoot 'themes\nc4.omp.json'
} elseif (Test-Path (Join-Path $PSScriptRoot 'Nc4.omp.json')) {
    Join-Path $PSScriptRoot 'Nc4.omp.json'
} else {
    Join-Path (Split-Path -Parent $PROFILE.CurrentUserCurrentHost) 'themes\nc4.omp.json'
}

if (-not $Nc4StartPath) { $Nc4StartPath = $env:NC4_START_PATH }
if ($Nc4StartPath -and (Test-Path $Nc4StartPath)) {
    Set-Location $Nc4StartPath
}

Import-Module posh-git -ErrorAction SilentlyContinue

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path $Nc4Theme) {
        oh-my-posh init pwsh --config "$Nc4Theme" | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

Set-PSReadLineOption -BellStyle None
# Prediction needs a real console; it errors when output is piped or captured.
if (-not [Console]::IsOutputRedirected) {
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
}
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
Set-PSReadLineKeyHandler -Key Tab    -Function AcceptSuggestion

if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'
}

Import-Module z -ErrorAction SilentlyContinue

Set-Alias vim  nvim
Set-Alias ll   ls
Set-Alias g    git
Set-Alias grep findstr
Set-Alias cls  Clear-Host
Set-Alias c    Clear-Host
Set-Alias py   python
Set-Alias pip  pip3
Set-Alias wget Invoke-WebRequest
Set-Alias curl Invoke-WebRequest
