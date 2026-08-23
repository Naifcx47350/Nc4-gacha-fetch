# Option 1 — both

The full setup: the coloured prompt **and** a new ASCII roll each session.

Use this if you want the screenshots. If you only want one half, see [prompt](../prompt/README.md) or [fetch](../fetch/README.md).

## What you get

- [oh-my-posh](https://ohmyposh.dev/) theme (user, host, timing, RAM, clock, git, language chips)
- Aliases, fuzzy find, and the other prompt add-ons
- The gacha fetch on every new Windows Terminal tab
- The `reroll` command

## What you need

Follow [getting started](../../docs/getting-started.md) first (Windows Terminal, PowerShell 7, a Nerd Font).

This option also needs **oh-my-posh**, **fastfetch**, and the modules `posh-git`, `Terminal-Icons`, `PSFzf`, and `z`. The flags below install those for you.

## Install

From the **project root** (the folder that contains `install.ps1`):

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
./install.ps1 1 -InstallModules -InstallTools
```

`1`, `All`, and `Both` are the same switch. Add `-WhatIf` to preview every change without writing anything.

Then set the font and open a **new** PowerShell 7 tab. Details: [main install](../../README.md#install).

## What the installer copies

| From this folder | To your machine |
| --- | --- |
| `Microsoft.PowerShell_profile.ps1` | PowerShell 7’s startup file |
| Theme, if you do not already have one | Next to that startup file |
| [`fastfetch/`](../../fastfetch/README.md) | `fastfetch\` beside the profile |

Anything replaced is saved as `*.bak-<timestamp>` (three newest kept). An existing theme file is left alone. conda and `Modules` are not touched. Your pity and roll history carry over.

## Afterward

```powershell
reroll
```

How ranks work: [gacha](../../docs/gacha.md).  
Change the look: [customize](../../docs/customize.md).  
Something looks wrong: [troubleshooting](../../docs/troubleshooting.md).
