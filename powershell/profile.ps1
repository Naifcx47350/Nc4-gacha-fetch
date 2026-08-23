# Optional AllHosts snippet. Merge into $PROFILE.CurrentUserAllHosts if you use conda.

$condaCandidates = @(
    "$env:USERPROFILE\anaconda3\Scripts\conda.exe",
    "$env:USERPROFILE\miniconda3\Scripts\conda.exe",
    "$env:USERPROFILE\Anaconda3\Scripts\conda.exe",
    "$env:ProgramData\anaconda3\Scripts\conda.exe",
    "$env:ProgramData\miniconda3\Scripts\conda.exe"
)

$condaExe = $condaCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($condaExe) {
    (& $condaExe 'shell.powershell' 'hook') | Out-String | Where-Object { $_ } | Invoke-Expression
}
