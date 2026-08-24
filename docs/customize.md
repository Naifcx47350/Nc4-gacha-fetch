# Customize

Change the look after install. Art and palettes you add **in this repo** do not update a live install until you run `./install.ps1` again (or copy the files yourself).

[`test-shell.ps1`](../powershell/test/README.md) always reads the repo, so it is the safer place to experiment.

## Working on art without reinstalling

If you add art often, the copy-then-reinstall loop gets tiring. Link your shell to this repo instead:

```powershell
./install.ps1 1 -Link
```

That installs the profile as usual but **skips the copy** — your shell runs the engine straight out of this folder, so anything you drop in `fastfetch/Ascii/` appears in the next new tab.

Things to know about a linked install:

- Keep the repo where it is. If you move or delete it, new tabs quietly fall back to plain fastfetch until you install again.
- Your pity file is stored **outside** the repo (next to your PowerShell profile), so `git clean` and branch switches cannot wipe it.
- `config.jsonc` and `Ascii/ascii_current.txt` get rewritten inside the repo on every roll. Both are already in `.gitignore`, so `git status` stays clean.
- To go back to a normal self-contained copy, run `./install.ps1 1` without `-Link`. It clears the link for you.

Add `-WhatIf` to see exactly what either one would do first.

## ASCII art (fetch)

1. Pick a category folder under `fastfetch/Ascii/` (`Cats`, `Dogs`, `Memes`, …) — the [engine folder guide](../fastfetch/README.md) lists every category.
2. Save a plain `.txt` drawing there.
3. Tag the colour slots:

```powershell
py fastfetch/scripts/gradient_tag.py fastfetch/Ascii/Cats/mycat.txt
```

4. Set a rank in `$asciiCatalog` inside `fastfetch/scripts/randfetch.ps1`.  
   Art that is not listed is treated as **Mundane**.  
   The **folder name** is what shows as the category.

`$1` through `$9` are the nine colour slots on the logo. `$0` is a colour reset on the **last** art line. It is not a blank row.

Python 3.9+ is only needed for that tagging script.

## Palettes (fetch)

Add a block to `$palettes` in `fastfetch/scripts/randfetch.ps1`:

```powershell
@{ Name = 'My Scheme'; Rarity = 'Elite'; Anchors = @('#3a4a8c', '#4040ff', '#ffffff') }
```

| Field | What it does |
| --- | --- |
| `Name` | Shown on the **Palette** line |
| `Rarity` | Which art rank may use this set |
| `Anchors` | A few hex colours; they blend into 9 stops |
| `Slots` | Exactly 9 hex colours, no blending |
| `Banded` | Hard stops instead of a smooth blend |
| `KeyAnchors` | Colours only the labels on the right (System, OS, …) |

Keep the rank honest: an Elite palette should live on Elite art.

### Do not pick anchors that are too dark

This is the one rule that catches people out. Anything darker than **luma 68** gets mixed
toward white before it is drawn, so it stays visible on a black terminal — and that also
drains the colour out of it. A near-black `#0a0000` does not arrive as black, it arrives
as the grey `#4A4242`, and your deep red is gone.

So a palette that is meant to end on a dark colour should end *at* that floor on a
saturated one, not below it. `#a82c2c` sits just above the line and is drawn exactly as
written; `#4a0510` does not and comes out a muddy `#6F3840`. You can check any colour with:

```powershell
$hex = '#a82c2c'
$v = [Convert]::ToInt32($hex.TrimStart('#'), 16)
(0.2126 * (($v -shr 16) -band 255)) + (0.7152 * (($v -shr 8) -band 255)) + (0.0722 * ($v -band 255))
```

Luma is linear, so if every anchor clears 68, every blended stop between them does too.

Green clears the floor easily and deep blues and reds are the hardest, because the eye
weights green far more heavily than blue.

### Which direction it runs

Most palettes climb from dark to light. Each rank also carries at least one that runs the
other way so the collection is not all the same shape — those are tagged `# bright -> dark`
in the engine. If you are adding one of those, the rule above is what decides how dark you
can actually finish.

You do not need to design a shiny version. Every palette gets one automatically: a shiny
roll refoils whatever colours it landed on. See [How the gacha works](gacha.md#shiny), and
preview yours with `.\test\preview-palettes.ps1 -Both`.

## Prompt

The theme file is [`powershell/prompt/themes/nc4.omp.json`](../powershell/prompt/themes/nc4.omp.json), described in the [prompt folder guide](../powershell/prompt/README.md).

If the installer found a theme you already had (`Nc4.omp.json` or `themes\nc4.omp.json` next to your PowerShell 7 profile), it **left that file alone**. Edit the one that is actually on disk:

```powershell
# this prints the folder your live profile lives in
Split-Path $PROFILE
```

[oh-my-posh](https://ohmyposh.dev/) documents every segment if you want to add or remove blocks.

## Optional start folder

Each profile has a commented line for `$Nc4StartPath`. Set it to a folder if you want every new PowerShell 7 window to open there. The installer keeps a path it finds in your old profile.

## Windows Terminal chrome

Font, transparency, and the Tango Dark scheme used in the screenshots: [terminal/](../terminal/README.md).
