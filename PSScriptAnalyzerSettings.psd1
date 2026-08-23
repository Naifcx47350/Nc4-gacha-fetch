@{
    # Rules switched off on purpose. Each one is a deliberate choice in this
    # project, not an oversight, so leaving them on would make CI meaningless.
    ExcludeRules = @(
        # This is an installer and a terminal splash. Console output IS the
        # product; it is never piped into another command.
        'PSAvoidUsingWriteHost'

        # oh-my-posh's own documented init is `oh-my-posh init pwsh | Invoke-Expression`.
        'PSAvoidUsingInvokeExpression'

        # $global:FASTFETCH_RAN has to outlive the profile scope so the fetch
        # does not run twice when a profile is dot-sourced again.
        'PSAvoidGlobalVars'

        # fastfetch reads these files as UTF-8. A BOM breaks the JSON parse.
        'PSUseBOMForUnicodeEncodedFile'

        # install.ps1 captures $PSCmdlet once as $script:Cmdlet so nested helpers
        # can call ShouldProcess. The analyzer cannot follow that indirection, so
        # it reports false positives on helpers that are in fact fully guarded.
        'PSShouldProcess'
        'PSUseShouldProcessForStateChangingFunctions'

        # Helper names read better plural (Remove-OldBackups, Show-GachaStats).
        'PSUseSingularNouns'

        # Fires on parameters used only inside nested functions or if-conditions.
        'PSReviewUnusedParameter'
    )
}
