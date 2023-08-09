function Get-SepCloudFeatureList {
    <# TODO : fill in description Get-SepCloudFeatureList
    .SYNOPSIS
        retrieve SES enumeration details for your devices like feature names, security status and reason codes.
    .DESCRIPTION
        retrieve SES enumeration details for your devices like feature names, security status and reason codes.
    .PARAMETER
        None
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepCloudFeatureList
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding()]
    param ()

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/devices/enums"
        # Get token
        $Token = Get-SEPCloudToken
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
