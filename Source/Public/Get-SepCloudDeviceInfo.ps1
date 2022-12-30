function Get-SepCloudDeviceInfo {
    param (
        # Mandatory device_ID parameter
        [Parameter(mandatory)]
        [string]
        $Device_ID
    )

    # Init
    $BaseURL = (Get-ConfigurationPath).BaseUrl
    $URI_Tokens = 'https://' + $BaseURL + "/v1/devices/$Device_ID"
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
