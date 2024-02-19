function Clear-SepCloudAuthentication {
    <#
    .SYNOPSIS
        Clears out any API token from memory, as well as from local file storage.
    .DESCRIPTION
        Clears out any API token from memory, as well as from local file storage.
    .EXAMPLE
        Clear-SepCloudAuthentication

        Clears out any GitHub API token from memory, as well as from local file storage.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param ()

    Remove-Item -Path $($script:configuration.CachedTokenPath) -Force -ErrorAction SilentlyContinue -ErrorVariable ev
    Remove-Item -Path $($script:configuration.SepCloudCreds) -Force -ErrorAction SilentlyContinue -ErrorVariable ev

    if (($null -ne $ev) -and
            ($ev.Count -gt 0) -and
            ($ev[0].FullyQualifiedErrorId -notlike 'PathNotFound*')) {
        $message = "Experienced a problem trying to remove the file that persists the Access Token " + $($script:configuration.SepCloudCreds)
        $message += "Experienced a problem trying to remove the file that persists the Access Credentials " + $($script:configuration.CachedTokenPath)
        Write-Warning -Message $message
    }
}
