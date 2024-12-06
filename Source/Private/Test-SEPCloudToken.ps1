function Test-SEPCloudToken {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject]
        $token
    )

    if ($script:SEPCloudConnection.AccessToken) {
        # Check if still valid
        if ((Get-Date) -lt $script:SEPCloudConnection.AccessToken.Expiration) {
            return $True
        } else {
            Remove-SEPCloudToken
            return $false
        }
    } elseif ($token) {
        if ((Get-Date) -lt $token.Expiration) {
            return $True
        }
    } else {
        Write-Verbose -Message "no token available in memory"
        return $False
    }
}
