function Get-SepCloudTargetRules {
    <#
    .SYNOPSIS
        Provides a list of all target rules in your SEP Cloud account
    .DESCRIPTION
        Provides a list of all target rules in your SEP Cloud account. Formely known as SEP Location awareness
    .PARAMETER
        None
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepCloudTargetRules
        Gathers all possible target rules
    #>

    begin {
        # Init
        $BaseURL = $($script:configuration.BaseURL)
        $uri = 'https://' + $BaseURL + "/v1/policies/target-rules"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        $params = @{
            Method  = 'GET'
            Uri     = $uri
            Headers = @{
                Host          = $BaseURL
                Accept        = "application/json"
                Authorization = $Token
            }
        }
        try {
            $Response = Invoke-ABWebRequest @params
        }

        catch {
            $StatusCode = $_
            $StatusCode
        }

        return $Response.target_rules
    }
}
