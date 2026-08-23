#Requires -Version 7
<#
.SYNOPSIS
    Install nc4-gacha-fetch in parts.

.DESCRIPTION
    1 / All     prompt + gacha fetch (default)
    2 / Prompt  oh-my-posh theme, aliases, modules
    3 / Fetch   gacha engine only

    Only PowerShell 7's own profile is changed. Windows PowerShell 5.1, conda
    (AllHosts), Modules folders, and an existing oh-my-posh theme file are left
    alone. Gacha state (pity and roll history) is carried across reinstalls.

    -InstallModules  install the PowerShell modules that part needs
    -InstallTools    install oh-my-posh and/or fastfetch via winget
    -Link            run the engine straight from this repo instead of copying
                     it, so art you add here appears in the next new tab
    -Test            copy the engine to a test folder; do not change $PROFILE
    -KeepBackups     timestamped backups to keep per item (default 3, 0 = all)
    -WhatIf          report every change without making it

.EXAMPLE
    ./install.ps1 1 -InstallModules -InstallTools
    Normal install. Self-contained copy beside your profile.

.EXAMPLE
    ./install.ps1 1 -Link
    Author install. One engine, this repo, live edits.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Position = 0)]
    [ValidateSet('1', '2', '3', 'All', 'Both', 'Prompt', 'Fetch', 'Gacha')]
    [string]$Part = '1',

    [switch]$InstallModules,
    [switch]$InstallTools,
    [switch]$Link,
    [switch]$Test,

    [ValidateRange(0, 100)]
    [int]$KeepBackups = 3
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$profileDir = Split-Path -Parent $PROFILE.CurrentUserCurrentHost
$engineDst = Join-Path $profileDir 'fastfetch'

# Nested helpers cannot see $PSCmdlet reliably; capture it once.
$script:Cmdlet = $PSCmdlet

$mode = switch -Regex ($Part) {
    '^(1|All|Both)$'           { 'all' }
    '^(2|Prompt)$'             { 'prompt' }
    '^(3|Fetch|Gacha)$'        { 'fetch' }
}

$repoEngine = Join-Path $repo 'fastfetch'
$linkedState = Join-Path $profileDir 'gacha-state.json'

function Set-UserVar([string]$name, [string]$value) {
    $current = [Environment]::GetEnvironmentVariable($name, 'User')
    if ($current -eq $value) { return }
    $what = if ($value) { "Set to $value" } else { 'Clear' }
    if ($script:Cmdlet.ShouldProcess("user environment variable $name", $what)) {
        [Environment]::SetEnvironmentVariable($name, $value, 'User')
        Set-Item -Path "Env:$name" -Value $value -ErrorAction SilentlyContinue
        if (-not $value) { Remove-Item -Path "Env:$name" -ErrorAction SilentlyContinue }
        Write-Host ("  {0} {1}" -f $(if ($value) { 'set' } else { 'cleared' }), $name) -ForegroundColor DarkGray
    }
}

function Get-AnyExistingState {
    foreach ($p in @($linkedState, (Join-Path $engineDst 'gacha-state.json'), (Join-Path $HOME '.config\fastfetch\gacha-state.json'))) {
        if (Test-Path $p) { return (Get-Content -LiteralPath $p -Raw -Encoding UTF8) }
    }
    return $null
}

function Remove-EngineCopy([string]$path, [string]$label) {
    if (-not (Test-Path (Join-Path $path 'scripts\randfetch.ps1'))) { return }
    Write-Host "`nRetiring the $label engine copy..." -ForegroundColor Cyan
    Backup-IfExists $path
    if ($script:Cmdlet.ShouldProcess($path, 'Remove engine copy')) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host "  removed -> $path" -ForegroundColor DarkGray
    }
}

