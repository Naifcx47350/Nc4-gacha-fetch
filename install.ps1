<#
.SYNOPSIS
    Install nc4-gacha-fetch next to your PowerShell 7 profile.

.DESCRIPTION
    Copies the gacha engine into <profileDir>\fastfetch and updates
    Microsoft.PowerShell_profile.ps1. Does not touch Modules, conda
    (profile.ps1 / AllHosts), or an existing oh-my-posh theme.

    -InstallModules  posh-git, Terminal-Icons, PSFzf, z
    -InstallTools    oh-my-posh + fastfetch (winget)
    -Test            copy the engine only; do not change $PROFILE
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$InstallModules,
    [switch]$InstallTools,
    [switch]$Test
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$profileDir = Split-Path -Parent $PROFILE.CurrentUserCurrentHost
$engineDst = Join-Path $profileDir 'fastfetch'

function Backup-IfExists([string]$path) {
    if (Test-Path $path) {
        $bak = "$path.bak-$stamp"
        if ((Get-Item $path) -is [System.IO.DirectoryInfo]) {
            Copy-Item -Path $path -Destination $bak -Recurse -Force
        } else {
            Copy-Item -Path $path -Destination $bak -Force
        }
        Write-Host "  backed up -> $bak" -ForegroundColor DarkGray
    }
}

function Copy-Into([string]$src, [string]$dst) {
    $dir = Split-Path -Parent $dst
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Backup-IfExists $dst
    Copy-Item -Path $src -Destination $dst -Force
    Write-Host "  installed -> $dst" -ForegroundColor Green
}

function Copy-FastfetchTree([string]$dest) {
    if (Test-Path $dest) {
        Backup-IfExists $dest
        Remove-Item -LiteralPath $dest -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildItem -Path (Join-Path $repo 'fastfetch') -Force |
        Where-Object { $_.Name -notin @('config.jsonc', 'gacha-state.json') } |
        Copy-Item -Destination $dest -Recurse -Force
    $generated = @(
        (Join-Path $dest 'config.jsonc'),
        (Join-Path $dest 'gacha-state.json'),
        (Join-Path $dest 'Ascii\ascii_current.txt')
    )
    foreach ($g in $generated) {
        if (Test-Path $g) { Remove-Item -Force $g }
    }
    Write-Host "  installed -> $dest" -ForegroundColor Green
}

Write-Host "nc4-gacha-fetch installer" -ForegroundColor Cyan

if ($InstallModules) {
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
}

if ($InstallTools) {
    Write-Host "`nInstalling tools (winget)..." -ForegroundColor Cyan
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        foreach ($pkg in 'JanDeDobbeleer.OhMyPosh', 'Fastfetch-cli.Fastfetch') {
            if ($PSCmdlet.ShouldProcess($pkg, 'winget install')) {
                winget install --id $pkg -e --accept-source-agreements --accept-package-agreements
            }
        }
    } else {
        Write-Warning 'winget not found. Install oh-my-posh and fastfetch manually (see README).'
    }
}

if ($Test) {
    Write-Host "`nCopying engine only (live profile is not touched)..." -ForegroundColor Cyan
    Copy-FastfetchTree (Join-Path $HOME '.config\fastfetch-test')
    Write-Host "`nDone. Launch:  .\test-shell.ps1"
    return
}

Write-Host "`nInstalling engine beside the PowerShell profile..." -ForegroundColor Cyan
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force -Path $profileDir | Out-Null }
Copy-FastfetchTree $engineDst

$xdg = Join-Path $HOME '.config\fastfetch'
Write-Host "`nReplacing ~/.config/fastfetch with the same engine..." -ForegroundColor Cyan
Copy-FastfetchTree $xdg

$themeSrc = Join-Path $repo 'powershell\themes\nc4.omp.json'
$themeBeside = Join-Path $profileDir 'Nc4.omp.json'
$themeNested = Join-Path $profileDir 'themes\nc4.omp.json'
if (-not (Test-Path $themeBeside) -and -not (Test-Path $themeNested)) {
    Write-Host "`nInstalling oh-my-posh theme..." -ForegroundColor Cyan
    Copy-Into $themeSrc $themeNested
} else {
    Write-Host "`nExisting oh-my-posh theme left in place." -ForegroundColor DarkGray
}

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
Copy-Into (Join-Path $repo 'powershell\Microsoft.PowerShell_profile.ps1') $oldProfile
if ($recoveredStart) {
    $fresh = Get-Content -Path $oldProfile -Raw -Encoding UTF8
    $fresh = $fresh -replace '(?m)^# \$Nc4StartPath = .+$', ('$Nc4StartPath = ''{0}''' -f $recoveredStart)
    Set-Content -Path $oldProfile -Value $fresh -Encoding UTF8
    Write-Host "  kept start path -> $recoveredStart" -ForegroundColor DarkGray
}

Write-Host "`nDone." -ForegroundColor Cyan
Write-Host "Open a new PowerShell 7 tab, or run: reroll"
