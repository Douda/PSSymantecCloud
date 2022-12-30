function Get-SepCloudPolices {
    # TODO to finish; test cmd-let
    param (
        # Policy UUID
        [Parameter()]
        [string]
        $Policy_UUID

    )

    # Init
    $BaseURL = (Get-ConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/policies"
    # Get token
    $Token = Get-SEPCloudToken

    if ($null -ne $Token) {
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