function Remove-OldBackups([string]$path) {
    if ($KeepBackups -le 0) { return }
    $parent = Split-Path -Parent $path
    $leaf = Split-Path -Leaf $path
    $old = @(Get-ChildItem -LiteralPath $parent -Filter "$leaf.bak-*" -Force -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending | Select-Object -Skip $KeepBackups)
    foreach ($item in $old) {
        if ($script:Cmdlet.ShouldProcess($item.FullName, 'Remove old backup')) {
            Remove-Item -LiteralPath $item.FullName -Recurse -Force
            Write-Host "  pruned old backup -> $($item.Name)" -ForegroundColor DarkGray
        }
    }
}

function Backup-IfExists([string]$path) {
    if (-not (Test-Path $path)) { return }
    $bak = "$path.bak-$stamp"
    if ($script:Cmdlet.ShouldProcess($path, "Back up to $bak")) {
        if ((Get-Item $path) -is [System.IO.DirectoryInfo]) {
            Copy-Item -Path $path -Destination $bak -Recurse -Force
        } else {
            Copy-Item -Path $path -Destination $bak -Force
        }
        Write-Host "  backed up -> $bak" -ForegroundColor DarkGray
    }
    Remove-OldBackups $path
}

function Copy-Into([string]$src, [string]$dst) {
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) {
        if ($script:Cmdlet.ShouldProcess($dir, 'Create directory')) {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
        }
    }
    Backup-IfExists $dst
    if ($script:Cmdlet.ShouldProcess($dst, 'Install file')) {
        Copy-Item -Path $src -Destination $dst -Force
        Write-Host "  installed -> $dst" -ForegroundColor Green
    }
}

function Copy-FastfetchTree([string]$dest) {
    # Pity and roll history belong to the player, not the install.
    $statePath = Join-Path $dest 'gacha-state.json'
    $keptState = if (Test-Path $statePath) {
        Get-Content -LiteralPath $statePath -Raw -Encoding UTF8
    } else { $null }

    if (Test-Path $dest) {
        Backup-IfExists $dest
        if ($script:Cmdlet.ShouldProcess($dest, 'Replace engine folder')) {
            Remove-Item -LiteralPath $dest -Recurse -Force
        }
    }
    if (-not $script:Cmdlet.ShouldProcess($dest, 'Install engine')) { return }

    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem -Path (Join-Path $repo 'fastfetch') -Force |
        Where-Object { $_.Name -notin @('config.jsonc', 'gacha-state.json') } |
        Copy-Item -Destination $dest -Recurse -Force
    foreach ($g in @(
        (Join-Path $dest 'config.jsonc'),
        (Join-Path $dest 'gacha-state.json'),
        (Join-Path $dest 'Ascii\ascii_current.txt')
    )) {
        if (Test-Path $g) { Remove-Item -Force $g }
    }
    Write-Host "  installed -> $dest" -ForegroundColor Green

    if ($keptState) {
        Set-Content -LiteralPath $statePath -Value $keptState -Encoding UTF8
        Write-Host "  kept your gacha state (pity and history)" -ForegroundColor DarkGray
    }
}

function Install-Theme {
    $themeSrc = Join-Path $repo 'powershell\prompt\themes\nc4.omp.json'
    $themeBeside = Join-Path $profileDir 'Nc4.omp.json'
    $themeNested = Join-Path $profileDir 'themes\nc4.omp.json'
    if (-not (Test-Path $themeBeside) -and -not (Test-Path $themeNested)) {
        Write-Host "`nInstalling oh-my-posh theme..." -ForegroundColor Cyan
        Copy-Into $themeSrc $themeNested
    } else {
        Write-Host "`nExisting oh-my-posh theme left in place." -ForegroundColor DarkGray
    }
}

