function Get-SEPCloudToken {
    <#
    .SYNOPSIS
    Generates an authenticated Token from the SEP Cloud API

    .DESCRIPTION
    Gathers Bearer Token from the SEP Cloud console to interact with the authenticated API
    Securely stores credentials or valid token locally (By default on TEMP location)
    Connection information available here : https://sep.securitycloud.symantec.com/v2/integration/client-applications

    .PARAMETER ClientID
    ClientID parameter required to generate a token

    .PARAMETER Secret
    Secret parameter required in combinaison to ClientID to generate a token

    .EXAMPLE
    Get-SEPCloudToken

    .EXAMPLE
    Get-SEPCloudToken(ClientID,Secret)

    .NOTES
    Function logic
    1. Test locally stored encrypted token
    2. Test locally stored encrypted Client/Secret to generate a token
    3. Requests Client/Secret to generate token
    #>

    [CmdletBinding()]
    param (
        # ClientID from SEP Cloud Connection App
        [Parameter()]
        [string]
        $ClientID,

        # Secret from SEP Cloud Connection App
        [Parameter()]
        [string]
        $Secret
    )

    # init
    $BaseURL = (GetConfigurationPath).BaseUrl
    $SepCloudCreds = (GetConfigurationPath).SepCloudCreds
    $SepCloudToken = (GetConfigurationPath).SepCloudToken
    $URI_Tokens = 'https://' + $BaseURL + '/v1/oauth2/tokens'
    $URI_Features = 'https://' + $BaseURL + '/v1/devices/enums'

    # Test if we have a token locally stored
    if (Test-Path -Path $SepCloudToken) {
        <# If true, test it against the API #>
        $Token = Import-Clixml -Path $SepCloudToken
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
        }

        try {
            $response = Invoke-RestMethod -Method POST -Uri $URI_Features -Headers $Headers
            # Valid token, returning it
            Write-Verbose "Local token - valid"
            return $Token
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode
            Write-Verbose "Authentication error - From locally stored token - Expected HTTP 200, got $([int]$StatusCode) - Continue ..."
            # Invalid token, deleting local token file
            Remove-Item $SepCloudToken
        }
    }

    # Test if OAuth cred present on the disk
    if (Test-Path -Path "$SepCloudCreds") {
        <# If true, Attempt to get a token #>
        $OAuth = Import-Clixml -Path $SepCloudCreds
        $OAuth_Basic = "Basic " + $OAuth
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $OAuth_Basic
        }

        try {
            $response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers

            # Get the auth token from the response & store it locally
            Write-Verbose "Valid credentials - returning valid token"
            $null = $Bearer_Token = "Bearer " + $response.access_token
            $Bearer_Token | Export-Clixml -Path $SepCloudToken
            return $Bearer_Token

        } catch {
            $StatusCode = $_.Exception.Response.StatusCode
            Write-Verbose "Authentication error - From locally stored credentials - Expected HTTP 200, got $([int]$StatusCode) - Continue..."
            # Invalid Credentials, deleting local credentials file
            Remove-Item $SepCloudCreds
        }
    }


    <# If no token nor OAuth creds available locally
    # Encode ClientID and Secret to create Basic Auth string
    # Authentication requires the following "Basic + encoded CliendID:ClientSecret" #>
    if ($clientID -eq "" -or $Secret -eq "") {
        Write-Host "No local credentials found"
        $ClientID = Read-Host -Prompt "Enter ClientID"
        $Secret = Read-Host -Prompt "Enter Secret"
    }
    $Encoded_Creds = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($ClientID + ':' + $Secret)))
    $Encoded_Creds | Export-Clixml -Path $SepCloudCreds

    # Create Basic Auth string
    $BasicAuth = "Basic " + $Encoded_Creds
    $Headers = @{
        Host          = $BaseURL
        Accept        = "application/json"
        Authorization = $BasicAuth
    }
    $Response = Invoke-RestMethod -Method POST -Uri $URI_Tokens -Headers $Headers -UseBasicParsing

    # Get the auth token from the response and store it
    $Bearer_Token = "Bearer " + $Response.access_token
    $Bearer_Token | Export-Clixml -Path $SepCloudToken
    return $Bearer_Token
}
