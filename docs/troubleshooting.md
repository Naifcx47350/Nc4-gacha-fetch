# Troubleshooting

## Icons are boxes or question marks

The font is not a Nerd Font, or this tab was opened before you changed it.

1. Install **MesloLGL Nerd Font** ([getting started](getting-started.md#4-a-nerd-font)).
2. Windows Terminal → Settings → Defaults → Appearance → Font face → `MesloLGL Nerd Font Mono`.
3. Open a **new** tab.

## “Running scripts is disabled on this system”

Windows is blocking the install script. In PowerShell 7:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

That only affects **your** user account. Then run the install command again.

## I opened a window and nothing new appeared

- Confirm the tab says **PowerShell**, not **Windows PowerShell**.
- Close it and open a **new** tab. The old one is still using the previous startup file.
- If you are inside **VS Code**, **Cursor**, or a **JetBrains** terminal, the fetch is skipped on purpose so it does not spam the integrated terminal. Use Windows Terminal to see the roll.

## The prompt looks fancy but there is no logo

You installed **option 2** (prompt only). That is expected.

To add the roll later, run [option 1](../powershell/all/README.md) or [option 3](../powershell/fetch/README.md).

## The logo appears but the prompt looks like the default

Two different causes, same look.

**You installed option 3** (fetch only). That is expected. To add the prompt later, run [option 1](../powershell/all/README.md) or [option 2](../powershell/prompt/README.md).

**You installed option 1 or 2, and the prompt is still the plain PowerShell one.** The logo does not need oh-my-posh, so the fetch can work while the prompt quietly skips. After `winget` installs oh-my-posh, a **new tab is not enough** — Windows Terminal keeps the old PATH until every window is closed.

1. Fully quit Windows Terminal (every window, not just the tab).
2. Open it again, PowerShell 7 tab.
3. Check: `Get-Command oh-my-posh`

If that prints a path, the next tab should show the coloured prompt. If it still says the command was not found, install it by hand with `winget install JanDeDobbeleer.OhMyPosh`, then quit and reopen again.

## `winget` was not found

The script could not auto-install oh-my-posh or fastfetch. Install them yourself from [getting started](getting-started.md#tools-the-installer-can-fetch-for-you), then run the same `./install.ps1` line again (you can omit `-InstallTools` if they are already there).

## `./install.ps1` is not recognized

You are not inside the project folder. `cd` into `nc4-gacha-fetch` first (the folder that contains `install.ps1`).

## I want my old setup back

The installer writes a dated backup next to each file it replaces, for example:

`Microsoft.PowerShell_profile.ps1.bak-20260823-143000`

Copy that file back over `Microsoft.PowerShell_profile.ps1` in the same folder. Your PowerShell 7 profile folder is:

```powershell
Split-Path $PROFILE
```

The three newest backups are kept and older ones are pruned. Use `-KeepBackups 0` at install time if you want them all.

## “cannot be run because it contained a #requires statement”

You are in **Windows PowerShell 5.1**, not PowerShell 7. That message is the installer protecting you — running there would install to the wrong profile.

Open **Windows Terminal** and start a **PowerShell** tab, then try again. See [getting started](getting-started.md#3-powershell-7).

## I want to see what it would do before running it

```powershell
./install.ps1 1 -WhatIf
```

That prints every file it would back up, replace, or create, and changes nothing.

## Will reinstalling reset my pity?

No. `gacha-state.json` is carried across reinstalls, so your shiny and mythic counters keep counting.

## The fetch is skipped and I want it inside the editor

```powershell
$env:NC4_FETCH_FORCE = '1'
reroll
```

To turn the fetch off everywhere:

```powershell
$env:FASTFETCH_DISABLE = '1'
```

## I added art in the repo but my real terminal did not change

The live copy lives next to your PowerShell 7 profile, not in the git folder. Run `./install.ps1` again for the option you use, or preview with [`.\test-shell.ps1`](../powershell/test/README.md).

If you add art often, install once with `-Link` and this stops happening — your shell reads the repo directly. See [working on art without reinstalling](customize.md#working-on-art-without-reinstalling).
