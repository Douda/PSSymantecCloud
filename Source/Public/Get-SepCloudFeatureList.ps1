function Get-SepCloudFeatureList {
    <#
    .SYNOPSIS
        retrieve SES enumeration details for your devices like feature names, security status and reason codes.
    .DESCRIPTION
        retrieve SES enumeration details for your devices like feature names, security status and reason codes.
    .PARAMETER
        None
    .INPUTS
        None
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepCloudFeatureList
        Gathers all possible feature name, content name, security status and reason codes the API can provide and its related IDs
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/devices/enums"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        # HTTP body content containing all the queries
        $Body = @{}
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
            Body          = $Body
        }
        $Response = Invoke-RestMethod -Method GET -Uri $URI_Tokens -Headers $Headers -Body $Body -UseBasicParsing
        return $Response
    }
}
