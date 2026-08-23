<div align="center">

# nc4-gacha-fetch

A Windows Terminal look that rolls a new ASCII logo every time you open a shell.

[![CI](https://github.com/naifcx47350/nc4-gacha-fetch/actions/workflows/ci.yml/badge.svg)](https://github.com/naifcx47350/nc4-gacha-fetch/actions/workflows/ci.yml)
[![Windows](https://img.shields.io/badge/Windows-10%20%2F%2011-0078D4?logo=windows&logoColor=white)](docs/getting-started.md)
[![PowerShell 7](https://img.shields.io/badge/PowerShell-7-5391FE?logo=powershell&logoColor=white)](docs/getting-started.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-22c55e.svg)](LICENSE)

[What you get](#what-you-get) · [Before you start](#before-you-start) · [Pick one](#pick-one) · [Install](#install) · [Guides](#guides)

</div>

---

This repo is two pieces. You can install **both**, or only the one you want.

| Piece | In plain language |
| --- | --- |
| **Gacha fetch** | A [fastfetch](https://github.com/fastfetch-cli/fastfetch) splash: picture on the left, PC specs on the right. Each new window rolls a rarity, then paints the picture and the colours from **that same rank**. A **1 in 100 shiny** can swap the colours. |
| **Prompt** | The line you type on. An [oh-my-posh](https://ohmyposh.dev/) theme with your name, how long the last command took, RAM, time, git, and a few extras (icons, fuzzy find, aliases). |

You do not need to read the scripts. Copy the steps, pick a number, open a new tab.

---

## What you get

<p align="center">
  <img src="docs/images/Art/image1.png" alt="Fetch roll: empty_skull with the Rust palette" width="900">
</p>
<p align="center"><em>A fetch roll — art, palette, and pity under the specs.</em></p>

<p align="center">
  <img src="docs/images/Art/image4.png" alt="Fetch roll: smug_cat with the Diamond palette" width="900">
</p>

<details>
<summary>More fetch rolls</summary>

<br>

![Art 2](docs/images/Art/image2.png)
![Art 3](docs/images/Art/image3.png)
![Art 5](docs/images/Art/image5.png)

</details>

<p align="center">
  <img src="docs/images/terminal/image1.png" alt="The coloured PowerShell prompt" width="900">
</p>
<p align="center"><em>The prompt — what you type on after the fetch.</em></p>

<details>
<summary>More prompt shots</summary>

<br>

![Prompt 2](docs/images/terminal/image2.png)
![Prompt 3](docs/images/terminal/image3.png)

</details>

---

## Before you start

You need **Windows 10 or 11**, **Windows Terminal**, **PowerShell 7**, and a **Nerd Font** (the screenshots use MesloLGL). Those are explained in everyday language here:

**[Getting started — what to install, and what our installer will not touch](docs/getting-started.md)**

> [!IMPORTANT]
> Use **PowerShell 7** inside **Windows Terminal**. The older app named **Windows PowerShell** is a different program. If icons look like empty boxes, the font is not set yet.

Short version of the safety rules:

- Only **PowerShell 7** is changed. Windows PowerShell 5.1, conda, and your module folder stay put — the installer refuses to run anywhere else.
- Anything replaced is copied first to a dated `*.bak-…` file. The three newest are kept.
- If you already have an oh-my-posh theme in that folder, it is left alone.
- Your gacha pity and roll history survive a reinstall.

Nervous? Add `-WhatIf` to any install command to print every change it *would* make without touching a single file:

```powershell
./install.ps1 1 -WhatIf
```

Want a look **without** changing your real terminal? Skip to [Try it first](#try-it-first).

---

## Pick one

| | I want… | Command | Longer page |
| :---: | --- | --- | --- |
| **1** | The prompt **and** the rolling logo | `./install.ps1 1 -InstallModules -InstallTools` | [powershell/all](powershell/all/README.md) |
| **2** | Only the fancy prompt | `./install.ps1 2 -InstallModules -InstallTools` | [powershell/prompt](powershell/prompt/README.md) |
| **3** | Only the rolling logo | `./install.ps1 3 -InstallTools` | [powershell/fetch](powershell/fetch/README.md) |

The extra words on the command mean:

- **`-InstallTools`** — also download the programs that option needs (oh-my-posh and/or fastfetch)
- **`-InstallModules`** — also download the prompt add-ons (options 1 and 2 only)

`1` / `All` / `Both`, `2` / `Prompt`, and `3` / `Fetch` / `Gacha` are the same choices.

---

## Install

Do these in order, in a **PowerShell 7** tab.

### 1. Allow the install script to run

Windows sometimes blocks scripts you download. This line allows them **for your user account only**:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

### 2. Get a copy of this project

```powershell
git clone https://github.com/naifcx47350/nc4-gacha-fetch.git
cd nc4-gacha-fetch
```

No Git? On the GitHub page click **Code → Download ZIP**, unzip it, then `cd` into that folder. More on this in [getting started](docs/getting-started.md#git-or-a-zip).

### 3. Run one install command

Paste **one** line from the table above. Example for everything:

```powershell
./install.ps1 1 -InstallModules -InstallTools
```

Wait until it prints `Done.`

### 4. Point Windows Terminal at the font

Settings (`Ctrl+,`) → **Defaults** (or your PowerShell profile) → **Appearance** → Font face → `MesloLGL Nerd Font Mono`.

Optional: the [terminal snippet](terminal/README.md) also copies the screenshot colours and transparency.

### 5. Open a new tab

Close the old one. A **new** PowerShell 7 tab loads the new startup file.

> [!TIP]
> You should see a picture and specs (options 1 and 3) and a coloured prompt (options 1 and 2). Type `reroll` if you installed a fetch option and want another logo right now.

If that is not what you see, open [troubleshooting](docs/troubleshooting.md).

---

## Try it first

This opens a throwaway window that reads **this folder**. Your everyday PowerShell profile is not replaced.

```powershell
.\test-shell.ps1
```

Specs in that window are dummy numbers (same as the screenshots). Add `-Live` if you want your real hardware.

Walk every colour set or every logo, still without installing:

```powershell
.\test\preview-palettes.ps1
.\test\preview-arts.ps1
```

Details: [test profile](powershell/test/README.md) · [preview scripts](test/README.md)

---

## After you install

| You installed… | What to expect |
| --- | --- |
| **1 — both** | Logo + specs, then the fancy prompt. `reroll` works. |
| **2 — prompt** | Fancy prompt only. No logo, no `reroll`. |
| **3 — fetch** | Logo + specs. Your old prompt stays. `reroll` works. |

The fetch does not run inside VS Code, Cursor, or JetBrains terminals, so those stay quiet.

Ranks, pity, and the colour lists: **[How the gacha works](docs/gacha.md)**

Add art, add a palette, or edit the prompt: **[Customize](docs/customize.md)**

Planning to add a lot of your own art? `./install.ps1 1 -Link` runs the fetch straight from your clone, so new art shows up without reinstalling. [More on that](docs/customize.md#working-on-art-without-reinstalling).

---

## Guides

The landing page stops here on purpose. Longer pages live next to the files they describe, or under `docs/`.

| Page | When to open it |
| --- | --- |
| [docs/](docs/README.md) | Index of every guide |
| [Getting started](docs/getting-started.md) | Font, PowerShell 7, what is safe |
| [How the gacha works](docs/gacha.md) | Ranks, palettes, pity, `reroll` |
| [Customize](docs/customize.md) | Your own art and colours |
| [Troubleshooting](docs/troubleshooting.md) | Boxes, wrong app, how to undo |
| [powershell/](powershell/README.md) | Map of the four startup files |
| [fastfetch/](fastfetch/README.md) | Art folders and the roll script |
| [CHANGELOG](CHANGELOG.md) | What changed between versions |
| [CONTRIBUTING](CONTRIBUTING.md) | Reporting a problem, and why art PRs are closed |

```
nc4-gacha-fetch/
├─ install.ps1                 # 1 both · 2 prompt · 3 fetch
├─ powershell/
│  ├─ all/                     # option 1
│  ├─ prompt/                  # option 2 (+ themes/)
│  ├─ fetch/                   # option 3
│  ├─ test/                    # test-shell.ps1
│  └─ profile.ps1              # optional conda snippet
├─ fastfetch/                  # art, templates, roll script
├─ test/                       # palette and art previews
├─ terminal/                   # optional window colours
└─ docs/
```

Some ASCII art is fan-made and the collection is curated by hand, so art pull requests are closed — see [CONTRIBUTING](CONTRIBUTING.md). Bug reports and doc fixes are very welcome.

---

## Credits

- [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- Layout inspired by [FastCat](https://github.com/m3tozz/FastCat)
- [oh-my-posh](https://ohmyposh.dev/)
- Gacha idea inspired by [routefetch](https://github.com/TitaniteScale/routefetch)

Some ASCII pieces are fan-made likenesses (games, memes). They are included for personal terminal use, not as original commercial art.

## License

[MIT](LICENSE)
