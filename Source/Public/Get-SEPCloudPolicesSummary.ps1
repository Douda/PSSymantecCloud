function Get-SEPCloudPolicesSummary {
    <#
    .SYNOPSIS
        Provides a list of all policies in your SEP Cloud account
    .DESCRIPTION
        Provides a list of all policies in your SEP Cloud account
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
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/policies"
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

        $Response.policies
    }
}
