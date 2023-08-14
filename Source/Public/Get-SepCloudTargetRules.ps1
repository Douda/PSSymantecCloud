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
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/policies/target-rules"
        $Token = (Get-SEPCloudToken).Token_Bearer
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
    }

    process {
        try {
            $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing
        }

        catch {
            $StatusCode = $_
            $StatusCode
        }

        $Response
    }
}
