# How the gacha works

Every time a **new** PowerShell 7 window opens (outside VS Code, Cursor, and JetBrains), the fetch rolls once.

It picks **art first**. The colours come from **that same rank**. A rare shiny can then swap only the colours.

You see the result under the PC specs:

| Line | Meaning |
| --- | --- |
| **Art** | The logo file, its symbol, and its rank |
| **Palette** | The colour set that was used (name only) |
| **Pity** | How close you are to a guaranteed shiny or mythic |

Chance is **not** printed. The weights below are the real odds.

## Ranks

| Rank | Symbol | How often | Feel |
| --- | --- | --- | --- |
| Mundane | ● | 45 | Common, quiet greys and papers |
| Scarce | ◆ | 25 | A bit harder, earth and metal |
| Rare | ★ | 15 | Gold and royal colours |
| Elite | ✦ | 10 | Bright ice and diamond |
| Mythic | ✹ | 5 | Loud, saturated sets |
| **Shiny** | ✨ | 1 in 100 | Colour override only — the art stays whatever it was |

Shiny is a **palette** event. It does not replace the logo with a special drawing.

## Pity

The game will not leave you dry forever.

- **Shiny** — guaranteed on the 100th roll if you have not seen one
- **Mythic art** — a small boost starting at 50 rolls, guaranteed at 80

There is no separate pity for palettes. If the art is Rare, the palette is Rare (unless shiny overrides it).

## Palettes by rank

| Rank | Palettes |
| --- | --- |
| Mundane | Gray, Silver, Paper, Tin, Dust, Khaki, Denim |
| Scarce | Bronze, Copper, Rust, Moss |
| Rare | Gold, Molten, Platinum, Royal |
| Elite | Diamond, Aurora, Ice, Pearl |
| Mythic | Magic Purple, Hex, Molten Lava, Prismatic, Void Walker |
| Shiny | Starlight, Shiny Gold |

## Useful commands (after a fetch install)

Type these in the same PowerShell 7 window.

```powershell
reroll                 # roll again right now
```

To force a look, or inspect the pool:

```powershell
$rf = Join-Path (Split-Path $PROFILE) 'fastfetch\scripts\randfetch.ps1'

& $rf                  # same as reroll
& $rf -List            # every palette and every art
& $rf -Stats           # pity and history
& $rf -Palette 'Diamond'
& $rf -Art cat.txt
& $rf -Shiny
```

```powershell
$env:FASTFETCH_DISABLE = '1'     # skip the picture on the next windows
```

Walk the whole collection without changing pity (uses dummy PC specs):

```powershell
.\test\preview-palettes.ps1
.\test\preview-arts.ps1
```

See [test/](../test/README.md) and [fastfetch/](../fastfetch/README.md).

To add your own art or colours, open [Customize](customize.md).
