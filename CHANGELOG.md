# Changelog

Notable changes to this project. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-08-24

### Changed

- **Shiny now refoils the palette you rolled instead of replacing it.** Every rank palette has a shiny form, so `✨ Shiny Silver` and `✨ Shiny Molten Lava` are both possible and the rank still reads through. Refoiling rotates each stop's hue further along the ramp, raises saturation to a floor so grey palettes gain real colour, and drops a three-stop specular highlight at a random position. Every stop keeps its original brightness, so nothing lands below the readability floor that was not already there.
- **Shiny odds cut from 1-in-100 to 1-in-1000, hard pity moved from 250 to 500.** With pity counted in, a shiny now averages one roll in 394 rather than one in 88.
- **`Starlight` and `Shiny Gold` became exclusives.** They are the only palettes that override the rolled rank outright, they appear on one shiny in six, and they carry ❈ instead of ✨.

- **Every rank now has a palette that runs bright to dark**, instead of the collection nearly all climbing dark to light: `Denim` and `Pearl` were flipped, and `Fern`, `Rose`, and `Sapphire` are new. Each ends *at* the readability floor on a saturated colour rather than below it, since anything darker gets mixed toward white and loses its hue.
- **`Royal` reworked** from pale gold into a brighter gold that falls through orange to red, and no longer ends on a near-black that rendered as grey.
- **`Magic Purple` gained a middle anchor and now descends**, running pale lavender through its signature `#c77dff` into deep violet.
- **`Shiny Gold` no longer ends on an unrelated teal.** It now crosses white, light gold, gold, and deep gold in one continuous ramp.
- **`Starlight` given actual range.** It was nine near-identical whites; it now falls from white through periwinkle into twilight blue.
- **`Void Walker` rebuilt and reversed.** It now climbs rather than descends, running slate charcoal through crimson into light grey and white. Its old ending pair rendered as flat grey rather than the intended dark red, since both sat far below the readability floor.

### Added

- **Three new palettes** — `Fern` (Scarce), `Rose` (Rare), and `Sapphire` (Elite), bringing the pool to 27 rank palettes plus 2 exclusives.
- `shinyKind` on each `gacha-state.json` history entry, recording whether a roll was a `foil` or an `exclusive`.

## [1.0.0] - 2026-08-23

First public release.

### Added

- **Gacha startup fetch.** Each new PowerShell 7 session rolls a rarity-weighted ASCII logo and paints [fastfetch](https://github.com/fastfetch-cli/fastfetch) with a colour set from that same rank. `reroll` rolls again in place.
- **Six ranks** — Mundane 48%, Scarce 25%, Rare 15%, Elite 10%, Mythic 2%, plus a 1-in-100 Shiny that overrides the palette. Hard pity at 250 for shiny and 100 for mythic art.
- **26 palettes and 80 ASCII pieces** across twelve categories.
- **Three install options** — `1` prompt and fetch, `2` prompt only, `3` fetch only.
- **`-Link` install mode** that runs the engine straight from a clone, so art you add appears in the next tab without reinstalling.
- **oh-my-posh prompt theme** with user, host, exec time, RAM, clock, git, and language segments.
- **`-WhatIf` on every install command**, reporting each change without writing anything.
- **`test-shell.ps1`** for trying the setup without replacing your profile, plus `test/preview-palettes.ps1` and `test/preview-arts.ps1` to walk the whole collection using dummy specs.
- **Beginner documentation** under `docs/`, plus a README in each install folder.
- **CI** on `windows-latest`: PSScriptAnalyzer, JSON validation, art-tag checks, engine smoke tests, per-palette config validation, and installer dry runs.

### Changed

- Palettes now follow the art's rank instead of rolling independently.
- The engine installs to one location beside your PowerShell profile. The unused second copy under `~/.config/fastfetch` is retired on install.
- Dark palette stops are lifted toward white so they stay readable on black terminals, and info keys skip the two darkest stops.

### Fixed

- Reinstalling no longer resets pity and roll history; `gacha-state.json` is carried across installs.
- The installer refuses to run under Windows PowerShell 5.1 instead of silently installing to the wrong profile.
- PSReadLine prediction options no longer throw when console output is redirected.
- Timestamped backups are pruned to the three newest (`-KeepBackups` to change).
- `randfetch.bat` requires PowerShell 7 rather than falling back to 5.1, which wrote a byte-order mark that fastfetch could not parse.
- `-Test` no longer stages the engine for prompt-only installs.
- The `Display` line printed only the refresh rate (`60`) instead of the resolution; it now reads `1920x1080 @ 60Hz`.
- The `GPU` line repeated the vendor (`NVIDIA NVIDIA GeForce…`).
- Repeated hardware is now labelled: displays and GPUs are numbered, and each disk shows its drive letter, so machines with two monitors, two drives, or a discrete plus integrated GPU no longer show identical keys.

[Unreleased]: https://github.com/naifcx47350/nc4-gacha-fetch/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/naifcx47350/nc4-gacha-fetch/releases/tag/v1.0.0
