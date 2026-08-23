# nc4-gacha-fetch — isolated test profile
# Launch with test-shell.ps1. Does not replace $PROFILE.

if (-not $env:NC4_FETCH_ROOT) {
    $beside = Join-Path $PSScriptRoot 'fastfetch'
    $env:NC4_FETCH_ROOT = if (Test-Path (Join-Path $beside 'scripts\randfetch.ps1')) {
        $beside
    } else {
        Join-Path $HOME '.config\fastfetch'
    }
}

$Nc4Theme = if ($env:NC4_THEME) {
    $env:NC4_THEME
} elseif (Test-Path (Join-Path $PSScriptRoot 'themes\nc4.omp.json')) {
    Join-Path $PSScriptRoot 'themes\nc4.omp.json'
} else {
    Join-Path (Split-Path -Parent $PROFILE.CurrentUserCurrentHost) 'themes\nc4.omp.json'
}

$inVSCodeOrCursor = ($env:TERM_PROGRAM -eq 'vscode') -or
                    ($env:VSCODE_PID) -or
                    ($env:VSCODE_GIT_IPC_HANDLE) -or
                    ($env:VSCODE_IPC_HOOK)
$inJetBrainsIDE   = ($env:TERMINAL_EMULATOR -like 'JetBrains*') -or
                    ($env:TERM_PROGRAM -eq 'JetBrains-JediTerm')
$inIDE = $inVSCodeOrCursor -or $inJetBrainsIDE

function Reset-Fetch {
    $rf = Join-Path $env:NC4_FETCH_ROOT 'scripts\randfetch.ps1'
    $rfArgs = @()
    if ($env:NC4_FETCH_DEMO) { $rfArgs += '-Demo' }
    if (Test-Path $rf) { & $rf @rfArgs }
}
Set-Alias reroll Reset-Fetch

if ($env:NC4_START_PATH -and (Test-Path $env:NC4_START_PATH)) {
    Set-Location $env:NC4_START_PATH
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

if ((-not $inIDE -or $env:NC4_FETCH_FORCE) -and -not $env:FASTFETCH_DISABLE) {
    if (-not $global:FASTFETCH_RAN) {
        $global:FASTFETCH_RAN = $true
        $randfetch = Join-Path $env:NC4_FETCH_ROOT 'scripts\randfetch.ps1'
        if (Test-Path $randfetch) {
            if ($env:NC4_FETCH_DEMO) { & $randfetch -Demo } else { & $randfetch }
        } elseif (Get-Command fastfetch -ErrorAction SilentlyContinue) {
            fastfetch
        }
    }
}
