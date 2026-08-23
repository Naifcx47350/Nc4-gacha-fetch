# nc4-gacha-fetch — PowerShell 7 profile

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

$besideFetch = Join-Path $PSScriptRoot 'fastfetch'
$env:NC4_FETCH_ROOT = if ($env:NC4_FETCH_ROOT) {
    $env:NC4_FETCH_ROOT
} elseif (Test-Path (Join-Path $besideFetch 'scripts\randfetch.ps1')) {
    $besideFetch
} else {
    Join-Path $HOME '.config\fastfetch'
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
    if (Test-Path $rf) { & $rf }
}
Set-Alias reroll Reset-Fetch

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
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
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
            & $randfetch
        } elseif (Get-Command fastfetch -ErrorAction SilentlyContinue) {
            fastfetch
        }
    }
}