function Install-Profile([string]$src) {
    Write-Host "`nUpdating PowerShell 7 profile (AllHosts / conda / Modules are not touched)..." -ForegroundColor Cyan
    $oldProfile = $PROFILE.CurrentUserCurrentHost
    $recoveredStart = $null
    if (Test-Path $oldProfile) {
        $oldText = Get-Content -Path $oldProfile -Raw -ErrorAction SilentlyContinue
        if ($oldText -match '(?m)^\s*\$Nc4StartPath\s*=\s*[''"]([^''"]+)[''"]') {
            $recoveredStart = $Matches[1]
        } elseif ($oldText -match '(?m)^\s*(?:Set-Location|cd)\s+[''"]?([^''"\r\n#]+)[''"]?') {
            $candidate = $Matches[1].Trim()
            if ($candidate -and (Test-Path $candidate)) { $recoveredStart = $candidate }
        }
    }
    Copy-Into $src $oldProfile
    if ($recoveredStart -and $script:Cmdlet.ShouldProcess($oldProfile, "Keep start path $recoveredStart")) {
        $fresh = Get-Content -Path $oldProfile -Raw -Encoding UTF8
        $fresh = $fresh -replace '(?m)^# Set \$Nc4StartPath to a folder if you want every new shell to start there\.\s*$', ('$Nc4StartPath = ''{0}''' -f $recoveredStart)
        Set-Content -Path $oldProfile -Value $fresh -Encoding UTF8
        Write-Host "  kept start path -> $recoveredStart" -ForegroundColor DarkGray
    }
}

function Install-Engine {
    # Self-contained copy. This is what people who clone the repo get.
    $carried = Get-AnyExistingState
    $newState = Join-Path $engineDst 'gacha-state.json'

    Write-Host "`nInstalling gacha engine beside the PowerShell profile..." -ForegroundColor Cyan
    if (-not (Test-Path $profileDir)) {
        if ($script:Cmdlet.ShouldProcess($profileDir, 'Create profile directory')) {
            New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
        }
    }
    Copy-FastfetchTree $engineDst

    if ($carried -and $script:Cmdlet.ShouldProcess($newState, 'Carry gacha state into the new copy')) {
        Set-Content -LiteralPath $newState -Value $carried -Encoding UTF8
        Write-Host "  carried your gacha state into the copy" -ForegroundColor DarkGray
    }

    # A previous -Link install would otherwise keep overriding this copy.
    Write-Host "`nPointing the fetch at the installed copy..." -ForegroundColor Cyan
    Set-UserVar 'NC4_FETCH_ROOT' $null
    Set-UserVar 'NC4_FETCH_STATE' $null

    Remove-EngineCopy (Join-Path $HOME '.config\fastfetch') 'unused ~/.config'
}

