# Contributing

Thanks for looking. This is a personal terminal setup that other people are welcome to use, so the bar for changes is a little different from a general-purpose tool.

## ASCII art

**Art submissions are closed.** The collection is curated by hand — rank, category, and colour balance are chosen together, and every piece is checked for alignment at the sizes the fetch renders. Art pull requests will be closed.

You are very welcome to add your own art **to your own clone**. [Customize](docs/customize.md) walks through it, and `./install.ps1 1 -Link` lets you do it without reinstalling each time.

## What is welcome

- Bug reports, especially anything the installer gets wrong on a machine unlike mine
- Fixes for broken behaviour, with a note on how you reproduced it
- Documentation that was unclear to you as a first-time reader
- Palette suggestions, as an issue with hex values (I will balance them against the rank)

## Before opening a pull request

Run the same checks CI runs:

```powershell
Install-Module PSScriptAnalyzer -Scope CurrentUser
Invoke-ScriptAnalyzer -Path . -Recurse -Settings ./PSScriptAnalyzerSettings.psd1
```

That must come back empty. If a rule genuinely does not apply to this project, say why in the PR rather than working around it — the exclusions in `PSScriptAnalyzerSettings.psd1` are documented individually.

Then exercise the engine and the installer without touching your live setup:

```powershell
$env:NC4_FETCH_ROOT = "$PWD\fastfetch"; $env:NC4_FETCH_NOSTATE = '1'
./fastfetch/scripts/randfetch.ps1 -DryRun
./install.ps1 1 -WhatIf
.\test-shell.ps1
```

`-WhatIf` and `-DryRun` are expected to write nothing at all. If you change the installer, please verify that is still true — it is the safety net for everyone who tries this repo.

## House rules for code

- PowerShell 7 only. Scripts carry `#Requires -Version 7`.
- Files stay UTF-8 **without** a BOM. fastfetch cannot parse a config that has one.
- Any file the installer replaces must be backed up first.
- Nothing outside PowerShell 7's own profile gets touched — not conda, not `Modules`, not Windows PowerShell 5.1.
- Comments explain intent or a constraint, not what the next line does.

## Reporting a problem

Include your PowerShell version (`$PSVersionTable.PSVersion`), which install option you used, and the output of:

```powershell
./install.ps1 1 -WhatIf
```

That last one shows what the installer sees on your machine without changing anything.
