function Get-SEPCloudPolicesSummary {
    <#
    .SYNOPSIS
        Provides a list of all SEP Cloud policies
    .DESCRIPTION
        Provides a list of all SEP Cloud policies
    .PARAMETER
        None
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SEPCloudPolicesSummary
        Gathers all possible policies in your SEP Cloud account
    #>

    begin {
        # Init
        $baseUrl = $($script:configuration.baseUrl)
        $uri = 'https://' + $baseUrl + "/v1/policies"
        $token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $params = @{
            Method  = 'GET'
            Uri     = $uri
            Headers = @{
                # Host          = $baseUrl
                Accept        = "application/json"
                Authorization = $token
            }
        }

        try {
            $response = Invoke-SEPCloudWebRequest @params
        } catch {
            "Error : " + $_
        }

        return $response
    }
}
