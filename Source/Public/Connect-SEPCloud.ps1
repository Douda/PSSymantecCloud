function Connect-SEPCloud {
    [CmdletBinding()]
    param (
        # Additional information to be added, takes hashtable as input
        [hashtable] $UserAgent,
        [switch] $cacheOnly
    )

    process {
        # Create User Agent string
        $UserAgentString = New-UserAgentString -UserAgentHash $UserAgent
        $PSBoundParameters.Remove($UserAgent) | Out-Null
        Remove-Variable -Force -Name UserAgent -ErrorAction SilentlyContinue

        Write-Verbose -Message "Using User Agent $($UserAgentString)"

        # If called from Initialize-SEPCloudConfiguration
        # get token from cache only to avoid prompting for creds while loading the module
        if ($cacheOnly) {
            $token = Get-SEPCloudToken -cacheOnly
        } else {
            $token = Get-SEPCloudToken
        }

        # if we have a token, add it to the header
        if ($null -ne $token) {
            $head = @{'Authorization' = "$($Token.Token_Bearer)"; 'User-Agent' = $UserAgentString }
            Write-Verbose -Message 'Storing header connection details into $script:SEPCloudConnection'
            $script:SEPCloudConnection | Add-Member -Type NoteProperty -Name 'header' -Value $head -Force
        }
    }
}
