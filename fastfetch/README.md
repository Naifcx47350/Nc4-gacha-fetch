# Gacha engine

This folder is the fetch: ASCII art, colour templates, and the script that rolls them.

You do not run these files by double-clicking. After [option 1](../powershell/all/README.md) or [option 3](../powershell/fetch/README.md), a copy lives next to your PowerShell 7 profile. [`test-shell.ps1`](../powershell/test/README.md) reads **this** copy in the repo.

## Layout

```
fastfetch/
├─ Ascii/                      # drawings, one folder per category
├─ scripts/
│  ├─ randfetch.ps1            # the roll
│  └─ gradient_tag.py          # colour-tag a new drawing
├─ config.template.jsonc       # live specs
└─ config.demo.template.jsonc  # dummy specs (screenshots / test-shell)
```

Generated files (`config.jsonc`, `Ascii/ascii_current.txt`, `gacha-state.json`) are created at run time and are not what you edit.

## Art

Drop a `.txt` file in a category folder (`Cats`, `Dogs`, `Birds`, `Bugs`, `Critters`, `Pokemon`, `Fantasy`, `Spooky`, `Memes`, `People`, `Food`, `Symbols`). The folder name is the category.

How to tag and rank a new piece: [customize](../docs/customize.md).  
What the ranks mean: [gacha](../docs/gacha.md).

## Preview everything

From the project root:

```powershell
.\test\preview-palettes.ps1
.\test\preview-arts.ps1
```

Those use dummy specs and do not move pity. See [test/](../test/README.md).
