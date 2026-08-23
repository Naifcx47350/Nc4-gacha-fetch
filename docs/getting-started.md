# Before you start

You only need four things. If you already have them, go back to the [install steps](../README.md#install).

## 1. Windows 10 or 11

This setup is for Windows. It is written for **Windows Terminal** and **PowerShell 7**.

## 2. Windows Terminal

Windows Terminal is Microsoft’s modern terminal app. It is free.

- Microsoft Store: search **Windows Terminal**
- Or in PowerShell: `winget install Microsoft.WindowsTerminal`

You will open **Windows Terminal** for every step below. The old blue **Windows PowerShell** window is a different, older program and will not look right.

## 3. PowerShell 7

PowerShell 7 is the newer shell. In the Start menu it is just called **PowerShell**.

It is **not** the same as **Windows PowerShell** (the older one that ships with Windows).

- Microsoft Store: search **PowerShell** (publisher: Microsoft)
- Or: `winget install Microsoft.PowerShell`

Check you have the right one. In Windows Terminal, open a **PowerShell** tab (not Windows PowerShell) and paste:

```powershell
$PSVersionTable.PSVersion
```

The major number should be **7** or higher.

## 4. A Nerd Font

A **Nerd Font** is a regular coding font with extra icons sewn in. The prompt and the fetch both use those icons. Without this font, icons show up as empty boxes or question marks.

The screenshots use **MesloLGL Nerd Font**.

1. Open [Nerd Fonts downloads](https://www.nerdfonts.com/font-downloads).
2. Search **Meslo**.
3. Download **MesloLGL Nerd Font**, unzip the file.
4. Select the font files, right-click, choose **Install**.
5. In Windows Terminal press `Ctrl+,` to open Settings.
6. Click **Defaults** (or your PowerShell profile) → **Appearance**.
7. Set **Font face** to `MesloLGL Nerd Font Mono`.
8. Save, then open a **new** tab.

> [!TIP]
> A new tab is required. The old tab keeps the old font.

## Optional: matching window colors

The [reference snippet](../terminal/README.md) copies the screenshot look (font, transparency, Tango Dark). You do not need it for the fetch or the prompt to work.

## Tools the installer can fetch for you

If you add `-InstallTools` to the install command, Windows’ built-in installer (`winget`) downloads the programs that option needs:

| Program | Used by | Manual install |
| --- | --- | --- |
| [oh-my-posh](https://ohmyposh.dev/) | Prompt (options 1 and 2) | `winget install JanDeDobbeleer.OhMyPosh` |
| [fastfetch](https://github.com/fastfetch-cli/fastfetch) | Gacha fetch (options 1 and 3) | `winget install Fastfetch-cli.Fastfetch` |

`-InstallModules` only applies to the prompt. It downloads four PowerShell add-ons into **your user account**: `posh-git`, `Terminal-Icons`, `PSFzf`, and `z`. It does not replace anything already in your `Modules` folder.

## Git, or a ZIP

You need a copy of this project on disk.

**Option A — Git** (keeps updates easy):

```powershell
git clone https://github.com/naifcx47350/nc4-gacha-fetch.git
cd nc4-gacha-fetch
```

If Git is missing: [Git for Windows](https://git-scm.com/download/win), or `winget install Git.Git`.

**Option B — ZIP:** on GitHub click the green **Code** button → **Download ZIP**. Unzip it, then in PowerShell 7:

```powershell
cd path\to\nc4-gacha-fetch
```

Replace that path with the folder you unzipped.

## What the installer will and will not touch

**It will**

- Copy a startup file into **PowerShell 7 only**
- If you pick a fetch option, copy the art and scripts next to that startup file
- Make a dated backup of anything it replaces (`something.bak-20260823-143000`), keeping the three newest
- Carry your gacha pity and roll history over to the new copy

**It will not**

- Run at all under **Windows PowerShell 5.1** — it stops with a message instead of installing to the wrong place
- Change conda, or the `profile.ps1` that All-hosts / conda uses
- Wipe your installed PowerShell modules
- Overwrite an oh-my-posh theme you already have in that folder

## See it before you commit to it

Every install command accepts `-WhatIf`. It prints each change it would make and writes nothing:

```powershell
./install.ps1 1 -WhatIf
```

Run that first if you want to know exactly which files are involved.

To keep more (or fewer) backups than the default three:

```powershell
./install.ps1 1 -KeepBackups 10     # 0 keeps every backup forever
```

After install, open a **new** PowerShell 7 tab. The old tab is still running the previous startup file.

Next: [install](../README.md#install) · [troubleshooting](troubleshooting.md)
