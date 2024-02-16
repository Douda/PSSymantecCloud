function Move-SEPCloudDevice {
    <#
    .SYNOPSIS
    Moves one or many devices to a different group
    .DESCRIPTION
    Moves one or many devices to a different group.
    Requires group ID and device ID. does not support device name or group name.
    You can use :
        Get-SEPCloudDevice to get the device ID
        Get-SEPCloudGroup to get the group ID
    .PARAMETER GroupID
    The group ID to move the device to
    .PARAMETER DeviceID
    The device ID to move
    None
    .EXAMPLE
    Move-SEPCloudDevice -GroupID "tqrSman3RyqFFd1EqLlZZA" -DeviceID "f3teVmApQlya8XJvEf-wpw"

        Move-SEPCloudDevice -GroupID "tqrSman3RyqFFd1EqLlZZA" -DeviceID "f3teVmApQlya8XJvEf-wpw"

        device_uid             message            status
        ----------             -------            ------
        f3teVmApQlya8XJvEf-wpw Moved successfully MOVED

    Moves a device to a different group, returns the status of the move.

    .EXAMPLE
    (Get-SEPCloudDevice -Device_group "B1qWSPGeTkydCHzdfcCqpA").id | Move-SEPCloudDevice -GroupID "tqrSman3RyqFFd1EqLlZZA"

    Moves all devices from the device group ID "B1qWSPGeTkydCHzdfcCqpA" to the group ID "tqrSman3RyqFFd1EqLlZZA"
    #>

    [CmdletBinding()]
    param (
        # Group ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true
        )]
        [String]
        $GroupID,

        # Device ID
        [Parameter(
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true
        )]
        [String[]]
        $DeviceID
    )

    begin {
        # Init
        $BaseURL = (Get-ConfigurationPath).BaseUrl
        $BaseURI = 'https://' + $BaseURL + "/v1/device-groups"
        $Token = (Get-SEPCloudToken).Token_Bearer
    }

    process {
        # Setup Headers
        $Headers = @{
            Host          = $BaseURL
            Accept        = "application/json"
            Authorization = $Token
        }

        $Body = @{
            device_uids = @($DeviceID)
        }

        try {
            $params = @{
                Uri         = $BaseURI + '/' + $GroupID + '/devices'
                Method      = 'PUT'
                Body        = $Body | ConvertTo-Json -Depth 100
                Headers     = $Headers
                ContentType = "application/json"
            }

            # Run query, add it to the array, increment counter
            $Response = Invoke-RestMethod @params

        } catch {
            # If error, return the status code
            $_
        }

        # Reorder the object to match the expected output
        # $Response | ForEach-Object {
        #     $OrderedResponse = [PSCustomObject]@{
        #         device_uid = $_.devices.device_uid
        #         message    = $_.devices.message
        #         status     = $_.devices.status
        #         failed     = $_.failed
        #         succeeded  = $_.succeeded
        #     }
        # }


        # Add a PSTypeName to the object
        $Response.devices | ForEach-Object {
            $_.PSTypeNames.Insert(0, "SEPCloud.DeviceTransfer")
        }

        return $Response.devices
    }
}
