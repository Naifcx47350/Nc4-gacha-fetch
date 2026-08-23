<#
.SYNOPSIS
    nc4-gacha-fetch :: the gacha fetch engine.

.DESCRIPTION
    On each run this:
      1. Rolls a random ASCII logo, weighted by per-art rarity.
      2. Picks a colour set from that same rarity (shiny may override).
      3. Has a 1/100 chance of a "shiny" roll (hard pity at 100).
      4. Regenerates config.jsonc from a template, rewriting colours and
         the Art / Palette / Pity lines.
      5. Runs fastfetch.

    Root is $env:NC4_FETCH_ROOT, else the fastfetch folder next to this
    script, else ~/.config/fastfetch.

.PARAMETER Palette
    Force a specific palette by name (skips the palette roll).

.PARAMETER Art
    Force a specific ASCII file by name (skips the art roll).

.PARAMETER Shiny
    Force a shiny roll.

.PARAMETER NoRun
    Regenerate the config but do not launch fastfetch.

.PARAMETER List
    Print palettes and art with their rarities and exit.

.PARAMETER Stats
    Print persisted roll / pity stats and exit.

.PARAMETER DryRun
    Print the roll and do not write files, state, or run fastfetch.

.PARAMETER Demo
    Use config.demo.template.jsonc (dummy specs for screenshots).

.PARAMETER LogoWhite
    Paint the logo #ffffff on every slot (alignment previews).
#>
[CmdletBinding()]
param(
    [string]$Palette,
    [string]$Art,
    [switch]$Shiny,
    [switch]$NoRun,
    [switch]$List,
    [switch]$Stats,
    [switch]$DryRun,
    [switch]$Demo,
    [switch]$LogoWhite
)

$ErrorActionPreference = 'Stop'
if ($env:NC4_FETCH_DEMO)  { $Demo = $true }

# ---- Paths -----------------------------------------------------------------
$scriptRoot = Split-Path -Parent $PSScriptRoot
$rootDir = if ($env:NC4_FETCH_ROOT) {
    $env:NC4_FETCH_ROOT
} elseif (Test-Path (Join-Path $scriptRoot 'config.template.jsonc')) {
    $scriptRoot
} else {
    Join-Path $HOME '.config/fastfetch'
}
$asciiDir     = Join-Path $rootDir 'Ascii'
$currentArt   = Join-Path $asciiDir 'ascii_current.txt'
$livePath     = Join-Path $rootDir 'config.jsonc'
$statePath    = Join-Path $rootDir 'gacha-state.json'
$templateName = if ($Demo) { 'config.demo.template.jsonc' } else { 'config.template.jsonc' }
$templatePath = Join-Path $rootDir $templateName
if ($Demo -and -not (Test-Path $templatePath)) {
    Write-Warning "Demo template missing; falling back to config.template.jsonc."
    $templatePath = Join-Path $rootDir 'config.template.jsonc'
}

if (-not (Test-Path $asciiDir))     { Write-Error "Ascii directory not found: $asciiDir"; exit 1 }
if (-not (Test-Path $templatePath)) { Write-Error "Template not found: $templatePath"; exit 1 }

# ---- Colour helpers --------------------------------------------------------
function Convert-HexToRgb([string]$hex) {
    $h = $hex.TrimStart('#')
    if ($h.Length -eq 3) {
        $h = '{0}{0}{1}{1}{2}{2}' -f $h[0], $h[1], $h[2]
    }
    $v = [Convert]::ToInt32($h, 16)
    return @((($v -shr 16) -band 255), (($v -shr 8) -band 255), ($v -band 255))
}

function Get-BlendedHex([string]$hex1, [string]$hex2, [double]$t) {
    $c1 = Convert-HexToRgb $hex1
    $c2 = Convert-HexToRgb $hex2
    $r = [int][math]::Round($c1[0] + ($c2[0] - $c1[0]) * $t)
    $g = [int][math]::Round($c1[1] + ($c2[1] - $c1[1]) * $t)
    $b = [int][math]::Round($c1[2] + ($c2[2] - $c1[2]) * $t)
    return ('#{0:X2}{1:X2}{2:X2}' -f $r, $g, $b)
}

function New-Gradient([string[]]$anchors) {
    $n = $anchors.Count
    if ($n -lt 2) { return @($anchors[0]) * 9 }
    $out = @()
    for ($i = 0; $i -lt 9; $i++) {
        $p       = $i / 8.0
        $seg     = [math]::Min([math]::Floor($p * ($n - 1)), $n - 2)
        $localT  = ($p * ($n - 1)) - $seg
        $out    += Get-BlendedHex $anchors[$seg] $anchors[$seg + 1] $localT
    }
    return $out
}

