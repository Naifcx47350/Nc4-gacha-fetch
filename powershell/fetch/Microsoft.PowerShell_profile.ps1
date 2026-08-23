# nc4-gacha-fetch — gacha fetch only (no oh-my-posh prompt)

# Set $Nc4StartPath to a folder if you want every new shell to start there.

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
