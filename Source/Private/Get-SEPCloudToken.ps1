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
    .INPUTS
    [string] ClientID
    [string] Secret
    .OUTPUTS
    [PSCustomObject] Token

    .EXAMPLE
    Get-SEPCloudToken
    .EXAMPLE
    Get-SEPCloudToken(ClientID,Secret)
    .EXAMPLE
    Get-SEPCloudToken -ClientID "myclientid" -Secret "mysecret"

    .NOTES
    Function logic
    1. Test locally stored encrypted token
    2. Test locally stored encrypted Client/Secret to generate a token
    3. Requests Client/Secret to generate token
    #>


    [CmdletBinding()]
    param (
        # ClientID from SEP Cloud Connection App
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $ClientID,

        # Secret from SEP Cloud Connection App
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $Secret
    )
    begin {
        try {
            # init
            $BaseURL = $($script:configuration.BaseURL)
            $SepCloudCreds = $($script:configuration.SepCloudCreds)
            $CachedTokenPath = $($script:configuration.CachedTokenPath)
            $uriTokens = 'https://' + $BaseURL + '/v1/oauth2/tokens'

            if (-not $BaseURL) { throw "Missing 'BaseUrl' configuration value" }
            if (-not $SepCloudCreds) { throw "Missing 'SepCloudCreds' configuration value" }
            if (-not $CachedTokenPath) { throw "Missing 'CachedTokenPath' configuration value" }
        } catch {
            throw "Error initializing SEPCloudToken: $_"
        }
    }

    process {
        # Check if we already have a valid token
        if (Test-Path -Path "$CachedTokenPath") {
            $CachedToken = Import-Clixml -Path $CachedTokenPath
            # Check if still valid
            if ((Get-Date) -lt $CachedToken.Expiration) {
                Write-Verbose "cached token valid - returning"
                return $CachedToken
            } else {
                Write-Verbose "Cached token expired - deleting"
                Remove-Item $CachedTokenPath
            }
        }

        # Test if OAuth cred present on the disk
    elseif (Test-Path -Path "$script:configuration.SEPCloudCredsPath") {
        $OAuth = "Basic " + (Import-Clixml -Path $script:configuration.SEPCloudCredsPath)
            $Headers = @{
                Host          = $BaseURL
                Accept        = "application/json"
                Authorization = $OAuth
            }

            try {
                $params = @{
                    Uri     = $uriTokens
                    Method  = 'POST'
                    Headers = $Headers
                }
                $response = Invoke-RestMethod @params

                # Get the auth token from the response & store it locally
                Write-Verbose "Valid credentials - returning valid token"
                $CachedToken = [PSCustomObject]@{
                    Token        = $response.access_token
                    Token_Type   = $response.token_type
                    Token_Bearer = $response.token_type + " " + $response.access_token
                    Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
                }
                $CachedToken | Export-Clixml -Path $CachedTokenPath
                return $CachedToken

            } catch {
                $StatusCode = $_.Exception.Response.StatusCode
                $message = "Authentication error - Failed to gather token from locally stored credentials"
                $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)"
                $message = $message + "delete cached credentials"
                Write-Warning $message
                # Invalid Credentials, deleting local credentials file
                Remove-Item $SepCloudCreds
            }
        }

        # If no token nor OAuth creds available locally
        # Encode ClientID and Secret to create Basic Auth string
        # Authentication requires the following "Basic + encoded CliendID:ClientSecret"
        if ($clientID -eq "" -or $Secret -eq "") {
            Write-Warning "No local credentials found. Please provide ClientID and Secret to generate a token"
            $ClientID = Read-Host -Prompt "Enter ClientID"
            $Secret = Read-Host -Prompt "Enter Secret"
        }
        $Encoded_Creds = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($ClientID + ':' + $Secret)))

        # Verify if the directory exists
        $directory = Split-Path -Path $CachedTokenPath -Parent
        if (-not (Test-Path -Path $directory)) {
            # If the directory does not exist, create it
            New-Item -ItemType Directory -Path $directory | Out-Null
        }

        # Cache the credentials
    $encodedCreds | Export-Clixml -Path $script:configuration.SEPCloudCredsPath

        # Setup the headers for the request
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
        Authorization = "Basic " + $encodedCreds
        }

        $params = @{
            Uri             = $uriTokens
            Method          = 'POST'
            Headers         = $Headers
            useBasicParsing = $true
        }

        $Response = Invoke-RestMethod @params

        # Get the auth token from the response & store it locally
        Write-Verbose "Valid credentials - returning valid Bearer token"
        $CachedToken = [PSCustomObject]@{
            Token        = $response.access_token
            Token_Type   = $response.token_type
            Token_Bearer = $response.token_type + " " + $response.access_token
            Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
        }
        $CachedToken | Export-Clixml -Path $CachedTokenPath
        return $CachedToken
    }
}