function ConvertTo-Alternating([string[]]$palette) {
    $indices = @(0, 3, 6, 8, 1, 4, 7, 2, 5)
    $out = @()
    foreach ($idx in $indices) {
        $j = if ($idx -ge $palette.Count) { $palette.Count - 1 } else { $idx }
        $out += $palette[$j]
    }
    return $out
}

function New-Banded([string[]]$anchors) {
    $n = @($anchors).Count
    if ($n -lt 1) { return @('#888888') * 9 }
    $out = @()
    for ($i = 0; $i -lt 9; $i++) {
        $idx = [math]::Min([int][math]::Floor($i * $n / 9.0), $n - 1)
        $out += $anchors[$idx]
    }
    return $out
}

function Resolve-PaletteColors($palette) {
    if ($palette.Slots -and @($palette.Slots).Count -ge 2) {
        $s = [System.Collections.Generic.List[string]]@($palette.Slots)
        while ($s.Count -lt 9) { $s.Add($s[$s.Count - 1]) }
        return @($s.ToArray()[0..8])
    }
    if ($palette.Mode -eq 'Banded') { return New-Banded $palette.Anchors }
    $g = New-Gradient $palette.Anchors
    if ($palette.Mode -eq 'Alternating') { $g = ConvertTo-Alternating $g }
    return $g
}

function Get-RelativeLuma([int[]]$rgb) {
    return (0.2126 * $rgb[0]) + (0.7152 * $rgb[1]) + (0.0722 * $rgb[2])
}

# Black terminals swallow the first dark stops. Mix toward white until readable.
function Get-ReadableHex([string]$hex, [double]$minLuma = 68) {
    $rgb = Convert-HexToRgb $hex
    $luma = Get-RelativeLuma $rgb
    if ($luma -ge $minLuma) { return $hex }
    $t = ($minLuma - $luma) / (255.0 - [math]::Max($luma, 0.001))
    $r = [int][math]::Round($rgb[0] + ((255 - $rgb[0]) * $t))
    $g = [int][math]::Round($rgb[1] + ((255 - $rgb[1]) * $t))
    $b = [int][math]::Round($rgb[2] + ((255 - $rgb[2]) * $t))
    return ('#{0:X2}{1:X2}{2:X2}' -f $r, $g, $b)
}

function Protect-PaletteStops([string[]]$stops) {
    return @($stops | ForEach-Object { Get-ReadableHex $_ })
}

function Get-TemplateInfoHeight([string]$templateText) {
    $types = [regex]::Matches($templateText, '"type"\s*:').Count
    $breaks = [regex]::Matches($templateText, '(?m)^\s*"break"\s*,?\s*$').Count
    return $types + $breaks
}

function ConvertTo-JsonString([string]$s) {
    return ($s -replace '\\', '\\' -replace '"', '\"' -replace [char]27, '\u001b')
}

function Format-AnsiText([string]$hex, [string]$text) {
    $rgb = Convert-HexToRgb $hex
    $e = [char]27
    return "$e[38;2;$($rgb[0]);$($rgb[1]);$($rgb[2])m$text$e[0m"
}

function Test-GeneratedConfig([string]$text) {
    $stripped = [regex]::Replace($text, '(?m)^\s*//.*$', '')
    $stripped = [regex]::Replace($stripped, '/\*[\s\S]*?\*/', '')
    try {
        $null = $stripped | ConvertFrom-Json
        return $true
    } catch {
        Write-Warning "generated config failed JSON validation: $($_.Exception.Message)"
        return $false
    }
}

# ---- Rarity model ----------------------------------------------------------
# Mundane (often) → Scarce → Rare → Elite → Mythic (almost never). Shiny is 1/100.
$rarityWeights = @{ Mundane = 45; Scarce = 25; Rare = 15; Elite = 10; Mythic = 5 }
$rarityOrder = @('Mundane', 'Scarce', 'Rare', 'Elite', 'Mythic', 'Shiny')
$rarityMeta = @{
    Mundane  = @{ Color = '#c0c0c0'; Sym = [char]0x25CF }
    Scarce    = @{ Color = '#6e5a24'; Sym = [char]0x25C6 }
    Rare      = @{ Color = '#ffd700'; Sym = [char]0x2605 }
    Elite     = @{ Color = '#e8f6ff'; Sym = [char]0x2726 }
    Mythic    = @{ Color = '#c77dff'; Sym = [char]0x2739 }
    Shiny     = @{ Color = '#ffe566'; Sym = [char]0x2728 }
}

$shinyHardPity = 100
$mythicHardPity = 80
$mythicSoftPity = 50

