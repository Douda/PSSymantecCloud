function Test-SEPCloudToken {

    Write-Verbose -Message "Test in-memory token"

    if ($script:SEPCloudConnection.AccessToken) {
        # Check if still valid
        if ((Get-Date) -lt $script:SEPCloudConnection.AccessToken.Expiration) {
            Write-Verbose -Message "token valid - returning"
            return $True
        } else {
            Write-Verbose -Message "token expired - deleting in-memory"
            Write-Verbose -Message "token expired - deleting local copy at $($script:configuration.CachedTokenPath)"
            $script:SEPCloudConnection | Add-Member -MemberType NoteProperty -Name AccessToken -Value $null -Force
            $script:configuration | Add-Member -MemberType NoteProperty -Name AccessToken  -Value $null -Force
            if ($script:configuration.CachedTokenPath) {
                Remove-Item $script:configuration.CachedTokenPath -Force
            }
            return $false
        }
    } else {
        Write-Verbose -Message "no token available in memory"
        return $False
    }
}
