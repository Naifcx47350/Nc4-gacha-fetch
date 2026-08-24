# Previews

Scripts here walk the collection. They do **not** install anything and they do **not** change your live profile.

Run them from the **project root**.

```powershell
.\test\preview-palettes.ps1           # every colour set, random art
.\test\preview-palettes.ps1 -Shiny    # the shiny form of every colour set
.\test\preview-palettes.ps1 -Both     # each colour set next to its shiny form
.\test\preview-arts.ps1               # every logo, white ink, Gray palette
```

Each preview is tagged with what you are looking at: nothing for a normal palette,
`[shiny]` for its refoiled form, and `[exclusive]` for the two that override the roll
instead of refoiling it. Press Enter to step to the next one.

Both use dummy PC specs and skip pity writes, so you can page through looks without advancing shiny / mythic counters.

For a real interactive window (prompt + one roll) that still leaves your live profile alone:

```powershell
.\test-shell.ps1
```

See [powershell/test](../powershell/test/README.md).