function Get-WeightedRarity([object[]]$items, [hashtable]$Boost) {
    $present = $items | ForEach-Object { $_.Rarity } | Select-Object -Unique
    $pool = foreach ($r in $present) {
        $w = if ($rarityWeights.ContainsKey($r)) { $rarityWeights[$r] } else { 1 }
        if ($Boost -and $Boost.ContainsKey($r)) { $w = [int]$Boost[$r] }
        [pscustomobject]@{ Rarity = $r; Weight = $w }
    }
    $total = ($pool | Measure-Object -Property Weight -Sum).Sum
    $roll = Get-Random -Minimum 0 -Maximum $total
    $acc = 0
    foreach ($p in $pool) {
        $acc += $p.Weight
        if ($roll -lt $acc) { return $p.Rarity }
    }
    return @($present)[-1]
}

function Get-WeightedPick([object[]]$items, [hashtable]$Boost) {
    $rarity = Get-WeightedRarity $items $Boost
    $bucket = @($items | Where-Object { $_.Rarity -eq $rarity })
    return $bucket[(Get-Random -Minimum 0 -Maximum $bucket.Count)]
}

function Select-GachaItem {
    param(
        [object[]]$Items,
        [string]$ForcedName,
        [string]$ForceRarity,
        [hashtable]$SoftBoost
    )
    if ($ForcedName) {
        $hit = $Items | Where-Object { $_.Name -eq $ForcedName -or $_.Name -eq "$ForcedName.txt" } | Select-Object -First 1
        if (-not $hit) { Write-Error "Item '$ForcedName' not found."; exit 1 }
        return $hit
    }
    if ($ForceRarity) {
        $bucket = @($Items | Where-Object { $_.Rarity -eq $ForceRarity })
        if ($bucket.Count -gt 0) {
            return $bucket[(Get-Random -Minimum 0 -Maximum $bucket.Count)]
        }
    }
    return Get-WeightedPick $Items $SoftBoost
}

# ---- State -----------------------------------------------------------------
function New-GachaState {
    [pscustomobject]@{
        version               = 1
        totalRolls            = 0
        shinyCount            = 0
        pityShiny             = 0
        pityMythicPalette     = 0
        pityMythicArt         = 0
        art                   = @{ Mundane = 0; Scarce = 0; Rare = 0; Elite = 0; Mythic = 0 }
        palette               = @{ Mundane = 0; Scarce = 0; Rare = 0; Elite = 0; Mythic = 0; Shiny = 0 }
        history               = @()
    }
}

