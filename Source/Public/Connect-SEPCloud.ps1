function Connect-SEPCloud {
    [CmdletBinding()]
    param (
        # Additional information to be added, takes hashtable as input
        [hashtable] $UserAgent
    )

    process {
        # Create User Agent string
        $UserAgentString = New-UserAgentString -UserAgentHash $UserAgent
        $PSBoundParameters.Remove($UserAgent) | Out-Null
        Remove-Variable -Force -Name UserAgent -ErrorAction SilentlyContinue

        Write-Verbose -Message "Using User Agent $($UserAgentString)"

        $token = Get-SEPCloudToken
        $head = @{'Authorization' = "$($Token.Token_Bearer)"; 'User-Agent' = $UserAgentString }

        # Needs to keep handling token in Get-SEPCloudToken for the moment
        # TODO: Update Get-SEPCloudToken to get inline with the new design from Get-SEPCloudAPIData instead of a standalone custom function

        Write-Verbose -Message 'Storing all connection details into $script:SEPCloudConnection'
        [PSCustomObject] $script:SEPCloudConnection = [PSCustomObject]@{
            BaseURL     = "api.sep.securitycloud.symantec.com"
            Credential  = $null
            AccessToken = $token
            time        = (Get-Date)
            header      = $head
        }
    }
}
