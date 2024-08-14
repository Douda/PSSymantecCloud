function Get-SEPCloudToken {
    <#
    .SYNOPSIS
    Generates an authenticated Token from the SEP Cloud API
    .DESCRIPTION
    Gathers Bearer Token from the SEP Cloud console to interact with the authenticated API
    Securely stores credentials or valid token locally (By default on TEMP location)
    Connection information available here : https://sep.securitycloud.symantec.com/v2/integration/client-applications

    .PARAMETER clientId
    clientId parameter required to generate a token

    .PARAMETER secret
    secret parameter required in combinaison to clientId to generate a token

    .PARAMETER cacheOnly
    if set to $true, will only lookup for in-memory or local cache of token/credentials.
    Will not prompt for credentials or generate a new token.
    Usefful for automation.

    .INPUTS
    [string] clientId
    [string] secret
    .OUTPUTS
    [PSCustomObject] Token

    .EXAMPLE
    Get-SEPCloudToken
    .EXAMPLE
    Get-SEPCloudToken(clientId,secret)
    .EXAMPLE
    Get-SEPCloudToken -clientId "myclientid" -secret "mysecret"

    .NOTES
    Function logic
    - Test if token is already loaded in memory (and verify its validity)
    - Test locally stored encrypted token (and verify its validity)
    - Test if credentials is already loaded in memory to generate a token
    - Test locally stored encrypted Client/secret to generate a token
    - Requests Client/secret to generate token
    #>


    [CmdletBinding()]
    param (
        # clientId from SEP Cloud Connection App
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $clientId,

        # secret from SEP Cloud Connection App
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [string]
        $secret,

        # Unattended
        [switch]
        $cacheOnly
    )

    # Test if token already in memory
    if ($script:SEPCloudConnection.AccessToken) {
        # Check if still valid
        if (Test-SEPCloudToken) {
            Write-Verbose -Message "Token in-memory is still valid"
            return $script:SEPCloudConnection.AccessToken
        }
    }

    # Test if token present on the disk
    if (Test-Path -Path "$script:configuration.cachedTokenPath") {
        $cachedToken = Import-Clixml -Path $script:configuration.cachedTokenPath
        # Check if still valid
        if ((Get-Date) -lt $cachedToken.Expiration) {
            Write-Verbose "Token on disk is still valid"
            return $cachedToken
        } else {
            Write-Verbose -Message "Token on disk expired - deleting"
            Remove-Item $script:configuration.cachedTokenPath
            $script:SEPCloudConnection.AccessToken = $null
            Write-Verbose -Message "continue..."
        }
    }

    # Test if OAuth cred present in memory
    if ($script:SEPCloudConnection.Credential) {
        Write-Verbose -Message "credentials in-memory available - testing"
        try {
            $params = @{
                Uri     = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
                Method  = 'POST'
                Headers = @{
                    Host          = $script:SEPCloudConnection.baseURL
                    Accept        = "application/json"
                    Authorization = "Basic " + $script:SEPCloudConnection.Credential
                }
            }
            $response = Invoke-RestMethod @params

            if ($null -ne $response) {
                # Get the auth token from the response. Store it locally & in memory
                Write-Verbose -Message "credentials in-memory valid - returning valid token"
                $cachedToken = [PSCustomObject]@{
                    Token        = $response.access_token
                    Token_Type   = $response.token_type
                    Token_Bearer = $response.token_type + " " + $response.access_token
                    Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
                }
                $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath
                $script:SEPCloudConnection.AccessToken = $cachedToken
                Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
                return $cachedToken
            }
        } catch {
            $message = "Authentication error - Failed to gather token from locally stored credentials"
            $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)"
            $message = $message + "delete cached credentials"
            $message = $message + "`n" + "Error : $($_.Exception.Response.StatusCode) : $($_.Exception.Response.StatusDescription)"
            Write-Warning -Message $message
            $script:SEPCloudConnection.Credential = $null
            Write-Verbose -Message "continue..."
        }
    }

    # Test if OAuth cred present on the disk
    if ((Test-Path -Path "$script:configuration.SEPCloudCredsPath")) {
        Write-Verbose "credentials on disk available - testing"
        try {
            $params = @{
                Uri     = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
                Method  = 'POST'
                Headers = @{
                    Host          = $script:SEPCloudConnection.baseURL
                    Accept        = "application/json"
                    Authorization = "Basic " + (Import-Clixml -Path $script:configuration.SEPCloudCredsPath)
                }
            }
            $response = Invoke-RestMethod @params

            if ($null -ne $response) {
                # Get the auth token from the response. Store it locally & in memory
                Write-Verbose "Valid credentials - returning valid token"
                $cachedToken = [PSCustomObject]@{
                    Token        = $response.access_token
                    Token_Type   = $response.token_type
                    Token_Bearer = $response.token_type + " " + $response.access_token
                    Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
                }
                $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath
                Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
                $script:SEPCloudConnection.AccessToken = $cachedToken
                return $cachedToken
            }

        } catch {
            $message = "Authentication error - Failed to gather token from locally stored credentials"
            $message = $message + "`n" + "Expected HTTP 200, got $($_.Exception.Response.StatusCode)"
            $message = $message + "delete cached credentials"
            $message = $message + "`n" + "Error : $($_.Exception.Response.StatusCode) : $($_.Exception.Response.StatusDescription)"
            Write-Warning -Message $message
        }
    }

    # If -cacheOnly do not attempt to prompt for credentials for unattended mode
    if ($cacheOnly) {
        return $null
    } else {
        # If no token nor OAuth creds available locally
        # Encode clientId and secret to create Basic Auth string
        # Authentication requires the following "Basic + encoded CliendID:Clientsecret"
        if ($clientID -eq "" -or $secret -eq "") {

            Write-Warning "No local credentials found. Please provide clientId and secret to generate a token"
            $clientId = Read-Host -Prompt "Enter clientId"
            $secret = Read-Host -Prompt "Enter secret" -MaskInput
        }
        $encodedCreds = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($clientId + ':' + $secret)))

        # Verify if the directory exists
        $directory = Split-Path -Path $script:configuration.cachedTokenPath -Parent
        if (-not (Test-Path -Path $directory)) {
            # If the directory does not exist, create it
            New-Item -ItemType Directory -Path $directory | Out-Null
        }

        # Cache the credentials
        $encodedCreds | Export-Clixml -Path $script:configuration.SEPCloudCredsPath
        $script:SEPCloudConnection.Credential = $encodedCreds
        Write-Verbose -Message "stored credentials : $($script:configuration.SEPCloudCredsPath)"

        $params = @{
            Uri             = 'https://' + $script:SEPCloudConnection.baseURL + '/v1/oauth2/tokens'
            Method          = 'POST'
            Headers         = @{
                Host          = $script:SEPCloudConnection.baseURL
                Accept        = "application/json"
                Authorization = "Basic " + $encodedCreds
            }
            useBasicParsing = $true
        }

        $Response = Invoke-RestMethod @params

        if ($null -ne $response) {
            # Get the auth token from the response & store it locally
            Write-Verbose "Valid credentials - returning valid Bearer token"
            $cachedToken = [PSCustomObject]@{
                Token        = $response.access_token
                Token_Type   = $response.token_type
                Token_Bearer = $response.token_type.ToString() + " " + $response.access_token
                Expiration   = (Get-Date).AddSeconds($response.expires_in) # token expiration is 3600s
            }
            $script:SEPCloudConnection.AccessToken = $cachedToken
            $cachedToken | Export-Clixml -Path $script:configuration.cachedTokenPath
            Write-Verbose -Message "stored valid token : $($script:configuration.cachedTokenPath)"
            return $cachedToken
        }

    }
}
