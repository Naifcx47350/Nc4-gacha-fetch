# Option 3 — gacha fetch only

The rolling logo and PC specs, without changing your prompt theme.

Your current oh-my-posh (or default) prompt stays. You get the fetch hook and `reroll`.

## What you get

- A rarity-weighted ASCII logo each new Windows Terminal session
- A colour set from that same rank (a shiny refoils it; an exclusive replaces it)
- Art / Palette / Pity lines under the specs
- `reroll` to roll again in the same window

## What you need

[Getting started](../../docs/getting-started.md), plus **fastfetch**. You do **not** need oh-my-posh or the extra modules. Python is only needed if you [tag your own art](../../docs/customize.md).

## Install

From the project root:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
./install.ps1 3 -InstallTools
```

`3`, `Fetch`, and `Gacha` are the same switch. Add `-WhatIf` to preview every change without writing anything. `-InstallModules` does nothing here because this profile does not load those modules.

Open a new PowerShell 7 tab (not inside VS Code / Cursor / JetBrains — the fetch is skipped there on purpose).

## Where the files live

The installer copies [`fastfetch/`](../../fastfetch/README.md) into `fastfetch\` next to your PowerShell 7 profile. That copy is the one that runs.

`config.jsonc` and `ascii_current.txt` are generated on each roll. Do not edit those by hand; change the templates or the art instead. `gacha-state.json` holds your pity and history and is preserved when you reinstall.

## Running from the repo instead

If you are working on the art and do not want to reinstall after every change:

```powershell
./install.ps1 3 -Link
```

That skips the copy and points your shell at this repo, so new art shows up in the next tab. See [customize](../../docs/customize.md#working-on-art-without-reinstalling).

## Commands

```powershell
reroll
```

```powershell
$rf = Join-Path (Split-Path $PROFILE) 'fastfetch\scripts\randfetch.ps1'

& $rf -List
& $rf -Stats
& $rf -Palette 'Diamond'
& $rf -Art cat.txt
& $rf -Shiny
```

```powershell
$env:FASTFETCH_DISABLE = '1'    # skip the fetch
```

Ranks and pity: [gacha](../../docs/gacha.md).  
To add the fancy prompt later: [option 1](../all/README.md) or [option 2](../prompt/README.md).
