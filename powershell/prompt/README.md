# Option 2 — prompt only

The coloured command line, without the ASCII roll.

Your current fetch (or lack of one) stays as it is. There is no `reroll` and no gacha engine.

## What you get

- [oh-my-posh](https://ohmyposh.dev/) theme
- Git status in the prompt (`posh-git`)
- File icons in `ls` (`Terminal-Icons`)
- Fuzzy history / files (`PSFzf` — `Ctrl+r` / `Ctrl+f`)
- Jump-to-folder (`z`)
- The aliases in this profile (`ll`, `g`, `c`, …)

## What you need

[Getting started](../../docs/getting-started.md), plus **oh-my-posh** and the modules above. You do **not** need fastfetch.

## Install

From the project root:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
./install.ps1 2 -InstallModules -InstallTools
```

`2` and `Prompt` are the same switch. Add `-WhatIf` to preview every change without writing anything.

Set **MesloLGL Nerd Font Mono** in Windows Terminal, then open a new PowerShell 7 tab.

## Theme file

The theme that ships with the repo is [`themes/nc4.omp.json`](themes/nc4.omp.json).

The installer copies it only if you do **not** already have `Nc4.omp.json` or `themes\nc4.omp.json` next to your PowerShell 7 profile. If you already riced a theme, that file wins.

Edit the live copy (or this repo copy, then reinstall) to change segments. See [customize](../../docs/customize.md).

## What the installer does not do

- Does not install fastfetch
- Does not copy the `fastfetch\` engine
- Does not add `reroll`

To add the roll later without losing this prompt, run [option 1](../all/README.md).
