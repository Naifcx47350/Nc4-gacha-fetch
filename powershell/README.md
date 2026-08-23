# PowerShell profiles

This folder holds the four startup files. You do not copy them by hand — [`install.ps1`](../install.ps1) (or [`test-shell.ps1`](../test-shell.ps1)) does that.

| Folder | Install | What it turns on |
| --- | --- | --- |
| [all/](all/README.md) | `./install.ps1 1` | Prompt + gacha fetch |
| [prompt/](prompt/README.md) | `./install.ps1 2` | Prompt only |
| [fetch/](fetch/README.md) | `./install.ps1 3` | Gacha fetch only |
| [test/](test/README.md) | `.\test-shell.ps1` | Same as both, but **not** written to your live profile |

`profile.ps1` is an optional conda snippet. The installer never overwrites your real All-hosts / conda profile.

New to this? Start at the [main README](../README.md) and [getting started](../docs/getting-started.md).
