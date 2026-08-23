# Test profile

This startup file is **only** for [`test-shell.ps1`](../../test-shell.ps1) at the project root. It is never copied over your live PowerShell 7 profile.

Use it when you want to see the prompt and the fetch from **this repo** without installing.

## Launch

From the project root, in PowerShell 7:

```powershell
.\test-shell.ps1
```

That opens a new window with:

- This test profile
- The repo’s [`fastfetch/`](../../fastfetch/README.md) folder
- The repo’s [prompt theme](../prompt/themes/nc4.omp.json)
- **Dummy** PC specs (the same fake hardware as the README screenshots)

Flags:

```powershell
.\test-shell.ps1 -Live         # your real CPU / RAM / name
.\test-shell.ps1 -Installed    # use ~/.config/fastfetch-test instead of the repo
```

`-Installed` is for `./install.ps1 1 -Test` (or any fetch option with `-Test`), which copies the engine only and leaves `$PROFILE` alone.

## What this profile does

Same as [option 1](../all/README.md): prompt + fetch + `reroll`. The difference is **where** it runs — a disposable `pwsh -NoProfile` window, not your everyday tab.

Pity writes are off in the [preview scripts](../../test/README.md). `test-shell.ps1` itself can write pity if you reroll a lot; use the preview scripts when you want a full walk with no pity.

## Requirements

You still need PowerShell 7, a Nerd Font, oh-my-posh, and fastfetch on the machine. The test launcher does not install those. See [getting started](../../docs/getting-started.md).
