# nc4-gacha-fetch

A PowerShell 7 setup for Windows Terminal with a **gacha startup fetch**. Each session rolls a rarity-weighted ASCII logo, then colours [fastfetch](https://github.com/fastfetch-cli/fastfetch) with a palette from **that same rank**. A **1/100 shiny** can override the colours.

### Fetch

![empty_skull / Rust](docs/images/Art/image1.png)
![smug_cat / Diamond](docs/images/Art/image4.png)

<details>
<summary>More rolls</summary>

![Art 2](docs/images/Art/image2.png)
![Art 3](docs/images/Art/image3.png)
![Art 5](docs/images/Art/image5.png)

</details>

---

## Features

- **One gacha** — art rarity is rolled first; the palette is picked from that rank.
- **Rank-theme colours** — everyday sets at Mundane, metals and specials above that. Shiny is Starlight and Shiny Gold.
- **Art, Palette, and Pity** under the fetch (shiny `n/100`, mythic `n/80`).
- **oh-my-posh prompt** — user/host, exec time, RAM, clock, git, and language segments.
- **Aliases and tools** — `ll`, `g`, `grep`, `py`, history suggestions, `PSFzf`, `Terminal-Icons`.
- **Editor-aware** — the fetch is skipped inside VS Code, Cursor, and JetBrains terminals.
- **Installer** that copies the engine next to your PowerShell 7 profile and leaves Modules and conda alone.

---

## Requirements

- PowerShell 7 (`pwsh`) and [Windows Terminal](https://aka.ms/terminal)
- A [Nerd Font](https://www.nerdfonts.com/font-downloads) — **MesloLGL Nerd Font** matches the screenshots
- [oh-my-posh](https://ohmyposh.dev/) and [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- Modules: `posh-git`, `Terminal-Icons`, `PSFzf`, `z`
- Python 3.9+ only if you tag your own ASCII art

---

## Install

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
git clone https://github.com/naifcx47350/nc4-gacha-fetch.git
cd nc4-gacha-fetch
./install.ps1 -InstallModules -InstallTools
```

The installer:

- copies the engine to `<profileDir>\fastfetch` (and `~/.config/fastfetch`)
- updates `Microsoft.PowerShell_profile.ps1` only
- leaves `Modules`, conda (`profile.ps1` / AllHosts), and an existing oh-my-posh theme untouched
- backs up anything it replaces as `<name>.bak-<timestamp>`

Then install the font, set Windows Terminal → Defaults → Font face to `MesloLGL Nerd Font Mono`, and merge `terminal/settings.snippet.jsonc` into Windows Terminal if you want the reference colors. Open a new tab.

Try the repo without touching the live profile:

```powershell
.\test-shell.ps1
```

---

## Usage

```powershell
reroll                              # roll again in this session
```

```powershell
$rf = Join-Path (Split-Path $PROFILE) 'fastfetch\scripts\randfetch.ps1'

& $rf                               # random roll
& $rf -List                         # palettes and art
& $rf -Stats                        # pity and history
& $rf -Palette 'Diamond'            # force a palette
& $rf -Art cat.txt                  # force an art
& $rf -Shiny                        # force shiny
```

Set `FASTFETCH_DISABLE=1` to skip the fetch. Set `NC4_FETCH_ROOT` to point at another engine folder.

Walk every palette or every logo (dummy specs, no pity):

```powershell
.\test\preview-palettes.ps1
.\test\preview-arts.ps1
```

---

## Ranks

| Rank      | Symbol | Weight                       |
| --------- | ------ | ---------------------------- |
| Mundane   | ●      | 45                           |
| Scarce    | ◆      | 25                           |
| Rare      | ★      | 15                           |
| Elite     | ✦      | 10                           |
| Mythic    | ✹      | 5                            |
| **Shiny** | ✨      | 1 in 100 (overrides colours) |

Shiny has hard pity at 100. Mythic art has a soft boost at 50 and hard pity at 80.

| Rank    | Palettes                                               |
| ------- | ------------------------------------------------------ |
| Mundane | Gray, Silver, Paper, Tin, Dust, Khaki, Denim           |
| Scarce  | Bronze, Copper, Rust, Moss                             |
| Rare    | Gold, Molten, Platinum, Royal                          |
| Elite   | Diamond, Aurora, Ice, Pearl                            |
| Mythic  | Magic Purple, Hex, Molten Lava, Prismatic, Void Walker |
| Shiny   | Starlight, Shiny Gold                                  |

---

## Customization

### ASCII art

Drop a file in a category folder and tag it:

```powershell
py fastfetch/scripts/gradient_tag.py fastfetch/Ascii/Cats/mycat.txt
```

Set rarity in `$asciiCatalog` inside `randfetch.ps1`. Unlisted art is Mundane. `$1`–`$9` are gradient slots. `$0` is a reset on the last line, not a blank row.

### Palettes

Add an entry to `$palettes` in `randfetch.ps1`:

```powershell
@{ Name = 'My Scheme'; Rarity = 'Elite'; Anchors = @('#101020', '#4040ff', '#ffffff') }
```

`Anchors` blend into 9 stops. `Slots` is exactly 9 colours. `Banded` is hard stops. `KeyAnchors` colours the info keys only.

### Prompt

Edit `powershell/themes/nc4.omp.json`, or your existing `Nc4.omp.json` if the installer left it in place.

---

## Layout

```
nc4-gacha-fetch/
├─ install.ps1
├─ powershell/          # profile + theme
├─ fastfetch/           # engine, templates, Ascii/
├─ test/                # palette and art previews
├─ terminal/            # Windows Terminal snippet
└─ docs/images/Art/     # fetch screenshots
```

After install the engine also lives next to your PowerShell 7 profile, in `fastfetch\`. Runtime files `config.jsonc` and `ascii_current.txt` are generated.

---

## Credits

- [fastfetch](https://github.com/fastfetch-cli/fastfetch)
- Layout inspired by [FastCat](https://github.com/m3tozz/FastCat)
- [oh-my-posh](https://ohmyposh.dev/)
- Gacha idea inspired by [routefetch](https://github.com/TitaniteScale/routefetch)

Some ASCII pieces are fan-made likenesses (games, memes). They are included for personal terminal use, not as original commercial art.

## License

[MIT](LICENSE)
