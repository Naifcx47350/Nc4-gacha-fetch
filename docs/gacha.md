# How the gacha works

Every time a **new** PowerShell 7 window opens (outside VS Code, Cursor, and JetBrains), the fetch rolls once.

It picks **art first**. The colours come from **that same rank**. A very rare shiny then refoils those colours.

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
| Mundane | ● | 48% | Common, quiet greys and papers |
| Scarce | ◆ | 25% | A bit harder, earth and metal |
| Rare | ★ | 15% | Gold and royal colours |
| Elite | ✦ | 10% | Bright ice and diamond |
| Mythic | ✹ | 2% | Loud, saturated sets |
| **Shiny** | ✨ | 1 in 1000 | Refoils whatever colours you rolled |

Shiny is a **palette** event. It does not replace the logo with a special drawing.

## Shiny

A shiny does not throw your palette away and hand you a different one. It takes the
palette you actually rolled and refoils it, so the rank still shows through. That is why
the Palette line reads **✨ Shiny Silver** or **✨ Shiny Molten Lava** — every one of the
22 normal palettes has a shiny form, and the sparkle sits next to the rank symbol on the
Art line too.

Refoiling keeps each colour at the brightness it already had, so nothing becomes
unreadable on a black terminal. What changes is the colour itself:

- The hue rotates a little further with every step up the ramp, so a flat colour becomes a spectrum sweep. Grey palettes like Silver, which have no colour to rotate, get one from a saturation floor — a shiny Silver is not grey at all.
- A three-stop highlight lands somewhere random along the ramp, like light catching a foil card. Its position changes every time, so no two shinies look quite alike.

### Exclusives

One shiny in six is an **exclusive** instead. These are the only two palettes that ignore
your roll completely: any art can pull them, and they override both the rank and its
colours. They are marked ❈ rather than ✨.

| Exclusive | Look |
| --- | --- |
| Starlight | Near-white with faint blue and violet drift |
| Shiny Gold | White through warm gold, dropped into deep teal |

That works out to roughly one exclusive every 2,400 rolls.

## Pity

The game will not leave you dry forever.

- **Shiny** — guaranteed on the 500th roll if you have not seen one. Counting the 1-in-1000 chance along the way, a shiny lands about every 394 rolls on average.
- **Mythic art** — guaranteed on the 100th roll without one. There is no gradual boost before that; the odds stay a flat 2% until the guarantee.

There is no separate pity for palettes. If the art is Rare, the palette is Rare — shiny or
not, since a shiny keeps the rank it landed on.

## Palettes by rank

| Rank | Palettes |
| --- | --- |
| Mundane | Gray, Silver, Paper, Tin, Dust, Khaki, **Denim** |
| Scarce | Bronze, Copper, Rust, Moss, **Fern** |
| Rare | Gold, Molten, Platinum, **Royal**, **Rose** |
| Elite | Diamond, Aurora, Ice, **Pearl**, **Sapphire** |
| Mythic | **Magic Purple**, Hex, Molten Lava, Prismatic, Void Walker |
| Exclusive | Starlight, Shiny Gold |

Every palette above except the exclusives also has a shiny form, so the real pool is
27 palettes, 27 shiny palettes, and 2 exclusives.

### Which way a palette runs

Most palettes start dark and climb to a light colour. The **bold** ones above run the
other way, starting bright and descending into a deep colour, so the collection is not
all the same shape. Every rank has at least one.

A descending palette cannot end darker than the readability floor. Anything below it gets
mixed toward white so it stays visible on a black terminal, which also drains the colour
out — pure `#0a0000` would arrive on screen as the grey `#4A4242`. The reversed palettes
therefore end *at* the floor on a deep, saturated colour rather than going darker and
losing the hue.

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
& $rf -Shiny -Palette 'Silver'    # see one palette's shiny form
& $rf -Palette 'Starlight'        # force an exclusive
```

```powershell
$env:FASTFETCH_DISABLE = '1'     # skip the picture on the next windows
```

Walk the whole collection without changing pity (uses dummy PC specs):

```powershell
.\test\preview-palettes.ps1
.\test\preview-palettes.ps1 -Shiny    # the shiny form of each one
.\test\preview-palettes.ps1 -Both     # each one next to its shiny form
.\test\preview-arts.ps1
```

See [test/](../test/README.md) and [fastfetch/](../fastfetch/README.md).

To add your own art or colours, open [Customize](customize.md).