function Get-GachaState([string]$path) {
    $s = New-GachaState
    if (-not (Test-Path $path)) { return $s }
    try {
        $raw = Get-Content -Path $path -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch { return $s }
    foreach ($k in 'totalRolls', 'shinyCount', 'pityShiny', 'pityMythicPalette', 'pityMythicArt') {
        if ($null -ne $raw.$k) { $s.$k = [int]$raw.$k }
    }
    if ($null -ne $raw.pityLegendaryPalette) { $s.pityMythicPalette = [int]$raw.pityLegendaryPalette }
    if ($null -ne $raw.pityLegendaryArt) { $s.pityMythicArt = [int]$raw.pityLegendaryArt }
    if ($s.art['Mundane'] -eq 0 -and $raw.art -and $null -ne $raw.art.Everyday) {
        $s.art['Mundane'] = [int]$raw.art.Everyday
    }
    if ($s.palette['Mundane'] -eq 0 -and $raw.palette -and $null -ne $raw.palette.Everyday) {
        $s.palette['Mundane'] = [int]$raw.palette.Everyday
    }
    foreach ($tier in $rarityOrder) {
        if ($tier -eq 'Shiny') { continue }
        if ($raw.art -and $null -ne $raw.art.$tier) { $s.art[$tier] = [int]$raw.art.$tier }
    }
    foreach ($tier in $rarityOrder) {
        if ($raw.palette -and $null -ne $raw.palette.$tier) { $s.palette[$tier] = [int]$raw.palette.$tier }
    }
    if ($raw.history) { $s.history = @($raw.history) }
    return $s
}

function Save-GachaState($state, [string]$path) {
    $state | ConvertTo-Json -Depth 6 | Set-Content -Path $path -Encoding UTF8
}

function Show-GachaStats($state) {
    $pct = if ($state.totalRolls -gt 0) {
        [math]::Round(100.0 * $state.shinyCount / $state.totalRolls, 1)
    } else { 0 }
    Write-Host "nc4-gacha-fetch  stats"
    Write-Host ("  rolls    {0}" -f $state.totalRolls)
    Write-Host ("  shiny    {0} ({1}%)" -f $state.shinyCount, $pct)
    Write-Host ("  pity     shiny {0}/{1}  mythic {2}/{3}" -f `
        $state.pityShiny, $shinyHardPity, `
        $state.pityMythicArt, $mythicHardPity)
    Write-Host ""
    Write-Host "  art"
    foreach ($t in $rarityOrder) {
        if ($state.art.ContainsKey($t)) { Write-Host ("    {0,-10} {1}" -f $t, $state.art[$t]) }
    }
    Write-Host "  palette"
    foreach ($t in $rarityOrder) {
        if ($state.palette.ContainsKey($t)) { Write-Host ("    {0,-10} {1}" -f $t, $state.palette[$t]) }
    }
    if ($state.history) {
        Write-Host "  recent"
        foreach ($h in $state.history) {
            $flag = if ($h.shiny) { ' shiny' } else { '' }
            Write-Host ("    {0}  {1} {2}  |  {3} {4}{5}" -f $h.ts, $h.art, $h.artRarity, $h.palette, $h.paletteRarity, $flag)
        }
    }
}

$palettes = @(
    # --- Mundane ---
    @{ Name = 'Gray';   Rarity = 'Mundane'; Anchors = @('#2b2a28', '#6e6a64', '#c4bfb6') }
    @{ Name = 'Silver'; Rarity = 'Mundane'; Anchors = @('#2a2a2a', '#c0c0c0') }
    @{ Name = 'Paper';  Rarity = 'Mundane'; Slots = @('#2a2a2a', '#3a3a3a', '#4a4a4a', '#6a6a6a', '#8a8a8a', '#aaaaaa', '#cccccc', '#e8e8e8', '#f5f0e6') }
    @{ Name = 'Tin';    Rarity = 'Mundane'; Anchors = @('#2e3236', '#6d767c', '#b7c0c4', '#e4e8ea') }
    @{ Name = 'Dust';   Rarity = 'Mundane'; Anchors = @('#3a2e24', '#8a7358', '#d2b48c', '#efe4d2') }
    @{ Name = 'Khaki';  Rarity = 'Mundane'; Anchors = @('#2c2a18', '#6b6b3d', '#b8a36e', '#e6d9a8') }
    @{ Name = 'Denim';  Rarity = 'Mundane'; Anchors = @('#1a2433', '#3d5a7a', '#6f8faf', '#c5d4e0') }
    # --- Scarce ---
    @{ Name = 'Bronze'; Rarity = 'Scarce'; Anchors = @('#2a2410', '#6e5a24', '#c4a35a') }
    @{ Name = 'Copper'; Rarity = 'Scarce'; Anchors = @('#3b1208', '#b85c38', '#f0a090') }
    @{ Name = 'Rust';   Rarity = 'Scarce'; Anchors = @('#2a0c08', '#8b3a1a', '#c44536', '#e8a87c') }
    @{ Name = 'Moss';   Rarity = 'Scarce'; Anchors = @('#121a0e', '#3d5a2c', '#7a9b4a', '#c4d6a0') }
    # --- Rare ---
    @{ Name = 'Gold';      Rarity = 'Rare'; Anchors = @('#3d2f00', '#ffd700') }
    @{ Name = 'Molten';    Rarity = 'Rare'; Anchors = @('#1a0000', '#7a2a00', '#ff6a00', '#ffd700') }
    @{ Name = 'Platinum';  Rarity = 'Rare'; Anchors = @('#2c2c30', '#8d8d96', '#d8d6d0', '#f4f1ea') }
    @{ Name = 'Royal';     Rarity = 'Rare'; Anchors = @('#fff3b0', '#ffd166', '#e85d04', '#9b2226', '#4a0000') }
    # --- Elite ---
    @{ Name = 'Diamond'; Rarity = 'Elite'; Anchors = @('#1a2a33', '#e8f6ff') }
    @{ Name = 'Aurora';  Rarity = 'Elite'; Anchors = @('#020617', '#064e3b', '#67e8f9', '#c084fc') }
    @{ Name = 'Ice';     Rarity = 'Elite'; Anchors = @('#021a24', '#0a4a6e', '#2ec4e8', '#e8f6ff') }
    @{ Name = 'Pearl';   Rarity = 'Elite'; Anchors = @('#2a2030', '#8a6e88', '#f0d6e4', '#fff8f4') }
    # --- Mythic ---
    @{ Name = 'Magic Purple'; Rarity = 'Mythic'; Anchors = @('#1a0033', '#c77dff') }
    @{ Name = 'Hex';          Rarity = 'Mythic'; Anchors = @('#031a16', '#0f766e', '#5eead4', '#d9f99d', '#facc15') }
    @{ Name = 'Molten Lava';  Rarity = 'Mythic'; Anchors = @('#1a0000', '#7a2a00', '#ff4d00', '#ffd700', '#fff3b0') }
    @{ Name = 'Prismatic';    Rarity = 'Mythic'; Anchors = @('#ff0040', '#ff8c00', '#ffee00', '#00e676', '#00e5ff', '#2979ff', '#d500f9') }
    @{ Name = 'Void Walker';  Rarity = 'Mythic'; Anchors = @('#ffe4e6', '#fb7185', '#be123c', '#4a0510', '#0a0000') }
)

$shinyPalettes = @(
    @{ Name = 'Starlight';  Rarity = 'Shiny'; Anchors = @('#eef2ff', '#ffffff', '#fdf4ff', '#e0f2fe') }
    @{ Name = 'Shiny Gold'; Rarity = 'Shiny'; Anchors = @('#ffffff', '#ffe566', '#ffd700', '#123a4a') }
)

# ---- ASCII catalogue -------------------------------------------------------
# Unlisted files default to Mundane. Folder name is the category.
$categoryOrder = @(
    'Cats', 'Dogs', 'Birds', 'Bugs', 'Critters',
    'Pokemon', 'Fantasy', 'Spooky', 'Memes', 'People',
    'Food', 'Symbols', 'Unsorted'
)

$asciiCatalog = @{
    # --- Cats ---
    'cat.txt'            = @{ Rarity = 'Mundane';    Category = 'Cats' }
    'cat_alt.txt'        = @{ Rarity = 'Mundane';    Category = 'Cats' }
    'jumping_cat.txt'    = @{ Rarity = 'Scarce';     Category = 'Cats' }
    'leaving_cat.txt'    = @{ Rarity = 'Mundane';    Category = 'Cats' }
    'pop_cat.txt'        = @{ Rarity = 'Rare';       Category = 'Cats' }
    'drinking_cat.txt'   = @{ Rarity = 'Rare';       Category = 'Cats' }
    'drum_cat_alt.txt'   = @{ Rarity = 'Scarce';     Category = 'Cats' }
    'scream_cat.txt'     = @{ Rarity = 'Mundane';    Category = 'Cats' }
    'smug_cat.txt'       = @{ Rarity = 'Scarce';  Category = 'Cats' }
    'funky_cat.txt'      = @{ Rarity = 'Mythic';     Category = 'Cats' }
    'drum_cat.txt'       = @{ Rarity = 'Rare';       Category = 'Cats' }
    'cat_harmony.txt'    = @{ Rarity = 'Mythic';     Category = 'Cats' }
    'cat_pirate.txt'     = @{ Rarity = 'Elite';      Category = 'Cats' }
    'moon_cat.txt'       = @{ Rarity = 'Elite';      Category = 'Cats' }

    # --- Dogs ---
    'friendly_dog.txt'   = @{ Rarity = 'Mythic';     Category = 'Dogs' }
    'dog.txt'            = @{ Rarity = 'Elite';      Category = 'Dogs' }
    'pochita.txt'        = @{ Rarity = 'Elite';      Category = 'Dogs' }

    # --- Birds ---
    'normal_bird.txt'    = @{ Rarity = 'Rare';       Category = 'Birds' }
    'odd_bird.txt'       = @{ Rarity = 'Mythic';     Category = 'Birds' }
    'angry_duck.txt'     = @{ Rarity = 'Mundane';    Category = 'Birds' }
    'cool_duck.txt'      = @{ Rarity = 'Rare';      Category = 'Birds' }
    'wizard_duck.txt'    = @{ Rarity = 'Elite';      Category = 'Birds' }

    # --- Bugs ---
    'centipede.txt'      = @{ Rarity = 'Scarce';  Category = 'Bugs' }
    'judging_bug.txt'    = @{ Rarity = 'Scarce';  Category = 'Bugs' }
    'coolest_bug.txt'    = @{ Rarity = 'Mythic';     Category = 'Bugs' }

    # --- Critters ---
    'pig.txt'            = @{ Rarity = 'Mundane';    Category = 'Critters' }
    'small_teddy_bear.txt' = @{ Rarity = 'Mundane';  Category = 'Critters' }
    'bat.txt'            = @{ Rarity = 'Scarce';  Category = 'Critters' }
    'baby_bunny.txt'     = @{ Rarity = 'Rare';       Category = 'Critters' }
    'terraria_bunny.txt' = @{ Rarity = 'Elite';      Category = 'Critters' }
    'teddy_bear.txt'     = @{ Rarity = 'Scarce';  Category = 'Critters' }
    'bull_head.txt'      = @{ Rarity = 'Scarce';  Category = 'Critters' }
    'big_eyed_giraffe.txt' = @{ Rarity = 'Scarce'; Category = 'Critters' }
    'fox.txt'            = @{ Rarity = 'Rare';      Category = 'Critters' }
    'platypus.txt'       = @{ Rarity = 'Rare';      Category = 'Critters' }
    'catching_fish.txt'  = @{ Rarity = 'Rare';      Category = 'Critters' }
    'howling_wolf.txt'   = @{ Rarity = 'Mythic'; Category = 'Critters' }
    'perry_the_platypus.txt' = @{ Rarity = 'Mythic'; Category = 'Critters' }

    # --- Pokemon ---
    'pichu.txt'          = @{ Rarity = 'Mundane';    Category = 'Pokemon' }
    'mimikyu.txt'        = @{ Rarity = 'Mundane';    Category = 'Pokemon' }
    'eevee.txt'          = @{ Rarity = 'Scarce';  Category = 'Pokemon' }
    'haunter.txt'        = @{ Rarity = 'Rare';      Category = 'Pokemon' }
    'mew.txt'            = @{ Rarity = 'Mythic';     Category = 'Pokemon' }

    # --- Fantasy ---
    'hell_brand.txt'     = @{ Rarity = 'Mundane';    Category = 'Fantasy' }
    'toothless.txt'      = @{ Rarity = 'Scarce';     Category = 'Fantasy' }
    'scorpion.txt'       = @{ Rarity = 'Elite';      Category = 'Fantasy' }
    'dragon.txt'         = @{ Rarity = 'Mythic';     Category = 'Fantasy' }
    'dragon_alt.txt'     = @{ Rarity = 'Rare';       Category = 'Fantasy' }
    'berserk.txt'        = @{ Rarity = 'Scarce';     Category = 'Fantasy' }

    # --- Spooky ---
    'shade.txt'          = @{ Rarity = 'Mythic';     Category = 'Spooky' }
    'skull.txt'          = @{ Rarity = 'Rare';       Category = 'Spooky' }
    'empty_skull.txt'    = @{ Rarity = 'Scarce';     Category = 'Spooky' }
    'skeleton.txt'       = @{ Rarity = 'Mythic';     Category = 'Spooky' }
    'creature.txt'       = @{ Rarity = 'Mundane';    Category = 'Spooky' }
    'scream.txt'         = @{ Rarity = 'Rare';       Category = 'Spooky' }
    'scary_face.txt'     = @{ Rarity = 'Scarce';     Category = 'Spooky' }

    # --- Memes ---
    'salt.txt'           = @{ Rarity = 'Mundane';    Category = 'Memes' }
    'poop.txt'           = @{ Rarity = 'Mundane';    Category = 'Memes' }
    'sad_pepe.txt'       = @{ Rarity = 'Scarce';  Category = 'Memes' }
    'thinking_pepe.txt'  = @{ Rarity = 'Rare';      Category = 'Memes' }
    'chad.txt'           = @{ Rarity = 'Elite';      Category = 'Memes' }
    'hacker_pepe.txt'    = @{ Rarity = 'Mythic'; Category = 'Memes' }

    # --- People ---
    'standing_guy.txt'   = @{ Rarity = 'Rare';       Category = 'People' }
    'bald_guy.txt'       = @{ Rarity = 'Mundane';    Category = 'People' }
    'angry_golrie.txt'   = @{ Rarity = 'Scarce';  Category = 'People' }
    'biker.txt'          = @{ Rarity = 'Rare';      Category = 'People' }

    # --- Food ---
    'pizza.txt'          = @{ Rarity = 'Rare';       Category = 'Food' }
    'cake.txt'           = @{ Rarity = 'Mundane';    Category = 'Food' }
    'ice_cream.txt'      = @{ Rarity = 'Rare';       Category = 'Food' }
    'cafe.txt'           = @{ Rarity = 'Scarce';  Category = 'Food' }

    # --- Symbols ---
    'arch.txt'           = @{ Rarity = 'Elite';      Category = 'Symbols' }
    'saturn.txt'         = @{ Rarity = 'Scarce';  Category = 'Symbols' }
    'letter_a.txt'       = @{ Rarity = 'Scarce';  Category = 'Symbols' }
    'harmony.txt'        = @{ Rarity = 'Scarce';  Category = 'Symbols' }
    'eyes.txt'           = @{ Rarity = 'Scarce';  Category = 'Symbols' }
    'heart.txt'          = @{ Rarity = 'Mundane';    Category = 'Symbols' }
    'eight_point_star.txt' = @{ Rarity = 'Rare';    Category = 'Symbols' }
    'infinity.txt'       = @{ Rarity = 'Mythic';     Category = 'Symbols' }
    'swirls.txt'         = @{ Rarity = 'Rare';      Category = 'Symbols' }
    'interlink.txt'      = @{ Rarity = 'Scarce';     Category = 'Symbols' }
}

function Get-ArtMeta([string]$name) {
    if ($asciiCatalog.ContainsKey($name)) { return $asciiCatalog[$name] }
    return @{ Rarity = 'Mundane'; Category = 'Unsorted' }
}

$asciiFiles = Get-ChildItem -Path $asciiDir -Filter '*.txt' -File -Recurse |
    Where-Object { $_.Name -ne 'ascii_current.txt' } |
    ForEach-Object {
        $meta = Get-ArtMeta $_.Name
        $fromFolder = $_.Directory.Name
        $category = if ($fromFolder -ne 'Ascii') { $fromFolder } else { $meta.Category }
        [pscustomobject]@{
            Name     = $_.Name
            FullName = $_.FullName
            Rarity   = $meta.Rarity
            Category = $category
        }
    }

if (-not $asciiFiles) { Write-Error "No ascii art found in $asciiDir"; exit 1 }

if ($List) {
    Write-Host "palettes"
    $palettes + $shinyPalettes |
        Sort-Object { $rarityOrder.IndexOf($_.Rarity) }, Name |
        ForEach-Object { '  {0,-10} {1}' -f $_.Rarity, $_.Name }
    Write-Host "art"
    foreach ($cat in $categoryOrder) {
        $bucket = @($asciiFiles | Where-Object { $_.Category -eq $cat } | Sort-Object { $rarityOrder.IndexOf($_.Rarity) }, Name)
        if (-not $bucket) { continue }
        Write-Host ("  [{0}]" -f $cat)
        $bucket | ForEach-Object { '    {0,-10} {1}' -f $_.Rarity, $_.Name }
    }
    return
}

$state = Get-GachaState $statePath
if ($Stats) { Show-GachaStats $state; return }

# ---- Roll ------------------------------------------------------------------
$hasMythicArt = @($asciiFiles | Where-Object { $_.Rarity -eq 'Mythic' }).Count -gt 0

$shinyPityHit = (-not $Shiny) -and ($state.pityShiny -ge ($shinyHardPity - 1))
$isShiny = [bool]($Shiny -or $shinyPityHit -or ((Get-Random -Minimum 1 -Maximum 101) -eq 1))

$artForceRarity = $null
$artBoost = $null
if (-not $Art -and $hasMythicArt) {
    if ($state.pityMythicArt -ge ($mythicHardPity - 1)) { $artForceRarity = 'Mythic' }
    elseif ($state.pityMythicArt -ge $mythicSoftPity) { $artBoost = @{ Mythic = 12 } }
}
$chosenArt = Select-GachaItem -Items $asciiFiles -ForcedName $Art -ForceRarity $artForceRarity -SoftBoost $artBoost

$rankPals = @($palettes | Where-Object { $_.Rarity -eq $chosenArt.Rarity })
if ($Palette) {
    $chosenPalette = Select-GachaItem -Items ($palettes + $shinyPalettes) -ForcedName $Palette
} elseif ($isShiny) {
    $chosenPalette = $shinyPalettes[(Get-Random -Minimum 0 -Maximum $shinyPalettes.Count)]
} elseif ($rankPals.Count -gt 0) {
    $chosenPalette = $rankPals[(Get-Random -Minimum 0 -Maximum $rankPals.Count)]
} else {
    $chosenPalette = $palettes[0]
}

$gradient = Protect-PaletteStops (Resolve-PaletteColors $chosenPalette)
$keyGradient = $gradient
if ($chosenPalette.KeyAnchors) {
    $keyGradient = Protect-PaletteStops (Resolve-PaletteColors @{
        Anchors = $chosenPalette.KeyAnchors
        Mode    = $chosenPalette.KeyMode
    })
}
if ($LogoWhite) { $gradient = @('#ffffff') * 9 }

$am = $rarityMeta[$chosenArt.Rarity]
$artDisplay = [IO.Path]::GetFileNameWithoutExtension($chosenArt.Name)
$rankInk = $am.Color
$artLabel = '{0}  {1}' -f $artDisplay, (Format-AnsiText $rankInk ('{0} {1}' -f $am.Sym, $chosenArt.Rarity))
$palLabel = $chosenPalette.Name

$nextShiny = if ($isShiny) { 0 } else { $state.pityShiny + 1 }
$nextMythicArt = if ($chosenArt.Rarity -eq 'Mythic') { 0 } else { $state.pityMythicArt + 1 }
$pityLabel = 'shiny {0}/{1}' -f $nextShiny, $shinyHardPity
if ($hasMythicArt) { $pityLabel += '  ·  mythic {0}/{1}' -f $nextMythicArt, $mythicHardPity }
if ($shinyPityHit -or $artForceRarity) { $pityLabel = 'PITY  ' + $pityLabel }

if ($DryRun) {
    $prefix = if ($Demo) { '[dry-run demo] ' } else { '[dry-run] ' }
    Write-Host ($prefix + "art $($chosenArt.Name) $($chosenArt.Rarity)")
    Write-Host ($prefix + "palette $($chosenPalette.Name) $($chosenPalette.Rarity)")
    Write-Host ($prefix + $pityLabel)
    Write-Host ($prefix + 'no files written')
    return
}

# ---- Apply -----------------------------------------------------------------
$cfg = Get-Content -Path $templatePath -Raw -Encoding UTF8
$artLines = @(Get-Content -Path $chosenArt.FullName -Encoding UTF8)
$infoH = Get-TemplateInfoHeight $cfg
$pad = [math]::Max(0, [int][math]::Floor(($infoH - $artLines.Count) / 2))
$padded = @('') * $pad + $artLines
Set-Content -Path $currentArt -Value $padded -Encoding UTF8
$logoSource = ($currentArt -replace '\\', '/')
$cfg = $cfg.Replace('@@LOGO_SOURCE@@', $logoSource)
$cfg = $cfg.Replace('~/.config/fastfetch/Ascii/ascii_current.txt', $logoSource)

for ($i = 1; $i -le 9; $i++) {
    $hex = $gradient[$i - 1]
    $pattern = ('("{0}"\s*:\s*")#[0-9A-Fa-f]{{3,8}}(")' -f $i)
    $cfg = [regex]::Replace($cfg, $pattern, ('${1}' + $hex + '${2}'))
}

$kcMatches = [regex]::Matches($cfg, '"keyColor"\s*:\s*"#[0-9A-Fa-f]{3,8}"')
$kcCount = $kcMatches.Count
# Skip the two darkest logo stops so System / OS / Kernel stay visible.
$keyStart = 2
$keySpan = 8 - $keyStart
for ($i = $kcCount - 1; $i -ge 0; $i--) {
    $gidx = if ($kcCount -le 1) { 8 } else { $keyStart + [int][math]::Round($i / ($kcCount - 1) * $keySpan) }
    $hex = $keyGradient[$gidx]
    $m = $kcMatches[$i]
    $new = '"keyColor": "' + $hex + '"'
    $cfg = $cfg.Substring(0, $m.Index) + $new + $cfg.Substring($m.Index + $m.Length)
}

$cfg = $cfg.Replace('@@ART_FORMAT@@', (ConvertTo-JsonString $artLabel))
$cfg = $cfg.Replace('@@ART_KEYCOLOR@@', $rankInk)
$cfg = $cfg.Replace('@@PALETTE_FORMAT@@', (ConvertTo-JsonString $palLabel))
$cfg = $cfg.Replace('@@PALETTE_KEYCOLOR@@', $gradient[4])
$cfg = $cfg.Replace('@@PITY_FORMAT@@', (ConvertTo-JsonString $pityLabel))
$cfg = $cfg.Replace('@@PITY_KEYCOLOR@@', $(if ($shinyPityHit) { $rarityMeta['Shiny'].Color } else { '#6e6d6c' }))

# Legacy Palette block (old templates without tokens).
if ($cfg -notmatch '@@PALETTE_FORMAT@@' -and $cfg -match '"key"\s*:\s*"Palette"') {
    $paletteBlock = @"
{
      "type": "custom",
      "key": "Palette",
      "keyColor": "$($gradient[4])",
      "format": "$(ConvertTo-JsonString $palLabel)"
    }
"@
    $cfg = [regex]::Replace(
        $cfg,
        '\{\s*"type"\s*:\s*"custom"[^}]*"key"\s*:\s*"Palette"[^}]*\}',
        { $paletteBlock },
        [System.Text.RegularExpressions.RegexOptions]::Singleline
    )
}

$tmpPath = "$livePath.tmp"
if (Test-GeneratedConfig $cfg) {
    Set-Content -Path $tmpPath -Value $cfg -Encoding UTF8
    Move-Item -Path $tmpPath -Destination $livePath -Force
} else {
    Write-Warning 'Refusing to publish invalid config; previous config.jsonc left in place.'
}

if (-not $env:NC4_FETCH_NOSTATE) {
    $state.totalRolls++
    if ($isShiny) { $state.shinyCount++; $state.pityShiny = 0 } else { $state.pityShiny = $nextShiny }
    $state.pityMythicArt = $nextMythicArt
    if ($state.art.ContainsKey($chosenArt.Rarity)) { $state.art[$chosenArt.Rarity] = [int]$state.art[$chosenArt.Rarity] + 1 }
    if ($state.palette.ContainsKey($chosenPalette.Rarity)) { $state.palette[$chosenPalette.Rarity] = [int]$state.palette[$chosenPalette.Rarity] + 1 }
    $entry = [pscustomobject]@{
        ts             = (Get-Date).ToString('s')
        art            = $chosenArt.Name
        artRarity      = $chosenArt.Rarity
        palette        = $chosenPalette.Name
        paletteRarity  = $chosenPalette.Rarity
        shiny          = [bool]$isShiny
    }
    $state.history = @($entry) + @($state.history) | Select-Object -First 20
    Save-GachaState $state $statePath
}

if (-not $NoRun) {
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        fastfetch --config $livePath
    } else {
        Write-Warning 'fastfetch is not installed or not on PATH.'
    }
}
