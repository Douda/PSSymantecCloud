function Test-SEPCloudToken {

    Write-Verbose -Message "Test-SEPCloudToken: $script:SEPCloudConnection.AccessToken.Token"

    if ($script:SEPCloudConnection.AccessToken) {
        # Check if still valid
        if ((Get-Date) -lt $script:SEPCloudConnection.AccessToken.Expiration) {
            Write-Verbose -Message "token valid - returning"
            return $True
        } else {
            Write-Verbose -Message "token expired - deleting"
            $script:configuration.AccessToken = $null
            Remove-Item $script:configuration.CachedTokenPath -Force
            return $false
        }
    }
}
