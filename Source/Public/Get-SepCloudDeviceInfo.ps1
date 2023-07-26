function Get-SepCloudDeviceInfo {
    #TODO find a way to use the command with the computername and not the device_ID
    # Remove Device ID as mandatory when adding the computername option
    [CmdletBinding()]
    param (
        # Mandatory device_ID parameter
        [Parameter(mandatory,
            ValueFromPipelineByPropertyName = $true)]
        [string]
        $Device_ID
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $URI_Tokens = 'https://' + $BaseURL + "/v1/devices/$Device_ID"
        # Get token
        $Token = Get-SEPCloudToken
    }

    process {

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
}
