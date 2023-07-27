function Get-SepCloudDeviceDetails {
    # TODO add documentation
    <#
    .SYNOPSIS
        Gathers device details from the SEP Cloud console
    .DESCRIPTION
        Gathers device details from the SEP Cloud console
    .PARAMETER Device_ID
        id used to lookup a unique computer
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        Get-SepCloudDeviceDetails -id wduiKXDDSr2CVrRaqrFKNx
    .EXAMPLE
        Get-SepCloudDeviceDetails -computername MyComputer
    #>

    [CmdletBinding()]
    param (
        # device_ID parameter
        [Parameter(
            ValueFromPipelineByPropertyName = $true)]
        [Alias("id")]
        [string]
        $Device_ID,

        # Computer Name
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias("Computer")]
        [Alias("Device")]
        [Alias("host")]
        [string]
        $Computername
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        # Get token
        $Token = Get-SEPCloudToken
    }

    process {
        # Get Device_ID from the computername
        if ($null -ne $Computername) {
            $Device_ID = (Get-SepCloudDevices -Computername $Computername).id
        }

        # Setup URI
        $URI = 'https://' + $BaseURL + "/v1/devices/$Device_ID"

        if ($null -ne $Token) {
            $Body = @{}
            $Headers = @{
                Host          = $BaseURL
                Accept        = "application/json"
                Authorization = $Token
                Body          = $Body
            }
            $Response = Invoke-RestMethod -Method GET -Uri $URI -Headers $Headers -Body $Body -UseBasicParsing
            return $Response
        }

    }
}
