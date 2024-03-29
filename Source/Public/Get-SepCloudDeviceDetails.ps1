function Get-SepCloudDeviceDetails {
    <#
    .SYNOPSIS
        Gathers device details from the SEP Cloud console
    .DESCRIPTION
        Gathers device details from the SEP Cloud console
    .PARAMETER Device_ID
        id used to lookup a unique computer
    .PARAMETER Computername
        Computername used to lookup a unique computer
    .INPUTS
        Device_ID
        Computername
    .OUTPUTS
        PSObject
    .EXAMPLE
        Get-SepCloudDeviceDetails -id wduiKXDDSr2CVrRaqrFKNx
    .EXAMPLE
        Get-SepCloudDeviceDetails -computername MyComputer
    #>

    [CmdletBinding(DefaultParameterSetName = 'Computername')]
    param (
        # device_ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Device_ID')]
        [Alias("id")]
        [string]
        $Device_ID,

        # Computer Name
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ParameterSetName = 'Computername'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Computer', 'Device', 'Hostname', 'Host')]
        [string]
        $Computername
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        switch ($PSBoundParameters.Keys) {
            Computername {
                # Get Device_ID if computername is provided
                $Device_ID = (Get-SepCloudDevices -Computername $Computername).id
            }
            Default {}
        }

        # Setup URI
        $URI = 'https://' + $BaseURL + "/v1/devices/$Device_ID"

        # Setup Headers
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