function Install-EngineLink {
    # One engine: this repo. Edits here show up in the next new tab.
    if (-not (Test-Path (Join-Path $repoEngine 'scripts\randfetch.ps1'))) {
        Write-Error "Cannot link: no engine found at $repoEngine"
        return
    }

    Write-Host "`nLinking the fetch to this repo (no copy is made)..." -ForegroundColor Cyan
    Write-Host "  engine -> $repoEngine" -ForegroundColor Green

    # Pity lives outside the repo so `git clean` and branch switches cannot eat it.
    $carried = Get-AnyExistingState
    if ($carried -and -not (Test-Path $linkedState)) {
        if ($script:Cmdlet.ShouldProcess($linkedState, 'Move gacha state out of the repo')) {
            Set-Content -LiteralPath $linkedState -Value $carried -Encoding UTF8
            Write-Host "  gacha state -> $linkedState" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  gacha state -> $linkedState" -ForegroundColor DarkGray
    }

    Set-UserVar 'NC4_FETCH_ROOT' $repoEngine
    Set-UserVar 'NC4_FETCH_STATE' $linkedState

    Remove-EngineCopy $engineDst 'copied profile-folder'
    Remove-EngineCopy (Join-Path $HOME '.config\fastfetch') 'unused ~/.config'

    Write-Host "`n  Note: keep this repo where it is. If you move or delete it," -ForegroundColor DarkGray
    Write-Host "  new tabs fall back to plain fastfetch until you re-run install." -ForegroundColor DarkGray
}

$label = if ($Link) { "$mode, linked to this repo" } else { $mode }
Write-Host "nc4-gacha-fetch installer  ($label)" -ForegroundColor Cyan
if ($WhatIfPreference) {
    Write-Host "Dry run: reporting changes only, nothing is written." -ForegroundColor Yellow
}

$wantPrompt = $mode -in @('all', 'prompt')
$wantFetch  = $mode -in @('all', 'fetch')

if ($Link -and $Test) {
    Write-Host "`n-Link and -Test do the opposite of each other. Pick one:" -ForegroundColor Yellow
    Write-Host "  -Link   run the fetch from this repo"
    Write-Host "  -Test   stage a throwaway copy and leave your profile alone"
    return
}
if ($Link -and -not $wantFetch) {
    Write-Host "`n-Link only affects the gacha engine, and this part does not install it." -ForegroundColor Yellow
    Write-Host "Use:  ./install.ps1 1 -Link   or   ./install.ps1 3 -Link"
    return
}

if ($InstallModules -and $wantPrompt) {
    Write-Host "`nInstalling PowerShell modules..." -ForegroundColor Cyan
    foreach ($m in 'posh-git', 'Terminal-Icons', 'PSFzf', 'z') {
        if (-not (Get-Module -ListAvailable -Name $m)) {
            if ($PSCmdlet.ShouldProcess($m, 'Install-Module')) {
                Install-Module -Name $m -Scope CurrentUser -Force -AllowClobber
            }
        } else {
            Write-Host "  $m already installed" -ForegroundColor DarkGray
        }
    }
} elseif ($InstallModules) {
    Write-Host "`n-InstallModules does nothing for this part; it has no modules." -ForegroundColor DarkGray
}

if ($InstallTools) {
    Write-Host "`nInstalling tools (winget)..." -ForegroundColor Cyan
    $pkgs = @()
    if ($wantPrompt) { $pkgs += 'JanDeDobbeleer.OhMyPosh' }
    if ($wantFetch)  { $pkgs += 'Fastfetch-cli.Fastfetch' }
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        foreach ($pkg in $pkgs) {
            if ($PSCmdlet.ShouldProcess($pkg, 'winget install')) {
                winget install --id $pkg -e --accept-source-agreements --accept-package-agreements
            }
        }
    } else {
        Write-Warning 'winget not found. Install the tools for this part manually (see README).'
    }
}

if ($Test) {
    if (-not $wantFetch) {
        Write-Host "`n-Test only stages the gacha engine, and this part does not install it." -ForegroundColor Yellow
        Write-Host "Use:  ./install.ps1 1 -Test   or   ./install.ps1 3 -Test"
        return
    }
    Write-Host "`nCopying engine only (live profile is not touched)..." -ForegroundColor Cyan
    Copy-FastfetchTree (Join-Path $HOME '.config\fastfetch-test')
    Write-Host "`nDone. Launch:  .\test-shell.ps1 -Installed"
    return
}

if ($wantFetch) {
    if ($Link) { Install-EngineLink } else { Install-Engine }
}
if ($wantPrompt) { Install-Theme }

$profileSrc = Join-Path $repo "powershell\$mode\Microsoft.PowerShell_profile.ps1"
Install-Profile $profileSrc

Write-Host "`nDone." -ForegroundColor Cyan
switch ($mode) {
    'all'    { Write-Host "Open a new PowerShell 7 tab, or run: reroll" }
    'prompt' { Write-Host "Open a new PowerShell 7 tab to load the prompt." }
    'fetch'  { Write-Host "Open a new PowerShell 7 tab, or run: reroll" }
}
if ($Link) {
    Write-Host "Art you add under fastfetch\Ascii\ now shows up without reinstalling." -ForegroundColor DarkGray
}
